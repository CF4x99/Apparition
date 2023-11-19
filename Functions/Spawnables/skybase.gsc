/*
    Due To My Goal Of Allowing The Skybase To Be Used On All Maps, I Decided To Force The Player To Use A Custom Position Marker.
    You Could Easily Make It Spawn At A Specific Location On All Maps, But That Seems Pointless If The Player Is Able To Choose Their Own Position.

    Zomboss, I'm sure you're going to see this. Make sure you give proper credits for this one lol
*/

/*
    - Add Turrets to all four windows(Lasts 60 Seconds)
*/

SpawnSkybase()
{
    if(isDefined(level.spawnable["Skybase_Spawned"]))
        return;
    
    model = GetSpawnableBaseModel("vending_doubletap");
    
    self closeMenu1();
    wait 0.25;
    
    distance = 500;
    goalPos = SpawnScriptModel(GetGroundPos(self TraceBullet()), "tag_origin");
    PlayFXOnTag(level._effect["powerup_on"], goalPos, "tag_origin");

    self.menu["DisableMenuControls"] = true;
    self SetMenuInstructions("[{+attack}] - Increase Distance\n[{+speed_throw}] - Decrease Distance\n[{+activate}] - Confirm Location");

    while(1)
    {
        trace = BulletTrace(self GetWeaponMuzzlePoint(), self GetWeaponMuzzlePoint() + VectorScale(AnglesToForward(self GetPlayerAngles()), distance), 0, self);
        goalPos.origin = trace["position"];

        if(self AttackButtonPressed())
            distance += 25;
        else if(self AdsButtonPressed())
            distance -= 25;
        else if(self UseButtonPressed())
        {
            origin = trace["position"];
            level.SkybaseOrigin = origin;

            break;
        }

        if(distance < 100)
            distance = 100;
        else if(distance > 2500)
            distance = 2500;

        wait 0.01;
    }

    goalPos delete();
    self.menu["DisableMenuControls"] = undefined;
    self SetMenuInstructions();

    floor = [];
    roof = [];
    walls = [];
    corners = [];

    //These values control the size of the base
    x = 10;
    y = 5;

    //DON'T CHANGE THESE VALUES
    width = 51;
    height = 90;

    for(a = 0; a < x; a++)
        for(b = 0; b < y; b++)
            floor[floor.size] = SpawnScriptModel(origin + ((a * width), (b * height), 0), model, (0, 0, 90), 0.01);
    
    array::thread_all(floor, ::SpawnableArray, "Skybase");
    
    for(a = 0; a < x; a++)
        for(b = 0; b < y; b++)
            roof[roof.size] = SpawnScriptModel(origin + ((a * width), (b * height), (height + 35)), model, (180, 0, 90), 0.01);
    
    array::thread_all(roof, ::SpawnableArray, "Skybase");

    for(a = 0; a < 2; a++)
        for(b = 0; b < y; b++)
            walls[walls.size] = SpawnScriptModel(origin + (-25 + ((width * x) * a) + (10 * a), (b * height), 20), model, (90 - (180 * a), 0, 90), 0.01);
    
    for(a = 0; a < 2; a++)
        for(b = 0; b < (x - 4); b++)
            walls[walls.size] = SpawnScriptModel(origin + (5 + width + (b * height), (height * -1) + ((height * y) * a), 20), model, (-90 + (180 * a), 0, 0 - (180 * a)), 0.01);
    
    array::thread_all(walls, ::SpawnableArray, "Skybase");
    
    for(a = 0; a < 2; a++)
        for(b = 0; b < 2; b++)
            corners[corners.size] = SpawnScriptModel(origin + (0 - (((25 * b) + (25 * a)) - ((50 * a) * b)), (height * -1) + (15 * b) + (((height * y) - 15) * a), 44), model, (0, 0 - ((b * 90) + (a * 90)), 0), 0.01);
    
    for(a = 0; a < 2; a++)
        for(b = 0; b < 2; b++)
            corners[corners.size] = SpawnScriptModel(origin + ((width * (x - 1)) + (((36 * b) + (36 * a)) - ((72 * a) * b)), (height * -1) + (15 * b) + (((height * y) - 15) * a), 44), model, (0, 0 + ((b * 90) + (a * 90)), 0), 0.01);

    array::thread_all(corners, ::SpawnableArray, "Skybase");

    bottle = SpawnGlowingPerk(origin + (10, (55 * (y + 1)), 55));
    bottle SpawnableArray("Skybase");
}

SpawnGlowingPerk(origin)
{
    if(!isDefined(origin))
        origin = self.origin + (0, 0, 55);

    bottle = SpawnScriptModel(origin, GetSpawnableBottle());
    PlayFXOnTag(level._effect["powerup_on"], bottle, "tag_origin");
    PlayFXOnTag(level._effect["tesla_bolt"], bottle, "tag_origin");

    bottle thread ActivateGlowingPerk(origin);

    return bottle;
}

ActivateGlowingPerk(origin)
{
    self MakeUsable();
    self SetCursorHint("HINT_NOICON");
    self SetHintString("Press [{+activate}] For All Perks");

    self thread BottleTrigger();

    while(isDefined(self))
    {
        for(a = 0; a < 2; a++)
        {
            self MoveTo(origin + (0, 0, (25 - (50 * a))), 1, 0.25, 0.25);
            self RotateYaw(360, 1, 0.5, 0.5);

            wait 1;
        }
        
        wait 0.1;
    }
}

BottleTrigger()
{
    while(isDefined(self))
    {
        self waittill("trigger", player);

        if(!isDefined(self) || player isDown() || (player.perks_active.size == level.MenuPerks.size))
            continue;
        
        PlayerAllPerks(player);
    }
}

GetSpawnableBottle()
{
    for(a = 0; a < level.MenuModels.size; a++)
        if(IsSubStr(level.MenuModels[a], "perk_bottle"))
            return level.MenuModels[a];
}

SpawnSkybaseTeleporter()
{
    if(isDefined(level.spawnable["Skybase_Building"]) || isDefined(level.spawnable["Skybase_Dismantle"]) || isDefined(level.spawnable["Skybase_Deleted"]) || !isDefined(level.spawnable["Skybase_Spawned"]))
        return self iPrintlnBold("^1ERROR: ^7You Can't Use This Option Right Now");
    
    if(!isDefined(level.SkybaseTeleporters) || !level.SkybaseTeleporters.size)
    {
        traceSurface = BulletTrace(self GetWeaponMuzzlePoint(), self GetWeaponMuzzlePoint() + VectorScale(AnglesToForward(self GetPlayerAngles()), 1000000), 0, self)["surfacetype"];

        if(traceSurface == "none" || traceSurface == "default")
            return self iPrintlnBold("^1ERROR: ^7Invalid Surface");

        crosshairs = self TraceBullet();

        level.SkybaseTeleporters = [];

        for(a = 0; a < 2; a++)
            level.SkybaseTeleporters[level.SkybaseTeleporters.size] = SpawnTeleporter("Spawn", a ? (level.SkybaseOrigin + (20, -45, 45)) : (crosshairs + (0, 0, 45)), !a, true);
        
        array::thread_all(level.SkybaseTeleporters, ::SpawnableArray, "Skybase");
    }
    else
    {
        foreach(teleporter in level.SkybaseTeleporters)
            teleporter delete();
        
        level.SkybaseTeleporters = undefined;
    }
}
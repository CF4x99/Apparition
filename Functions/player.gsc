//Model Attachment Functions
PlayerAttachmentBone(tag)
{
    self.playerAttachBone = tag;
}

PlayerModelAttachment(model, player)
{
    if(!isDefined(player.ModelAttachment))
        player.ModelAttachment = [];

    player.ModelAttachment[player.ModelAttachment.size] = model + ";" + self.playerAttachBone;
    player Attach(model, self.playerAttachBone, true);
}

PlayerDetachModels(player)
{
    if(!isDefined(player.ModelAttachment) || isDefined(player.ModelAttachment) && !player.ModelAttachment.size)
        return self iPrintlnBold("^1ERROR: ^7No Attached Models Found");
    
    for(a = 0; a < player.ModelAttachment.size; a++)
    {
        attach = StrTok(player.ModelAttachment[a], ";");
        player Detach(attach[0], attach[1]);
    }

    player.ModelAttachment = undefined;
}



//Malicious Player Functions

PlayerOpenPauseMenu(player)
{
    player OpenMenu("StartMenu_Main");
}

DisableAiming(player)
{
    player.DisableAiming = isDefined(player.DisableAiming) ? undefined : true;

    if(isDefined(player.DisableAiming))
    {
        player endon("disconnect");

        while(isDefined(player.DisableAiming))
        {
            player AllowAds(false);

            wait 0.1;
        }
    }
    else
        player AllowAds(true);
}

DisableJumping(player)
{
    player.DisableJumping = isDefined(player.DisableJumping) ? undefined : true;

    if(isDefined(player.DisableJumping))
    {
        player endon("disconnect");

        while(isDefined(player.DisableJumping))
        {
            player AllowJump(false);

            wait 0.1;
        }
    }
    else
        player AllowJump(true);
}

DisableSprinting(player)
{
    player.DisableSprinting = isDefined(player.DisableSprinting) ? undefined : true;

    if(isDefined(player.DisableSprinting))
    {
        player endon("disconnect");

        while(isDefined(player.DisableSprinting))
        {
            player AllowSprint(false);

            wait 0.1;
        }
    }
    else
        player AllowSprint(true);
}

DisableOffhands(player)
{
    player.DisableOffhands = isDefined(player.DisableOffhands) ? undefined : true;

    if(isDefined(player.DisableOffhands))
    {
        player endon("disconnect");

        while(isDefined(player.DisableOffhands))
        {
            player DisableOffHandWeapons();

            wait 0.1;
        }
    }
    else
        player EnableOffHandWeapons();
}

DisableWeaps(player)
{
    player.DisableWeaps = isDefined(player.DisableWeaps) ? undefined : true;

    if(isDefined(player.DisableWeaps))
    {
        player endon("disconnect");

        while(isDefined(player.DisableWeaps))
        {
            player DisableWeapons();

            wait 0.1;
        }
    }
    else
        player EnableWeapons();
}

SetPlayerStance(stance, player)
{
    player SetStance(ToLower(stance));
}

LaunchPlayer(player)
{
    player SetOrigin(player.origin + (0, 0, 5));
    player SetVelocity(player GetVelocity() + (RandomIntRange(-500, 500), RandomIntRange(-500, 500), RandomIntRange(1500, 5000)));
}

MortarStrikePlayer(player)
{
    player endon("disconnect");

    for(a = 0; a < 3; a++)
    {
        MagicBullet(GetWeapon("launcher_standard"), player.origin + (0, 0, 2500), player.origin);

        wait 0.15;
    }
}

FlashLoop(player)
{
    player.FlashLoop = isDefined(player.FlashLoop) ? undefined : true;

    if(isDefined(player.FlashLoop))
    {
        player endon("disconnect");

        while(isDefined(player.FlashLoop))
        {
            player ShellShock("concussion_grenade_mp", 5);

            wait 5;
        }
    }
    else
        player StopShellShock();
}

ApplyShellShock(shock, player)
{
    switch(shock)
    {
        case "Concussion Grenade":
            shock = "concussion_grenade_mp";
            break;
        
        case "Zombie Death":
            shock = "zombie_death";
            break;
        
        case "Explosion":
            shock = "explosion";
            break;
        
        default:
            break;
    }

    player ShellShock(shock, player.ShellShockTime);
}

SetShellShockTime(time, player)
{
    player.ShellShockTime = time;
}

SpinPlayer(player)
{
    player.SpinPlayer = isDefined(player.SpinPlayer) ? undefined : true;

    player endon("disconnect");

    while(isDefined(player.SpinPlayer))
    {
        player SetPlayerAngles(player GetPlayerAngles() + (0, 25, 0));
        
        wait 0.01;
    }
}

BlackScreenPlayer(player)
{
    player.BlackScreen = isDefined(player.BlackScreen) ? undefined : true;

    if(isDefined(player.BlackScreen))
    {
        if(!isDefined(player.BlackScreenHud))
            player.BlackScreenHud = [];

        for(a = 0; a < 2; a++)
            player.BlackScreenHud[player.BlackScreenHud.size] = player createRectangle("CENTER", "CENTER", 0, 0, 1000, 1000, (0, 0, 0), 0, 1, "black");
    }
    else
        destroyAll(player.BlackScreenHud);
}

FakeLag(player)
{
    player.FakeLag = isDefined(player.FakeLag) ? undefined : true;

    player endon("disconnect");

    while(isDefined(player.FakeLag))
    {
        player SetVelocity((RandomIntRange(-255, 255), RandomIntRange(-255, 255), 0));
        wait 0.25;

        player SetVelocity((0, 0, 0));
        wait 0.025;
    }
}

AttachSelfToPlayer(player)
{
    if(player == self)
        return self iPrintlnBold("^1ERROR: ^7You Can't Attach To Yourself");
    
    if(!Is_Alive(player))
        return self iPrintlnBold("^1ERROR: ^7Player Isn't Alive");

    self.AttachToPlayer = isDefined(self.AttachToPlayer) ? undefined : true;

    if(isDefined(self.AttachToPlayer))
    {
        player endon("disconnect");

        while(isDefined(self.AttachToPlayer))
        {
            if(!self IsLinkedTo(player))
                self PlayerLinkTo(player, "j_head");
            
            if(!Is_Alive(player))
                self thread AttachSelfToPlayer(player);

            wait 0.1;
        }
    }
    else
        self Unlink();
}

PlayerMountCamera(tag, player)
{
    if(isDefined(player.SpecNade) && !isDefined(player.PlayerMountCamera))
        return self iPrintlnBold("^1ERROR: ^7You Can't Use This Option While Spec-Nade Is Enabled");
    
    if(isDefined(player.DropCamera) && !isDefined(player.PlayerMountCamera))
        return self iPrintlnBold("^1ERROR: ^7You Can't Use This Option While Drop Camera Is Enabled");
    
    if(tag != "Disable")
    {
        if(isDefined(player.PlayerMountCamera))
        {
            player CameraActivate(false);
        
            if(isDefined(player.camlinker))
                player.camlinker delete();
        }

        player.PlayerMountCamera = true;

        player.camlinker = SpawnScriptModel((player GetTagOrigin(tag) + (AnglesToForward(player GetPlayerAngles()) * 9)), "tag_origin");
        player.camlinker LinkToBlendToTag(player, tag);

        player CameraSetPosition(player.camlinker);
        player CameraActivate(true);
    }
    else
    {
        player CameraActivate(false);
        
        if(isDefined(player.camlinker))
            player.camlinker delete();
        
        player.PlayerMountCamera = undefined;
    }
}

PlayerDropCamera(player)
{
    if(isDefined(player.SpecNade) && !isDefined(player.DropCamera))
        return self iPrintlnBold("^1ERROR: ^7You Can't Use This Option While Spec-Nade Is Enabled");
    
    if(isDefined(player.PlayerMountCamera) && !isDefined(player.DropCamera))
        return self iPrintlnBold("^1ERROR: ^7You Can't Use This Option While Mount Camera Is Enabled");
    
    player.DropCamera = isDefined(player.DropCamera) ? undefined : true;

    if(isDefined(player.DropCamera))
    {
        player.camlinker = SpawnScriptModel(player GetTagOrigin("j_head"), "tag_origin");

        player CameraSetPosition(player.camlinker);
        player CameraActivate(true);

        player.camlinker Launch(VectorScale(AnglesToForward(self GetPlayerAngles()), 10));
    }
    else
    {
        player CameraActivate(false);

        if(isDefined(player.camlinker))
            player.camlinker delete();
    }
}

JumpScarePlayer(player)
{
    if(isDefined(player.JumpScarePlayer))
        return;
    player.JumpScarePlayer = true;

    player endon("disconnect");

    player.var_92fcfed8 = player OpenLUIMenu((ReturnMapName(level.script) == "Shadows Of Evil") ? "JumpScare" : "JumpScare-Tomb");

    wait 0.55;

    if(isDefined(player.var_92fcfed8))
        player CloseLUIMenu(player.var_92fcfed8);
    
    player.JumpScarePlayer = undefined;
}

FakeDerank(player)
{
    player SetRank(0, 0);
    player iPrintlnBold("You Have Been ^1Deranked");
}

FakeDamagePlayer(player)
{
    player FakeDamageFrom((RandomIntRange(-100, 100), RandomIntRange(-100, 100), RandomIntRange(-100, 100)));
}

CrashPlayer(player)
{
    if(player IsHost() || player isDeveloper())
        return self iPrintlnBold("^1ERROR: ^7Can't Crash Player");
    
    player iPrintlnBold("^B");
}

ShowPlayerIP(showto, player)
{
    showto = (showto == "self") ? self : player;

    showto iPrintlnBold(StrTok(player GetIPAddress(), "Public Addr: ")[0]);
}


//Miscellaneous Player Functions
MessagePlayer(msg, player)
{
    player iPrintlnBold("^2" + CleanName(self getName()) + ": ^7" + msg);
}

FreezePlayer(player)
{
    player.FreezePlayer = isDefined(player.FreezePlayer) ? undefined : true;

    if(isDefined(player.FreezePlayer))
    {
        player endon("disconnect");

        while(isDefined(player.FreezePlayer))
        {
            player FreezeControls(true);
            wait 0.1;
        }
    }
    else
        player FreezeControls(false);
}

KickPlayer(player)
{
    if(player IsHost())
        return self iPrintlnBold("^1ERROR: ^7You Can't Kick The Host");
    
    if(player isDeveloper())
        return self iPrintlnBold("^1ERROR: ^7You Can't Kick The Developer");
    
    Kick(player GetEntityNumber(), "EXE_PLAYERKICKED_NOTSPAWNED");
}

BanPlayer(player)
{
    if(player IsHost())
        return self iPrintlnBold("^1ERROR: ^7You Can't Ban The Host");
    
    if(player isDeveloper())
        return self iPrintlnBold("^1ERROR: ^7You Can't Ban The Developer");
    
    SetDvar("Apparition_" + player GetXUID(), "Banned");
    Kick(player GetEntityNumber(), "EXE_PLAYERKICKED_NOTSPAWNED");
    
    self iPrintlnBold(CleanName(player getName()) + " Has Been ^1Temp Banned");
}
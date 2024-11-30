/*
    Menu:                 Apparition
    Developer:            CF4_99
    Version:              1.5.0.8
    Discord:              cf4_99
    YouTube:              https://www.youtube.com/c/CF499
    Project Start Date:   6/10/21
    Initial Release Date: 1/29/23

    Menu Source & Current Update: https://github.com/CF4x99/Apparition
    IF YOU USE ANY SCRIPTS FROM THIS PROJECT, OR MAKE AN EDIT, LEAVE CREDIT.

    NOTE:
        I Can Without A Doubt Say Apparition Will Be Unmatched In Every Possible Way.
        It Will Be The Most Stable, In-Depth, Detail Oriented, Organized, and Largest Mod Menu You Will Ever See.
        I Have Spent Countless Hours Over The Years Getting Apparition To Where It Is, Which Includes On Other Games As Well(Newer and Older).

        You Won't Find Anything That Will Be Comparable To Apparition, Not Even The Menus With "Devs" That Constantly Have To Rip Scripts From Apparition For Their Projects.
        Apparition Will Remain On Top, Regardless Of Who Tries To Compete With It.

        Since There Has Been Confusion and Accusations, Apparition(including the base) Belongs To Me(CF4_99) and Me Only. I have built it 100%, from the ground up.
        I Am The Sole Developer Of Apparition, No One Else Helps With it, Or Provides Scripts.
        The Credits Below Says Exactly What These People Offered Apparition, Nothing More, Nothing Less.


    Credits:
        - CF4_99 ~ Project Developer
        - Extinct ~ Ideas, Suggestions, Constructive Criticism, and His Spec-Nade
        - CraftyCritter ~ BO3 Compiler
        - ItsFebiven ~ Some Ideas and Suggestions
        - Joel ~ Suggestions, Bug Reports, and Testing The Unique String Crash Protection


    Custom Maps:
        While I have tested Apparition a lot on custom maps, you may run into some issues with a few options not working 100% as they should.

        Known Issues On Custom Maps(Ones that can't, or won't, be fixed):

            Weaponry - Not all weapons are in the right category(Also applies to custom weapon mods):
                ~ I am aware of this. There isn't anything I can do about it. Most of them, if not all, are moved into the 'Specials' Category.


    Map EE Options:
        I have created scripts to complete the EE's for the classic maps that have smaller EE's.
        As for the bigger maps that have bigger and more complex EE's, I have made scripts to make completing the EE's, a lot easier.
        The EE scripts will complete steps properly, not just set flags/variables tricking the game into thinking the step is completed, when it actually hasn't(unlike other "developers")
        This will prevent any issues with crashes/conflictions later on while continuing regular gameplay/playing through other parts of the EE.

        Where to find options that help completing EE's:
            Main Menu -> [map name] Scripts
            Server Modifications -> Craftables
        
    Craftables:
        Not all craftables will be found in the Craftables menu
        Some craftables have to be added and collected manually
        So if you can't find a craftable in the Craftables menu, check the map scripts menu
        If it's not found in Craftables, or the map scripts menu, then it's a craftable that would have to be added manually, and I haven't made a script to collect the parts yet


    If you find any bugs, or come across something that you feel isn't working as it should, please message me on discord.

    Discord: cf4_99
*/

#include scripts\zm\_zm;
#include scripts\zm\_util;
#include scripts\zm\_zm_net;
#include scripts\zm\_zm_bgb;
#include scripts\zm\_zm_audio;
#include scripts\zm\_zm_score;
#include scripts\zm\_zm_stats;
#include scripts\zm\_zm_perks;
#include scripts\zm\_zm_weapons;
#include scripts\zm\_zm_utility;
#include scripts\zm\_zm_zonemgr;
#include scripts\zm\_zm_spawner;
#include scripts\zm\_zm_blockers;
#include scripts\zm\_zm_powerups;
#include scripts\zm\_zm_behavior;
#include scripts\zm\_zm_magicbox;
#include scripts\zm\_zm_equipment;
#include scripts\zm\_zm_laststand;
#include scripts\zm\_zm_unitrigger;
#include scripts\zm\_zm_placeable_mine;
#include scripts\zm\gametypes\_globallogic;
#include scripts\zm\bgbs\_zm_bgb_reign_drops;
#include scripts\zm\craftables\_zm_craftables;
#include scripts\zm\_zm_powerup_weapon_minigun;
#include scripts\zm\gametypes\_globallogic_score;

#include scripts\shared\ai_shared;
#include scripts\shared\bots\_bot;
#include scripts\shared\hud_shared;
#include scripts\shared\lui_shared;
#include scripts\shared\aat_shared;
#include scripts\shared\util_shared;
#include scripts\codescripts\struct;
#include scripts\shared\math_shared;
#include scripts\shared\flag_shared;
#include scripts\shared\rank_shared;
#include scripts\shared\_burnplayer;
#include scripts\shared\scene_shared;
#include scripts\shared\array_shared;
#include scripts\shared\system_shared;
#include scripts\shared\ai\systems\gib;
#include scripts\shared\spawner_shared;
#include scripts\shared\vehicle_shared;
#include scripts\shared\ai\zombie_death;
#include scripts\shared\hud_util_shared;
#include scripts\shared\exploder_shared;
#include scripts\shared\gameskill_shared;
#include scripts\shared\laststand_shared;
#include scripts\shared\ai\zombie_shared;
#include scripts\shared\callbacks_shared;
#include scripts\shared\ai\zombie_utility;
#include scripts\shared\tweakables_shared;
#include scripts\shared\ai\systems\shared;
#include scripts\shared\vehicle_ai_shared;
#include scripts\shared\scoreevents_shared;
#include scripts\shared\clientfield_shared;
#include scripts\shared\visionset_mgr_shared;
#include scripts\shared\damagefeedback_shared;
#include scripts\shared\abilities\_ability_power;

#namespace duplicate_render;

autoexec __init__system__()
{
    system::register("duplicate_render", ::__init__, undefined, undefined);
}

__init__()
{
    callback::on_start_gametype(::init);
    callback::on_spawned(::onPlayerSpawned);
}

init()
{
    level DefineOnce();

    if(isDefined(level.overrideplayerdamage))
        level.saved_overrideplayerdamage = level.overrideplayerdamage;

    level.overrideplayerdamage = ::override_player_damage;

    if(isDefined(level.global_damage_func))
        level.saved_global_damage_func = level.global_damage_func;
    
    level.global_damage_func = ::override_zombie_damage;

    if(isDefined(level.global_damage_func_ads))
        level.saved_global_damage_func_ads = level.global_damage_func_ads;
    
    level.global_damage_func_ads = ::override_zombie_damage_ads;

    if(isDefined(level.callbackactorkilled))
        level.saved_callbackactorkilled = level.callbackactorkilled;
    
    level.callbackactorkilled = ::override_actor_killed;

    if(isDefined(level.callbackplayerdisconnect))
        level.saved_callbackplayerdisconnect = level.callbackplayerdisconnect;
    
    level.callbackplayerdisconnect = ::override_player_disconnect;
    
    level.custom_game_over_hud_elem = ::override_game_over_hud_elem;
    level.player_score_override = ::override_player_points;
}

onPlayerSpawned()
{
    self endon("disconnect");

    if(Is_True(self.runningSpawned))
        return;
    self.runningSpawned = true;
    
    if(self IsHost() && !isDefined(self.playerSpawned))
    {
        if(!Is_True(level.AntiEndGame))
            self thread AntiEndGame();
        
        if(!Is_True(level.GSpawnProtection))
            self thread GSpawnProtection();
        
        level.player_out_of_playable_area_monitor = 0;
        level.player_out_of_playable_area_monitor_callback = ::player_out_of_playable_area_monitor;
    }

    self thread GivePlayerLoadout();

    level flag::wait_till("initial_blackscreen_passed");

    self AllowWallRun(0);
    self AllowDoubleJump(0);

    self.StartOrigin = self.origin;
    self notify("stop_player_out_of_playable_area_monitor");

    if(GetDvarString(level.script + "Spawn" + self GetEntityNumber()) != "")
        self SetOrigin(GetDvarVector1(level.script + "Spawn" + self GetEntityNumber()));
    
    self.runningSpawned = BoolVar(self.runningSpawned);

    //Anthing Above This Is Ran Every Time The Player Spawns
    if(isDefined(self.playerSpawned))
        return;
    self.playerSpawned = true;

    if(self IsHost())
    {
        level DefineMenuArrays();

        //If there is an unknown map detected(custom map) it will display this note to the host.
        if(ReturnMapName(level.script) == "Unknown")
            self DebugiPrint("^1" + ToUpper(level.menuName) + ": ^7On Custom Maps, Some Things Might Not Work As They Should.");
    }
    
    self playerSetup();
}

DefineOnce()
{
    if(isDefined(level.DefineOnce))
        return;
    level.DefineOnce = true;
    
    level.menuName    = "Apparition";
    level.menuVersion = "1.5.0.8";
    level.MenuStatus  = Array("Bot", "None", "Verified", "VIP", "Admin", "Co-Host", "Host", "Developer");
    level.colorNames  = Array("Ciper Purple", "xbOnline Blue", "Skyblue", "Pink", "Green", "Brown", "Blue", "Red", "Orange", "Purple", "Cyan", "Yellow", "Black", "White");
    level.colors      = Array(100, 0, 100, 57, 152, 254, 135, 206, 250, 255, 110, 255, 0, 255, 0, 101, 67, 33, 0, 0, 255, 255, 0, 0, 255, 128, 0, 100, 0, 255, 0, 255, 255, 255, 255, 0, 0, 0, 0, 255, 255, 255);
    
    level thread RGBFade();
}

DefineMenuArrays()
{
    if(isDefined(level.MenuArraysDefined))
        return;
    level.MenuArraysDefined = true;
    
    level.BgGravity = GetDvarInt("bg_gravity");
    level.GSpeed = GetDvarString("g_speed");
    
    level.MenuPerks = [];
    perks = GetArrayKeys(level._custom_perks);

    for(a = 0; a < perks.size; a++)
        array::add(level.MenuPerks, perks[a], 0);
    
    level.MenuBGB = [];
    bgb = GetArrayKeys(level.bgb);

    for(a = 0; a < bgb.size; a++)
        array::add(level.MenuBGB, bgb[a], 0);
    
    level.MenuVOXCategory = [];

    foreach(category, sound in level.sndplayervox)
        array::add(level.MenuVOXCategory, CleanString(category, true), 0);
    
    map = ReturnMapName(level.script);

    if(map != "Unknown") //Feel free to add your own custom teleport locations
    {
        //Teleport Name, Followed By The Origin
        //[< teleport location name >, < (x, y, z) origin >]

        switch(map)
        {
            case "Shadows Of Evil":
                locations = Array("Spawn", (1077.87, -5364.46, 124.719), "Pack 'a' Punch", (2614.68, -2348.33, -351.875), "Prison", (3007, -6542, 296.125));
                break;
            
            case "The Giant":
                locations = Array("Spawn", (-56.6293, 286.99, 98.125), "Power", (529.258, -1835.94, 61.6158), "Pack 'a' Punch", (-53.7356, 499.323, 101.125), "Prison", (-93.9053, -3268.56, -104.875));
                break;
            
            case "Der Eisendrache":
                locations = Array("Spawn", (421.786, 559.05, -47.875), "Power", (-27.8228, 2784.15, 848.125), "Boss Fight Room", (-3182.63, 6962.58, -252.375), "Time Travel Room", (-278.407, 5001.93, 152.125), "Prison", (917.821, 912.26, 144.125));
                break;
            
            case "Zetsubou No Shima":
                locations = Array("Spawn", (393.455, -3181.32, -501.117), "Power", (-1475.2, 3456.67, -426.877), "Pack 'a' Punch", (246.815, 3818.53, -503.875), "Prison", (2608, 1135, -175.875));
                break;
            
            case "Gorod Krovi":
                locations = Array("Spawn", (-144, -184, 0.125), "Power", (102, 4969, 144.125), "Pack 'a' Punch", (-2967, 21660, 0.125), "Prison", (-2152, 3644, 160.125));
                break;
            
            case "Revelations":
                locations = Array("Spawn", (-4812, 72, -451.2), "Pack 'a' Punch", (819, 145, -3301.9), "Origins", (-3006, 3470, 1066), "Nacht Der Untoten", (109, 448, -379.6), "Verruckt", (5027, -2366, 230), "Kino Der Toten", (-1393, -9218, -1663.5), "Shangri-La", (-2023, -4151, -1699.5), "Mob Of The Dead", (478, 3301, 1264.125), "Prison", (154, 474, -740.125));
                break;
            
            case "Nacht Der Untoten":
                locations = Array("Spawn", (53, 415, 5.25), "Prison", (-162, -396, 1.125));
                break;
            
            case "Verruckt":
                locations = Array("Spawn", (1097, 302, 64.125), "Power", (-357, -219, 226.125), "Prison", (1154, 791, 64.125));
                break;
            
            case "Shi No Numa":
                locations = Array("Spawn", (10267, 514, -528.875), "Out Of The Map", (12374, 4523, -664.875), "Under The Map", (11838, -1614, -1217.94), "Prison", (12500, -939, -644.875));
                break;
            
            case "Kino Der Toten":
                locations = Array("Spawn", (13.2366, -1262.8, 90.125), "Power", (-619.298, 1391.23, -15.875), "Pack 'a' Punch", (5.74551, -376.756, 320.125), "Air Force Room", (1154.75, 2650.46, -367.875), "Surgical Room", (1948.13, -2204.91, 136.125), "Samantha's Room", (-2636.31, 189.825, 52.125), "Samantha's Red Room", (-2620.55, -1106.91, 53.3851), "Prison", (-1590.36, -4760.5, -167.875));
                break;
            
            case "Ascension":
                locations = Array("Spawn", (-512, 3, -484.875), "Power", (-464, 1028, 220.125), "Pack 'a' Punch", (487, 389, -303.875), "Prison", (-228, 1306, -485.875));
                break;
            
            case "Shangri-La":
                locations = Array("Spawn", (-10, -740, 20.125), "Pack 'a' Punch", (-2, 381, 289.125), "Prison", (1052, 1275, -547.875));
                break;
            
            case "Moon":
                locations = Array("Earth Spawn", (22250, -38663, -679.875), "Moon Spawn", (-4, 32, -1.875), "Power", (42, 3100, -587.875), "Dome", (-162, 6893, 0.45), "Prison", (743, 966, -220.875));
                break;
            
            case "Origins":
                locations = Array("Spawn", (2698.43, 5290.48, -346.219), "Staff Chamber", (-2.4956, -2.693, -751.875), "The Crazy Place", (10334.5, -7891.93, -411.875), "Lightning Tunnel", (-3234, -372, -188), "Wind Tunnel", (3330, 1227, -343), "Fire Tunnel", (3064, 4395, -599), "Ice Tunnel", (1431, -1728, -121), "Robot Head: Odin", (-6759.17, -6541.72, 159.375), "Robot Head: Thor", (-6223.59, -6547.65, 159.375), "Robot Head: Freya", (-5699.83, -6540.03, 159.375), "Prison", (-3142.11, 1125.09, -63.875));
                break;
            
            default:
                break;
        }

        if(isDefined(locations) && locations.size)
            level.menuTeleports = locations;
    }
    
    level.MenuModels = Array("defaultactor", "defaultvehicle");
    ents = GetEntArray("script_model", "classname");

    for(a = 0; a < ents.size; a++)
        if(ents[a].model != "tag_origin" && ents[a].model != "" && !IsSubStr(ents[a].model, "collision_"))
            array::add(level.MenuModels, ents[a].model, 0);
    
    level.MenuEffects = [];
    fxs = GetArrayKeys(level._effect);

    for(a = 0; a < fxs.size; a++)
    {
        if(!isDefined(fxs[a]))
            continue;
        
        if(IsSubStr(fxs[a], "step_") || IsSubStr(fxs[a], "fall_") || IsSubStr(fxs[a], "tesla_viewmodel") || isInArray(level.MenuEffects, fxs[a]))
            continue;
        
        level.MenuEffects[level.MenuEffects.size] = fxs[a];
    }
    
    level.customBoxWeapons = [];
    weapons = GetArrayKeys(level.zombie_weapons);

    for(a = 0; a < weapons.size; a++)
        if(isDefined(weapons[a]) && isDefined(level.zombie_weapons[weapons[a]].is_in_box) && level.zombie_weapons[weapons[a]].is_in_box)
            array::add(level.customBoxWeapons, weapons[a], 0);
    
    level.MenuSpawnPoints = ArrayCombine(struct::get_array("player_respawn_point_arena", "targetname"), struct::get_array("player_respawn_point", "targetname"), 0, 1);
    
    trapTypes = Array("zombie_trap", "gas_access", "trap_electric", "trap_fire", "use_trap_chain");
    level.MenuZombieTraps = [];

    for(a = 0; a < trapTypes.size; a++)
    {
        traps = GetEntArray(trapTypes[a], "targetname");

        if(isDefined(traps) && traps.size)
        {
            for(b = 0; b < traps.size; b++)
            {
                //This will ensure that traps with more than one trigger, aren't added more than once.
                if(level.MenuZombieTraps.size && isDefined(traps[b].prefabname) && isDefined(level.MenuZombieTraps[(level.MenuZombieTraps.size - 1)].prefabname) && level.MenuZombieTraps[(level.MenuZombieTraps.size - 1)].prefabname == traps[b].prefabname)
                    continue;
                
                array::add(level.MenuZombieTraps, traps[b], 0);
            }
        }
    }

    foreach(DeathBarrier in GetEntArray("trigger_hurt", "classname"))
        DeathBarrier delete();
    
    //this will save the origin/angles of doors to be used by moon doors
    if(ReturnMapName(level.script) != "Moon" && ReturnMapName(level.script) != "Origins")
    {
        types = Array("zombie_door", "zombie_airlock_buy");
        validScriptStrings = Array("rotate", "slide_apart", "move");

        for(a = 0; a < types.size; a++)
        {
            doors = GetEntArray(types[a], "targetname");
            
            if(!isDefined(doors))
                continue;
            
            for(b = 0; b < doors.size; b++)
            {
                if(!isDefined(doors[b]))
                    continue;
                
                for(c = 0; c < doors[b].doors.size; c++)
                {
                    if(!isDefined(doors[b].doors[c]) || !isInArray(validScriptStrings, doors[b].doors[c].script_string))
                        continue;
                    
                    if(doors[b].doors[c].script_string == "slide_apart" || doors[b].doors[c].script_string == "move")
                        doors[b].doors[c].savedOrigin = doors[b].doors[c].origin;
                    else
                        doors[b].doors[c].savedAngles = doors[b].doors[c].angles;
                }
            }
        }
    }

    level.savedJokerModel = level.chest_joker_model;
    
    SetDvar("wallRun_maxTimeMs_zm", 10000);
    SetDvar("playerEnergy_maxReserve_zm", 200);
    SetDvar("doublejump_enabled", 1);
    SetDvar("playerEnergy_enabled", 1);
    SetDvar("wallrun_enabled", 1);
}

playerSetup()
{
    if(isDefined(self.menuThreaded))
        return;
    self.menuThreaded = true;
    
    self endon("disconnect");
    
    self defineVariables();
    self.hud_count = 0;

    if(self util::is_bot())
    {
        self.verification = level.MenuStatus[0];
        return;
    }

    dvar = GetDvarInt("ApparitionV_" + self GetXUID());
    self.verification = self isDeveloper() ? level.MenuStatus[(level.MenuStatus.size - 1)] : self IsHost() ? level.MenuStatus[(level.MenuStatus.size - 2)] : (isDefined(dvar) && dvar != "" && Int(dvar) != 0) ? level.MenuStatus[Int(dvar)] : level.MenuStatus[1];
    
    if(self hasMenu())
    {
        self thread MenuInstructionsDisplay();
        self thread menuMonitor();
    }
}
 
defineVariables()
{
    if(isDefined(self.DefinedVariables))
        return;
    self.DefinedVariables = true;
    
    self.menuHud = [];
    self.menuParent = [];
    self.menuParentQM = [];
    self.menuCurs = [];
    self.menuSS = [];
    
    //Menu Design Variables
    self LoadMenuVars();
}

MenuInstructionsDisplay()
{
    self endon("disconnect");
    
    if(Is_True(self.MenuInstructionsDisplay))
        return;
    self.MenuInstructionsDisplay = true;
    
    while(1)
    {
        if(self hasMenu() && (!Is_True(self.DisableMenuInstructions) && (!isDefined(self.MenuInstructionsBG) || !isDefined(self.MenuInstructionsBGOuter) || !isDefined(self.MenuInstructions))))
        {
            if(!Is_True(self.DisableMenuInstructions))
            {
                if(!isDefined(self.MenuInstructionsBG))
                    self.MenuInstructionsBG = self createRectangle("TOP_LEFT", "CENTER", -100, 230, 0, 15, (0, 0, 0), 2, 1, "white");
                
                if(!isDefined(self.MenuInstructionsBGOuter))
                    self.MenuInstructionsBGOuter = self createRectangle("TOP_LEFT", "CENTER", -101, 229, 0, 17, self.MainColor, 1, 1, "white");
                
                if(!isDefined(self.MenuInstructions))
                    self.MenuInstructions = self createText("default", 1.1, 3, "", "LEFT", "CENTER", (self.MenuInstructionsBG.x + 1), (self.MenuInstructionsBG.y + 7), 1, (1, 1, 1));
            }
        }

        if(isDefined(self.MenuInstructions) && Is_True(self.DisableMenuInstructions) || !self hasMenu() || !Is_Alive(self) && !Is_True(self.refreshInstructions))
        {
            if(Is_True(self.DisableMenuInstructions) || !self hasMenu() || !Is_Alive(self) && !Is_True(self.refreshInstructions))
            {
                if(isDefined(self.MenuInstructions))
                    self.MenuInstructions DestroyHud();

                if(isDefined(self.MenuInstructionsBG))
                    self.MenuInstructionsBG DestroyHud();
                
                if(isDefined(self.MenuInstructionsBGOuter))
                    self.MenuInstructionsBGOuter DestroyHud();
            }
            
            if(!self hasMenu())
                break;
            
            if(!Is_Alive(self) && !Is_True(self.refreshInstructions))
                self.refreshInstructions = true; //Instructions Need To Be Refreshed To Make Sure They Are Archived Correctly To Be Shown While Dead
        }

        if(Is_Alive(self) && Is_True(self.refreshInstructions))
            self.refreshInstructions = BoolVar(self.refreshInstructions);
        
        if(isDefined(self.MenuInstructions))
        {
            if(Is_Alive(self))
            {
                if(!isDefined(self.MenuInstructionsString))
                {
                    if(!self isInMenu(true))
                    {
                        str = "[{+speed_throw}] & [{+melee}]: Open " + level.menuName;

                        if(!Is_True(self.DisableQM))
                            str += "\n[{+speed_throw}] & [{+smoke}]: Open Quick Menu";
                    }
                    else
                        str = "[{+attack}]/[{+speed_throw}]: Scroll\n[{+actionslot 3}]/[{+actionslot 4}]: Slider Left/Right\n[{+activate}]: Select\n[{+melee}]: Go Back/Exit";
                }
                else
                    str = self.MenuInstructionsString;
            }
            else
            {
                str = "[{+speed_throw}] & [{+gostand}]: Open Quick Menu";

                if(self isInMenu(true))
                    str = "[{+attack}]/[{+speed_throw}]: Scroll\n[{+actionslot 3}]/[{+actionslot 4}]: Slider Left/Right\n[{+activate}]: Select\n[{+gostand}]: Exit";
            }
            
            if(self.MenuInstructions.text != str)
                self.MenuInstructions SetTextString(str);
            
            width = self.MenuInstructions GetTextWidth3arc(self);
            height = IsSubStr(str, "\n") ? (CorrectNL_BGHeight(str) - 5) : CorrectNL_BGHeight(str);
            
            if(self.MenuInstructionsBG.width != width || self.MenuInstructionsBG.height != height)
            {
                self.MenuInstructionsBG SetShaderValues(undefined, width, height);
                self.MenuInstructionsBGOuter SetShaderValues(undefined, (width + 2), (height + 2));
            }

            if(self.MenuInstructionsBG.y != (230 - height))
            {
                self.MenuInstructionsBG.y = (230 - height);
                self.MenuInstructionsBGOuter.y = (229 - height);
                self.MenuInstructions.y = (self.MenuInstructionsBG.y + 6);
            }
        }

        wait 0.1;
    }
}

SetMenuInstructions(text)
{
    self.MenuInstructionsString = (!isDefined(text) || text == "") ? undefined : text;
}

override_player_disconnect()
{
    foreach(player in level.players)
    {
        if(!player hasMenu() || !isDefined(player) || player == self)
            continue;
        
        //If a player is navigating another players options, and that player disconnects, it will kick them back to the player menu
        if(isDefined(player.menuParent) && isInArray(player.menuParent, "Players") && player.SelectedPlayer == self)
        {
            openMenu = player isInMenu(false);

            if(openMenu)
                player thread closeMenu1();
            
            player.menuParent = [];
            player.currentMenu = "Players";
            player.menuParent[player.menuParent.size] = "Main";

            if(openMenu)
            {
                player thread openMenu1();
                player iPrintlnBold("^1ERROR: ^7Player Has Disconnected");
            }
        }
        else if(player isInMenu() && player getCurrent() == "Players") //If a player is viewing the player menu when a player disconnects, it will refresh the options
            player RefreshMenu();
    }

    if(isDefined(level.saved_callbackplayerdisconnect))
        self [[ level.saved_callbackplayerdisconnect ]]();
}
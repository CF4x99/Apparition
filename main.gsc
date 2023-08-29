/*
    Menu:                 Apparition
    Developer:            CF4_99
    Version:              1.1.9.0
    Project Start Date:   6/10/21
    Initial Release Date: 1/29/23
    
    Menu Source & Current Update: https://github.com/CF4x99/Apparition
    Make sure you check my github link for updates. This menu is updated often.

    IF YOU USE ANY SCRIPTS FROM THIS PROJECT, OR MAKE AN EDIT, LEAVE CREDIT.

    Discord:            cf4_99
    Apparition Discord: https://discord.gg/NExXdMhDnW
    YouTube:            https://www.youtube.com/c/CF499
    MXT Server:         https://discord.gg/MXT

    If you are using Crafty's Compiler/Injector, make sure you have the latest build. If not, you will get a syntax error.
    Latest Build: https://github.com/LJW-Dev/Black-Ops-3-GSC-Compiler/releases/latest


    Controls:
        - Apparition: Aim & Knife
        - Quick Menu: Aim & Secondary Offhand Button
        - Scroll: Aim/Shoot Or Actionslots 1 & 2(Controller Users: Dpad up/down)
        - Slider Scroll: Actionslot 3 & 4(Controller Users: Dpad left/right)
        - Select: Use Button(PlayStation Controller: Square || Xbox Controller: X)
        - Go Back/Exit: Knife
    

    Credits:
        - CF4_99 ~ Project Developer
        - Extinct ~ Ideas, Suggestions, Constructive Criticism, and His Spec-Nade
        - CraftyCritter ~ BO3 Compiler
        - ItsFebiven ~ Some Ideas and Suggestions
        - Joel ~ Suggestions, Bug Reports, and Testing The Unique String Crash Protection

    IF YOU USE ANY SCRIPTS FROM THIS PROJECT, OR MAKE AN EDIT, LEAVE CREDIT.



    Apparition has been in development for a long time(too long).
    While I haven't spent every second of every day on this project, a lot of time and work has gone into it.
    Every step of the way, I have tried to make it one of the biggest, and best menus for BO3 Zombies.
    I have spent countless hours not only developing, but also bug testing every option in this menu.
    While I don't think it will ever officially be finished, I thought it was in a good state to be released.

    While I do test everything I add, or change, there are probably things I have missed.
    If you come across any bugs, please message me on discord.



    Custom Maps:
        While I have tested Apparition a lot on custom maps, you may run into some issues with a few options not working 100% as they should.

        Known Issues On Custom Maps(Ones that can't, or won't, be fixed):

            Weaponry - Not all weapons are in the right category(Also applies to custom weapon mods):
                ~ I am aware of this. There isn't anything I can do about it. Most of them, if not all, are moved into the 'Specials' Category.



    Map EE Options:
        I have created scripts to complete the EE's for the classic maps that have smaller EE's.
        As for the bigger maps that have bigger and more complex EE's, I have made scripts to make completing the EE's, a lot easier.
        The reason for me not adding an option to complete the whole EE for bigger maps, isn't because I can't do it.
        It saves myself time, which I don't have a lot of.

        If I missed something that would help with EE's, or you just want to request a USEFUL script, feel free to message me on discord.

        Where to find options that help completing EE's:
            Main Menu -> [map name] Scripts
            Server Modifications -> Craftables
        
        Whole EE's Completed:
            - The Giant
            - Nacht Der Untoten
            - Verruckt
            - Shi No Numa
            - Kino Der Toten



    If you find any bugs, or come across something that you feel isn't working as it should, please message me on discord.

    IF YOU USE ANY SCRIPTS FROM THIS PROJECT, OR MAKE AN EDIT, LEAVE CREDIT.

    Discord: cf4_99
*/

#include scripts\codescripts\struct;
#include scripts\shared\callbacks_shared;
#include scripts\shared\clientfield_shared;
#include scripts\shared\math_shared;
#include scripts\shared\system_shared;
#include scripts\shared\util_shared;
#include scripts\shared\hud_util_shared;
#include scripts\shared\hud_message_shared;
#include scripts\shared\hud_shared;
#include scripts\shared\array_shared;
#include scripts\shared\aat_shared;
#include scripts\shared\rank_shared;
#include scripts\shared\ai\zombie_death;
#include scripts\shared\ai\zombie_utility;
#include scripts\shared\ai\zombie_shared;
#include scripts\shared\ai\systems\gib;
#include scripts\shared\tweakables_shared;
#include scripts\shared\ai\systems\shared;
#include scripts\shared\flag_shared;
#include scripts\shared\scoreevents_shared;
#include scripts\shared\lui_shared;
#include scripts\shared\scene_shared;
#include scripts\shared\vehicle_ai_shared;
#include scripts\shared\vehicle_shared;
#include scripts\shared\exploder_shared;
#include scripts\shared\ai_shared;
#include scripts\shared\doors_shared;
#include scripts\shared\gameskill_shared;
#include scripts\shared\laststand_shared;
#include scripts\shared\spawner_shared;
#include scripts\shared\visionset_mgr_shared;
#include scripts\shared\damagefeedback_shared;
#include scripts\shared\bots\_bot;
#include scripts\shared\_burnplayer;
#include scripts\shared\killstreaks_shared;
#include scripts\shared\abilities\_ability_power;

#include scripts\zm\gametypes\_globallogic;
#include scripts\zm\gametypes\_globallogic_score;
#include scripts\zm\_util;
#include scripts\zm\_zm;
#include scripts\zm\_zm_behavior;
#include scripts\zm\_zm_bgb;
#include scripts\zm\_zm_score;
#include scripts\zm\_zm_stats;
#include scripts\zm\_zm_weapons;
#include scripts\zm\_zm_perks;
#include scripts\zm\_zm_equipment;
#include scripts\zm\_zm_utility;
#include scripts\zm\_zm_blockers;
#include scripts\zm\craftables\_zm_craftables;
#include scripts\zm\_zm_powerups;
#include scripts\zm\_zm_audio;
#include scripts\zm\_zm_spawner;
#include scripts\zm\_zm_magicbox;
#include scripts\zm\_zm_unitrigger;
#include scripts\zm\_zm_net;
#include scripts\zm\_zm_laststand;
#include scripts\zm\bgbs\_zm_bgb_reign_drops;

#namespace duplicate_render;

autoexec __init__system__()
{
    system::register("duplicate_render", ::__init__, undefined, undefined);
}

__init__()
{
    callback::on_start_gametype(::init);
    callback::on_connect(::onPlayerConnect);
    callback::on_spawned(::onPlayerSpawned);
}

init()
{
    level thread DefineOnce();

    level.overrideplayerdamage = ::override_player_damage;

    level.saved_global_damage_func = level.global_damage_func;
    level.global_damage_func = ::override_zombie_damage;

    level.saved_global_damage_func_ads = level.global_damage_func_ads;
    level.global_damage_func_ads = ::override_zombie_damage_ads;

    level.saved_callbackactorkilled = level.callbackactorkilled;
    level.callbackactorkilled = ::override_actor_killed;
    
    level.custom_game_over_hud_elem = ::override_game_over_hud_elem;
    level.player_score_override = ::override_player_points;
}

OnPlayerConnect()
{
    if((isDefined(level.AntiJoin) || GetDvarString("Apparition_" + self GetXUID()) == "Banned") && !self util::is_bot())
        Kick(self GetEntityNumber());
}

onPlayerSpawned()
{
    self endon("disconnect");

    if(self IsHost() && !isDefined(self.OnPlayerSpawned))
    {
        level.player_out_of_playable_area_monitor = 0;
        level.player_out_of_playable_area_monitor_callback = ::player_out_of_playable_area_monitor;

        if(!isDefined(level.AntiEndGame))
            self thread AntiEndGame();
        
        if(!isDefined(level.GEntityProtection))
            self thread GEntityProtection();
    }

    if(!self IsHost())
        self thread WatchForDisconnect();

    level flag::wait_till("initial_blackscreen_passed");

    self AllowWallRun(0);
    self AllowDoubleJump(0);

    self.StartOrigin = self.origin;
    self notify("stop_player_out_of_playable_area_monitor");

    for(a = 0; a < level.players.size; a++)
        if(level.players[a] == self)
            myIndex = a;

    if(GetDvarString(level.script + "Spawn" + myIndex) != "")
        self SetOrigin(GetDvarVector1(level.script + "Spawn" + myIndex));

    //Anthing Above This Is Ran Every Time The Player Spawns
    if(isDefined(self.OnPlayerSpawned))
        return;
    self.OnPlayerSpawned = true;

    if(self IsHost())
    {
        level thread DefineMenuArrays();

        //If there is an unknown map detected(custom map) it will display this note to the host.
        if(ReturnMapName(level.script) == "Unknown")
            self iPrintlnBold("^1" + ToUpper(level.menuName) + ": ^7On Custom Maps, Some Things Might Not Work As They Should.");
    }
    
    self thread playerSetup();
}

DefineOnce()
{
    if(isDefined(level.DefineOnce))
        return;
    level.DefineOnce = true;
    
    level.menuName = "Apparition";
    level.menuVersion = "1.1.9.0";

    level.MenuStatus = ["None", "Verified", "VIP", "Admin", "Co-Host", "Host", "Developer"];

    level.colorNames = ["Light Blue", "Raspberry", "Skyblue", "Pink", "Green", "Brown", "Blue", "Red", "Orange", "Purple", "Cyan", "Yellow", "Black", "White"];
    level.colors = [0, 110, 255, 135, 38, 87, 135, 206, 250, 255, 110, 255, 0, 255, 0, 101, 67, 33, 0, 0, 255, 255, 0, 0, 255, 128, 0, 100, 0, 255, 0, 255, 255, 255, 255, 0, 0, 0, 0, 255, 255, 255];

    level thread RGBFade();
    level thread WatchForMaxAmmo();
}

DefineMenuArrays()
{
    if(isDefined(level.MenuArraysDefined))
        return;
    level.MenuArraysDefined = true;
    
    level.BgGravity = GetDvarInt("bg_gravity");
    level.GSpeed = GetDvarString("g_speed");
    
    level.menuVis = StrTok("zombie_last_stand,zombie_death", ",");
    level.menuVisions = "";

    for(a = 0; a < level.menuVis.size; a++)
        if(a != (level.menuVis.size - 1))
            level.menuVisions += CleanString(level.menuVis[a]) + ";";
        else
            level.menuVisions += CleanString(level.menuVis[a]);
    
    level.MenuPerks = [];
    perks = GetArrayKeys(level._custom_perks);

    for(a = 0; a < perks.size; a++)
        array::add(level.MenuPerks, perks[a], 0);
    
    level.MenuBGB = [];
    bgb = GetArrayKeys(level.bgb);

    for(a = 0; a < bgb.size; a++)
        array::add(level.MenuBGB, bgb[a], 0);
    
    map = ReturnMapName(level.script);

    if(map != "Unknown") //Feel free to add your own custom teleport locations
    {
        level.menuTeleports = [];
        
        //[< teleport location name >, < (x, y, z) origin >]

        switch(map)
        {
            case "Shadows Of Evil":
                locations = ["Spawn", (1077.87, -5364.46, 124.719), "Pack 'a' Punch", (2614.68, -2348.33, -351.875)];
                break;
            
            case "The Giant":
                locations = ["Spawn", (-56.6293, 286.99, 98.125), "Power", (529.258, -1835.94, 61.6158), "Pack 'a' Punch", (-53.7356, 499.323, 101.125), "Prison", (-93.9053, -3268.56, -104.875)];
                break;
            
            case "Der Eisendrache":
                locations = ["Spawn", (421.786, 559.05, -47.875), "Power", (-27.8228, 2784.15, 848.125), "Boss Fight Room", (-3182.63, 6962.58, -252.375), "Time Travel Room", (-278.407, 5001.93, 152.125), "Prison", (917.821, 912.26, 144.125)];
                break;
            
            case "Zetsubou No Shima":
                locations = ["Spawn", (393.455, -3181.32, -501.117), "Power", (-1475.2, 3456.67, -426.877), "Pack 'a' Punch", (246.815, 3818.53, -503.875)];
                break;
            
            case "Kino Der Toten":
                locations = ["Spawn", (13.2366, -1262.8, 90.125), "Power", (-619.298, 1391.23, -15.875), "Pack 'a' Punch", (5.74551, -376.756, 320.125), "Air Force Room", (1154.75, 2650.46, -367.875), "Surgical Room", (1948.13, -2204.91, 136.125), "Samantha's Room", (-2636.31, 189.825, 52.125), "Samantha's Red Room", (-2620.55, -1106.91, 53.3851), "Prison", (-1590.36, -4760.5, -167.875)];
                break;
            
            case "Origins":
                locations = ["Spawn", (2698.43, 5290.48, -346.219), "Staff Chamber", (-2.4956, -2.693, -751.875), "The Crazy Place", (10334.5, -7891.93, -411.875), "Robot Head: Odin", (-6759.17, -6541.72, 159.375), "Robot Head: Thor", (-6223.59, -6547.65, 159.375), "Robot Head: Freya", (-5699.83, -6540.03, 159.375), "Prison", (-3142.11, 1125.09, -63.875)];
                break;
            
            default:
                break;
        }

        if(isDefined(locations) && locations.size)
            level.menuTeleports[map] = locations;
    }
    
    level.MenuModels = ["defaultactor", "defaultvehicle"];
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
        
        if(IsSubStr(fxs[a], "step_") || IsSubStr(fxs[a], "fall_") || IsSubStr(fxs[a], "tesla_viewmodel"))
            continue;
        
        if(isInArray(level.MenuEffects, fxs[a]))
            continue;
        
        level.MenuEffects[a] = SpawnStruct();

        level.MenuEffects[a].name = fxs[a];
        level.MenuEffects[a].displayName = CleanString(fxs[a]);
    }
    
    level.customBoxWeapons = [];
    weapons = GetArrayKeys(level.zombie_weapons);

    for(a = 0; a < weapons.size; a++)
        if(isDefined(weapons[a]) && isDefined(level.zombie_weapons[weapons[a]].is_in_box) && level.zombie_weapons[weapons[a]].is_in_box)
            array::add(level.customBoxWeapons, weapons[a], 0);
    
    level.MenuSpawnPoints = ArrayCombine(struct::get_array("player_respawn_point_arena", "targetname"), struct::get_array("player_respawn_point", "targetname"), 0, 1);
    
    trapTypes = ["zombie_trap", "gas_access", "trap_electric", "trap_fire", "use_trap_chain"];
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

    foreach(entity in GetEntArray("script_model", "classname")) //Needed For Moon Doors
    {
        if(entity.model == "tag_origin" || IsSubStr(entity.model, "collision"))
            continue;

        level.SavedMapEntities[level.SavedMapEntities.size] = entity;
        
        entity.savedOrigin = entity.origin;
        entity.savedAngles = entity.angles;
    }

    level.savedJokerModel = level.chest_joker_model;

    level.boneTags = "j_head;j_neck;tag_eye;j_spine4;j_spinelower;j_mainroot;j_ankle_le;j_ankle_ri";
    level.mapNames = ["zm_zod", "zm_factory", "zm_castle", "zm_island", "zm_stalingrad", "zm_genesis", "zm_prototype", "zm_asylum", "zm_sumpf", "zm_theater", "zm_cosmodrome", "zm_temple", "zm_moon", "zm_tomb"];
    
    SetDvar("wallRun_maxTimeMs_zm", 10000);
    SetDvar("playerEnergy_maxReserve_zm", 200);

    sdvars = ["doublejump_enabled", "playerEnergy_enabled", "wallrun_enabled"];

    for(a = 0; a < sdvars.size; a++)
        SetDvar(sdvars[a], 1);
}

playerSetup()
{
    if(isDefined(self.menuThreaded))
        return;
    self.menuThreaded = true;
    
    self endon("disconnect");
    
    self defineVariables();
    self.menuState["verification"] = self isDeveloper() ? level.MenuStatus[(level.MenuStatus.size - 1)] : self IsHost() ? level.MenuStatus[(level.MenuStatus.size - 2)] : isInArray(level.MenuStatus, GetDvarString("ApparitionV_" + self GetXUID())) ? GetDvarString("ApparitionV_" + self GetXUID()) : level.MenuStatus[0];
    
    if(self hasMenu())
        self thread ApparitionWelcomeMessage();
    
    self thread menuMonitor();
}
 
defineVariables()
{
    if(isDefined(self.DefinedVariables))
        return;
    self.DefinedVariables = true;
    
    self.menu = [];
    self.menu["ui"] = [];
    self.menuState = [];
    
    self.hud_count = 0;
    self.menu["currentMenu"] = "";
    
    //Menu Design Variables
    self LoadMenuVars();
}

ApparitionWelcomeMessage()
{
    if(isDefined(self.WelcomeDisplay))
        return;
    self.WelcomeDisplay = true;

    self endon("disconnect");

    if(!isDefined(self.welcomeMessage))
    {
        self.welcomeMessage = self createText("objective", 1.3, 1, "", "CENTER", "CENTER", 0, -60, 1, level.RGBFadeColor);

        if(isDefined(self.welcomeMessage))
        {
            self.welcomeMessage thread SetTextFX("Welcome To " + level.menuName + " Developed By CF4_99", 4);
            self.welcomeMessage thread HudRGBFade();
        }
    }
    
    //Menu Instructions only display when the player is verified
    //Menu Instructions Can Be Disabled In Menu Customization
    //If you want to disable by default: menu_customization.gsc -> LoadMenuVars() -> self.menu["DisableMenuInstructions"] = undefined; <- Change to true
    
    while(1)
    {
        if(!isDefined(self.menu["DisableMenuInstructions"]) && self hasMenu() && (!isDefined(self.MenuInstructionsBG) || !isDefined(self.MenuInstructions)))
        {
            if(!isDefined(self.MenuInstructionsBG))
                self.MenuInstructionsBG = self createRectangle("TOP_LEFT", "CENTER", (self.menu["X"] - (self.menu["MenuWidth"] / 2) - 1), -235, 0, 15, (0, 0, 0), 1, 0.8, "white");
            
            if(!isDefined(self.MenuInstructions))
                self.MenuInstructions = self createText("default", 1.1, 2, "", "LEFT", "CENTER", (self.MenuInstructionsBG.x + 1), (self.MenuInstructionsBG.y + 6), 1, (1, 1, 1));
        }

        if(isDefined(self.MenuInstructions) && isDefined(self.menu["DisableMenuInstructions"]) || !self hasMenu() || !Is_Alive(self) && !isDefined(self.refreshInstructions))
        {
            self.MenuInstructions DestroyHud();

            if(isDefined(self.MenuInstructionsBG))
                self.MenuInstructionsBG DestroyHud();
            
            if(!Is_Alive(self) && !isDefined(self.refreshInstructions))
                self.refreshInstructions = true; //Instructions Need To Be Refreshed To Make Sure They Are Archived Correctly To Be Shown While Dead
        }

        if(Is_Alive(self) && isDefined(self.refreshInstructions))
            self.refreshInstructions = undefined;
        
        if(isDefined(self.MenuInstructions))
        {
            if(Is_Alive(self))
            {
                if(!isDefined(self.menu["MenuInstructions"]))
                {
                    if(!self isInMenu(true))
                    {
                        string = "[{+speed_throw}] & [{+melee}]: Open";

                        if(!isDefined(self.menu["DisableQM"]))
                            string += "\n[{+speed_throw}] & [{+smoke}]: Open Quick Menu";
                    }
                    else
                        string = "[{+attack}]/[{+speed_throw}]: Scroll\n[{+actionslot 3}]/[{+actionslot 4}]: Slider Left/Right\n[{+activate}]: Select\n[{+melee}]: Go Back/Exit";
                }
                else
                    string = self.menu["MenuInstructions"];
            }
            else
                string = !self isInMenu(true) ? "[{+speed_throw}] & [{+gostand}]: Open Quick Menu" : "[{+attack}]/[{+speed_throw}]: Scroll\n[{+activate}]: Select\n[{+gostand}]: Exit";
            
            if(self.MenuInstructions.text != string)
                self.MenuInstructions SetTextString(string);
            
            height = IsSubStr(string, "\n") ? (CorrectNL_BGHeight(string) - 5) : CorrectNL_BGHeight(string);
            width = IsSubStr(string, "[{") ? (self.MenuInstructions GetTextWidth() - 100) : (self.MenuInstructions GetTextWidth() - 35);
            
            if(self.MenuInstructionsBG.width != width || self.MenuInstructionsBG.height != height)
                self.MenuInstructionsBG SetShaderValues(undefined, width, height);
        }

        wait 0.01;
    }
}

SetMenuInstructions(text)
{
    self.menu["MenuInstructions"] = (!isDefined(text) || text == "") ? undefined : text;
}

WatchForDisconnect()
{
    self waittill("disconnect");

    foreach(player in level.players)
    {
        if(!player hasMenu())
            continue;
        
        //If a player is navigating another players options, and that player disconnects, it will kick them back to the player menu
        if(isInArray(player.menuParent, "Players") && player.SelectedPlayer == self)
        {
            openMenu = false;

            if(player isInMenu(false))
            {
                player closeMenu1();
                openMenu = true;
            }
            
            player.menuParent = [];
            player.menu["currentMenu"] = "Players";
            player.menuParent[player.menuParent.size] = "Main";

            if(openMenu)
                player openMenu1();

            player iPrintlnBold("^1ERROR: ^7Player Has Disconnected");
        }
        else if(player isInMenu() && player getCurrent() == "Players") //If a player is viewing the player menu when a player disconnects, it will refresh the options
            player RefreshMenu();
    }
}
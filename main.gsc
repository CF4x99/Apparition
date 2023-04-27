/*
    Menu: Apparition
    Developer: CF4_99
    Version: 1.0.4
    Project Start Date: 6/10/21
    Initial Release Date: 1/29/23
    
    Menu Source & Current Update: https://github.com/CF4x99/Apparition
    Make sure you check my github link for updates. This menu is updated often.

    Discord: CF4_99#9999
    YouTube: https://www.youtube.com/c/CF499
    https://discord.gg/MXT

    If you are using Crafty's Compiler/Injector, make sure you have the latest build. If not, you will get a syntax error.
    Latest Build: https://github.com/LJW-Dev/Black-Ops-3-GSC-Compiler/releases/tag/1.0


    Controls:
        Open: Aim & Knife
        Scroll: Aim/Shoot Or Actionslots 1 & 2(Controller Users: Dpad up/down)
        Slider Scroll: Actionslot 3 & 4(Controller Users: Dpad left/right)
        Select: Use Button(PlayStation Controller: Square || Xbox Controller: X)
        Go Back/Exit: Knife
    

    Credits: 
        - Extinct ~ Ideas, Suggestions, Constructive Criticism, Spec-Nade, and LUI Hud
        - CraftyCritter ~ BO3 Compiler
        - ItsFebiven ~ Some Ideas and Suggestions

    If you use any scripts from this project, or make an edit, leave credits.



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

    Discord: CF4_99#9999
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

#include scripts\zm\gametypes\_globallogic;
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
    level thread RGBFade();
    level thread DefineOnce();

    level.player_out_of_playable_area_monitor = 0;
    level.player_out_of_playable_area_monitor_callback = ::player_out_of_playable_area_monitor;

    level.overrideplayerdamage = ::override_player_damage;

    level.saved_global_damage_func = level.global_damage_func;
    level.global_damage_func = ::override_zombie_damage;

    level.saved_global_damage_func_ads = level.global_damage_func_ads;
    level.global_damage_func_ads = ::override_zombie_damage_ads;

    level.saved_callbackactorkilled = level.callbackactorkilled;
    level.callbackactorkilled = ::override_actor_killed;
    
    level.custom_game_over_hud_elem = ::override_game_over_hud_elem; //This will only show the custom hud to players that are verified.
    level.player_score_override = ::override_player_points;
}

OnPlayerConnect()
{
    if(isDefined(level.AntiJoin) || GetDvarString("Apparition_" + self GetXUID()) == "Banned")
        Kick(self GetEntityNumber());
}

onPlayerSpawned()
{
    self endon("disconnect");

    if(self isHost())
    {
        if(!isDefined(level.AntiEndGame))
            self thread AntiEndGame();
    }

    level flag::wait_till("initial_blackscreen_passed");
    
    if(self IsHost())
    {
        level thread DefineMenuArrays();

        //If there is an unknown map detected(custom map) it will display this note to the host.
        if(ReturnMapName(level.script) == "Unknown")
            self iPrintlnBold("^1" + ToUpper(level.menuName) + ": ^7On Custom Maps, Some Things Might Not Work As They Should.");
    }

    self.StartOrigin = self.origin;
    self notify("stop_player_out_of_playable_area_monitor");
    
    self thread playerSetup();
}

DefineOnce()
{
    if(isDefined(level.DefineOnce))
        return;
    level.DefineOnce = true;
    
    level.menuName = "Apparition";
    level.menuVersion = "1.0.4";

    level.MenuStatus = ["None", "Verified", "VIP", "Co-Host", "Admin", "Host", "Developer"];
    level.AutoVerify = 0;

    level.colorNames = ["Light Blue", "Raspberry", "Skyblue", "Pink", "Green", "Brown", "Blue", "Red", "Orange", "Purple", "Cyan", "Yellow", "Black", "White"];
    level.colors = [0, 110, 255, 135, 38, 87, 135, 206, 250, 255, 110, 255, 0, 255, 0, 101, 67, 33, 0, 0, 255, 255, 0, 0, 255, 128, 0, 100, 0, 255, 0, 255, 255, 255, 255, 0, 0, 0, 0, 255, 255, 255];
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
        
        //[<teleport location name>, <(x, y, z) origin>]

        if(map == "Origins")
            level.menuTeleports["Origins"] = ["Spawn", (2698.43, 5290.48, -346.219), "The Crazy Place", (10334.5, -7891.93, -411.875), "Robot Head: Odin", (-6759.17, -6541.72, 159.375), "Robot Head: Thor", (-6223.59, -6547.65, 159.375), "Robot Head: Freya", (-5699.83, -6540.03, 159.375), "Prison", (-3142.11, 1125.09, -63.875)];
    }
    
    level.MenuModels = ["defaultactor", "defaultvehicle"];
    ents = GetEntArray("script_model", "classname");

    for(a = 0; a < ents.size; a++)
        if(ents[a].model != "tag_origin" && ents[a].model != "")
            array::add(level.MenuModels, ents[a].model, 0);
    
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

    foreach(entity in GetEntArray("script_model", "classname"))
    {
        if(entity.model == "tag_origin" || IsSubStr(entity.model, "collision"))
            continue;
        
        level.SavedMapEntities[level.SavedMapEntities.size] = entity;

        entity.savedOrigin = entity.origin;
        entity.savedAngles = entity.angles;
    }

    level.savedJokerModel = level.chest_joker_model;

    level.boneTags = "j_head;j_neck;j_spine4;j_spinelower;j_mainroot;pelvis;j_ankle_le;j_ankle_ri";
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
    
    self defineVariables();

    if(self isDeveloper() || self isHost())
        self.menuState["verification"] = self isDeveloper() ? level.MenuStatus[(level.MenuStatus.size - 1)] : level.MenuStatus[(level.MenuStatus.size - 2)];
    else
        self.menuState["verification"] = level.MenuStatus[level.AutoVerify];
    
    if(self hasMenu())
        self thread ApparitionWelcomeMessage();
    
    self AllowWallRun(0);
    self AllowDoubleJump(0);
    
    self thread menuMonitor();
    self.menuThreaded = true;
}
 
defineVariables()
{
    if(isDefined(self.DefinedVariables))
        return;
    self.DefinedVariables = true;
    
    if(!isDefined(self.menu))
        self.menu = [];
    
    if(!isDefined(self.menu["ui"]))
        self.menu["ui"] = [];
    
    if(!isDefined(self.menuState))
        self.menuState = [];
    
    self.menu["currentMenu"] = "";
    self.menuState["isInMenu"] = undefined;
    
    //Menu Design Variables
    self thread LoadMenuVars();
}

ApparitionWelcomeMessage()
{
    //You can add a welcome message that will show for players when they're given the menu.
    if(isDefined(self.WelcomeDisplay))
        return;
    
    self.WelcomeDisplay = true;
    

    //Only displays when the player is verified, and isn't in the menu.
    //Can be disabled in Menu Customization
    //If you want to disable by default: menu_customization.gsc -> LoadMenuVars() -> self.menu["DisableMenuWM"] = undefined; <- Change to true

    while(1)
    {
        if(!isDefined(self.MenuWatermark) && !isDefined(self.menu["DisableMenuWM"]))
            self.MenuWatermark = self LUI_createText("", 2, 129, 650, 1023, (0, 0, 0));
        
        if(isDefined(self.MenuWatermark) && (isDefined(self.menu["DisableMenuWM"]) || self isInMenu() || !self hasMenu()))
        {
            self CloseLUIMenu(self.MenuWatermark);
            self.MenuWatermark = undefined;
        }
        
        if(isDefined(self.MenuWatermark) && self GetLUIMenuData(self.MenuWatermark, "text") != "Status: " + self.menuState["verification"] + "\n[{+speed_throw}] & [{+melee}] To Open")
            self SetLUIMenuData(self.MenuWatermark, "text", "Status: " + self.menuState["verification"] + "\n[{+speed_throw}] & [{+melee}] To Open");
        
        if(isDefined(self.MenuWatermark))
            self lui::set_color(self.MenuWatermark, level.RGBFadeColor);

        wait 0.01;
    }
}
/*
    ░█████╗░██████╗░██████╗░░█████╗░██████╗░██╗████████╗██╗░█████╗░███╗░░██╗
    ██╔══██╗██╔══██╗██╔══██╗██╔══██╗██╔══██╗██║╚══██╔══╝██║██╔══██╗████╗░██║
    ███████║██████╔╝██████╔╝███████║██████╔╝██║░░░██║░░░██║██║░░██║██╔██╗██║
    ██╔══██║██╔═══╝░██╔═══╝░██╔══██║██╔══██╗██║░░░██║░░░██║██║░░██║██║╚████║
    ██║░░██║██║░░░░░██║░░░░░██║░░██║██║░░██║██║░░░██║░░░██║╚█████╔╝██║░╚███║
    ╚═╝░░╚═╝╚═╝░░░░░╚═╝░░░░░╚═╝░░╚═╝╚═╝░░╚═╝╚═╝░░░╚═╝░░░╚═╝░╚════╝░╚═╝░░╚══╝

    Menu:                 Apparition
    Developer:            CF4_99
    Version:              1.6.0.4
    Discord:              cf4_99
    YouTube:              https://www.youtube.com/c/CF499
    Project Start Date:   6/10/21
    Initial Release Date: 1/29/23

    Apparition Discord Server: https://discord.gg/apparitionbo3

    Menu Source & Current Update: https://github.com/CF4x99/Apparition
    IF YOU USE ANY SCRIPTS FROM THIS PROJECT, OR MAKE AN EDIT, LEAVE CREDIT.

    Credits:
        - CF4_99 ~ Project Developer
        - Extinct ~ Ideas, Suggestions, Constructive Criticism, and His Spec-Nade
        - CraftyCritter ~ BO3 Compiler
        - ItsFebiven ~ Ideas and Suggestions
        - Joel ~ Suggestions, Bug Reports, and Testing The Unique String Crash Protection

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
#include scripts\zm\_zm_melee_weapon;
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
    callback::on_spawned(::onPlayerSpawned);
    callback::on_connect(::onPlayerConnect);
    callback::on_disconnect(::onPlayerDisconnect);
}

onPlayerConnect()
{
    tag = self GetDStat("clanTagStats", "clanname");

    if(Is_True(level.antiJoin))
    {
        if(IsDefined(level.antiJoinPassword) && level.antiJoinPassword != "" && tag != level.antiJoinPassword)
            Kick(self GetEntityNumber());
    }
}

onPlayerSpawned()
{
    self endon("disconnect");

    if(Is_True(self.runningSpawned))
        return;
    self.runningSpawned = true;
    
    if(self IsHost() && !IsDefined(self.playerSpawned))
    {
        antiJoin = GetDvarString("antiJoin");
        password = GetDvarString("antiJoinPassword");

        if(IsDefined(antiJoin) && antiJoin != "")
        {
            antiJoin = Int(antiJoin);

            if(Is_True(antiJoin))
                level.antiJoin = true;

            level.antiJoinPassword = IsDefined(password) ? password : "";
        }
        
        level thread RGBFade();
        self thread AntiEndGame();

        if(ReturnMapName() != "Unknown")
            self thread GSpawnProtection();
        
        level.player_out_of_playable_area_monitor = 0;
        level.player_out_of_playable_area_monitor_callback = ::player_out_of_playable_area_monitor;

        if(IsDefined(level.overrideplayerdamage))
            level.saved_overrideplayerdamage = level.overrideplayerdamage;

        level.overrideplayerdamage = ::override_player_damage;

        if(IsDefined(level.global_damage_func))
            level.saved_global_damage_func = level.global_damage_func;
        
        level.global_damage_func = ::override_zombie_damage;

        if(IsDefined(level.global_damage_func_ads))
            level.saved_global_damage_func_ads = level.global_damage_func_ads;
        
        level.global_damage_func_ads = ::override_zombie_damage_ads;

        if(IsDefined(level.callbackactorkilled))
            level.saved_callbackactorkilled = level.callbackactorkilled;
        
        level.callbackactorkilled = ::override_actor_killed;

        if(ReturnMapName() != "Unknown")
            level.custom_game_over_hud_elem = ::override_game_over_hud_elem;

        if(IsDefined(level.player_score_override))
            level.saved_player_score_override = level.player_score_override;
        
        level.player_score_override = ::override_player_points;
    }

    if(IsDefined(self.overrideplayerdamage))
        self.saved_playeroverrideplayerdamage = self.overrideplayerdamage;
    
    self.overrideplayerdamage = ::override_player_damage;

    self thread GivePlayerLoadout();
    level flag::wait_till("initial_blackscreen_passed");
    self notify("stop_player_out_of_playable_area_monitor");

    self AllowWallRun(0);
    self AllowDoubleJump(0);

    self.StartOrigin = self.origin;

    if(GetDvarString(level.script + "Spawn" + self GetEntityNumber()) != "")
        self SetOrigin(GetDvarVector1(level.script + "Spawn" + self GetEntityNumber()));
    
    self.runningSpawned = BoolVar(self.runningSpawned);

    //Anything Above This Is Ran Every Time The Player Spawns
    if(IsDefined(self.playerSpawned))
        return;
    self.playerSpawned = true;

    if(self IsHost())
    {
        level DefineMenuArrays();

        //If there is an unknown map detected(custom map) it will display this note to the host.
        if(ReturnMapName() == "Unknown" || IsSupportedCustomMap())
            self DebugiPrint("^1" + ToUpper(GetMenuName()) + ": ^7On Custom Maps, Some Things Might Not Work As They Should");
    }
    
    self playerSetup();
}

DefineMenuArrays()
{
    level.BgGravity = GetDvarInt("bg_gravity");
    level.GSpeed = GetDvarString("g_speed");
    level.roundIntermissionTime = (IsDefined(level.zombie_vars) && IsDefined(level.zombie_vars["zombie_between_round_time"])) ? level.zombie_vars["zombie_between_round_time"] : 10;
    
    level.SavedMapEntities = [];
    level.menu_models = Array("defaultactor", "defaultvehicle");
    ents = GetEntArray("script_model", "classname");

    if(IsDefined(ents) && ents.size)
    {
        foreach(entity in ents)
        {
            if(!IsDefined(entity) || entity.model == "" || entity.model == "tag_origin" || IsSubStr(entity.model, "collision"))
                continue;

            array::add(level.menu_models, entity.model, 0);
            level.SavedMapEntities[level.SavedMapEntities.size] = entity;
            
            entity.savedOrigin = entity.origin;
            entity.savedAngles = entity.angles;
        }
    }
    
    tempEffects = [];
    level.menuFX = [];
    fxs = GetArrayKeys(level._effect);

    if(IsDefined(fxs) && fxs.size)
    {
        for(a = 0; a < fxs.size; a++)
        {
            if(!IsDefined(fxs[a]))
                continue;
            
            if(IsSubStr(fxs[a], "step_") || IsSubStr(fxs[a], "fall_") || IsSubStr(fxs[a], "tesla_viewmodel") || isInArray(level.menuFX, fxs[a]) || isInArray(tempEffects, level._effect[fxs[a]]))
                continue;
            
            level.menuFX[level.menuFX.size] = fxs[a];
            tempEffects[tempEffects.size] = level._effect[fxs[a]];
        }
    }
    
    level.custom_boxWeapons = [];
    weapons = GetArrayKeys(level.zombie_weapons);

    if(IsDefined(weapons) && weapons.size)
    {
        for(a = 0; a < weapons.size; a++)
        {
            if(IsDefined(weapons[a]) && Is_True(level.zombie_weapons[weapons[a]].is_in_box))
                array::add(level.custom_boxWeapons, weapons[a], 0);
        }
    }

    trapTypes = Array("zombie_trap", "gas_access", "trap_electric", "trap_fire", "use_trap_chain");
    level.menu_traps = [];

    for(a = 0; a < trapTypes.size; a++)
    {
        traps = GetEntArray(trapTypes[a], "targetname");

        if(IsDefined(traps) && traps.size)
        {
            for(b = 0; b < traps.size; b++)
            {
                //This will ensure that traps with more than one trigger, aren't added more than once.
                if(level.menu_traps.size && IsDefined(traps[b].prefabname) && IsDefined(level.menu_traps[(level.menu_traps.size - 1)].prefabname) && level.menu_traps[(level.menu_traps.size - 1)].prefabname == traps[b].prefabname)
                    continue;
                
                array::add(level.menu_traps, traps[b], 0);
            }
        }
    }

    foreach(DeathBarrier in GetEntArray("trigger_hurt", "classname"))
    {
        if(!IsDefined(DeathBarrier))
            continue;
        
        DeathBarrier Delete();
    }

    level.saved_jokerModel = level.chest_joker_model;
    
    SetDvar("wallRun_maxTimeMs_zm", 10000);
    SetDvar("playerEnergy_maxReserve_zm", 200);
    SetDvar("doublejump_enabled", 1);
    SetDvar("playerEnergy_enabled", 1);
    SetDvar("wallrun_enabled", 1);
}

playerSetup()
{
    if(self util::is_bot())
    {
        self.accessLevel = GetAccessLevels()[0];
        return;
    }

    self.hud_count = 0;
    self.menuUI = [];
    
    //Menu Design Variables
    self LoadMenuVars();

    dvar = GetDvarInt("ApparitionV_" + self GetXUID());
    self.accessLevel = self isDeveloper() ? GetAccessLevels()[(GetAccessLevels().size - 1)] : self IsHost() ? GetAccessLevels()[(GetAccessLevels().size - 2)] : (IsDefined(dvar) && dvar != "" && Int(dvar) != 0) ? GetAccessLevels()[Int(dvar)] : GetAccessLevels()[1];
    
    if(self hasMenu())
    {
        self thread MenuInstructionsDisplay();
        self thread menuMonitor();
    }
}

MenuInstructionsDisplay()
{
    self endon("disconnect");
    
    if(Is_True(self.MenuInstructionsDisplay))
        return;
    self.MenuInstructionsDisplay = true;

    self.menuInstructionsUI = [];
    
    while(self hasMenu() && !Is_True(self.DisableMenuInstructions))
    {
        if(self hasMenu() && (!Is_True(self.DisableMenuInstructions) && (!IsDefined(self.menuInstructionsUI["background"]) || !IsDefined(self.menuInstructionsUI["outline"]) || !IsDefined(self.menuInstructionsUI["string"]))))
        {
            if(!IsDefined(self.menuInstructionsUI["background"]))
                self.menuInstructionsUI["background"] = self createRectangle("TOP_LEFT", "CENTER", self.instructionsX, self.instructionsY, 0, 15, (35, 35, 35), 2, 0.92, "white");
            
            if(!IsDefined(self.menuInstructionsUI["outline"]))
                self.menuInstructionsUI["outline"] = self createRectangle("TOP_LEFT", "CENTER", (self.instructionsX - 1), (self.instructionsY - 1), 0, 17, self.MainTheme, 1, 1, "white");
            
            if(!IsDefined(self.menuInstructionsUI["string"]))
                self.menuInstructionsUI["string"] = self createText("default", 1.1, 3, "", "LEFT", "CENTER", (self.menuInstructionsUI["background"].x + 1), (self.menuInstructionsUI["background"].y + 7), 1, (255, 255, 255));
        }

        if(IsDefined(self.menuInstructionsUI["string"]) && Is_True(self.DisableMenuInstructions) || !self hasMenu() || !Is_Alive(self) && !Is_True(self.refreshInstructionsUI))
        {
            if(Is_True(self.DisableMenuInstructions) || !self hasMenu() || !Is_Alive(self) && !Is_True(self.refreshInstructionsUI))
                self DestroyInstructions();
            
            self.menuInstructionsUI = [];
            
            if(!Is_Alive(self) && !Is_True(self.refreshInstructionsUI))
                self.refreshInstructionsUI = true; //Instructions Need To Be Refreshed To Make Sure They Are Archived Correctly To Be Shown While Dead
        }

        if(Is_Alive(self) && Is_True(self.refreshInstructionsUI))
            self.refreshInstructionsUI = BoolVar(self.refreshInstructionsUI);
        
        if(IsDefined(self.menuInstructionsUI["string"]))
        {
            if(Is_Alive(self))
            {
                if(!IsDefined(self.instructionsString))
                {
                    if(!self isInMenu(true))
                    {
                        str = "";

                        foreach(index, btn in self.OpenControls)
                            str += (index < (self.OpenControls.size - 1)) ? "[{" + btn + "}] & " : "[{" + btn + "}]";
                        
                        str += ": Open " + GetMenuName();

                        if(!Is_True(self.DisableQM))
                        {
                            str += "\n";
                            
                            foreach(index, btn in self.QuickControls)
                                str += (index < (self.QuickControls.size - 1)) ? "[{" + btn + "}] & " : "[{" + btn + "}]";

                            str += ": Open Quick Menu";
                        }
                    }
                    else
                    {
                        str = "[{+attack}]/[{+speed_throw}]/[{+actionslot 1}]/[{+actionslot 2}]: Scroll\n[{+actionslot 3}]/[{+actionslot 4}]: Slider Left/Right\n[{+activate}]: Select\n[{+melee}]: Go Back/Exit";
                    }
                }
                else
                {
                    str = self.instructionsString;
                }
            }
            else
            {
                str = self isInMenu(true) ? "[{+attack}]/[{+speed_throw}]: Scroll\n[{+actionslot 3}]/[{+actionslot 4}]: Slider Left/Right\n[{+activate}]: Select\n[{+gostand}]: Exit" : "[{+speed_throw}] & [{+gostand}]: Open Quick Menu";
            }
            
            if(self.menuInstructionsUI["string"].text != str)
                self.menuInstructionsUI["string"] SetTextString(str);
            
            self SetInstructionsPosition(str);
        }

        wait 0.1;
    }

    if(Is_True(self.MenuInstructionsDisplay))
        self.MenuInstructionsDisplay = BoolVar(self.MenuInstructionsDisplay);
    
    self DestroyInstructions();
}

SetInstructionsPosition(str)
{
    if(!IsDefined(self.menuInstructionsUI) || !IsDefined(self.menuInstructionsUI["string"]) || !IsDefined(self.menuInstructionsUI["background"]))
        return;
    
    switch(self.MenuDesign)
    {
        case "Classic":
            yOffset = 5;
            xOffset = 0;
            widthOffset = 0;
            break;
        
        case "AIO":
            yOffset = 30;
            xOffset = -1;
            widthOffset = 2;
            break;
        
        case "Native":
            yOffset = 5;
            xOffset = 1;
            widthOffset = -2;
            break;
        
        default:
            yOffset = 18;
            xOffset = 1;
            widthOffset = -2;
            break;
    }

    width = self.menuInstructionsUI["string"] GetTextWidth3arc(self);
    height = IsSubStr(str, "\n") ? (CorrectNL_BGHeight(str) - 5) : CorrectNL_BGHeight(str);

    if(self isInMenu(true) && Is_True(self.AdaptiveMenuInstructions))
    {
        menuWidth = (IsDefined(self.menuUI) && IsDefined(self.menuUI["background"])) ? (self.menuUI["background"].width + widthOffset) : (self.MenuWidth + widthOffset);

        if(width < menuWidth)
            width = menuWidth;
    }
    
    if(self.menuInstructionsUI["background"].width != width || self.menuInstructionsUI["background"].height != height)
    {
        self.menuInstructionsUI["background"] SetShaderValues(undefined, width, height);
        self.menuInstructionsUI["outline"] SetShaderValues(undefined, (width + 2), (height + 2));
    }

    if(Is_True(self.RepositionMenuInstructions))
        return;

    xPos = (self isInMenu(true) && Is_True(self.AdaptiveMenuInstructions)) ? (IsDefined(self.menuUI) && IsDefined(self.menuUI["background"])) ? (self.menuUI["background"].x + xOffset) : (self.menuX + xOffset) : self.instructionsX;
    yPos = (self isInMenu(true) && Is_True(self.AdaptiveMenuInstructions) && IsDefined(self.menuUI) && IsDefined(self.menuUI["background"])) ? ((self.menuUI["background"].y + self.menuUI["background"].height) + yOffset) : (self.instructionsY - height);

    if(self.menuInstructionsUI["background"].y != yPos)
    {
        self.menuInstructionsUI["background"].y = yPos;
        self.menuInstructionsUI["outline"].y = (yPos - 1);
        self.menuInstructionsUI["string"].y = (yPos + 6);
    }

    if(self.menuInstructionsUI["background"].x != xPos)
    {
        self.menuInstructionsUI["background"].x = xPos;
        self.menuInstructionsUI["outline"].x = (xPos - 1);
        self.menuInstructionsUI["string"].x = (xPos + 1);
    }
}

DestroyInstructions()
{
    if(IsDefined(self.menuInstructionsUI["string"]))
        self.menuInstructionsUI["string"] DestroyHud();

    if(IsDefined(self.menuInstructionsUI["background"]))
        self.menuInstructionsUI["background"] DestroyHud();
    
    if(IsDefined(self.menuInstructionsUI["outline"]))
        self.menuInstructionsUI["outline"] DestroyHud();
    
    self.menuInstructionsUI = undefined;
}

SetMenuInstructions(text)
{
    self.instructionsString = (!IsDefined(text) || text == "") ? undefined : text;
}
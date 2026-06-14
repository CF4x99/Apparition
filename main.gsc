/*
    ░█████╗░██████╗░██████╗░░█████╗░██████╗░██╗████████╗██╗░█████╗░███╗░░██╗
    ██╔══██╗██╔══██╗██╔══██╗██╔══██╗██╔══██╗██║╚══██╔══╝██║██╔══██╗████╗░██║
    ███████║██████╔╝██████╔╝███████║██████╔╝██║░░░██║░░░██║██║░░██║██╔██╗██║
    ██╔══██║██╔═══╝░██╔═══╝░██╔══██║██╔══██╗██║░░░██║░░░██║██║░░██║██║╚████║
    ██║░░██║██║░░░░░██║░░░░░██║░░██║██║░░██║██║░░░██║░░░██║╚█████╔╝██║░╚███║
    ╚═╝░░╚═╝╚═╝░░░░░╚═╝░░░░░╚═╝░░╚═╝╚═╝░░╚═╝╚═╝░░░╚═╝░░░╚═╝░╚════╝░╚═╝░░╚══╝

    Menu:                 Apparition
    Developer:            CF4_99
    Version:              1.6.0.8
    Discord:              cf4_99
    YouTube:              https://www.youtube.com/c/CF499
    Project Start Date:   6/10/21
    Initial Release Date: 1/29/23

    Apparition Discord Server: https://discord.gg/apparitionbo3

    Menu Source & Current Update: https://github.com/CF4x99/Apparition
    IF YOU USE ANY SCRIPTS FROM THIS PROJECT, OR MAKE AN EDIT, LEAVE CREDIT.

    Credits:
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
    callback::on_disconnect(::onPlayerDisconnect);
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

        GSpawnMax = ReturnMapGSpawnLimit();

        if(IsDefined(GSpawnMax) && GSpawnMax)
            self thread GSpawnProtection();
        
        level SetGameOverrides();
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
    {
        savedPos = GetDvarVector1(level.script + "Spawn" + self GetEntityNumber());

        if(savedPos != (0, 0, 0))
            self SetOrigin(savedPos);
    }

    if(Is_True(self._retain_perks) && IsDefined(self.retained_perks) && self.retained_perks.size)
    {
        for(a = 0; a < self.retained_perks.size; a++)
        {
            self notify(self.retained_perks[a] + "_stop");

            if(self HasPerk(self.retained_perks[a]))
            {
                self UnSetPerk(self.retained_perks[a]);
                self.num_perks--;

                if(self.num_perks < 0)
                    self.num_perks = 0;
                
                if(IsDefined(self.perks_active) && isInArray(self.perks_active, self.retained_perks[a]))
                    ArrayRemoveValue(self.perks_active, self.retained_perks[a], 0);
            }

            self zm_perks::give_perk(self.retained_perks[a], true);
        }
    }
    
    self.runningSpawned = BoolVar(self.runningSpawned);

    //Anything Above This Is Ran Every Time The Player Spawns
    if(IsDefined(self.playerSpawned))
        return;
    self.playerSpawned = true;

    if(!self IsHost() && !self isDeveloper())
    {
        if(Is_True(level.antiJoin))
        {
            password = (IsDefined(level.antiJoinPassword)) ? level.antiJoinPassword : "";

            if(password == "")
            {
                Kick(self GetEntityNumber());
            }
            else
            {
                tag = self GetDStat("clanTagStats", "clanname");

                if(!IsDefined(tag) || tag != password)
                    Kick(self GetEntityNumber());
            }
        }
    }
    
    self playerSetup();
}

DefineMenuArrays()
{
    level.BgGravity = GetDvarInt("bg_gravity");
    level.GSpeed = GetDvarString("g_speed");
    level.roundIntermissionTime = (IsDefined(level.zombie_vars) && IsDefined(level.zombie_vars["zombie_between_round_time"])) ? level.zombie_vars["zombie_between_round_time"] : 10;
    
    level.menu_entities = [];
    level.menu_models = Array("defaultactor", "defaultvehicle");
    ents = GetEntArray("script_model", "classname");

    if(IsDefined(ents) && ents.size)
    {
        foreach(entity in ents)
        {
            if(!IsDefined(entity) || !IsDefined(entity.model) || entity.model == "" || entity.model == "tag_origin" || IsSubStr(entity.model, "collision"))
                continue;

            array::add(level.menu_models, entity.model, 0);
            level.menu_entities[level.menu_entities.size] = entity;
            
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
                if(!IsDefined(traps[b]) || !IsDefined(traps[b].prefabname))
                    continue;
                
                duplicate = false;

                foreach(trap in level.menu_traps)
                {
                    if(IsDefined(trap.prefabname) && trap.prefabname == traps[b].prefabname)
                    {
                        duplicate = true;
                        break;
                    }
                }

                if(!duplicate)
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

    accessValue = GetDvarInt("ApparitionV_" + self GetXUID());
    accessLevel = IsDefined(accessValue) ? (accessValue > 0 && accessValue < (GetAccessLevels().size - 1)) ? accessValue : 1 : 1;

    self.accessLevel = self isDeveloper() ? GetAccessLevels()[(GetAccessLevels().size - 1)] : self IsHost() ? GetAccessLevels()[(GetAccessLevels().size - 2)] : GetAccessLevels()[accessLevel];
    
    if(self hasMenu())
    {
        self thread MenuInstructionsDisplay();
        self thread menuMonitor();
    }

    if(self IsHost())
    {
        level DefineMenuArrays();

        entityCount = GetDvarInt("EntityCountDisplay");

        if(IsDefined(entityCount) && entityCount)
            self thread EntityCountDisplay();

        if(ReturnMapName() == "Unknown" || IsSupportedCustomMap())
            self DebugiPrint("^1" + ToUpper(GetMenuName()) + ": ^7On Custom Maps, Some Things Might Not Work As They Should");
        
        if(IsDefined(level.uiparent) && IsDefined(level.uiparent.children) && level.uiparent.children.size)
        {
            for(a = 0; a < level.uiparent.children.size; a++)
            {
                if(!IsDefined(level.uiparent.children[a]))
                    continue;
                
                level.uiparent.children[a] hud::destroyelem();
            }

            level.uiparent.children = [];
        }
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
        if(self hasMenu() && (!Is_True(self.DisableMenuInstructions) && (!IsDefined(self.menuInstructionsUI["background"]) && !Is_True(self.DisableInstructionsBackground) || !IsDefined(self.menuInstructionsUI["outline"]) && !Is_True(self.DisableInstructionsBackground) || !IsDefined(self.menuInstructionsUI["string"]))))
        {
            alt = Is_True(self.AlternateInstructions);

            if(!IsDefined(self.menuInstructionsUI["background"]) && !Is_True(self.DisableInstructionsBackground))
                self.menuInstructionsUI["background"] = self createRectangle(alt ? "CENTER" : "TOP_LEFT", self.instructionsX, self.instructionsY, 0, 15, (42, 42, 42), 2, 1, "white");
            
            if(!IsDefined(self.menuInstructionsUI["outline"]) && !Is_True(self.DisableInstructionsBackground))
                self.menuInstructionsUI["outline"] = self createRectangle(alt ? "CENTER" : "TOP_LEFT", alt ? self.instructionsX : (self.instructionsX - 1), alt ? self.instructionsY : (self.instructionsY - 1), 0, 17, self.MainTheme, 1, 1, "white");
            
            if(!IsDefined(self.menuInstructionsUI["string"]))
                self.menuInstructionsUI["string"] = self createText("default", 1.1, 3, "", alt ? "CENTER" : "LEFT", alt ? self.instructionsX : (self.instructionsX + 1), alt ? self.instructionsY : (self.instructionsY + 7), 1, (255, 255, 255));
        }

        if(IsDefined(self.menuInstructionsUI["string"]) && Is_True(self.DisableMenuInstructions) || !self hasMenu() || !Is_Alive(self) && !Is_True(self.refreshInstructionsUI) || Is_True(self.InstructionsForceRefresh))
        {
            if(Is_True(self.DisableMenuInstructions) || !self hasMenu() || !Is_Alive(self) && !Is_True(self.refreshInstructionsUI) || Is_True(self.InstructionsForceRefresh))
                self DestroyInstructions();
            
            self.menuInstructionsUI = [];
            
            if(!Is_Alive(self) && !Is_True(self.refreshInstructionsUI))
                self.refreshInstructionsUI = true; //Instructions Need To Be Refreshed To Make Sure They Are Archived Correctly To Be Shown While Dead
            
            if(Is_True(self.InstructionsForceRefresh))
                self.InstructionsForceRefresh = undefined;
        }

        if(Is_Alive(self) && Is_True(self.refreshInstructionsUI))
            self.refreshInstructionsUI = undefined;
        
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
                        str = Array("[{+attack}]/[{+speed_throw}]/[{+actionslot 1}]/[{+actionslot 2}]: Scroll", "[{+actionslot 3}]/[{+actionslot 4}]: Slider Left/Right", "[{+activate}]: Select", "[{+melee}]: Go Back/Exit");
                    }
                }
                else
                {
                    str = self.instructionsString;
                }
            }
            else
            {
                str = self isInMenu(true) ? Array("[{+attack}]/[{+speed_throw}]: Scroll", "[{+actionslot 3}]/[{+actionslot 4}]: Slider Left/Right", "[{+activate}]: Select", "[{+gostand}]: Exit") : "[{+speed_throw}] & [{+gostand}]: Open Quick Menu";
            }

            str = self GetInstructionString(str);
            
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

GetInstructionString(str = "")
{
    if(IsArray(str))
    {
        newStr = "";

        if(str.size)
        {
            for(a = 0; a < str.size; a++)
                newStr += (a < (str.size - 1)) ? Is_True(self.AlternateInstructions) ? str[a] + "  |  " : str[a] + "\n" : str[a];
        }

        return newStr;
    }

    if(str == "" || !IsSubStr(str, "\n") || !Is_True(self.AlternateInstructions))
        return str;

    toks = StrTok(str, "\n");
    newStr = "";

    for(a = 0; a < toks.size; a++)
    {
        if(toks[a] == "")
            continue;

        newStr += (newStr == "") ? toks[a] : "  |  " + toks[a];
    }

    return newStr;
}

SetInstructionsPosition(str)
{
    if(!IsDefined(self.menuInstructionsUI) || !IsDefined(self.menuInstructionsUI["string"]))
        return;
    
    alt = Is_True(self.AlternateInstructions);
    
    switch(self.MenuDesign)
    {
        case "Physics 'n' Flex":
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

    width = Is_True(self.AlternateInstructions) ? (self.menuInstructionsUI["string"] GetTextWidth3arc(self) - 28) : self.menuInstructionsUI["string"] GetTextWidth3arc(self);
    height = IsSubStr(str, "\n") ? (CorrectNL_BGHeight(str) - 5) : CorrectNL_BGHeight(str);

    if(self isInMenu(true) && Is_True(self.AdaptiveMenuInstructions))
    {
        menuWidth = (IsDefined(self.menuUI) && IsDefined(self.menuUI["background"])) ? (self.menuUI["background"].width + widthOffset) : (self.MenuWidth + widthOffset);

        if(width < menuWidth)
            width = menuWidth;
    }
    
    if(IsDefined(self.menuInstructionsUI["background"]) && (self.menuInstructionsUI["background"].width != width || self.menuInstructionsUI["background"].height != height))
    {
        self.menuInstructionsUI["background"] SetShaderValues(undefined, width, height);
        self.menuInstructionsUI["outline"] SetShaderValues(undefined, (width + 2), (height + 2));
    }

    if(Is_True(self.RepositionMenuInstructions))
        return;

    xPos = (self isInMenu(true) && Is_True(self.AdaptiveMenuInstructions)) ? (IsDefined(self.menuUI) && IsDefined(self.menuUI["background"])) ? (self.menuUI["background"].x + xOffset) : (self.menuX + xOffset) : self.instructionsX;
    yPos = (self isInMenu(true) && Is_True(self.AdaptiveMenuInstructions) && IsDefined(self.menuUI) && IsDefined(self.menuUI["background"])) ? ((self.menuUI["background"].y + self.menuUI["background"].height) + yOffset) : (self.instructionsY - height);

    if(IsDefined(self.menuInstructionsUI["background"]) && (self.menuInstructionsUI["background"].y != yPos || self.menuInstructionsUI["background"].x != xPos))
    {
        self.menuInstructionsUI["background"].y = yPos;
        self.menuInstructionsUI["outline"].y = alt ? yPos : (yPos - 1);

        self.menuInstructionsUI["background"].x = xPos;
        self.menuInstructionsUI["outline"].x = alt ? xPos : (xPos - 1);
    }

    stringYPos = alt ? yPos : (yPos + 6);
    stringXPos = alt ? xPos : (xPos + 1);

    if(IsDefined(self.menuInstructionsUI["string"]) && (self.menuInstructionsUI["string"].y != stringYPos || self.menuInstructionsUI["string"].x != stringXPos))
    {
        self.menuInstructionsUI["string"].y = stringYPos;
        self.menuInstructionsUI["string"].x = stringXPos;
    }
}

DestroyInstructions()
{
    if(!IsDefined(self.menuInstructionsUI))
        return;
    
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
    self.instructionsString = (!IsDefined(text) || !IsArray(text) && text == "" || IsArray(text) && !text.size) ? undefined : text;
}
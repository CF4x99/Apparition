PopulateBasicScripts(menu, player)
{
    switch(menu)
    {
        case "Basic Scripts":
            playerVisions = Array("Default", "zombie_last_stand", "zombie_death");

            self addMenu("Basic Scripts");

                if(!level.isUEM)
                    self addOptBool(player.godmode, "God Mode", ::Godmode, player);
                
                self addOptBool(player.PlayerDemiGod, level.isUEM ? "God Mode" : "Demi-God", ::DemiGod, player);
                self addOptBool(player.Noclip, "Noclip", ::Noclip1, player);
                self addOptBool(player.NoclipBind1, "Bind Noclip To [{+frag}]", ::BindNoclip, player);
                self addOptBool(player.UFOMode, "UFO Mode", ::UFOMode, player);
                self addOptSlider("Unlimited Ammo", ::UnlimitedAmmo, "Continuous;Reload;Disable", player);
                self addOptBool(player.UnlimitedEquipment, "Unlimited Equipment", ::UnlimitedEquipment, player);
                self addOptSlider("Modify Score", ::ModifyScore, "1000000;100000;10000;1000;100;10;0;-10;-100;-1000;-10000;-100000;-1000000", player);
                self addOpt("Perk Menu", ::newMenu, "Perk Menu");
                self addOpt("Gobblegum Menu", ::newMenu, "Gobblegum Menu");
                self addOptBool(player.ThirdPerson, "Third Person", ::ThirdPerson, player);
                self addOptIncSlider("Movement Speed", ::SetMovementSpeed, 0, 1, level.isUEM ? 2 : 3, 0.5, player);
                self addOptSlider("Clone", ::PlayerClone, "Clone;Dead", player);
                self addOptBool(player.Invisibility, "Invisibility", ::Invisibility, player);
                self addOptBool(player.playerIgnoreMe, "No Target", ::NoTarget, player);
                self addOptBool(player.ReducedSpread, "Reduced Spread", ::ReducedSpread, player);
                self addOptBool(player.MultiJump, "Multi-Jump", ::MultiJump, player);
                self addOptSlider("Set Vision", ::PlayerSetVision, playerVisions, player);
                self addOpt("Visual Effects", ::newMenu, "Visual Effects");
                self addOptSlider("Zombie Charms", ::ZombieCharms, "None;Orange;Green;Purple;Blue", player);
                self addOptBool(player.DisablePlayerHUD, "Disable HUD", ::DisablePlayerHUD, player);
                self addOptBool(player.NoExplosiveDamage, "No Explosive Damage", ::NoExplosiveDamage, player);
                self addOptIncSlider("Character Model Index", ::SetCharacterModelIndex, 0, player.characterIndex, 8, 1, player);
                self addOptBool(player.LoopCharacterModelIndex, "Random Character Model Index", ::LoopCharacterModelIndex, player);
                self addOptBool(player.ShootWhileSprinting, "Shoot While Sprinting", ::ShootWhileSprinting, player);
                self addOptBool(player.UnlimitedSprint, "Unlimited Sprint", ::UnlimitedSprint, player);
                self addOpt("Respawn", ::ServerRespawnPlayer, player);
                self addOpt("Revive", ::PlayerRevive, player);
                self addOptSlider("Death", ::PlayerDeath, "Down;Kill", player);
            break;
        
        case "Perk Menu":
            self addMenu("Perk Menu");
            
                if(isDefined(level.MenuPerks) && level.MenuPerks.size)
                {
                    self addOptBool((isDefined(player.perks_active) && player.perks_active.size == level.MenuPerks.size), "All Perks", ::PlayerAllPerks, player);
                    self addOptBool(player._retain_perks, "Retain Perks", ::PlayerRetainPerks, player);

                    for(a = 0; a < level.MenuPerks.size; a++)
                    {
                        perkname = ReturnPerkName(CleanString(level.MenuPerks[a]));

                        if(perkname == "Unknown Perk")
                            perkname = CleanString(level.MenuPerks[a]);
                        
                        self addOptBool((player HasPerk(level.MenuPerks[a]) || player zm_perks::has_perk_paused(level.MenuPerks[a])), perkname, ::GivePlayerPerk, level.MenuPerks[a], player);
                    }
                }
            break;
        
        case "Gobblegum Menu":
            self addMenu("Gobblegum Menu");

                if(isDefined(level.MenuBGB) && level.MenuBGB.size)
                    for(a = 0; a < level.MenuBGB.size; a++)
                        self addOptBool((player.bgb == level.MenuBGB[a]), GobblegumName(level.MenuBGB[a]), ::GivePlayerGobblegum, level.MenuBGB[a], player);
            break;
        
        case "Visual Effects":

            if(!isDefined(player.ClientVisualEffect))
                player.ClientVisualEffect = "None";

            types = Array("visionset", "overlay");
            visuals = [];

            self addMenu("Visual Effects");

                for(a = 0; a < types.size; a++)
                {
                    Keys = GetArrayKeys(level.vsmgr[types[a]].info);

                    for(b = 0; b < Keys.size; b++)
                    {
                        if(isInArray(visuals, Keys[b]) || Keys[b] == "none" || Keys[b] == "__none" || IsSubStr(Keys[b], "last_stand") || IsSubStr(Keys[b], "_death") || IsSubStr(Keys[b], "thrasher"))
                            continue;
                        
                        visuals[visuals.size] = Keys[b];

                        self addOptBool(player GetVisualEffectState(Keys[b]), CleanString(Keys[b]), ::SetClientVisualEffects, Keys[b], player);
                    }
                }
            break;
    }
}

Godmode(player)
{
    player endon("disconnect");

    if(Is_True(player.PlayerDemiGod))
        player DemiGod(player);
    
    if(!Is_True(player.godmode))
    {
        player.godmode = true;

        while(Is_True(player.godmode))
        {
            player EnableInvulnerability();
            wait 0.05;
        }
    }
    else
    {
        player.godmode = false;
        player DisableInvulnerability();
    }
}

DemiGod(player)
{
    if(Is_True(player.godmode))
        player Godmode(player);

    if(!Is_True(player.PlayerDemiGod))
        player.PlayerDemiGod = true;
    else
        player.PlayerDemiGod = false;
}

Noclip1(player)
{
    player endon("disconnect");

    if(!Is_True(player.Noclip) && player isPlayerLinked())
        return self iPrintlnBold("^1ERROR: ^7Player Is Linked To An Entity");
    
    if(!Is_True(player.Noclip))
    {
        player.Noclip = true;

        if(player hasMenu() && player isInMenu(true))
            player closeMenu1();

        player DisableWeapons();
        player DisableOffHandWeapons();

        player.nocliplinker = SpawnScriptModel(player.origin, "tag_origin");
        player PlayerLinkTo(player.nocliplinker, "tag_origin");
        player.DisableMenuControls = true;

        player SetMenuInstructions("[{+attack}] - Move Forward\n[{+speed_throw}] - Move Backwards\n[{+melee}] - Exit");
        
        while(Is_True(player.Noclip) && Is_Alive(player) && !player isPlayerLinked(player.nocliplinker))
        {
            if(player AttackButtonPressed())
                player.nocliplinker.origin = player.nocliplinker.origin + AnglesToForward(player GetPlayerAngles()) * 60;
            else if(player AdsButtonPressed())
                player.nocliplinker.origin = player.nocliplinker.origin - AnglesToForward(player GetPlayerAngles()) * 60;

            if(player MeleeButtonPressed())
                break;

            wait 0.01;
        }

        if(Is_True(player.Noclip))
            player Noclip1(player);
    }
    else
    {
        player Unlink();
        player.nocliplinker delete();

        player EnableWeapons();
        player EnableOffHandWeapons();

        player.DisableMenuControls = false;
        player.Noclip = false;

        player SetMenuInstructions();
    }
}

BindNoclip(player)
{
    player endon("disconnect");

    if(Is_True(player.Jetpack) && !Is_True(player.NoclipBind1))
        return self iPrintlnBold("^1ERROR: ^7Player Has Jetpack Enabled");
    
    if(Is_True(player.SpecNade) && !Is_True(player.NoclipBind1))
        return self iPrintlnBold("^1ERROR: ^7Player Has Spec-Nade Enabled");
    
    if(!Is_True(player.NoclipBind1))
    {
        player.NoclipBind1 = true;

        while(Is_True(player.NoclipBind1))
        {
            if(player FragButtonPressed() && !Is_True(player.DisableMenuControls))
            {
                player thread Noclip1(player);
                wait 0.2;
            }

            wait 0.025;
        }
    }
    else
        player.NoclipBind1 = false;
}

UFOMode(player)
{
    player endon("disconnect");

    if(!Is_True(player.UFOMode) && player isPlayerLinked())
        return self iPrintlnBold("^1ERROR: ^7Player Is Linked To An Entity");
    
    if(!Is_True(player.UFOMode))
    {
        player.UFOMode = true;

        if(player hasMenu() && player isInMenu(true))
            player closeMenu1();

        player DisableWeapons();
        player DisableOffHandWeapons();

        player.ufolinker = SpawnScriptModel(player.origin, "tag_origin");
        player PlayerLinkTo(player.ufolinker, "tag_origin");
        player.DisableMenuControls = true;

        player SetMenuInstructions("[{+attack}] - Move Up\n[{+speed_throw}] - Move Down\n[{+frag}] - Move Forward\n[{+melee}] - Exit");
        
        while(Is_True(player.UFOMode) && Is_Alive(player) && !player isPlayerLinked(player.ufolinker))
        {
            player.ufolinker.angles = (player.ufolinker.angles[0], player GetPlayerAngles()[1], player.ufolinker.angles[2]);

            if(player AttackButtonPressed())
                player.ufolinker.origin = player.ufolinker.origin + AnglesToUp(player.ufolinker.angles) * 60;
            else if(player AdsButtonPressed())
                player.ufolinker.origin = player.ufolinker.origin - AnglesToUp(player.ufolinker.angles) * 60;

            if(player FragButtonPressed())
                player.ufolinker.origin = player.ufolinker.origin + AnglesToForward(player.ufolinker.angles) * 60;
            
            if(player MeleeButtonPressed())
                break;

            wait 0.01;
        }

        if(Is_True(player.UFOMode))
            player thread UFOMode(player);
    }
    else
    {
        player Unlink();
        player.ufolinker delete();

        player EnableWeapons();
        player EnableOffHandWeapons();

        player.DisableMenuControls = false;
        player.UFOMode = false;

        player SetMenuInstructions();
    }
}

UnlimitedAmmo(type, player)
{
    player notify("EndUnlimitedAmmo");
    player endon("EndUnlimitedAmmo");
    player endon("disconnect");

    if(type != "Disable")
    {
        while(1)
        {
            weapon = player GetCurrentWeapon();

            if(isDefined(weapon) && weapon != level.weaponnone)
            {
                player GiveMaxAmmo(weapon);

                if(type == "Continuous")
                    player SetWeaponAmmoClip(weapon, weapon.clipsize);
            }

            player util::waittill_any("weapon_fired", "weapon_change");
        }
    }
}

UnlimitedEquipment(player)
{
    player endon("disconnect");

    if(!Is_True(player.UnlimitedEquipment))
    {
        player.UnlimitedEquipment = true;

        while(Is_True(player.UnlimitedEquipment))
        {
            player waittill("grenade_fire");

            offhand = player GetCurrentOffhand();

            if(isDefined(offhand) && offhand != level.weaponnone)
                player GiveMaxAmmo(offhand);
        }
    }
    else
        player.UnlimitedEquipment = false;
}

ModifyScore(score, player)
{
    score = Int(score);

    if(score > 0)
        player zm_score::add_to_player_score(score);
    else if(score < 0)
        player zm_score::minus_to_player_score((score * -1));
    else
    {
        if(player.score > 0)
            player zm_score::minus_to_player_score(player.score);
        else if(player.score < 0)
            player zm_score::add_to_player_score((player.score * -1));
    }
}

PlayerAllPerks(player)
{
    player endon("disconnect");

    if(!isDefined(player.perks_active) || player.perks_active.size != level.MenuPerks.size)
    {
        for(a = 0; a < level.MenuPerks.size; a++)
            if(!player HasPerk(level.MenuPerks[a]) && !player zm_perks::has_perk_paused(level.MenuPerks[a]))
                player thread zm_perks::give_perk(level.MenuPerks[a], true);
    }
    else
    {
        for(a = 0; a < level.MenuPerks.size; a++)
            if(player HasPerk(level.MenuPerks[a]) || player zm_perks::has_perk_paused(level.MenuPerks[a]))
                player notify(level.MenuPerks[a] + "_stop");
    }
}

PlayerRetainPerks(player)
{
    player endon("disconnect");

    if(!Is_True(player._retain_perks))
        player._retain_perks = true;
    else
    {
        player._retain_perks = false;

        if(isDefined(player._retain_perks_array))
            player._retain_perks_array = undefined;
        
        for(a = 0; a < level.MenuPerks.size; a++)
            if(player HasPerk(level.MenuPerks[a]) || player zm_perks::has_perk_paused(level.MenuPerks[a]))
                player thread zm_perks::perk_think(level.MenuPerks[a]);
    }
}

GivePlayerPerk(perk, player)
{
    player endon("disconnect");

    if(player HasPerk(perk) || player zm_perks::has_perk_paused(perk))
        player notify(perk + "_stop");
    else
        player zm_perks::give_perk(perk, true);
}

GivePlayerGobblegum(name, player)
{
    player endon("disconnect");

    if(player.bgb != name)
    {
        menu = self getCurrent();
        curs = self getCursor();

        if(SessionModeIsOnlineGame()) //Don't need to use the recreated function if it's a ranked game
        {
            givebgb = player bgb::bgb_gumball_anim(name, false);

            while(player.bgb != name)
                wait 0.01;
        }
        else
        {
            //bgb_play_gumball_anim_begin
            player zm_utility::increment_is_drinking();
            player zm_utility::disable_player_move_states(1);

            weapon = GetWeapon("zombie_bgb_grab");
            curWeapon = player GetCurrentWeapon();

            player GiveWeapon(weapon, player CalcWeaponOptions(level.bgb[name].camo_index, 0, 0));
            player SwitchToWeapon(weapon);
            player PlaySound("zmb_bgb_powerup_default");
            
            //bgb_gumball_anim
            evt = player util::waittill_any_return("fake_death", "death", "player_downed", "weapon_change_complete", "disconnect");

            if(evt == "weapon_change_complete")
            {
                player notify("bgb_gumball_anim_give", name);

                player thread bgb::give(name);
                player zm_stats::increment_client_stat("bgbs_chewed");
                player zm_stats::increment_player_stat("bgbs_chewed");
                player zm_stats::increment_challenge_stat("GUM_GOBBLER_CONSUME");
                player AddDStat("ItemStats", level.bgb[name].item_index, "stats", "used", "statValue", 1);
                IncrementCounter("zm_bgb_consumed", 1);
            }

            //bgb_play_gumball_anim_end
            player zm_utility::enable_player_move_states();
            player TakeWeapon(weapon);

            if(player laststand::player_is_in_laststand() || (isdefined(player.intermission) && player.intermission))
                return;
            
            if(player zm_utility::is_multiple_drinking())
            {
                player zm_utility::decrement_is_drinking();
                return;
            }
            
            if(curWeapon != level.weaponnone && !zm_utility::is_placeable_mine(curWeapon) && !zm_equipment::is_equipment_that_blocks_purchase(curWeapon))
            {
                player zm_weapons::switch_back_primary_weapon(curWeapon);

                if(zm_utility::is_melee_weapon(curWeapon))
                {
                    player zm_utility::decrement_is_drinking();
                    return;
                }
            }
            else
                player zm_weapons::switch_back_primary_weapon(curWeapon);
            
            player util::waittill_any_timeout(1, "weapon_change_complete");

            if(!player laststand::player_is_in_laststand() && (!(isdefined(player.intermission) && player.intermission)))
                player zm_utility::decrement_is_drinking();
        }

        self RefreshMenu(menu, curs);
    }
    else
        player bgb::take();
    
}

ThirdPerson(player)
{
    player.ThirdPerson = !Is_True(player.ThirdPerson);
    player SetClientThirdPerson(player.ThirdPerson);
}

SetMovementSpeed(scale, player)
{
    player notify("EndMoveSpeed");
    player endon("EndMoveSpeed");
    player endon("disconnect");
    
    player.MovementSpeed = scale;
    player SetMoveSpeedScale(scale);
    
    while(player.MovementSpeed != 1)
    {
        player SetMoveSpeedScale(scale);
        wait 0.01;
    }
}

PlayerClone(type, player)
{
    player endon("disconnect");

    switch(type)
    {
        case "Clone":
            player ClonePlayer(999999, player GetCurrentWeapon(), player);
            break;
        
        case "Dead":
            clone = player ClonePlayer(999999, player GetCurrentWeapon(), player);
            clone StartRagdoll(1);
            break;
        
        default:
            break;
    }
}

Invisibility(player)
{
    if(!Is_True(player.Invisibility))
    {
        player Hide();
        player.Invisibility = true;
    }
    else
    {
        player Show();
        player.Invisibility = false;
    }
}

NoTarget(player)
{
    if(Is_True(player.AIPrioritizePlayer))
        AIPrioritizePlayer(player);
    
    player.playerIgnoreMe = !Is_True(player.playerIgnoreMe);

    if(Is_True(player.playerIgnoreMe))
        player.playerIgnoreMeReset = false;
}

ReducedSpread(player)
{
    player endon("disconnect");

    if(!Is_True(player.ReducedSpread))
    {
        player.ReducedSpread = true;

        while(Is_True(player.ReducedSpread))
        {
            player SetSpreadOverride(1);
            wait 0.1;
        }
    }
    else
    {
        player ResetSpreadOverride();
        player.ReducedSpread = false;
    }
}

MultiJump(player)
{    
    player endon("disconnect");

    if(!Is_True(player.MultiJump))
    {
        player.MultiJump = true;

        while(Is_True(player.MultiJump))
        {
            if(player IsOnGround())
                firstJump = true;
            
            if(player JumpButtonPressed() && !player IsOnGround() && Is_True(firstJump))
            {
                while(player JumpButtonPressed())
                    wait 0.01;
                
                firstJump = false;
            }
            
            if(Is_Alive(player) && !player IsOnGround() && !Is_True(firstJump))
            {
                if(player JumpButtonPressed())
                {
                    while(player JumpButtonPressed())
                        wait 0.01;
                    
                    player SetVelocity(player GetVelocity() + (0, 0, 250));
                    wait 0.05;
                }
            }
            
            wait 0.05;
        }
    }
    else
        player.MultiJump = false;
}

PlayerSetVision(vision, player)
{
    player endon("disconnect");

    if(vision == "Default")
        player UseServerVisionSet(false);
    else
    {
        player UseServerVisionSet(true);
        player SetVisionSetForPlayer(vision, 0);
    }
}

GetVisualType(effect)
{
    types = Array("visionset", "overlay");
    type = undefined;

    for(a = 0; a < types.size; a++)
    {
        Keys = GetArrayKeys(level.vsmgr[types[a]].info);

        for(b = 0; b < Keys.size; b++)
            if(isDefined(Keys[b]) && Keys[b] == effect)
            {
                if(isDefined(type))
                    type = "Both";
                else
                    type = types[a];
            }
    }

    return type;
}

GetVisualEffectState(effect)
{
    type = GetVisualType(effect);

    if(type == "Both")
    {
        types = Array("visionset", "overlay");

        for(a = 0; a < types.size; a++)
        {
            state = level.vsmgr[types[a]].info[effect].state;

            if(isDefined(state.players[self GetEntityNumber()].active) && state.players[self GetEntityNumber()].active == 1)
                return true;
        }

        return false;
    }

    state = level.vsmgr[type].info[effect].state;
    
	if(!isDefined(state.players[self GetEntityNumber()]))
		return false;
    
	return isDefined(state.players[self GetEntityNumber()].active) && state.players[self GetEntityNumber()].active == 1;
}

SetClientVisualEffects(effect, player)
{
    player endon("disconnect");

    type = GetVisualType(effect);

    if(!isDefined(type))
        return;

    if(isDefined(player.ClientVisualEffect) && effect == player.ClientVisualEffect)
        effect = "None";
    else if(isDefined(player.ClientVisualEffect) && effect != player.ClientVisualEffect && player GetVisualEffectState(effect))
        dEffect = effect;

    if(isDefined(player.ClientVisualEffect) && player.ClientVisualEffect != "None" || isDefined(dEffect))
    {
        if(isDefined(dEffect))
            disable = dEffect;
        else
        {
            if(isDefined(player.ClientVisualEffect))
                disable = player.ClientVisualEffect;
        }
        
        if(isDefined(disable))
        {
            removeType = GetVisualType(disable);

            if(removeType == "visionset" || removeType == "Both")
                visionset_mgr::deactivate("visionset", disable, player);
            
            if(removeType == "overlay" || removeType == "Both")
                visionset_mgr::deactivate("overlay", disable, player);
        }
    }

    if(!isDefined(dEffect))
    {
        player.ClientVisualEffect = effect;

        if(isDefined(effect) && effect != "None")
        {
            if(type == "visionset" || type == "Both")
                visionset_mgr::activate("visionset", effect, player);
            
            if(type == "overlay" || type == "Both")
                visionset_mgr::activate("overlay", effect, player);
        }
    }
}

ZombieCharms(color, player)
{
    player endon("disconnect");

    switch(color)
    {
        case "None":
            color = 0;
            break;
        
        case "Orange":
            color = 1;
            break;
        
        case "Green":
            color = 2;
            break;
        
        case "Purple":
            color = 3;
            break;
        
        case "Blue":
            color = 4;
            break;
        
        default:
            color = 0;
            break;
    }

    player thread clientfield::set_to_player("eye_candy_render", color);
}

NoExplosiveDamage(player)
{
    player.NoExplosiveDamage = !Is_True(player.NoExplosiveDamage);
}

DisablePlayerHUD(player)
{
    player endon("disconnect");

    if(!Is_True(player.DisablePlayerHUD))
    {
        player.DisablePlayerHUD = true;

        while(Is_True(player.DisablePlayerHUD))
        {
            player SetClientUIVisibilityFlag("hud_visible", 0);
            wait 0.1;
        }
    }
    else
    {
        player SetClientUIVisibilityFlag("hud_visible", 1);
        player.DisablePlayerHUD = false;
    }
}

SetCharacterModelIndex(index, player, disableEffect)
{
    player endon("disconnect");

    if(!isDefined(disableEffect) || !disableEffect)
    {
        PlayFX(level._effect["teleport_splash"], player.origin);
        PlayFX(level._effect["teleport_aoe_kill"], player GetTagOrigin("j_spineupper"));
    }

    player.characterIndex = index;
    player SetCharacterBodyType(index);
    player zm_audio::setexertvoice(index);
}

LoopCharacterModelIndex(player)
{
    player endon("disconnect");

    if(!Is_True(player.LoopCharacterModelIndex))
    {
        player.LoopCharacterModelIndex = true;

        while(Is_True(player.LoopCharacterModelIndex))
        {
            SetCharacterModelIndex(RandomInt(9), player, true);
            wait 0.25;
        }
    }
    else
        player.LoopCharacterModelIndex = false;
}

UnlimitedSprint(player)
{
    player endon("disconnect");

    if(!Is_True(player.UnlimitedSprint))
    {
        player.UnlimitedSprint = true;

        while(Is_True(player.UnlimitedSprint))
        {
            if(!player HasPerk("specialty_unlimitedsprint"))
                player SetPerk("specialty_unlimitedsprint");
            
            wait 0.05;
        }
    }
    else
    {
        player UnSetPerk("specialty_unlimitedsprint");
        player.UnlimitedSprint = false;
    }
}

ShootWhileSprinting(player)
{
    player endon("disconnect");

    if(!Is_True(player.ShootWhileSprinting))
    {
        player.ShootWhileSprinting = true;

        while(Is_True(player.ShootWhileSprinting))
        {
            if(!player HasPerk("specialty_sprintfire"))
                player SetPerk("specialty_sprintfire");
            
            wait 0.05;
        }
    }
    else
    {
        player UnSetPerk("specialty_sprintfire");
        player.ShootWhileSprinting = false;
    }
}

ServerRespawnPlayer(player)
{
    player endon("disconnect");

    if(player.sessionstate != "spectator")
        return;
    
    if(!isDefined(level.custom_spawnplayer))
        level.custom_spawnplayer = zm::spectator_respawn;

    player [[ level.spawnplayer ]]();
    thread zm::refresh_player_navcard_hud();

    if(isDefined(level.script) && level.round_number > 6 && player.score < 1500)
    {
        player.old_score = player.score;

        if(isDefined(level.spectator_respawn_custom_score))
            player [[ level.spectator_respawn_custom_score ]]();

        player.score = 1500;
    }

    if(player isInMenu(true))
        player closeMenu1();
}

PlayerRevive(player)
{
    player endon("disconnect");

    if(!player isDown())
        return;

    player zm_laststand::auto_revive(player);
}

PlayerDeath(type, player)
{
    player endon("disconnect");
    
    if(Is_True(player.godmode))
        player Godmode(player);

    if(Is_True(player.PlayerDemiGod))
        player DemiGod(player);
    
    player DisableInvulnerability(); //Just to ensure that the player is able to be damaged.

    if(!Is_Alive(player))
        return self iPrintlnBold("^1ERROR: ^7Player Isn't Alive");
    
    switch(type)
    {
        case "Down":
            if(player IsDown())
                return self iPrintlnBold("^1ERROR: ^7Player Is Already Down");
            
            player DoDamage(player.health + 999, (0, 0, 0));
            break;
        
        case "Kill":
            if(level.players.size < 2)
                if(player HasPerk("specialty_quickrevive") || player zm_perks::has_perk_paused("specialty_quickrevive"))
                {
                    player notify("specialty_quickrevive_stop");
                    wait 0.5;
                }

            if(!player IsDown())
            {
                player DoDamage(player.health + 999, (0, 0, 0));
                wait 0.25;
            }
            
            if(player IsDown() && level.players.size > 1)
            {
                player notify("bled_out");
                player zm_laststand::bleed_out();
            }
            break;
        
        default:
            break;
    }
}
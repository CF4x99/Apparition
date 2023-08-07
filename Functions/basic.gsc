Godmode(player)
{
    if(isDefined(player.DemiGod))
        player DemiGod(player);
    
    player.godmode = isDefined(player.godmode) ? undefined : true;

    if(isDefined(player.godmode))
    {
        player endon("disconnect");
        
        while(isDefined(player.godmode))
        {
            player EnableInvulnerability();

            wait 0.05;
        }
    }
    else
        player DisableInvulnerability();
}

DemiGod(player)
{
    if(isDefined(player.godmode))
        player Godmode(player);

    player.DemiGod = isDefined(player.DemiGod) ? undefined : true;
}

Noclip1(player)
{
    if(!isDefined(player.Noclip) && player isPlayerLinked())
        return self iPrintlnBold("^1ERROR: ^7Player Is Linked To An Entity");
    
    player.Noclip = isDefined(player.Noclip) ? undefined : true;
    
    if(isDefined(player.Noclip))
    {
        player endon("disconnect");

        if(player hasMenu() && player isInMenu(true))
            player closeMenu1();

        player DisableWeapons();
        player DisableOffHandWeapons();

        player.nocliplinker = SpawnScriptModel(player.origin, "tag_origin");
        player PlayerLinkTo(player.nocliplinker, "tag_origin");
        player.menu["DisableMenuControls"] = true;

        player SetMenuInstructions("[{+attack}] - Move Forward\n[{+speed_throw}] - Move Backwards\n[{+melee}] - Exit");
        
        while(isDefined(player.Noclip) && Is_Alive(player) && !player isPlayerLinked(player.nocliplinker))
        {
            if(player AttackButtonPressed())
                player.nocliplinker.origin = player.nocliplinker.origin + AnglesToForward(player GetPlayerAngles()) * 60;
            else if(player AdsButtonPressed())
                player.nocliplinker.origin = player.nocliplinker.origin - AnglesToForward(player GetPlayerAngles()) * 60;

            if(player MeleeButtonPressed())
                break;

            wait 0.01;
        }

        if(isDefined(player.Noclip))
            player Noclip1(player);
    }
    else
    {
        player Unlink();
        player.nocliplinker delete();

        player EnableWeapons();
        player EnableOffHandWeapons();

        player.menu["DisableMenuControls"] = undefined;

        player SetMenuInstructions();
    }
}

BindNoclip(player)
{
    if(isDefined(player.Jetpack) && !isDefined(player.NoclipBind))
        return self iPrintlnBold("^1ERROR: ^7Player Has Jetpack Enabled");
    
    if(isDefined(player.SpecNade) && !isDefined(player.NoclipBind))
        return self iPrintlnBold("^1ERROR: ^7Player Has Spec-Nade Enabled");
    
    player.NoclipBind = isDefined(player.NoclipBind) ? undefined : true;
    
    player endon("disconnect");

    while(isDefined(player.NoclipBind))
    {
        if(player FragButtonPressed() && !isDefined(player.menu["DisableMenuControls"]))
        {
            player thread Noclip1(player);
            wait 0.2;
        }

        wait 0.025;
    }
}

UFOMode(player)
{
    if(!isDefined(player.UFOMode) && player isPlayerLinked())
        return self iPrintlnBold("^1ERROR: ^7Player Is Linked To An Entity");
    
    player.UFOMode = isDefined(player.UFOMode) ? undefined : true;
     
    if(isDefined(player.UFOMode))
    {
        player endon("disconnect");

        if(player hasMenu() && player isInMenu(true))
            player closeMenu1();

        player DisableWeapons();
        player DisableOffHandWeapons();

        player.ufolinker = SpawnScriptModel(player.origin, "tag_origin");
        player PlayerLinkTo(player.ufolinker, "tag_origin");
        player.menu["DisableMenuControls"] = true;

        player SetMenuInstructions("[{+attack}] - Move Up\n[{+speed_throw}] - Move Down\n[{+frag}] - Move Forward\n[{+melee}] - Exit");
        
        while(isDefined(player.UFOMode) && Is_Alive(player) && !player isPlayerLinked(player.ufolinker))
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

        if(isDefined(player.UFOMode))
            player thread UFOMode(player);
    }
    else
    {
        player Unlink();
        player.ufolinker delete();

        player EnableWeapons();
        player EnableOffHandWeapons();

        player.menu["DisableMenuControls"] = undefined;

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
            player GiveMaxAmmo(player GetCurrentWeapon());

            if(type == "Continuous")
                player SetWeaponAmmoClip(player GetCurrentWeapon(), player GetCurrentWeapon().clipsize);

            wait 0.05;
        }
    }
}

UnlimitedEquipment(player)
{
    player.UnlimitedEquipment = isDefined(player.UnlimitedEquipment) ? undefined : true;

    player endon("disconnect");

    while(isDefined(player.UnlimitedEquipment))
    {
        player GiveMaxAmmo(player GetCurrentOffhand());

        wait 0.05;
    }
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

    if(player.perks_active.size != level.MenuPerks.size)
    {
        for(a = 0; a < level.MenuPerks.size; a++)
            if(!player HasPerk(level.MenuPerks[a]) && !player zm_perks::has_perk_paused(level.MenuPerks[a]))
                player thread zm_perks::give_perk(level.MenuPerks[a]);
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
    player._retain_perks = isDefined(player._retain_perks) ? undefined : true;

    if(!isDefined(player._retain_perks))
    {
        if(isDefined(player._retain_perks_array))
            player._retain_perks_array = undefined;
        
        for(a = 0; a < level.MenuPerks.size; a++)
            if(player HasPerk(level.MenuPerks[a]) || player zm_perks::has_perk_paused(level.MenuPerks[a]))
                player thread zm_perks::perk_think(level.MenuPerks[a]);
    }
}

GivePlayerPerk(perk, player)
{
    if(player HasPerk(perk) || player zm_perks::has_perk_paused(perk))
        player notify(perk + "_stop");
    else
        player zm_perks::give_perk(perk);
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

            weapon = level.var_adfa48c4;
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
    player.ThirdPerson = isDefined(player.ThirdPerson) ? undefined : true;
    player SetClientThirdPerson(isDefined(player.ThirdPerson));
}

SetMovementSpeed(scale, player)
{
    player notify("EndMoveSpeed");
    player endon("EndMoveSpeed");
    
    player.MovementSpeed = scale;
    player SetMoveSpeedScale(scale);
    
    player endon("disconnect");

    while(player.MovementSpeed != 1)
    {
        player SetMoveSpeedScale(scale);

        wait 0.01;
    }
}

PlayerClone(type, player)
{
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
    player.Invisibility = isDefined(player.Invisibility) ? undefined : true;

    if(isDefined(player.Invisibility))
        player Hide();
    else
        player Show();
}

SaveAndLoad(player)
{
    player.SaveAndLoad = isDefined(player.SaveAndLoad) ? undefined : true;

    if(isDefined(player.SaveAndLoad))
    {
        player iPrintlnBold("Press [{+actionslot 3}] To ^2Save Current Location");
        player iPrintlnBold("Press [{+actionslot 2}] To ^2Load Saved Location");

        player endon("disconnect");

        while(isDefined(player.SaveAndLoad))
        {
            if(player ActionslotThreeButtonPressed())
            {
                player SaveCurrentLocation(player);
                wait 0.05;
            }

            if(player ActionslotTwoButtonPressed() && isDefined(player.SavedOrigin))
            {
                player LoadSavedLocation(player);
                wait 0.05;
            }

            wait 0.05;
        }
    }
}

NoTarget(player)
{   
    player.NoTarget = isDefined(player.NoTarget) ? undefined : true;

    if(isDefined(player.NoTarget))
    {
        player endon("disconnect");

        while(isDefined(player.NoTarget))
        {
            player.ignoreme = true;

            wait 0.1;
        }
    }
    else
        player.ignoreme = false;
}

ReducedSpread(player)
{
    player.ReducedSpread = isDefined(player.ReducedSpread) ? undefined : true;

    if(isDefined(player.ReducedSpread))
    {
        player endon("disconnect");

        while(isDefined(player.ReducedSpread))
        {
            player SetSpreadOverride(1);
            wait 0.1;
        }
    }
    else
        player ResetSpreadOverride();
}

MultiJump(player)
{    
    player.MultiJump = isDefined(player.MultiJump) ? undefined : true;

    player endon("disconnect");

    while(isDefined(player.MultiJump))
    {
        if(player IsOnGround())
            firstJump = true;
        
        if(player JumpButtonPressed() && !player IsOnGround() && isDefined(firstJump))
        {
            while(player JumpButtonPressed())
                wait 0.01;
            
            firstJump = undefined;
        }
        
        if(Is_Alive(player) && !player IsOnGround() && !isDefined(firstJump))
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

PlayerSetVision(vision, player)
{
    if(vision == "Default")
        player UseServerVisionSet(false);
    else
    {
        visions = StrTok(level.menuVisions, ";");

        for(a = 0; a < visions.size; a++)
            if(visions[a] == vision)
            {
                player UseServerVisionSet(true);
                player SetVisionSetForPlayer(level.menuVis[a], 0);
                
                break;
            }
    }
}

GetVisualType(effect)
{
    types = ["visionset", "overlay"];

    for(a = 0; a < types.size; a++)
    {
        Keys = GetArrayKeys(level.vsmgr[types[a]].info);

        for(b = 0; b < Keys.size; b++)
            if(Keys[b] == effect)
                type = isDefined(type) ? "Both" : types[a];
    }

    return type;
}

GetVisualEffectState(effect)
{
    type = GetVisualType(effect);

    if(type == "Both")
    {
        types = ["visionset", "overlay"];

        for(a = 0; a < types.size; a++)
        {
            state = level.vsmgr[types[a]].info[effect].state;

            if(state.players[self GetEntityNumber()].active == 1)
                return true;
        }

        return false;
    }

    state = level.vsmgr[type].info[effect].state;
    
	if(!isDefined(state.players[self GetEntityNumber()]))
		return false;
    
	return state.players[self GetEntityNumber()].active == 1;
}

SetClientVisualEffects(effect, player)
{
    type = GetVisualType(effect);

    if(effect == player.ClientVisualEffect)
        effect = "None";
    else if(effect != player.ClientVisualEffect && player GetVisualEffectState(effect))
        dEffect = effect;

    if(player.ClientVisualEffect != "None" || isDefined(dEffect))
    {
        disable = isDefined(dEffect) ? dEffect : player.ClientVisualEffect;
        removeType = GetVisualType(disable);

        if(removeType == "visionset" || removeType == "Both")
            visionset_mgr::deactivate("visionset", disable, player);
        
        if(removeType == "overlay" || removeType == "Both")
            visionset_mgr::deactivate("overlay", disable, player);
    }

    if(!isDefined(dEffect))
    {
        player.ClientVisualEffect = effect;

        if(effect != "None")
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
    player.NoExplosiveDamage = isDefined(player.NoExplosiveDamage) ? undefined : true;
}

SetCharacterModelIndex(index, player, disableEffect)
{
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
    player.LoopCharacterModelIndex = isDefined(player.LoopCharacterModelIndex) ? undefined : true;

    if(isDefined(player.LoopCharacterModelIndex))
    {
        player endon("disconnect");

        while(isDefined(player.LoopCharacterModelIndex))
        {
            SetCharacterModelIndex(RandomInt(9), player, true);

            wait 0.25;
        }
    }
}

UnlimitedSprint(player)
{
    player.UnlimitedSprint = isDefined(player.UnlimitedSprint) ? undefined : true;

    if(isDefined(player.UnlimitedSprint))
    {
        player endon("disconnect");
        
        while(isDefined(player.UnlimitedSprint))
        {
            if(!player HasPerk("specialty_unlimitedsprint"))
                player SetPerk("specialty_unlimitedsprint");
            
            wait 0.05;
        }
    }
    else
        player UnSetPerk("specialty_unlimitedsprint");
}

ShootWhileSprinting(player)
{
    player.ShootWhileSprinting = isDefined(player.ShootWhileSprinting) ? undefined : true;

    if(isDefined(player.ShootWhileSprinting))
    {
        player endon("disconnect");
        
        while(isDefined(player.ShootWhileSprinting))
        {
            if(!player HasPerk("specialty_sprintfire"))
                player SetPerk("specialty_sprintfire");
            
            wait 0.05;
        }
    }
    else
        player UnSetPerk("specialty_sprintfire");
}

ServerRespawnPlayer(player)
{
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
            player [[level.spectator_respawn_custom_score]]();

        player.score = 1500;
    }

    if(player isInMenu(true))
        player closeMenu1();
}

PlayerRevive(player)
{
    if(!player isDown())
        return;

    player zm_laststand::auto_revive(player);
}

PlayerDeath(type, player)
{
    if(isDefined(player.godmode))
        player Godmode(player);

    if(isDefined(player.DemiGod))
        player DemiGod(player);
    
    player DisableInvulnerability(); //Just to ensure that the player is able to be damaged.

    if(!Is_Alive(player))
        return self iPrintlnBold("^1ERROR: ^7Player Isn't Alive");
    
    wait 0.5;
    
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
            
            if(player IsDown() && level.players.size > 1) //Not using else, because this needs to run whether the block above runs, or not
            {
                player notify("bled_out");
                player zm_laststand::bleed_out();
            }
            break;
        
        default:
            break;
    }
}
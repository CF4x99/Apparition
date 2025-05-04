override_player_damage(einflictor, eattacker, idamage, idflags, smeansofdeath, weapon, vpoint, vdir, shitloc, psoffsettime)
{
    if(Is_True(self.PlayerDemiGod) || Is_True(self.NoExplosiveDamage) && zm_utility::is_explosive_damage(smeansofdeath) || Is_True(level.AllPlayersTeleporting) && !self IsHost() && !self isDeveloper() || Is_True(self.ControllableZombie) || Is_True(self.AC130) || Is_True(self.lander))
    {
        if(Is_True(self.PlayerDemiGod))
            self FakeDamageFrom(vdir);
        
        return 0;
    }

    if(isDefined(level.saved_overrideplayerdamage))
        return [[ level.saved_overrideplayerdamage ]](eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, weapon, vPoint, vDir, sHitLoc, psOffsetTime);
    
    return zm::player_damage_override(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, weapon, vPoint, vDir, sHitLoc, psOffsetTime);
}

override_zombie_damage(mod, hit_location, hit_origin, player, amount, team, weapon, direction_vec, tagname, modelname, partname, dflags, inflictor, chargelevel)
{
    if(zm_utility::is_magic_bullet_shield_enabled(self) || isDefined(self.marked_for_death) || !isDefined(player) || self zm_spawner::check_zombie_damage_callbacks(mod, hit_location, hit_origin, player, amount, weapon, direction_vec, tagname, modelname, partname, dflags, inflictor, chargelevel))
        return;
    
    self CommonDamageOverride(mod, hit_location, hit_origin, player, amount, team, weapon, direction_vec, tagname, modelname, partname, dflags, inflictor, chargelevel);
    self thread [[ level.saved_global_damage_func ]](mod, hit_location, hit_origin, player, amount, team, weapon, direction_vec, tagname, modelname, partname, dflags, inflictor, chargelevel);
}

override_zombie_damage_ads(mod, hit_location, hit_origin, player, amount, team, weapon, direction_vec, tagname, modelname, partname, dflags, inflictor, chargelevel)
{
    if(zm_utility::is_magic_bullet_shield_enabled(self) || !isDefined(player) || self zm_spawner::check_zombie_damage_callbacks(mod, hit_location, hit_origin, player, amount, weapon, direction_vec, tagname, modelname, partname, dflags, inflictor, chargelevel))
        return;
    
    self CommonDamageOverride(mod, hit_location, hit_origin, player, amount, team, weapon, direction_vec, tagname, modelname, partname, dflags, inflictor, chargelevel);
    self thread [[ level.saved_global_damage_func_ads ]](mod, hit_location, hit_origin, player, amount, team, weapon, direction_vec, tagname, modelname, partname, dflags, inflictor, chargelevel);
}

CommonDamageOverride(mod, hit_location, hit_origin, player, amount, team, weapon, direction_vec, tagname, modelname, partname, dflags, inflictor, chargelevel)
{
    if(isDefined(self))
    {
        if(Is_True(level.ZombiesDamageEffect) && isDefined(level.ZombiesDamageFX))
            thread DisplayZombieEffect(level.ZombiesDamageFX, hit_origin);
        
        if(isDefined(player) && IsPlayer(player))
        {
            if(Is_True(player.ExtraGore))
            {
                fx = SpawnFX(level._effect["bloodspurt"], hit_origin, direction_vec);

                if(isDefined(fx))
                    TriggerFX(fx);
            }
            
            if(isDefined(player.hud_damagefeedback) && Is_True(player.ShowHitmarkers))
                player thread DamageFeedBack();

            if(isDefined(player.PlayerInstaKill) && (player.PlayerInstaKill == "All" || player.PlayerInstaKill == "Melee" && mod == "MOD_MELEE"))
            {
                self.health = 1;

                self DoDamage((self.health + 666), self.origin, player, self, hit_location, zm_utility::remove_mod_from_methodofdeath(mod));
                player notify("zombie_killed");
            }
        }
    }
}

override_actor_killed(einflictor, attacker, idamage, smeansofdeath, weapon, vdir, shitloc, psoffsettime)
{
    if(game["state"] == "postgame")
        return;
    
    if(Is_True(level.ZombiesDeathEffect) && isDefined(level.ZombiesDeathFX))
        thread DisplayZombieEffect(level.ZombiesDeathFX, self.origin);
    
    if(isDefined(attacker) && IsPlayer(attacker))
    {
        if(Is_True(attacker.ExtraGore))
        {
            fx = SpawnFX(level._effect["bloodspurt"], self.origin, vdir);

            if(isDefined(fx))
                TriggerFX(fx);
        }

        if(isDefined(attacker.hud_damagefeedback) && Is_True(attacker.ShowHitmarkers))
            attacker thread DamageFeedBack();
        
        if(Is_True(level.initAllTheWeapons))
        {
            baseWeapon = !IsVerkoMap() ? zm_weapons::get_base_weapon(weapon) : weapon;

            if(baseWeapon == level.currentWeaponAllTheWeapons)
                level.killsAllTheWeapons++;
            
            if(level.killsAllTheWeapons >= level.killGoalAllTheWeapons)
            {
                level.indexAllTheWeapons++;
                level.killsAllTheWeapons = 0;
            }
        }
    }
    
    if(Is_True(self.explodingzombie) || Is_True(self.ZombieFling) || Is_True(level.ZombieRagdoll))
    {
        self thread zm_spawner::zombie_ragdoll_then_explode(VectorScale(vdir, 145), attacker);

        if(Is_True(self.explodingzombie) && !Is_True(self.nuked))
            self MagicGrenadeType(GetWeapon("frag_grenade"), self GetTagOrigin("j_mainroot"), (0, 0, 0), 0.01);
    }
    
    self thread [[ level.saved_callbackactorkilled ]](einflictor, attacker, idamage, smeansofdeath, weapon, vdir, shitloc, psoffsettime);
}

override_player_points(damage_weapon, player_points)
{
    if(isDefined(level.saved_player_score_override)) //Der Eisendrache and some custom maps use this override as well
        self [[ level.saved_player_score_override ]](damage_weapon, player_points);
    
    if(isDefined(self.DamagePointsMultiplier) || Is_True(self.DisableEarningPoints))
        player_points = (isDefined(self.DamagePointsMultiplier) && !Is_True(self.DisableEarningPoints)) ? (player_points * self.DamagePointsMultiplier) : 0;
    
    return player_points;
}

DamageFeedBack()
{
    if(isDefined(self.HitMarkerColor))
    {
        if(IsString(self.HitMarkerColor) && self.HitMarkerColor == "Rainbow")
            self.hud_damagefeedback thread HudRGBFade();
        else
        {
            if(Is_True(self.hud_damagefeedback.RGBFade))
                self.hud_damagefeedback.RGBFade = BoolVar(self.hud_damagefeedback.RGBFade);
            
            self.hud_damagefeedback.color = self.HitMarkerColor;
        }
    }
    
    self zombie_utility::show_hit_marker();
    
    if(isDefined(self.HitmarkerFeedback))
        self.hud_damagefeedback SetShaderValues(self.HitmarkerFeedback, 24, 48);
}

DisplayZombieEffect(fx, origin)
{
    impactfx = SpawnFX(level._effect[fx], origin);

    if(isDefined(impactfx))
    {
        TriggerFX(impactfx);
        
        wait 0.5;
        impactfx delete();
    }
}

override_game_over_hud_elem(player, game_over, survived)
{
    game_over.alignx = "CENTER";
    game_over.aligny = "MIDDLE";

    game_over.horzalign = "CENTER";
    game_over.vertalign = "MIDDLE";

    game_over.y = (game_over.y - 130);
    game_over.foreground = 1;
    game_over.fontscale = 3;
    game_over.alpha = 0;
    game_over.color = player hasMenu() ? level.RGBFadeColor : (1, 1, 1);
    game_over.hidewheninmenu = 1;

    game_over SetText(player hasMenu() ? "Thanks For Using " + level.menuName + " Developed By CF4_99" : &"ZOMBIE_GAME_OVER");
    game_over FadeOverTime(1);
    game_over.alpha = 1;

    if(player IsSplitScreen())
    {
        game_over.fontscale = 2;
        game_over.y = (game_over.y + 40);
    }

    survived.alignx = "CENTER";
    survived.aligny = "MIDDLE";

    survived.horzalign = "CENTER";
    survived.vertalign = "MIDDLE";

    survived.y = (survived.y - 100);
    survived.foreground = 1;
    survived.fontscale = 2;
    survived.alpha = 0;
    survived.color = player hasMenu() ? level.RGBFadeColor : (1, 1, 1);
    survived.hidewheninmenu = 1;

    if(player IsHost())
        player thread HoldMeleeToRestart(survived);

    if(player IsSplitScreen())
    {
        survived.fontscale = 1.5;
        survived.y = (survived.y + 40);
    }
}

HoldMeleeToRestart(survived)
{
    if(!isDefined(self))
        return;
    
    self endon("disconnect");

    while(survived.alpha != 1)
        wait 0.05;
    
    survived SetText("Press & Hold [{+melee}] To Restart The Match");
    goal = 15; //1.5 seconds

    while(1)
    {
        count = 0;

        while(self MeleeButtonPressed())
        {
            count++;

            if(count >= goal)
                break;
            
            wait 0.1;
        }

        if(count >= goal)
            break;
        
        wait 0.01;
    }

    if(count >= goal)
        ServerRestartGame();
}

player_out_of_playable_area_monitor()
{
    return 0;
}

WatchForMaxAmmo()
{
    if(Is_True(level.WatchForMaxAmmo))
        return;
    level.WatchForMaxAmmo = true;

    level endon("EndMaxAmmoMonitor");

    while(Is_True(level.ServerMaxAmmoClips))
    {
        level waittill("zmb_max_ammo_level");
        
        if(!Is_True(level.ServerMaxAmmoClips))
            continue;
        
        foreach(player in level.players)
        {
            foreach(weapon in player GetWeaponsList(1))
            {
                if(!isDefined(weapon) || weapon == level.weaponnone)
                    continue;
                
                clipAmmo = player GetWeaponAmmoClip(weapon);
                clipSize = weapon.clipsize;

                if(!isDefined(clipAmmo) || !isDefined(clipSize))
                    continue;

                if(clipAmmo < clipSize)
                    player SetWeaponAmmoClip(weapon, clipSize);

                if(weapon.isdualwield && weapon.dualwieldweapon != level.weaponnone)
                    player SetWeaponAmmoClip(weapon.dualwieldweapon, clipSize);
            }
        }
    }
}

wallbuy_should_upgrade_weapon_override()
{
    return true;
}

onPlayerDisconnect()
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
        else if(player isInMenu() && player getCurrent() == "Players") //If a player is viewing the player menu when a player disconnects, it will refresh the player list
            player RefreshMenu();
    }
}
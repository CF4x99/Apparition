override_player_damage(einflictor, eattacker, idamage, idflags, smeansofdeath, weapon, vpoint, vdir, shitloc, psoffsettime)
{
    if(isDefined(self.NoExplosiveDamage) && zm_utility::is_explosive_damage(smeansofdeath))
        return 0;

    if(isDefined(self.DemiGod))
    {
        self FakeDamageFrom(vdir);
        
        return 0;
    }

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
        if(isDefined(level.ZombiesDamageEffect) && isDefined(level.ZombiesDamageFX))
            thread DisplayZombieEffect(level.ZombiesDamageFX, hit_origin);

        player thread DamageFeedBack();

        if(isDefined(player.PlayerInstaKill))
        {
            self.health = 1;
            modname = zm_utility::remove_mod_from_methodofdeath(mod);

            self DoDamage((self.health + 666), self.origin, player, self, hit_location, modname);
            player notify("zombie_killed");
        }
    }
}

override_actor_killed(einflictor, attacker, idamage, smeansofdeath, weapon, vdir, shitloc, psoffsettime)
{
    if(game["state"] == "postgame")
        return;
    
    if(isDefined(level.ZombiesDeathEffect) && isDefined(level.ZombiesDeathEffect))
        thread DisplayZombieEffect(level.ZombiesDeathFX, self.origin);
    
    if(isDefined(attacker) && IsPlayer(attacker))
        attacker thread DamageFeedBack();

    if(isDefined(self.explodingzombie) || isDefined(self.ZombieFling) || isDefined(level.ZombieRagdoll))
    {
        self thread zm_spawner::zombie_ragdoll_then_explode(VectorScale(vdir, 145), attacker);

        if(isDefined(self.explodingzombie) && !isDefined(self.nuked))
            self MagicGrenadeType(GetWeapon("frag_grenade"), self GetTagOrigin("j_mainroot"), (0, 0, 0), 0.01);
    }
    
    self thread [[ level.saved_callbackactorkilled ]](einflictor, attacker, idamage, smeansofdeath, weapon, vdir, shitloc, psoffsettime);
}

override_player_points(damage_weapon, player_points)
{
    if(isDefined(self.DamagePointsMultiplier))
        player_points *= self.DamagePointsMultiplier;
    
    return player_points;
}

override_server_xp_multiplier(type, n_xp)
{
    return n_xp * level.ServerXPMultiplier;
}

override_player_events()
{
    events = ["death_raps", "death_wasp", "death_spider", "death_thrasher", "death", "death_mechz", "ballistic_knife_death", "damage_light", "damage", "damage_ads", "carpenter_powerup", "rebuild_board", "bonus_points_powerup", "nuke_powerup", "jetgun_fling", "riotshield_fling", "thundergun_fling", "hacker_transfer", "reviver", "vulture", "build_wallbuy", "ww_webbed"];

    foreach(event in events)
        level.a_func_score_events[event] = ::event_override;
}

event_override(event, mod, hit_location, zombie_team, damage_weapon)
{
    player_points = 0;
	team_points = 0;

    switch(event)
    {
        case "death_raps":
        case "death_wasp":
        {
            player_points = mod;

            override_processscoreevent("kill", self, undefined, damage_weapon);
            break;
        }

        case "death_spider":
        {
            player_points = zm_score::get_zombie_death_player_points();

            override_processscoreevent("kill_spider", self, undefined, damage_weapon);
            break;
        }

        case "death_thrasher":
        {
            player_points = zm_score::get_zombie_death_player_points();
            points = self player_add_points_kill_bonus(mod, hit_location, damage_weapon);

            if(level.zombie_vars[self.team]["zombie_powerup_insta_kill_on"] == 1 && mod == "MOD_UNKNOWN")
                points = points * 2;

            player_points = player_points + points;
            player_points = player_points * 2;
            
            if(mod == "MOD_GRENADE" || mod == "MOD_GRENADE_SPLASH")
            {
                self zm_stats::increment_client_stat("grenade_kills");
                self zm_stats::increment_player_stat("grenade_kills");
            }

            override_processscoreevent("kill_thrasher", self, undefined, damage_weapon);
            break;
        }

        case "death":
        {
            player_points = zm_score::get_zombie_death_player_points();
            points = self player_add_points_kill_bonus(mod, hit_location, damage_weapon, player_points);

            if(level.zombie_vars[self.team]["zombie_powerup_insta_kill_on"] == 1 && mod == "MOD_UNKNOWN")
                points = points * 2;

            player_points = player_points + points;

            if(mod == "MOD_GRENADE" || mod == "MOD_GRENADE_SPLASH")
            {
                self zm_stats::increment_client_stat("grenade_kills");
                self zm_stats::increment_player_stat("grenade_kills");
            }
            break;
        }

        case "death_mechz":
        {
            player_points = mod;

            override_processscoreevent("kill_mechz", self, undefined, damage_weapon);
            break;
        }

        case "ballistic_knife_death":
        {
            player_points = zm_score::get_zombie_death_player_points() + level.zombie_vars["zombie_score_bonus_melee"];

            self zm_score::score_cf_increment_info("death_melee");
            break;
        }

        case "damage_light":
        {
            player_points = level.zombie_vars["zombie_score_damage_light"];
            self zm_score::score_cf_increment_info("damage");
            break;
        }

        case "damage":
        {
            player_points = level.zombie_vars["zombie_score_damage_normal"];
            self zm_score::score_cf_increment_info("damage");
            break;
        }

        case "damage_ads":
        {
            player_points = int(level.zombie_vars["zombie_score_damage_normal"] * 1.25);

            self zm_score::score_cf_increment_info("damage");
            break;
        }

        case "carpenter_powerup":
        case "rebuild_board":
        {
            player_points = mod;
            break;
        }

        case "bonus_points_powerup":
        {
            player_points = mod;
            break;
        }

        case "nuke_powerup":
        {
            player_points = mod;
            team_points = mod;
            break;
        }

        case "jetgun_fling":
        case "riotshield_fling":
        case "thundergun_fling":
        {
            player_points = mod;

            override_processscoreevent("kill", self, undefined, damage_weapon);
            break;
        }

        case "hacker_transfer":
        {
            player_points = mod;
            break;
        }

        case "reviver":
        {
            player_points = mod;
            override_processscoreevent("player_did_revived", self, undefined, damage_weapon);
            break;
        }

        case "vulture":
        {
            player_points = mod;
            break;
        }

        case "build_wallbuy":
        {
            player_points = mod;
            break;
        }

        case "ww_webbed":
        {
            player_points = mod;
            break;
        }

        case "death_raz":
        {
            player_points = zm_score::get_zombie_death_player_points();
            points = self player_add_points_kill_bonus(mod, hit_location, damage_weapon);
            player_points = (player_points + points) * 2;

            if(mod == "MOD_GRENADE" || mod == "MOD_GRENADE_SPLASH")
            {
                self zm_stats::increment_client_stat("grenade_kills");
                self zm_stats::increment_player_stat("grenade_kills");
            }

            override_processscoreevent("kill_raz", self, undefined, damage_weapon);
            break;
        }

        case "death_sentinel":
        {
            override_processscoreevent("kill_sentinel", self, undefined, damage_weapon);
            player_points = 100;
        }

        default:
        {
            break;
        }
    }

    return player_points;
}

override_processscoreevent(event, player, victim, weapon)
{
	pixbeginevent("processScoreEvent");

	scoregiven = 0;

	if(!IsPlayer(player))
		return;

	if(isDefined(level.challengesoneventreceived))
		player thread [[ level.challengesoneventreceived ]](event);

	if(scoreevents::isregisteredevent(event) && (!SessionModeIsZombiesGame() || level.onlinegame))
	{
		allowplayerscore = 0;

		if(!isDefined(weapon) || !killstreaks::is_killstreak_weapon(weapon))
			allowplayerscore = 1;
		else
			allowplayerscore = scoreevents::killstreakweaponsallowedscore(event);

		if(allowplayerscore)
		{
			if(isDefined(level.scoreongiveplayerscore))
			{
				scoregiven = [[ level.scoreongiveplayerscore ]](event, player, victim, undefined, weapon);
				isscoreevent = scoregiven > 0;

				if(isscoreevent)
				{
					hero_restricted = scoreevents::is_hero_score_event_restricted(event);
					player ability_power::power_gain_event_score(victim, scoregiven, weapon, hero_restricted);
				}
			}
		}
	}

	if(scoreevents::shouldaddrankxp(player) && GetDvarInt("teamOpsEnabled") == 0)
	{
		pickedup = 0;

		if(isDefined(weapon) && isDefined(player.pickedupweapons) && isDefined(player.pickedupweapons[weapon]))
			pickedup = 1;
        
		player AddRankXP(event, weapon, player.class_num, pickedup, isscoreevent, level.ServerXPMultiplier);
	}

	pixendevent();
    
	return scoregiven;
}

player_add_points_kill_bonus(mod, hit_location, weapon, player_points = undefined)
{
	if(mod != "MOD_MELEE")
	{
		if("head" == hit_location || "helmet" == hit_location)
			override_processscoreevent("headshot", self, undefined, weapon);
		else
			override_processscoreevent("kill", self, undefined, weapon);
	}

	if(isdefined(level.player_score_override))
	{
		new_points = self [[ level.player_score_override ]](weapon, player_points);

		if(new_points > 0 && new_points != player_points)
			return 0;
	}

	if(mod == "MOD_MELEE")
	{
		self zm_score::score_cf_increment_info("death_melee");
		override_processscoreevent("melee_kill", self, undefined, weapon);

		return level.zombie_vars["zombie_score_bonus_melee"];
	}

	if(mod == "MOD_BURNED")
	{
		self zm_score::score_cf_increment_info("death_torso");

		return level.zombie_vars["zombie_score_bonus_burn"];
	}

	score = 0;

	if(isDefined(hit_location))
	{
		switch(hit_location)
		{
			case "head":
			case "helmet":
			{
				self zm_score::score_cf_increment_info("death_head");
				score = level.zombie_vars["zombie_score_bonus_head"];

				break;
			}

			case "neck":
			{
				self zm_score::score_cf_increment_info("death_neck");
				score = level.zombie_vars["zombie_score_bonus_neck"];

				break;
			}

			case "torso_lower":
			case "torso_upper":
			{
				self zm_score::score_cf_increment_info("death_torso");
				score = level.zombie_vars["zombie_score_bonus_torso"];

				break;
			}

			default:
			{
				self zm_score::score_cf_increment_info("death_normal");

				break;
			}
		}
	}

	return score;
}

DamageFeedBack()
{
    if(isDefined(self.hud_damagefeedback) && isDefined(self.ShowHitmarkers))
    {
        if(isDefined(self.HitMarkerColor))
        {
            if(self.HitMarkerColor == "Rainbow")
                self.hud_damagefeedback thread HudRGBFade();
            else
            {
                self.hud_damagefeedback.RGBFade = undefined;
                self.hud_damagefeedback.color = self.HitMarkerColor;
            }
        }
        
        self zombie_utility::show_hit_marker();
        
        if(isDefined(self.HitmarkerFeedback))
            self.hud_damagefeedback SetShaderValues(self.HitmarkerFeedback, 24, 48);
    }
}

DisplayZombieEffect(fx, origin)
{
    impactfx = SpawnFX(level._effect[fx], origin);
    TriggerFX(impactfx);
    
    wait 0.5;
    impactfx delete();
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

    if(player IsSplitScreen())
    {
        survived.fontscale = 1.5;
        survived.y = (survived.y + 40);
    }

    if(level.round_number < 2)
    {
        if(level.script == "zm_moon")
        {
            if(!isDefined(level.left_nomans_land))
            {
                nomanslandtime = level.nml_best_time;
                player_survival_time = Int(nomanslandtime / 1000);
                player_survival_time_in_mins = zm::to_mins(player_survival_time);

                survived SetText(&"ZOMBIE_SURVIVED_NOMANS", player_survival_time_in_mins);
            }
            else if(level.left_nomans_land == 2)
                survived SetText(&"ZOMBIE_SURVIVED_ROUND");
        }
        else
            survived SetText(&"ZOMBIE_SURVIVED_ROUND");
    }
    else
        survived SetText(&"ZOMBIE_SURVIVED_ROUNDS", level.round_number);

    survived FadeOverTime(1);
    survived.alpha = 1;

    if(player hasMenu())
    {
        if(isDefined(survived))
            survived thread HudRGBFade();
        
        if(isDefined(game_over))
            game_over thread HudRGBFade();
    }
}

player_out_of_playable_area_monitor()
{
    return 0;
}

WatchForMaxAmmo()
{
    if(isDefined(level.WatchForMaxAmmo))
        return;
    level.WatchForMaxAmmo = true;

    while(1)
    {
        level waittill("zmb_max_ammo_level");
        
        if(!isDefined(level.ServerMaxAmmoClips))
            continue;
        
        foreach(player in level.players)
        {
            foreach(weapon in player GetWeaponsList(1))
            {
                clipAmmo = player GetWeaponAmmoClip(weapon);
                clipSize = weapon.clipsize;

                if(clipAmmo < clipSize)
                    player SetWeaponAmmoClip(weapon, clipSize);

                if(weapon.isdualwield && weapon.dualwieldweapon != level.weaponnone)
                    player SetWeaponAmmoClip(weapon.dualwieldweapon, clipSize);
            }
        }
    }
}
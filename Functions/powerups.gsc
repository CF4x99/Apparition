PowerUpSpawnLocation(location)
{
    self.PowerUpSpawnLocation = location;
}

SpawnPowerUp(powerup, origin)
{
    if(!isDefined(origin))
    {
        if(self.PowerUpSpawnLocation == "Self")
            origin = self.origin;
        else
        {
            trace = BulletTrace(self GetWeaponMuzzlePoint(), self GetWeaponMuzzlePoint() + VectorScale(AnglesToForward(self GetPlayerAngles()), 1000000), 0, self);
            
            origin = trace["position"];
            surface = trace["surfacetype"];

            if(surface == "none")
                return self iPrintlnBold("^1ERROR: ^7Invalid Surface");
        }
    }
    
    drop = level zm_powerups::specific_powerup_drop(powerup, origin);

    if(isDefined(level.powerup_drop_count) && level.powerup_drop_count)
        level.powerup_drop_count--;
}




//Reign Drops

ReignDropsActivate()
{
	self endon("disconnect");
	self endon("bled_out");

	level thread ReignDropsSpawnPowerup("minigun", self ReturnReignDropOrigin(1));
	self thread ReignDropExtraCreditHandler(self ReturnReignDropOrigin(2));
	level thread ReignDropsSpawnPowerup("nuke", self ReturnReignDropOrigin(3));
	level thread ReignDropsSpawnPowerup("carpenter", self ReturnReignDropOrigin(4));
	level thread ReignDropsSpawnPowerup("free_perk", self ReturnReignDropOrigin(5));
	level thread ReignDropsSpawnPowerup("fire_sale", self ReturnReignDropOrigin(6));
	level thread ReignDropsSpawnPowerup("insta_kill", self ReturnReignDropOrigin(7));
	level thread ReignDropsSpawnPowerup("full_ammo", self ReturnReignDropOrigin(8));
	level thread ReignDropsSpawnPowerup("double_points", self ReturnReignDropOrigin(9));

	self.var_b90dda44 = 1;

	self thread ReignDropsTime();
}

ReignDropsSpawnPowerup(str_powerup, v_origin = self ReignDropsStartOrigin())
{
	var_93eb638b = zm_powerups::specific_powerup_drop(str_powerup, v_origin);

	wait 1;

	if(isDefined(var_93eb638b) && (!var_93eb638b zm::in_enabled_playable_area() && !var_93eb638b zm::in_life_brush()))
		level thread ReignDropRemoveHandler(var_93eb638b);
}

ReignDropsStartOrigin()
{
	return ((self.origin + VectorScale(AnglesToForward((0, self GetPlayerAngles()[1], 0)), 60)));
}

ReignDropRemoveHandler(var_93eb638b)
{
	if(!isDefined(var_93eb638b))
		return;
    
	var_93eb638b Ghost();
	var_93eb638b.clone_model = util::spawn_model(var_93eb638b.model, var_93eb638b.origin, var_93eb638b.angles);
	var_93eb638b.clone_model LinkTo(var_93eb638b);

	direction = var_93eb638b.origin;
	direction = (direction[1], direction[0], 0);

	if(direction[1] < 0 || (direction[0] > 0 && direction[1] > 0))
		direction = (direction[0], direction[1] * -1, 0);
	else if(direction[0] < 0)
		direction = (direction[0] * -1, direction[1], 0);

	if(!(isDefined(var_93eb638b.sndnosamlaugh) && var_93eb638b.sndnosamlaugh))
	{
		players = GetPlayers();

		for(i = 0; i < players.size; i++)
			if(Is_Alive(players[i]))
				players[i] PlayLocalSound(level.zmb_laugh_alias);
	}

	PlayFXOnTag(level._effect["samantha_steal"], var_93eb638b, "tag_origin");
	var_93eb638b.clone_model Unlink();
	var_93eb638b.clone_model MoveZ(60, 1, 0.25, 0.25);
	var_93eb638b.clone_model Vibrate(direction, 1.5, 2.5, 1);
	var_93eb638b.clone_model waittill("movedone");

	if(isDefined(self.damagearea))
		self.damagearea delete();

	var_93eb638b.clone_model delete();

	if(isDefined(var_93eb638b))
	{
		if(isDefined(var_93eb638b.damagearea))
			var_93eb638b.damagearea delete();

		var_93eb638b zm_powerups::powerup_delete();
	}
}

ReturnReignDropOrigin(var_d858aeb5)
{
	var_7ec6c170 = self ReignDropsStartOrigin();

	v_up = VectorScale((0, 0, 1), 5);
	var_8e2dcc47 = var_7ec6c170 + (AnglesToForward(self.angles) * 60);
	var_682b51de = var_8e2dcc47 + (AnglesToForward(self.angles) * 60);

	switch(var_d858aeb5)
	{
		case 1:
			return var_7ec6c170 + (AnglesToRight(self.angles) * -60);

		case 2:
			return var_7ec6c170;
        
		case 3:
			return var_7ec6c170 + (AnglesToRight(self.angles) * 60);
        
		case 4:
			return var_8e2dcc47 + (AnglesToRight(self.angles) * -60);
        
		case 5:
			return var_8e2dcc47;
        
		case 6:
			return var_8e2dcc47 + (AnglesToRight(self.angles) * 60);
        
		case 7:
			return var_682b51de + (AnglesToRight(self.angles) * -60);
        
		case 8:
			return var_682b51de;
        
		case 9:
			return var_682b51de + (AnglesToRight(self.angles) * 60);
        
		default:
			return var_7ec6c170;
	}
}

ReignDropExtraCreditHandler(origin)
{
	self endon("disconnect");
	self endon("bled_out");

	var_93eb638b = zm_powerups::specific_powerup_drop("bonus_points_player", origin, undefined, undefined, 0.1);
	var_93eb638b.bonus_points_powerup_override = ::ReturnReignDropsExtraCredit;

	wait 1;

	if(isDefined(var_93eb638b) && (!var_93eb638b zm::in_enabled_playable_area() && !var_93eb638b zm::in_life_brush()))
		level thread ReignDropRemoveHandler(var_93eb638b);
}

ReturnReignDropsExtraCredit()
{
	return 1250;
}

ReignDropsTime()
{
	wait 0.05;

	n_start_time = GetTime();
	n_total_time = 0;

	while(isDefined(level.active_powerups) && level.active_powerups.size)
	{
		wait 0.5;

		n_current_time = GetTime();
		n_total_time = (n_current_time - (n_start_time / 1000));

		if(n_total_time >= 28)
			break;
	}

	self.var_b90dda44 = undefined;
}
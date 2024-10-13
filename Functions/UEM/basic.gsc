PopulateHatManipulation(menu, player)
{
	switch(menu)
	{
		case "Hat Manipulation":
            hats = Array("_zmu_hat_chicken_hat", "_zmu_hat_tv_hat", "_zmu_paper_bag_hat", "_zmu_christmas_hat", "_zmu_halloween_hat", "_zmu_crown_vip_bronze", "_zmu_crown_vip_silver", "_zmu_crown_vip_gold", "_zmu_crown_vip_master", "_zmu_crown_vip_paragon", "_zmu_crown_vip_ultimate");

            self addMenu("Hat Manipulation");
                self addOptBool(player.ThirdPerson, "Third Person", ::ThirdPerson, player);
                self addOpt("");
                self addOptBool(!isDefined(player.var_1652177e), "None", ::UEMChangeHat, "None", player);
                
                for(a = 0; a < hats.size; a++)
                    self addOptBool(isDefined(player.var_1652177e) && player.var_1652177e == hats[a], CleanString(hats[a]), ::UEMChangeHat, hats[a], player);
            break;
	}
}

UEMChangeHat(hat, player)
{
	player endon("disconnect");

	player notify("player_equip_new_hat");
	wait 0.05;

	if(hat == "None")
	{
		player.var_1652177e = undefined;
		return;
	}

	player Attach(hat, "j_head");
	player.var_1652177e = hat;

	player waittill("player_equip_new_hat");

	if(isDefined(player) && IsAlive(player))
		player Detach(hat, "j_head");
}
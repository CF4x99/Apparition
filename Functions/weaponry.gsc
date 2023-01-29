TakeCurrentWeapon(player)
{
    player TakeWeapon(player GetCurrentWeapon());
}

TakePlayerWeapons(player)
{
    player TakeAllWeapons();
}

DropCurrentWeapon(type, player)
{
    weapon = player GetCurrentWeapon();
    clip = player GetWeaponAmmoClip(player GetCurrentWeapon());
    stock = player GetWeaponAmmoStock(player GetCurrentWeapon());

    player DropItem(weapon);

    if(type == "Don't Take")
    {
        player zm_weapons::weapon_give(weapon, false, false, true);
        player SetWeaponAmmoClip(player GetCurrentWeapon(), clip);
        player SetWeaponAmmoStock(player GetCurrentWeapon(), stock);

        if(!IsSubStr(weapon.name, "_knife"))
            player SwitchToWeaponImmediate(weapon);
    }
}

PackCurrentWeapon(player)
{
    newWeapon = !zm_weapons::is_weapon_upgraded(player GetCurrentWeapon()) ? zm_weapons::get_upgrade_weapon(player GetCurrentWeapon()) : zm_weapons::get_base_weapon(player GetCurrentWeapon());
    
    base_weapon = newWeapon;
    upgraded = 0;

    if(zm_weapons::is_weapon_upgraded(newWeapon))
    {
        upgraded = 1;
        base_weapon = zm_weapons::get_base_weapon(newWeapon);
    }

    if(zm_weapons::is_weapon_included(base_weapon))
		force_attachments = zm_weapons::get_force_attachments(base_weapon.rootweapon);

	if(isDefined(force_attachments) && force_attachments.size)
	{
		if(upgraded)
		{
			packed_attachments = [];

			packed_attachments[packed_attachments.size] = "extclip";
			packed_attachments[packed_attachments.size] = "fmj";

			force_attachments = ArrayCombine(force_attachments, packed_attachments, 0, 0);
		}

		newWeapon = GetWeapon(newWeapon.rootweapon.name, force_attachments);

		if(!isDefined(camo))
			camo = 0;
        
        acvi = 0;
		weapon_options = player CalcWeaponOptions(camo, 0, 0);
	}
	else
	{
		newWeapon = player GetBuildKitWeapon(newWeapon, upgraded);
		weapon_options = player GetBuildKitWeaponOptions(newWeapon, camo);
		acvi = player GetBuildKitAttachmentCosmeticVariantIndexes(newWeapon, upgraded);
	}

    if(!isDefined(newWeapon))
        return;

    player TakeWeapon(player GetCurrentWeapon());
    player GiveWeapon(newWeapon, weapon_options, acvi);
    player GiveStartAmmo(newWeapon);
    player SwitchToWeaponImmediate(newWeapon);
}

SetPlayerCamo(camo, player)
{
    weap = player GetCurrentWeapon();
    weapon = player CalcWeaponOptions(camo, 0, 0);
    NewWeapon = player GetBuildKitAttachmentCosmeticVariantIndexes(weap, zm_weapons::is_weapon_upgraded(player GetCurrentWeapon()));
    
    player TakeWeapon(weap);
    player GiveWeapon(weap, weapon, NewWeapon);
    player SwitchToWeaponImmediate(weap);
}

FlashingCamo(player)
{
    player.FlashingCamo = isDefined(player.FlashingCamo) ? undefined : true;

    player endon("disconnect");

    while(isDefined(player.FlashingCamo))
    {
        camo = RandomInt(138);

        if(!player IsMeleeing() && !player IsSwitchingWeapons() && !player IsReloading() && !player IsSprinting() && !player IsUsingOffhand() && !zm_utility::is_placeable_mine(player GetCurrentWeapon()) && !zm_equipment::is_equipment(player GetCurrentWeapon()) && !player zm_utility::has_powerup_weapon() && !zm_utility::is_hero_weapon(player GetCurrentWeapon()) && !player zm_utility::in_revive_trigger() && !player.is_drinking && player GetCurrentWeapon() != level.weaponnone)
            SetPlayerCamo(camo, player);
        
        wait 0.25;
    }
}

GiveWeaponAAT(aat, player)
{
    if(player.aat[player aat::get_nonalternate_weapon(player GetCurrentWeapon())] != aat)
        player aat::acquire(player GetCurrentWeapon(), aat);
    else
    {
        player aat::remove(player GetCurrentWeapon());
        player clientfield::set_to_player("aat_current", 0);
    }
}

GivePlayerWeapon(weapon, player)
{
    if(player HasWeapon1(weapon))
    {
        weapons = player GetWeaponsList(true);

        for(a = 0; a < weapons.size; a++)
            if(zm_weapons::get_base_weapon(weapons[a]) == zm_weapons::get_base_weapon(weapon))
                weapon = weapons[a];

        player TakeWeapon(weapon);

        return;
    }
    
    player zm_weapons::weapon_give(weapon, false, false, true);
    player GiveStartAmmo(weapon);

    if(!IsSubStr(weapon.name, "_knife"))
        player SwitchToWeaponImmediate(weapon);
}

HasWeapon1(weapon)
{
    weapons = self GetWeaponsList(true);

    for(a = 0; a < weapons.size; a++)
        if(zm_weapons::get_base_weapon(weapons[a]) == zm_weapons::get_base_weapon(weapon))
            return true;

    return false;
}

GivePlayerEquipment(equipment, player)
{
    if(player HasWeapon(equipment))
        player TakeWeapon(equipment);
    else
        player zm_weapons::weapon_give(equipment, false, false, true);
}
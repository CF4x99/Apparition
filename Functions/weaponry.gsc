TakeCurrentWeapon(player)
{
    weapon = player GetCurrentWeapon();

    if(weapon == level.weaponbasemelee || IsSubStr(weapon.name, "_knife"))
        return;
    
    player TakeWeapon(weapon);
}

TakePlayerWeapons(player)
{
    foreach(weapon in player GetWeaponsList(1))
    {
        if(weapon == level.weaponbasemelee || IsSubStr(weapon.name, "_knife"))
            continue;
        
        player TakeWeapon(weapon);
    }
}

DropCurrentWeapon(type, player)
{
    weapon = player GetCurrentWeapon();
    clip = player GetWeaponAmmoClip(player GetCurrentWeapon());
    stock = player GetWeaponAmmoStock(player GetCurrentWeapon());

    if(isDefined(player.aat[player aat::get_nonalternate_weapon(weapon)]))
        aat = player.aat[player aat::get_nonalternate_weapon(weapon)];

    player DropItem(weapon);

    if(type == "Don't Take")
    {
        player zm_weapons::weapon_give(weapon, false, false, true);

        if(isDefined(weapon.savedCamo))
            SetPlayerCamo(weapon.savedCamo, player);
        
        if(isDefined(aat))
            player aat::acquire(weapon, aat);
        
        player SetWeaponAmmoClip(player GetCurrentWeapon(), clip);
        player SetWeaponAmmoStock(player GetCurrentWeapon(), stock);

        if(!IsSubStr(weapon.name, "_knife"))
            player SetSpawnWeapon(weapon, true);
    }
}

PackCurrentWeapon(player)
{
    originalWeapon = player GetCurrentWeapon();
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
    
    
    camo = (!upgraded && isDefined(originalWeapon.savedCamo) && originalWeapon.savedCamo != level.pack_a_punch_camo_index) ? originalWeapon.savedCamo : upgraded ? level.pack_a_punch_camo_index : undefined;

	if(isDefined(force_attachments) && force_attachments.size)
	{
		if(upgraded)
		{
			packed_attachments = [];

			packed_attachments[packed_attachments.size] = "extclip";
			packed_attachments[packed_attachments.size] = "fmj";

			force_attachments = ArrayCombine(force_attachments, packed_attachments, 0, 0);
		}
        
        acvi = 0;

		newWeapon = GetWeapon(newWeapon.rootweapon.name, force_attachments);
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
    
    newWeapon.savedCamo = camo;

    player TakeWeapon(player GetCurrentWeapon());
    player GiveWeapon(newWeapon, weapon_options, acvi);
    player GiveStartAmmo(newWeapon);
    player SetSpawnWeapon(newWeapon, true);
}

GivePlayerAttachment(attachment, player)
{
    weapon = player GetCurrentWeapon();
    attachments = weapon.attachments;

    if(isDefined(player.aat[player aat::get_nonalternate_weapon(weapon)]))
        aat = player.aat[player aat::get_nonalternate_weapon(weapon)];
    
    if(isInArray(attachments, attachment)) //If the weapon has the attachment, it will be removed
    {
        attachments = ArrayRemove(attachments, attachment);
    }
    else //If the weapon doesn't have the attachment, it will be added
    {
        if(!IsValidCombination(attachments, attachment))
        {
            if(isDefined(player.CorrectInvalidCombo)) //Auto-Correct invalid attachment combinations
            {
                invalid = GetInvalidAttachments(attachments, attachment);

                if(isDefined(invalid) && invalid.size)
                    for(a = 0; a < invalid.size; a++)
                        attachments = ArrayRemove(attachments, invalid[a]);
            }
            else
                return self iPrintlnBold("^1ERROR: ^7Invalid Attachment Combination");
        }
        
        array::add(attachments, attachment, 0);

        if(attachments.size > 8)
            return self iPrintlnBold("^1ERROR: ^7Attachment Limit Reached");
    }

    newWeapon = GetWeapon(weapon.rootweapon.name, attachments);
    weapon_options = player CalcWeaponOptions(isDefined(weapon.savedCamo) ? weapon.savedCamo : undefined, 0, 0);
    newWeapon.savedCamo = isDefined(weapon.savedCamo) ? weapon.savedCamo : undefined;
    
    player TakeWeapon(weapon);
    player GiveWeapon(newWeapon, weapon_options);
    player SetSpawnWeapon(newWeapon, true);

    if(isDefined(aat))
        player aat::acquire(newWeapon, aat);
}

IsValidCombination(attachments, attachment)
{
    valid = ReturnAttachmentCombinations(attachment);
    tokens = StrTok(valid, " ");

    for(a = 0; a < attachments.size; a++)
        if(!isInArray(tokens, attachments[a]))
            return false;
    
    return true;
}

GetInvalidAttachments(attachments, attachment)
{
    valid = ReturnAttachmentCombinations(attachment);
    tokens = StrTok(valid, " ");

    invalid = [];

    for(a = 0; a < attachments.size; a++)
        if(!isInArray(tokens, attachments[a]))
            array::add(invalid, attachments[a], 0);
    
    return invalid;
}

CorrectInvalidCombo(player)
{
    player.CorrectInvalidCombo = isDefined(player.CorrectInvalidCombo) ? undefined : true;
}

SetPlayerCamo(camo, player)
{
    weap = player GetCurrentWeapon();
    weapon = player CalcWeaponOptions(camo, 0, 0);
    NewWeapon = player GetBuildKitAttachmentCosmeticVariantIndexes(weap, zm_weapons::is_weapon_upgraded(player GetCurrentWeapon()));
    
    player TakeWeapon(weap);
    player GiveWeapon(weap, weapon, NewWeapon);
    player SetSpawnWeapon(weap, true);

    weap.savedCamo = camo;
}

FlashingCamo(player)
{
    player.FlashingCamo = isDefined(player.FlashingCamo) ? undefined : true;

    player endon("disconnect");

    while(isDefined(player.FlashingCamo))
    {
        camo = RandomInt(139);

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
    
    newWeapon = player zm_weapons::weapon_give(weapon, false, false, true);
    player GiveStartAmmo(newWeapon);

    if(!IsSubStr(weapon.name, "_knife"))
        player SetSpawnWeapon(weapon, true);
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
PopulateWeaponry(menu, player)
{
    switch(menu)
    {
        case "Weaponry":
            weapons = Array("Assault Rifles", "Sub Machine Guns", "Light Machine Guns", "Sniper Rifles", "Shotguns", "Pistols", "Launchers", "Specials");

            self addMenu("Weaponry");
                self addOpt("Options", ::newMenu, "Weapon Options");
                self addOpt("Attachments", ::newMenu, "Weapon Attachments");
                self addOpt("Camo", ::newMenu, "Weapon Camo");
                self addOpt("AAT", ::newMenu, "Weapon AAT");
                self addOpt("");
                self addOpt("Equipment", ::newMenu, "Equipment Menu");

                for(a = 0; a < weapons.size; a++)
                    self addOpt(weapons[a], ::newMenu, weapons[a]);
            break;
        
        case "Weapon Options":
            self addMenu("Options");
                self addOpt("Take Current Weapon", ::TakeCurrentWeapon, player);
                self addOpt("Take All Weapons", ::TakePlayerWeapons, player);
                self addOptSlider("Drop Current Weapon", ::DropCurrentWeapon, "Take;Don't Take", player);
                self addOpt("");
                self addOptBool(player zm_weapons::is_weapon_upgraded(player GetCurrentWeapon()), "Pack 'a' Punch Current Weapon", ::PackCurrentWeapon, player);
            break;
        
        case "Weapon Camo":
            self addMenu("Camo");
                self addOptBool(player.FlashingCamo, "Flashing Camo", ::FlashingCamo, player);
                self addOpt("");

                skip = Array(37, 72, 127, 128, 129, 130); //These are camos that aren't in the game anymore, so they will be skipped

                for(a = 0; a < 139; a++)
                {
                    if(isInArray(skip, a))
                        continue;
                    
                    name = ReturnCamoName((a + 45));

                    if(name == "" || IsSubStr(name, "PLACEHOLDER") || name == "MPUI_CAMO_LOOT_CONTRACT")
                        name = CleanString(ReturnRawCamoName((a + 45)));
                    
                    self addOpt(name, ::SetPlayerCamo, a, player);
                }
            break;
        
        case "Weapon Attachments":
            self addMenu("Attachments");
                self addOptBool(player.CorrectInvalidCombo, "Correct Invalid Combinations", ::CorrectInvalidCombo, player);
                self addOpt("");

                attachmentFound = 0;
                weapon = player GetCurrentWeapon();

                for(a = 0; a < 44; a++)
                {
                    attachment = ReturnAttachment(a);
                    name = ReturnAttachmentName(attachment);

                    if(!isInArray(weapon.supportedAttachments, attachment) || attachment == "none" || attachment == "dw")
                        continue;
                    
                    self addOptBool(isInArray(weapon.attachments, attachment), name, ::GivePlayerAttachment, attachment, player);

                    attachmentFound++;
                }

                if(!attachmentFound)
                    self addOpt("No Supported Attachments Found");
            break;
        
        case "Weapon AAT":
            keys = GetArrayKeys(level.aat);
            
            self addMenu("AAT");
                
                if(isDefined(keys) && keys.size)
                {
                    for(a = 0; a < keys.size; a++)
                    {
                        if(isDefined(keys[a]) && level.aat[keys[a]].name != "none")
                            self addOptBool((isDefined(player.aat[player aat::get_nonalternate_weapon(player GetCurrentWeapon())]) && player.aat[player aat::get_nonalternate_weapon(player GetCurrentWeapon())] == keys[a]), CleanString(level.aat[keys[a]].name), ::GiveWeaponAAT, keys[a], player);
                    }
                }
            break;
        
        case "Equipment Menu":
             if(isDefined(level.zombie_include_equipment))
                include_equipment = GetArrayKeys(level.zombie_include_equipment);
            
            equipment = ArrayCombine(level.zombie_lethal_grenade_list, level.zombie_tactical_grenade_list, 0, 1);
            keys = GetArrayKeys(equipment);
            
            self addMenu("Equipment");

                if(isDefined(keys) && keys.size || isDefined(include_equipment) && include_equipment.size)
                {
                    foreach(index, weapon in GetArrayKeys(level.zombie_weapons))
                        if(isInArray(equipment, weapon))
                            self addOptBool(player HasWeapon(weapon), weapon.displayname, ::GivePlayerEquipment, weapon, player);
                    
                    if(isDefined(include_equipment) && include_equipment.size)
                        foreach(weapon in include_equipment)
                            self addOptBool(player HasWeapon(weapon), weapon.displayname, ::GivePlayerEquipment, weapon, player);
                }
            break;
    }
}

TakeCurrentWeapon(player)
{
    weapon = player GetCurrentWeapon();

    if(!isDefined(weapon) || weapon == level.weaponnone || weapon == level.weaponbasemelee || IsSubStr(weapon.name, "_knife"))
        return;
    
    player TakeWeapon(weapon);
}

TakePlayerWeapons(player)
{
    foreach(weapon in player GetWeaponsList(1))
    {
        if(!isDefined(weapon) || weapon == level.weaponnone || weapon == level.weaponbasemelee || IsSubStr(weapon.name, "_knife"))
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
    player endon("disconnect");

    originalWeapon = player GetCurrentWeapon();

    if(!isDefined(originalWeapon))
        return self iPrintlnBold("^1ERROR: ^7Invalid Weapon");
    
    if(!zm_weapons::is_weapon_upgraded(player GetCurrentWeapon()))
        newWeapon = zm_weapons::get_upgrade_weapon(player GetCurrentWeapon());
    else
        newWeapon = zm_weapons::get_base_weapon(player GetCurrentWeapon());
    
    if(!isDefined(newWeapon))
        return;
    
    base_weapon = newWeapon;
    upgraded = 0;

    if(zm_weapons::is_weapon_upgraded(newWeapon))
    {
        upgraded = 1;
        base_weapon = zm_weapons::get_base_weapon(newWeapon);
    }

    if(zm_weapons::is_weapon_included(base_weapon))
		force_attachments = zm_weapons::get_force_attachments(base_weapon.rootweapon);
    
    if(!upgraded && isDefined(originalWeapon.savedCamo) && originalWeapon.savedCamo != level.pack_a_punch_camo_index)
        camo = originalWeapon.savedCamo;
    else
    {
        if(upgraded)
            camo = level.pack_a_punch_camo_index;
    }

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
    player endon("disconnect");

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
            if(Is_True(player.CorrectInvalidCombo)) //Auto-Correct invalid attachment combinations
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
    camo = 0;

    if(isDefined(weapon.savedCamo))
        camo = weapon.savedCamo;
    
    weapon_options = player CalcWeaponOptions(camo, 0, 0);
    newWeapon.savedCamo = camo;
    
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
    if(!Is_True(player.CorrectInvalidCombo))
        player.CorrectInvalidCombo = true;
    else
        player.CorrectInvalidCombo = false;
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
    player endon("disconnect");

    if(!Is_True(player.FlashingCamo))
    {
        player.FlashingCamo = true;

        while(Is_True(player.FlashingCamo))
        {
            if(!player IsMeleeing() && !player IsSwitchingWeapons() && !player IsReloading() && !player IsSprinting() && !player IsUsingOffhand() && !zm_utility::is_placeable_mine(player GetCurrentWeapon()) && !zm_equipment::is_equipment(player GetCurrentWeapon()) && !player zm_utility::has_powerup_weapon() && !zm_utility::is_hero_weapon(player GetCurrentWeapon()) && !player zm_utility::in_revive_trigger() && !player.is_drinking && player GetCurrentWeapon() != level.weaponnone)
                SetPlayerCamo(RandomInt(139), player);
            
            wait 0.25;
        }
    }
    else
        player.FlashingCamo = false;
}

GiveWeaponAAT(aat, player)
{
    player endon("disconnect");
    
    if(!isDefined(player.aat[player aat::get_nonalternate_weapon(player GetCurrentWeapon())]) || player.aat[player aat::get_nonalternate_weapon(player GetCurrentWeapon())] != aat)
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

    if(!IsSubStr(newWeapon.name, "_knife"))
        player SetSpawnWeapon(newWeapon, true);
}

HasWeapon1(weapon)
{
    if(!isDefined(weapon))
        return false;
    
    weapons = self GetWeaponsList(true);

    if(!isDefined(weapons) || !weapons.size)
        return false;

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
PopulateWeaponry(menu, player)
{
    switch(menu)
    {
        case "Weaponry":
            weapons = Array("Assault Rifles", "Sub Machine Guns", "Light Machine Guns", "Sniper Rifles", "Shotguns", "Pistols", "Launchers", "Specials");

            self addMenu("Weaponry");

                if(!IsVerkoMap())
                {
                    self addOpt("Options", ::newMenu, "Weapon Options");
                    self addOpt("Attachments", ::newMenu, "Weapon Attachments");
                    self addOpt("Loadout", ::newMenu, "Weapon Loadout");
                    self addOpt("Camo", ::newMenu, "Weapon Camo");
                    self addOpt("AAT", ::newMenu, "Weapon AAT");
                }
                else
                {
                    self addOpt("Take Current Weapon", ::TakeCurrentWeapon, player);
                    self addOpt("Take All Weapons", ::TakePlayerWeapons, player);
                    self addOptSlider("Drop Current Weapon", ::DropCurrentWeapon, "Take;Don't Take", player);
                    self addOptSlider("Pack 'a' Punch Current Weapon", ::VerkoPackCurrentWeapon, "None;Upgrade;Mastery", player);
                }

                self addOpt("");
                self addOpt("Equipment", ::newMenu, "Equipment Menu");

                if(!IsVerkoMap())
                {
                    for(a = 0; a < weapons.size; a++)
                        self addOpt(weapons[a], ::newMenu, weapons[a]);
                }
                else
                {
                    for(a = 0; a < level.var_21b77150.size; a++)
                        self addOptBool(player HasWeapon1(GetWeapon(level.var_21b77150[a])), level.var_7df703ba[a], ::GivePlayerWeapon, GetWeapon(level.var_21b77150[a]), player);
                }
            break;
        
        case "Weapon Options":
            self addMenu("Options");
                self addOpt("Take Current Weapon", ::TakeCurrentWeapon, player);
                self addOpt("Take All Weapons", ::TakePlayerWeapons, player);
                self addOptSlider("Drop Current Weapon", ::DropCurrentWeapon, "Take;Don't Take", player);
                self addOptBool(player zm_weapons::is_weapon_upgraded(player GetCurrentWeapon()), "Pack 'a' Punch Current Weapon", ::PackCurrentWeapon, player);
            break;
        
        case "Weapon Loadout":
            self addMenu("Loadout");
                self addOpt("Save Primary Weapon", ::SaveCurrentLoadout, "Primary", player);
                self addOpt("Save Secondary Weapon", ::SaveCurrentLoadout, "Secondary", player);
                self addOpt("Save Primary Offhand", ::SaveCurrentLoadout, "Primary Offhand", player);
                self addOpt("Save Secondary Offhand", ::SaveCurrentLoadout, "Secondary Offhand", player);
                self addOpt("");
                self addOpt("Reset", ::ClearLoadout, player);
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
                    
                    self addOpt((ReturnCamoName((a + 45)) == "" || IsSubStr(ReturnCamoName((a + 45)), "PLACEHOLDER") || ReturnCamoName((a + 45)) == "MPUI_CAMO_LOOT_CONTRACT") ? CleanString(ReturnRawCamoName((a + 45))) : ReturnCamoName((a + 45)), ::SetPlayerCamo, a, player);
                }
            break;
        
        case "Weapon Attachments":
            weapon = player GetCurrentWeapon();
            attachments = [];

            if(isDefined(weapon) && weapon != level.weaponnone)
            {
                for(a = 0; a < 44; a++)
                {
                    if(!isInArray(weapon.supportedAttachments, ReturnAttachment(a)) || ReturnAttachment(a) == "none" || ReturnAttachment(a) == "dw")
                        continue;
                    
                    attachments[attachments.size] = ReturnAttachment(a);
                }
            }
            
            self addMenu("Attachments");

                if(attachments.size)
                {
                    self addOptBool(player.CorrectInvalidCombo, "Correct Invalid Combinations", ::CorrectInvalidCombo, player);
                    self addOpt("");

                    foreach(attachment in attachments)
                        self addOptBool(isInArray(weapon.attachments, attachment), ReturnAttachmentName(attachment), ::GivePlayerAttachment, attachment, player);
                }
                else
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

PackCurrentWeapon(player, buildKit = true)
{
    player endon("disconnect");

    originalWeapon = player GetCurrentWeapon();

    if(!isDefined(originalWeapon))
        return self iPrintlnBold("^1ERROR: ^7Invalid Weapon");

    newWeapon = !zm_weapons::is_weapon_upgraded(player GetCurrentWeapon()) ? zm_weapons::get_upgrade_weapon(player GetCurrentWeapon()) : zm_weapons::get_base_weapon(player GetCurrentWeapon());

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
        if(buildKit)
        {
            newWeapon = player GetBuildKitWeapon(newWeapon, upgraded);
            weapon_options = player GetBuildKitWeaponOptions(newWeapon, camo);
            acvi = player GetBuildKitAttachmentCosmeticVariantIndexes(newWeapon, upgraded);
        }
        else
        {
            acvi = 0;
            weapon_options = player CalcWeaponOptions(camo, 0, 0);
        }
    }

    if(!isDefined(newWeapon))
        return;

    newWeapon.savedCamo = camo;

    player TakeWeapon(player GetCurrentWeapon());
    player GiveWeapon(newWeapon, weapon_options, acvi);
    player GiveStartAmmo(newWeapon);
    player SetSpawnWeapon(newWeapon, true);
}

VerkoPackCurrentWeapon(type, player)
{
    currentWeapon = player GetCurrentWeapon();

    if(!isDefined(currentWeapon) || currentWeapon == level.weaponnone)
        return self iPrintlnBold("^1ERROR: ^7Not A Valid Weapon");
    
    if(isInArray(level.var_21b77150, currentWeapon.name))
    {
        currentArray = level.var_21b77150;

        if(type == "None")
            return;
    }
    else if(isInArray(level.var_2b893b73, currentWeapon.name))
    {
        currentArray = level.var_2b893b73;

        if(type == "Upgrade")
            return;
    }
    else if(isInArray(level.var_23af580e, currentWeapon.name))
    {
        currentArray = level.var_23af580e;

        if(type == "Mastery")
            return;
    }
    else
        return self iPrintlnBold("^1ERROR: Not A Valid Weapon");
    
    weaponIndex = 0;

    for(a = 0; a < currentArray.size; a++)
        if(currentArray[a] == currentWeapon.name)
            weaponIndex = a;
    
    switch(type)
    {
        case "None":
            newWeapon = GetWeapon(level.var_21b77150[weaponIndex]);
            break;
        
        case "Upgrade":
            newWeapon = GetWeapon(level.var_2b893b73[weaponIndex]);
            break;
        
        case "Mastery":
            newWeapon = GetWeapon(level.var_23af580e[weaponIndex]);
            break;
    }
    
    player TakeWeapon(currentWeapon);
    player GiveWeapon(newWeapon);
    player GiveStartAmmo(newWeapon);
    player SetSpawnWeapon(newWeapon, true);
    wait 0.05;

    if(type == "Mastery")
        player thread aat::acquire(newWeapon, VerkoGetAAT(level.var_fc480cef[weaponIndex]));
}

VerkoGetAAT(aat)
{
    switch(aat)
    {
        case "deadwire":
            return "zm_aat_dead_wire";
        
        case "blastfurnace":
            return "zm_aat_blast_furnace";
        
        case "thunderwall":
            return "zm_aat_thunder_wall";
        
        case "turned":
            return "zm_aat_turned";
        
        case "fireworks":
            return "zm_aat_fire_works";
        
        case "aethercollapse":
            return "zm_aat_aethercollapse";
    }
}

GivePlayerAttachment(attachment, player, override = false)
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
            if(Is_True(player.CorrectInvalidCombo) || override) //Auto-Correct invalid attachment combinations
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
    camo = isDefined(weapon.savedCamo) ? weapon.savedCamo : 0;
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
    player.CorrectInvalidCombo = BoolVar(player.CorrectInvalidCombo);
}

SaveCurrentLoadout(type, player)
{
    userID = player GetXUID();

    if(!IsSubStr(ToLower(type), "offhand"))
    {
        weapon = player GetCurrentWeapon();

        if(!isDefined(weapon) || weapon == level.weaponnone || weapon == level.weaponbasemelee || IsSubStr(weapon.name, "_knife"))
            return self iPrintlnBold("^1ERROR: ^7Invalid Weapon");

        if(isDefined(weapon.attachments) && weapon.attachments.size)
        {
            attachments = "";

            foreach(index, attachment in weapon.attachments)
                attachments += (index == weapon.attachments.size) ? attachment : attachment + ";";
        }
        else
            attachments = "none";
        
        SetDvar("Loadout_" + type + "_" + userID, zm_weapons::get_base_weapon(weapon).name);
        SetDvar("Loadout_" + type + "_Attachments_" + userID, attachments);
        SetDvar("Loadout_" + type + "_Camo_" + userID, isDefined(weapon.savedCamo) ? weapon.savedCamo : 0);
        SetDvar("Loadout_" + type + "_Upgraded_" + userID, zm_weapons::is_weapon_upgraded(weapon));
        SetDvar("Loadout_" + type + "_AAT_" + userID, isDefined(player.aat[player aat::get_nonalternate_weapon(weapon)]) ? player.aat[player aat::get_nonalternate_weapon(weapon)] : "none");
    }
    else
    {
        saveType = (type == "Primary Offhand") ? "primary_offhand" : "secondary_offhand";
        weapon = (type == "Primary Offhand") ? player zm_utility::get_player_lethal_grenade() : player zm_utility::get_player_tactical_grenade();
        
        if(!isDefined(weapon) || weapon == level.weaponnone)
            return self iPrintlnBold("^1ERROR: ^7Invalid Offhand");
        
        SetDvar("Loadout_" + saveType + "_" + userID, weapon.name);
    }
    
    SetDvar("Apparition_Loadout_" + userID, 1);
    self iPrintlnBold(type + " ^2Saved");
}

ClearLoadout(player)
{
    saved = GetDvarInt("Apparition_Loadout_" + userID);

    if(!isDefined(saved) || !saved)
        return;
    
    userID = player GetXUID();
    types = Array("Primary", "Secondary");

    SetDvar("Apparition_Loadout_" + userID, 0);

    foreach(type in types)
    {
        SetDvar("Loadout_" + type + "_" + userID, "");
        SetDvar("Loadout_" + type + "_Attachments_" + userID, "");
        SetDvar("Loadout_" + type + "_Camo_" + userID, 0);
        SetDvar("Loadout_" + type + "_Upgraded_" + userID, 0);
        SetDvar("Loadout_" + type + "_AAT_" + userID, "");
    }

    types = Array("Primary Offhand", "Secondary Offhand");

    foreach(type in types)
        SetDvar("Loadout_" + type + "_" + userID, "");

    self iPrintlnBold("Loadout ^2Cleared");
}

GivePlayerLoadout()
{
    userID = self GetXUID();
    
    if(GetDvarInt("Apparition_Loadout_" + userID))
    {
        types = Array("Secondary", "Primary");
        first = true;

        foreach(type in types)
        {
            weapon = GetDvarString("Loadout_" + type + "_" + userID);

            if(!isDefined(weapon) || weapon == "" || !isInArrayKeys(level.zombie_weapons, GetWeapon(weapon)))
                continue;
            
            if(first)
            {
                foreach(primary in self GetWeaponsListPrimaries())
                {
                    if(!isDefined(primary) || primary == level.weaponnone || primary == level.weaponbasemelee || IsSubStr(primary.name, "_knife"))
                        continue;
                    
                    self TakeWeapon(primary);
                }

                first = false;
            }

            newWeapon = GivePlayerWeapon(GetWeapon(weapon), self);

            if(isDefined(newWeapon.attachments) && newWeapon.attachments.size) //Fix for build kit attachments conflicting saved attachments
            {
                attachments = [];
                baseWeapon = GetWeapon(newWeapon.rootweapon.name, attachments);

                self TakeWeapon(newWeapon);
                self GiveWeapon(baseWeapon);
                self SetSpawnWeapon(baseWeapon, true);
            }

            if(GetDvarInt("Loadout_" + type + "_Upgraded_" + userID))
                PackCurrentWeapon(self, false);
            
            weaponCamo = GetDvarInt("Loadout_" + type + "_Camo_" + userID);

            if(weaponCamo)
            {
                newWeapon.savedCamo = weaponCamo;
                SetPlayerCamo(weaponCamo, self);
            }

            weaponAAT = GetDvarString("Loadout_" + type + "_AAT_" + userID);

            if(isDefined(weaponAAT) && weaponAAT != "" && weaponAAT != "none")
                GiveWeaponAAT(weaponAAT, self);
            
            weaponAttachments = GetDvarString("Loadout_" + type + "_Attachments_" + userID);

            if(isDefined(weaponAttachments) && weaponAttachments != "" && weaponAttachments != "none")
            {
                attachments = StrTok(weaponAttachments, ";");

                for(a = 0; a < attachments.size; a++)
                    GivePlayerAttachment(attachments[a], self, true);
            }
        }

        level flag::wait_till("initial_blackscreen_passed");
        wait 4;

        types = Array("primary_offhand", "secondary_offhand");

        foreach(type in types)
        {
            weapon = GetDvarString("Loadout_" + type + "_" + userID);

            if(!isDefined(weapon) || weapon == "" || weapon == level.weaponnone || !isInArrayKeys(level.zombie_weapons, GetWeapon(weapon)) && !isInArrayKeys(level.zombie_include_equipment, GetWeapon(weapon)))
                continue;
            
            if(self HasWeapon(GetWeapon(weapon)))
            {
                self GiveStartAmmo(GetWeapon(weapon));
                continue;
            }
            
            GivePlayerEquipment(GetWeapon(weapon), self);
            self GiveStartAmmo(GetWeapon(weapon));
        }
    }
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

    player.FlashingCamo = BoolVar(player.FlashingCamo);

    while(Is_True(player.FlashingCamo))
    {
        if(!player IsMeleeing() && !player IsSwitchingWeapons() && !player IsReloading() && !player IsSprinting() && !player IsUsingOffhand() && !zm_utility::is_placeable_mine(player GetCurrentWeapon()) && !zm_equipment::is_equipment(player GetCurrentWeapon()) && !player zm_utility::has_powerup_weapon() && !zm_utility::is_hero_weapon(player GetCurrentWeapon()) && !player zm_utility::in_revive_trigger() && !player.is_drinking && player GetCurrentWeapon() != level.weaponnone)
            SetPlayerCamo(RandomInt(139), player);
        
        wait 0.25;
    }
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

GivePlayerEquipment(equipment, player)
{
    if(player HasWeapon(equipment))
        player TakeWeapon(equipment);
    else
        player zm_weapons::weapon_give(equipment, false, false, true);
}

GivePlayerWeapon(weapon, player)
{
    if(player HasWeapon1(weapon))
    {
        weapons = player GetWeaponsList(true);

        if(!IsVerkoMap())
        {
            for(a = 0; a < weapons.size; a++)
                if(zm_weapons::get_base_weapon(weapons[a]) == zm_weapons::get_base_weapon(weapon))
                    weapon = weapons[a];
        }
        else
        {
            for(a = 0; a < weapons.size; a++)
                if(VerkoGetBaseWeapon(weapons[a]) == VerkoGetBaseWeapon(weapon))
                    weapon = weapons[a];
        }

        player TakeWeapon(weapon);
        return;
    }
    
    newWeapon = player zm_weapons::weapon_give(weapon, false, false, true);
    player GiveStartAmmo(newWeapon);

    if(!IsSubStr(newWeapon.name, "_knife"))
        player SetSpawnWeapon(newWeapon, true);
    
    return newWeapon;
}

VerkoGetBaseWeapon(weapon)
{
    if(!isInArray(level.var_2b893b73, weapon.name) && !isInArray(level.var_23af580e, weapon.name))
        return weapon;
    
    if(isInArray(level.var_2b893b73, weapon.name))
        currentArray = level.var_2b893b73;
    else if(isInArray(level.var_23af580e, weapon.name))
        currentArray = level.var_23af580e;
    
    if(!isDefined(currentArray))
        return weapon;
    
    for(a = 0; a < currentArray.size; a++)
        if(currentArray[a] == weapon.name)
            return GetWeapon(level.var_21b77150[a]);
}

HasWeapon1(weapon)
{
    if(!isDefined(weapon))
        return false;
    
    weapons = self GetWeaponsList(true);

    if(!isDefined(weapons) || !weapons.size)
        return false;

    if(!IsVerkoMap())
    {
        for(a = 0; a < weapons.size; a++)
            if(zm_weapons::get_base_weapon(weapons[a]) == zm_weapons::get_base_weapon(weapon))
                return true;
    }
    else
    {
        for(a = 0; a < weapons.size; a++)
            if(VerkoGetBaseWeapon(weapons[a]) == VerkoGetBaseWeapon(weapon))
                return true;
    }

    return false;
}
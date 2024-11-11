
runMenuIndex(menu)
{
    self endon("disconnect");
    
    switch(menu)
    {
        case "Main":
            titleString = level.menuName;

            if(self.MenuStyle == "Native")
                titleString = "Main Menu";
            
            self addMenu(titleString);
                self addOpt("Basic Scripts", ::newMenu, "Basic Scripts");
                self addOpt("Menu Customization", ::newMenu, "Menu Customization");
                self addOpt("Message Menu", ::newMenu,"Message Menu");
                self addOpt("Teleport Menu", ::newMenu, "Teleport Menu");

                if(self getVerification() > 2) //VIP
                {
                    self addOpt("Power-Up Menu", ::newMenu, "Power-Up Menu");

                    if(SessionModeIsOnlineGame())
                        self addOpt("Profile Management", ::newMenu, "Profile Management");
                    
                    self addOpt("Weaponry", ::newMenu, "Weaponry");
                    self addOpt("Bullet Menu", ::newMenu, "Bullet Menu");
                    self addOpt("Fun Scripts", ::newMenu, "Fun Scripts");
                    self addOpt("Model Manipulation", ::newMenu, "Model Manipulation");
                    self addOpt("Aimbot Menu", ::newMenu, "Aimbot Menu");

                    if(self getVerification() > 3) //Admin
                    {
                        self addOpt("Advanced Scripts", ::newMenu, "Advanced Scripts");

                        if(ReturnMapName(level.script) != "Unknown")
                            self addOpt(ReturnMapName(level.script) + " Scripts", ::newMenu, ReturnMapName(level.script) + " Scripts");

                        self addOpt("Forge Options", ::newMenu, "Forge Options");
                        
                        if(self getVerification() > 4) //Co-Host
                        {
                            self addOpt("Server Modifications", ::newMenu, "Server Modifications");
                            self addOpt("Zombie Options", ::newMenu, "Zombie Options");
                            self addOpt("Spawnables", ::newMenu, "Spawnables");

                            if(self IsHost() || self isDeveloper())
                                self addOpt("Host Menu", ::newMenu, "Host Menu");
                            
                            self addOpt("Players Menu", ::newMenu, "Players");
                            self addOpt("All Players Menu", ::newMenu, "All Players");
                        }
                    }
                }
            break;
        
        case "Quick Menu":
            self addMenu("Quick Menu H4X");

                if(Is_Alive(self))
                {
                    self addOptBool(self.godmode, "God Mode", ::Godmode, self);
                    self addOptBool(self.Noclip, "Noclip", ::Noclip1, self);
                    self addOptBool(self.NoclipBind1, "Bind Noclip To [{+frag}]", ::BindNoclip, self);
                    self addOptSlider("Unlimited Ammo", ::UnlimitedAmmo, "Continuous;Reload;Disable", self);
                    self addOptBool(self.UnlimitedEquipment, "Unlimited Equipment", ::UnlimitedEquipment, self);
                    self addOptSlider("Modify Score", ::ModifyScore, "1000000;100000;10000;1000;100;10;0;-10;-100;-1000;-10000;-100000;-1000000", self);
                    self addOpt("Perk Menu", ::newMenu, "Perk Menu");
                    self addOptBool(self.playerIgnoreMe, "No Target", ::NoTarget, self);
                    self addOptBool(self.ReducedSpread, "Reduced Spread", ::ReducedSpread, self);
                    self addOptBool(self.UnlimitedSprint, "Unlimited Sprint", ::UnlimitedSprint, self);
                }

                self addOpt("Respawn", ::ServerRespawnPlayer, self);

                if(Is_Alive(self))
                    self addOpt("Revive", ::PlayerRevive, self);

                if(self IsHost() || self IsDeveloper())
                {
                    self addOpt("Restart Game", ::ServerRestartGame);
                    self addOpt("Disconnect", ::disconnect);
                }
            break;
        
        case "Menu Customization":
        case "Design Preferences":
        case "Main Design Color":
        case "Title Color":
        case "Options Color":
        case "Toggled Option Color":
        case "Scrolling Option Color":
            self PopulateMenuCustomization(menu);
            break;
        
        case "Message Menu":
        case "Miscellaneous Messages":
        case "Advertisements Messages":
            self PopulateMessageMenu(menu);
            break;
        
        case "Power-Up Menu":
            self PopulatePowerupMenu(menu);
            break;
        
        case "Advanced Scripts":
        case "Rain Options":
        case "Rain Models":
        case "Rain Effects":
        case "Rain Projectiles":
        case "Custom Sentry":
            self PopulateAdvancedScripts(menu);
            break;
        
        case "Forge Options":
        case "Spawn Script Model":
        case "Rotate Script Model":
            self PopulateForgeOptions(menu);
            break;
        
        case "The Giant Scripts":
        case "The Giant Teleporters":
            self PopulateTheGiantScripts(menu);
            break;
        
        case "Nacht Der Untoten Scripts":
            self PopulateNachtScripts(menu);
            break;
        
        case "Kino Der Toten Scripts":
            self PopulateKinoScripts(menu);
            break;
        
        case "Moon Scripts":
            self PopulateMoonScripts(menu);
            break;
        
        case "Shangri-La Scripts":
            self PopulateShangriLaScripts(menu);
            break;
        
        case "Verruckt Scripts":
            self PopulateVerrucktScripts(menu);
            break;
        
        case "Shi No Numa Scripts":
            self PopulateShinoScripts(menu);
            break;
        
        case "Origins Scripts":
        case "Origins Generators":
        case "Origins Gateways":
        case "Give Shovel Origins":
        case "Give Helmet Origins":
        case "Soul Boxes":
        case "Origins Challenges":
        case "Origins Puzzles":
        case "Ice Puzzles":
        case "Wind Puzzles":
        case "Fire Puzzles":
        case "Lightning Puzzles":
            self PopulateOriginsScripts(menu);
            break;
        
        case "Gorod Krovi Scripts":
            self PopulateGorodKroviScripts(menu);
            break;
        
        case "Zetsubou No Shima Scripts":
        case "Zetsubou No Shima KT-4 Parts":
        case "Map Challenges":
        case "Skulltar Teleports":
        case "ZNS Bucket Water":
            self PopulateZetsubouNoShimaScripts(menu);
            break;
        
        case "Ascension Scripts":
            self PopulateAscensionScripts(menu);
            break;
        
        case "Der Eisendrache Scripts":
        case "Bow Quests":
        case "Fire Bow":
        case "Lightning Bow":
        case "Void Bow":
        case "Wolf Bow":
            self PopulateDerEisendracheScripts(menu);
            break;
        
        case "Shadows Of Evil Scripts":
        case "Beast Mode":
        case "SOE Fumigator":
        case "SOE Smashables":
        case "SOE Power Switches":
            self PopulateSOEScripts(menu);
            break;
        
        case "Revelations Scripts":
        case "Revelations Keeper Companion":
            self PopulateRevelationsScripts(menu);
            break;
        
        case "Server Modifications":
        case "Doheart Options":
        case "Lobby Timer Options":
        case "Zombie Craftables":
        case "Zombie Traps":
        case "Mystery Box Options":
        case "Mystery Box Weapons":
        case "Mystery Box Normal Weapons":
        case "Mystery Box Upgraded Weapons":
        case "Joker Model":
        case "Server Tweakables":
        case "Change Map":
            self PopulateServerModifications(menu);
            break;
        
        case "Zombie Options":
        case "AI Spawner":
        case "Prioritize Players":
        case "Zombie Model Manipulation":
        case "Zombie Animations":
        case "Zombie Death Effect":
        case "Zombie Damage Effect":
            self PopulateZombieOptions(menu);
            break;
        
        case "Spawnables":
            self PopulateSpawnables(menu);
            break;
        
        case "Host Menu":
            self addMenu("Host Menu");
                self addOpt("Disconnect", ::disconnect);
                self addOpt("Player Info", ::newMenu, "Player Info");
                self addOpt("Custom Map Spawns", ::newMenu, "Custom Map Spawns");
                self addOptBool(level.AntiEndGame, "Anti-End Game", ::AntiEndGame);
                self addOptBool((GetDvarInt("migration_forceHost") == 1), "Force Host", ::ForceHost);
                self addOptBool(level.GSpawnProtection, "G_Spawn Crash Protection", ::GSpawnProtection);
                self addOptBool((GetDvarString("r_showTris") == "1"), "Tris Lines", ::TrisLines);
                self addOptBool((GetDvarString("ui_lobbyDebugVis") == "1"), "DevGui Info", ::DevGUIInfo);
                self addOptBool((GetDvarString("r_fog") == "0"), "Disable Fog", ::DisableFog);
                self addOptBool((GetDvarString("sv_cheats") == "1"), "SV Cheats", ::ServerCheats);
                self addOptBool((GetDvarInt("developer") == 2), "Developer Mode", ::SetDeveloperMode);
            break;
        
        case "Player Info":
            self addMenu("Player Info");
                self addOptBool(level.DisablePlayerInfo, "Disable", ::DisablePlayerInfo);
                self addOptBool(level.IncludeIPInfo, "Include IP", ::IncludeIPInfo);
            break;
        
        case "Custom Map Spawns":
            self addMenu("Custom Map Spawns");
                self addOptSlider("Set Map Spawn Location", ::SetMapSpawn, "Player 1;Player 2;Player 3;Player 4", "Set");
                self addOptSlider("Clear Map Spawn Location", ::SetMapSpawn, "Player 1;Player 2;Player 3;Player 4", "Clear");
            break;
        
        case "All Players":
        case "All Players Verification":
        case "All Players Profile Management":
        case "Clan Tag Options All Players":
        case "All Players Model Manipulation":
        case "All Players Malicious Options":
            self PopulateAllPlayerOptions(menu);
            break;
        
        case "Players":
            self addMenu("Players");

                foreach(player in level.players)
                {
                    if(!isDefined(player.verification)) //If A Player Doesn't Have A Verification Set, They Won't Show. Mainly Happens If They Are Still Connecting
                        player.verification = level.MenuStatus[1];
                    
                    self addOpt("[^2" + player.verification + "^7]" + CleanName(player getName()), ::newMenu, "Options");
                }
            break;
        
        default:
            craftables = GetArrayKeys(level.zombie_include_craftables);

            if(isInArray(craftables, menu))
            {
                self addMenu(CleanString(menu));

                    for(a = 0; a < craftables.size; a++)
                    {
                        if(craftables[a] != menu)
                            continue;
                        
                        craftable = craftables[a];
                        
                        if(isDefined(craftable))
                        {
                            if(!IsCraftableCollected(craftable))
                            {
                                self addOpt("Collect All", ::CollectCraftableParts, craftable);
                                self addOpt("");
                            }

                            foreach(part in level.zombie_include_craftables[craftable].a_piecestubs)
                            {
                                if(IsPartCollected(part))
                                    continue;
                                
                                if(isDefined(part.pieceSpawn.model))
                                    self addOpt(CleanString(part.pieceSpawn.piecename), ::CollectCraftablePart, part);
                            }
                        }
                    }
            }
            else
            {
                if(!isDefined(self.SelectedPlayer))
                    self.SelectedPlayer = self;
                
                self MenuOptionsPlayer(menu, self.SelectedPlayer);
            }

            break;
    }
}

MenuOptionsPlayer(menu, player)
{
    self endon("disconnect");
    
    if(!isDefined(player) || !IsPlayer(player))
        menu = "404";
    
    switch(menu)
    {
        case "Basic Scripts":
        case "Perk Menu":
        case "Gobblegum Menu":
        case "Visual Effects":
            self PopulateBasicScripts(menu, player);
            break;
        
        case "Teleport Menu":
        case "Entity Teleports":            
            self PopulateTeleportMenu(menu, player);
            break;
        
        case "Profile Management":
        case "Clan Tag Options":
        case "Custom Stats":
        case "General Stats":
        case "Gobblegum Stats":
        case "Map Stats":
        case "EE Stats":
            self PopulateProfileManagement(menu, player);
            break;

        case "Weaponry":
        case "Weapon Options":
        case "Weapon Loadout":
        case "Weapon Camo":
        case "Weapon Attachments":
        case "Weapon AAT":
        case "Equipment Menu":
            self PopulateWeaponry(menu, player);
            break;
        
        case "Bullet Menu":
        case "Weapon Projectiles":
        case "Weapon Bullets":
        case "Normal Weapon Bullets":
        case "Upgraded Weapon Bullets":
        case "Equipment Bullets":
        case "Bullet Effects":
        case "Bullet Spawnables":
        case "Explosive Bullets":
            self PopulateBulletMenu(menu, player);
            break;
        
        case "Fun Scripts":
        case "Sound/Music":
        case "Perk Jingles & Quotes":
        case "Hit Markers":
        case "Force Field Options":
            self PopulateFunScripts(menu, player);
            break;
        
        case "Model Manipulation":            
            self PopulateModelManipulation(menu, player);
            break;
        
        case "Aimbot Menu":
            self PopulateAimbotMenu(menu, player);
            break;
        
        case "Map Challenges Player":
            self PopulateMapChallenges(player);
            break;
        
        case "Origins Challenges Player":
            self PopulateOriginsChallenges(player);
            break;
        
        case "Options":
        case "Verification":
        case "Model Attachment":
        case "Malicious Options":
        case "Disable Actions":
            self PopulatePlayerOptions(menu, player);
            break;
        
        default:
            weapons = Array("Assault Rifles", "Sub Machine Guns", "Light Machine Guns", "Sniper Rifles", "Shotguns", "Pistols", "Launchers", "Specials");
            weaponsVar = Array("assault", "smg", "lmg", "sniper", "cqb", "pistol", "launcher", "special");

            if(isInArray(weapons, menu))
            {
                pistols = Array("pistol_standard", "pistol_burst", "pistol_fullauto", "pistol_m1911", "pistol_revolver38", "pistol_c96");
                
                foreach(index, weapon_category in weapons)
                {
                    if(menu != weapon_category)
                        continue;
                    
                    self addMenu(weapon_category);

                        foreach(weapon in GetArrayKeys(level.zombie_weapons))
                        {
                            if(menu == "Specials" && (isInArray(pistols, weapon.name) || zm_utility::GetWeaponClassZM(weapon) != "weapon_special" && zm_utility::GetWeaponClassZM(weapon) != "weapon_pistol"))
                                continue;
                            
                            if(zm_utility::GetWeaponClassZM(weapon) != "weapon_" + weaponsVar[index] && menu != "Specials" || MakeLocalizedString(weapon.displayname) == "" || weapon.isgrenadeweapon || weapon.name == "knife" || IsSubStr(weapon.name, "upgraded") || weapon.name == "none")
                                continue;
                            
                            strng = weapon.name;

                            if(MakeLocalizedString(weapon.displayname) != "")
                                strng = weapon.displayname;

                            self addOptBool(player HasWeapon1(weapon), strng, ::GivePlayerWeapon, weapon, player);
                        }
                }

                if(menu == "Specials")
                {
                    self addOptBool(player HasWeapon1(GetWeapon("defaultweapon")), "Default Weapon", ::GivePlayerWeapon, GetWeapon("defaultweapon"), player);
                    self addOptBool(player HasWeapon1(GetWeapon("minigun")), GetWeapon("minigun").displayname, ::GivePlayerWeapon, GetWeapon("minigun"), player);

                    if(ReturnMapName(level.script) == "Shadows Of Evil")
                        self addOptBool(player HasWeapon1(GetWeapon("tesla_gun")), GetWeapon("tesla_gun").displayname, ::GivePlayerWeapon, GetWeapon("tesla_gun"), player);
                }
            }
            else if(isInArray(level.MenuVOXCategory, menu))
                self PopulateFunScripts(menu, player);
            else
            {
                error404 = true;
                mapNames = Array("zm_zod", "zm_factory", "zm_castle", "zm_island", "zm_stalingrad", "zm_genesis", "zm_prototype", "zm_asylum", "zm_sumpf", "zm_theater", "zm_cosmodrome", "zm_temple", "zm_moon", "zm_tomb");

                for(a = 0; a < mapNames.size; a++)
                {
                    if(IsSubStr(menu, "Map Stats " + mapNames[a]) || menu == "Map Stats " + mapNames[a])
                    {
                        error404 = false;
                        mapStats = Array("score", "total_games_played", "total_rounds_survived", "highest_round_reached", "time_played_total", "total_downs");

                        self addMenu(ReturnMapName(mapNames[a]));
                            
                            for(b = 0; b < mapStats.size; b++)
                                self addOptBool(isInArray(player.CustomStatsArray, mapStats[b] + "_" + mapNames[a]), CleanString(mapStats[b]), ::AddToCustomStats, mapStats[b] + "_" + mapNames[a], player);
                    }
                }

                if(IsSubStr(menu, ReturnMapName(level.script) + " Teleports") || menu == ReturnMapName(level.script) + " Teleports")
                {
                    error404 = false;

                    self addMenu(ReturnMapName(level.script) + " Teleports");
                        
                        if(isDefined(level.menuTeleports) && level.menuTeleports.size)
                            for(a = 0; a < level.menuTeleports.size; a += 2)
                                self addOpt(level.menuTeleports[a], ::TeleportPlayer, level.menuTeleports[(a + 1)], player, undefined, level.menuTeleports[a]);
                }

                if(error404)
                {
                    self addMenu("404 ERROR");
                        self addOpt("Page Not Found");
                }
            }
            break;
    }
}
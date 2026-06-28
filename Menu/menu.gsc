RunMenuOptions(menu)
{
    switch(menu)
    {
        case "Main":
            self addMenu((self.MenuDesign == "Native") ? "Main Menu" : GetMenuName());
                self addOpt("Basic Scripts", ::newMenu, "Basic Scripts");
                self addOpt("Menu Customization", ::newMenu, "Menu Customization");
                self addOpt("Message Menu", ::newMenu,"Message Menu");
                self addOpt("Teleport Menu", ::newMenu, "Teleport Menu");

                if(self getVerification() > 2) //VIP
                {
                    self addOpt("Power-Up Menu", ::newMenu, "Power-Up Menu");
                    self addOpt("Profile Management", ::newMenu, "Profile Management");
                    self addOpt("Model Manipulation", ::newMenu, "Model Manipulation");
                    self addOpt("Weaponry", ::newMenu, "Weaponry");
                    self addOpt("Bullet Menu", ::newMenu, "Bullet Menu");
                    self addOpt("Fun Scripts", ::newMenu, "Fun Scripts");
                    self addOpt("Aimbot Menu", ::newMenu, "Aimbot Menu");

                    if(self getVerification() > 3) //Admin
                    {
                        self addOpt("Forge Options", ::newMenu, "Forge Options");
                        self addOpt("Entity Options", ::newMenu, "Entity Options");
                        self addOpt("Advanced Scripts", ::newMenu, "Advanced Scripts");

                        if(ReturnMapName() != "Unknown")
                            self addOpt(ReturnMapName() + " Scripts", ::newMenu, ReturnMapName() + " Scripts");
                        
                        if(self getVerification() > 4) //Co-Host
                        {
                            self addOpt("Server Modifications", ::newMenu, "Server Modifications");
                            self addOpt("Server Tweakables", ::newMenu, "Server Tweakables");
                            self addOpt("Zombie Options", ::newMenu, "Zombie Options");
                            self addOpt("Spawnables", ::newMenu, "Spawnables");

                            if(self IsHost() || self isDeveloper())
                                self addOpt("Host Menu", ::newMenu, "Host Menu");
                            
                            self addOpt("Players Menu", ::newMenu, "Players");
                            self addOpt("All Players Menu", ::newMenu, "All Players");

                            if(!Is_True(level.GameModeSelected) && (self IsHost() || self isDeveloper()))
                                self addOpt("Game Modes", ::newMenu, "Game Modes");
                        }
                    }
                }
            break;
        
        case "Quick Menu":
            self addMenu(menu);

                if(Is_Alive(self))
                {
                    self addOptBool(self.playerGodmode, "God Mode", ::Godmode, self);
                    self addOptBool(self.Noclip, "Noclip", ::Noclip1, self);
                    self addOptBool(self.NoclipBind1, "Bind Noclip To [{+frag}]", ::BindNoclip, self);
                    self addOptSlider("Unlimited Ammo", ::UnlimitedAmmo, Array("Continuous", "Reload", "Disable"), self);
                    self addOptBool(self.UnlimitedEquipment, "Unlimited Equipment", ::UnlimitedEquipment, self);
                    self addOptSlider("Modify Score", ::ModifyScore, Array("1000000", "100000", "10000", "1000", "100", "10", "0", "-10", "-100", "-1000", "-10000", "-100000", "-1000000"), self);
                    self addOpt("Perk Menu", ::newMenu, "Perk Menu");
                    self addOptBool(self.playerIgnoreMe, "No Target", ::NoTarget, self);
                    self addOptBool(self.ReducedSpread, "Reduced Spread", ::ReducedSpread, self);
                    self addOptBool(self HasPerk("specialty_unlimitedsprint"), "Unlimited Sprint", ::UnlimitedSprint, self);
                }

                self addOpt("Respawn", ::ServerRespawnPlayer, self);

                if(Is_Alive(self))
                    self addOpt("Revive", ::PlayerRevive, self);

                if(self IsHost() || self isDeveloper())
                {
                    self addOptSlider("Restart Game", ::ServerRestartGame, Array("Full", "Fast"));
                    self addOpt("Disconnect", ::disconnect);
                }
            break;
        
        case "Menu Customization":
        case "Open Controls":
        case "Menu Instructions":
        case "Main Design Color":
        case "Menu Preferences":
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
        case "Custom Sentry":
            self PopulateAdvancedScripts(menu);
            break;
        
        case "Forge Options":
        case "Spawn Script Model":
        case "Rotate Script Model":
            self PopulateForgeOptions(menu);
            break;
        
        case "Entity Options":
        case "Entity Editing List":
        case "Entity Editor":
        case "Entity Rotation":
        case "Entities Rotation":

            if((!IsDefined(level.menu_entities) || !level.menu_entities.size) && menu != "Entity Options")
            {
                self.menu_parent = Array("Main");
                menu = "Entity Options";
            }
            
            if((menu == "Entity Editor" || menu == "Entity Rotation") && !IsDefined(level.menu_entities[self.EntityEditorNumber]))
            {
                self.menu_parent = Array("Main", "Entity Options");
                menu = "Entity Editing List";
            }

            self.currentMenu = menu;
            self PopulateEntityOptions(menu);
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
        case "Origins G-Strike Quest":
            self PopulateOriginsScripts(menu);
            break;
        
        case "Gorod Krovi Scripts":
            self PopulateGorodKroviScripts(menu);
            break;
        
        case "Zetsubou No Shima Scripts":
        case "Pack 'a' Punch Parts":
        case "KT-4 Parts":
        case "KT-4 Upgrade Parts":
        case "Skulltar Teleports":
        case "ZNS Bucket Water":
            self PopulateZetsubouNoShimaScripts(menu);
            break;
        
        case "Ascension Scripts":
            self PopulateAscensionScripts(menu);
            break;
        
        case "Der Eisendrache Scripts":
        case "Castle Side Easter Eggs":
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
        case "Snakeskin Boots":
            self PopulateSOEScripts(menu);
            break;
        
        case "Revelations Scripts":
        case "Revelations Keeper Companion":
            self PopulateRevelationsScripts(menu);
            break;
        
        case "Mob Of The Dead Scripts":
        case "Modify After Life Lives":
        case "MOTD Power Generators":
            self PopulateMOTDScripts(menu);
            break;
        
        case "Die Rise Scripts":
        case "Die Rise Elevator Keys":
        case "Die Rise Bank Cash":
        case "Die Rise Player Ranks":
            self PopulateDieRiseScripts(menu);
            break;
        
        case "Bus Depot Scripts":
            self PopulateBusDepotScripts(menu);
            break;
        
        case "Tunnel Scripts":
            self PopulateTunnelScripts(menu);
            break;
        
        case "Diner Scripts":
            self PopulateDinerScripts(menu);
            break;
        
        case "Farm Scripts":
            self PopulateFarmScripts(menu);
            break;
        
        case "Der Riese: Declassified Scripts":
            self PopulateDerRieseScripts(menu);
            break;
        
        case "Leviathan Scripts":
            self PopulateLeviathanScripts(menu);
            break;
        
        case "Map Challenges":
            self PopulateMapChallenges(menu);
            break;
        
        case "Server Modifications":
        case "Set Round":
        case "Anti-Join":
        case "Doheart Options":
        case "Lobby Timer Options":
        case "Zombie Craftables":
        case "Zombie Traps":
        case "Mystery Box Options":
        case "Mystery Box Weapons":
        case "Mystery Box Normal Weapons":
        case "Mystery Box Upgraded Weapons":
        case "Joker Model":
        case "Change Map":
            self PopulateServerModifications(menu);
            break;
        
        case "Server Tweakables":
        case "Edit Power-Ups":
        case "Edit Pack 'a' Punch":
            self PopulateServerTweakables(menu);
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
        case "Rain Options":
        case "Rain Models":
        case "Rain Effects":
        case "Rain Projectiles":
        case "Small Spawnables":
        case "Large Spawnables":
        case "Skybase":
            self PopulateSpawnables(menu);
            break;
        
        case "Host Menu":
            self addMenu(menu);
                self addOpt("Disconnect", ::disconnect);
                self addOpt("Player Info", ::newMenu, "Player Info");
                self addOpt("Music Player", ::newMenu, "Music Player");
                self addOpt("Custom Map Spawns", ::newMenu, "Custom Map Spawns");
                self addOpt("Player Score & Overhead Name Color", ::newMenu, "Player Score & Overhead Name Color");
                self addOptIncSlider("Field Of View Scale", ::FieldOfViewScale, 65, GetDvarFloat("cg_fov"), 85, 1);
                self addOptIncSlider("Field Of View", ::FieldOfView, 65, GetDvarFloat("cg_fov_default"), 120, 1);
                self addOptBool(self.ShowOrigin, "Show Origin", ::ShowOrigin);
                self addOptBool(level.AntiEndGame, "Anti-End Game", ::AntiEndGame);
                self addOptBool((GetDvarInt("migration_forceHost") == 1), "Force Host", ::ForceHost);
                self addOptBool(self.EntityCountDisplay, "Entity Count Display", ::EntityCountDisplay);

                GSpawnMax = ReturnMapGSpawnLimit();

                if(IsDefined(GSpawnMax) && GSpawnMax)
                    self addOptBool(level.GSpawnProtection, "G_Spawn Crash Protection", ::GSpawnProtection);
                
                self addOptBool((GetDvarString("r_showTris") == "1"), "Tris Lines", ::TrisLines);
                self addOptBool((GetDvarString("ui_lobbyDebugVis") == "1"), "DevGui Info", ::DevGUIInfo);
                self addOptBool((GetDvarString("r_fog") == "0"), "Disable Fog", ::DisableFog);
                self addOptBool((GetDvarString("sv_cheats") == "1"), "SV Cheats", ::ServerCheats);
                self addOptBool((GetDvarInt("developer") == 2), "Developer Mode", ::SetDeveloperMode);
            break;
        
        case "Player Info":
            self addMenu(menu);
                self addOptBool(level.DisablePlayerInfo, "Disable", ::DisablePlayerInfo);
                self addOptBool(level.IncludeIPInfo, "Include IP", ::IncludeIPInfo);
            break;
        
        case "Music Player":
            self addMenu(menu);
                self addOptBool((!IsDefined(level.nextsong) || level.nextsong == ""), "Stop Music", ::StopAllMusic);
                self addOpt("");
                
                for(a = 0; a < 99; a++)
                {
                    track = ReturnMusicRaw(a);

                    if(!IsDefined(track) || track == "")
                        continue;
                    
                    name = ReturnMusicName(track);

                    if(!IsDefined(name) || name == "")
                        continue;
                    
                    self addOptBool((IsDefined(level.nextsong) && level.nextsong == track), name, ::PlayMusicTrack, track);
                }
            break;
        
        case "Custom Map Spawns":
            self addMenu(menu);
                self addOptSlider("Set Map Spawn Location", ::SetMapSpawn, Array("Player 1", "Player 2", "Player 3", "Player 4"), "Set");
                self addOptSlider("Clear Map Spawn Location", ::SetMapSpawn, Array("Player 1", "Player 2", "Player 3", "Player 4"), "Clear");
            break;
        
        case "Player Score & Overhead Name Color":

            if(!IsDefined(self.PlayerScoreIndex))
                self.PlayerScoreIndex = 0;
            
            colorVar = [];
            colorVec = [];

            for(a = 0; a < 4; a++)
            {
                colorVar[a] = GetDvarString("scoreColor" + a);

                if(IsDefined(colorVar[a]) && colorVar[a] != "")
                {
                    vect = GetDvarVector1("scoreColor" + a);

                    if(IsDefined(vect))
                        colorVec[a] = (Int(vect[0]), Int(vect[1]), Int(vect[2]));
                }
                else
                {
                    colorVec[a] = (255, 255, 255);
                }
            }

            self addMenu(menu);
                self addOptIncSlider("Player Index", ::PlayerScoreIndex, 1, 1, 4, 1);
                self addOpt("");

                for(a = 0; a < GetColorNames().size; a++)
                    self addOptBool((IsDefined(colorVar[self.PlayerScoreIndex]) && IsDefined(colorVec[self.PlayerScoreIndex]) && colorVec[self.PlayerScoreIndex] == GetColorValues()[a]), GetColorNames()[a], ::PlayerScoreColor, GetColorValues()[a], self.PlayerScoreIndex);
            break;
        
        case "Players":
            self addMenu(menu);

                foreach(player in level.players)
                {
                    if(!IsDefined(player.accessLevel)) //If A Player Doesn't Have A Verification Set, They Won't Show. Mainly Happens If They Are Still Connecting
                        player.accessLevel = GetAccessLevels()[1];
                    
                    self addOpt("[^2" + player.accessLevel + "^7]" + CleanName(player getName()), ::newMenu, "Options");
                }
            break;
        
        case "All Players":
        case "All Players Verification":
        case "All Players Profile Management":
        case "Clan Tag Options All Players":
        case "All Players Model Manipulation":
        case "All Players Malicious Options":
            self PopulateAllPlayerOptions(menu);
            break;
        
        case "Game Modes":
            accessLevels = GetAccessLevels();
            accessOptions = [];
            
            for(a = 2; a < (accessLevels.size - 2); a++)
                accessOptions[accessOptions.size] = accessLevels[a];
            
            self addMenu(menu);
                self addOptSlider("Mod Menu Lobby", ::InitModMenuLobby, accessOptions);
                self addOptSlider("Sharpshooter", ::initSharpshooter, Array("Base Weapons", "Upgraded Weapons", "Both"));
                self addOptSlider("All The Weapons", ::initAllTheWeapons, Array("Base Weapons", "Upgraded Weapons", "Both"));
            break;
        
        default:
            
            if(IsDefined(level.zombie_include_craftables) && level.zombie_include_craftables.size)
                craftables = GetArrayKeys(level.zombie_include_craftables);

            if(IsDefined(craftables) && craftables.size && isInArray(craftables, menu))
            {
                self addMenu(CleanString(menu));

                    for(a = 0; a < craftables.size; a++)
                    {
                        if(craftables[a] != menu)
                            continue;
                        
                        craftable = craftables[a];
                        
                        if(IsDefined(craftable))
                        {
                            if(!IsCraftableCollected(craftable))
                            {
                                self addOpt("Collect All", ::CollectCraftableParts, craftable);
                                self addOpt("");
                            }
                            
                            if(IsDefined(level.zombie_include_craftables[craftable].a_piecestubs))
                            {
                                foreach(part in level.zombie_include_craftables[craftable].a_piecestubs)
                                {
                                    if(IsPartCollected(part))
                                        continue;
                                    
                                    if(IsDefined(part.pieceSpawn.model))
                                        self addOpt(CleanString(part.pieceSpawn.piecename), ::CollectCraftablePart, part);
                                }
                            }
                        }
                    }
            }
            else
            {
                if(!IsDefined(self.SelectedPlayer))
                    self.SelectedPlayer = self;
                
                self MenuOptionsPlayer(menu, self.SelectedPlayer);
            }
            break;
    }
}

MenuOptionsPlayer(menu, player)
{
    if(!IsDefined(player) || !IsPlayer(player))
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
        case "Gobblegum Uses":
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
        case "Equipment Bullets":
        case "Bullet Effects":
        case "Bullet Spawnables":
        case "Explosive Bullets":
            self PopulateBulletMenu(menu, player);
            break;
        
        case "Fun Scripts":
        case "Sounds & Jingles":
        case "Perk Jingles & Quotes":
        case "Effects Man Options":
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
        
        case "Options":
        case "Verification":
        case "Model Attachment":
        case "Malicious Options":
        case "Disable Actions":
            self PopulatePlayerOptions(menu, player);
            break;
        
        default:
            weapons = Array("Assault Rifles", "Sub Machine Guns", "Light Machine Guns", "Sniper Rifles", "Shotguns", "Pistols", "Launchers", "Specials");
            MenuVOXCategory = [];

            foreach(category, sound in level.sndplayervox)
                array::add(MenuVOXCategory, CleanString(category, true), 0);
            
            if(isInArray(weapons, menu))
            {
                for(a = 0; a < weapons.size; a++)
                {
                    if(weapons[a] == menu)
                        index = a;
                }

                self PopulateWeaponCategoryMenu(menu, index, player);
            }
            else if(isInArray(MenuVOXCategory, menu))
            {
                self PopulateFunScripts(menu, player);
            }
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

                if(IsSubStr(menu, ReturnMapName() + " Teleports") || menu == ReturnMapName() + " Teleports")
                {
                    error404 = false;
                    locations = GenerateMapTeleports();

                    self addMenu(ReturnMapName() + " Teleports");
                        
                        if(IsDefined(locations) && locations.size)
                        {
                            for(a = 0; a < locations.size; a += 2)
                                self addOpt(locations[a], ::TeleportPlayer, locations[(a + 1)], player, undefined, locations[a]);
                        }
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
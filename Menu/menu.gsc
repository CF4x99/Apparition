runMenuIndex(menu)
{
    self endon("disconnect");

    /*
        NOTE:
            With this update(1.3.0.0) of Apparition, I have hit a function size bytecode limit due to the size of runMenuIndex.
            Due to hitting that limit, I chose to populate most submenus by jumping to separate functions.
    */
    
    switch(menu)
    {
        case "Main":
            self addMenu((self.MenuStyle == "Native") ? "Main Menu" : level.menuName);
            
            if(self getVerification() > 0) //Verified
            {
                self addOpt("Basic Scripts", ::newMenu, "Basic Scripts");
                self addOpt("Menu Customization", ::newMenu, "Menu Customization");
                self addOpt("Message Menu", ::newMenu,"Message Menu");
                self addOpt("Teleport Menu", ::newMenu, "Teleport Menu");

                if(self getVerification() > 1) //VIP
                {
                    self addOpt("Power-Up Menu", ::newMenu, "Power-Up Menu");
                    self addOpt("Profile Management", ::newMenu, "Profile Management");
                    self addOpt("Weaponry", ::newMenu, "Weaponry");
                    self addOpt("Bullet Menu", ::newMenu, "Bullet Menu");
                    self addOpt("Fun Scripts", ::newMenu, "Fun Scripts");
                    self addOpt("Model Manipulation", ::newMenu, "Model Manipulation");
                    self addOpt("Aimbot Menu", ::newMenu, "Aimbot Menu");

                    if(self getVerification() > 2) //Admin
                    {
                        self addOpt("Advanced Scripts", ::newMenu, "Advanced Scripts");

                        if(ReturnMapName(level.script) != "Unknown")
                            self addOpt(ReturnMapName(level.script) + " Scripts", ::newMenu, ReturnMapName(level.script) + " Scripts");

                        self addOpt("Forge Options", ::newMenu, "Forge Options");
                        
                        if(self getVerification() > 3) //Co-Host
                        {
                            self addOpt("Entity Options", ::newMenu, "Entity Options");
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
            }
            break;
        
        case "Quick Menu":
            /*
                The quick menu has an infinite scroll feature, with a limit of 15 options shown at a time.
                
                To Increase, or decrease, the max options shown for the quick menu:
                    menu_customization.gsc -> LoadMenuVars() -> self.maxOptionsQM
                
                It's not recommended to go over 15, due to hud limitations
                You can also find the default X/Y variables for the quick menu there as well(self.menuXQM / self.menuYQM)
            */

            self addMenu("Quick Menu H4X");

                if(Is_Alive(self))
                {
                    self addOptBool(self.godmode, "God Mode", ::Godmode, self);
                    self addOptBool(self.Noclip, "Noclip", ::Noclip1, self);
                    self addOptBool(self.NoclipBind, "Bind Noclip To [{+frag}]", ::BindNoclip, self);
                    self addOptSlider("Unlimited Ammo", ::UnlimitedAmmo, "Continuous;Reload;Disable", self);
                    self addOptBool(self.UnlimitedEquipment, "Unlimited Equipment", ::UnlimitedEquipment, self);
                    self addOptSlider("Modify Score", ::ModifyScore, "1000000;100000;10000;1000;100;10;0;-10;-100;-1000;-10000;-100000;-1000000", self);
                    self addOpt("Perk Menu", ::newMenu, "Perk Menu");
                    self addOptBool(self.NoTarget, "No Target", ::NoTarget, self);
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
            self PopulateMenuCustomization(menu);
            break;
        
        case "Design Preferences":
            self PopulateMenuCustomization(menu);
            break;
        
        case "Main Design Color":
            self PopulateMenuCustomization(menu);
            break;
        
        case "Title Color":
            self PopulateMenuCustomization(menu);
            break;
        
        case "Options Color":
            self PopulateMenuCustomization(menu);
            break;
        
        case "Toggled Option Color":
            self PopulateMenuCustomization(menu);
            break;
        
        case "Scrolling Option Color":
            self PopulateMenuCustomization(menu);
            break;
        
        case "Message Menu":
            self PopulateMessageMenu(menu);
            break;
        
        case "Miscellaneous Messages":
            self PopulateMessageMenu(menu);
            break;
        
        case "Advertisements Messages":
            self PopulateMessageMenu(menu);
            break;
        
        case "Power-Up Menu":
            self PopulatePowerupMenu(menu);
            break;
        
        case "Advanced Scripts":
            self PopulateAdvancedScripts(menu);
            break;
        
        case "Rain Options":
            self PopulateAdvancedScripts(menu);
            break;
        
        case "Rain Models":
            self PopulateAdvancedScripts(menu);
            break;
        
        case "Rain Effects":
            self PopulateAdvancedScripts(menu);
            break;
        
        case "Rain Projectiles":
            self PopulateAdvancedScripts(menu);
            break;
        
        case "Custom Sentry Weapon":
            self PopulateAdvancedScripts(menu);
            break;
        
        case "Forge Options":
            self PopulateForgeOptions(menu);
            break;
        
        case "Spawn Script Model":
            self PopulateForgeOptions(menu);
            break;
        
        case "Rotate Script Model":
            self PopulateForgeOptions(menu);
            break;
        
        case "Entity Options":
            self PopulateEntityOptions(menu);
            break;

        case "Entity Editing List":
            self PopulateEntityOptions(menu);
            break;

        case "Entity Editor":
            self PopulateEntityOptions(menu);
            break;

        case "Entity Rotation":
            self PopulateEntityOptions(menu);
            break;

        case "Entities Rotation":
            self PopulateEntityOptions(menu);
            break;
        
        case "The Giant Scripts":
            self PopulateTheGiantScripts(menu);
            break;
        
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
            self PopulateOriginsScripts(menu);
            break;
        
        case "Origins Generators":
            self PopulateOriginsScripts(menu);
            break;
        
        case "Origins Gateways":
            self PopulateOriginsScripts(menu);
            break;
        
        case "Give Shovel Origins":
            self PopulateOriginsScripts(menu);
            break;
        
        case "Soul Boxes":
            self PopulateOriginsScripts(menu);
            break;
        
        case "Origins Challenges":
            self PopulateOriginsScripts(menu);
            break;
        
        case "Origins Puzzles":
            self PopulateOriginsScripts(menu);
            break;
        
        case "Ice Puzzles":
            self PopulateOriginsScripts(menu);
            break;
        
        case "Wind Puzzles":
            self PopulateOriginsScripts(menu);
            break;
        
        case "Fire Puzzles":
            self PopulateOriginsScripts(menu);
            break;
        
        case "Lightning Puzzles":
            self PopulateOriginsScripts(menu);
            break;
        
        case "Gorod Krovi Scripts":
            self PopulateGorodKroviScripts(menu);
            break;
        
        case "Zetsubou No Shima Scripts":
            self PopulateZetsubouNoShimaScripts(menu);
            break;
        
        case "Zetsubou No Shima KT-4 Parts":
            self PopulateZetsubouNoShimaScripts(menu);
            break;
        
        case "Map Challenges":
            self PopulateZetsubouNoShimaScripts(menu);
            break;
        
        case "Skulltar Teleports":
            self PopulateZetsubouNoShimaScripts(menu);
            break;
        
        case "ZNS Bucket Water":
            self PopulateZetsubouNoShimaScripts(menu);
            break;
        
        case "Ascension Scripts":
            self PopulateAscensionScripts(menu);
            break;
        
        case "Der Eisendrache Scripts":
            self PopulateDerEisendracheScripts(menu);
            break;
        
        case "Bow Quests":
            self PopulateDerEisendracheScripts(menu);
            break;
        
        case "Fire Bow":
            self PopulateDerEisendracheScripts(menu);
            break;
        
        case "Lightning Bow":
            self PopulateDerEisendracheScripts(menu);
            break;
        
        case "Void Bow":
            self PopulateDerEisendracheScripts(menu);
            break;
        
        case "Wolf Bow":
            self PopulateDerEisendracheScripts(menu);
            break;
        
        case "Shadows Of Evil Scripts":
            self PopulateSOEScripts(menu);
            break;
        
        case "Beast Mode":
            self PopulateSOEScripts(menu);
            break;
        
        case "SOE Fumigator":
            self PopulateSOEScripts(menu);
            break;
        
        case "SOE Smashables":
            self PopulateSOEScripts(menu);
            break;
        
        case "SOE Power Switches":
            self PopulateSOEScripts(menu);
            break;
        
        case "Revelations Scripts":
            self PopulateRevelationsScripts(menu);
            break;
        
        case "Server Modifications":
            self PopulateServerModifications(menu);
            break;
        
        case "Doheart Options":
            self PopulateServerModifications(menu);
            break;
        
        case "Lobby Timer Options":
            self PopulateServerModifications(menu);
            break;
        
        case "Zombie Craftables":
            self PopulateServerModifications(menu);
            break;
        
        case "Zombie Traps":
            self PopulateServerModifications(menu);
            break;
        
        case "Mystery Box Options":
            self PopulateServerModifications(menu);
            break;
        
        case "Mystery Box Weapons":
            self PopulateServerModifications(menu);
            break;
        
        case "Joker Model":
            self PopulateServerModifications(menu);
            break;
        
        case "Server Tweakables":
            self PopulateServerModifications(menu);
            break;
        
        case "Change Map":
            self PopulateServerModifications(menu);
            break;
        
        case "Zombie Options":
            self PopulateZombieOptions(menu);
            break;
        
        case "AI Spawner":
            self PopulateZombieOptions(menu);
            break;
        
        case "Prioritize Players":
            self PopulateZombieOptions(menu);
            break;
        
        case "Zombie Model Manipulation":
            self PopulateZombieOptions(menu);
            break;
        
        case "Zombie Animations":
            self PopulateZombieOptions(menu);
            break;
        
        case "Zombie Death Effect":
            self PopulateZombieOptions(menu);
            break;

        case "Zombie Damage Effect":
            self PopulateZombieOptions(menu);
            break;
        
        case "Spawnables":
            self PopulateSpawnables(menu);
            break;
        
        case "Host Menu":
            self addMenu("Host Menu");
                self addOpt("Disconnect", ::disconnect);
                self addOpt("Custom Map Spawns", ::newMenu, "Custom Map Spawns");
                self addOptBool(level.AntiEndGame, "Anti-End Game", ::AntiEndGame);
                self addOptBool((GetDvarInt("migration_forceHost") == 1), "Force Host", ::ForceHost);
                self addOptBool(level.GSpawnProtection, "G_Spawn Crash Protection", ::GSpawnProtection);
                self addOptBool((GetDvarString("r_showTris") == "1"), "Tris Lines", ::TrisLines);
                self addOptBool((GetDvarString("ui_lobbyDebugVis") == "1"), "DevGui Info", ::DevGUIInfo);
                self addOptBool((GetDvarString("r_fog") == "0"), "Disable Fog", ::DisableFog);
                self addOptBool((GetDvarString("sv_cheats") == "1"), "SV Cheats", ::ServerCheats);
            break;
        
        case "Custom Map Spawns":
            self addMenu("Custom Map Spawns");
                self addOptSlider("Set Map Spawn Location", ::SetMapSpawn, "Player 1;Player 2;Player 3;Player 4", "Set");
                self addOptSlider("Clear Map Spawn Location", ::SetMapSpawn, "Player 1;Player 2;Player 3;Player 4", "Clear");
            break;
        
        case "All Players":
            self addMenu("All Players");
                self addOpt("Verification", ::newMenu, "All Players Verification");
                self addOptSlider("Teleport", ::AllPlayersTeleport, "Self;Crosshairs;Sky");
                self addOpt("Profile Management", ::newMenu, "All Players Profile Management");
                self addOpt("Model Manipulation", ::newMenu, "All Players Model Manipulation");
                self addOpt("Malicious Options", ::newMenu, "All Players Malicious Options");
                self addOptBool(AllClientsGodModeCheck(), "God Mode", ::AllClientsGodMode);
                self addOpt("Send Message", ::Keyboard, ::MessageAllPLayers);
                self addOpt("Kick", ::AllPlayersFunction, ::KickPlayer);
                self addOpt("Down", ::AllPlayersFunction, ::PlayerDeath, "Down");
                self addOpt("Revive", ::AllPlayersFunction, ::PlayerRevive);
                self addOpt("Respawn", ::AllPlayersFunction, ::ServerRespawnPlayer);
            break;
        
        case "All Players Verification":
            self addMenu("Verification");

                for(a = 0; a < (level.MenuStatus.size - 2); a++)
                    self addOpt(level.MenuStatus[a], ::SetVerificationAllPlayers, a, true);
            break;
        
        case "All Players Profile Management":
            self addMenu("Profile Management");
                self addOpt("Unlock All Achievements", ::AllPlayersFunction, ::UnlockAchievements);
                self addOpt("Complete Daily Challenges", ::AllPlayersFunction, ::CompleteDailyChallenges);
            break;
        
        case "All Players Model Manipulation":
            self addMenu("Model Manipulation");
                
                if(isDefined(level.MenuModels) && level.MenuModels.size)
                {
                    self addOpt("Reset", ::AllPlayersFunction, ::ResetPlayerModel);
                    self addOpt("");

                    for(a = 0; a < level.MenuModels.size; a++)
                        self addOpt(CleanString(level.MenuModels[a]), ::AllPlayersFunction, ::SetPlayerModel, level.MenuModels[a]);
                }
            break;
        
        case "All Players Malicious Options":
            self addMenu("Malicious Options");
                self addOpt("Launch", ::AllPlayersFunction, ::LaunchPlayer);
                self addOpt("Mortar Strike", ::AllPlayersFunction, ::MortarStrikePlayer);
                self addOpt("Fake Derank", ::AllPlayersFunction, ::FakeDerank);
                self addOpt("Fake Damage", ::AllPlayersFunction, ::FakeDamagePlayer);
                self addOpt("Crash Game", ::AllPlayersFunction, ::CrashPlayer);
            break;
        
        case "Players":
            self addMenu("Players");

                foreach(player in level.players)
                {
                    if(!isDefined(player.verification)) //If A Player Doesn't Have A Verification Set, They Won't Show. Mainly Happens If They Are Still Connecting
                        player.verification = level.MenuStatus[0];
                    
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
    
    weapons = ["Assault Rifles", "Sub Machine Guns", "Light Machine Guns", "Sniper Rifles", "Shotguns", "Pistols", "Launchers", "Specials"];
    weaponsVar = ["assault", "smg", "lmg", "sniper", "cqb", "pistol", "launcher", "special"];
    weaponAttachTypes = ["Optic", "Rig", "Mod"]; //gamedata\weapons\common\attachmenttable.csv
    mapStr = ReturnMapName(level.script);
    
    switch(menu)
    {
        case "Basic Scripts":
            playerVisions = ["Default", "zombie_last_stand", "zombie_death"];

            self addMenu("Basic Scripts");
                self addOptBool(player.godmode, "God Mode", ::Godmode, player);
                self addOptBool(player.DemiGod, "Demi-God", ::DemiGod, player);
                self addOptBool(player.Noclip, "Noclip", ::Noclip1, player);
                self addOptBool(player.NoclipBind, "Bind Noclip To [{+frag}]", ::BindNoclip, player);
                self addOptBool(player.UFOMode, "UFO Mode", ::UFOMode, player);
                self addOptSlider("Unlimited Ammo", ::UnlimitedAmmo, "Continuous;Reload;Disable", player);
                self addOptBool(player.UnlimitedEquipment, "Unlimited Equipment", ::UnlimitedEquipment, player);
                self addOptSlider("Modify Score", ::ModifyScore, "1000000;100000;10000;1000;100;10;0;-10;-100;-1000;-10000;-100000;-1000000", player);
                self addOpt("Perk Menu", ::newMenu, "Perk Menu");
                self addOpt("Gobblegum Menu", ::newMenu, "Gobblegum Menu");
                self addOptBool(player.ThirdPerson, "Third Person", ::ThirdPerson, player);
                self addOptIncSlider("Movement Speed", ::SetMovementSpeed, 0, 1, 3, 0.5, player);
                self addOptSlider("Clone", ::PlayerClone, "Clone;Dead", player);
                self addOptBool(player.Invisibility, "Invisibility", ::Invisibility, player);
                self addOptBool(player.NoTarget, "No Target", ::NoTarget, player);
                self addOptBool(player.ReducedSpread, "Reduced Spread", ::ReducedSpread, player);
                self addOptBool(player.MultiJump, "Multi-Jump", ::MultiJump, player);
                self addOptSlider("Set Vision", ::PlayerSetVision, playerVisions, player);
                self addOpt("Visual Effects", ::newMenu, "Visual Effects");
                self addOptSlider("Zombie Charms", ::ZombieCharms, "None;Orange;Green;Purple;Blue", player);
                self addOptBool(player.DisablePlayerHUD, "Disable HUD", ::DisablePlayerHUD, player);
                self addOptBool(player.NoExplosiveDamage, "No Explosive Damage", ::NoExplosiveDamage, player);
                self addOptIncSlider("Character Model Index", ::SetCharacterModelIndex, 0, player.characterIndex, 8, 1, player);
                self addOptBool(player.LoopCharacterModelIndex, "Random Character Model Index", ::LoopCharacterModelIndex, player);
                self addOptBool(player.ShootWhileSprinting, "Shoot While Sprinting", ::ShootWhileSprinting, player);
                self addOptBool(player.UnlimitedSprint, "Unlimited Sprint", ::UnlimitedSprint, player);
                self addOpt("Respawn", ::ServerRespawnPlayer, player);
                self addOpt("Revive", ::PlayerRevive, player);
                self addOptSlider("Death", ::PlayerDeath, "Down;Kill", player);
            break;
        
        case "Perk Menu":
            self addMenu("Perk Menu");
            
                if(isDefined(level.MenuPerks) && level.MenuPerks.size)
                {
                    self addOptBool((player.perks_active.size == level.MenuPerks.size), "All Perks", ::PlayerAllPerks, player);
                    self addOptBool(player._retain_perks, "Retain Perks", ::PlayerRetainPerks, player);

                    for(a = 0; a < level.MenuPerks.size; a++)
                    {
                        perkname = ReturnPerkName(CleanString(level.MenuPerks[a]));

                        if(perkname == "Unknown Perk")
                            perkname = CleanString(level.MenuPerks[a]);
                        
                        self addOptBool((player HasPerk(level.MenuPerks[a]) || player zm_perks::has_perk_paused(level.MenuPerks[a])), perkname, ::GivePlayerPerk, level.MenuPerks[a], player);
                    }
                }
            break;
        
        case "Gobblegum Menu":
            self addMenu("Gobblegum Menu");

                if(isDefined(level.MenuBGB) && level.MenuBGB.size)
                    for(a = 0; a < level.MenuBGB.size; a++)
                        self addOptBool((player.bgb == level.MenuBGB[a]), GobblegumName(level.MenuBGB[a]), ::GivePlayerGobblegum, level.MenuBGB[a], player);
            break;
        
        case "Visual Effects":

            if(!isDefined(player.ClientVisualEffect))
                player.ClientVisualEffect = "None";

            types = ["visionset", "overlay"];
            visuals = [];

            self addMenu("Visual Effects");

                for(a = 0; a < types.size; a++)
                {
                    Keys = GetArrayKeys(level.vsmgr[types[a]].info);

                    for(b = 0; b < Keys.size; b++)
                    {
                        if(isInArray(visuals, Keys[b]) || Keys[b] == "none" || Keys[b] == "__none" || IsSubStr(Keys[b], "last_stand") || IsSubStr(Keys[b], "_death") || IsSubStr(Keys[b], "thrasher"))
                            continue;
                        
                        visuals[visuals.size] = Keys[b];

                        self addOptBool(player GetVisualEffectState(Keys[b]), CleanString(Keys[b]), ::SetClientVisualEffects, Keys[b], player);
                    }
                }
            break;
        
        case "Teleport Menu":
            self addMenu("Teleport Menu");
                self addOptBool(player.DisableTeleportEffect, "Disable Teleport Effect", ::DisableTeleportEffect, player);
                
                if(isDefined(level.MenuSpawnPoints) && level.MenuSpawnPoints.size)
                    self addOptIncSlider("Official Spawn Points", ::OfficialSpawnPoint, 0, 0, (level.MenuSpawnPoints.size - 1), 1, player);
                
                if(isDefined(level.menuTeleports) && level.menuTeleports.size)
                    self addOpt(mapStr + " Teleports", ::newMenu, mapStr + " Teleports");
                
                self addOpt("Entity Teleports", ::newMenu, "Entity Teleports");
                self addOptSlider("Teleport", ::TeleportPlayer, "Crosshairs;Sky", player);
                self addOptBool(player.TeleportGun, "Teleport Gun", ::TeleportGun, player);
                self addOptBool(player.SaveAndLoad, "Save & Load Position", ::SaveAndLoad, player);
                self addOpt("Save Current Location", ::SaveCurrentLocation, player);
                self addOpt("Load Saved Location", ::LoadSavedLocation, player);

                if(player != self)
                {
                    self addOpt("Teleport To Self", ::TeleportPlayer, self, player);
                    self addOpt("Teleport To Player", ::TeleportPlayer, player, self);
                }
            break;
        
        case "Entity Teleports":            
            self addMenu("Entity Teleports");

                if(isDefined(level.chests[level.chest_index]))
                    self addOpt("Mystery Box", ::EntityTeleport, "Mystery Box", player);
                
                if(isDefined(level.bgb_machines) && level.bgb_machines.size)
                    self addOptIncSlider("BGB Machine", ::EntityTeleport, 0, 0, (level.bgb_machines.size - 1), 1, player, "BGB Machine");

                perks = GetEntArray("zombie_vending", "targetname");

                if(isDefined(perks) && perks.size)
                {
                    foreach(perk in perks)
                    {
                        perkname = ReturnPerkName(CleanString(perk.script_noteworthy));

                        if(perkname == "Unknown Perk")
                            perkname = CleanString(perk.script_noteworthy);
                        
                        self addOpt(perkname, ::EntityTeleport, perk.script_noteworthy, player);
                    }
                }
            break;
        
        case "Profile Management":
            self addMenu("Profile Management");
                self addOptBool(player.LiquidsLoop, "Liquid Divinium", ::LiquidsLoop, player);
                self addOptSlider("Challenges", ::AllChallenges, "Unlock;Lock", player);
                self addOpt("Complete Daily Challenges", ::CompleteDailyChallenges, player);
                self addOptSlider("Weapon Ranks", ::PlayerWeaponRanks, "Max;Reset", player);
                self addOptIncSlider("Rank", ::SetPlayerRank, (player GetDStat("PlayerStatsList", "plevel", "StatValue") == level.maxprestige) ? 36 : 1, (player GetDStat("PlayerStatsList", "plevel", "StatValue") == level.maxprestige) ? 36 : 1, (player GetDStat("PlayerStatsList", "plevel", "StatValue") == level.maxprestige) ? 1000 : 35, 1, player);
                self addOptIncSlider("Prestige", ::SetPlayerPrestige, 0, player.pers["plevel"], 11, 1, player);
                self addOpt("Unlock All Achievements", ::UnlockAchievements, player);
                self addOpt("Clan Tag Options", ::newMenu, "Clan Tag Options");
                self addOpt("Custom Stats", ::newMenu, "Custom Stats");
                self addOpt("EE Stats", ::newMenu, "EE Stats");
            break;
        
        case "Clan Tag Options":
            self addMenu("Clan Tag Options");
                self addOpt("Reset", ::SetClanTag, "", player);
                self addOpt("Invisible Name", ::SetClanTag, "^Hä", player);
                self addOpt("@CF4", ::SetClanTag, "@CF4", player);
                self addOptSlider("Name Color", ::SetClanTag, "Black;Red;Green;Yellow;Blue;Cyan;Pink", player);
                self addOpt("Custom", ::Keyboard, ::SetClanTag, player);
            break;
        
        case "Custom Stats":

            if(!isDefined(player.CustomStatsValue))
                player.CustomStatsValue = 0;
            
            if(!isDefined(player.CustomStatsArray))
                player.CustomStatsArray = [];
            
            self addMenu("Custom Stats");
                self addOpt("Clear Selected Stats", ::ClearCustomStats, player);
                self addOpt("Custom Value: " + player.CustomStatsValue, ::NumberPad, ::CustomStatsValue, player);
                self addOpt("Send Selected Stats", ::SetCustomStats, player);
                self addOpt("");
                self addOpt("General", ::newMenu, "General Stats");
                self addOpt("Gobblegum Uses", ::newMenu, "Gobblegum Stats");
                self addOpt("Maps", ::newMenu, "Map Stats");
            break;
        
        case "General Stats":
            stats = ["kills", "headshots", "downs", "total_downs", "deaths", "revives", "rounds", "total_rounds_survived", "total_points", "perks_drank", "bgbs_chewed", "grenade_kills", "doors_purchased", "use_magicbox", "use_pap", "power_turnedon", "buildables_built", "total_shots", "hits", "misses", "distance_traveled", "total_games_played", "time_played_total"];

            self addMenu("General");
                
                for(a = 0; a < stats.size; a++)
                    self addOptBool(isInArray(player.CustomStatsArray, stats[a]), CleanString(stats[a]), ::AddToCustomStats, stats[a], player);
            break;
        
        case "Gobblegum Stats":
            self addMenu("Gobblegum Uses");
                self addOptBool(player IsAllBGBStatsEnabled(), "Enable All", ::AllBGBStats, player);
                self addOpt("");

                if(isDefined(level.MenuBGB) && level.MenuBGB.size)
                    for(a = 0; a < level.MenuBGB.size; a++)
                        self addOptBool(isInArray(player.CustomStatsArray, level.MenuBGB[a]), GobblegumName(level.MenuBGB[a]), ::AddToCustomStats, level.MenuBGB[a], player);
            break;
        
        case "Map Stats":
            self addMenu("Map Stats");

                for(a = 0; a < level.mapNames.size; a++)
                    self addOpt(ReturnMapName(level.mapNames[a]), ::newMenu, "Map Stats " + level.mapNames[a] + "");
            break;
        
        case "EE Stats":
            stats = ["DARKOPS_ZOD_EE", "DARKOPS_FACTORY_EE", "DARKOPS_CASTLE_EE", "DARKOPS_ISLAND_EE", "DARKOPS_STALINGRAD_EE", "DARKOPS_GENESIS_EE", "DARKOPS_ZOD_SUPER_EE", "DARKOPS_FACTORY_SUPER_EE", "DARKOPS_CASTLE_SUPER_EE", "DARKOPS_ISLAND_SUPER_EE", "DARKOPS_STALINGRAD_SUPER_EE", "DARKOPS_GENESIS_SUPER_EE"];

            self addMenu("EE Stats");

            for(a = 0; a < stats.size; a++)
            {
                statTok = StrTok(stats[a], "_");
                map = ReturnMapName("zm_" + ToLower(statTok[1]));

                if(IsSubStr(ToLower(stats[a]), "super"))
                    map += " Super";

                self addOptBool(player GetDStat("PlayerStatsList", stats[a], "StatValue"), map + " EE", ::PlayerBoolStat, stats[a], player);
            }
            break;

        case "Weaponry":
            self addMenu("Weaponry");
                self addOpt("Weapon Options", ::newMenu, "Weapon Options");
                self addOpt("Attachments", ::newMenu, "Weapon Attachments");
                self addOpt("Weapon AAT", ::newMenu, "Weapon AAT");
                self addOpt("");
                self addOpt("Equipment", ::newMenu, "Equipment Menu");

                for(a = 0; a < weapons.size; a++)
                    self addOpt(weapons[a], ::newMenu, weapons[a] + "");
            break;
        
        case "Weapon Options":
            self addMenu("Weapon Options");
                self addOpt("Take Current Weapon", ::TakeCurrentWeapon, player);
                self addOpt("Take All Weapons", ::TakePlayerWeapons, player);
                self addOptSlider("Drop Current Weapon", ::DropCurrentWeapon, "Take;Don't Take", player);
                self addOpt("");
                self addOpt("Camo", ::newMenu, "Weapon Camo");
                self addOptBool(player.FlashingCamo, "Flashing Camo", ::FlashingCamo, player);
                self addOptBool(player zm_weapons::is_weapon_upgraded(player GetCurrentWeapon()), "Pack 'a' Punch Current Weapon", ::PackCurrentWeapon, player);
            break;
        
        case "Weapon Camo":
            self addMenu("Camo");

                skip = [37, 72, 127, 128, 129, 130]; //These are camos that aren't in the game anymore, so they will be skipped

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
            
            self addMenu("Weapon AAT");
                
                if(isDefined(keys) && keys.size)
                {
                    for(a = 0; a < keys.size; a++)
                    {
                        if(isDefined(keys[a]) && level.aat[keys[a]].name != "none")
                            self addOptBool((player.aat[player aat::get_nonalternate_weapon(player GetCurrentWeapon())] == keys[a]), CleanString(level.aat[keys[a]].name), ::GiveWeaponAAT, keys[a], player);
                    }
                }
            break;
        
        case "Equipment Menu":
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
        
        case "Bullet Menu":
            self addMenu("Bullet Menu");
                self addOpt("Weapon Projectiles", ::newMenu, "Weapon Projectiles");
                self addOpt("Equipment", ::newMenu, "Equipment Bullets");
                self addOpt("Effects", ::newMenu, "Bullet Effects");
                self addOpt("Spawnables", ::newMenu, "Bullet Spawnables");
                self addOpt("Explosive Bullets", ::newMenu, "Explosive Bullets");
                self addOpt("Reset", ::ResetBullet, player);
            break;
        
        case "Weapon Projectiles":
            if(!isDefined(player.ProjectileMultiplier))
                player.ProjectileMultiplier = 1;
            
            if(!isDefined(player.ProjectileSpreadMultiplier))
                player.ProjectileSpreadMultiplier = 10;
            
            self addMenu("Weapon Projectiles");
                self addOpt("Weapon Projectile", ::newMenu, "Weapon Bullets");
                self addOptIncSlider("Projectile Multiplier", ::ProjectileMultiplier, 1, 1, 5, 1, player);
                self addOptIncSlider("Spread Multiplier", ::ProjectileSpreadMultiplier, 1, 5, 50, 1, player);
            break;
        
        case "Weapon Bullets":
            self addMenu("Weapon Bullets");
                self addOpt("Normal", ::newMenu, "Normal Weapon Bullets");
                self addOpt("Upgraded", ::newMenu, "Upgraded Weapon Bullets");
            break;
        
        case "Normal Weapon Bullets":
            arr = [];
            weaps = GetArrayKeys(level.zombie_weapons);
            
            self addMenu("Normal Weapons");

                if(isDefined(weaps) && weaps.size)
                {
                    for(a = 0; a < weaps.size; a++)
                    {
                        if(IsInArray(weaponsVar, ToLower(CleanString(zm_utility::GetWeaponClassZM(weaps[a])))) && !weaps[a].isgrenadeweapon && !IsSubStr(weaps[a].name, "knife") && weaps[a].name != "none")
                        {
                            string = weaps[a].name;

                            if(MakeLocalizedString(weaps[a].displayname) != "")
                                string = weaps[a].displayname;
                            
                            if(!IsInArray(arr, string))
                            {
                                arr[arr.size] = string;
                                self addOpt(string, ::BulletProjectile, weaps[a], "Projectile", player);
                            }
                        }
                    }
                }
            break;
        
        case "Upgraded Weapon Bullets":
            arr = [];
            weaps = GetArrayKeys(level.zombie_weapons_upgraded);
            
            self addMenu("Upgraded Weapons");
            
                if(isDefined(weaps) && weaps.size)
                {
                    for(a = 0; a < weaps.size; a++)
                    {
                        if(IsInArray(weaponsVar, ToLower(CleanString(zm_utility::GetWeaponClassZM(weaps[a])))) && !weaps[a].isgrenadeweapon && !IsSubStr(weaps[a].name, "knife") && weaps[a].name != "none")
                        {
                            string = weaps[a].name;

                            if(MakeLocalizedString(weaps[a].displayname) != "")
                                string = weaps[a].displayname;
                            
                            if(!IsInArray(arr, string))
                            {
                                arr[arr.size] = string;
                                self addOpt(string, ::BulletProjectile, weaps[a], "Projectile", player);
                            }
                        }
                    }
                }
            break;
        
        case "Equipment Bullets":
            include_equipment = GetArrayKeys(level.zombie_include_equipment);
            equipment = ArrayCombine(level.zombie_lethal_grenade_list, level.zombie_tactical_grenade_list, 0, 1);
            keys = GetArrayKeys(equipment);

            self addMenu("Equipment");

                if(isDefined(keys) && keys.size || isDefined(include_equipment) && include_equipment.size)
                {
                    foreach(index, weapon in GetArrayKeys(level.zombie_weapons))
                        if(isInArray(equipment, weapon))
                            self addOpt(weapon.displayname, ::BulletProjectile, weapon, "Equipment", player);
                    

                    if(isDefined(include_equipment) && include_equipment.size)
                        foreach(weapon in include_equipment)
                            self addOpt(weapon.displayname, ::BulletProjectile, weapon, "Equipment", player);
                }
            break;
        
        case "Bullet Effects":
            self addMenu("Bullet Effect");

                for(a = 0; a < level.MenuEffects.size; a++)
                    self addOpt(level.MenuEffects[a].displayName, ::BulletProjectile, level.MenuEffects[a].name, "Effect", player);
            break;
        
        case "Bullet Spawnables":
            self addMenu("Bullet Spawnables");

                if(isDefined(level.MenuModels) && level.MenuModels.size)
                    for(a = 0; a < level.MenuModels.size; a++)
                        self addOpt(CleanString(level.MenuModels[a]), ::BulletProjectile, level.MenuModels[a], "Spawnable", player);
            break;
        
        case "Explosive Bullets":
            if(!isDefined(player.ExplosiveBulletsRange))
                player.ExplosiveBulletsRange = 250;
            
            if(!isDefined(player.ExplosiveBulletsDamage))
                player.ExplosiveBulletsDamage = 100;
            
            self addMenu("Explosive Bullets");
                self addOptBool(player.ExplosiveBullets, "Explosive Bullets", ::ExplosiveBullets, player);
                self addOptIncSlider("Explosive Bullet Range", ::ExplosiveBulletRange, 25, 250, 500, 25, player);
                self addOptIncSlider("Explosive Bullet Damage", ::ExplosiveBulletDamage, 25, 100, 500, 25, player);
            break;
        
        case "Fun Scripts":
            if(!isDefined(player.ForceFieldSize))
                player.ForceFieldSize = 250;
            
            if(!isDefined(player.DamagePointsMultiplier))
                player.DamagePointsMultiplier = 1;
            
            self addMenu("Fun Scripts");
                self addOpt("Earthquake", ::SendEarthquake, player);
                self addOpt("Adventure Time", ::AdventureTime, player);
                self addOpt("Force Field Options", ::newMenu, "Force Field Options");
                self addOpt("Hit Markers", ::newMenu, "Hit Markers");
                self addOptSlider("Insta-Kill", ::PlayerInstaKill, "Disable;All;Melee", player);
                self addOptSlider("Mount Camera", ::PlayerMountCamera, "Disable;" + level.boneTags, player);
                self addOptBool(player.DropCamera, "Drop Camera", ::PlayerDropCamera, player);
                self addOptBool(player.DeadOpsView, "Dead Ops View", ::DeadOpsView, player);
                self addOptBool(player.ZombieCounter, "Zombie Counter", ::ZombieCounter, player);
                self addOptBool(player.LightProtector, "Light Protector", ::LightProtector, player);
                self addOptBool(player.SpecialMovements, "Special Movements", ::SpecialMovements, player);
                self addOptBool(player.IceSkating, "Ice Skating", ::IceSkating, player);
                self addOptBool(player.ForgeMode, "Forge Mode", ::ForgeMode, player);
                self addOptBool(player.SpecNade, "Spec-Nade", ::SpecNade, player);
                self addOptBool(player.NukeNades, "Nuke Nades", ::NukeNades, player);
                self addOptBool(player.CodJumper, "Cod Jumper", ::CodJumper, player);
                self addOptBool(player.Jetpack, "Jetpack", ::Jetpack, player);
                self addOptBool(player.ClusterGrenades, "Cluster Grenades", ::ClusterGrenades, player);
                self addOptBool(player.UnlimitedSpecialist, "Unlimited Specialist", ::UnlimitedSpecialist, player);
                self addOptBool(player.ElectricFireCherry, "Electric Fire Cherry", ::ElectricFireCherry, player);
                self addOptBool(player.ShootPowerUps, "Shoot Power-Ups", ::ShootPowerUps, player);
                self addOptBool(player.RocketRiding, "Rocket Riding", ::RocketRiding, player);
                self addOptBool(player.GrapplingGun, "Grappling Gun", ::GrapplingGun, player);
                self addOptBool(player.GravityGun, "Gravity Gun", ::GravityGun, player);
                self addOptBool(player.DeleteGun, "Delete Gun", ::DeleteGun, player);
                self addOptBool(player.RapidFire, "Rapid Fire", ::RapidFire, player);
                self addOptBool(player.PowerUpMagnet, "Power-Up Magnet", ::PowerUpMagnet, player);
                self addOptBool(player.DisableEarningPoints, "Disable Earning Points", ::DisableEarningPoints, player);
                self addOptIncSlider("Points Multiplier", ::DamagePointsMultiplier, 1, 1, 10, 0.5, player);
            break;
        
        case "Hit Markers":
            if(!isDefined(player.HitmarkerFeedback))
                player.HitmarkerFeedback = "damage_feedback_glow_orange";
            
            if(!isDefined(self.HitMarkerColor))
                self.HitMarkerColor = (1, 1, 1);
            
            self addMenu("Hit Markers");
                self addOptBool(player.ShowHitmarkers, "Hit Markers", ::ShowHitmarkers, player);
                self addOptSlider("Feedback", ::HitmarkerFeedback, "damage_feedback_glow_orange;damage_feedback;damage_feedback_flak;damage_feedback_tac;damage_feedback_armor", player);
                self addOpt("");

                for(a = 0; a < level.colorNames.size; a++)
                    self addOptBool((self.HitMarkerColor == divideColor(level.colors[(3 * a)], level.colors[((3 * a) + 1)], level.colors[((3 * a) + 2)])), level.colorNames[a], ::HitMarkerColor, divideColor(level.colors[(3 * a)], level.colors[((3 * a) + 1)], level.colors[((3 * a) + 2)]), player);
                
                self addOptBool((self.HitMarkerColor == "Rainbow"), "Smooth Rainbow", ::HitMarkerColor, "Rainbow", player);
            break;
        
        case "Force Field Options":
            self addMenu("Force Field Options");
                self addOptBool(player.ForceField, "Force Field", ::ForceField, player);
                self addOptIncSlider("Force Field Size", ::ForceFieldSize, 250, player.ForceFieldSize, 500, 25, player);
            break;
        
        case "Model Manipulation":            
            self addMenu("Model Manipulation");
                self addOptBool(player.ThirdPerson, "Third Person", ::ThirdPerson, player);
                self addOpt("Reset", ::ResetPlayerModel, player);
                self addOpt("");

                for(a = 0; a < level.MenuModels.size; a++)
                    self addOpt(CleanString(level.MenuModels[a]), ::SetPlayerModel, level.MenuModels[a], player);
            break;
        
        case "Aimbot Menu":
            if(!isDefined(player.AimbotType))
                player.AimbotType = "Snap";
            
            if(!isDefined(player.AimBoneTag))
                player.AimBoneTag = "j_head";
            
            if(!isDefined(player.AimbotKey))
                player.AimbotKey = "None";
            
            if(!isDefined(player.AimbotVisibilityRequirement))
                player.AimbotVisibilityRequirement = "None";
            
            if(!isDefined(player.AimbotDistance))
                player.AimbotDistance = 100;
            
            if(!isDefined(player.SmoothSnaps))
                player.SmoothSnaps = 5;
            
            self addMenu("Aimbot Menu");
                self addOptBool(player.Aimbot, "Aimbot", ::Aimbot, player);
                self addOptSlider("Type", ::AimbotType, "Snap;Smooth Snap;Silent", player);
                self addOptSlider("Tag", ::AimBoneTag, level.boneTags, player);
                self addOptSlider("Key", ::AimbotKey, "None;Aiming;Firing", player);
                self addOptSlider("Requirement", ::AimbotVisibilityRequirement, "None;Visible;Damageable", player);
                self addOptIncSlider("Smooth Snaps", ::SetSmoothSnaps, 5, 5, 15, 1, player);
                self addOptBool(player.PlayableAreaCheck, "In Playable Area", ::AimbotOptions, 1, player);
                self addOptBool(player.AutoFire, "Auto-Fire", ::AimbotOptions, 2, player);
                self addOptBool(player.AimbotDistanceCheck, "Distance", ::AimbotOptions, 3, player);

                if(isDefined(player.AimbotDistanceCheck))
                    self addOptIncSlider("Max Distance", ::AimbotDistance, 100, 100, 1000, 100, player);
            break;
        
        case "Map Challenges Player":
            self addMenu("Challenges");

                if(isDefined(player._challenges))
                {
                    self addOptBool(player flag::get("flag_player_completed_challenge_" + player._challenges.var_4687355c.n_index), player._challenges.var_4687355c.str_info, ::MapCompleteChallenge, player._challenges.var_4687355c, player);
                    self addOptBool(player flag::get("flag_player_completed_challenge_" + player._challenges.var_b88ea497.n_index), player._challenges.var_b88ea497.str_info, ::MapCompleteChallenge, player._challenges.var_b88ea497, player);
                    self addOptBool(player flag::get("flag_player_completed_challenge_" + player._challenges.var_928c2a2e.n_index), player._challenges.var_928c2a2e.str_info, ::MapCompleteChallenge, player._challenges.var_928c2a2e, player);
                }
            break;
        
        case "Origins Challenges Player":
            self addMenu("Challenges");

                foreach(challenge in level._challenges.a_stats)
                    self addOptBool(get_stat(challenge.str_name, player).b_medal_awarded, challenge.str_hint, ::CompleteOriginChallenge, challenge.str_name, player);
            break;
        
        case "Options":
            submenus = [
            "Verification",
            "Basic Scripts",
            "Teleport Menu",
            "Profile Management",
            "Weaponry",
            "Bullet Menu",
            "Fun Scripts",
            "Model Manipulation",
            "Aimbot Menu",
            "Model Attachment",
            "Malicious Options"
            ];
            
            self addMenu("[^2" + player.verification + "^7]" + CleanName(player getName()));

                for(a = 0; a < submenus.size; a++)
                    self addOpt(submenus[a], ::newMenu, submenus[a]);

                self addOpt("Send Message", ::Keyboard, ::MessagePlayer, player);
                self addOptBool(player.FreezePlayer, "Freeze", ::FreezePlayer, player);
                self addOpt("Kick", ::KickPlayer, player);
                self addOpt("Temp Ban", ::BanPlayer, player);
            break;
        
        case "Verification":
            self addMenu("Verification");
                self addOpt("Save Verification", ::SavePlayerVerification, player);

                for(a = 0; a < (level.MenuStatus.size - 2); a++)
                    self addOptBool((player getVerification() == a), level.MenuStatus[a], ::setVerification, a, player, true);
            break;
        
        case "Model Attachment":
            if(!isDefined(self.playerAttachBone))
                self.playerAttachBone = "j_head";
            
            self addMenu("Model Attachment");
                
                if(isDefined(level.MenuModels) && level.MenuModels.size)
                {
                    self addOptSlider("Location", ::PlayerAttachmentBone, level.boneTags);
                    self addOpt("Detach All", ::PlayerDetachModels, player);
                    self addOpt("");

                    for(a = 0; a < level.MenuModels.size; a++)
                        if(level.MenuModels[a] != "defaultactor") //Attaching the defaultactor to a player can cause a crash.
                            self addOpt(CleanString(level.MenuModels[a]), ::PlayerModelAttachment, level.menuModels[a], player);
                }
            break;
        
        case "Malicious Options":
            if(!isDefined(player.ShellShockTime))
                player.ShellShockTime = 1;
            
            self addMenu("Malicious Options");
                self addOpt("Open Pause Menu", ::PlayerOpenPauseMenu, player);
                self addOpt("Disable Actions", ::newMenu, "Disable Actions");
                self addOptSlider("Set Stance", ::SetPlayerStance, "Prone;Crouch;Stand", player);
                self addOpt("Launch", ::LaunchPlayer, player);
                self addOpt("Mortar Strike", ::MortarStrikePlayer, player);

                if(ReturnMapName(level.script) == "Shadows Of Evil" || ReturnMapName(level.script) == "Origins")
                    self addOpt("Jump Scare", ::JumpScarePlayer, player);
                
                self addOptBool(player.AutoDown, "Auto-Down", ::AutoDownPlayer, player);
                self addOptBool(player.FlashLoop, "Flash Loop", ::FlashLoop, player);
                self addOptBool(player.SpinPlayer, "Spin Player", ::SpinPlayer, player);
                self addOptBool(player.BlackScreen, "Black Screen", ::BlackScreenPlayer, player);
                self addOptBool(player.FakeLag, "Fake Lag", ::FakeLag, player);
                self addOptBool(self.AttachToPlayer, "Attach Self To Player", ::AttachSelfToPlayer, player);
                self addOptSlider("Shellshock", ::ApplyShellShock, "Concussion Grenade;Zombie Death;Explosion", player);
                self addOptIncSlider("Shellshock Time", ::SetShellShockTime, 1, 1, 30, 1, player);
                self addOptSlider("Show IP", ::ShowPlayerIP, "Self;Player", player);
                self addOpt("Fake Derank", ::FakeDerank, player);
                self addOpt("Fake Damage", ::FakeDamagePlayer, player);
                self addOpt("Crash Game", ::CrashPlayer, player);
            break;
        
        case "Disable Actions":
            self addMenu("Disable Actions");
                self addOptBool(player.DisableAiming, "Aiming", ::DisableAiming, player);
                self addOptBool(player.DisableJumping, "Jumping", ::DisableJumping, player);
                self addOptBool(player.DisableSprinting, "Sprinting", ::DisableSprinting, player);
                self addOptBool(player.DisableWeaps, "Weapons", ::DisableWeaps, player);
                self addOptBool(player.DisableOffhands, "Offhand Weapons", ::DisableOffhands, player);
            break;
        
        default:
            if(isInArray(weapons, menu))
            {
                pistols = ["pistol_standard", "pistol_burst", "pistol_fullauto", "pistol_m1911", "pistol_revolver38", "pistol_c96"];
                specials = [];

                foreach(index, weapon_category in weapons)
                {
                    if(menu == weapon_category)
                    {
                        self addMenu(weapon_category);
                            if(isDefined(level.zombie_weapons) && level.zombie_weapons.size)
                            {
                                foreach(weapon in GetArrayKeys(level.zombie_weapons))
                                {
                                    if(MakeLocalizedString(weapon.displayname) == "" || weapon.isgrenadeweapon || weapon.name == "knife" || IsSubStr(weapon.name, "upgraded") || weapon.name == "none")
                                        continue;
                                    
                                    if(!IsInArray(pistols, weapon.name) && !IsInArray(specials, weapon) && zm_utility::GetWeaponClassZM(weapon) == "weapon_pistol")
                                        specials[specials.size] = weapon;
                                    else if(zm_utility::GetWeaponClassZM(weapon) == "weapon_" + weaponsVar[index])
                                        self addOptBool(player HasWeapon1(weapon), weapon.displayname, ::GivePlayerWeapon, weapon, player);
                                }
                            }
                    }
                }

                foreach(weapon in specials)
                {
                    if(menu == "Specials")
                    {
                        if(weapon.isgrenadeweapon || weapon.name == "knife" || weapon.name == "none")
                            continue;
                        
                        string = weapon.name;

                        if(MakeLocalizedString(weapon.displayname) != "")
                            string = weapon.displayname;
                        
                        self addOptBool(player HasWeapon1(weapon), string, ::GivePlayerWeapon, weapon, player);
                    }
                }

                if(menu == "Specials")
                {
                    self addOptBool(player HasWeapon1(GetWeapon("defaultweapon")), "Default Weapon", ::GivePlayerWeapon, GetWeapon("defaultweapon"), player);
                    self addOptBool(player HasWeapon1(GetWeapon("minigun")), GetWeapon("minigun").displayname, ::GivePlayerWeapon, GetWeapon("minigun"), player);

                    if(mapStr == "Shadows Of Evil")
                        self addOptBool(player HasWeapon1(GetWeapon("tesla_gun")), GetWeapon("tesla_gun").displayname, ::GivePlayerWeapon, GetWeapon("tesla_gun"), player);
                }
            }
            else if(menu == "Mystery Box Normal Weapons" || menu == "Mystery Box Upgraded Weapons")
            {
                arr = [];
                type = (menu == "Mystery Box Normal Weapons") ? level.zombie_weapons : level.zombie_weapons_upgraded;
                weaponsVar = ["assault", "smg", "lmg", "sniper", "cqb", "pistol", "launcher", "special"];
                weaps = GetArrayKeys(type);

                self addMenu((menu == "Mystery Box Normal Weapons") ? "Normal Weapons" : "Upgraded Weapons");
                self addOptBool(IsAllWeaponsInBox(type), "Enable All", ::EnableAllWeaponsInBox, type);

                if(isDefined(weaps) && weaps.size)
                {
                    for(a = 0; a < weaps.size; a++)
                    {
                        if(menu == "Mystery Box Normal Weapons" && IsSubStr(weaps[a].name, "upgraded"))
                            continue;

                        if(IsInArray(weaponsVar, ToLower(CleanString(zm_utility::GetWeaponClassZM(zm_weapons::get_base_weapon(weaps[a]))))) && !weaps[a].isgrenadeweapon && !IsSubStr(weaps[a].name, "knife") && weaps[a].name != "none")
                        {
                            string = weaps[a].name;

                            if(MakeLocalizedString(weaps[a].displayname) != "")
                                string = weaps[a].displayname;
                            
                            if(!IsInArray(arr, string))
                            {
                                arr[arr.size] = string;
                                self addOptBool(IsWeaponInBox(weaps[a]), string, ::SetBoxWeaponState, weaps[a]);
                            }
                        }
                    }
                }
                
                if(menu == "Mystery Box Normal Weapons")
                {
                    equipment = ArrayCombine(level.zombie_lethal_grenade_list, level.zombie_tactical_grenade_list, 0, 1);
                    keys = GetArrayKeys(equipment);

                    self addOptBool(IsWeaponInBox(GetWeapon("minigun")), "Death Machine", ::SetBoxWeaponState, GetWeapon("minigun"));
                    self addOptBool(IsWeaponInBox(GetWeapon("defaultweapon")), "Default Weapon", ::SetBoxWeaponState, GetWeapon("defaultweapon"));

                    if(isDefined(keys) && keys.size)
                    {
                        foreach(index, weapon in GetArrayKeys(level.zombie_weapons))
                            if(isInArray(equipment, weapon))
                                self addOptBool(IsWeaponInBox(weapon), weapon.displayname, ::SetBoxWeaponState, weapon);
                    }
                }
            }
            else
            {
                error404 = true;

                for(a = 0; a < level.mapNames.size; a++)
                {
                    if(IsSubStr(menu, "Map Stats " + level.mapNames[a]) || menu == "Map Stats " + level.mapNames[a])
                    {
                        error404 = false;
                        mapStats = ["score", "total_games_played", "total_rounds_survived", "highest_round_reached", "time_played_total", "total_downs"];

                        self addMenu(ReturnMapName(level.mapNames[a]));
                            for(b = 0; b < mapStats.size; b++)
                                self addOptBool(isInArray(player.CustomStatsArray, mapStats[b] + "_" + level.mapNames[a]), CleanString(mapStats[b]), ::AddToCustomStats, mapStats[b] + "_" + level.mapNames[a], player);
                    }
                }

                if(IsSubStr(menu, mapStr + " Teleports") || menu == mapStr + " Teleports")
                {
                    error404 = false;

                    self addMenu(mapStr + " Teleports");
                        
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
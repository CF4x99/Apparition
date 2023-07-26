runMenuIndex(menu)
{
    self endon("disconnect");
    
    switch(menu)
    {
        case "Main":
            self addMenu(menu, (self.menu["MenuDesign"] == "Right Side") ? "Main Menu" : level.menuName);
            
            if(self getVerification() > 0) //Verified
            {
                self addOpt("Basic Scripts", ::newMenu, "Basic Scripts " + self GetEntityNumber());
                self addOpt("Menu Customization", ::newMenu, "Menu Customization");
                self addOpt("Message Menu", ::newMenu,"Message Menu");
                self addOpt("Teleport Menu", ::newMenu, "Teleport Menu " + self GetEntityNumber());

                if(self getVerification() > 1) //VIP
                {
                    self addOpt("Power-Up Menu", ::newMenu, "Power-Up Menu");
                    self addOpt("Profile Management", ::newMenu, "Profile Management " + self GetEntityNumber());
                    self addOpt("Weaponry", ::newMenu, "Weaponry " + self GetEntityNumber());
                    self addOpt("Bullet Menu", ::newMenu, "Bullet Menu " + self GetEntityNumber());
                    self addOpt("Fun Scripts", ::newMenu, "Fun Scripts " + self GetEntityNumber());
                    self addOpt("Model Manipulation", ::newMenu, "Model Manipulation " + self GetEntityNumber());
                    self addOpt("Aimbot Menu", ::newMenu, "Aimbot Menu " + self GetEntityNumber());

                    if(self getVerification() > 2) //Admin
                    {
                        self addOpt("Advanced Scripts", ::newMenu, "Advanced Scripts");

                        if(ReturnMapName(level.script) != "Unknown")
                            self addOpt(ReturnMapName(level.script) + " Scripts", ::newMenu, ReturnMapName(level.script) + " Scripts");

                        self addOpt("Forge Options", ::newMenu, "Forge Options");
                        
                        if(self getVerification() > 3) //Co-Host
                        {
                            self addOpt("Server Modifications", ::newMenu, "Server Modifications");
                            self addOpt("Zombie Options", ::newMenu, "Zombie Options");
                            self addOpt("Spawnables", ::newMenu, "Spawnables");

                            if(self IsHost())
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
                    menu_customization.gsc -> LoadMenuVars() -> self.menu["maxOptionsQM"]
                
                It's not recommended to go over 15 - 18, due to hud limitations
                You can also find the default X/Y variables for the quick menu there as well(self.menu["XQM"] / self.menu["YQM"])
            */

            self addMenu(menu, "Quick Menu H4X");

                if(Is_Alive(self))
                {
                    self addOptBool(self.godmode, "God Mode", ::Godmode, self);
                    self addOptBool(self.Noclip, "Noclip", ::Noclip1, self);
                    self addOptBool(self.NoclipBind, "Bind Noclip To [{+frag}]", ::BindNoclip, self);
                    self addOptSlider("Unlimited Ammo", ::UnlimitedAmmo, "Continuous;Reload;Disable", self);
                    self addOptBool(self.UnlimitedEquipment, "Unlimited Equipment", ::UnlimitedEquipment, self);
                    self addOptSlider("Modify Score", ::ModifyScore, "1000000;100000;10000;1000;100;10;0;-10;-100;-1000;-10000;-100000;-1000000", self);
                    self addOpt("Perk Menu", ::newMenu, "Perk Menu " + self GetEntityNumber());
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
            self addMenu(menu, "Menu Customization");
                self addOpt("Menu Credits", ::MenuCredits);
                self addOptSlider("Style", ::MenuDesign, level.menuName + ";Right Side;Old School");
                self addOpt("Design Preferences", ::newMenu, "Design Preferences");
                self addOpt("Main Design Color", ::newMenu, "Main Design Color");
            break;
        
        case "Design Preferences":
            self addMenu(menu, "Design Preferences");
                if(self.menu["MenuDesign"] != "Old School")
                {
                    self addOptSlider("Toggle Style", ::ToggleStyle, "Boxes;Text;Text Color");
                    self addOptIncSlider("Max Options", ::MenuMaxOptions, 5, self.menu["MaxOptions"], 12, 1);

                    if(self.menu["MenuDesign"] != "Right Side")
                        self addOptBool(self.menu["DisableOptionCounter"], "Disable Option Counter", ::DisableOptionCounter);
                }

                self addOptBool(self.menu["MenuBlur"], "Menu Blur", ::MenuBlur);
                self addOptBool(self.menu["DisableMenuInstructions"], "Disable Instructions", ::DisableMenuInstructions);
                self addOptBool(self.menu["LargeCursor"], "Large Cursor", ::LargeCursor);
                self addOptBool(self.menu["DisableQM"], "Disable Quick Menu", ::DisableQuickMenu);
            break;
        
        case "Main Design Color":
            self addMenu(menu, "Main Design Color");

                for(a = 0; a < level.colorNames.size; a++)
                    self addOptBool((!isDefined(self.SmoothRainbowTheme) && self.menu["Main_Color"] == divideColor(level.colors[(3 * a)], level.colors[((3 * a) + 1)], level.colors[((3 * a) + 2)])), level.colorNames[a], ::MenuTheme, divideColor(level.colors[(3 * a)], level.colors[((3 * a) + 1)], level.colors[((3 * a) + 2)]));
                
                self addOptBool(self.SmoothRainbowTheme, "Smooth Rainbow", ::SmoothRainbowTheme);
            break;
        
        case "Message Menu":
            self addMenu(menu, "Message Menu");
                self addOptSlider("Display Type", ::MessageDisplay, "Notify;Print Bold");
                self addOpt("Custom Message", ::Keyboard, "Custom Message", ::DisplayMessage);
                self addOpt("Miscellaneous", ::newMenu, "Miscellaneous Messages");
                self addOpt("Advertisements", ::newMenu, "Advertisements Messages");
            break;
        
        case "Miscellaneous Messages":
            self addMenu(menu, "Miscellaneous");
                self addOpt("Want Menu?", ::DisplayMessage, "Want Menu?");
                self addOpt("Who's Modding?", ::DisplayMessage, "Who's Modding?");
                self addOpt(CleanName(self getName()), ::DisplayMessage, CleanName(self getName()) + " <3");
                self addOpt("Host", ::DisplayMessage, "Your Host Today Is " + CleanName(bot::get_host_player() getName()));
            break;
        
        case "Advertisements Messages":
            self addMenu(menu, "Advertisements");
                self addOpt("Welcome", ::DisplayMessage, "Welcome To " + level.menuName);
                self addOpt("Developer", ::DisplayMessage, level.menuName + " Was Developed By CF4_99");
                self addOpt("YouTube", ::DisplayMessage, "YouTube: CF4_99");
                self addOpt("Discord.gg/MXT", ::DisplayMessage, "Discord.gg/MXT");
            break;
        
        case "Power-Up Menu":
            if(!isDefined(self.PowerUpSpawnLocation))
                self.PowerUpSpawnLocation = "Crosshairs";
            
            powerups = GetArrayKeys(level.zombie_include_powerups);
            
            self addMenu(menu, "Power-Up Menu");
                self addOptSlider("Spawn Location", ::PowerUpSpawnLocation, "Crosshairs;Self");
                self addOpt("Reign Drops", ::ReignDropsActivate);

                if(isDefined(powerups) && powerups.size)
                {
                    for(a = 0; a < powerups.size; a++)
                        if(powerups[a] != "free_perk")
                            self addOpt(CleanString(powerups[a]), ::SpawnPowerUp, powerups[a]);
                        else
                            self addOpt("Free Perk", ::SpawnPowerUp, powerups[a]);
                }
                else
                    self addOpt("No Power-Ups Found");
            break;
        
        case "Advanced Scripts":
            if(!isDefined(self.CustomSentryWeapon))
                self.CustomSentryWeapon = GetWeapon("minigun");
            
            self addMenu(menu, "Advanced Scripts");
                self addOptSlider("AC-130", ::AC130, "Fly;Walking");

                if(isDefined(level.zombie_include_powerups) && level.zombie_include_powerups.size)
                    self addOptBool(level.RainPowerups, "Rain Power-Ups", ::RainPowerups);
                
                self addOpt("Rain Options", ::newMenu, "Rain Options");
                self addOptBool(self.CustomSentry, "Custom Sentry", ::CustomSentry);
                self addOpt("Custom Sentry Weapon", ::newMenu, "Custom Sentry Weapon");
                self addOpt("Artillery Strike", ::ArtilleryStrike);
                self addOptBool(level.TornadoSpawned, "Tornado", ::Tornado);

                if(ReturnMapName(level.script) != "Moon" && ReturnMapName(level.script) != "Origins")
                    self addOptBool(level.MoonDoors, "Moon Doors", ::MoonDoors);

                self addOptSlider("Controllable Zombie", ::ControllableZombie, "Friendly;Enemy");
                self addOptBool(self.BodyGuard, "Body Guard", ::BodyGuard);
                self addOptIncSlider("Spiral Staircase", ::SpiralStaircase, 5, 5, 50, 1);
            break;
        
        case "Rain Options":
            self addMenu(menu, "Rain Options");
                self addOpt("Disable", ::DisableLobbyRain);
                self addOpt("Models", ::newMenu, "Rain Models");
                self addOpt("Effects", ::newMenu, "Rain Effects");
                self addOpt("Projectiles", ::newMenu, "Rain Projectiles");
            break;
        
        case "Rain Models":
            arr = [];
            ents = GetEntArray("script_model", "classname");
            
            self addMenu(menu, "Models");

                if(isDefined(level.MenuModels) && level.MenuModels.size)
                    for(a = 0; a < level.MenuModels.size; a++)
                        self addOpt(CleanString(level.MenuModels[a]), ::LobbyRain, "Model", level.MenuModels[a]);
                else
                    self addOpt("No Models Found");
            break;
        
        case "Rain Effects":
            fxs = GetArrayKeys(level._effect);
            
            self addMenu(menu, "Effects");

                for(a = 0; a < fxs.size; a++)
                    self addOpt(CleanString(fxs[a]), ::LobbyRain, "FX", fxs[a]);
            break;
        
        case "Rain Projectiles":
            arr = [];
            weaponsVar = ["assault", "smg", "lmg", "sniper", "cqb", "pistol", "launcher", "special"];
            weaps = GetArrayKeys(level.zombie_weapons);

            self addMenu("Rain Projectiles", "Projectiles");

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
                                self addOpt(string, ::LobbyRain, "Projectile", weaps[a]);
                            }
                        }
                    }
                }
            break;
        
        case "Custom Sentry Weapon":
            arr = [];
            weaps = GetArrayKeys(level.zombie_weapons);
            weaponsVar = ["assault", "smg", "lmg", "sniper", "cqb", "pistol", "launcher", "special"];
            
            self addMenu(menu, "Custom Sentry Weapon");
                self addOptBool((self.CustomSentryWeapon == GetWeapon("minigun")), "Death Machine", ::SetCustomSentryWeapon, GetWeapon("minigun"));

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
                                self addOptBool((self.CustomSentryWeapon == weaps[a]), string, ::SetCustomSentryWeapon, weaps[a]);
                            }
                        }
                    }
                }
            break;
        
        case "Forge Options":
            if(!isDefined(self.forge["ModelDistance"]))
                self.forge["ModelDistance"] = 200;
            
            if(!isDefined(self.forge["ModelScale"]))
                self.forge["ModelScale"] = 1;
            
            self addMenu(menu, "Forge Options");
                self addOpt("Spawn", ::newMenu, "Spawn Script Model");
                self addOptIncSlider("Scale", ::ForgeModelScale, 1, 1, 10, 1);
                self addOpt("Place", ::ForgePlaceModel);
                self addOpt("Copy", ::ForgeCopyModel);
                self addOpt("Rotate", ::newMenu, "Rotate Script Model");
                self addOpt("Delete", ::ForgeDeleteModel);
                self addOpt("Drop", ::ForgeDropModel);
                self addOpt("Distance", ::NumberPad, "Model Distance", ::ForgeModelDistance);
                self addOptBool(self.forge["ignoreCollisions"], "Ignore Collisions", ::ForgeIgnoreCollisions);
                self addOpt("Delete Last Spawn", ::ForgeDeleteLastSpawn);
                self addOpt("Delete All Spawned", ::ForgeDeleteAllSpawned);
                self addOptBool(self.ForgeShootModel, "Shoot Model", ::ForgeShootModel);
            break;
        
        case "Spawn Script Model":
            self addMenu(menu, "Spawn");

                if(isDefined(level.MenuModels) && level.MenuModels.size)
                    for(a = 0; a < level.MenuModels.size; a++)
                        self addOpt(CleanString(level.MenuModels[a]), ::ForgeSpawnModel, level.MenuModels[a]);
                else
                    self addOpt("No Models Found");
            break;
        
        case "Rotate Script Model":
            self addMenu(menu, "Rotate");
                self addOpt("Reset Angles", ::ForgeRotateModel, 0, "Reset");
                self addOptIncSlider("Roll", ::ForgeRotateModel, -10, 0, 10, 1, "Roll");
                self addOptIncSlider("Yaw", ::ForgeRotateModel, -10, 0, 10, 1, "Yaw");
                self addOptIncSlider("Pitch", ::ForgeRotateModel, -10, 0, 10, 1, "Pitch");
            break;
        
        case "The Giant Scripts":
            self addMenu(menu, "The Giant Scripts");
                self addOptBool(level flag::get("power_on"), "Turn On Power", ::ActivatePower);
                self addOpt("Link Teleporters", ::newMenu, "The Giant Teleporters");
                self addOptBool(level flag::get("snow_ee_completed"), "Complete Sixth Perk", ::GiantCompleteSixthPerk);
                self addOptBool((isDefined(level.HideAndSeekInit) || level flag::get("hide_and_seek")), "Start Hide & Seek", ::InitializeGiantHideAndSeek);
                self addOptBool((isDefined(level.GiantHideAndSeekCompleted) || level flag::get("hide_and_seek") && !level flag::get("flytrap")), "Complete Hide & Seek", ::GiantCompleteHideAndSeek);
            break;
        
        case "The Giant Teleporters":
            self addMenu(menu, "The Giant Teleporters");
                self addOptBool((level.active_links == 3), "Link All", ::GiantLinkAllTeleporters);

                for(a = 0; a < 3; a++)
                    self addOptBool((level.teleport[a] == "active"), "Teleporter " + (a + 1), ::GiantLinkTeleporterToMainframe, a);
            break;
        
        case "Nacht Der Untoten Scripts":
            self addMenu(menu, "Nacht Der Untoten Scripts");
                self addOptBool(level flag::get("snd_zhdegg_completed"), "Samantha's Hide & Seek", ::SamanthasHideAndSeekSong);
                self addOptBool(level.NachtUndoneSong, "Undone Song", ::NachtUndoneSong);
            break;
        
        case "Kino Der Toten Scripts":
            self addMenu(menu, "Kino Der Toten Scripts");
                self addOptBool(level flag::get("power_on"), "Turn On Power", ::ActivatePower);
                self addOptBool(level flag::get("snd_zhdegg_activate"), "Door Knocking Combination", ::CompleteDoorKnockingCombination);
                self addOptBool(level flag::get("snd_zhdegg_completed"), "Samantha's Hide & Seek", ::SamanthasHideAndSeekSong);
                self addOptBool(level flag::get("snd_song_completed"), "Meteor 115 Song", ::CompleteMeteorEE);
            break;
        
        case "Moon Scripts":
            self addMenu(menu, "Moon Scripts");
                self addOptBool(level flag::get("power_on"), "Turn On Power", ::ActivatePower);
                self addOptSlider("Activate Excavator", ::ActivateDigger, "Teleporter;Hangar;Biodome");
                self addOptBool(level.FastExcavators, "Fast Excavators", ::FastExcavators);

                if(level flag::get("power_on"))
                {
                    self addOptBool(level flag::get("ss1"), "Samantha Says Part 1", ::CompleteSamanthaSays, "ss1");

                    if(level flag::get("ss1"))
                        self addOptBool(level flag::get("ss2"), "Samantha Says Part 2", ::CompleteSamanthaSays, "ss2");
                }
            break;
        
        case "Shangri-La Scripts":
            self addMenu(menu, "Shangri-La Scripts");
                self addOptBool(level flag::get("power_on"), "Turn On Power", ::ActivatePower);
                self addOptBool(level flag::get("snd_zhdegg_completed"), "Samantha's Hide & Seek", ::ShangHideAndSeekSong);
            break;
        
        case "Verruckt Scripts":
            self addMenu(menu, "Verruckt Scripts");
                self addOptBool(level flag::get("power_on"), "Turn On Power", ::ActivatePower);
                self addOptBool(level flag::get("snd_zhdegg_completed"), "Samantha's Hide & Seek", ::VerrucktHideAndSeekSong);
                self addOptBool(level.VerrucktLullaby, "Lullaby For A Dead Man Song", ::VerrucktLullabyForADeadMan);
            break;
        
        case "Shi No Numa Scripts":
            self addMenu(menu, "Shi No Numa Scripts");
                self addOptBool(level flag::get("snd_zhdegg_completed"), "Samantha's Hide & Seek", ::ShinoHideAndSeek);
                self addOptBool(level.ShinoTheOneSong, "The One Song", ::ShinoTheOneSong);
            break;
        
        case "Origins Scripts":
            self addMenu(menu, "Origins Scripts");
                self addOptSlider("Weather", ::OriginsSetWeather, "None;Rain;Snow");
                self addOpt("Generators", ::newMenu, "Origins Generators");
                self addOpt("Gateways", ::newMenu, "Origins Gateways");
                self addOpt("Give Shovel", ::newMenu, "Give Shovel Origins");
                self addOptBool(isDefined(level.a_e_slow_areas), "Mud Slowdown", ::MudSlowdown);
                self addOpt("Soul Boxes", ::newMenu, "Soul Boxes");
                self addOpt("Challenges", ::newMenu, "Origins Challenges");
                self addOpt("Staff Puzzles", ::newMenu, "Origins Puzzles");
            break;
        
        case "Origins Generators":
            generators = struct::get_array("s_generator", "targetname");

            self addMenu(menu, "Generators");

                for(a = 0; a < generators.size; a++)
                    self addOptBool(generators[a] flag::get("player_controlled"), "Generator " + generators[a].script_int, ::SetGeneratorState, a);
            break;
        
        case "Origins Gateways":
            gateways = struct::get_array("trigger_teleport_pad", "targetname");

            self addMenu(menu, "Gateways");

                for(a = 0; a < gateways.size; a++)
                    self addOptBool(GetGatewayState(gateways[a]), ReturnGatewayName(gateways[a].target), ::SetGatewayState, gateways[a]);
            break;
        
        case "Give Shovel Origins":
            self addMenu(menu, "Give Shovel");
            
                foreach(player in level.players)
                    self addOptBool(player.dig_vars["has_shovel"], CleanName(player getName()), ::GivePlayerShovel, player);
            break;
        
        case "Soul Boxes":
            boxes = GetEntArray("foot_box", "script_noteworthy");

            self addMenu(menu, "Soul Boxes");

                if(boxes.size)
                {
                    for(a = 0; a < boxes.size; a++)
                        self addOpt("Soul Box " + (a + 1), ::CompleteSoulbox, boxes[a]);
                }
                else
                    self addOpt("No Soul Boxes Found");
            break;
        
        case "Origins Challenges":
            self addMenu(menu, "Challenges");

                foreach(player in level.players)
                    self addOpt(CleanName(player getName()), ::newMenu, "Origins Challenges Player " + player GetEntityNumber());
            break;
        
        case "Origins Puzzles":
            self addMenu(menu, "Puzzles");
                self addOpt("Ice", ::newMenu, "Ice Puzzles");
                self addOpt("Wind", ::newMenu, "Wind Puzzles");
                self addOpt("Fire", ::newMenu, "Fire Puzzles");
                self addOpt("Lightning", ::newMenu, "Lightning Puzzles");
                self addOpt("");
                self addOptSlider("115 Rings(Buggy)", ::Align115Rings, "Ice;Lightning;Fire;Wind");
            break;
        
        case "Ice Puzzles":
            self addMenu(menu, "Ice");
                self addOptBool(level flag::get("ice_puzzle_1_complete"), "Tiles", ::CompleteIceTiles);
                self addOptBool(level flag::get("ice_puzzle_2_complete"), "Tombstones", ::CompleteIceTombstones);
            break;
        
        case "Wind Puzzles":
            self addMenu(menu, "Wind");
                self addOptBool(level flag::get("air_puzzle_1_complete"), "Rings", ::CompleteWindRings);
                self addOptBool(level flag::get("air_puzzle_2_complete"), "Smoke", ::CompleteWindSmoke);
            break;
        
        case "Fire Puzzles":
            self addMenu(menu, "Fire");
                self addOptBool(level flag::get("fire_puzzle_1_complete"), "Fill Cauldrons", ::ComepleteFireCauldrons);
                self addOptBool(level flag::get("fire_puzzle_2_complete"), "Light Torches", ::CompleteFireTorches);
            break;
        
        case "Lightning Puzzles":
            self addMenu(menu, "Lightning");
                self addOptBool(level flag::get("electric_puzzle_1_complete"), "Song", ::CompleteLightningSong);
                self addOptBool(level flag::get("electric_puzzle_2_complete"), "Turn Dials", ::CompleteLightningDials);
            break;
        
        case "Gorod Krovi Scripts":
            self addMenu(menu, "Gorod Krovi Scripts");
                self addOptBool(level flag::get("power_on"), "Turn On Power", ::ActivatePower);
                self addOpt("Challenges", ::newMenu, "Map Challenges");
            break;
        
        case "Zetsubou No Shima Scripts":
            self addMenu(menu, "Zetsubou No Shima Scripts");
                self addOpt("KT-4 Parts", ::newMenu, "Zetsubou No Shima KT-4 Parts");
                self addOpt("Skulltar Teleports", ::newMenu, "Skulltar Teleports");
                self addOpt("Challenges", ::newMenu, "Map Challenges");
                self addOptBool(self clientfield::get_to_player("bucket_held"), "Collect Bucket", ::ZNSGrabWaterBucket);
                self addOpt("Bucket Water Type", ::newMenu, "ZNS Bucket Water");
            break;
        
        case "Zetsubou No Shima KT-4 Parts":
            self addMenu(menu, "KT-4 Parts");
                self addOptBool(level flag::get("ww1_found"), "Vial", ::CollectKT4Parts, "ww1_found");
                self addOptBool(level flag::get("ww2_found"), "Plant", ::CollectKT4Parts, "ww2_found");
                self addOptBool(level flag::get("ww3_found"), "Venom", ::CollectKT4Parts, "ww3_found");
            break;
        
        case "Map Challenges":
            self addMenu(menu, "Challenges");
                
                foreach(player in level.players)
                    self addOpt(CleanName(player getName()), ::newMenu, "Map Challenges Player " + player GetEntityNumber());
            break;
        
        case "Skulltar Teleports":
            skulltars = GetEntArray("mdl_skulltar", "targetname");

            self addMenu(menu, "Skulltar Teleports");

                for(a = 0; a < skulltars.size; a++)
                    self addOpt("Skulltar " + (a + 1), ::TeleportPlayer, skulltars[a].origin, self);
            break;
        
        case "ZNS Bucket Water":
            self addMenu(menu, "Bucket Water Type");
                foreach(source in GetEntArray("water_source", "targetname"))
                    self addOptBool(self.var_c6cad973 == source.script_int, ZNSReturnWaterType(source.script_int), ::ZNSFillBucket, source);
                
                self addOptBool(self.var_c6cad973 == GetEnt("water_source_ee", "targetname").script_int, "Rainbow", ::ZNSFillBucket, GetEnt("water_source_ee", "targetname"));
            break;
        
        case "Ascension Scripts":
            self addMenu(menu, "Ascension Scripts");
                self addOptBool(level flag::get("power_on"), "Turn On Power", ::ActivatePower);

                if(!level flag::get("target_teleported"))
                    self addOpt("Throw Gersch At Generator", ::TeleportGenerator);
                
                if(!level flag::get("rerouted_power"))
                    self addOpt("Activate Computer", ::ActivateComputer);
                
                if(!level flag::get("switches_synced"))
                    self addOpt("Activate Switches", ::ActivateSwitches);
                
                if(!(level flag::get("lander_a_used") && level flag::get("lander_b_used") && level flag::get("lander_c_used") && level flag::get("launch_activated")))
                    self addOpt("Refuel The Rocket", ::RefuelRocket);
                
                if(!level flag::get("launch_complete"))
                    self addOpt("Launch The Rocket", ::LaunchRocket);
                
                if(!level flag::get("pressure_sustained"))
                    self addOpt("Complete Time Clock", ::CompleteTimeClock);
            break;
        
        case "Der Eisendrache Scripts":
            self addMenu(menu, "Der Eisendrache Scripts");
                self addOptBool(level flag::get("power_on"), "Turn On Power", ::ActivatePower);
                self addOptBool(level flag::get("soul_catchers_charged"), "Feed Dragons", ::FeedDragons);

                if(level flag::get("soul_catchers_charged"))
                    self addOpt("Bow Quests", ::newMenu, "Bow Quests");
            break;
        
        case "Bow Quests":
            self addMenu(menu, "Bow Quests");
                self addOpt("Fire", ::newMenu, "Fire Bow");
                self addOpt("Lightning", ::newMenu, "Lightning Bow");
                //self addOpt("Void", ::newMenu, "Void Bow");
                //self addOpt("Wolf", ::newMenu, "Wolf Bow");
            break;
        
        case "Fire Bow":
            //level.var_c62829c7 <- player bound to fire quest

            self addMenu(menu, "Fire");
                self addOptBool(isDefined(level.var_714fae39), "Initiate Quest", ::InitFireBow);

                if(isDefined(level.var_714fae39))
                {
                    if(isDefined(level.var_c62829c7))
                    {
                        self addOptBool((level flag::get("rune_prison_obelisk") && !isDefined(level.MagmaRock)), "Shoot Magma Rock", ::MagmaRock);
                        self addOptBool(AllRunicCirclesCharged(), "Activate & Charge Runic Circles", ::RunicCircles);
                        self addOptBool(IsClockFireplaceComplete(), "Complete Fireplace Step", ::ClockFireplaceStep);
                        self addOptBool(level flag::get("rune_prison_repaired"), "Collect Repaired Arrows", ::CollectRepairedFireArrows);
                    }
                    else
                    {
                        self addOpt("");
                        self addOpt("Quest Hasn't Been Bound Yet");
                    }
                }
            break;
        
        case "Lightning Bow":
            //level.var_f8d1dc16 <- player bound to lightning quest

            trig = GetEnt("aq_es_weather_vane_trig", "targetname");

            self addMenu(menu, "Lightning");
                self addOptBool(!isDefined(trig), "Initiate Quest", ::InitLightningBow);

                if(!isDefined(trig))
                {
                    if(isDefined(level.var_f8d1dc16))
                    {
                        self addOptBool(AreBeaconsLit(), "Light Beacons", ::LightningBeacons);
                        self addOptBool(level flag::get("elemental_storm_wallrun"), "Wallrun Step", ::LightningWallrun);
                        self addOptBool(LightningBeaconsCharged(), "Fill Urns & Charge Beacons", ::LightningChargeBeacons);
                        self addOptBool(level flag::get("elemental_storm_repaired"), "Charge & Collect Arrows", ::ChargeLightningArrows);
                    }
                    else
                    {
                        self addOpt("");
                        self addOpt("Quest Hasn't Been Bound Yet");
                    }
                }
            break;
        
        /*case "Void Bow":
            //level.var_6e68c0d8 <- player bound to void quest
            symDestroyed = level IsDemonSymbolDestroyed();

            self addMenu(menu, "Void");
                self addOpt("Removed For The Time Being");
                self addOptBool(symDestroyed, "Initiate Quest", ::InitVoidBow);

                if(symDestroyed)
                {
                    if(isDefined(level.var_6e68c0d8))
                    {
                        self addOptBool(level flag::get("demon_gate_seal"), "Release Demon Urn", ::ReleaseDemonUrn);
                        //self addOptBool(IsAllFossilsTriggered(), "Trigger Fossil Heads", ::TriggerDemonFossils);
                        //self addOptBool(level flag::get("demon_gate_crawlers"), "Feed Demon Urn", ::FeedDemonUrn);
                    }
                    else
                    {
                        self addOpt("");
                        self addOpt("Quest Hasn't Been Bound Yet");
                    }
                }
            break;*/
        
        case "Shadows Of Evil Scripts":
            self addMenu(menu, "Shadows Of Evil Scripts");
                self addOptBool((isDefined(self.beastmode) && self.beastmode), "Beast Mode", ::PlayerEnterBeastMode);
                self addOptBool(self clientfield::get_to_player("pod_sprayer_held"), "Fumigator", ::SOEGrabFumigator);
                self addOpt("Smashables", ::newMenu, "SOE Smashables");
                self addOpt("Power Switches", ::newMenu, "SOE Power Switches");
                self addOpt("Show Symbol Code", ::SOEShowCode);
            break;
        
        case "SOE Smashables":
            self addMenu(menu, "Smashables");

                if(SOESmashablesRemaining())
                {
                    foreach(smashable in GetEntArray("beast_melee_only", "script_noteworthy"))
                    {
                        target = GetEnt(smashable.target, "targetname");

                        if(!isDefined(target))
                            continue;
                        
                        self addOpt(ReturnSOESmashableName(CleanString(smashable.targetname)), ::TriggerSOESmashable, smashable);
                    }
                }
                else
                    self addOpt("No Smashables Found");
            break;
        
        case "SOE Power Switches":
            self addMenu(menu, "Power Switches");

                if(SOEPowerSwitchesRemaining())
                {
                    foreach(ooze in GetEntArray("ooze_only", "script_noteworthy"))
                    {
                        if(IsSubStr(ooze.targetname, "keeper_sword") || IsSubStr(ooze.targetname, "ee_district_rail"))
                            continue;
                        
                        self addOpt(ReturnSOEPowerName(ooze.script_int), ::TriggerSOEESwitch, ooze);
                    }
                }
                else
                    self addOpt("No Power Switches Found");
            break;
        
        case "Revelations Scripts":
            self addMenu(menu, "Revelations Scripts");
                self addOptBool(level flag::get("character_stones_done"), "Damage Tombstones", ::DamageGraveStones);
            break;
        
        case "Server Modifications":
            self addMenu(menu, "Server Modifications");
                self addOptBool(level.SuperJump, "Super Jump", ::SuperJump);
                self addOptBool((GetDvarInt("bg_gravity") == 200), "Low Gravity", ::LowGravity);
                self addOptBool((GetDvarString("g_speed") == "500"), "Super Speed", ::SuperSpeed);
                self addOptIncSlider("Timescale", ::ServerSetTimeScale, 0.1, GetDvarInt("timescale"), 5, 0.1);
                self addOpt("Set Round", ::NumberPad, "Set Round", ::SetRound);
                self addOptBool(level.AntiQuit, "Anti-Quit", ::AntiQuit);
                self addOptBool(level.AntiJoin, "Anti-Join", ::AntiJoin);
                self addOptBool(level.AntiEndGame, "Anti-End Game", ::AntiEndGame);
                self addOptBool(level.AutoRevive, "Auto-Revive", ::AutoRevive);
                self addOptBool(level.AutoRespawn, "Auto-Respawn", ::AutoRespawn);
                self addOpt("Auto-Verification", ::newMenu, "Auto-Verification");
                self addOptBool(level.ServerPauseWorld, "Pause World", ::ServerPauseWorld);
                self addOpt("Doheart Options", ::newMenu, "Doheart Options");
                self addOpt("Lobby Timer Options", ::newMenu, "Lobby Timer Options");
                self addOptBool(IsAllDoorsOpen(), "Open All Doors & Debris", ::OpenAllDoors);
                self addOptSlider("Zombie Barriers", ::SetZombieBarrierState, "Break All;Repair All");
                self addOpt("Spawn Bot", ::SpawnBot);

                if(isDefined(level.zombie_include_craftables) && level.zombie_include_craftables.size && !isDefined(level.all_parts_required))
                {
                    if(level.zombie_include_craftables.size > 1 || level.zombie_include_craftables.size && GetArrayKeys(level.zombie_include_craftables)[0] != "open_table")
                        self addOpt("Craftables", ::newMenu, "Zombie Craftables");
                }

                if(isDefined(level.MenuZombieTraps) && level.MenuZombieTraps.size)
                    self addOpt("Zombie Traps", ::newMenu, "Zombie Traps");
                
                self addOpt("Mystery Box Options", ::newMenu, "Mystery Box Options");
                self addOpt("Server Tweakables", ::newMenu, "Server Tweakables");
                self addOpt("Change Map", ::newMenu, "Change Map");
                self addOpt("Restart Game", ::ServerRestartGame);
                self addOpt("End Game", ::ServerEndGame);
            break;
        
        case "Auto-Verification":
            self addMenu(menu, "Auto-Verification");

                for(a = 0; a < (level.MenuStatus.size - 2); a++)
                    self addOptBool((level.AutoVerify == a), level.MenuStatus[a], ::SetAutoVerification, a);
            break;
        
        case "Doheart Options":
            if(!isDefined(level.DoheartStyle))
                level.DoheartStyle = "Pulsing";
            
            if(!isDefined(level.DoheartSavedText))
                level.DoheartSavedText = CleanName(bot::get_host_player() getName());
            
            self addMenu(menu, "Doheart Options");
                self addOptBool(level.Doheart, "Doheart", ::Doheart);
                self addOptSlider("Text", ::DoheartTextPass, CleanName(bot::get_host_player() getName()) + ";" + level.menuName + ";CF4_99;Discord.gg/MXT;Custom");
                self addOptSlider("Style", ::SetDoheartStyle, "Pulsing;Pulse Effect;Type Writer;Moving;Fade Effect");
            break;
        
        case "Lobby Timer Options":
            if(!isDefined(level.LobbyTime))
                level.LobbyTime = 10;
            
            self addMenu(menu, "Lobby Timer Options");
                self addOptBool(level.LobbyTimer, "Lobby Timer", ::LobbyTimer);
                self addOptIncSlider("Set Lobby Timer", ::SetLobbyTimer, 1, 10, 30, 1);
            break;
        
        case "Zombie Craftables":
            found = 0;
            craftables = GetArrayKeys(level.zombie_include_craftables);

            self addMenu(menu, "Craftables");

                for(a = 0; a < craftables.size; a++)
                {
                    if(IsCraftableCollected(craftables[a]) || craftables[a] == "open_table" || IsSubStr(craftables[a], "ritual_"))
                        continue;

                    found++;
                    
                    self addOpt(CleanString(craftables[a]), ::newMenu, craftables[a]);
                }

                if(!found)
                    self addOpt("No Craftables Found");
            break;
        
        case "Zombie Traps":
            self addMenu(menu, "Zombie Traps");

                if(isDefined(level.MenuZombieTraps) && level.MenuZombieTraps.size)
                {
                    self addOpt("Activate All Traps", ::ActivateAllZombieTraps);

                    for(a = 0; a < level.MenuZombieTraps.size; a++)
                        if(isDefined(level.MenuZombieTraps[a]))
                            self addOpt(isDefined(level.MenuZombieTraps[a].prefabname) ? CleanString(level.MenuZombieTraps[a].prefabname) : "Trap " + (a + 1), ::ActivateZombieTrap, a);
                }
                else
                    self addOpt("No Traps Found");
            break;
        
        case "Mystery Box Options":
            self addMenu(menu, "Mystery Box Options");
                self addOptBool(level.chests[level.chest_index].old_cost != 950, "Custom Price", ::NumberPad, "Mystery Box Price", ::SetBoxPrice);
                self addOptBool(AllBoxesActive(), "Show All", ::ShowAllChests);
                self addOpt("Force Joker", ::BoxForceJoker);
                self addOptBool((GetDvarString("magic_chest_movable") == "0"), "Never Moves", ::BoxNeverMoves);
                self addOpt("Weapons", ::newMenu, "Mystery Box Weapons");
                self addOpt("Joker Model", ::newMenu, "Joker Model");
            break;
        
        case "Mystery Box Weapons":
            self addMenu(menu, "Weapons");
                self addOpt("Normal", ::newMenu, "Mystery Box Normal Weapons");
                self addOpt("Upgraded", ::newMenu, "Mystery Box Upgraded Weapons");
            break;
        
        case "Joker Model":
            self addMenu(menu, "Joker Model");
                self addOptBool((level.chest_joker_model == level.savedJokerModel), "Default", ::SetBoxJokerModel, level.savedJokerModel);

                if(isDefined(level.MenuModels) && level.MenuModels.size)
                    for(a = 0; a < level.MenuModels.size; a++)
                        self addOptBool((level.chest_joker_model == level.MenuModels[a]), CleanString(level.MenuModels[a]), ::SetBoxJokerModel, level.MenuModels[a]);
                else
                    self addOpt("No Models Found");
            break;
        
        case "Server Tweakables":
            self addMenu(menu, "Server Tweakables");
                self addOptBool(level.ServerMaxAmmoClips, "Max Ammo Powerups Fill Clips", ::ServerMaxAmmoClips);
                self addOptBool(level.ShootToRevive, "Shoot To Revive", ::ShootToRevive);
                self addOptIncSlider("Pack 'a' Punch Camo Index", ::SetPackCamoIndex, 0, level.pack_a_punch_camo_index, 138, 1);
                self addOptIncSlider("Player Weapon Limit", ::SetPlayerWeaponLimit, 0, 0, 15, 1);
                self addOptIncSlider("Player Perk Limit", ::SetPlayerPerkLimit, 0, 0, level.MenuPerks.size, 1);
                self addOptBool(level.IncreasedDropRate, "Increased Power-Up Drop Rate", ::IncreasedDropRate);
                self addOptBool(level.PowerupsNeverLeave, "Power-Ups Never Leave", ::PowerupsNeverLeave);
                self addOptBool(level.DisablePowerups, "Disable Power-Ups", ::DisablePowerups);
                self addOptBool(level.headshots_only, "Headshots Only", ::headshots_only);
                self addOptIncSlider("Clip Size Multiplier", ::ServerSetClipSizeMultiplier, 1, 1, 10, 1);
                self addOpt("Pack 'a' Punch Price", ::NumberPad, "Pack 'a' Punch Price", ::EditPackAPunchPrice);
                self addOpt("Repack 'a' Punch Price", ::NumberPad, "Repack 'a' Punch Price", ::EditRepackAPunchPrice);
            break;
        
        case "Change Map":
            self addMenu(menu, "Change Map");

                for(a = 0; a < level.mapNames.size; a++)
                    self addOptBool((level.script == level.mapNames[a]), ReturnMapName(level.mapNames[a]), ::ServerChangeMap, level.mapNames[a]);
            break;
        
        case "Zombie Options":
            self addMenu(menu, "Zombie Options");
                self addOpt("Spawner", ::newMenu, "AI Spawner");
                self addOpt("Prioritize Players", ::newMenu, "Prioritize Players");
                self addOptSlider("Kill", ::KillZombies, "Death;Head Gib;Flame;Delete");
                self addOptSlider("Teleport", ::TeleportZombies, "Crosshairs;Self");
                self addOptBool(level.ZombiesToCrosshairsLoop, "Teleport To Crosshairs", ::ZombiesToCrosshairsLoop);
                self addOptSlider("Health", ::SetZombieHealth, "Custom;Reset");
                self addOpt("Model", ::newMenu, "Zombie Model Manipulation");
                self addOpt("Animations", ::newMenu, "Zombie Animations");
                self addOptBool((GetDvarString("ai_disableSpawn") == "1"), "Disable Spawning", ::DisableZombieSpawning);
                self addOptBool(level.DisableZombieCollision, "Disable Collision", ::DisableZombieCollision);
                self addOptBool(level.DisableZombiePush, "Disable Push", ::DisableZombiePush);
                self addOptBool(level.ZombiesInvisibility, "Invisibility", ::ZombiesInvisibility);
                self addOptBool((GetDvarString("g_ai") == "0"), "Freeze", ::FreezeZombies);
                self addOptSlider("Movement", ::SetZombieRunSpeed, "Walk;Run;Sprint;Super Sprint");
                self addOptIncSlider("Animation Speed", ::SetZombieAnimationSpeed, 1, 1, 2, 0.1);
                self addOpt("Make Crawlers", ::ForceZombieCrawlers);
                self addOptSlider("Gib Bone", ::ZombieGibBone, "Random;Head;Right Leg;Left Leg;Right Arm;Left Arm");
                self addOptBool(level.DisappearingZombies, "Disappearing Zombies", ::DisappearingZombies);
                self addOptBool(level.ExplodingZombies, "Exploding Zombies", ::ExplodingZombies);
                self addOptBool(level.ZombieRagdoll, "Zombie Ragdoll", ::ZombieRagdoll);
                self addOptBool(level.StackZombies, "Stack Zombies", ::StackZombies);
                self addOpt("Zombie Effects", ::newMenu, "Zombie Effects");
                self addOpt("Detach Heads", ::DetachZombieHeads);
                self addOpt("Clear All Corpses", ::ServerClearCorpses);
            break;
        
        case "AI Spawner":
            if(!isDefined(self.AISpawnLocation))
                self.AISpawnLocation = "Crosshairs";
            
            map = ReturnMapName(level.script);
            
            self addMenu(menu, "Spawner");
                self addOptSlider("Spawn Location", ::AISpawnLocation, "Crosshairs;Random;Self");
                self addOptIncSlider("Spawn Zombie", ::ServerSpawnAI, 1, 1, 10, 1, ::ServerSpawnZombie);

                if(map != "Unknown")
                {
                    maps = ["Shi No Numa", "The Giant", "Moon", "Kino Der Toten", "Der Eisendrache"];

                    if(isInArray(maps, map))
                        self addOptIncSlider("Spawn Hellhound", ::ServerSpawnAI, 1, 1, 10, 1, ::ServerSpawnDog);
                    
                    
                    maps = ["Shadows Of Evil", "Revelations", "Gorod Krovi"];

                    if(isInArray(maps, map))
                    {
                        if(map != "Gorod Krovi")
                        {
                            self addOptIncSlider("Spawn Wasp", ::ServerSpawnAI, 1, 1, 10, 1, ::ServerSpawnWasp);
                            self addOptIncSlider("Spawn Margwa", ::ServerSpawnAI, 1, 1, 10, 1, ::ServerSpawnMargwa);

                            if(map == "Shadows Of Evil")
                                self addOptIncSlider("Spawn Civil Protector", ::ServerSpawnAI, 1, 1, 10, 1, ::ServerSpawnCivilProtector);
                        }
                        
                        if(map != "Revelations")
                            self addOptIncSlider("Spawn Raps", ::ServerSpawnAI, 1, 1, 10, 1, ::ServerSpawnRaps);
                    }


                    maps = ["Origins", "Der Eisendrache", "Revelations"];

                    if(isInArray(maps, map))
                        self addOptIncSlider("Spawn Mechz", ::ServerSpawnAI, 1, 1, 10, 1, ::ServerSpawnMechz);
                    
                    if(map == "Gorod Krovi")
                    {
                        self addOptIncSlider("Spawn Sentinel Drone", ::ServerSpawnAI, 1, 1, 10, 1, ::ServerSpawnSentinelDrone);
                        self addOptIncSlider("Spawn Mangler", ::ServerSpawnAI, 1, 1, 10, 1, ::ServerSpawnMangler);
                    }

                    if(map == "Zetsubou No Shima" || map == "Revelations")
                    {
                        if(map == "Zetsubou No Shima")
                            self addOptIncSlider("Spawn Thrasher", ::ServerSpawnAI, 1, 1, 10, 1, ::ServerSpawnThrasher);
                        
                        self addOptIncSlider("Spawn Spider", ::ServerSpawnAI, 1, 1, 10, 1, ::ServerSpawnSpider);
                    }

                    if(map == "Revelations")
                        self addOptIncSlider("Spawn Fury", ::ServerSpawnAI, 1, 1, 10, 1, ::ServerSpawnFury);
                    
                    if(map == "Kino Der Toten")
                        self addOptIncSlider("Spawn Nova Zombie", ::ServerSpawnAI, 1, 1, 10, 1, ::ServerSpawnNovaZombie);
                }
            break;
        
        case "Prioritize Players":
            self addMenu(menu, "Prioritize Players");
                foreach(player in level.players)
                    self addOptBool(player.AIPrioritizePlayer, CleanName(player getName()), ::AIPrioritizePlayer, player);
            break;
        
        case "Zombie Model Manipulation":
            self addMenu(menu, "Model Manipulation");
                self addOptBool(!isDefined(level.ZombieModel), "Disable", ::DisableZombieModel);
                self addOpt("");

                if(isDefined(level.MenuModels) && level.MenuModels.size)
                    for(a = 0; a < level.MenuModels.size; a++)
                        self addOptBool(level.ZombieModel == level.MenuModels[a], CleanString(level.MenuModels[a]), ::SetZombieModel, level.MenuModels[a]);
                else
                    self addOpt("No Models Found");
            break;
        
        case "Zombie Animations":

            //These are base animations that will work on every map
            anims = ["ai_zombie_base_ad_attack_v1", "ai_zombie_base_ad_attack_v2", "ai_zombie_base_ad_attack_v3", "ai_zombie_base_ad_attack_v4", "ai_zombie_taunts_4"];
            notifies = ["attack_anim", "attack_anim", "attack_anim", "attack_anim", "taunt_anim"];

            //These are the animations that are map specific
            if(ReturnMapName(level.script) == "Origins")
            {
                add_anims = ["ai_zombie_mech_ft_burn_player", "ai_zombie_mech_exit", "ai_zombie_mech_exit_hover", "ai_zombie_mech_arrive"];
                add_notifies = ["flamethrower_anim", "zm_fly_out", "zm_fly_hover_finished", "zm_fly_in"];
            }
            
            if(isDefined(add_anims) && add_anims.size)
            {
                anims = ArrayCombine(anims, add_anims, 0, 1);
                notifies = ArrayCombine(notifies, add_notifies, 0, 1);
            }

            self addMenu(menu, "Animations");
                for(a = 0; a < anims.size; a++)
                    self addOpt(CleanString(anims[a]), ::ZombieAnimScript, anims[a], notifies[a]);
            break;
        
        case "Zombie Effects":
            self addMenu(menu, "Zombie Effects");
                self addOpt("Death Effect", ::newMenu, "Zombie Death Effect");
                self addOpt("Damage Effect", ::newMenu, "Zombie Damage Effect");
            break;
        
        case "Zombie Death Effect":
            fxs = GetArrayKeys(level._effect);

            if(!isDefined(level.ZombiesDeathFX))
                level.ZombiesDeathFX = fxs[0];
            
            self addMenu(menu, "Death Effect");
                self addOptBool(level.ZombiesDeathEffect, "Death Effect", ::ZombiesDeathEffect);
                self addOpt("");

                if(isDefined(fxs) && fxs.size)
                    for(a = 0; a < fxs.size; a++)
                        self addOptBool((level.ZombiesDeathFX == fxs[a]), CleanString(fxs[a]), ::SetZombiesDeathEffect, fxs[a]);
            break;

        case "Zombie Damage Effect":
            fxs = GetArrayKeys(level._effect);

            if(!isDefined(level.ZombiesDamageFX))
                level.ZombiesDamageFX = fxs[0];
            
            self addMenu(menu, "Damage Effect");
                self addOptBool(level.ZombiesDamageEffect, "Damage Effect", ::ZombiesDamageEffect);
                self addOpt("");

                if(isDefined(fxs) && fxs.size)
                    for(a = 0; a < fxs.size; a++)
                        self addOptBool((level.ZombiesDamageFX == fxs[a]), CleanString(fxs[a]), ::SetZombiesDamageEffect, fxs[a]);
            break;
        
        case "Spawnables":
            self addMenu(menu, "Spawnables");
                self addOptSlider("Drop Tower", ::SpawnSystem, "Spawn;Dismantle;Delete", "Drop Tower", ::SpawnDropTower);
                self addOptSlider("Merry Go Round", ::SpawnSystem, "Spawn;Dismantle;Delete", "Merry Go Round", ::SpawnMerryGoRound);
                self addOptIncSlider("Merry Go Round Speed", ::SetMerryGoRoundSpeed, 1, 1, 10, 1);
            break;
        
        case "Host Menu":
            self addMenu(menu, "Host Menu");
                self addOpt("Disconnect", ::disconnect);
                self addOptBool((GetDvarInt("migration_forceHost") == 1), "Force Host", ::ForceHost);
                self addOptBool(level.GEntityProtection, "G_Entity Crash Protection", ::GEntityProtection);
                self addOpt("Custom Map Spawns", ::newMenu, "Custom Map Spawns");
                self addOptBool((GetDvarString("ui_lobbyDebugVis") == "1"), "DevGui Info", ::DevGUIInfo);
                self addOptBool((GetDvarString("r_fog") == "0"), "Disable Fog", ::DisableFog);
            break;
        
        case "Custom Map Spawns":
            self addMenu(menu, "Custom Map Spawns");
                self addOptSlider("Set Map Spawn Location", ::SetMapSpawn, "Player 1;Player 2;Player 3;Player 4", "Set");
                self addOptSlider("Clear Map Spawn Location", ::SetMapSpawn, "Player 1;Player 2;Player 3;Player 4", "Clear");
            break;
        
        case "All Players":
            self addMenu(menu, "All Players");
                self addOpt("Verification", ::newMenu, "All Players Verification");
                self addOptSlider("Teleport", ::AllPlayersTeleport, "Self;Crosshairs;Sky");
                self addOpt("Profile Management", ::newMenu, "All Players Profile Management");
                self addOpt("Model Manipulation", ::newMenu, "All Players Model Manipulation");
                self addOpt("Malicious Options", ::newMenu, "All Players Malicious Options");
                self addOpt("Send Message", ::Keyboard, "Send Message To All Players", ::MessageAllPLayers);
                self addOpt("Temp Ban", ::AllPlayersFunction, ::BanPlayer);
                self addOpt("Kick", ::AllPlayersFunction, ::KickPlayer);
                self addOpt("Down", ::AllPlayersFunction, ::PlayerDeath, "Down");
                self addOpt("Revive", ::AllPlayersFunction, ::PlayerRevive);
                self addOpt("Respawn", ::AllPlayersFunction, ::ServerRespawnPlayer);
            break;
        
        case "All Players Verification":
            self addMenu(menu, "Verification");

                for(a = 0; a < (level.MenuStatus.size - 2); a++)
                    self addOpt(level.MenuStatus[a], ::SetVerificationAllPlayers, a, true);
            break;
        
        case "All Players Profile Management":
            self addMenu(menu, "Profile Management");
                self addOpt("Unlock All Achievements", ::AllPlayersFunction, ::UnlockAchievements);
                self addOpt("Complete Daily Challenges", ::AllPlayersFunction, ::CompleteDailyChallenges);
            break;
        
        case "All Players Model Manipulation":
            self addMenu(menu, "Model Manipulation");
                self addOpt("Reset Player Model", ::AllPlayersFunction, ::ResetPlayerModel);
                self addOpt("");

                if(isDefined(level.MenuModels) && level.MenuModels.size)
                    for(a = 0; a < level.MenuModels.size; a++)
                        self addOpt(CleanString(level.MenuModels[a]), ::AllPlayersFunction, ::SetPlayerModel, level.MenuModels[a]);
                else
                    self addOpt("No Models Found");
            break;
        
        case "All Players Malicious Options":
            self addMenu(menu, "Malicious Options");
                self addOpt("Launch", ::AllPlayersFunction, ::LaunchPlayer);
                self addOpt("Mortar Strike", ::AllPlayersFunction, ::MortarStrikePlayer);
                self addOpt("Fake Derank", ::AllPlayersFunction, ::FakeDerank);
                self addOpt("Fake Damage", ::AllPlayersFunction, ::FakeDamagePlayer);
                self addOpt("Crash Game", ::AllPlayersFunction, ::CrashPlayer);
            break;
        
        case "Players":
            self addMenu(menu, "Players");

                foreach(player in level.players)
                {
                    if(!isDefined(player.menuState["verification"])) //If A Player Doesn't Have A Verification Set, They Won't Show. Mainly Happens If They Are Still Connecting
                        player.menuState["verification"] = level.MenuStatus[level.AutoVerify];
                    
                    self addOpt("[^2" + player.menuState["verification"] + "^7]" + CleanName(player getName()), ::newMenu, "Options " + player GetEntityNumber());
                }
            break;
        
        default:
            foundplayer = false;

            foreach(player in level.players)
            {
                sepmenu = StrTok(menu, " ");

                if(Int(sepmenu[(sepmenu.size - 1)]) == player GetEntityNumber())
                {
                    foundplayer = true;
                    self MenuOptionsPlayer(menu, player);
                }
            }
            
            if(!foundplayer)
            {
                self addMenu(menu, "404 ERROR");
                    self addOpt("Page Not Found");
            }

            break;
    }
}

MenuOptionsPlayer(menu, player)
{
    self endon("disconnect");
    
    newmenu = CleanMenuName(menu);
    
    weapons = ["Assault Rifles", "Sub Machine Guns", "Light Machine Guns", "Sniper Rifles", "Shotguns", "Pistols", "Launchers", "Specials"];
    weaponsVar = ["assault", "smg", "lmg", "sniper", "cqb", "pistol", "launcher", "special"];
    weaponAttachTypes = ["Optic", "Rig", "Mod"]; //gamedata\weapons\common\attachmenttable.csv
    craftables = GetArrayKeys(level.zombie_include_craftables);
    mapStr = ReturnMapName(level.script);
    
    switch(newmenu)
    {
        case "Basic Scripts":
            self addMenu(menu, "Basic Scripts");
                self addOptBool(player.godmode, "God Mode", ::Godmode, player);
                self addOptBool(player.DemiGod, "Demi-God", ::DemiGod, player);
                self addOptBool(player.Noclip, "Noclip", ::Noclip1, player);
                self addOptBool(player.NoclipBind, "Bind Noclip To [{+frag}]", ::BindNoclip, player);
                self addOptBool(player.UFOMode, "UFO Mode", ::UFOMode, player);
                self addOptSlider("Unlimited Ammo", ::UnlimitedAmmo, "Continuous;Reload;Disable", player);
                self addOptBool(player.UnlimitedEquipment, "Unlimited Equipment", ::UnlimitedEquipment, player);
                self addOptSlider("Modify Score", ::ModifyScore, "1000000;100000;10000;1000;100;10;0;-10;-100;-1000;-10000;-100000;-1000000", player);
                self addOpt("Perk Menu", ::newMenu, "Perk Menu " + player GetEntityNumber());
                self addOpt("Gobblegum Menu", ::newMenu, "Gobblegum Menu " + player GetEntityNumber());
                self addOptBool(player.ThirdPerson, "Third Person", ::ThirdPerson, player);
                self addOptIncSlider("Movement Speed", ::SetMovementSpeed, 0, 1, 3, 0.1, player);
                self addOptSlider("Clone", ::PlayerClone, "Clone;Dead", player);
                self addOptBool(player.Invisibility, "Invisibility", ::Invisibility, player);
                self addOptBool(player.SaveAndLoad, "Save & Load Position", ::SaveAndLoad, player);
                self addOptBool(player.NoTarget, "No Target", ::NoTarget, player);
                self addOptBool(player.ReducedSpread, "Reduced Spread", ::ReducedSpread, player);
                self addOptBool(player.MultiJump, "Multi-Jump", ::MultiJump, player);
                self addOptSlider("Set Vision", ::PlayerSetVision, "Default;" + level.menuVisions, player);
                self addOpt("Visual Effects", ::newMenu, "Visual Effects " + player GetEntityNumber());
                self addOptSlider("Zombie Charms", ::ZombieCharms, "None;Orange;Green;Purple;Blue", player);
                self addOptBool(player.NoExplosiveDamage, "No Explosive Damage", ::NoExplosiveDamage, player);
                self addOptIncSlider("Character Model Index", ::SetCharacterModelIndex, 0, player.characterIndex, 8, 1, player);
                self addOptBool(player.LoopCharacterModelIndex, "Random Character Model Index", ::LoopCharacterModelIndex, player);
                self addOptBool(player.UnlimitedSprint, "Unlimited Sprint", ::UnlimitedSprint, player);
                self addOpt("Respawn", ::ServerRespawnPlayer, player);
                self addOpt("Revive", ::PlayerRevive, player);
                self addOptSlider("Death", ::PlayerDeath, "Down;Kill", player);
            break;
        
        case "Perk Menu":
            self addMenu(menu, "Perk Menu");
            
                if(isDefined(level.MenuPerks) && level.MenuPerks.size)
                {
                    self addOptBool((player.perks_active.size == level.MenuPerks.size), "All Perks", ::PlayerAllPerks, player);

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
            self addMenu(menu, "Gobblegum Menu");

                if(isDefined(level.MenuBGB) && level.MenuBGB.size)
                    for(a = 0; a < level.MenuBGB.size; a++)
                        self addOptBool((player.bgb == level.MenuBGB[a]), GobblegumName(level.MenuBGB[a]), ::GivePlayerGobblegum, level.MenuBGB[a], player);
            break;
        
        case "Visual Effects":

            if(!isDefined(player.ClientVisualEffect))
                player.ClientVisualEffect = "None";

            types = ["visionset", "overlay"];
            visuals = [];

            self addMenu(menu, "Visual Effects");

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
            self addMenu(menu, "Teleport Menu");
                self addOptBool(player.DisableTeleportEffect, "Disable Teleport Effect", ::DisableTeleportEffect, player);
                
                if(isDefined(level.MenuSpawnPoints) && level.MenuSpawnPoints.size)
                    self addOptIncSlider("Official Spawn Points", ::OfficialSpawnPoint, 0, 0, (level.MenuSpawnPoints.size - 1), 1, player);
                
                if(isDefined(level.menuTeleports) && isDefined(level.menuTeleports[mapStr]) && level.menuTeleports[mapStr].size)
                    self addOpt(mapStr + " Teleports", ::newMenu, mapStr + " Teleports " + player GetEntityNumber());
                
                self addOpt("Entity Teleports", ::newMenu, "Entity Teleports " + player GetEntityNumber());
                self addOptSlider("Teleport", ::TeleportPlayer, "Crosshairs;Sky", player);
                self addOptBool(player.TeleportGun, "Teleport Gun", ::TeleportGun, player);
                self addOpt("Save Current Location", ::SaveCurrentLocation, player);
                self addOpt("Load Saved Location", ::LoadSavedLocation, player);

                if(player != self)
                {
                    self addOpt("Teleport To Self", ::TeleportPlayer, self, player);
                    self addOpt("Teleport To Player", ::TeleportPlayer, player, self);
                }
            break;
        
        case "Entity Teleports":            
            self addMenu(menu, "Entity Teleports");

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
            self addMenu(menu, "Profile Management");
                self addOptBool(player.LiquidsLoop, "Liquid Divinium", ::LiquidsLoop, player);
                self addOptSlider("Challenges", ::AllChallenges, "Unlock;Lock", player);
                self addOpt("Complete Daily Challenges", ::CompleteDailyChallenges, player);
                self addOptSlider("Weapon Ranks", ::PlayerWeaponRanks, "Max;Reset", player);
                self addOptIncSlider("Rank", ::SetPlayerRank, (player.pers["plevel"] > 10) ? 36 : 1, (player.pers["plevel"] > 10) ? 36 : 1, (player.pers["plevel"] > 10) ? 1000 : 35, 1, player);
                self addOptIncSlider("Prestige", ::SetPlayerPrestige, 0, player.pers["plevel"], 10, 1, player);
                self addOpt("Unlock All Achievements", ::UnlockAchievements, player);
                self addOpt("Clan Tag Options", ::newMenu, "Clan Tag Options " + player GetEntityNumber());
                self addOpt("Custom Stats", ::newMenu, "Custom Stats " + player GetEntityNumber());
                self addOpt("EE Stats", ::newMenu, "EE Stats " + player GetEntityNumber());
            break;
        
        case "Clan Tag Options":
            self addMenu(menu, "Clan Tag Options");
                self addOpt("Reset", ::SetClanTag, "", player);
                self addOpt("Invisible Name", ::SetClanTag, "^Hä", player);
                self addOpt("@CF4", ::SetClanTag, "@CF4", player);
                self addOptSlider("Name Color", ::SetClanTag, "Black;Red;Green;Yellow;Blue;Cyan;Pink", player);
                self addOpt("Custom", ::Keyboard, "Custom Clan Tag", ::SetClanTag, player);
            break;
        
        case "Custom Stats":

            if(!isDefined(player.CustomStatsValue))
                player.CustomStatsValue = 0;
            
            if(!isDefined(player.CustomStatsArray))
                player.CustomStatsArray = [];
            
            self addMenu(menu, "Custom Stats");
                self addOpt("Custom Value: " + player.CustomStatsValue, ::NumberPad, "Custom Stats Value", ::CustomStatsValue, player);
                self addOpt("Send Selected Stats", ::SetCustomStats, player);
                self addOpt("");
                self addOpt("General", ::newMenu, "General Stats " + player GetEntityNumber());
                self addOpt("Gobblegum Uses", ::newMenu, "Gobblegum Stats " + player GetEntityNumber());
                self addOpt("Maps", ::newMenu, "Map Stats " + player GetEntityNumber());
            break;
        
        case "General Stats":
            stats = ["kills", "headshots", "downs", "total_downs", "deaths", "revives", "rounds", "total_rounds_survived", "total_points", "perks_drank", "bgbs_chewed", "grenade_kills", "doors_purchased", "use_magicbox", "use_pap", "power_turnedon", "buildables_built", "total_shots", "hits", "misses", "distance_traveled", "total_games_played", "time_played_total"];

            self addMenu(menu, "General");
                
                for(a = 0; a < stats.size; a++)
                    self addOptBool(isInArray(player.CustomStatsArray, stats[a]), CleanString(stats[a]), ::AddToCustomStats, stats[a], player);
            break;
        
        case "Gobblegum Stats":
            self addMenu(menu, "Gobblegum Uses");
                self addOptBool(player IsAllBGBStatsEnabled(), "Enable All", ::AllBGBStats, player);
                self addOpt("");

                if(isDefined(level.MenuBGB) && level.MenuBGB.size)
                    for(a = 0; a < level.MenuBGB.size; a++)
                        self addOptBool(isInArray(player.CustomStatsArray, level.MenuBGB[a]), GobblegumName(level.MenuBGB[a]), ::AddToCustomStats, level.MenuBGB[a], player);
            break;
        
        case "Map Stats":
            self addMenu(menu, "Map Stats");

                for(a = 0; a < level.mapNames.size; a++)
                    self addOpt(ReturnMapName(level.mapNames[a]), ::newMenu, "Map Stats " + level.mapNames[a] + " " + player GetEntityNumber());
            break;
        
        case "EE Stats":
            stats = ["DARKOPS_ZOD_EE", "DARKOPS_FACTORY_EE", "DARKOPS_CASTLE_EE", "DARKOPS_ISLAND_EE", "DARKOPS_STALINGRAD_EE", "DARKOPS_GENESIS_EE", "DARKOPS_ZOD_SUPER_EE", "DARKOPS_FACTORY_SUPER_EE", "DARKOPS_CASTLE_SUPER_EE", "DARKOPS_ISLAND_SUPER_EE", "DARKOPS_STALINGRAD_SUPER_EE", "DARKOPS_GENESIS_SUPER_EE"];

            self addMenu(menu, "EE Stats");

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
            self addMenu(menu, "Weaponry");
                self addOpt("Weapon Options", ::newMenu, "Weapon Options " + player GetEntityNumber());
                self addOpt("Attachments", ::newMenu, "Weapon Attachments " + player GetEntityNumber());
                self addOpt("Weapon AAT", ::newMenu, "Weapon AAT " + player GetEntityNumber());
                self addOpt("");
                self addOpt("Equipment", ::newMenu, "Equipment Menu " + player GetEntityNumber());

                for(a = 0; a < weapons.size; a++)
                    self addOpt(weapons[a], ::newMenu, weapons[a] + " " + player GetEntityNumber());
            break;
        
        case "Weapon Options":
            self addMenu(menu, "Weapon Options");
                self addOpt("Take Current Weapon", ::TakeCurrentWeapon, player);
                self addOpt("Take All Weapons", ::TakePlayerWeapons, player);
                self addOptSlider("Drop Current Weapon", ::DropCurrentWeapon, "Take;Don't Take", player);
                self addOpt("");
                self addOptIncSlider("Camo", ::SetPlayerCamo, 0, 0, 138, 1, player);
                self addOptBool(player.FlashingCamo, "Flashing Camo", ::FlashingCamo, player);
                self addOptBool(player zm_weapons::is_weapon_upgraded(player GetCurrentWeapon()), "Pack 'a' Punch Current Weapon", ::PackCurrentWeapon, player);
            break;
        
        case "Weapon Attachments":
            self addMenu(menu, "Attachments");
                self addOptBool(player.CorrectInvalidCombo, "Correct Invalid Combinations", ::CorrectInvalidCombo, player);
                
                for(a = 0; a < weaponAttachTypes.size; a++)
                    self addOpt(weaponAttachTypes[a], ::newMenu, weaponAttachTypes[a] + " " + player GetEntityNumber());
            break;
        
        case "Weapon AAT":
            keys = GetArrayKeys(level.aat);
            
            self addMenu(menu, "Weapon AAT");
                
                if(isDefined(keys) && keys.size)
                {
                    for(a = 0; a < keys.size; a++)
                    {
                        if(isDefined(keys[a]) && level.aat[keys[a]].name != "none")
                            self addOptBool((player.aat[player aat::get_nonalternate_weapon(player GetCurrentWeapon())] == keys[a]), CleanString(level.aat[keys[a]].name), ::GiveWeaponAAT, keys[a], player);
                    }
                }
                else
                    self addOpt("No AAT Found");
            break;
        
        case "Equipment Menu":
            include_equipment = GetArrayKeys(level.zombie_include_equipment);
            equipment = ArrayCombine(level.zombie_lethal_grenade_list, level.zombie_tactical_grenade_list, 0, 1);
            keys = GetArrayKeys(equipment);
            
            self addMenu(menu, "Equipment");

                if(isDefined(keys) && keys.size || isDefined(include_equipment) && include_equipment.size)
                {
                    foreach(index, weapon in GetArrayKeys(level.zombie_weapons))
                        if(isInArray(equipment, weapon) && !IsSubStr(weapon.name, "_upgraded"))
                            self addOptBool(player HasWeapon(weapon), weapon.displayname, ::GivePlayerEquipment, weapon, player);
                    
                    if(isDefined(include_equipment) && include_equipment.size)
                        foreach(weapon in include_equipment)
                            if(!IsSubStr(weapon.name, "_upgraded"))
                                self addOptBool(player HasWeapon(weapon), weapon.displayname, ::GivePlayerEquipment, weapon, player);
                }
                else
                    self addOpt("No Equipment Found");
            break;
        
        case "Bullet Menu":
            self addMenu(menu, "Bullet Menu");
                self addOpt("Weapon Projectiles", ::newMenu, "Weapon Projectiles " + player GetEntityNumber());
                self addOpt("Equipment", ::newMenu, "Equipment Bullets " + player GetEntityNumber());
                self addOpt("Effects", ::newMenu, "Bullet Effects " + player GetEntityNumber());
                self addOpt("Spawnables", ::newMenu, "Bullet Spawnables " + player GetEntityNumber());
                self addOpt("Explosive Bullets", ::newMenu, "Explosive Bullets " + player GetEntityNumber());
                self addOpt("Reset Bullets", ::ResetBullet, player);
            break;
        
        case "Weapon Projectiles":
            if(!isDefined(player.ProjectileMultiplier))
                player.ProjectileMultiplier = 1;
            
            if(!isDefined(player.ProjectileSpreadMultiplier))
                player.ProjectileSpreadMultiplier = 10;
            
            self addMenu(menu, "Weapon Projectiles");
                self addOpt("Weapon Projectile", ::newMenu, "Weapon Bullets " + player GetEntityNumber());
                self addOptIncSlider("Projectile Multiplier", ::ProjectileMultiplier, 1, 1, 5, 1, player);
                self addOptIncSlider("Spread Multiplier", ::ProjectileSpreadMultiplier, 1, 5, 50, 1, player);
            break;
        
        case "Weapon Bullets":
            self addMenu(menu, "Weapon Bullets");
                self addOpt("Normal", ::newMenu, "Normal Weapon Bullets " + player GetEntityNumber());
                self addOpt("Upgraded", ::newMenu, "Upgraded Weapon Bullets " + player GetEntityNumber());
            break;
        
        case "Normal Weapon Bullets":
            arr = [];
            weaps = GetArrayKeys(level.zombie_weapons);
            
            self addMenu(menu, "Normal Weapons");

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
            
            self addMenu(menu, "Upgraded Weapons");
            
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

            self addMenu(menu, "Equipment");

                if(isDefined(keys) && keys.size || isDefined(include_equipment) && include_equipment.size)
                {
                    foreach(index, weapon in GetArrayKeys(level.zombie_weapons))
                        if(isInArray(equipment, weapon) && !IsSubStr(weapon.name, "_upgraded"))
                            self addOpt(weapon.displayname, ::BulletProjectile, weapon, "Equipment", player);
                    

                    if(isDefined(include_equipment) && include_equipment.size)
                        foreach(weapon in include_equipment)
                            if(!IsSubStr(weapon.name, "_upgraded"))
                                self addOpt(weapon.displayname, ::BulletProjectile, weapon, "Equipment", player);
                }
                else
                    self addOpt("No Equipment Found");
            break;
        
        case "Bullet Effects":
            fxs = GetArrayKeys(level._effect);
            
            self addMenu(menu, "Bullet Effect");

                if(isDefined(fxs) && fxs.size)
                    for(a = 0; a < fxs.size; a++)
                        self addOpt(CleanString(fxs[a]), ::BulletProjectile, fxs[a], "Effect", player);
            break;
        
        case "Bullet Spawnables":
            self addMenu(menu, "Bullet Spawnables");

                if(isDefined(level.MenuModels) && level.MenuModels.size)
                    for(a = 0; a < level.MenuModels.size; a++)
                        self addOpt(CleanString(level.MenuModels[a]), ::BulletProjectile, level.MenuModels[a], "Spawnable", player);
                else
                    self addOpt("No Models Found");
            break;
        
        case "Explosive Bullets":
            if(!isDefined(player.ExplosiveBulletsRange))
                player.ExplosiveBulletsRange = 250;
            
            if(!isDefined(player.ExplosiveBulletsDamage))
                player.ExplosiveBulletsDamage = 100;
            
            self addMenu(menu, "Explosive Bullets");
                self addOptBool(player.ExplosiveBullets, "Explosive Bullets", ::ExplosiveBullets, player);
                self addOpt("Explosive Bullet Range: " + player.ExplosiveBulletsRange, ::NumberPad, "Explosive Bullet Range", ::ExplosiveBulletRange, player);
                self addOpt("Explosive Bullet Damage: " + player.ExplosiveBulletsDamage, ::NumberPad, "Explosive Bullet Damage", ::ExplosiveBulletDamage, player);
            break;
        
        case "Fun Scripts":
            if(!isDefined(player.ForceFieldSize))
                player.ForceFieldSize = 255;
            
            if(!isDefined(player.DamagePointsMultiplier))
                player.DamagePointsMultiplier = 1;
            
            self addMenu(menu, "Fun Scripts");
                self addOpt("Effects Man Options", ::newMenu, "Effects Man Options " + player GetEntityNumber());
                self addOptBool(player.ForceField, "Force Field", ::ForceField, player);
                self addOpt("Force Field Size: " + player.ForceFieldSize, ::NumberPad, "Force Field Size", ::ForceFieldSize, player);
                self addOptBool(player.Jetpack, "Jetpack", ::Jetpack, player);
                self addOptBool(player.ZombieCounter, "Zombie Counter", ::ZombieCounter, player);
                self addOptBool(player.LightProtector, "Light Protector", ::LightProtector, player);
                self addOptBool(player.SpecialMovements, "Special Movements", ::SpecialMovements, player);
                self addOptBool(player.SpecNade, "Spec-Nade", ::SpecNade, player);
                self addOptBool(player.NukeNades, "Nuke Nades", ::NukeNades, player);
                self addOptBool(player.ShootPowerUps, "Shoot Power-Ups", ::ShootPowerUps, player);
                self addOptBool(player.CodJumper, "Cod Jumper", ::CodJumper, player);
                self addOptBool(player.ClusterGrenades, "Cluster Grenades", ::ClusterGrenades, player);
                self addOptBool(player.UnlimitedSpecialist, "Unlimited Specialist", ::UnlimitedSpecialist, player);
                self addOptBool(player.RocketRiding, "Rocket Riding", ::RocketRiding, player);
                self addOptBool(player.GrapplingGun, "Grappling Gun", ::GrapplingGun, player);
                self addOptBool(player.GravityGun, "Gravity Gun", ::GravityGun, player);
                self addOptBool(player.DeleteGun, "Delete Gun", ::DeleteGun, player);
                self addOpt("Hit Markers", ::newMenu, "Hit Markers " + player GetEntityNumber());
                self addOptBool(player.PowerUpMagnet, "Power-Up Magnet", ::PowerUpMagnet, player);
                self addOptBool(player.PlayerInstaKill, "Insta-Kill", ::PlayerInstaKill, player);
                self addOptIncSlider("Points Multiplier", ::DamagePointsMultiplier, 1, 1, 10, 0.5, player);
            break;
        
        case "Effects Man Options":
            if(!isDefined(player.FXManTag))
                player.FXManTag = "j_head";
            
            fxs = GetArrayKeys(level._effect);
            
            self addMenu(menu, "Effects Man Options");
                self addOpt("Disable", ::DisableFXMan, player);
                self addOptSlider("Play FX On Tag", ::SetFXManTag, level.boneTags, player);
                self addOpt("");

                if(isDefined(fxs) && fxs.size)
                    for(a = 0; a < fxs.size; a++)
                        self addOpt(CleanString(fxs[a]), ::FXMan, level._effect[fxs[a]], player);
            break;
        
        case "Hit Markers":
            if(!isDefined(player.HitmarkerFeedback))
                player.HitmarkerFeedback = "damage_feedback_glow_orange";
            
            if(!isDefined(self.HitMarkerColor))
                self.HitMarkerColor = (1, 1, 1);
            
            self addMenu(menu, "Hit Markers");
                self addOptBool(player.ShowHitmarkers, "Hit Markers", ::ShowHitmarkers, player);
                self addOptSlider("Feedback", ::HitmarkerFeedback, "damage_feedback_glow_orange;damage_feedback;damage_feedback_flak;damage_feedback_tac;damage_feedback_armor", player);
                self addOpt("");

                for(a = 0; a < level.colorNames.size; a++)
                    self addOptBool((self.HitMarkerColor == divideColor(level.colors[(3 * a)], level.colors[((3 * a) + 1)], level.colors[((3 * a) + 2)])), level.colorNames[a], ::HitMarkerColor, divideColor(level.colors[(3 * a)], level.colors[((3 * a) + 1)], level.colors[((3 * a) + 2)]), player);
                
                self addOptBool((self.HitMarkerColor == "Rainbow"), "Smooth Rainbow", ::HitMarkerColor, "Rainbow", player);
            break;
        
        case "Model Manipulation":            
            self addMenu(menu, "Model Manipulation");
                self addOptBool(player.ThirdPerson, "Third Person", ::ThirdPerson, player);
                self addOpt("Reset Player Model", ::ResetPlayerModel, player);
                self addOpt("");

                if(isDefined(level.MenuModels) && level.MenuModels.size)
                    for(a = 0; a < level.MenuModels.size; a++)
                        self addOpt(CleanString(level.MenuModels[a]), ::SetPlayerModel, player, level.MenuModels[a]);
                else
                    self addOpt("No Models Found");
            break;
        
        case "Aimbot Menu":
            if(!isDefined(player.AimbotType))
                player.AimbotType = "Snap";
            
            if(!isDefined(player.AimBoneTag))
                player.AimBoneTag = "j_head";
            
            if(!isDefined(player.AimbotKey))
                player.AimbotKey = "None";
            
            if(!isDefined(player.AimbotDistance))
                player.AimbotDistance = 100;
            
            self addMenu(menu, "Aimbot Menu");
                self addOptBool(player.Aimbot, "Aimbot", ::Aimbot, player);
                self addOptSlider("Type", ::AimbotType, "Snap;Silent", player);
                self addOptSlider("Tag", ::AimBoneTag, level.boneTags, player);
                self addOptSlider("Key", ::AimbotKey, "None;Aiming;Firing", player);
                self addOptBool(player.VisibilityCheck, "Damageable Only", ::AimbotOptions, 2, player);
                self addOptBool(player.PlayableAreaCheck, "In Playable Area", ::AimbotOptions, 3, player);
                self addOptBool(player.AutoFire, "Auto-Fire", ::AimbotOptions, 4, player);
                self addOptBool(player.AimbotDistanceCheck, "Distance", ::AimbotOptions, 5, player);

                if(isDefined(player.AimbotDistanceCheck))
                    self addOptIncSlider("Max Distance", ::AimbotDistance, 100, 100, 1000, 100, player);
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
            
            self addMenu(menu, "[^2" + player.menuState["verification"] + "^7]" + CleanName(player getName()));

                for(a = 0; a < submenus.size; a++)
                    self addOpt(submenus[a], ::newMenu, submenus[a] + " " + player GetEntityNumber());

                self addOpt("Send Message", ::Keyboard, "Send Message", ::MessagePlayer, player);
                self addOptBool(player.FreezePlayer, "Freeze", ::FreezePlayer, player);
                self addOpt("Kick", ::KickPlayer, player);
                self addOpt("Temp Ban", ::BanPlayer, player);
            break;
        
        case "Verification":
            self addMenu(menu, "Verification");
            
                for(a = 0; a < (level.MenuStatus.size - 2); a++)
                    self addOptBool((player getVerification() == a), level.MenuStatus[a], ::setVerification, a, player, true);
            break;
        
        case "Model Attachment":
            if(!isDefined(self.playerAttachBone))
                self.playerAttachBone = "j_head";
            
            self addMenu(menu, "Model Attachment");
                self addOptSlider("Location", ::PlayerAttachmentBone, level.boneTags);
                self addOpt("Detach All", ::PlayerDetachModels, player);
                self addOpt("");
                
                if(isDefined(level.MenuModels) && level.MenuModels.size)
                {
                    for(a = 0; a < level.MenuModels.size; a++)
                        if(level.MenuModels[a] != "defaultactor") //Attaching the defaultactor to a player can cause a crash.
                            self addOpt(CleanString(level.MenuModels[a]), ::PlayerModelAttachment, level.menuModels[a], player);
                }
                else
                    self addOpt("No Models Found");
            break;
        
        case "Malicious Options":
            if(!isDefined(player.ShellShockTime))
                player.ShellShockTime = 1;
            
            self addMenu(menu, "Malicious Options");
                self addOpt("Open Pause Menu", ::PlayerOpenPauseMenu, player);
                self addOpt("Disable Actions", ::newMenu, "Disable Actions " + player GetEntityNumber());
                self addOptSlider("Set Stance", ::SetPlayerStance, "Prone;Crouch;Stand", player);
                self addOpt("Launch", ::LaunchPlayer, player);
                self addOpt("Mortar Strike", ::MortarStrikePlayer, player);
                self addOptBool(player.FlashLoop, "Flash Loop", ::FlashLoop, player);
                self addOptSlider("Shellshock", ::ApplyShellShock, "Concussion Grenade;Zombie Death;Explosion", player);
                self addOptIncSlider("Shellshock Time", ::SetShellShockTime, 1, 1, 30, 1, player);
                self addOptBool(player.SpinPlayer, "Spin Player", ::SpinPlayer, player);
                self addOptBool(player.BlackScreen, "Black Screen", ::BlackScreenPlayer, player);
                self addOptBool(player.FakeLag, "Fake Lag", ::FakeLag, player);
                self addOptBool(self.AttachToPlayer, "Attach Self To Player", ::AttachSelfToPlayer, player);
                self addOptSlider("Mount Camera", ::PlayerMountCamera, "Disable;" + level.boneTags, player);
                self addOptBool(player.DropCamera, "Drop Camera", ::PlayerDropCamera, player);

                if(ReturnMapName(level.script) == "Shadows Of Evil" || ReturnMapName(level.script) == "Origins")
                    self addOpt("Jump Scare", ::JumpScarePlayer, player);
                
                self addOpt("Fake Derank", ::FakeDerank, player);
                self addOpt("Fake Damage", ::FakeDamagePlayer, player);
                self addOpt("Crash Game", ::CrashPlayer, player);
                self addOptSlider("Show IP", ::ShowPlayerIP, "Self;Player", player);
            break;
        
        case "Disable Actions":
            self addMenu(menu, "Disable Actions");
                self addOptBool(player.DisableAiming, "Disable Aiming", ::DisableAiming, player);
                self addOptBool(player.DisableJumping, "Disable Jumping", ::DisableJumping, player);
                self addOptBool(player.DisableSprinting, "Disable Sprinting", ::DisableSprinting, player);
                self addOptBool(player.DisableOffhands, "Disable Offhand Weapons", ::DisableOffhands, player);
                self addOptBool(player.DisableWeaps, "Disable Weapons", ::DisableWeaps, player);
            break;
        
        case "Map Challenges Player":
            self addMenu(menu, "Challenges");

                if(isDefined(player._challenges))
                {
                    self addOptBool(player flag::get("flag_player_completed_challenge_" + player._challenges.var_4687355c.n_index), player._challenges.var_4687355c.str_info, ::MapCompleteChallenge, player._challenges.var_4687355c, player);
                    self addOptBool(player flag::get("flag_player_completed_challenge_" + player._challenges.var_b88ea497.n_index), player._challenges.var_b88ea497.str_info, ::MapCompleteChallenge, player._challenges.var_b88ea497, player);
                    self addOptBool(player flag::get("flag_player_completed_challenge_" + player._challenges.var_928c2a2e.n_index), player._challenges.var_928c2a2e.str_info, ::MapCompleteChallenge, player._challenges.var_928c2a2e, player);
                }
                else
                    self addOpt("No Challenges Found");
            break;
        
        case "Origins Challenges Player":
            self addMenu(menu, "Challenges");

                foreach(challenge in level._challenges.a_stats)
                    self addOptBool(get_stat(challenge.str_name, player).b_medal_awarded, challenge.str_hint, ::CompleteOriginChallenge, challenge.str_name, player);
            break;
        
        default:
            if(isInArray(weapons, newmenu))
            {
                pistols = ["pistol_standard", "pistol_burst", "pistol_fullauto", "pistol_m1911", "pistol_revolver38", "pistol_c96"];
                specials = [];

                foreach(index, weapon_category in weapons)
                {
                    if(newmenu == weapon_category)
                    {
                        self addMenu(menu, weapon_category);
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
                    if(newmenu == "Specials")
                    {
                        if(weapon.isgrenadeweapon || weapon.name == "knife" || weapon.name == "none")
                            continue;
                        
                        string = weapon.name;

                        if(MakeLocalizedString(weapon.displayname) != "")
                            string = weapon.displayname;
                        
                        self addOptBool(player HasWeapon1(weapon), string, ::GivePlayerWeapon, weapon, player);
                    }
                }

                if(newmenu == "Specials")
                {
                    self addOptBool(player HasWeapon1(GetWeapon("minigun")), "Death Machine", ::GivePlayerWeapon, GetWeapon("minigun"), player);
                    self addOptBool(player HasWeapon1(GetWeapon("defaultweapon")), "Default Weapon", ::GivePlayerWeapon, GetWeapon("defaultweapon"), player);
                }
            }
            else if(isInArray(weaponAttachTypes, newmenu))
            {
                attachmentFound = 0;
                weapon = player GetCurrentWeapon();

                self addMenu(menu, newmenu);
                    for(a = 0; a < 44; a++)
                    {
                        type = ReturnAttachmentType(a);

                        if(type != ToLower(newmenu))
                            continue;
                        
                        attachment = ReturnAttachment(a);
                        name = ReturnAttachmentName(attachment);

                        if(!isInArray(weapon.supportedAttachments, attachment) || attachment == "dw")
                            continue;
                        
                        self addOptBool(isInArray(weapon.attachments, attachment), name, ::GivePlayerAttachment, attachment, player);

                        attachmentFound++;
                    }

                    if(!attachmentFound)
                        self addOpt("No Supported Attachments Found");
            }
            else if(newmenu == "Mystery Box Normal Weapons" || newmenu == "Mystery Box Upgraded Weapons")
            {
                arr = [];
                weaponsVar = ["assault", "smg", "lmg", "sniper", "cqb", "pistol", "launcher", "special"];
                type = (newmenu == "Mystery Box Normal Weapons") ? level.zombie_weapons : level.zombie_weapons_upgraded;
                weaps = GetArrayKeys(type);

                self addMenu(menu, newmenu);
                self addOptBool(IsAllWeaponsInBox(type), "Enable All", ::EnableAllWeaponsInBox, type);

                if(isDefined(weaps) && weaps.size)
                {
                    for(a = 0; a < weaps.size; a++)
                    {
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
                
                if(newmenu == "Mystery Box Normal Weapons")
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
            else if(isInArray(craftables, newmenu))
            {
                self addMenu(menu, CleanString(newmenu));

                    for(a = 0; a < craftables.size; a++)
                    {
                        if(craftables[a] != newmenu)
                            continue;
                        
                        parts = 0;
                        craftable = craftables[a];
                        
                        if(isDefined(craftable))
                        {
                            foreach(part in level.zombie_include_craftables[craftable].a_piecestubs)
                            {
                                if(IsPartCollected(part))
                                    continue;
                                
                                if(isDefined(part.pieceSpawn.model))
                                {
                                    self addOpt(CleanString(part.pieceSpawn.piecename), ::CollectCraftablePart, part);

                                    parts++;
                                }
                            }
                        }
                    }

                    if(!isDefined(craftable) || !parts)
                        self addOpt("No Parts Found");
            }
            else
            {
                error404 = true;

                for(a = 0; a < level.mapNames.size; a++)
                {
                    if(IsSubStr(newmenu, "Map Stats " + level.mapNames[a]) || newmenu == "Map Stats " + level.mapNames[a])
                    {
                        error404 = false;

                        mapStats = ["score", "total_games_played", "total_rounds_survived", "highest_round_reached", "time_played_total", "total_downs"];

                        self addMenu(menu, ReturnMapName(level.mapNames[a]));
                            for(b = 0; b < mapStats.size; b++)
                                self addOptBool(isInArray(player.CustomStatsArray, mapStats[b] + "_" + level.mapNames[a]), CleanString(mapStats[b]), ::AddToCustomStats, mapStats[b] + "_" + level.mapNames[a], player);
                    }
                }

                if(IsSubStr(newmenu, mapStr + " Teleports") || newmenu == mapStr + " Teleports")
                {
                    error404 = false;

                    self addMenu(menu, mapStr + " Teleports");
                        if(isDefined(level.menuTeleports) && isDefined(level.menuTeleports[mapStr]) && level.menuTeleports[mapStr].size)
                            for(a = 0; a < level.menuTeleports[mapStr].size; a += 2)
                                self addOpt(level.menuTeleports[mapStr][a], ::TeleportPlayer, level.menuTeleports[mapStr][(a + 1)], player);
                        else
                            self addOpt("No " + mapStr + " Teleports Found");
                }

                if(error404)
                {
                    self addMenu(menu, "404 ERROR");
                        self addOpt("Page Not Found");
                }
            }
            break;
    }
}
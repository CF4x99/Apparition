runMenuIndex(menu)
{
    self endon("disconnect");
    
    switch(menu)
    {
        case "Main":
            self addMenu(menu, (self.menu["MenuDesign"] == "Native") ? "Main Menu" : level.menuName);
            
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

                    if(self getVerification() > 2) //Co-Host
                    {
                        self addOpt("Advanced Scripts", ::newMenu, "Advanced Scripts");

                        if(ReturnMapName(level.script) != "Unknown")
                            self addOpt(ReturnMapName(level.script) + " Scripts", ::newMenu, ReturnMapName(level.script) + " Scripts");

                        self addOpt("Forge Options", ::newMenu, "Forge Options");
                        
                        if(self getVerification() > 3) //Admin
                        {
                            self addOpt("Entity Options", ::newMenu, "Entity Options");
                            self addOpt("Server Modifications", ::newMenu, "Server Modifications");
                            self addOpt("Zombie Options", ::newMenu, "Zombie Options");

                            if(self IsHost())
                                self addOpt("Host Menu", ::newMenu, "Host Menu");
                            
                            self addOpt("Players Menu", ::newMenu, "Players");
                            self addOpt("All Players Menu", ::newMenu, "All Players");
                        }
                    }
                }
            }
            break;
        
        case "Menu Customization":
            self addMenu(menu, "Menu Customization");
                self addOpt("Menu Credits", ::MenuCredits);
                self addOptSlider("Style", ::MenuDesign, level.menuName + ";Native;Old School");
                self addOpt("Design Preferences", ::newMenu, "Design Preferences");
                self addOpt("Main Design Color", ::newMenu, "Main Design Color");
            break;
        
        case "Design Preferences":
            self addMenu(menu, "Design Preferences");
                if(self.menu["MenuDesign"] != "Old School")
                {
                    self addOpt("Menu Position", ::newMenu, "Menu Position");
                    self addOpt("Menu Width", ::newMenu, "Menu Width");
                    self addOptSlider("Toggle Style", ::ToggleStyle, "Boxes;Text Color");
                    self addOptIncSlider("Max Options", ::MenuMaxOptions, 3, 9, 9, 2); //Do Not Change These Values.
                    self addOptBool(self.menu["DisableOptionCounter"], "Disable Option Counter", ::DisableOptionCounter);
                }

                self addOptBool(self.menu["MenuBlur"], "Menu Blur", ::MenuBlur);
                self addOptBool(self.menu["DisableMenuWM"], "Disable Watermark", ::DisableMenuWM);
                self addOptBool(self.menu["LargeCursor"], "Large Cursor", ::LargeCursor);
            break;
        
        case "Menu Position":
            self addMenu(menu, "Menu Position");
                self addOpt("Manually Control", ::MoveMenuControlled);
                self addOptIncSlider("Menu X", ::MoveMenu, -5, 1, 5, 2, "X");
                self addOptIncSlider("Menu Y", ::MoveMenu, -5, 1, 5, 2, "Y");
                self addOpt("Reset", ::ResetMenuPosition);
            break;
        
        case "Menu Width":
            self addMenu(menu, "Menu Width");
                self addOpt("Manually Control", ::MenuWidthControlled);
                self addOptIncSlider("Width", ::MenuWidth, -5, 1, 5, 2);
                self addOpt("Reset", ::ResetMenuWidth);
            break;
        
        case "Main Design Color":
            self addMenu(menu, "Main Design Color");

                for(a = 0; a < level.colorNames.size; a++)
                    self addOpt(level.colorNames[a], ::MenuTheme, divideColor(level.colors[(3 * a)], level.colors[((3 * a) + 1)], level.colors[((3 * a) + 2)]));
                
                self addOpt("Smooth Rainbow", ::SmoothRainbowTheme);
                self addOpt("Custom", ::newMenu, "Custom Menu Theme");
            break;
        
        case "Custom Menu Theme":
            self addMenu(menu, "Custom");
                self addOptIncSlider("Red", ::CustomMenuRGB, 0, (self.menu["Main_Color"][0] * 255), 255, 5, "R");
                self addOptIncSlider("Green", ::CustomMenuRGB, 0, (self.menu["Main_Color"][1] * 255), 255, 5, "G");
                self addOptIncSlider("Blue", ::CustomMenuRGB, 0, (self.menu["Main_Color"][2] * 255), 255, 5, "B");
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
                self addOpt("3D Drawing", ::newMenu, "3D Drawing Options");
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

                self addOpt("Controllable Zombie", ::ControllableZombie);
                self addOptBool(self.BodyGuard, "Body Guard", ::BodyGuard);
                self addOptIncSlider("Spiral Staircase", ::SpiralStaircase, 5, 5, 50, 1);
                self addOptBool(level.DesolidifyDebris, "Desolidify Debris", ::DesolidifyDebris);
            break;
        
        case "3D Drawing Options":
            if(!isDefined(self.x3DDrawingFX))
                self.x3DDrawingFX = GetArrayKeys(level._effect)[0];
            
            if(!isDefined(self.x3DDistance))
                self.x3DDistance = 150;
            
            self addMenu(menu, "3D Drawing Options");
                self addOptBool(self.x3DDrawing, "3D Drawing", ::x3DDrawing);
                self addOpt("3D Drawing Effect: " + CleanString(self.x3DDrawingFX), ::newMenu, "3D Drawing Effect");
                self addOpt("3D Drawing Distance: " + self.x3DDistance, ::NumberPad, "3D Drawing Distance", ::x3DDrawingDistance);
                self addOpt("Delete All 3D Drawings", ::DeleteAllDrawings);
            break;
        
        case "3D Drawing Effect":
            fxs = GetArrayKeys(level._effect);
            
            self addMenu(menu, "3D Drawing Effect");

                if(isDefined(fxs) && fxs.size)
                    for(a = 0; a < fxs.size; a++)
                        self addOpt(CleanString(fxs[a]), ::x3DDrawingFX, fxs[a]);
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
                self addOptBool(HasKT4Parts(), "Collect KT-4 Parts", ::CollectKT4Parts);
                self addOpt("Skulltar Teleports", ::newMenu, "Skulltar Teleports");
                self addOpt("Challenges", ::newMenu, "Map Challenges");
                self addOptBool(self clientfield::get_to_player("bucket_held"), "Collect Bucket", ::ZNSGrabWaterBucket);
                self addOpt("Bucket Water Type", ::newMenu, "ZNS Bucket Water");
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
                self addOpt("Void", ::newMenu, "Void Bow");
                self addOpt("Wolf", ::newMenu, "Wolf Bow");
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
        
        case "Void Bow":
            //level.var_6e68c0d8 <- player bound to void quest

            self addMenu(menu, "Void");
                self addOptBool(IsDemonSymbolDestroyed(), "Initiate Quest", ::InitVoidBow);

                if(IsDemonSymbolDestroyed())
                {
                    if(isDefined(level.var_6e68c0d8))
                    {
                        self addOptBool(level flag::get("demon_gate_seal"), "Release Demon Urn", ::ReleaseDemonUrn);
                        self addOptBool(IsAllFossilsTriggered(), "Trigger Fossil Heads", ::TriggerDemonFossils);
                        self addOptBool(level flag::get("demon_gate_crawlers"), "Feed Demon Urn", ::FeedDemonUrn);
                    }
                    else
                    {
                        self addOpt("");
                        self addOpt("Quest Hasn't Been Bound Yet");
                    }
                }
            break;
        
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
        
        case "Entity Options":
            self addMenu(menu, "Entity Options");

                if(isDefined(level.SavedMapEntities) && level.SavedMapEntities.size)
                {
                    self addOpt("Entity Editing List", ::newMenu, "Entity Editing List");
                    self addOptBool(AllEntitiesInvisible(), "Invisibility", ::EntitiesInvisibility);
                    self addOpt("Delete", ::DeleteEntities);
                    self addOpt("Rotation", ::newMenu, "Entities Rotation");
                    self addOptIncSlider("Scale", ::EntitiesScale, 1, 1, 10, 1);
                    self addOptSlider("Teleport", ::TeleportEntities, "Self;Crosshairs");
                    self addOpt("Reset Origin", ::EntitiesResetOrigins);
                }
                else
                    self addOpt("No Entities Found");
            break;
        
        case "Entity Editing List":
            self addMenu(menu, "Entity Editing List");

                if(isDefined(level.SavedMapEntities) && level.SavedMapEntities.size)
                {
                    for(a = 0; a < level.SavedMapEntities.size; a++)
                        if(isDefined(level.SavedMapEntities[a]) && level.SavedMapEntities[a].model != "")
                            self addOpt(CleanString(level.SavedMapEntities[a].model), ::newMenu, "Entity Editor", false, a);
                }
                else
                    self addOpt("No Entities Found");
            break;
        
        case "Entity Editor":
            self addMenu(menu, CleanString(level.SavedMapEntities[self.EntityEditorNumber].model));
                self addOpt("Delete", ::DeleteEntity, level.SavedMapEntities[self.EntityEditorNumber]);
                self addOptBool(level.SavedMapEntities[self.EntityEditorNumber].Invisibility, "Invisibility", ::EntityInvisibility, level.SavedMapEntities[self.EntityEditorNumber]);
                self addOpt("Rotation", ::newMenu, "Entity Rotation", false, self.EntityEditorNumber);
                self addOptIncSlider("Scale", ::EntityScale, 1, 1, 10, 1, level.SavedMapEntities[self.EntityEditorNumber]);
                self addOptSlider("Teleport", ::TeleportEntity, "Self;Crosshairs", level.SavedMapEntities[self.EntityEditorNumber]);
                self addOpt("Reset Origin", ::EntityResetOrigin, level.SavedMapEntities[self.EntityEditorNumber]);
            break;
        
        case "Entity Rotation":
            self addMenu(menu, "Rotation");
                self addOpt("Reset Angles", ::EntityResetAngles, level.SavedMapEntities[self.EntityEditorNumber]);
                self addOptIncSlider("Pitch", ::EntityRotation, -10, 0, 10, 1, "Pitch", level.SavedMapEntities[self.EntityEditorNumber]);
                self addOptIncSlider("Yaw", ::EntityRotation, -10, 0, 10, 1, "Yaw", level.SavedMapEntities[self.EntityEditorNumber]);
                self addOptIncSlider("Roll", ::EntityRotation, -10, 0, 10, 1, "Roll", level.SavedMapEntities[self.EntityEditorNumber]);
            break;
        
        case "Entities Rotation":
            self addMenu(menu, "Rotation");
                self addOpt("Reset Angles", ::EntitiesResetAngles);
                self addOptIncSlider("Pitch", ::EntitiesRotation, -10, 0, 10, 1, "Pitch");
                self addOptIncSlider("Yaw", ::EntitiesRotation, -10, 0, 10, 1, "Yaw");
                self addOptIncSlider("Roll", ::EntitiesRotation, -10, 0, 10, 1, "Roll");
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
                self addOptSlider("Style", ::SetDoheartStyle, "Pulsing;Pulse Effect;Moving;Fade Effect");
            break;
        
        case "Lobby Timer Options":
            if(!isDefined(level.LobbyTime))
                level.LobbyTime = 10;
            
            self addMenu(menu, "Lobby Timer Options");
                self addOptBool(level.LobbyTimer, "Lobby Timer", ::LobbyTimer);
                self addOptIncSlider("Set Lobby Timer", ::SetLobbyTimer, 1, 10, 30, 1);
            break;
        
        case "Zombie Craftables":
            craftables = GetArrayKeys(level.zombie_include_craftables);

            self addMenu(menu, "Craftables");

                if(!IsAllCraftablesCollected())
                {
                    for(a = 0; a < craftables.size; a++)
                        if(craftables[a] != "open_table" && !IsSubStr(craftables[a], "ritual_") && !IsCraftableCollected(craftables[a]))
                            self addOpt(CleanString(craftables[a]), ::CollectCraftableParts, craftables[a]);
                }
                else
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
            arr = [];
            weaps = GetArrayKeys(level.zombie_weapons);
            weaponsVar = ["assault", "smg", "lmg", "sniper", "cqb", "pistol", "launcher", "special"];
            equipment = ArrayCombine(level.zombie_lethal_grenade_list, level.zombie_tactical_grenade_list, 0, 1);
            keys = GetArrayKeys(equipment);
            
            self addMenu(menu, "Weapons");
                self addOptBool(IsAllWeaponsInBox(), "Enable All", ::EnableAllWeaponsInBox);

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
                                self addOptBool(IsWeaponInBox(weaps[a]), string, ::SetBoxWeaponState, weaps[a]);
                            }
                        }
                    }
                }
                
                self addOptBool(IsWeaponInBox(GetWeapon("minigun")), "Death Machine", ::SetBoxWeaponState, GetWeapon("minigun"));
                self addOptBool(IsWeaponInBox(GetWeapon("defaultweapon")), "Default Weapon", ::SetBoxWeaponState, GetWeapon("defaultweapon"));

                if(isDefined(keys) && keys.size)
                {
                    foreach(index, weapon in GetArrayKeys(level.zombie_weapons))
                        if(isInArray(equipment, weapon))
                            self addOptBool(IsWeaponInBox(weapon), weapon.displayname, ::SetBoxWeaponState, weapon);
                }
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
        
        case "Host Menu":
            self addMenu(menu, "Host Menu");
                self addOpt("Disconnect", ::disconnect);
                self addOptBool((GetDvarInt("migration_forceHost") == 1), "Force Host", ::ForceHost);
                self addOptBool(level.GEntityProtection, "G_Entity Crash Protection", ::GEntityProtection);
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
                self addOpt("Down", ::AllPlayersFunction, ::DownPlayer);
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
                    if(player IsHost() && !self IsHost() || player isDeveloper() && !self isDeveloper()) //This Will Make It So No One Can See The Host In The Player Menu Besides The Host & Developer. No one can see the developer, besides the developer.
                        continue;

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
    
    newmenu = "";
    sepmenu = StrTok(menu, " " + player GetEntityNumber());

    for(a = 0; a < sepmenu.size; a++)
    {
        newmenu += sepmenu[a];

        if(a != (sepmenu.size - 1))
            newmenu += " ";
    }
    
    weapons = ["Assault Rifles", "Sub Machine Guns", "Light Machine Guns", "Sniper Rifles", "Shotguns", "Pistols", "Launchers", "Specials"];
    weaponsVar = ["assault", "smg", "lmg", "sniper", "cqb", "pistol", "launcher", "special"];
    
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
                self addOptSlider("Custom Crosshairs", ::CustomCrosshairs, "Disable;+;(+);.;o;<>;|-|;-|-;<3;" + CleanName(player getName()) + ";" + level.menuName + ";CF4_99;Extinct;ItsFebiven;Discord.gg/MXT", player);
                self addOptBool(player.NoTarget, "No Target", ::NoTarget, player);
                self addOptBool(player.ReducedSpread, "Reduced Spread", ::ReducedSpread, player);
                self addOptBool(player.MultiJump, "Multi-Jump", ::MultiJump, player);
                self addOptSlider("Set Vision", ::PlayerSetVision, "Default;" + level.menuVisions, player);
                self addOpt("Visual Effects", ::newMenu, "Visual Effects " + player GetEntityNumber());
                self addOptSlider("Zombie Charms", ::ZombieCharms, "None;Orange;Green;Purple;Blue", player);
                self addOptBool(player.NoExplosiveDamage, "No Explosive Damage", ::NoExplosiveDamage, player);
                self addOptIncSlider("Character Model Index", ::SetCharacterModelIndex, 0, player.characterIndex, 8, 1, player);
                self addOptBool(player.UnlimitedSprint, "Unlimited Sprint", ::UnlimitedSprint, player);
                self addOpt("Respawn", ::ServerRespawnPlayer, player);
                self addOpt("Revive", ::PlayerRevive, player);
                self addOpt("Down", ::DownPlayer, player);
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
                
                if(isDefined(level.menuTeleports) && isDefined(level.menuTeleports[ReturnMapName(level.script)]) && level.menuTeleports[ReturnMapName(level.script)].size)
                    self addOpt(ReturnMapName(level.script) + " Teleports", ::newMenu, ReturnMapName(level.script) + " Teleports " + player GetEntityNumber());
                
                self addOpt("Entity Teleports", ::newMenu, "Entity Teleports " + player GetEntityNumber());
                self addOptSlider("Teleport", ::TeleportPlayer, "Crosshairs;Sky", player);
                self addOptBool(player.TeleportGun, "Teleport Gun", ::TeleportGun, player);
                self addOpt("Save Current Location", ::SaveCurrentLocation, player);
                self addOpt("Load Saved Location", ::LoadSavedLocation, player);

                if(player != self)
                {
                    self addOpt("Teleport To Self", ::TeleportPlayer, player, self);
                    self addOpt("Teleport To Player", ::TeleportPlayer, self, player);
                }
            break;
        
        case ReturnMapName(level.script) + " Teleports":
            self addMenu(menu, ReturnMapName(level.script) + " Teleports");
                if(isDefined(level.menuTeleports) && isDefined(level.menuTeleports[ReturnMapName(level.script)]) && level.menuTeleports[ReturnMapName(level.script)].size)
                    for(a = 0; a < level.menuTeleports[ReturnMapName(level.script)].size; a += 2)
                        self addOpt(level.menuTeleports[ReturnMapName(level.script)][a], ::TeleportPlayer, level.menuTeleports[ReturnMapName(level.script)][(a + 1)], player);
                else
                    self addOpt("No " + ReturnMapName(level.script) + " Teleports Found");
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
                self addOpt("Unlock All Achievements", ::UnlockAchievements, player);
                self addOpt("Clan Tag Options", ::newMenu, "Clan Tag Options " + player GetEntityNumber());
                self addOpt("Custom Stats", ::newMenu, "Custom Stats " + player GetEntityNumber());
                self addOpt("EE Stats", ::newMenu, "EE Stats " + player GetEntityNumber());
                self addOptIncSlider("Rank", ::SetPlayerRank, (player.pers["plevel"] > 10) ? 36 : 1, (player.pers["plevel"] > 10) ? 36 : 1, (player.pers["plevel"] > 10) ? 1000 : 35, 1, player);
                self addOptIncSlider("Prestige", ::SetPlayerPrestige, 0, 0, 10, 1, player);
                self addOpt("Complete Daily Challenges", ::CompleteDailyChallenges, player);
                self addOptSlider("Weapon Rank", ::PlayerWeaponRanks, "Max;Reset", player);
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
                self addOpt("Set Selected Stats", ::SetCustomStats, player);
                self addOpt("");
                self addOpt("General", ::newMenu, "General Stats " + player GetEntityNumber());
                self addOpt("Gobblegums", ::newMenu, "Gobblegum Stats " + player GetEntityNumber());
                self addOpt("Maps", ::newMenu, "Map Stats " + player GetEntityNumber());
            break;
        
        case "General Stats":
            stats = ["kills", "headshots", "downs", "total_downs", "deaths", "revives", "rounds", "total_rounds_survived", "total_points", "perks_drank", "bgbs_chewed", "grenade_kills", "doors_purchased", "use_magicbox", "use_pap", "power_turnedon", "buildables_built", "total_shots", "hits", "misses", "distance_traveled", "total_games_played", "time_played_total"];

            self addMenu(menu, "General");
                
                for(a = 0; a < stats.size; a++)
                    self addOptBool(isInArray(player.CustomStatsArray, stats[a]), CleanString(stats[a]), ::AddToCustomStats, stats[a], player);
            break;
        
        case "Gobblegum Stats":
            self addMenu(menu, "Gobblegums");
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
            stats = ["DARKOPS_GENESIS_SUPER_EE", "darkops_zod_ee", "darkops_factory_ee", "darkops_castle_ee", "darkops_island_ee", "darkops_stalingrad_ee", "darkops_genesis_ee", "darkops_zod_super_ee", "darkops_factory_super_ee", "darkops_castle_super_ee", "darkops_island_super_ee", "darkops_stalingrad_super_ee"];

            self addMenu(menu, "EE Stats");

            for(a = 0; a < stats.size; a++)
            {
                statTok = StrTok(stats[a], "_");
                map = ReturnMapName("zm_" + ToLower(statTok[1]));

                if(IsSubStr(stats[a], "super"))
                    map += " Super";

                self addOptBool(player GetDStat("PlayerStatsList", stats[a], "StatValue"), map + " EE", ::PlayerBoolStat, stats[a], player);
            }
            break;

        case "Weaponry":
            self addMenu(menu, "Weaponry");
                self addOpt("Weapon Options", ::newMenu, "Weapon Options " + player GetEntityNumber());
                self addOptIncSlider("Weapon Camo", ::SetPlayerCamo, 0, 0, 138, 1, player);
                self addOptBool(player.FlashingCamo, "Flashing Camo", ::FlashingCamo, player);
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
                self addOptBool(player zm_weapons::is_weapon_upgraded(player GetCurrentWeapon()), "Pack 'a' Punch Current Weapon", ::PackCurrentWeapon, player);
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
                self addOptBool(player.HealthBar, "Health Bar", ::HealthBar, player);
                self addOptBool(player.LightProtector, "Light Protector", ::LightProtector, player);
                self addOpt("Adventure Time", ::AdventureTime, player);
                self addOpt("Earthquake", ::SendEarthquake, player);
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
            if(!isDefined(player.AimBoneTag))
                player.AimBoneTag = "Best";
            
            self addMenu(menu, "Aimbot Menu");
                self addOptBool(player.Aimbot, "Aimbot", ::Aimbot, player);
                self addOptSlider("Bone Tag", ::AimBoneTag, "Best;" + level.boneTags, player);
                self addOptBool(player.AimingRequired, "Aiming Required", ::AimbotOptions, 1, player);
                self addOptBool(player.AimSnap, "Aim Snap To Zombie", ::AimbotOptions, 2, player);
                self addOptBool(player.ShootThruWalls, "Shoot Through Walls", ::AimbotOptions, 3, player);
                self addOptBool(player.VisibilityCheck, "Visibility Check", ::AimbotOptions, 4, player);
                self addOptBool(player.PlayableAreaCheck, "Playable Area Check", ::AimbotOptions, 5, player);
                self addOptBool(player.AutoFire, "Auto-Fire", ::AimbotOptions, 6, player);
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
            if(!isDefined(self.ShellShockTime))
                self.ShellShockTime = 1;
            
            self addMenu(menu, "Malicious Options");
                self addOpt("Disable Actions", ::newMenu, "Disable Actions " + player GetEntityNumber());
                self addOptSlider("Set Stance", ::SetPlayerStance, "Prone;Crouch;Stand", player);
                self addOpt("Launch", ::LaunchPlayer, player);
                self addOpt("Mortar Strike", ::MortarStrikePlayer, player);
                self addOptBool(player.FlashLoop, "Flash Loop", ::FlashLoop, player);
                self addOptSlider("Shellshock", ::ApplyShellShock, "Concussion Grenade;Zombie Death;Explosion", player);
                self addOptIncSlider("Shellshock Time", ::SetShellShockTime, 1, 1, 30, 1);
                self addOptBool(player.SpinPlayer, "Spin Player", ::SpinPlayer, player);
                self addOptBool(player.BlackScreen, "Black Screen", ::BlackScreenPlayer, player);
                self addOptBool(player.FakeLag, "Fake Lag", ::FakeLag, player);
                self addOptBool(self.AttachToPlayer, "Attach Self To Player", ::AttachSelfToPlayer, player);
                self addOptBool(player.DropCamera, "Drop Camera", ::PlayerDropCamera, player);
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
                pistols = ["pistol_standard", "pistol_burst", "pistol_fullauto"];
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
            else
            {
                error404 = true;

                for(a = 0; a < level.mapNames.size; a++)
                {
                    if(IsSubStr(newmenu, level.mapNames[a]))
                    {
                        error404 = false;

                        mapStats = ["score", "total_games_played", "total_rounds_survived", "highest_round_reached", "time_played_total", "total_downs"];

                        self addMenu(menu, ReturnMapName(level.mapNames[a]));
                            for(b = 0; b < mapStats.size; b++)
                                self addOptBool(isInArray(player.CustomStatsArray, mapStats[b] + "_" + level.mapNames[a]), CleanString(mapStats[b]), ::AddToCustomStats, mapStats[b] + "_" + level.mapNames[a], player);
                    }
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

menuMonitor()
{
    self endon("disconnect");
    
    while(1)
    {
        if(self getVerification() && !isDefined(self.menu["DisableMenuControls"]))
        {
            if(!self isInMenu())
            {
                if(self AdsButtonPressed() && self MeleeButtonPressed())
                {
                    self openMenu1();
                    wait 0.5;
                }
            }
            else
            {
                menu = self getCurrent();
                curs = self getCursor();

                if(self AdsButtonPressed() || self AttackButtonPressed() || self ActionSlotOneButtonPressed() || self ActionSlotTwoButtonPressed())
                {
                    if(!self AdsButtonPressed() || !self AttackButtonPressed() || !self ActionSlotOneButtonPressed() || !self ActionSlotTwoButtonPressed())
                    {
                        self.menu["curs"][menu] += (self AttackButtonPressed() || self ActionSlotTwoButtonPressed()) ? 1 : -1;
                        
                        if(curs != self.menu["curs"][menu])
                        {
                            self scrollMenu(((self AttackButtonPressed() || self ActionSlotTwoButtonPressed()) ? 1 : -1), curs);
                            self PlaySoundToPlayer("uin_alert_lockon", self);
                        }

                        wait 0.2;
                    }
                }
                else if(self UseButtonPressed())
                {
                    if(isDefined(self.menu["items"][menu].func[curs]))
                    {
                        if(isDefined(self.menu["items"][menu].slider[curs]) || isDefined(self.menu["items"][menu].incslider[curs]))
                            self thread ExeFunction(self.menu["items"][menu].func[curs], isDefined(self.menu["items"][menu].slider[curs]) ? self.menu_S[menu][curs][self.menu_SS[menu][curs]] : self.menu_SS[menu][curs], self.menu["items"][menu].input1[curs], self.menu["items"][menu].input2[curs], self.menu["items"][menu].input3[curs], self.menu["items"][menu].input4[curs]);
                        else
                        {
                            if(self.menu["items"][menu].func[curs] == ::newMenu)
                                self MenuArrays(self BackMenu());
                            
                            self thread ExeFunction(self.menu["items"][menu].func[curs], self.menu["items"][menu].input1[curs], self.menu["items"][menu].input2[curs], self.menu["items"][menu].input3[curs], self.menu["items"][menu].input4[curs]);
                            
                            if(isDefined(self.menu["items"][menu].bool[curs]))
                            {
                                wait 0.18;
                                self RefreshMenu(menu, curs); //This Will Refresh That Bool Option For Every Player That Is Able To See It.
                            }
                        }
                        
                        wait 0.2;
                    }
                }
                else if(self ActionSlotThreeButtonPressed() || self ActionSlotFourButtonPressed())
                {
                    if(!self ActionSlotThreeButtonPressed() || !self ActionSlotFourButtonPressed())
                    {
                        if(isDefined(self.menu["items"][menu].slider[curs]) || isDefined(self.menu["items"][menu].incslider[curs]))
                        {
                            dir = self ActionSlotThreeButtonPressed() ? 1 : -1;
                            
                            if(isDefined(self.menu["items"][menu].slider[curs]))
                                self SetSlider(dir);
                            else
                                self SetIncSlider(dir);
                            
                            self PlaySoundToPlayer("uin_alert_lockon", self);

                            wait 0.2;
                        }
                    }
                }
                else if(self MeleeButtonPressed())
                {
                    if(menu == "Main")
                        self closeMenu1();
                    else
                        self newMenu();

                    wait 0.2;
                }
            }
        }

        wait 0.05;
    }
}

ExeFunction(fnc, i1, i2, i3, i4, i5, i6)
{
    if(!isDefined(fnc))
        return;
    
    if(isDefined(i6))
        return self thread [[ fnc ]](i1, i2, i3, i4, i5, i6);
    
    if(isDefined(i5))
        return self thread [[ fnc ]](i1, i2, i3, i4, i5);
    
    if(isDefined(i4))
        return self thread [[ fnc ]](i1, i2, i3, i4);
    
    if(isDefined(i3))
        return self thread [[ fnc ]](i1, i2, i3);
    
    if(isDefined(i2))
        return self thread [[ fnc ]](i1, i2);
    
    if(isDefined(i1))
        return self thread [[ fnc ]](i1);

    return self thread [[ fnc ]]();
}

drawText()
{
    self endon("menuClosed");
    self endon("disconnect");

    self DestroyOpts();
    self runMenuIndex(self getCurrent());
    self SetMenuTitle();

    if(!isDefined(self.menu["curs"][self getCurrent()]))
        self.menu["curs"][self getCurrent()] = 0;
    
    start = 0;
    text = self.menu["items"][self getCurrent()].name;

    if(!text.size)
    {
        self addOpt("No Options Found");
        text = self.menu["items"][self getCurrent()].name;
    }
    
    if(self getCursor() > Int(((self.menu["MaxOptions"] - 1) / 2)) && self getCursor() < (text.size - Int(((self.menu["MaxOptions"] + 1) / 2))) && text.size > self.menu["MaxOptions"])
        start = (self getCursor() - Int(((self.menu["MaxOptions"] - 1) / 2)));
    
    if(self getCursor() > (text.size - (Int(((self.menu["MaxOptions"] + 1) / 2)) + 1)) && text.size > self.menu["MaxOptions"])
        start = (text.size - self.menu["MaxOptions"]);
    
    if(isDefined(text) && text.size)
    {
        numOpts = text.size;
        
        if(numOpts >= self.menu["MaxOptions"])
            numOpts = self.menu["MaxOptions"];
        
        for(a = 0; a < numOpts; a++)
        {
            text = self.menu["items"][self getCurrent()].name;
            optStr = self.menu["items"][self getCurrent()].name[(a + start)];
            yOffset = (self.menu["MenuDesign"] == "Native") ? 45 : 54;
            
            if(self.menu["MenuDesign"] != "Old School")
            {
                if(isDefined(self.menu["items"][self getCurrent()].bool[(a + start)]) && self.menu["ToggleStyle"] == "Boxes")
                {
                    self.menu["ui"]["BoolBack"][(a + start)] = self createRectangle("CENTER", "CENTER", (self.menu["X"] + (self.menu["MenuWidth"] - 8)), (self.menu["Y"] - yOffset) + (a * 20), 8, 8, (0.15, 0.15, 0.15), 4, 1, "white");
                    self.menu["ui"]["BoolOpt"][(a + start)] = self createRectangle("CENTER", "CENTER", (self.menu["X"] + (self.menu["MenuWidth"] - 8)), (self.menu["Y"] - yOffset) + (a * 20), 7, 7, (isDefined(self.menu_B[self getCurrent()][(a + start)]) && self.menu_B[self getCurrent()][(a + start)]) ? self.menu["Main_Color"] : (0, 0, 0), 5, 1, "white");
                }
                
                if(isDefined(self.menu["items"][self getCurrent()].func[(a + start)]) && self.menu["items"][self getCurrent()].func[(a + start)] == ::newMenu)
                    self.menu["ui"]["subMenu"][(a + start)] = self createText("default", 1.1, 4, ">", "RIGHT", "CENTER", (self.menu["X"] + (self.menu["MenuWidth"] - 4)), (self.menu["Y"] - yOffset) + (a * 20), 1, (1, 1, 1));
            
                if(isDefined(self.menu["items"][self getCurrent()].incslider[(a + start)]))
                    self.menu["ui"]["IntSlider"][(a + start)] = self createText("default", 1.1, 4, "< " + self.menu_SS[self getCurrent()][(a + start)] + " >", "RIGHT", "CENTER", (self.menu["X"] + (self.menu["MenuWidth"] - 4)), (self.menu["Y"] - yOffset) + (a * 20), 1, (1, 1, 1));

                if(isDefined(self.menu["items"][self getCurrent()].slider[(a + start)]))
                    self.menu["ui"]["StringSlider"][(a + start)] = self createText("default", 1.1, 4, "< " + self.menu_S[self getCurrent()][(a + start)][self.menu_SS[self getCurrent()][(a + start)]] + " > [" + (self.menu_SS[self getCurrent()][(a + start)] + 1) + "/" + self.menu_S[self getCurrent()][(a + start)].size + "]", "RIGHT", "CENTER", (self.menu["X"] + (self.menu["MenuWidth"] - 4)), (self.menu["Y"] - yOffset) + (a * 20), 1, (1, 1, 1));
            }
            else
            {
                if(isDefined(self.menu["items"][self getCurrent()].slider[(a + start)]) || isDefined(self.menu["items"][self getCurrent()].incslider[(a + start)]))
                    optStr = isDefined(self.menu["items"][self getCurrent()].slider[(a + start)]) ? optStr + " < " + self.menu_S[self getCurrent()][(a + start)][self.menu_SS[self getCurrent()][(a + start)]] + " > [" + (self.menu_SS[self getCurrent()][(a + start)] + 1) + "/" + self.menu_S[self getCurrent()][(a + start)].size + "]" : optStr + " < " + self.menu_SS[self getCurrent()][(a + start)] + " >";
            }

            fixedScale = (self.menu["MenuDesign"] == "Old School") ? 1.7 : 1.3;
            optColor = (self.menu["MenuDesign"] == "Old School" && (a + start) == self getCursor()) ? self.menu["Main_Color"] : (1, 1, 1);

            self.menu["ui"]["text"][(a + start)] = self createText("default", ((a + start) == self getCursor() && isDefined(self.menu["LargeCursor"])) ? fixedScale : 1.1, 5, optStr, (self.menu["MenuDesign"] == "Old School") ? "CENTER" : "LEFT", "CENTER", (self.menu["X"] + 4), (self.menu["Y"] - yOffset) + (a * 20), 1, (isDefined(self.menu["items"][self getCurrent()].bool[(a + start)]) && isDefined(self.menu_B[self getCurrent()][(a + start)]) && self.menu_B[self getCurrent()][(a + start)] && self.menu["ToggleStyle"] == "Text Color") ? divideColor(0, 255, 0) : optColor);
        }
    }
    
    if(!isDefined(self.menu["ui"]["text"][self getCursor()]))
        self.menu["curs"][self getCurrent()] = (text.size - 1);
    
    if(isDefined(self.menu["ui"]["scroller"]))
        self.menu["ui"]["scroller"].y = (self.menu["ui"]["text"][self getCursor()].y - 8);

    self UpdateOptCount();
}

scrollMenu(dir, OldCurs)
{
    self endon("menuClosed");
    self endon("disconnect");
    
    arry = self.menu["items"][self getCurrent()].name;
    curs = self getCursor();
    
    if(curs < 0 || curs > (arry.size - 1))
    {
        self setCursor((curs < 0) ? (arry.size - 1) : 0);
        
        curs = getCursor();
        OldCurs = curs;

        if(arry.size > self.menu["MaxOptions"])
            self RefreshMenu();
    }
    else if(curs < (arry.size - Int(((self.menu["MaxOptions"] + 1) / 2))) && (OldCurs > Int(((self.menu["MaxOptions"] - 1) / 2))) || (curs > Int(((self.menu["MaxOptions"] - 1) / 2))) && OldCurs < (arry.size - Int(((self.menu["MaxOptions"] + 1) / 2))))
    {
        optStr = self.menu["items"][self getCurrent()].name[(curs + (Int(((self.menu["MaxOptions"] - 1) / 2)) * dir))];
        hud = ["text", "BoolOpt", "BoolBack", "subMenu", "IntSlider", "StringSlider"];
        
        for(a = 0; a < arry.size; a++)
            for(b = 0; b < hud.size; b++)
            {
                if(!isDefined(self.menu["ui"][hud[b]][a]) || a == (curs + ((Int(((self.menu["MaxOptions"] + 1) / 2)) * -1) * dir)))
                    continue;
                
                self.menu["ui"][hud[b]][a] thread hudMoveY((self.menu["ui"][hud[b]][a].y - (20 * dir)), 0.16);
            }
        
        for(a = 0; a < hud.size; a++)
            if(isDefined(self.menu["ui"][hud[a]][(curs + ((Int(((self.menu["MaxOptions"] + 1) / 2)) * -1) * dir))]))
                self.menu["ui"][hud[a]][(curs + ((Int(((self.menu["MaxOptions"] + 1) / 2)) * -1) * dir))] thread hudFadenDestroy(0, 0.16);
        
        if(self.menu["MenuDesign"] != "Old School")
        {
            if(isDefined(self.menu["items"][self getCurrent()].bool[(curs + (Int(((self.menu["MaxOptions"] - 1) / 2)) * dir))]) && self.menu["ToggleStyle"] == "Boxes")
            {
                self.menu["ui"]["BoolBack"][(curs + (Int(((self.menu["MaxOptions"] - 1) / 2)) * dir))] = self createRectangle("CENTER", "CENTER", (self.menu["X"] + (self.menu["MenuWidth"] - 8)), self.menu["ui"]["text"][curs].y + (((self.menu["MaxOptions"] * 10) - 10) * dir), 8, 8, (0.15, 0.15, 0.15), 4, 0, "white");
                self.menu["ui"]["BoolOpt"][(curs + (Int(((self.menu["MaxOptions"] - 1) / 2)) * dir))] = self createRectangle("CENTER", "CENTER", (self.menu["X"] + (self.menu["MenuWidth"] - 8)), self.menu["ui"]["text"][curs].y + (((self.menu["MaxOptions"] * 10) - 10) * dir), 7, 7, (isDefined(self.menu_B[self getCurrent()][(curs + (Int(((self.menu["MaxOptions"] - 1) / 2)) * dir))]) && self.menu_B[self getCurrent()][(curs + (Int(((self.menu["MaxOptions"] - 1) / 2)) * dir))]) ? self.menu["Main_Color"] : (0, 0, 0), 5, 0, "white");
            }
            
            if(isDefined(self.menu["items"][self getCurrent()].func[(curs + (Int(((self.menu["MaxOptions"] - 1) / 2)) * dir))]) && self.menu["items"][self getCurrent()].func[(curs + (Int(((self.menu["MaxOptions"] - 1) / 2)) * dir))] == ::newMenu)
                self.menu["ui"]["subMenu"][(curs + (Int(((self.menu["MaxOptions"] - 1) / 2)) * dir))] = self createText("default", 1.1, 4, ">", "RIGHT", "CENTER", (self.menu["X"] + (self.menu["MenuWidth"] - 4)), self.menu["ui"]["text"][curs].y + (((self.menu["MaxOptions"] * 10) - 10) * dir), 0, (1, 1, 1));
            
            if(isDefined(self.menu["items"][self getCurrent()].incslider[(curs + (Int(((self.menu["MaxOptions"] - 1) / 2)) * dir))]))
                self.menu["ui"]["IntSlider"][(curs + (Int(((self.menu["MaxOptions"] - 1) / 2)) * dir))] = self createText("default", 1.1, 4, "< " + self.menu_SS[self getCurrent()][(curs + (Int(((self.menu["MaxOptions"] - 1) / 2)) * dir))] + " >", "RIGHT", "CENTER", (self.menu["X"] + (self.menu["MenuWidth"] - 4)), self.menu["ui"]["text"][curs].y + (((self.menu["MaxOptions"] * 10) - 10) * dir), 0, (1, 1, 1));
            
            if(isDefined(self.menu["items"][self getCurrent()].slider[(curs + (Int(((self.menu["MaxOptions"] - 1) / 2)) * dir))]))
                self.menu["ui"]["StringSlider"][(curs + (Int(((self.menu["MaxOptions"] - 1) / 2)) * dir))] = self createText("default", 1.1, 4, "< " + self.menu_S[self getCurrent()][(curs + (Int(((self.menu["MaxOptions"] - 1) / 2)) * dir))][self.menu_SS[self getCurrent()][(curs + (Int(((self.menu["MaxOptions"] - 1) / 2)) * dir))]] + " > [" + (self.menu_SS[self getCurrent()][(curs + (Int(((self.menu["MaxOptions"] - 1) / 2)) * dir))] + 1) + "/" + self.menu_S[self getCurrent()][(curs + (Int(((self.menu["MaxOptions"] - 1) / 2)) * dir))].size + "]", "RIGHT", "CENTER", (self.menu["X"] + (self.menu["MenuWidth"] - 4)), self.menu["ui"]["text"][curs].y + (((self.menu["MaxOptions"] * 10) - 10) * dir), 0, (1, 1, 1));
        }
        else
        {
            if(isDefined(self.menu["items"][self getCurrent()].slider[(curs + (Int(((self.menu["MaxOptions"] - 1) / 2)) * dir))]) || isDefined(self.menu["items"][self getCurrent()].incslider[(curs + (Int(((self.menu["MaxOptions"] - 1) / 2)) * dir))]))
                optStr = isDefined(self.menu["items"][self getCurrent()].slider[(curs + (Int(((self.menu["MaxOptions"] - 1) / 2)) * dir))]) ? optStr + " < " + self.menu_S[self getCurrent()][(curs + (Int(((self.menu["MaxOptions"] - 1) / 2)) * dir))][self.menu_SS[self getCurrent()][(curs + (Int(((self.menu["MaxOptions"] - 1) / 2)) * dir))]] + " > [" + (self.menu_SS[self getCurrent()][(curs + (Int(((self.menu["MaxOptions"] - 1) / 2)) * dir))] + 1) + "/" + self.menu_S[self getCurrent()][(curs + (Int(((self.menu["MaxOptions"] - 1) / 2)) * dir))].size + "]" : optStr + " < " + self.menu_SS[self getCurrent()][(curs + (Int(((self.menu["MaxOptions"] - 1) / 2)) * dir))] + " >";
        }

        self.menu["ui"]["text"][(curs + (Int(((self.menu["MaxOptions"] - 1) / 2)) * dir))] = self createText("default", 1.1, 5, optStr, (self.menu["MenuDesign"] == "Old School") ? "CENTER" : "LEFT", "CENTER", (self.menu["X"] + 4), (self.menu["ui"]["text"][curs].y + (((self.menu["MaxOptions"] * 10) - 10) * dir)), 0, (isDefined(self.menu["items"][self getCurrent()].bool[(curs + (Int(((self.menu["MaxOptions"] - 1) / 2)) * dir))]) && isDefined(self.menu_B[self getCurrent()][(curs + (Int(((self.menu["MaxOptions"] - 1) / 2)) * dir))]) && self.menu_B[self getCurrent()][(curs + (Int(((self.menu["MaxOptions"] - 1) / 2)) * dir))] && self.menu["ToggleStyle"] == "Text Color") ? divideColor(0, 255, 0) : (1, 1, 1));
        
        for(a = 0; a < hud.size; a++)
            if(isDefined(self.menu["ui"][hud[a]][(curs + (Int(((self.menu["MaxOptions"] - 1) / 2)) * dir))]))
                self.menu["ui"][hud[a]][(curs + (Int(((self.menu["MaxOptions"] - 1) / 2)) * dir))] thread hudFade(1, 0.16);
    }
    
    if(isDefined(self.menu["ui"]["scroller"]) && self.menu["ui"]["scroller"].y != (self.menu["ui"]["text"][curs].y - 8))
        self.menu["ui"]["scroller"] thread hudMoveY((self.menu["ui"]["text"][curs].y - 8), 0.13);
    
    if(self.menu["MenuDesign"] == "Old School" || isDefined(self.menu["LargeCursor"]))
    {
        for(a = 0; a < self.menu["ui"]["text"].size; a++)
        {
            if(!isDefined(self.menu["ui"]["text"][a]))
                continue;
            
            if(a == curs)
            {
                if(self.menu["MenuDesign"] == "Old School")
                    self.menu["ui"]["text"][a].color = (isDefined(self.menu["items"][self getCurrent()].bool[a]) && isDefined(self.menu_B[self getCurrent()][a]) && self.menu_B[self getCurrent()][a] && self.menu["ToggleStyle"] == "Text Color") ? divideColor(0, 255, 0) : self.menu["Main_Color"];

                scale = (self.menu["MenuDesign"] == "Old School") ? 1.7 : 1.3;
                
                if(self.menu["ui"]["text"][a].fontScale != scale && isDefined(self.menu["LargeCursor"]))
                    self.menu["ui"]["text"][a] ChangeFontscaleOverTime1(scale, 0.13);

                continue;
            }
            
            if(self.menu["MenuDesign"] == "Old School")
                self.menu["ui"]["text"][a].color = (isDefined(self.menu["items"][self getCurrent()].bool[a]) && isDefined(self.menu_B[self getCurrent()][a]) && self.menu_B[self getCurrent()][a] && self.menu["ToggleStyle"] == "Text Color") ? divideColor(0, 255, 0) : (1, 1, 1);

            if(self.menu["ui"]["text"][a].fontScale != 1.1)
                self.menu["ui"]["text"][a] ChangeFontscaleOverTime1(1.1, 0.13);
        }
    }

    self UpdateOptCount();
}

SetMenuTitle(title)
{
    if(!isDefined(self.menu["ui"]["title"]))
        return;
    
    if(!isDefined(title))
        title = self.menu["items"][self getCurrent()].title;
    
    self.menu["ui"]["title"] SetText(title);

    if(self.menu["MenuDesign"] == "Old School")
        self.menu["ui"]["title"].fontScale = 1.8;
}

openMenu1(menu)
{
    if(!isDefined(menu))
        menu = (isDefined(self.menu["currentMenu"]) && self.menu["currentMenu"] != "") ? self.menu["currentMenu"] : "Main";
    
    if(!isDefined(self.menu["curs"][menu]))
        self.menu["curs"][menu] = 0;
    
    if(self.menu["MenuDesign"] != "Old School")
    {
        self.menu["ui"]["background"] = self createRectangle("TOP_LEFT", "CENTER", self.menu["X"], (self.menu["MenuDesign"] == "Native") ? (self.menu["Y"] - 55) : (self.menu["Y"] - 68), self.menu["MenuWidth"], 150, (0, 0, 0), 2, 0, "white");
        self.menu["ui"]["banners"] = self createRectangle("TOP_LEFT", "CENTER", (self.menu["MenuDesign"] == "Native") ? self.menu["X"] : (self.menu["X"] - 2), (self.menu["MenuDesign"] == "Native") ? (self.menu["Y"] - 108) : (self.menu["Y"] - 82), (self.menu["MenuDesign"] == "Native") ? self.menu["MenuWidth"] : (self.menu["MenuWidth"] + 4), (self.menu["MenuDesign"] == "Native") ? 39 : 168, self.menu["Main_Color"], 1, 0, "white");
        self.menu["ui"]["scroller"] = self createRectangle("TOP_LEFT", "CENTER", self.menu["X"], self.menu["Y"], self.menu["MenuWidth"], 18, self.menu["Main_Color"], 3, 0, "white");
    }

    self.menu["ui"]["title"] = self createText("default", 1.2, 5, "", (self.menu["MenuDesign"] == "Old School") ? "CENTER" : "LEFT", "CENTER", (self.menu["X"] + 4), (self.menu["MenuDesign"] == "Native") ? (self.menu["Y"] - 62) : (self.menu["Y"] - 75), 0, (self.menu["MenuDesign"] == "Old School") ? self.menu["Main_Color"] : (1, 1, 1));
    
    if(!isDefined(self.menu["DisableOptionCounter"]) && self.menu["MenuDesign"] != "Old School")
        self.menu["ui"]["optionCount"] = self createText("default", 1.2, 5, "", "RIGHT", "CENTER", (self.menu["X"] + (self.menu["MenuWidth"] - 4)), (self.menu["MenuDesign"] == "Native") ? (self.menu["Y"] - 62) : (self.menu["Y"] - 75), 0, (1, 1, 1));

    if((self.menu["MenuDesign"] == "Native"))
    {
        self.menu["ui"]["MenuName"] = self createText("default", 1.5, 5, level.menuName, "CENTER", "CENTER", (self.menu["X"] + (self.menu["MenuWidth"] / 2)), (self.menu["Y"] - 88), 0, (1, 1, 1));
        self.menu["ui"]["NativeBar"] = self createRectangle("TOP_LEFT", "CENTER", self.menu["X"], (self.menu["Y"] - 70), self.menu["MenuWidth"], 17, (0, 0, 0), 4, 0, "white");
    }
    
    hud = ["banners", "optionCount", "scroller", "MenuName", "NativeBar"];

    alpha = (self.menu["MenuDesign"] != "Old School") ? 1 : 0;
    hudFadeInTime = 0;

    for(a = 0; a < hud.size; a++)
        if(isDefined(self.menu["ui"][hud[a]]))
            self.menu["ui"][hud[a]] thread hudFade(alpha, hudFadeInTime);
    
    self.menu["ui"]["title"] thread hudFade(1, hudFadeInTime);
    
    switch(self.menu["MenuDesign"])
    {
        case "Native":
            alpha = 0.45;
            break;
        
        case "Old School":
            alpha = 0;
            break;
        
        default:
            alpha = 0.8;
            break;
    }

    if(isDefined(self.menu["ui"]["background"]))
        self.menu["ui"]["background"] thread hudFade(alpha, hudFadeInTime);
    
    self.menu["currentMenu"] = menu;
    self drawText();

    if(isDefined(self.menu["MenuBlur"]))
        self SetBlur(self.menu["MenuBlurValue"], 0.1);
    
    self.menuState["isInMenu"] = true;
}

SoftLockMenu(title, optCount, bgHeight)
{
    if(!self hasMenu() || self hasMenu() && !self isInMenu())
        return;
    
    self.menu["DisableMenuControls"] = true;
    self DestroyOpts();

    if(!IsSubStr(title, "Increase Width"))
    {
        self.menu["SoftMenuReset"] = true;

        huds = ["background", "banners", "NativeBar"];

        foreach(hud in huds)
        {
            offset = (hud == "banners" && self.menu["MenuDesign"] != "Native") ? 4 : 0;

            if(isDefined(self.menu["ui"][hud]))
                self.menu["ui"][hud] thread hudScaleOverTime(0.1, (210 + offset), self.menu["ui"][hud].height);
        }
    
        if(isDefined(self.menu["ui"]["optionCount"]))
            self.menu["ui"]["optionCount"].x = (self.menu["X"] + 206);

        if(isDefined(self.menu["ui"]["MenuName"]))
            self.menu["ui"]["MenuName"].x = (self.menu["X"] + 105);

        wait 0.1;
    }
    
    if(isDefined(self.menu["ui"]["background"]))
        self.menu["ui"]["background"] SetShaderValues(self.menu["ui"]["background"].shader, self.menu["ui"]["background"].width, bgHeight);
    
    if(isDefined(self.menu["ui"]["banners"]) && self.menu["MenuDesign"] != "Native")
        self.menu["ui"]["banners"] SetShaderValues(self.menu["ui"]["banners"].shader, self.menu["ui"]["banners"].width, bgHeight + 16);
    
    if(isDefined(self.menu["ui"]["title"]))
        self.menu["ui"]["title"] SetText(title);
    
    if(isDefined(self.menu["ui"]["optionCount"]))
        self.menu["ui"]["optionCount"] SetText(optCount);
}

SoftUnlockMenu()
{
    if(!self hasMenu() || !self isInMenu())
        return;
    
    if(self.menu["MenuDesign"] == "Old School" && isDefined(self.menu["ui"]["scroller"]))
        self.menu["ui"]["scroller"] destroy();
    
    if(isDefined(self.menu["SoftMenuReset"]))
    {
        self.menu["SoftMenuReset"] = undefined;

        huds = ["background", "banners", "NativeBar"];

        foreach(hud in huds)
        {
            offset = (hud == "banners" && self.menu["MenuDesign"] != "Native") ? 4 : 0;

            if(isDefined(self.menu["ui"][hud]))
                self.menu["ui"][hud] thread hudScaleOverTime(0.1, (self.menu["MenuWidth"] + offset), self.menu["ui"][hud].height);
        }

        if(isDefined(self.menu["ui"]["optionCount"]))
            self.menu["ui"]["optionCount"].x = (self.menu["X"] + (self.menu["MenuWidth"] - 4));

        if(isDefined(self.menu["ui"]["MenuName"]))
            self.menu["ui"]["MenuName"].x = (self.menu["X"] + (self.menu["MenuWidth"] / 2));

        wait 0.1;
    }

    if(isDefined(self.menu["ui"]["scroller"]))
    {
        self.menu["ui"]["scroller"] hudMoveX(self.menu["X"], 0.1);
        self.menu["ui"]["scroller"] hudScaleOverTime(0.1, self.menu["MenuWidth"], 18);
        self.menu["ui"]["scroller"] hudFade(1, 0.1);
    }
    
    self.menu["DisableMenuControls"] = undefined;
    self.menu["inKeyboard"] = undefined;
    self.menu["CreditsPlaying"] = undefined;

    self RefreshMenu();
}

UpdateOptCount()
{
    if(self hasMenu() && isDefined(self.menu["ui"]["optionCount"]))
        self.menu["ui"]["optionCount"] SetText((self getCursor() + 1) + "/" + self.menu["items"][self getCurrent()].name.size);
    
    height = (((self.menu["items"][self getCurrent()].name.size >= self.menu["MaxOptions"]) ? self.menu["MaxOptions"] : self.menu["items"][self getCurrent()].name.size) * 20);
    
    if(isDefined(self.menu["ui"]["background"]))
        self.menu["ui"]["background"] SetShaderValues(self.menu["ui"]["background"].shader, self.menu["ui"]["background"].width, (self.menu["MenuDesign"] == "Native") ? height : height + 9);
    
    if(isDefined(self.menu["ui"]["banners"]) && self.menu["MenuDesign"] != "Native")
        self.menu["ui"]["banners"] SetShaderValues(self.menu["ui"]["banners"].shader, self.menu["ui"]["banners"].width, height + 25);
}

closeMenu1()
{
    if(!self isInMenu())
        return;
    
    self DestroyOpts();
    self notify("menuClosed");
    
    vars = ["inKeyboard", "CreditsPlaying"];
    hud = [self.keyboard, self.credits["MenuCreditsHud"]];
    
    for(a = 0; a < vars.size; a++)
    {
        if(isDefined(self.menu[vars[a]]))
        {
            destroyAll(hud[a]);
            self FreezeControls(false);
            
            self.menu[vars[a]] = undefined;
            self.menu["DisableMenuControls"] = undefined;
        }
    }
    
    destroyAll(self.menu["ui"]);
    self SetBlur(0, 0.1);
    
    self.menuState["isInMenu"] = undefined;
}

DestroyOpts()
{
    hud = ["text", "BoolOpt", "BoolBack", "subMenu", "IntSlider", "StringSlider"];

    for(a = 0; a < hud.size; a++)
        destroyAll(self.menu["ui"][hud[a]]);
}

RefreshMenu(menu, curs, force)
{
    if(isDefined(menu) && !isDefined(curs) || !isDefined(menu) && isDefined(curs))
        return;
    
    if(self hasMenu() && self isInMenu() && !isDefined(self.menu["DisableMenuControls"]))
    {
        if(isDefined(menu) && isDefined(curs))
        {
            foreach(player in level.players)
                if(player hasMenu() && player isInMenu() && player getCurrent() == menu && !isDefined(player.menu["DisableMenuControls"]))
                    if(isDefined(player.menu["ui"]["text"][curs]) || isDefined(force) && force)
                        player drawText();
        }
        else
            self drawText();
    }
}
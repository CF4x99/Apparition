menuMonitor()
{
    if(Is_True(self.menuMonitor))
        return;
    self.menuMonitor = true;

    self endon("endMenuMonitor");
    self endon("disconnect");

    while(1)
    {
        if(self hasMenu() && !Is_True(self.DisableMenuControls))
        {
            if(!self isInMenu(true))
            {
                self.menuUI = [];
                
                if(self AreButtonsPressed(self.OpenControls) && Is_Alive(self))
                {
                    self openMenu1(!Is_True(self.DisableMenuAnimations));

                    if(!Is_True(self.DisableMenuSounds))
                        self PlaySoundToPlayer("uin_alert_lockon", self);

                    wait 0.5;
                }
                else if(self AdsButtonPressed() && (self SecondaryOffhandButtonPressed() || !Is_Alive(self) && self JumpButtonPressed()) && !Is_True(self.DisableQM))
                {
                    self openQuickMenu1();

                    if(!Is_True(self.DisableMenuSounds))
                        self PlaySoundToPlayer("uin_alert_lockon", self);

                    wait 0.5;
                }
            }
            else
            {
                if(self isInMenu(false) && !Is_Alive(self))
                    self closeMenu1();

                menu = self getCurrent();
                curs = self getCursor();

                if((self AdsButtonPressed() || self ActionSlotOneButtonPressed()) && !(self AttackButtonPressed() || self ActionSlotTwoButtonPressed()) || (self AttackButtonPressed() || self ActionSlotTwoButtonPressed()) && !(self AdsButtonPressed() || self ActionSlotOneButtonPressed()))
                {
                    dir = (self AdsButtonPressed() || self ActionSlotOneButtonPressed()) ? -1 : 1;

                    self setCursor(curs + dir);
                    self ScrollingSystem(dir);

                    if(!Is_True(self.DisableMenuSounds))
                        self PlaySoundToPlayer("cac_grid_nav", self);

                    wait (0.01 * self.ScrollingBuffer);
                }
                else if(self UseButtonPressed())
                {
                    if(IsDefined(self.menuStructure[curs]) && IsDefined(self.menuStructure[curs].func))
                    {
                        if(Is_True(self.menuStructure[curs].slider) || Is_True(self.menuStructure[curs].incslider))
                        {
                            self ExeFunction(self.menuStructure[curs].func, Is_True(self.menuStructure[curs].slider) ? self.menuStructure[curs].sliderValues[self.menuSlider[menu + "_" + curs]] : self.menuSlider[menu + "_" + curs], self.menuStructure[curs].input1, self.menuStructure[curs].input2, self.menuStructure[curs].input3, self.menuStructure[curs].input4);
                        }
                        else
                        {
                            self ExeFunction(self.menuStructure[curs].func, self.menuStructure[curs].input1, self.menuStructure[curs].input2, self.menuStructure[curs].input3, self.menuStructure[curs].input4);

                            if(IsDefined(self.menuStructure[curs]) && Is_True(self.menuStructure[curs].boolOpt))
                            {
                                wait 0.18;
                                self RefreshMenu(menu, curs); //This Will Refresh That Bool Option For Every Player That Is Able To See It.
                            }
                        }

                        if(!Is_True(self.DisableMenuSounds))
                            self PlaySoundToPlayer("uin_alert_lockon", self);

                        wait 0.2;
                    }
                }
                else if(self ActionslotThreeButtonPressed() && !self ActionSlotFourButtonPressed() || self ActionslotFourButtonPressed() && !self ActionSlotThreeButtonPressed())
                {
                    if(Is_True(self.menuStructure[curs].slider) || Is_True(self.menuStructure[curs].incslider))
                    {
                        dir = self ActionslotThreeButtonPressed() ? -1 : 1;

                        if(Is_True(self.menuStructure[curs].slider))
                            self SetSlider(dir);
                        else
                            self SetIncSlider(dir);

                        if(!Is_True(self.DisableMenuSounds))
                            self PlaySoundToPlayer("cac_grid_nav", self);

                        wait 0.13;
                    }
                }
                else if(self MeleeButtonPressed() || !Is_Alive(self) && self JumpButtonPressed())
                {
                    if(menu == "Main" || menu == "Quick Menu")
                    {
                        if(self isInQuickMenu())
                            self closeQuickMenu();
                        else
                            self closeMenu1(!Is_True(self.DisableMenuAnimations));
                    }
                    else
                        self newMenu();

                    if(!Is_True(self.DisableMenuSounds))
                        self PlaySoundToPlayer("uin_alert_lockon", self);

                    wait 0.2;
                }
            }
        }

        wait 0.05;
    }
}

ExeFunction(fnc, i1, i2, i3, i4, i5, i6)
{
    self endon("disconnect");

    if(!IsDefined(fnc))
        return;
    
    if(IsDefined(i6))
        return self thread [[ fnc ]](i1, i2, i3, i4, i5, i6);
    
    if(IsDefined(i5))
        return self thread [[ fnc ]](i1, i2, i3, i4, i5);
    
    if(IsDefined(i4))
        return self thread [[ fnc ]](i1, i2, i3, i4);
    
    if(IsDefined(i3))
        return self thread [[ fnc ]](i1, i2, i3);
    
    if(IsDefined(i2))
        return self thread [[ fnc ]](i1, i2);
    
    if(IsDefined(i1))
        return self thread [[ fnc ]](i1);

    return self thread [[ fnc ]]();
}

openMenu1(showAnim)
{
    self endon("disconnect");

    self.isInMenu = true;
    wait 0.05;

    if(!IsDefined(self.currentMenu) || self.currentMenu == "")
        self.currentMenu = "Main";
    
    if(!IsDefined(self.menu_parent))
        self.menu_parent = [];

    if(isInArray(self.menu_parent, "Players") && IsDefined(self.SavedSelectedPlayer))
        self.SelectedPlayer = self.SavedSelectedPlayer;

    if(self.MenuStyle != "Quick Menu")
    {
        self.menuUI["background"] = self createRectangle("TOP", "CENTER", self.menuX, (self.MenuStyle == "Zodiac") ? (self.menuY - 60) : (self.MenuStyle == "Native") ? (self.menuY + 6) : (self.MenuStyle == "AIO") ? (self.menuY - 5) : self.menuY, 260, 0, (self.MenuStyle == "Nautaremake") ? divideColor(25, 25, 25) : (0, 0, 0), 2, Is_True(showAnim) ? 0 : (self.MenuStyle == "Zodiac") ? 0.8 : (self.MenuStyle == "Native") ? 0.35 : (self.MenuStyle == "AIO") ? 0.4 : 1, "white");

        if(self.MenuStyle == "Nautaremake" || self.MenuStyle == "AIO")
        {
            self.menuUI["nautabackground"] = self createRectangle("TOP", "CENTER", self.menuX, (self.MenuStyle == "Nautaremake") ? (self.menuY - 40) : (self.menuY - 27), (self.MenuStyle == "Nautaremake") ? 260 : 264, 0, (self.MenuStyle == "Nautaremake") ? divideColor(45, 45, 45) : (0, 0, 0), 1, Is_True(showAnim) ? 0 : (self.MenuStyle == "AIO") ? 0.3 : 1, "white");

            if(self.MenuStyle == "Nautaremake")
                self.menuUI["nautaicon"] = self createRectangle("TOP", "CENTER", self.menuX, (self.menuY - 57), 32, 54, (1, 1, 1), 4, Is_True(showAnim) ? 0 : 1, "damage_feedback_tac");
        }

        if(self.MenuStyle != "Zodiac")
        {
            self.menuUI["outlines"] = [];

            if(self.MenuStyle != "Native" && self.MenuStyle != "AIO")
            {
                //Left Side
                self.menuUI["outlines"][self.menuUI["outlines"].size] = self createRectangle("TOP", "CENTER", (self.menuX - 130), (self.MenuStyle == "Nautaremake") ? (self.menuY - 40) : self.menuY, 1, 0, self.MainTheme, 5, Is_True(showAnim) ? 0 : 1, "white");

                //Right Side
                self.menuUI["outlines"][self.menuUI["outlines"].size] = self createRectangle("TOP", "CENTER", (self.menuX + 130), (self.MenuStyle == "Nautaremake") ? (self.menuY - 40) : self.menuY, 1, 0, self.MainTheme, 5, Is_True(showAnim) ? 0 : 1, "white");
            }

            //Top 2 || Native Design Banner || AIO Top Banner
            self.menuUI["outlines"][self.menuUI["outlines"].size] = self createRectangle("TOP", "CENTER", self.menuX, (self.MenuStyle == "Nautaremake") ? self.menuY : (self.MenuStyle == "Native") ? (self.menuY - 50) : (self.MenuStyle == "AIO") ? (self.menuY - 25) : (self.menuY - 13), (self.MenuStyle == GetMenuName()) ? 261 : 260, (self.MenuStyle == "Nautaremake") ? 1 : (self.MenuStyle == "Native") ? 39 : (self.MenuStyle == "AIO") ? 25 : 16, self.MainTheme, 5, Is_True(showAnim) ? 0 : (self.MenuStyle == "Native") ? 0.8 : 1, "white");

            //Bottom 1 || AIO Bottom Banner
            if(self.MenuStyle != "Native")
                self.menuUI["outlines"][self.menuUI["outlines"].size] = self createRectangle("TOP", "CENTER", self.menuX, self.menuY, 260, (self.MenuStyle == "AIO") ? 25 : 1, self.MainTheme, 5, Is_True(showAnim) ? 0 : 1, "white");

            if(self.MenuStyle == "Nautaremake" || self.MenuStyle == "Native")
            {
                //Top 1 || Native Design Title Bar
                self.menuUI["outlines"][self.menuUI["outlines"].size] = self createRectangle("TOP", "CENTER", self.menuX, (self.MenuStyle == "Native") ? (self.menuY - 11) : (self.menuY - 40), 260, (self.MenuStyle == "Native") ? 17 : 1, (self.MenuStyle == "Native") ? (0, 0, 0) : self.MainTheme, 6, Is_True(showAnim) ? 0 : 1, "white");

                //Bottom 2
                if(self.MenuStyle == "Nautaremake")
                    self.menuUI["outlines"][self.menuUI["outlines"].size] = self createRectangle("TOP", "CENTER", self.menuX, self.menuY, 260, 1, self.MainTheme, 5, Is_True(showAnim) ? 0 : 1, "white");
            }
        }

        self.menuUI["scroller"] = self createRectangle("TOP", "CENTER", (self.MenuStyle == "AIO") ? (self.menuX - 129) : self.menuX, (self.menuY + 6), (self.MenuStyle == "AIO") ? 2 : 260, (self.MenuStyle == "AIO") ? 20 : 18, (self.MenuStyle == "Nautaremake") ? divideColor(45, 45, 45) : self.MainTheme, 4, Is_True(showAnim) ? 0 : (self.MenuStyle == "Native") ? 0.6 : 1, "white");

        if(self.MenuStyle != "Nautaremake")
            self.menuUI["title"] = self createText("default", (self.MenuStyle == "Native") ? 1.2 : self.TitleFontScale, 7, "", (self.MenuStyle == "Native") ? "CENTER" : "LEFT", "CENTER", (self.MenuStyle == "Native") ? self.menuX : (self.menuX - 126), (self.MenuStyle == "Native") ? (self.menuY - 3) : (self.MenuStyle == "Zodiac") ? (self.menuY - 20) : (self.MenuStyle == "AIO") ? (self.menuY - 13) : (self.menuY - 6), Is_True(showAnim) ? 0 : 1, (self.MenuStyle == "Zodiac") ? self.MainTheme : (IsDefined(self.TitleColor) && IsVec(self.TitleColor)) ? self.TitleColor : IsString(self.TitleColor) ? level.RGBFadeColor : (0, 0, 0));
        
        if(self.MenuStyle == "Native" || self.MenuStyle == "AIO")
            self.menuUI["MenuName"] = self createText("default", self.TitleFontScale, 7, (self.MenuStyle == "AIO") ? "Status: " + self.accessLevel : GetMenuName(), (self.MenuStyle == "AIO") ? "LEFT" : "CENTER", "CENTER", (self.MenuStyle == "AIO") ? (self.menuX - 126) : self.menuX, (self.MenuStyle == "AIO") ? self.menuY : (self.menuY - 31), Is_True(showAnim) ? 0 : 1, (self.MenuStyle == "AIO") ? (IsDefined(self.TitleColor) && IsVec(self.TitleColor)) ? self.TitleColor : IsString(self.TitleColor) ? level.RGBFadeColor : (0, 0, 0) : (1, 1, 1));
    }
    else
    {
        self.menuUI["background"] = self createRectangle("TOP", "CENTER", self.menuX, self.menuY, 155, 0, (0, 0, 0), 2, 0.7, "white");
        self.menuUI["scroller"] = self createRectangle("TOP", "CENTER", self.menuX, (self.menuY + 24), 155, 14, self.MainTheme, 4, 1, "white");
        self.menuUI["title"] = self createText("default", self.TitleFontScale, 4, "", "CENTER", "CENTER", self.menuX, (self.menuUI["background"].y + 8), 1, self.MainTheme);
    }

    self drawText(showAnim);

    if(self getCurrent() == "Players" && !Is_True(self.PlayerInfoHandler))
        self thread PlayerInfoHandler();
}

closeMenu1(showAnim = false)
{
    self endon("disconnect");

    if(self isInQuickMenu())
    {
        self closeQuickMenu();
        return;
    }

    if(!self isInMenu())
        return;
    
    self notify("menuClosed");
    
    if(Is_True(self.inKeyboard) || Is_True(self.CreditsPlaying))
    {
        if(Is_True(self.inKeyboard))
        {
            destroyAll(self.keyboard);
            self.keyboard = undefined;
            self.inKeyboard = BoolVar(self.inKeyboard);
        }
        
        if(Is_True(self.CreditsPlaying))
        {
            destroyAll(self.credits);
            self.credits = undefined;
            self.CreditsPlaying = BoolVar(self.CreditsPlaying);
        }
        
        if(Is_True(self.DisableMenuControls))
            self.DisableMenuControls = BoolVar(self.DisableMenuControls);
    }

    if(Is_True(showAnim))
    {
        if(IsDefined(self.menuUI["scroller"]))
            self.menuUI["scroller"] DestroyHud();
        
        hudElems = Array(self.menuUI["BoolBack"], self.menuUI["BoolOpt"], self.menuUI["subMenu"], self.menuUI["IntSlider"], self.menuUI["StringSlider"], self.menuUI["text"]);
        fadeTime = 0.15;

        foreach(hud in hudElems)
        {
            if(!IsDefined(hud) || !IsArray(hud) || !hud.size)
                continue;
            
            indexf = 0;

            foreach(index, hude in hud)
            {
                if(IsDefined(hude))
                {
                    indexf++;
                    hude thread hudFade(0, ((fadeTime + 0.1) / indexf));
                }
            }
        }

        hudElems = Array(self.menuUI["background"], self.menuUI["nautabackground"]);

        //self.menuUI["outlines"] won't always be defined, so before we try to use it to grab the elements from the array, we need to make sure it's actually defined.
        if(IsDefined(self.menuUI["outlines"]))
        {
            if(IsDefined(self.menuUI["outlines"][0]))
                hudElems[hudElems.size] = self.menuUI["outlines"][0];
            
            if(IsDefined(self.menuUI["outlines"][1]))
                hudElems[hudElems.size] = self.menuUI["outlines"][1];
        }
        
        foreach(hud in hudElems)
        {
            if(!IsDefined(hud))
                continue;
            
            if(!((self.MenuStyle == "Native" || self.MenuStyle == "AIO") && IsDefined(self.menuUI["outlines"]) && isInArray(self.menuUI["outlines"], hud)))
                hud thread hudScaleOverTime(fadeTime, hud.width, (self.MenuStyle == "Nautaremake" && hud != self.menuUI["background"]) ? 89 : 29);
            
            if(IsDefined(self.menuUI["outlines"]) && self.MenuStyle == "AIO" && hud == self.menuUI["outlines"][1])
            {
                hud thread hudMoveY(self.menuY + 29, fadeTime);

                if(IsDefined(self.menuUI["MenuName"]))
                {
                    self.menuUI["MenuName"] thread hudMoveY(self.menuY + 29, fadeTime + 0.035);
                    self.menuUI["MenuName"] thread hudFade(0, fadeTime + 0.1);
                }
            }
            
            hud thread hudFade(0, fadeTime + 0.1);
        }

        if(IsDefined(self.menuUI["outlines"]) && self.MenuStyle != "AIO")
        {
            for(a = 2; a < 6; a++)
            {
                if(!IsDefined(self.menuUI["outlines"][a]))
                    continue;
                
                if(a == 3)
                    self.menuUI["outlines"][a] thread hudMoveY((self.menuY + 28), fadeTime);
                
                if(a == 5)
                    self.menuUI["outlines"][a] thread hudMoveY((self.menuY + 48), fadeTime);
                
                self.menuUI["outlines"][a] thread hudFade(0, fadeTime + 0.1);
            }
        }

        if(IsDefined(self.menuUI["nautaicon"]))
            self.menuUI["nautaicon"] thread hudFade(0, fadeTime + 0.1);

        menuText = Array(self.menuUI["title"], self.menuUI["MenuName"]);

        foreach(hud in menuText)
        {
            if(!IsDefined(hud))
                continue;
            
            hud thread hudFade(0, fadeTime + 0.1);
        }
        
        wait (fadeTime + 0.1);
    }
    else
        self DestroyOpts();
    
    destroyAll(self.menuUI);
    self.menuUI = undefined;
    self.menuStructure = undefined;

    if(Is_True(self.isInMenu))
        self.isInMenu = BoolVar(self.isInMenu);
}

openQuickMenu1(menu)
{
    self endon("disconnect");

    self.isInQuickMenu = true;
    self.SelectedPlayer = self;

    if(!IsDefined(self.menu_parentQM))
        self.menu_parentQM = [];

    if(!IsDefined(self.currentMenuQM))
        self.currentMenuQM = (IsDefined(menu) && menu != "") ? menu : "Quick Menu";

    self.menuUI["background"] = self createRectangle("TOP", "CENTER", 0, -210, 155, 0, (0, 0, 0), 2, 0.7, "white");
    self.menuUI["scroller"] = self createRectangle("TOP", "CENTER", self.menuUI["background"].x, self.menuUI["background"].y, 155, 14, self.MainTheme, 4, 1, "white");
    self.menuUI["title"] = self createText("default", 1.4, 4, "", "CENTER", "CENTER", self.menuUI["background"].x, (self.menuUI["background"].y + 8), 1, self.MainTheme);

    self drawText();
}

closeQuickMenu()
{
    if(!self isInQuickMenu())
        return;
    
    self endon("disconnect");
    
    self DestroyOpts();
    destroyAll(self.menuUI);

    self.menuUI = undefined;
    self.menuStructure = undefined;

    if(Is_True(self.isInQuickMenu))
        self.isInQuickMenu = BoolVar(self.isInQuickMenu);
}

drawText(showAnim = false)
{
    self endon("menuClosed");
    self endon("disconnect");

    self DestroyOpts();
    self RunMenuOptions(self getCurrent());
    self SetMenuTitle();

    if(!IsDefined(self.menuStructure) || !self.menuStructure.size)
        self addOpt("No Options Found");
    
    cursor = self getCursor();
    
    if(!IsDefined(cursor))
        self setCursor(0);
    
    self.menuUI["text"] = [];
    maxOptions = self isInQuickMenu() ? 20 : self.MaxOptions;
    numOpts = (self.menuStructure.size > maxOptions) ? maxOptions : self.menuStructure.size;

    if(!self isInQuickMenu() && self.MenuStyle != "Quick Menu")
    {
        self UpdateOptCount(showAnim);
        
        self.menuUI["subMenu"] = [];
        self.menuUI["BoolOpt"] = [];
        self.menuUI["BoolBack"] = [];
        self.menuUI["IntSlider"] = [];
        self.menuUI["StringSlider"] = [];
        
        if(self getCursor() >= self.menuStructure.size)
            self setCursor((self.menuStructure.size - 1));

        half = Int(self.MaxOptions / 2);
        start = (self getCursor() >= half && self.menuStructure.size > self.MaxOptions) ? (self getCursor() + half >= self.menuStructure.size - 1) ? (self.menuStructure.size - self.MaxOptions) : (self getCursor() - (half - 1)) : 0;

        for(a = 0; a < numOpts; a++)
        {
            if(Is_True(self.menuStructure[(start + a)].boolOpt) && (self.ToggleStyle == "Boxes" || self.ToggleStyle == "Text"))
            {
                if(self.ToggleStyle == "Boxes")
                {
                    self.menuUI["BoolBack"][(a + start)] = self createRectangle("CENTER", "CENTER", (self.menuBoxLocation == "Right") ? (self.menuX + 122) : (self.menuX - 122), (self.menuY + 14) + (a * 20), 8, 8, (self.MenuStyle == "Nautaremake") ? self.MainTheme : (0.25, 0.25, 0.25), 5, 0, "white");
                    self.menuUI["BoolOpt"][(a + start)] = self createRectangle("CENTER", "CENTER", (self.menuBoxLocation == "Right") ? (self.menuX + 122) : (self.menuX - 122), (self.menuY + 14) + (a * 20), 7, 7, Is_True(self.menuStructure[(start + a)].bool) ? (self.MenuStyle == "Nautaremake") ? divideColor(85, 85, 85) : self.MainTheme : (self.MenuStyle == "Nautaremake") ? divideColor(30, 30, 30) : (0, 0, 0), 6, 0, "white");
                }
                else
                    self.menuUI["BoolOpt"][(a + start)] = self createText("default", ((a + start) == self getCursor() && Is_True(self.LargeCursor)) ? 1.2 : 1, 5, Is_True(self.menuStructure[(start + a)].bool) ? "ON" : "OFF", "RIGHT", "CENTER", (self.menuX + 126), (self.menuY + 14) + (a * 20), 0, ((start + a) == self getCursor()) ? self.ScrollingTextColor : self.OptionsColor);
            }

            if(IsDefined(self.menuStructure[(start + a)].func) && self.menuStructure[(start + a)].func == ::newMenu)
                self.menuUI["subMenu"][(a + start)] = self createText("default", ((a + start) == self getCursor() && Is_True(self.LargeCursor)) ? 1.2 : 1, 5, ">", "RIGHT", "CENTER", (self.menuX + 126), (self.menuY + 14) + (a * 20), 0, ((start + a) == self getCursor()) ? self.ScrollingTextColor : self.OptionsColor);

            if(IsDefined(self.menuStructure[(start + a)].incslider) && self.menuStructure[(start + a)].incslider)
                self.menuUI["IntSlider"][(a + start)] = self createText("default", ((a + start) == self getCursor() && Is_True(self.LargeCursor)) ? 1.2 : 1, 5, self.menuSlider[self getCurrent() + "_" + (start + a)], "RIGHT", "CENTER", (self.menuX + 126), (self.menuY + 14) + (a * 20), 0, ((start + a) == self getCursor()) ? self.ScrollingTextColor : self.OptionsColor);

            if(IsDefined(self.menuStructure[(start + a)].slider) && self.menuStructure[(start + a)].slider)
                self.menuUI["StringSlider"][(a + start)] = self createText("default", ((a + start) == self getCursor() && Is_True(self.LargeCursor)) ? 1.2 : 1, 5, "< " + self.menuStructure[(start + a)].sliderValues[self.menuSlider[self getCurrent() + "_" + (start + a)]] + " > [" + (self.menuSlider[self getCurrent() + "_" + (start + a)] + 1) + "/" + self.menuStructure[(start + a)].sliderValues.size + "]", "RIGHT", "CENTER", (self.menuX + 126), (self.menuY + 14) + (a * 20), 0, ((start + a) == self getCursor()) ? self.ScrollingTextColor : self.OptionsColor);

            self.menuUI["text"][(a + start)] = self createText("default", ((a + start) == self getCursor() && Is_True(self.LargeCursor)) ? 1.2 : 1, 5, self.menuStructure[(start + a)].name, "LEFT", "CENTER", (self.menuBoxLocation == "Right" || !Is_True(self.menuStructure[(start + a)].boolOpt) || self.ToggleStyle != "Boxes") ? (self.menuX - 126) : (self.menuX - 115), (self.menuY + 14) + (a * 20), 0, (Is_True(self.menuStructure[(start + a)].bool) && self.ToggleStyle == "Text Color") ? (IsVec(self.ToggleTextColor)) ? self.ToggleTextColor : IsString(self.ToggleTextColor) ? level.RGBFadeColor : (0, 0, 0) : ((start + a) == self getCursor()) ? self.ScrollingTextColor : self.OptionsColor);
            elems = Array(self.menuUI["BoolBack"][(a + start)], self.menuUI["BoolOpt"][(a + start)], self.menuUI["subMenu"][(a + start)], self.menuUI["IntSlider"][(a + start)], self.menuUI["StringSlider"][(a + start)], self.menuUI["text"][(a + start)]);

            foreach(elem in elems)
            {
                if(!IsDefined(elem))
                    continue;
                
                if(Is_True(showAnim))
                    elem thread hudFade(1, (a * 0.15));
                else
                    elem.alpha = 1;
            }
        }

        if(!IsDefined(self.menuUI["text"][self getCursor()]))
            self.menuCursor[self getCurrent()] = (self.menuStructure.size - 1);
        
        if(IsDefined(self.menuUI["scroller"]) && IsDefined(self.menuUI["text"][self getCursor()]))
        {
            offset = (self.MenuStyle == "AIO") ? 10 : 8;

            if(Is_True(showAnim))
                self.menuUI["scroller"] thread hudMoveY((self.menuUI["text"][self getCursor()].y - offset), 0.15);
            else
                self.menuUI["scroller"].y = (self.menuUI["text"][self getCursor()].y - offset);
        }
    }
    else
    {
        start = (self getCursor() >= maxOptions) ? (self getCursor() - (maxOptions - 1)) : 0;
        largestStr = self.menuUI["title"] GetTextWidth3arc(self);

        for(a = 0; a < numOpts; a++)
        {
            optStr = self.menuStructure[(start + a)].name;

            if(IsDefined(self.menuStructure[(start + a)].slider) || IsDefined(self.menuStructure[(start + a)].incslider))
            {
                optionString = IsDefined(self.menuStructure[(start + a)].slider) ? optStr + " < " + self.menuStructure[(start + a)].sliderValues[self.menuSlider[self getCurrent() + "_" + (start + a)]] + " > [" + (self.menuSlider[self getCurrent() + "_" + (start + a)] + 1) + "/" + self.menuStructure[(start + a)].sliderValues.size + "]" : optStr + " < " + self.menuSlider[self getCurrent() + "_" + (start + a)] + " >";
                optStr = optionString;
            }

            if(IsDefined(self.menuStructure[(start + a)].func) && self.menuStructure[(start + a)].func == ::newMenu)
                optStr += " >";

            self.menuUI["text"][(start + a)] = self createText("default", ((a + start) == self getCursor() && (Is_True(self.LargeCursor) || self isInQuickMenu())) ? 1.2 : 1, 5, optStr, "CENTER", "CENTER", self.menuUI["background"].x, ((self.menuUI["background"].y + 30) + (a * 15)), 0, Is_True(self.menuStructure[(start + a)].bool) ? IsVec(self.ToggleTextColor) ? self.ToggleTextColor : IsString(self.ToggleTextColor) ? level.RGBFadeColor : (0, 0, 0) : ((start + a) == self getCursor()) ? self.ScrollingTextColor : self.OptionsColor);

            if(Is_True(showAnim) && !self isInQuickMenu())
                self.menuUI["text"][(start + a)] thread hudFade(1, (a * 0.15));
            else
                self.menuUI["text"][(start + a)].alpha = 1;

            if(self.menuUI["text"][(start + a)] GetTextWidth3arc(self) > largestStr)
                largestStr = self.menuUI["text"][(start + a)] GetTextWidth3arc(self);
        }

        if(!IsDefined(self.menuUI["text"][self getCursor()]))
            self.menuCursor[self getCurrent()] = (self.menuStructure.size - 1);
        
        if(IsDefined(self.menuUI["scroller"]))
            self.menuUI["scroller"] SetShaderValues(undefined, largestStr);

        if(IsDefined(self.menuUI["background"]))
        {
            if(self isInQuickMenu() || !Is_True(showAnim))
            {
                self.menuUI["background"] SetShaderValues(undefined, largestStr, 23 + (numOpts * 15));
                
                if(IsDefined(self.menuUI["scroller"]) && IsDefined(self.menuUI["text"][self getCursor()]))
                    self.menuUI["scroller"].y = (self.menuUI["text"][self getCursor()].y - 6);
            }
            else
            {
                self.menuUI["background"] SetShaderValues(undefined, largestStr);
                self.menuUI["background"] thread hudScaleOverTime(0.15, largestStr, 23 + (numOpts * 15));
                
                if(IsDefined(self.menuUI["scroller"]) && IsDefined(self.menuUI["text"][self getCursor()]))
                    self.menuUI["scroller"] thread hudMoveY((self.menuUI["text"][self getCursor()].y - 6), 0.15);
            }
        }
    }

    self CreateOptionPreview();
}

ScrollingSystem(dir)
{
    self endon("disconnect");

    menu = self getCurrent();

    if(IsDefined(self.menuStructure[self getCursor()]) && IsInvalidOption(self.menuStructure[self getCursor()].name))
    {
        self setCursor(self getCursor() + dir);
        return ScrollingSystem(dir);
    }

    if(!self isInQuickMenu() && self.MenuStyle != "Quick Menu")
    {
        if(self getCursor() >= self.menuStructure.size || self getCursor() < 0)
            self setCursor((self getCursor() >= self.menuStructure.size) ? 0 : (self.menuStructure.size - 1));

        self drawText();

        if(IsDefined(self.menuUI["scroller"]) && IsDefined(self.menuUI["text"][self getCursor()]))
            self.menuUI["scroller"].y = (self.MenuStyle == "AIO") ? (self.menuUI["text"][self getCursor()].y - 10) : (self.menuUI["text"][self getCursor()].y - 8);

        self UpdateOptCount();
    }
    else
    {
        maxOptions = self isInQuickMenu() ? 20 : self.MaxOptions;

        if(self.menuCursor[menu] >= self.menuStructure.size || self.menuCursor[menu] < 0 || self.menuStructure.size > maxOptions && self.menuCursor[menu] >= (maxOptions - 1))
        {
            if(self.menuCursor[menu] >= self.menuStructure.size || self.menuCursor[menu] < 0)
                self.menuCursor[menu] = (self.menuCursor[menu] >= self.menuStructure.size) ? 0 : (self.menuStructure.size - 1);

            self drawText();
        }
        else
        {
            foreach(index, elem in self.menuUI["text"])
            {
                color = Is_True(self.menuStructure[index].bool) ? (IsString(self.ToggleTextColor) && self.ToggleTextColor == "Rainbow") ? level.RGBFadeColor : self.ToggleTextColor : (index == self getCursor()) ? self.ScrollingTextColor : self.OptionsColor;
                scale = (index == self getCursor() && (Is_True(self.LargeCursor) || self isInQuickMenu())) ? 1.2 : 1;

                if(elem.fontScale != scale)
                    elem ChangeFontscaleOverTime1(scale, 0.05);

                if(elem.color != color)
                    elem.color = color;
            }
        }

        if(IsDefined(self.menuUI["scroller"]) && IsDefined(self.menuUI["text"][self getCursor()]))
            self.menuUI["scroller"].y = (self.menuUI["text"][self getCursor()].y - 6);
        
        self CreateOptionPreview();
    }
}

CreateOptionPreview()
{
    if(Is_True(self.menuStructure[self getCursor()].preview))
    {
        if(IsDefined(self.optionPreview))
            self.optionPreview DestroyHud();
        
        previewWidth = 100;
        self.optionPreview = self createRectangle("TOP_LEFT", "CENTER", (self.menuX > 97) ? ((self.menuX - 135) - previewWidth) : ((self.menuX + (self.menuUI["background"].width / 2)) + 15), self.menuUI["scroller"].y, previewWidth, 15, (IsString(self.menuStructure[self getCursor()].color) && self.menuStructure[self getCursor()].color == "Rainbow") ? level.RGBFadeColor : self.menuStructure[self getCursor()].color, 2, 1, self.menuStructure[self getCursor()].shader);
        
        if(IsString(self.menuStructure[self getCursor()].color) && self.menuStructure[self getCursor()].color == "Rainbow")
            self.optionPreview thread HudRGBFade();
    }
    else
    {
        if(IsDefined(self.optionPreview))
            self.optionPreview DestroyHud();
        
        self.optionPreview = undefined;
    }
}

SoftLockMenu(bgHeight)
{
    if(!self hasMenu() || self hasMenu() && !self isInMenu())
        return;

    self endon("disconnect");

    self.DisableMenuControls = true;
    self DestroyOpts();

    if(self.MenuStyle == "Zodiac")
        return;
    
    if(self.MenuStyle == "Quick Menu")
        bgHeight += 10;

    if(IsDefined(self.menuUI["background"]))
    {
        self.menuUI["background"] SetShaderValues(undefined, 260, bgHeight);

        if(self.MenuStyle == "AIO")
        {
            if(IsDefined(self.menuUI["outlines"]) && IsDefined(self.menuUI["outlines"][1]))
                self.menuUI["outlines"][1].y = ((self.menuY + bgHeight) -5);
            
            if(IsDefined(self.menuUI["MenuName"]))
                self.menuUI["MenuName"].y = ((self.menuY + bgHeight) + 7);
        }
    }

    if(IsDefined(self.menuUI["nautabackground"]))
        self.menuUI["nautabackground"] SetShaderValues(undefined, undefined, (self.MenuStyle == "AIO") ? (bgHeight + 49) : (bgHeight + 60));

    if(self.MenuStyle != "Native" && self.MenuStyle != "Quick Menu" && self.MenuStyle != "AIO")
    {
        if(IsDefined(self.menuUI["outlines"][0]) || IsDefined(self.menuUI["outlines"][1]))
        {
            if(IsDefined(self.menuUI["outlines"][0]))
                self.menuUI["outlines"][0] SetShaderValues(undefined, undefined, (self.MenuStyle == "Nautaremake") ? (bgHeight + 60) : bgHeight);
            
            if(IsDefined(self.menuUI["outlines"][1]))
                self.menuUI["outlines"][1] SetShaderValues(undefined, undefined, (self.MenuStyle == "Nautaremake") ? (bgHeight + 60) : bgHeight);
        }

        if(IsDefined(self.menuUI["outlines"][3]))
            self.menuUI["outlines"][3].y = (self.menuY + (bgHeight - 1));

        if(IsDefined(self.menuUI["outlines"][5]))
            self.menuUI["outlines"][5].y = (self.menuY + (bgHeight - 1)) + 20;
    }
}

SoftUnlockMenu()
{
    if(!self hasMenu() || !self isInMenu())
        return;
    
    self endon("disconnect");

    self.menuUI["scroller"] hudMoveX((IsDefined(self.menuUI["background"]) && self.MenuStyle == "Quick Menu") ? self.menuUI["background"].x : (self.MenuStyle == "AIO") ? (self.menuX - 129) : self.menuX, 0.1);
    self.menuUI["scroller"] hudScaleOverTime(0.1, (self.MenuStyle == "Quick Menu") ? self.menuUI["background"].width : (self.MenuStyle == "AIO") ? 2 : 260, (self.MenuStyle == "Quick Menu") ? 14 : (self.MenuStyle == "AIO") ? 20 : 18);
    self.menuUI["scroller"] hudFade((self.MenuStyle == "Native") ? 0.6 : 1, 0.05);
    
    if(Is_True(self.inKeyboard))
    {
        self.inKeyboard = BoolVar(self.inKeyboard);
        self.keyboard = undefined;
    }
    
    if(Is_True(self.CreditsPlaying))
    {
        self.CreditsPlaying = BoolVar(self.CreditsPlaying);
        self.credits = undefined;
    }
    
    if(Is_True(self.DisableMenuControls))
        self.DisableMenuControls = BoolVar(self.DisableMenuControls);

    self RefreshMenu();
}

SetMenuTitle(title)
{
    self endon("disconnect");

    if(!IsDefined(self.menuUI["title"]))
        return;

    if(!IsDefined(title))
        title = self.menuTitle;

    self.menuUI["title"] SetTextString(title);

    if((!IsString(self.TitleColor) && self.menuUI["title"].color != self.TitleColor || IsString(self.TitleColor) && self.menuUI["title"].color != level.RGBFadeColor) && self.MenuStyle != "Zodiac" && self.MenuStyle != "Quick Menu" && !self isInQuickMenu())
    {
        self.menuUI["title"].color = IsString(self.TitleColor) ? level.RGBFadeColor : self.TitleColor;

        if(IsDefined(self.menuUI["MenuName"]) && self.MenuStyle == "AIO")
            self.menuUI["MenuName"].color = self.menuUI["title"].color;
    }
}

UpdateOptCount(showAnim)
{
    self endon("disconnect");

    height = (self.MenuStyle == "Zodiac") ? 1000 : ((self.menuStructure.size >= self.MaxOptions) ? self.MaxOptions : self.menuStructure.size) * 20;
    
    if(self.MenuStyle == "AIO")
        height += 6;

    //self.menuUI["outlines"] won't always be defined, so before we try to use it to grab the elements from the array, we need to make sure it's actually defined as an array.
    hudElems = IsDefined(self.menuUI["outlines"]) ? Array(self.menuUI["background"], self.menuUI["nautabackground"], self.menuUI["outlines"][0], self.menuUI["outlines"][1]) : Array(self.menuUI["background"], self.menuUI["nautabackground"]);

    if(Is_True(showAnim))
    {
        keys = GetArrayKeys(self.menuUI);

        foreach(key in keys)
        {
            if(!IsDefined(self.menuUI[key]))
                continue;
            
            if(IsArray(self.menuUI[key]))
            {
                foreach(index, hud in self.menuUI[key])
                {
                    if(IsDefined(hud))
                        hud thread hudFade((self.MenuStyle == "Zodiac") ? 0.8 : (self.MenuStyle == "Native" && key == "background") ? 0.45 : (self.MenuStyle == "AIO" && key == "nautabackground") ? 0.3 : (self.MenuStyle == "AIO" && key == "background") ? 0.4 : (self.MenuStyle == "Native" && key == "outlines" && index == 0) ? 0.8 : 1, 0.15);
                }
            }
            else
                self.menuUI[key] thread hudFade((self.MenuStyle == "Zodiac" && key == "background") ? 0.8 : (self.MenuStyle == "Native") ? (key == "background") ? 0.45 : (key == "scroller") ? 0.6 : 1 : (self.MenuStyle == "AIO" && key == "nautabackground") ? 0.3 : (self.MenuStyle == "AIO" && key == "background") ? 0.4 : 1, 0.15);
        }
    }

    foreach(hud in hudElems)
    {
        if(!IsDefined(hud) || (self.MenuStyle == "Native" || self.MenuStyle == "AIO") && isInArray(self.menuUI["outlines"], hud))
            continue;

        if(self.MenuStyle == "Native")
            height -= 11;
        
        hudHeight = (self.MenuStyle == "Nautaremake" && hud != self.menuUI["background"]) ? (69 + height) : (self.MenuStyle == "AIO" && hud == self.menuUI["nautabackground"]) ? (height + 58) : (height + 9);
        
        if(Is_True(showAnim))
            hud thread hudScaleOverTime(0.15, hud.width, hudHeight);
        else
            hud SetShaderValues(undefined, undefined, hudHeight);
        
        if(self.MenuStyle == "AIO" && hud == self.menuUI["background"] && IsDefined(self.menuUI["outlines"]))
        {
            if(IsDefined(self.menuUI["outlines"][1]))
            {
                if(Is_True(showAnim))
                {
                    self.menuUI["outlines"][1] thread hudMoveY(((self.menuY + height) + 4), 0.15);
                    
                    if(IsDefined(self.menuUI["MenuName"]))
                        self.menuUI["MenuName"] thread hudMoveY(((self.menuY + height) + 16), 0.15);
                }
                else
                {
                    self.menuUI["outlines"][1].y = ((self.menuY + height) + 4);
                    
                    if(IsDefined(self.menuUI["MenuName"]))
                        self.menuUI["MenuName"].y = ((self.menuY + height) + 16);
                }
            }
        }
    }

    if(IsDefined(self.menuUI["outlines"]) && IsDefined(self.menuUI["outlines"][3]))
    {
        if(Is_True(showAnim))
        {
            self.menuUI["outlines"][3] thread hudMoveY((self.menuY + (height + 8)), 0.15);

            if(IsDefined(self.menuUI["outlines"][5]))
                self.menuUI["outlines"][5] thread hudMoveY((self.menuY + (height + 28)), 0.15);

            wait 0.05;
        }
        else
        {
            self.menuUI["outlines"][3].y = (self.menuY + (height + 8));

            if(IsDefined(self.menuUI["outlines"][5]))
                self.menuUI["outlines"][5].y = (self.menuY + (height + 28));
        }
    }
}

RefreshMenu(menu, curs, force)
{
    self endon("disconnect");

    if(IsDefined(menu) && !IsDefined(curs) || !IsDefined(menu) && IsDefined(curs))
        return;
    
    if(IsDefined(menu) && IsDefined(curs))
    {
        foreach(player in level.players)
        {
            if(!IsDefined(player) || !IsDefined(player.menuUI) || !player hasMenu() || !player isInMenu(true) || Is_True(player.DisableMenuControls))
                continue;
            
            if(player getCurrent() == menu || self != player && player PlayerHasOption(self, menu, curs))
            {
                if(IsDefined(player.menuUI["text"][curs]) || player == self && player getCurrent() == menu && IsDefined(player.menuUI["text"][curs]) || self != player && player PlayerHasOption(self, menu, curs) || IsDefined(force) && force)
                    player thread drawText();
            }
        }
    }
    else
    {
        if(IsDefined(self) && self hasMenu() && self isInMenu(true) && !Is_True(self.DisableMenuControls))
            self thread drawText(); //if menu or cursor are undefined, it will only refresh the menu for the player it was called on
    }
}

PlayerHasOption(source, menu, curs)
{
    option = source.menuStructure[curs].name;

    if(IsDefined(self.menuStructure) && self.menuStructure.size && IsDefined(option))
    {
        for(a = 0; a < self.menuStructure.size; a++)
        {
            if(option == self.menuStructure[a].name && (source.SelectedPlayer == self || self.SelectedPlayer == self && source.SelectedPlayer == source && self getCurrent() == menu))
                return true;
        }
    }

    return false;
}

DestroyOpts()
{
    self endon("disconnect");
    
    hud = Array("text", "BoolOpt", "BoolBack", "subMenu", "IntSlider", "StringSlider");
    
    for(a = 0; a < hud.size; a++)
    {
        if(IsDefined(self.menuUI[hud[a]]) && self.menuUI[hud[a]].size)
            destroyAll(self.menuUI[hud[a]]);
        
        self.menuUI[hud[a]] = undefined;
    }

    if(IsDefined(self.optionPreview))
    {
        self.optionPreview DestroyHud();
        self.optionPreview = undefined;
    }

    self.menuStructure = undefined;
}

IsInvalidOption(text)
{
    if(!IsDefined(text))
        return true;
    
    if(!IsDefined(text.size)) //.size of localized string will be undefined -- Even if the string = "" the size should be 0
        return false;
    
    if(text == "")
        return true;
    
    for(a = 0; a < text.size; a++)
    {
        if(text[a] != " ")
            return false;
    }
    
    return true;
}

BackMenu()
{
    if(!self isInQuickMenu())
        return self.menu_parent[(self.menu_parent.size - 1)];

    return self.menu_parentQM[(self.menu_parentQM.size - 1)];
}

isInMenu(iqm)
{
    return Is_True(self.isInMenu) || IsDefined(iqm) && iqm && Is_True(self.isInQuickMenu);
}

isInQuickMenu()
{
    return Is_True(self.isInQuickMenu);
}

getCurrent()
{
    if(self isInQuickMenu())
        return self.currentMenuQM;

    return self.currentMenu;
}

getCursor()
{
    if(!IsDefined(self.menuCursor))
        self.menuCursor = [];
    
    if(!IsDefined(self.menuCursor[self getCurrent()]))
        self.menuCursor[self getCurrent()] = 0;
    
    return self.menuCursor[self getCurrent()];
}

setCursor(curs)
{
    if(!IsDefined(self.menuCursor))
        self.menuCursor = [];
    
    self.menuCursor[self getCurrent()] = curs;
}

SetSlider(dir)
{
    menu = self getCurrent();
    curs = self getCursor();
    max  = (self.menuStructure[curs].sliderValues.size - 1);

    self.menuSlider[menu + "_" + curs] += (dir > 0) ? 1 : -1;
    
    if((self.menuSlider[menu + "_" + curs] > max) || (self.menuSlider[menu + "_" + curs] < 0))
        self.menuSlider[menu + "_" + curs] = (self.menuSlider[menu + "_" + curs] > max) ? 0 : max;
    
    if(IsDefined(self.menuUI["StringSlider"][curs]))
        self.menuUI["StringSlider"][curs] SetTextString("< " + self.menuStructure[curs].sliderValues[self.menuSlider[menu + "_" + curs]] + " > [" + (self.menuSlider[menu + "_" + curs] + 1) + "/" + self.menuStructure[curs].sliderValues.size + "]");
    else
        self drawText(); //Needed To Resize Background & Refresh Sliders
}

SetIncSlider(dir)
{
    menu = self getCurrent();
    curs = self getCursor();
    
    val = self.menuStructure[curs].increment;
    max = self.menuStructure[curs].max;
    min = self.menuStructure[curs].min;
    
    if(self.menuSlider[menu + "_" + curs] < max && (self.menuSlider[menu + "_" + curs] + val) > max || (self.menuSlider[menu + "_" + curs] > min) && (self.menuSlider[menu + "_" + curs] - val) < min)
        self.menuSlider[menu + "_" + curs] = (self.menuSlider[menu + "_" + curs] < max && (self.menuSlider[menu + "_" + curs] + val) > max) ? max : min;
    else
        self.menuSlider[menu + "_" + curs] += (dir > 0) ? val : (val * -1);
    
    if((self.menuSlider[menu + "_" + curs] > max) || (self.menuSlider[menu + "_" + curs] < min))
        self.menuSlider[menu + "_" + curs] = (self.menuSlider[menu + "_" + curs] > max) ? min : max;
    
    if(IsDefined(self.menuUI["IntSlider"][curs]))
        self.menuUI["IntSlider"][curs] SetValue(self.menuSlider[menu + "_" + curs]);
    else
        self drawText(); //Needed To Resize Background & Refresh Sliders
}

newMenu(menu, dontSave)
{
    self endon("disconnect");
    self notify("EndSwitchWeaponMonitor");
    self endon("menuClosed");

    if(!IsDefined(self.menu_parent))
        self.menu_parent = [];
    
    if(!IsDefined(self.menu_parentQM))
        self.menu_parentQM = [];

    if(self getCurrent() == "Players" && IsDefined(menu))
    {
        player = level.players[self getCursor()];

        //This will make it so only the host developers can access the host's player options. Also, only the developers can access other developer's player options.
        if(player IsHost() && !self IsHost() && !self IsDeveloper() || player isDeveloper() && !self isDeveloper())
            return self iPrintlnBold("^1ERROR: ^7Access Denied");

        self.SelectedPlayer = player;
        self.SavedSelectedPlayer = player; //Fix for force closing the menu while navigating a players options and opening the quick menu.
    }
    else if(self getCurrent() == "Players" && !IsDefined(menu))
        self.SelectedPlayer = self;
    else if(self isInMenu(false) && isInArray(self.menu_parent, "Players"))
        self.SelectedPlayer = self.SavedSelectedPlayer;
    
    if(!IsDefined(menu))
    {
        menu = self BackMenu();

        if(self getCursor() <= self.MaxOptions)
            self.menuCursor[self getCurrent()] = undefined;
        
        if(!self isInQuickMenu())
            self.menu_parent[(self.menu_parent.size - 1)] = undefined;
        else
            self.menu_parentQM[(self.menu_parentQM.size - 1)] = undefined;
    }
    else
    {
        if(!IsDefined(dontSave) || IsDefined(dontSave) && !dontSave)
        {
            if(!self isInQuickMenu())
                self.menu_parent[self.menu_parent.size] = self getCurrent();
            else
                self.menu_parentQM[self.menu_parentQM.size] = self getCurrent();
        }
    }

    for(a = 0; a < self.menuStructure.size; a++)
    {
        if(!IsDefined(self.menuStructure[a]) || !Is_True(self.menuStructure[a].incslider))
            continue;

        if(IsDefined(self.menuSlider[menu + "_" + a]) && self.menuSlider[menu + "_" + a] == self.menuStructure[a].start)
            self.menuSlider[menu + "_" + a] = undefined;
    }
    
    if(!self isInQuickMenu())
        self.currentMenu = menu;
    else
        self.currentMenuQM = menu;

    refresh = IsVerkoMap() ? Array("Weaponry") : Array("Weapon Options", "Weapon Attachments", "Weapon AAT");

    if(isInArray(refresh, menu)) //Submenus that should be refreshed when player switches weapons
    {
        player = self.SelectedPlayer;

        if(IsDefined(player))
            player thread WatchMenuWeaponSwitch(menu, self);
    }

    if(menu == "Players" && !Is_True(self.PlayerInfoHandler))
        self thread PlayerInfoHandler();
    
    self DestroyOpts();
    self drawText();
    self SetMenuTitle();
}

WatchMenuWeaponSwitch(menu, player)
{
    player endon("disconnect");
    player endon("menuClosed");
    player endon("EndSwitchWeaponMonitor");

    while(self getCurrent() == menu)
    {
        self waittill("weapon_change", newWeapon);

        if(player getCurrent() == menu)
            player RefreshMenu(player getCurrent(), player getCursor(), true);
    }
}

PlayerInfoHandler()
{
    if(Is_True(self.PlayerInfoHandler) || Is_True(level.DisablePlayerInfo))
        return;
    self.PlayerInfoHandler = true;

    self endon("disconnect");
    self endon("EndPlayerInfoHandler");

    wait 0.1; //buffer (needed)
    bgTempX = 0;

    self.playerInfoHud = [];

    while(self isInMenu() && self getCurrent() == "Players" && !Is_True(level.DisablePlayerInfo))
    {
        player = level.players[self getCursor()];
        infoString = (IsDefined(player) && IsPlayer(player)) ? (player IsHost() || player isDeveloper()) ? "N / A" : player BuildInfoString() : "^1PLAYER NOT FOUND";

        if(!IsDefined(self.playerInfoHud["background"]))
            self.playerInfoHud["background"] = self createRectangle("TOP_LEFT", "CENTER", bgTempX, self.menuUI["scroller"].y, 0, 0, (0, 0, 0), 2, 1, "white");
        
        if(!IsDefined(self.playerInfoHud["outline"]))
            self.playerInfoHud["outline"] = self createRectangle("TOP_LEFT", "CENTER", (bgTempX - 1), (self.menuUI["scroller"].y - 1), 0, 0, self.MainTheme, 1, 1, "white");
        
        if(!IsDefined(self.playerInfoHud["string"]))
            self.playerInfoHud["string"] = self createText("default", 1.2, 3, "", "LEFT", "CENTER", (self.playerInfoHud["background"].x + 2), self.playerInfoHud["background"].y + 6, 1, (1, 1, 1));

        if(self.playerInfoHud["string"].text != infoString)
            self.playerInfoHud["string"] SetTextString(infoString);
        
        width = self.playerInfoHud["string"] GetTextWidth3arc(self);
        bgTempX = (self.menuX > 97) ? ((self.menuX - 135) - width) : ((self.menuX + (self.menuUI["background"].width / 2)) + 15);

        if(self.playerInfoHud["background"].y != self.menuUI["scroller"].y || self.playerInfoHud["background"].x != bgTempX)
        {
            self.playerInfoHud["background"].y = self.menuUI["scroller"].y;
            self.playerInfoHud["outline"].y = (self.menuUI["scroller"].y - 1);
            self.playerInfoHud["string"].y = self.playerInfoHud["background"].y + 6;

            self.playerInfoHud["background"].x = bgTempX;
            self.playerInfoHud["outline"].x = (bgTempX - 1);
            self.playerInfoHud["string"].x = (self.playerInfoHud["background"].x + 2);
        }
        
        if(self.playerInfoHud["background"].width != width || self.playerInfoHud["background"].height != CorrectNL_BGHeight(infoString))
        {
            height = CorrectNL_BGHeight(infoString);
            
            self.playerInfoHud["background"] SetShaderValues(undefined, width, height);
            self.playerInfoHud["outline"] SetShaderValues(undefined, (width + 2), (height + 2));
        }

        wait 0.01;
    }

    if(IsDefined(self.playerInfoHud["background"]))
        self.playerInfoHud["background"] DestroyHud();
    
    if(IsDefined(self.playerInfoHud["outline"]))
        self.playerInfoHud["outline"] DestroyHud();

    if(IsDefined(self.playerInfoHud["string"]))
        self.playerInfoHud["string"] DestroyHud();

    if(Is_True(self.PlayerInfoHandler))
        self.PlayerInfoHandler = BoolVar(self.PlayerInfoHandler);
    
    self.playerInfoHud = undefined;
}

BuildInfoString()
{
    strng = "";
    strng += "^1PLAYER INFO:";
    strng += "\n^7Name: ^2" + CleanName(self getName());
    strng += "\n^7Verification: ^2" + self.accessLevel;

    if(Is_True(level.IncludeIPInfo))
        strng += "\n^7IP: ^2" + StrTok(self GetIPAddress(), "Public Addr: ")[0];
    
    strng += "\n^7XUID: ^2" + self GetXUID();
    strng += "\n^7STEAM ID: ^2" + self GetXUID(1);
    strng += "\n^7Controller: ^2" + self GamepadUsedLast() ? "Yes" : "No";
    strng += "\n^7Weapon: ^2" + StrTok(self GetCurrentWeapon().name, "+")[0]; //Can't use the displayname

    //I set it up like this for better organization, and to make it easier to add more display strings
    //Make sure you add \n before every new string you add

    return strng;
}

AreButtonsPressed(btnArray)
{
    pressed = false;

    foreach(buttonString in btnArray)
    {
        switch(buttonString)
        {
            case "+actionslot 1":
                pressed = self ActionSlotOneButtonPressed();
                break;
            
            case "+actionslot 2":
                pressed = self ActionSlotTwoButtonPressed();
                break;
            
            case "+actionslot 3":
                pressed = self ActionSlotThreeButtonPressed();
                break;
            
            case "+actionslot 4":
                pressed = self ActionslotFourButtonPressed();
                break;
            
            case "+melee":
                pressed = self MeleeButtonPressed();
                break;
            
            case "+speed_throw":
                pressed = self AdsButtonPressed();
                break;
            
            case "+attack":
                pressed = self AttackButtonPressed();
                break;
            
            case "+breath_sprint":
                pressed = self SprintButtonPressed();
                break;
            
            case "+activate":
                pressed = self UseButtonPressed();
                break;
            
            case "+frag":
                pressed = self FragButtonPressed();
                break;
            
            case "+stance":
                pressed = self StanceButtonPressed();
                break;
            
            default:
                pressed = true;
                break;
        }

        if(!pressed) //After checking either button, if this variable is still false, then the player didn't press the opening bind(s)
            return false;
    }

    return true;
}

SetOpenButtons(buttonString)
{
    buttonIndex = (self.OpenControlIndex - 1);

    if(!buttonIndex && buttonString == "None")
        return self iPrintlnBold("^1ERROR: ^7Button 1 Can't Be Set To None");
    
    if(isInArray(self.OpenControls, buttonString) && buttonString != "None")
        return self iPrintlnBold("^1ERROR: ^7This Button Is Already Being Used");
    
    if(buttonIndex && !IsDefined(self.OpenControls[(buttonIndex - 1)])) //Makes sure the player has selected slots in the correct order
        return self iPrintlnBold("^1ERROR: ^7You Need To Fill Bind Slot " + buttonIndex + " First");
    
    if(buttonString == "None") //If the player clears a slot, then we want to clear the following slots as well
    {
        saved = [];

        for(a = 0; a < buttonIndex; a++)
        {
            if(a == buttonIndex)
                break;
            
            saved[saved.size] = self.OpenControls[a];
        }

        self.OpenControls = saved;
        self SaveMenuTheme();
        return;
    }
    
    self.OpenControls[buttonIndex] = buttonString;
    self SaveMenuTheme();
}

OpenControlIndex(index)
{
    self.OpenControlIndex = index;
    self RefreshMenu(self getCurrent(), self getCursor());
}
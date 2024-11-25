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
                if(self AdsButtonPressed() && self MeleeButtonPressed() && Is_Alive(self))
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
                    if(isDefined(self.menuStructure[curs]) && isDefined(self.menuStructure[curs].func))
                    {
                        if(isDefined(self.menuStructure[curs].slider) || isDefined(self.menuStructure[curs].incslider))
                            self ExeFunction(self.menuStructure[curs].func, isDefined(self.menuStructure[curs].slider) ? self.menuStructure[curs].sliderValues[self.menuSS[menu + "_" + curs]] : self.menuSS[menu + "_" + curs], self.menuStructure[curs].input1, self.menuStructure[curs].input2, self.menuStructure[curs].input3, self.menuStructure[curs].input4);
                        else
                        {
                            self ExeFunction(self.menuStructure[curs].func, self.menuStructure[curs].input1, self.menuStructure[curs].input2, self.menuStructure[curs].input3, self.menuStructure[curs].input4);

                            if(isDefined(self.menuStructure[curs]) && isDefined(self.menuStructure[curs].bool))
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
                    if(isDefined(self.menuStructure[curs].slider) || isDefined(self.menuStructure[curs].incslider))
                    {
                        dir = self ActionslotThreeButtonPressed() ? -1 : 1;

                        if(isDefined(self.menuStructure[curs].slider))
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

openMenu1(showAnim)
{
    self endon("disconnect");

    self.isInMenu = true;
    wait 0.05;

    if(!isDefined(self.currentMenu) || self.currentMenu == "")
        self.currentMenu = "Main";

    if(isInArray(self.menuParent, "Players") && isDefined(self.SavedSelectedPlayer))
        self.SelectedPlayer = self.SavedSelectedPlayer;

    if(self.MenuStyle != "Quick Menu")
    {
        self.menuHud["background"] = self createRectangle("TOP", "CENTER", self.menuX, (self.MenuStyle == "Zodiac") ? (self.menuY - 60) : (self.MenuStyle == "Native") ? (self.menuY + 6) : self.menuY, 260, 0, (self.MenuStyle == "Nautaremake") ? divideColor(25, 25, 25) : (0, 0, 0), 2, (isDefined(showAnim) && showAnim) ? 0 : (self.MenuStyle == "Zodiac") ? 0.8 : (self.MenuStyle == "Native") ? 0.35 : 1, "white");

        if(self.MenuStyle == "Nautaremake")
        {
            self.menuHud["nautabackground"] = self createRectangle("TOP", "CENTER", self.menuX, (self.menuY - 40), 260, 0, divideColor(45, 45, 45), 1, (isDefined(showAnim) && showAnim) ? 0 : 1, "white");
            self.menuHud["nautaicon"] = self createRectangle("TOP", "CENTER", self.menuX, (self.menuY - 57), 32, 54, (1, 1, 1), 4, (isDefined(showAnim) && showAnim) ? 0 : 1, "damage_feedback_tac");
        }

        if(self.MenuStyle != "Zodiac")
        {
            self.menuHud["outlines"] = [];

            if(self.MenuStyle != "Native")
            {
                //Left Side
                self.menuHud["outlines"][self.menuHud["outlines"].size] = self createRectangle("TOP", "CENTER", (self.menuX - 130), (self.MenuStyle == "Nautaremake") ? (self.menuY - 40) : self.menuY, 1, 0, self.MainColor, 5, (isDefined(showAnim) && showAnim) ? 0 : 1, "white");

                //Right Side
                self.menuHud["outlines"][self.menuHud["outlines"].size] = self createRectangle("TOP", "CENTER", (self.menuX + 130), (self.MenuStyle == "Nautaremake") ? (self.menuY - 40) : self.menuY, 1, 0, self.MainColor, 5, (isDefined(showAnim) && showAnim) ? 0 : 1, "white");
            }

            //Top 2 || Native Design Banner
            self.menuHud["outlines"][self.menuHud["outlines"].size] = self createRectangle("TOP", "CENTER", self.menuX, (self.MenuStyle == "Nautaremake") ? self.menuY : (self.MenuStyle == "Native") ? (self.menuY - 50) : (self.menuY - 13), (self.MenuStyle == level.menuName) ? 261 : 260, (self.MenuStyle == "Nautaremake") ? 1 : (self.MenuStyle == "Native") ? 39 : 16, self.MainColor, 5, (isDefined(showAnim) && showAnim) ? 0 : 1, "white");

            //Bottom 1
            if(self.MenuStyle != "Native")
                self.menuHud["outlines"][self.menuHud["outlines"].size] = self createRectangle("TOP", "CENTER", self.menuX, self.menuY, 260, 1, self.MainColor, 5, (isDefined(showAnim) && showAnim) ? 0 : 1, "white");

            if(self.MenuStyle == "Nautaremake" || self.MenuStyle == "Native")
            {
                //Top 1 || Native Design Title Bar
                self.menuHud["outlines"][self.menuHud["outlines"].size] = self createRectangle("TOP", "CENTER", self.menuX, (self.MenuStyle == "Native") ? (self.menuY - 11) : (self.menuY - 40), 260, (self.MenuStyle == "Native") ? 17 : 1, (self.MenuStyle == "Native") ? (0, 0, 0) : self.MainColor, 6, (isDefined(showAnim) && showAnim) ? 0 : 1, "white");

                //Bottom 2
                if(self.MenuStyle == "Nautaremake")
                    self.menuHud["outlines"][self.menuHud["outlines"].size] = self createRectangle("TOP", "CENTER", self.menuX, self.menuY, 260, 1, self.MainColor, 5, (isDefined(showAnim) && showAnim) ? 0 : 1, "white");
            }
        }

        self.menuHud["scroller"] = self createRectangle("TOP", "CENTER", self.menuX, (self.menuY + 6), 260, 18, (self.MenuStyle == "Nautaremake") ? divideColor(45, 45, 45) : self.MainColor, 4, (isDefined(showAnim) && showAnim) ? 0 : 1, "white");

        if(self.MenuStyle != "Nautaremake")
            self.menuHud["title"] = self createText("default", (self.MenuStyle == "Native") ? 1.2 : self.TitleFontScale, 7, "", (self.MenuStyle == "Native") ? "CENTER" : "LEFT", "CENTER", (self.MenuStyle == "Native") ? self.menuX : (self.menuX - 126), (self.MenuStyle == "Native") ? (self.menuY - 3) : (self.MenuStyle == "Zodiac") ? (self.menuY - 20) : (self.menuY - 6), (isDefined(showAnim) && showAnim) ? 0 : 1, (self.MenuStyle == "Zodiac") ? self.MainColor : (isDefined(self.TitleColor) && IsVec(self.TitleColor)) ? self.TitleColor : IsString(self.TitleColor) ? level.RGBFadeColor : (0, 0, 0));

        if(self.MenuStyle == "Native")
            self.menuHud["MenuName"] = self createText("default", self.TitleFontScale, 7, level.menuName, "CENTER", "CENTER", self.menuX, (self.menuY - 31), (isDefined(showAnim) && showAnim) ? 0 : 1, (1, 1, 1));
    }
    else
    {
        self.menuHud["background"] = self createRectangle("TOP", "CENTER", self.menuX, self.menuY, 155, 0, (0, 0, 0), 2, 0.7, "white");
        self.menuHud["scroller"] = self createRectangle("TOP", "CENTER", self.menuX, (self.menuY + 24), 155, 14, self.MainColor, 4, 1, "white");
        self.menuHud["title"] = self createText("default", self.TitleFontScale, 4, "", "CENTER", "CENTER", self.menuX, (self.menuHud["background"].y + 8), 1, self.MainColor);
    }

    self drawText(showAnim);

    if(self getCurrent() == "Players" && !Is_True(self.PlayerInfoHandler))
        self thread PlayerInfoHandler();
}

closeMenu1(showAnim)
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
            self.inKeyboard = BoolVar(self.inKeyboard);
        }
        
        if(Is_True(self.CreditsPlaying))
        {
            destroyAll(self.credits);
            self.CreditsPlaying = BoolVar(self.CreditsPlaying);
        }
        
        if(Is_True(self.DisableMenuControls))
            self.DisableMenuControls = BoolVar(self.DisableMenuControls);
    }

    if(isDefined(showAnim) && showAnim)
    {
        if(isDefined(self.menuHud["scroller"]))
            self.menuHud["scroller"] DestroyHud();
        
        hudElems = Array(self.menuHud["BoolBack"], self.menuHud["BoolOpt"], self.menuHud["subMenu"], self.menuHud["IntSlider"], self.menuHud["StringSlider"], self.menuHud["text"]);
        fadeTime = 0.35;

        foreach(hud in hudElems)
        {
            if(!isDefined(hud) || !IsArray(hud) || !hud.size)
                continue;
            
            indexf = 0;

            foreach(index, hude in hud)
                if(isDefined(hude))
                {
                    indexf++;
                    hude thread hudFade(0, ((fadeTime + 0.1) / indexf));
                }
        }

        hudElems = Array(self.menuHud["background"], self.menuHud["nautabackground"]);

        //self.menuHud["outlines"] won't always be defined, so before we try to use it to grab the elements from the array, we need to make sure it's actually defined.
        if(isDefined(self.menuHud["outlines"]))
        {
            hudElems[hudElems.size] = self.menuHud["outlines"][0];
            hudElems[hudElems.size] = self.menuHud["outlines"][1];
        }
        
        foreach(hud in hudElems)
        {
            if(!isDefined(hud))
                continue;
            
            if(!(self.MenuStyle == "Native" && isInArray(self.menuHud["outlines"], hud)))
                hud thread hudScaleOverTime(fadeTime, hud.width, (self.MenuStyle == "Nautaremake" && hud != self.menuHud["background"]) ? 89 : 29);
            
            hud thread hudFade(0, fadeTime + 0.1);
        }

        if(isDefined(self.menuHud["outlines"]))
        {
            for(a = 2; a < 6; a++)
            {
                if(!isDefined(self.menuHud["outlines"][a]))
                    continue;
                
                if(a == 3)
                    self.menuHud["outlines"][a] thread hudMoveY((self.menuY + 28), fadeTime);
                
                if(a == 5)
                    self.menuHud["outlines"][a] thread hudMoveY((self.menuY + 48), fadeTime);
                
                self.menuHud["outlines"][a] thread hudFade(0, fadeTime + 0.1);
            }
        }

        if(isDefined(self.menuHud["nautaicon"]))
            self.menuHud["nautaicon"] thread hudFade(0, fadeTime + 0.1);

        menuText = Array(self.menuHud["title"], self.menuHud["MenuName"]);

        foreach(hud in menuText)
        {
            if(!isDefined(hud))
                continue;
            
            hud thread hudFade(0, fadeTime + 0.1);
        }
        
        wait (fadeTime + 0.1);
    }
    else
        self DestroyOpts();
    
    destroyAll(self.menuHud);

    if(Is_True(self.isInMenu))
        self.isInMenu = BoolVar(self.isInMenu);
}

openQuickMenu1(menu)
{
    self endon("disconnect");

    self.isInQuickMenu = true;
    self.SelectedPlayer = self;

    if(!isDefined(self.currentMenuQM))
        self.currentMenuQM = (isDefined(menu) && menu != "") ? menu : "Quick Menu";

    qmX = 0;
    qmY = -210;

    self.menuHud["background"] = self createRectangle("TOP", "CENTER", qmX, qmY, 155, 0, (0, 0, 0), 2, 0.7, "white");
    self.menuHud["scroller"] = self createRectangle("TOP", "CENTER", self.menuHud["background"].x, self.menuHud["background"].y, 155, 14, self.MainColor, 4, 1, "white");
    self.menuHud["title"] = self createText("default", 1.4, 4, "", "CENTER", "CENTER", self.menuHud["background"].x, (self.menuHud["background"].y + 8), 1, self.MainColor);

    self drawText();
}

closeQuickMenu()
{
    if(!self isInQuickMenu())
        return;
    
    self endon("disconnect");
    
    self DestroyOpts();
    destroyAll(self.menuHud);

    if(Is_True(self.isInQuickMenu))
        self.isInQuickMenu = BoolVar(self.isInQuickMenu);
}

drawText(showAnim)
{
    self endon("menuClosed");
    self endon("disconnect");

    self DestroyOpts();
    self runMenuIndex(self getCurrent());
    self SetMenuTitle();

    if(!isDefined(self.menuStructure) || !self.menuStructure.size)
        self addOpt("No Options Found");
    
    cursor = self getCursor();
    
    if(!isDefined(cursor))
        self setCursor(0);
    
    if(!isDefined(self.menuHud["text"]))
        self.menuHud["text"] = [];
    
    maxOptions = self isInQuickMenu() ? 20 : self.MaxOptions;
    numOpts = (self.menuStructure.size > maxOptions) ? maxOptions : self.menuStructure.size;

    if(!self isInQuickMenu() && self.MenuStyle != "Quick Menu")
    {
        self UpdateOptCount(showAnim);
        
        if(!isDefined(self.menuHud["subMenu"]))
            self.menuHud["subMenu"] = [];
        
        if(!isDefined(self.menuHud["BoolOpt"]))
            self.menuHud["BoolOpt"] = [];
        
        if(!isDefined(self.menuHud["BoolBack"]))
            self.menuHud["BoolBack"] = [];
        
        if(!isDefined(self.menuHud["IntSlider"]))
            self.menuHud["IntSlider"] = [];
        
        if(!isDefined(self.menuHud["StringSlider"]))
            self.menuHud["StringSlider"] = [];
        
        if(self getCursor() >= self.menuStructure.size)
            self setCursor((self.menuStructure.size - 1));

        half = Int(self.MaxOptions / 2);
        start = (self getCursor() >= half && self.menuStructure.size > self.MaxOptions) ? (self getCursor() + half >= self.menuStructure.size - 1) ? (self.menuStructure.size - self.MaxOptions) : (self getCursor() - (half - 1)) : 0;

        for(a = 0; a < numOpts; a++)
        {
            if(isDefined(self.menuStructure[(start + a)].bool) && (self.ToggleStyle == "Boxes" || self.ToggleStyle == "Text"))
            {
                if(self.ToggleStyle == "Boxes")
                {
                    self.menuHud["BoolBack"][(a + start)] = self createRectangle("CENTER", "CENTER", (self.menuX + 122), (self.menuY + 14) + (a * 20), 8, 8, (self.MenuStyle == "Nautaremake") ? self.MainColor : (0.25, 0.25, 0.25), 5, 0, "white");
                    self.menuHud["BoolOpt"][(a + start)] = self createRectangle("CENTER", "CENTER", (self.menuX + 122), (self.menuY + 14) + (a * 20), 7, 7, (isDefined(self.menuStructure[(start + a)].bool) && self.menuStructure[(start + a)].bool) ? (self.MenuStyle == "Nautaremake") ? divideColor(85, 85, 85) : self.MainColor : (self.MenuStyle == "Nautaremake") ? divideColor(30, 30, 30) : (0, 0, 0), 6, 0, "white");
                }
                else
                    self.menuHud["BoolOpt"][(a + start)] = self createText("default", ((a + start) == self getCursor() && Is_True(self.LargeCursor)) ? 1.2 : 1, 5, self.menuStructure[(start + a)].bool ? "ON" : "OFF", "RIGHT", "CENTER", (self.menuX + 126), (self.menuY + 14) + (a * 20), 0, ((start + a) == self getCursor()) ? self.ScrollingTextColor : self.OptionsColor);
            }

            if(isDefined(self.menuStructure[(start + a)].func) && self.menuStructure[(start + a)].func == ::newMenu)
                self.menuHud["subMenu"][(a + start)] = self createText("default", ((a + start) == self getCursor() && Is_True(self.LargeCursor)) ? 1.2 : 1, 5, ">", "RIGHT", "CENTER", (self.menuX + 126), (self.menuY + 14) + (a * 20), 0, ((start + a) == self getCursor()) ? self.ScrollingTextColor : self.OptionsColor);

            if(isDefined(self.menuStructure[(start + a)].incslider) && self.menuStructure[(start + a)].incslider)
                self.menuHud["IntSlider"][(a + start)] = self createText("default", ((a + start) == self getCursor() && Is_True(self.LargeCursor)) ? 1.2 : 1, 5, self.menuSS[self getCurrent() + "_" + (start + a)], "RIGHT", "CENTER", (self.menuX + 126), (self.menuY + 14) + (a * 20), 0, ((start + a) == self getCursor()) ? self.ScrollingTextColor : self.OptionsColor);

            if(isDefined(self.menuStructure[(start + a)].slider) && self.menuStructure[(start + a)].slider)
                self.menuHud["StringSlider"][(a + start)] = self createText("default", ((a + start) == self getCursor() && Is_True(self.LargeCursor)) ? 1.2 : 1, 5, "< " + self.menuStructure[(start + a)].sliderValues[self.menuSS[self getCurrent() + "_" + (start + a)]] + " > [" + (self.menuSS[self getCurrent() + "_" + (start + a)] + 1) + "/" + self.menuStructure[(start + a)].sliderValues.size + "]", "RIGHT", "CENTER", (self.menuX + 126), (self.menuY + 14) + (a * 20), 0, ((start + a) == self getCursor()) ? self.ScrollingTextColor : self.OptionsColor);
            
            self.menuHud["text"][(a + start)] = self createText("default", ((a + start) == self getCursor() && Is_True(self.LargeCursor)) ? 1.2 : 1, 5, self.menuStructure[(start + a)].name, "LEFT", "CENTER", (self.menuX - 126), (self.menuY + 14) + (a * 20), 0, (isDefined(self.menuStructure[(start + a)].bool) && self.menuStructure[(start + a)].bool && self.ToggleStyle == "Text Color") ? (IsVec(self.ToggleTextColor)) ? self.ToggleTextColor : IsString(self.ToggleTextColor) ? level.RGBFadeColor : (0, 0, 0) : ((start + a) == self getCursor()) ? self.ScrollingTextColor : self.OptionsColor);
            elems = Array(self.menuHud["BoolBack"][(a + start)], self.menuHud["BoolOpt"][(a + start)], self.menuHud["subMenu"][(a + start)], self.menuHud["IntSlider"][(a + start)], self.menuHud["StringSlider"][(a + start)], self.menuHud["text"][(a + start)]);

            foreach(elem in elems)
            {
                if(!isDefined(elem))
                    continue;
                
                if(isDefined(showAnim) && showAnim)
                    elem thread hudFade(1, (a * 0.15));
                else
                    elem.alpha = 1;
            }
        }

        if(!isDefined(self.menuHud["text"][self getCursor()]))
            self.menuCurs[self getCurrent()] = (self.menuStructure.size - 1);
        
        if(isDefined(self.menuHud["scroller"]) && isDefined(self.menuHud["text"][self getCursor()]))
        {
            if(isDefined(showAnim) && showAnim)
                self.menuHud["scroller"] thread hudMoveY((self.menuHud["text"][self getCursor()].y - 8), 0.15);
            else
                self.menuHud["scroller"].y = (self.menuHud["text"][self getCursor()].y - 8);
        }
    }
    else
    {
        start = (self getCursor() >= maxOptions) ? (self getCursor() - (maxOptions - 1)) : 0;
        largestStr = self.menuHud["title"] GetTextWidth3arc(self);

        for(a = 0; a < numOpts; a++)
        {
            optStr = self.menuStructure[(start + a)].name;

            if(isDefined(self.menuStructure[(start + a)].slider) || isDefined(self.menuStructure[(start + a)].incslider))
            {
                optionString = isDefined(self.menuStructure[(start + a)].slider) ? optStr + " < " + self.menuStructure[(start + a)].sliderValues[self.menuSS[self getCurrent() + "_" + (start + a)]] + " > [" + (self.menuSS[self getCurrent() + "_" + (start + a)] + 1) + "/" + self.menuStructure[(start + a)].sliderValues.size + "]" : optStr + " < " + self.menuSS[self getCurrent() + "_" + (start + a)] + " >";
                optStr = optionString;
            }

            if(isDefined(self.menuStructure[(start + a)].func) && self.menuStructure[(start + a)].func == ::newMenu)
                optStr += " >";

            self.menuHud["text"][(start + a)] = self createText("default", ((a + start) == self getCursor() && (Is_True(self.LargeCursor) || self isInQuickMenu())) ? 1.2 : 1, 5, optStr, "CENTER", "CENTER", self.menuHud["background"].x, ((self.menuHud["background"].y + 30) + (a * 15)), 0, (isDefined(self.menuStructure[(start + a)].bool) && self.menuStructure[(start + a)].bool) ? IsVec(self.ToggleTextColor) ? self.ToggleTextColor : IsString(self.ToggleTextColor) ? level.RGBFadeColor : (0, 0, 0) : ((start + a) == self getCursor()) ? self.ScrollingTextColor : self.OptionsColor);

            if(isDefined(showAnim) && showAnim && !self isInQuickMenu())
                self.menuHud["text"][(start + a)] thread hudFade(1, (a * 0.15));
            else
                self.menuHud["text"][(start + a)].alpha = 1;

            if(self.menuHud["text"][(start + a)] GetTextWidth3arc(self) > largestStr)
                largestStr = self.menuHud["text"][(start + a)] GetTextWidth3arc(self);
        }

        if(!isDefined(self.menuHud["text"][self getCursor()]))
            self.menuCurs[self getCurrent()] = (self.menuStructure.size - 1);
        
        if(isDefined(self.menuHud["scroller"]))
            self.menuHud["scroller"] SetShaderValues(undefined, largestStr);

        if(isDefined(self.menuHud["background"]))
        {
            if(self isInQuickMenu() || !isDefined(showAnim) || !showAnim)
            {
                self.menuHud["background"] SetShaderValues(undefined, largestStr, 23 + (numOpts * 15));
                
                if(isDefined(self.menuHud["scroller"]) && isDefined(self.menuHud["text"][self getCursor()]))
                    self.menuHud["scroller"].y = (self.menuHud["text"][self getCursor()].y - 6);
            }
            else
            {
                self.menuHud["background"] SetShaderValues(undefined, largestStr);
                self.menuHud["background"] thread hudScaleOverTime(0.15, largestStr, 23 + (numOpts * 15));
                
                if(isDefined(self.menuHud["scroller"]) && isDefined(self.menuHud["text"][self getCursor()]))
                    self.menuHud["scroller"] thread hudMoveY((self.menuHud["text"][self getCursor()].y - 6), 0.15);
            }
        }
    }
}

ScrollingSystem(dir)
{
    self endon("disconnect");

    menu = self getCurrent();

    if(isDefined(self.menuStructure[self getCursor()]) && IsInvalidOption(self.menuStructure[self getCursor()].name))
    {
        self setCursor(self getCursor() + dir);
        return ScrollingSystem(dir);
    }

    if(!self isInQuickMenu() && self.MenuStyle != "Quick Menu")
    {
        if(self getCursor() >= self.menuStructure.size || self getCursor() < 0)
            self setCursor((self getCursor() >= self.menuStructure.size) ? 0 : (self.menuStructure.size - 1));

        self drawText();

        if(isDefined(self.menuHud["scroller"]) && isDefined(self.menuHud["text"][self getCursor()]))
            self.menuHud["scroller"].y = (self.menuHud["text"][self getCursor()].y - 8);

        self UpdateOptCount();
    }
    else
    {
        maxOptions = self isInQuickMenu() ? 20 : self.MaxOptions;

        if(self.menuCurs[menu] >= self.menuStructure.size || self.menuCurs[menu] < 0 || self.menuStructure.size > maxOptions && self.menuCurs[menu] >= (maxOptions - 1))
        {
            if(self.menuCurs[menu] >= self.menuStructure.size || self.menuCurs[menu] < 0)
                self.menuCurs[menu] = (self.menuCurs[menu] >= self.menuStructure.size) ? 0 : (self.menuStructure.size - 1);

            self drawText();
        }
        else
        {
            foreach(index, elem in self.menuHud["text"])
            {
                color = (isDefined(self.menuStructure[index].bool) && self.menuStructure[index].bool) ? (IsString(self.ToggleTextColor) && self.ToggleTextColor == "Rainbow") ? level.RGBFadeColor : self.ToggleTextColor : (index == self getCursor()) ? self.ScrollingTextColor : self.OptionsColor;
                scale = (index == self getCursor() && (Is_True(self.LargeCursor) || self isInQuickMenu())) ? 1.2 : 1;

                if(elem.fontScale != scale)
                    elem ChangeFontscaleOverTime1(scale, 0.05);

                if(elem.color != color)
                    elem.color = color;
            }
        }

        if(isDefined(self.menuHud["scroller"]) && isDefined(self.menuHud["text"][self getCursor()]))
            self.menuHud["scroller"].y = (self.menuHud["text"][self getCursor()].y - 6);
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

    if(isDefined(self.menuHud["background"]))
        self.menuHud["background"] SetShaderValues(undefined, 260, bgHeight);

    if(isDefined(self.menuHud["nautabackground"]))
        self.menuHud["nautabackground"] SetShaderValues(undefined, undefined, (bgHeight + 60));

    if(self.MenuStyle != "Native" && self.MenuStyle != "Quick Menu")
    {
        if(isDefined(self.menuHud["outlines"][0]) || isDefined(self.menuHud["outlines"][1]))
        {
            if(isDefined(self.menuHud["outlines"][0]))
                self.menuHud["outlines"][0] SetShaderValues(undefined, undefined, (self.MenuStyle == "Nautaremake") ? (bgHeight + 60) : bgHeight);
            
            if(isDefined(self.menuHud["outlines"][1]))
                self.menuHud["outlines"][1] SetShaderValues(undefined, undefined, (self.MenuStyle == "Nautaremake") ? (bgHeight + 60) : bgHeight);
        }

        if(isDefined(self.menuHud["outlines"][3]))
            self.menuHud["outlines"][3].y = (self.menuY + (bgHeight - 1));

        if(isDefined(self.menuHud["outlines"][5]))
            self.menuHud["outlines"][5].y = (self.menuY + (bgHeight - 1)) + 20;
    }
}

SoftUnlockMenu()
{
    if(!self hasMenu() || !self isInMenu())
        return;
    
    self endon("disconnect");

    self.menuHud["scroller"] hudMoveX((isDefined(self.menuHud["background"]) && self.MenuStyle == "Quick Menu") ? self.menuHud["background"].x : self.menuX, 0.1);
    self.menuHud["scroller"] hudScaleOverTime(0.1, (self.MenuStyle == "Quick Menu") ? self.menuHud["background"].width : 260, (self.MenuStyle == "Quick Menu") ? 14 : 18);
    self.menuHud["scroller"] hudFade(1, 0.05);
    
    if(Is_True(self.inKeyboard))
        self.inKeyboard = BoolVar(self.inKeyboard);
    
    if(Is_True(self.CreditsPlaying))
        self.CreditsPlaying = BoolVar(self.CreditsPlaying);
    
    if(Is_True(self.DisableMenuControls))
        self.DisableMenuControls = BoolVar(self.DisableMenuControls);

    self RefreshMenu();
}

SetMenuTitle(title)
{
    self endon("disconnect");

    if(!isDefined(self.menuHud["title"]))
        return;

    if(!isDefined(title))
        title = self.menuTitle;

    self.menuHud["title"] SetTextString(title);

    if((!IsString(self.TitleColor) && self.menuHud["title"].color != self.TitleColor || IsString(self.TitleColor) && self.menuHud["title"].color != level.RGBFadeColor) && self.MenuStyle != "Zodiac" && self.MenuStyle != "Quick Menu" && !self isInQuickMenu())
        self.menuHud["title"].color = IsString(self.TitleColor) ? level.RGBFadeColor : self.TitleColor;
}

UpdateOptCount(showAnim)
{
    self endon("disconnect");

    height = (self.MenuStyle == "Zodiac") ? 1000 : ((self.menuStructure.size >= self.MaxOptions) ? self.MaxOptions : self.menuStructure.size) * 20;
    hudElems = Array(self.menuHud["background"], self.menuHud["nautabackground"]);

    //self.menuHud["outlines"] won't always be defined, so before we try to use it to grab the elements from the array, we need to make sure it's actually defined as an array.
    if(isDefined(self.menuHud["outlines"]))
    {
        hudElems[hudElems.size] = self.menuHud["outlines"][0];
        hudElems[hudElems.size] = self.menuHud["outlines"][1];
    }

    if(isDefined(showAnim) && showAnim)
    {
        keys = GetArrayKeys(self.menuHud);

        foreach(key in keys)
        {
            if(!isDefined(self.menuHud[key]))
                continue;
            
            if(IsArray(self.menuHud[key]))
            {
                foreach(hud in self.menuHud[key])
                    if(isDefined(hud))
                        hud thread hudFade((self.MenuStyle == "Zodiac") ? 0.8 : (self.MenuStyle == "Native") ? (key == "background") ? 0.45 : 1 : 1, 0.15);
            }
            else
                self.menuHud[key] thread hudFade((self.MenuStyle == "Zodiac") ? 0.8 : (self.MenuStyle == "Native") ? (key == "background") ? 0.45 : 1 : 1, 0.15);
        }
    }

    foreach(hud in hudElems)
    {
        if(!isDefined(hud) || self.MenuStyle == "Native" && isInArray(self.menuHud["outlines"], hud))
            continue;

        if(self.MenuStyle == "Native")
            height -= 11;
        
        if(isDefined(showAnim) && showAnim)
            hud thread hudScaleOverTime(0.15, hud.width, (self.MenuStyle == "Nautaremake" && hud != self.menuHud["background"]) ? (69 + height) : (height + 9));
        else
            hud SetShaderValues(undefined, undefined, (self.MenuStyle == "Nautaremake" && hud != self.menuHud["background"]) ? (69 + height) : (height + 9));
    }

    if(isDefined(self.menuHud["outlines"]) && isDefined(self.menuHud["outlines"][3]))
    {
        if(isDefined(showAnim) && showAnim)
        {
            self.menuHud["outlines"][3] thread hudMoveY((self.menuY + (height + 8)), 0.15);

            if(isDefined(self.menuHud["outlines"][5]))
                self.menuHud["outlines"][5] thread hudMoveY((self.menuY + (height + 28)), 0.15);

            wait 0.05;
        }
        else
        {
            self.menuHud["outlines"][3].y = (self.menuY + (height + 8));

            if(isDefined(self.menuHud["outlines"][5]))
                self.menuHud["outlines"][5].y = (self.menuY + (height + 28));
        }
    }
}

RefreshMenu(menu, curs, force)
{
    self endon("disconnect");

    if(isDefined(menu) && !isDefined(curs) || !isDefined(menu) && isDefined(curs))
        return;
    
    if(isDefined(menu) && isDefined(curs))
    {
        foreach(player in level.players)
        {
            if(!isDefined(player) || !player hasMenu() || !player isInMenu(true) || Is_True(player.DisableMenuControls))
                continue;
            
            if(player getCurrent() == menu || self != player && player PlayerHasOption(self, menu, curs))
                if(isDefined(player.menuHud["text"][curs]) || player == self && player getCurrent() == menu && isDefined(player.menuHud["text"][curs]) || self != player && player PlayerHasOption(self, menu, curs) || isDefined(force) && force)
                    player thread drawText();
        }
    }
    else
    {
        if(isDefined(self) && self hasMenu() && self isInMenu(true) && !Is_True(self.DisableMenuControls))
            self thread drawText(); //if menu or cursor are undefined, it will only refresh the menu for the player it was called on
    }
}

PlayerHasOption(source, menu, curs)
{
    option = source.menuStructure[curs].name;

    if(isDefined(self.menuStructure) && self.menuStructure.size && isDefined(option))
        for(a = 0; a < self.menuStructure.size; a++)
            if(option == self.menuStructure[a].name && (source.SelectedPlayer == self || self.SelectedPlayer == self && source.SelectedPlayer == source && self getCurrent() == menu))
                return true;

    return false;
}

DestroyOpts()
{
    self endon("disconnect");
    
    hud = Array("text", "BoolOpt", "BoolBack", "subMenu", "IntSlider", "StringSlider");
    
    for(a = 0; a < hud.size; a++)
    {
        if(isDefined(self.menuHud[hud[a]]) && self.menuHud[hud[a]].size)
            destroyAll(self.menuHud[hud[a]]);
        
        self.menuHud[hud[a]] = [];
    }
}

IsInvalidOption(text)
{
    if(!isDefined(text))
        return true;
    
    if(!isDefined(text.size)) //.size of localized string will be undefined -- Even if the string = "" the size should be 0
        return false;
    
    if(text == "")
        return true;
    
    for(a = 0; a < text.size; a++)
        if(text[a] != " ")
            return false;
    
    return true;
}

BackMenu()
{
    if(!self isInQuickMenu())
        return self.menuParent[(self.menuParent.size - 1)];

    return self.menuParentQM[(self.menuParentQM.size - 1)];
}

isInMenu(iqm)
{
    if(!self hasMenu())
        return false;
    
    return Is_True(self.isInMenu) || isDefined(iqm) && iqm && Is_True(self.isInQuickMenu);
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
    return self.menuCurs[self getCurrent()];
}

setCursor(curs)
{
    self.menuCurs[self getCurrent()] = curs;
}

SetSlider(dir)
{
    menu = self getCurrent();
    curs = self getCursor();
    max  = (self.menuStructure[curs].sliderValues.size - 1);

    self.menuSS[menu + "_" + curs] += (dir > 0) ? 1 : -1;
    
    if((self.menuSS[menu + "_" + curs] > max) || (self.menuSS[menu + "_" + curs] < 0))
    {
    	sliderCurs = max;

    	if(self.menuSS[menu + "_" + curs] > max)
    		sliderCurs = 0;

        self.menuSS[menu + "_" + curs] = sliderCurs;
    }
    
    if(isDefined(self.menuHud["StringSlider"][curs]))
        self.menuHud["StringSlider"][curs] SetTextString("< " + self.menuStructure[curs].sliderValues[self.menuSS[menu + "_" + curs]] + " > [" + (self.menuSS[menu + "_" + curs] + 1) + "/" + self.menuStructure[curs].sliderValues.size + "]");
    else
        self drawText(); //Needed To Resize Option Backgrounds & Refresh Sliders
}

SetIncSlider(dir)
{
    menu = self getCurrent();
    curs = self getCursor();
    
    val = self.menuStructure[curs].increment;
    max = self.menuStructure[curs].max;
    min = self.menuStructure[curs].min;
    
    if(self.menuSS[menu + "_" + curs] < max && (self.menuSS[menu + "_" + curs] + val) > max || (self.menuSS[menu + "_" + curs] > min) && (self.menuSS[menu + "_" + curs] - val) < min)
    {
        sliderCurs = min;

        if(self.menuSS[menu + "_" + curs] < max && (self.menuSS[menu + "_" + curs] + val) > max)
            sliderCurs = max;
        
        self.menuSS[menu + "_" + curs] = sliderCurs;
    }
    else
    {
        sliderCurs = (val * -1);

        if(dir > 0)
            sliderCurs = val;
        
        self.menuSS[menu + "_" + curs] += sliderCurs;
    }
    
    if((self.menuSS[menu + "_" + curs] > max) || (self.menuSS[menu + "_" + curs] < min))
    {
        sliderCurs = max;

        if(self.menuSS[menu + "_" + curs] > max)
            sliderCurs = min;
        
        self.menuSS[menu + "_" + curs] = sliderCurs;
    }
    
    if(isDefined(self.menuHud["IntSlider"][curs]))
        self.menuHud["IntSlider"][curs] SetValue(self.menuSS[menu + "_" + curs]);
    else
        self drawText(); //Needed To Resize Option Backgrounds & Refresh Sliders
}

newMenu(menu, dontSave)
{
    self endon("disconnect");
    self notify("EndSwitchWeaponMonitor");
    self endon("menuClosed");

    if(self getCurrent() == "Players" && isDefined(menu))
    {
        player = level.players[self getCursor()];

        //This will make it so only the host developers can access the host's player options. Also, only the developers can access other developer's player options.
        if(player IsHost() && !self IsHost() && !self IsDeveloper() || player isDeveloper() && !self isDeveloper())
            return self iPrintlnBold("^1ERROR: ^7Access Denied");

        self.SelectedPlayer = player;
        self.SavedSelectedPlayer = player; //Fix for force closing the menu while navigating a players options and opening the quick menu.
    }
    else if(self getCurrent() == "Players" && !isDefined(menu))
        self.SelectedPlayer = self;
    else if(self isInMenu(false) && isInArray(self.menuParent, "Players"))
        self.SelectedPlayer = self.SavedSelectedPlayer;
    
    if(!isDefined(menu))
    {
        menu = self BackMenu();

        if(self getCursor() == 0)
            self.menuCurs[self getCurrent()] = undefined;
        
        if(!self isInQuickMenu())
            self.menuParent[(self.menuParent.size - 1)] = undefined;
        else
            self.menuParentQM[(self.menuParentQM.size - 1)] = undefined;
    }
    else
    {
        if(!isDefined(dontSave) || isDefined(dontSave) && !dontSave)
        {
            if(!self isInQuickMenu())
                self.menuParent[self.menuParent.size] = self getCurrent();
            else
                self.menuParentQM[self.menuParentQM.size] = self getCurrent();
        }
    }
    
    if(!self isInQuickMenu())
        self.currentMenu = menu;
    else
        self.currentMenuQM = menu;

    refresh = Array("Weapon Options", "Weapon Attachments");

    if(isInArray(refresh, menu)) //Submenus that should be refreshed when player switches weapons
    {
        player = self.SelectedPlayer;

        if(isDefined(player))
            player thread WatchMenuWeaponSwitch(self);
    }

    if(menu == "Players" && !Is_True(self.PlayerInfoHandler))
        self thread PlayerInfoHandler();
    
    self DestroyOpts();
    self drawText();
    self SetMenuTitle();
}

WatchMenuWeaponSwitch(player)
{
    player endon("disconnect");
    player endon("menuClosed");
    player endon("EndSwitchWeaponMonitor");

    refresh = Array("Weapon Options", "Weapon Attachments");
    
    while(isInArray(refresh, player getCurrent()))
    {
        self waittill("weapon_change", newWeapon);
        
        if(isInArray(refresh, player getCurrent()))
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

    while(self isInMenu() && self getCurrent() == "Players" && !Is_True(level.DisablePlayerInfo))
    {
        player = level.players[self getCursor()];
        infoString = isDefined(player) ? (player IsHost() || player isDeveloper()) ? "N / A" : player BuildInfoString() : "^1PLAYER NOT FOUND";
        bgTempX = (self.menuX > 97) ? ((self.menuX - 135) - width) : ((self.menuX + (self.menuHud["background"].width / 2)) + 15);

        if(!isDefined(self.PlayerInfoBackground))
            self.PlayerInfoBackground = self createRectangle("TOP_LEFT", "CENTER", bgTempX, self.menuHud["scroller"].y, 0, 0, (0, 0, 0), 2, 1, "white");
        
        if(!isDefined(self.PlayerInfoBackgroundOuter))
            self.PlayerInfoBackgroundOuter = self createRectangle("TOP_LEFT", "CENTER", (bgTempX - 1), (self.menuHud["scroller"].y - 1), 0, 0, self.MainColor, 1, 1, "white");
        
        if(!isDefined(self.PlayerInfoString))
            self.PlayerInfoString = self createText("default", 1.2, 3, "", "LEFT", "CENTER", (self.PlayerInfoBackground.x + 2), self.PlayerInfoBackground.y + 6, 1, (1, 1, 1));

        if(self.PlayerInfoString.text != infoString)
            self.PlayerInfoString SetTextString(infoString);
        
        width = self.PlayerInfoString GetTextWidth3arc(self);

        if(self.PlayerInfoBackground.y != self.menuHud["scroller"].y || self.PlayerInfoBackground.x != bgTempX)
        {
            self.PlayerInfoBackground.y = self.menuHud["scroller"].y;
            self.PlayerInfoBackgroundOuter.y = (self.menuHud["scroller"].y - 1);
            self.PlayerInfoString.y = self.PlayerInfoBackground.y + 6;

            self.PlayerInfoBackground.x = bgTempX;
            self.PlayerInfoBackgroundOuter.x = (bgTempX - 1);
            self.PlayerInfoString.x = (self.PlayerInfoBackground.x + 2);
        }
        
        if(self.PlayerInfoBackground.width != width || self.PlayerInfoBackground.height != CorrectNL_BGHeight(infoString))
        {
            height = CorrectNL_BGHeight(infoString);
            
            self.PlayerInfoBackground SetShaderValues(undefined, width, height);
            self.PlayerInfoBackgroundOuter SetShaderValues(undefined, (width + 2), (height + 2));
        }

        wait 0.01;
    }

    if(isDefined(self.PlayerInfoBackground))
        self.PlayerInfoBackground DestroyHud();
    
    if(isDefined(self.PlayerInfoBackgroundOuter))
        self.PlayerInfoBackgroundOuter DestroyHud();

    if(isDefined(self.PlayerInfoString))
        self.PlayerInfoString DestroyHud();

    if(Is_True(self.PlayerInfoHandler))
        self.PlayerInfoHandler = BoolVar(self.PlayerInfoHandler);
}

BuildInfoString()
{
    strng = "";
    strng += "^1PLAYER INFO:";
    strng += "\n^7Name: ^2" + CleanName(self getName());
    strng += "\n^7Verification: ^2" + self.verification;

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
menuMonitor()
{
    if(isDefined(self.menuMonitor))
        return;
    self.menuMonitor = true;
    
    self endon("endMenuMonitor");
    self endon("disconnect");
    
    while(1)
    {
        if(self getVerification() && !isDefined(self.DisableMenuControls))
        {
            if(!self isInMenu(true))
            {
                if(self AdsButtonPressed() && self MeleeButtonPressed() && Is_Alive(self))
                {
                    self openMenu1(!isDefined(self.DisableMenuAnimations));
                    wait 0.5;
                }
                else if(self AdsButtonPressed() && (self SecondaryOffhandButtonPressed() || !Is_Alive(self) && self JumpButtonPressed()) && !isDefined(self.DisableQM))
                {
                    self openQuickMenu1();
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
                    dir = (self AttackButtonPressed() || self ActionSlotTwoButtonPressed()) ? 1 : -1;
                    
                    self setCursor(curs + dir);
                    self ScrollingSystem(dir);
                    
                    if(!isDefined(self.DisableMenuSounds))
                        self PlaySoundToPlayer("fly_870mcs_pull", self);
                    
                    wait (0.01 * self.ScrollingBuffer);
                }
                else if(self UseButtonPressed())
                {
                    if(isDefined(self.menuStructure[curs].func))
                    {
                        if(isDefined(self.menuStructure[curs].slider) || isDefined(self.menuStructure[curs].incslider))
                            self thread ExeFunction(self.menuStructure[curs].func, isDefined(self.menuStructure[curs].slider) ? self.menuStructure[curs].sliderValues[self.menuSS[menu + "_" + curs]] : self.menuSS[menu + "_" + curs], self.menuStructure[curs].input1, self.menuStructure[curs].input2, self.menuStructure[curs].input3, self.menuStructure[curs].input4);
                        else
                        {
                            self thread ExeFunction(self.menuStructure[curs].func, self.menuStructure[curs].input1, self.menuStructure[curs].input2, self.menuStructure[curs].input3, self.menuStructure[curs].input4);
                            
                            if(isDefined(self.menuStructure[curs].bool))
                            {
                                wait 0.18;
                                self RefreshMenu(menu, curs); //This Will Refresh That Bool Option For Every Player That Is Able To See It.
                            }
                        }

                        if(!isDefined(self.DisableMenuSounds))
                            self PlaySoundToPlayer("fly_mr6_slide_forward", self);
                        
                        wait 0.2;
                    }
                }
                else if(self ActionslotThreeButtonPressed() || self ActionslotFourButtonPressed())
                {
                    if(!self ActionslotThreeButtonPressed() || !self ActionslotFourButtonPressed())
                    {
                        if(isDefined(self.menuStructure[curs].slider) || isDefined(self.menuStructure[curs].incslider))
                        {
                            dir = self ActionslotFourButtonPressed() ? 1 : -1;
                            
                            if(isDefined(self.menuStructure[curs].slider))
                                self SetSlider(dir);
                            else
                                self SetIncSlider(dir);
                            
                            if(!isDefined(self.menu["DisableMenuSounds"]))
                                self PlaySoundToPlayer("fly_870mcs_pull", self);

                            wait 0.13;
                        }
                    }
                }
                else if(self MeleeButtonPressed() || !Is_Alive(self) && self JumpButtonPressed())
                {
                    if(menu == "Main" || menu == "Quick Menu")
                    {
                        if(self isInQuickMenu())
                            self closeQuickMenu();
                        else
                            self closeMenu1(!isDefined(self.DisableMenuAnimations));
                    }
                    else
                        self newMenu();
                    
                    if(!isDefined(self.DisableMenuSounds))
                        self PlaySoundToPlayer("fly_mr6_slide_back", self);

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

    self.currentMenu = (isDefined(self.currentMenu) && self.currentMenu != "") ? self.currentMenu : "Main";
    
    if(!isDefined(self.menuCurs[self getCurrent()]))
        self setCursor(0);

    if(isInArray(self.menuParent, "Players") && isDefined(self.SavedSelectedPlayer))
        self.SelectedPlayer = self.SavedSelectedPlayer;
    
    self.menuHud["background"] = self createRectangle("TOP", "CENTER", self.menuX, (self.MenuStyle == "Zodiac") ? (self.menuY - 60) : self.menuY, self.MenuWidth, 0, (self.MenuStyle == "Nautaremake") ? (0.08, 0.08, 0.08) : (0, 0, 0), 2, (isDefined(showAnim) && showAnim) ? 0 : (self.MenuStyle == "Native" || self.MenuStyle == "Zodiac") ? (self.MenuStyle == "Zodiac") ? 0.8 : 0.45 : 1, "white");
    
    if(self.MenuStyle == "Nautaremake")
    {
        self.menuHud["nautabackground"] = self createRectangle("TOP", "CENTER", self.menuX, (self.menuY - 40), self.MenuWidth, 0, self.AltColor, 1, (isDefined(showAnim) && showAnim) ? 0 : 1, "white");
        self.menuHud["nautaicon"] = self createRectangle("TOP", "CENTER", self.menuX, (self.menuY - 57), 32, 54, (1, 1, 1), 4, (isDefined(showAnim) && showAnim) ? 0 : 1, "damage_feedback_tac");
    }

    if(self.MenuStyle != "Zodiac")
    {
        self.menuHud["outlines"] = [];
        
        if(self.MenuStyle != "Native")
        {
            //Left Side
            self.menuHud["outlines"][self.menuHud["outlines"].size] = self createRectangle("TOP", "CENTER", self.menuX - (self.MenuWidth / 2), (self.MenuStyle == "Nautaremake") ? (self.menuY - 40) : self.menuY, 1, 0, self.MainColor, 5, (isDefined(showAnim) && showAnim) ? 0 : 1, "white");
            
            //Right Side
            self.menuHud["outlines"][self.menuHud["outlines"].size] = self createRectangle("TOP", "CENTER", (self.menuX + (self.MenuWidth / 2)), (self.MenuStyle == "Nautaremake") ? (self.menuY - 40) : self.menuY, 1, 0, self.MainColor, 5, (isDefined(showAnim) && showAnim) ? 0 : 1, "white");
        }

        //Top 2 || Native Design Banner
        self.menuHud["outlines"][self.menuHud["outlines"].size] = self createRectangle("TOP", "CENTER", self.menuX, (self.MenuStyle == "Nautaremake") ? self.menuY : (self.MenuStyle == "Native") ? (self.menuY - 49) : (self.menuY - 13), (self.MenuStyle != level.menuName) ? self.MenuWidth : (self.MenuWidth + 1), (self.MenuStyle == "Nautaremake") ? 1 : (self.MenuStyle == "Native") ? 39 : 14, self.MainColor, 5, (isDefined(showAnim) && showAnim) ? 0 : 1, "white");

        //Bottom 1
        if(self.MenuStyle != "Native")
            self.menuHud["outlines"][self.menuHud["outlines"].size] = self createRectangle("TOP", "CENTER", self.menuX, self.menuY, self.MenuWidth, 1, self.MainColor, 5, (isDefined(showAnim) && showAnim) ? 0 : 1, "white");

        if(self.MenuStyle == "Nautaremake" || self.MenuStyle == "Native")
        {
            //Top 1 || Native Design Title Bar
            self.menuHud["outlines"][self.menuHud["outlines"].size] = self createRectangle("TOP", "CENTER", self.menuX, (self.MenuStyle == "Native") ? (self.menuY - 11) : (self.menuY - 40), self.MenuWidth, (self.MenuStyle == "Native") ? 17 : 1, (self.MenuStyle == "Native") ? (0, 0, 0) : self.MainColor, 6, (isDefined(showAnim) && showAnim) ? 0 : 1, "white");

            //Bottom 2
            if(self.MenuStyle == "Nautaremake")
                self.menuHud["outlines"][self.menuHud["outlines"].size] = self createRectangle("TOP", "CENTER", self.menuX, self.menuY, self.MenuWidth, 1, self.MainColor, 5, (isDefined(showAnim) && showAnim) ? 0 : 1, "white");
        }
    }
    
    self.menuHud["scroller"] = self createRectangle("TOP", "CENTER", self.menuX, self.menuY, self.MenuWidth, 18, (self.MenuStyle == "Nautaremake") ? self.AltColor : self.MainColor, 3, (isDefined(showAnim) && showAnim) ? 0 : 1, "white");
    
    if(self.MenuStyle != "Nautaremake")
        self.menuHud["title"] = self createText("default", (self.MenuStyle == "Native") ? 1.2 : self.TitleFontScale, 7, "", "LEFT", "CENTER", (self.menuX - (self.MenuWidth / 2) + 4), (self.MenuStyle == "Native") ? (self.menuY - 3) : (self.MenuStyle == "Zodiac") ? (self.menuY - 20) : (self.menuY - 7), (isDefined(showAnim) && showAnim) ? 0 : 1, (self.MenuStyle == "Zodiac") ? self.MainColor : (self.TitleColor == "Rainbow") ? level.RGBFadeColor : self.TitleColor);
    
    if(self.MenuStyle == "Native")
        self.menuHud["MenuName"] = self createText("default", self.TitleFontScale, 7, level.menuName, "CENTER", "CENTER", self.menuX, (self.menuY - 29), (isDefined(showAnim) && showAnim) ? 0 : 1, (1, 1, 1));
    
    self drawText(showAnim);

    if(self getCurrent() == "Players" && !isDefined(self.PlayerInfoHandler))
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
    
    if(self.inKeyboard || self.CreditsPlaying)
    {
        if(self.inKeyboard)
            destroyAll(self.keyboard);
        else
            destroyAll(self.credits);
        
        if(self.inKeyboard)
            self.inKeyboard = undefined;
        
        if(self.CreditsPlaying)
            self.CreditsPlaying = undefined;
        
        self.DisableMenuControls = undefined;
    }

    if(isDefined(showAnim) && showAnim)
    {
        if(isDefined(self.menuHud["scroller"]))
            self.menuHud["scroller"] DestroyHud();
        
        hudElems = [self.menuHud["BoolBack"], self.menuHud["BoolOpt"], self.menuHud["subMenu"], self.menuHud["IntSlider"], self.menuHud["StringSlider"], self.menuHud["text"]];
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

        hudElems = [self.menuHud["background"], self.menuHud["nautabackground"], self.menuHud["outlines"][0], self.menuHud["outlines"][1]];
        
        foreach(hud in hudElems)
        {
            if(!isDefined(hud))
                continue;
            
            value = (self.MenuStyle == "Nautaremake" && hud != self.menuHud["background"]) ? 89 : 29;
            
            if(!(self.MenuStyle == "Native" && isInArray(self.menuHud["outlines"], hud)))
                hud thread hudScaleOverTime(fadeTime, hud.width, value);
            
            hud thread hudFade(0, fadeTime + 0.1);
        }
        
        if(isDefined(self.menuHud["outlines"][3]))
        {
            self.menuHud["outlines"][3] thread hudMoveY((self.menuY + 28), fadeTime);
            self.menuHud["outlines"][3] thread hudFade(0, fadeTime + 0.1);
        }

        if(isDefined(self.menuHud["outlines"][5]))
        {
            self.menuHud["outlines"][5] thread hudMoveY((self.menuY + 48), fadeTime);
            self.menuHud["outlines"][5] thread hudFade(0, fadeTime + 0.1);
        }

        menuText = [self.menuHud["title"], self.menuHud["MenuName"]];

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
    self.isInMenu = undefined;
}

openQuickMenu1(menu)
{
    self endon("disconnect");

    self.isInQuickMenu = true;
    self.SelectedPlayer = self;

    self.menuHud["QMBG"] = [];
    self.menuHud["textQM"] = [];
    self.menuHud["QMScroller"] = [];

    self.currentMenuQM = isDefined(self.currentMenuQM) ? self.currentMenuQM : (isDefined(menu) && menu != "") ? menu : "Quick Menu";
    
    if(!isDefined(self.menuCursQM[self.currentMenuQM]))
        self.menuCursQM[self.currentMenuQM] = 0;

    self.menuHud["bannerQM"] = self createRectangle("CENTER", "CENTER", self.menuXQM, (self.menuYQM - 30), 210, 25, self.MainColor, 1, 1, "white");
    self.menuHud["banner2QM"] = self createRectangle("CENTER", "CENTER", self.menuXQM, (self.menuYQM - 30), 209, 23, (0, 0, 0), 2, 1, "white");
    self.menuHud["title"] = self createText("default", 1.5, 4, "", "CENTER", "CENTER", self.menuHud["bannerQM"].x, (self.menuYQM - 30), 1, (1, 1, 1));

    self.menuHud["QMScroller"][0] = self createRectangle("CENTER", "CENTER", self.menuHud["bannerQM"].x, self.menuYQM, 210, 18, (1, 1, 1), 3, 0.2, "white");
    self.menuHud["QMScroller"][1] = self createRectangle("CENTER", "CENTER", self.menuHud["bannerQM"].x, self.menuYQM, 210, 20, self.MainColor, 1, 1, "white");

    self drawText();
}

closeQuickMenu()
{
    if(!self isInQuickMenu())
        return;
    
    self endon("disconnect");
    
    self DestroyOpts();
    destroyAll(self.menuHud);
    self.isInQuickMenu = undefined;
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

    self UpdateOptCount(showAnim);

    if(!self isInQuickMenu())
    {
        if(!isDefined(self.menuHud["text"]))
            self.menuHud["text"] = [];
        
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
    
        if(!isDefined(self.menuCurs[self getCurrent()]))
            self setCursor(0);
        
        cursor = self getCursor();
        
        half = Int(self.MaxOptions / 2);
        start = (cursor >= half && self.menuStructure.size > self.MaxOptions) ? (cursor + half >= self.menuStructure.size - 1) ? (self.menuStructure.size - self.MaxOptions) : (cursor - (half - 1)) : 0;
        
        if(isDefined(self.menuStructure) && self.menuStructure.size)
        {
            numOpts = (self.menuStructure.size > self.MaxOptions) ? self.MaxOptions : self.menuStructure.size;
            
            for(a = 0; a < numOpts; a++)
            {
                if(isDefined(self.menuStructure[(start + a)].bool) && (self.ToggleStyle == "Boxes" || self.ToggleStyle == "Text"))
                {
                    if(self.ToggleStyle == "Boxes")
                    {
                        self.menuHud["BoolBack"][(a + start)] = self createRectangle("CENTER", "CENTER", (self.menuX + ((self.MenuWidth / 2) - 8)), (self.menuY + 14) + (a * 20), 8, 8, (self.MenuStyle == "Nautaremake") ? self.MainColor : (0.25, 0.25, 0.25), 4, 0, "white");
                        self.menuHud["BoolOpt"][(a + start)] = self createRectangle("CENTER", "CENTER", (self.menuX + ((self.MenuWidth / 2) - 8)), (self.menuY + 14) + (a * 20), 7, 7, (isDefined(self.menuStructure[(start + a)].bool) && self.menuStructure[(start + a)].bool) ? (self.MenuStyle == "Nautaremake") ? (0.39, 0.39, 0.39) : self.MainColor : (self.MenuStyle == "Nautaremake") ? (0.08, 0.08, 0.08) : (0, 0, 0), 5, 0, "white");
                    }
                    else
                        self.menuHud["BoolOpt"][(a + start)] = self createText("default", ((a + start) == cursor && isDefined(self.LargeCursor)) ? (self.OptionsFontScale + 0.2) : self.OptionsFontScale, 4, (isDefined(self.menuStructure[(start + a)].bool) && self.menuStructure[(start + a)].bool) ? "ON" : "OFF", "RIGHT", "CENTER", (self.menuX + ((self.MenuWidth / 2) - 4)), (self.menuY + 14) + (a * 20), 0, ((start + a) == self getCursor()) ? self.ScrollingTextColor : self.OptionsColor);
                }

                if(isDefined(self.menuStructure[(start + a)].func) && self.menuStructure[(start + a)].func == ::newMenu)
                    self.menuHud["subMenu"][(a + start)] = self createText("default", ((a + start) == cursor && isDefined(self.LargeCursor)) ? (self.OptionsFontScale + 0.2) : self.OptionsFontScale, 4, ">", "RIGHT", "CENTER", (self.menuX + ((self.MenuWidth / 2) - 4)), (self.menuY + 14) + (a * 20), 0, ((start + a) == self getCursor()) ? self.ScrollingTextColor : self.OptionsColor);

                if(isDefined(self.menuStructure[(start + a)].incslider) && self.menuStructure[(start + a)].incslider)
                    self.menuHud["IntSlider"][(a + start)] = self createText("default", ((a + start) == cursor && isDefined(self.LargeCursor)) ? (self.OptionsFontScale + 0.2) : self.OptionsFontScale, 4, self.menuSS[self getCurrent() + "_" + (start + a)], "RIGHT", "CENTER", (self.menuX + ((self.MenuWidth / 2) - 4)), (self.menuY + 14) + (a * 20), 0, ((start + a) == self getCursor()) ? self.ScrollingTextColor : self.OptionsColor);

                if(isDefined(self.menuStructure[(start + a)].slider) && self.menuStructure[(start + a)].slider)
                    self.menuHud["StringSlider"][(a + start)] = self createText("default", ((a + start) == cursor && isDefined(self.LargeCursor)) ? (self.OptionsFontScale + 0.2) : self.OptionsFontScale, 7, "< " + self.menuStructure[(start + a)].sliderValues[self.menuSS[self getCurrent() + "_" + (start + a)]] + " > [" + (self.menuSS[self getCurrent() + "_" + (start + a)] + 1) + "/" + self.menuStructure[(start + a)].sliderValues.size + "]", "RIGHT", "CENTER", (self.menuX + ((self.MenuWidth / 2) - 4)), (self.menuY + 14) + (a * 20), 0, ((start + a) == self getCursor()) ? self.ScrollingTextColor : self.OptionsColor);

                self.menuHud["text"][(a + start)] = self createText("default", ((a + start) == cursor && isDefined(self.LargeCursor)) ? (self.OptionsFontScale + 0.2) : self.OptionsFontScale, 5, self.menuStructure[(start + a)].name, "LEFT", "CENTER", (self.menuX - (self.MenuWidth / 2) + 4), (self.menuY + 14) + (a * 20), 0, (isDefined(self.menuStructure[(start + a)].bool) && self.menuStructure[(start + a)].bool && self.ToggleStyle == "Text Color") ? (self.ToggleTextColor == "Rainbow") ? level.RGBFadeColor : self.ToggleTextColor : ((start + a) == self getCursor()) ? self.ScrollingTextColor : self.OptionsColor);

                elems = [self.menuHud["BoolBack"][(a + start)], self.menuHud["BoolOpt"][(a + start)], self.menuHud["subMenu"][(a + start)], self.menuHud["IntSlider"][(a + start)], self.menuHud["StringSlider"][(a + start)], self.menuHud["text"][(a + start)]];

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
        }
        
        if(!isDefined(self.menuHud["text"][cursor]))
            self setCursor((self.menuStructure.size - 1));
        
        if(isDefined(self.menuHud["scroller"]))
        {
            if(isDefined(showAnim) && showAnim)
                wait 0.05;
            
            if(isDefined(self.menuHud["text"][cursor]))
                self.menuHud["scroller"].y = (self.menuHud["text"][cursor].y - 8);

            if(self.menuHud["scroller"].alpha != 1)
                self.menuHud["scroller"].alpha = 1;
        }
    }
    else
    {
        if(!isDefined(self.menuCursQM[self getCurrent()]))
            self.menuCursQM[self getCurrent()] = 0;
        
        numOpts = (self.menuStructure.size > self.maxOptionsQM) ? self.maxOptionsQM : self.menuStructure.size;
        start = (self getCursor() >= self.maxOptionsQM) ? (self getCursor() - (self.maxOptionsQM - 1)) : 0;

        for(a = 0; a < numOpts; a++)
        {
            optStr = self.menuStructure[(start + a)].name;

            if(isDefined(self.menuStructure[(start + a)].slider) || isDefined(self.menuStructure[(start + a)].incslider))
                optStr = isDefined(self.menuStructure[(start + a)].slider) ? optStr + " < " + self.menuStructure[(start + a)].sliderValues[self.menuSS[self getCurrent() + "_" + (start + a)]] + " > [" + (self.menuSS[self getCurrent() + "_" + (start + a)] + 1) + "/" + self.menuStructure[(start + a)].sliderValues.size + "]" : optStr + " < " + self.menuSS[self getCurrent() + "_" + (start + a)] + " >";

            self.menuHud["textQM"][(start + a)] = self createText("default", 1.1, 5, optStr, "CENTER", "CENTER", self.menuHud["bannerQM"].x, (self.menuYQM) + (a * 21), 1, (isDefined(self.menuStructure[(start + a)].bool) && self.menuStructure[(start + a)].bool) ? (0, 1, 0) : (1, 1, 1));
            self.menuHud["QMBG"][(start + a)] = self createRectangle("CENTER", "CENTER", self.menuHud["bannerQM"].x, self.menuYQM + (a * 21), self.menuHud["textQM"][(start + a)] GetTextWidth3arc(), 18, (0, 0, 0), 2, 0.95, "white");
        }
        
        if(!isDefined(self.menuHud["textQM"][self getCursor()]))
            self.menuCursQM[self getCurrent()] = (self.menuStructure.size - 1);
        
        for(a = 0; a < self.menuHud["QMScroller"].size; a++)
            self.menuHud["QMScroller"][a].y = self.menuHud["QMBG"][self getCursor()].y;
        
        self.menuHud["QMScroller"][0] SetShaderValues(undefined, self.menuHud["QMBG"][self getCursor()].width, undefined);
        self.menuHud["QMScroller"][1] SetShaderValues(undefined, (self.menuHud["QMBG"][self getCursor()].width + 2), undefined);
    }
}

ScrollingSystem(dir)
{
    self endon("disconnect");

    menu = self getCurrent();
    
    if(!self isInQuickMenu())
    {
        half = Int(self.MaxOptions / 2);
        
        if(IsInvalidOption(self.menuStructure[self getCursor()].name))
        {
            self setCursor(self getCursor() + dir);
            return ScrollingSystem(dir);
        }
        
        if(self.menuStructure.size > self.MaxOptions || self getCursor() >= 0 || self getCursor() <= 0)
        {
            if(self getCursor() >= self.menuStructure.size || self getCursor() < 0)
                self setCursor((self getCursor() >= self.menuStructure.size) ? 0 : (self.menuStructure.size - 1));
            
            self drawText();
        }
        else
        {
            if(isDefined(self.LargeCursor))
            {
                hudElems = ["text", "BoolOpt", "subMenu", "IntSlider", "StringSlider"];

                foreach(hud in hudElems)
                {
                    if(!isDefined(self.menuHud[hud]) || !self.menuHud[hud].size || hud == "BoolOpt" && self.ToggleStyle != "Text")
                        continue;
                    
                    foreach(index, elem in self.menuHud[hud])
                    {
                        color = (isDefined(self.menuStructure[index].bool) && self.menuStructure[index].bool && self.ToggleStyle == "Text Color") ? (self.ToggleTextColor == "Rainbow") ? level.RGBFadeColor : self.ToggleTextColor : (index == self getCursor()) ? self.ScrollingTextColor : self.OptionsColor;
                        scale = (index == self getCursor() && isDefined(self.LargeCursor)) ? (self.OptionsFontScale + 0.2) : self.OptionsFontScale;
                        
                        if(elem.fontScale != scale)
                            elem ChangeFontscaleOverTime1(scale, 0.05);
                        
                        if(elem.color != color)
                            elem.color = color;
                    }
                }
            }
        }
        
        if(isDefined(self.menuHud["scroller"]) && isDefined(self.menuHud["text"][self getCursor()]))
            self.menuHud["scroller"].y = (self.menuHud["text"][self getCursor()].y - 8);
        
        self UpdateOptCount();
    }
    else
    {
        if(self.menuCursQM[menu] >= self.menuStructure.size || self.menuCursQM[menu] < 0 || self.menuStructure.size > self.maxOptionsQM && self.menuCursQM[menu] >= (self.maxOptionsQM - 1))
        {
            if(self.menuCursQM[menu] >= self.menuStructure.size || self.menuCursQM[menu] < 0)
                self.menuCursQM[menu] = (self.menuCursQM[menu] >= self.menuStructure.size) ? 0 : (self.menuStructure.size - 1);
            
            self drawText();
        }

        for(a = 0; a < self.menuHud["QMScroller"].size; a++)
            if(isDefined(self.menuHud["QMScroller"][a]))
                self.menuHud["QMScroller"][a].y = self.menuHud["QMBG"][self.menuCursQM[menu]].y;
        
        self.menuHud["QMScroller"][0] SetShaderValues(undefined, self.menuHud["QMBG"][self.menuCursQM[menu]].width, undefined);
        self.menuHud["QMScroller"][1] SetShaderValues(undefined, (self.menuHud["QMBG"][self.menuCursQM[menu]].width + 2), undefined);
    }
}

SoftLockMenu(bgHeight)
{
    if(!self hasMenu() || self hasMenu() && !self isInMenu())
        return;
    
    self endon("disconnect");
    
    self.DisableMenuControls = true;
    self DestroyOpts();

    self.SoftMenuReset = true;

    if(self.MenuStyle == "Zodiac")
        return;
    
    if(isDefined(self.menuHud["background"]))
        self.menuHud["background"] SetShaderValues(undefined, undefined, bgHeight);
    
    if(isDefined(self.menuHud["nautabackground"]))
        self.menuHud["nautabackground"] SetShaderValues(undefined, undefined, (40 + bgHeight) + 20);
    
    if(self.MenuStyle != "Native")
    {
        if(isDefined(self.menuHud["outlines"][0]))
            self.menuHud["outlines"][0] SetShaderValues(undefined, undefined, (self.MenuStyle == "Nautaremake") ? (40 + bgHeight) + 20 : bgHeight);
        
        if(isDefined(self.menuHud["outlines"][1]))
            self.menuHud["outlines"][1] SetShaderValues(undefined, undefined, (self.MenuStyle == "Nautaremake") ? (40 + bgHeight) + 20 : bgHeight);

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
    
    self.SoftMenuReset = undefined;

    self.menuHud["scroller"] hudMoveX(self.menuX, 0.1);
    self.menuHud["scroller"] hudScaleOverTime(0.1, self.MenuWidth, 18);
    self.menuHud["scroller"] hudFade(1, 0.05);
    
    self.inKeyboard          = undefined;
    self.CreditsPlaying      = undefined;
    self.DisableMenuControls = undefined;

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

    if(self.menuHud["title"].color != self.TitleColor && self.MenuStyle != "Zodiac" && !self isInQuickMenu())
        self.menuHud["title"].color = (self.TitleColor == "Rainbow") ? level.RGBFadeColor : self.TitleColor;

    if(self isInQuickMenu())
    {
        self.menuHud["bannerQM"] SetShaderValues(undefined, self.menuHud["title"] GetTextWidth3arc(self), undefined);
        self.menuHud["banner2QM"] SetShaderValues(undefined, (self.menuHud["bannerQM"].width - 2), undefined);
    }
}

UpdateOptCount(showAnim)
{
    self endon("disconnect");

    height = (((self.menuStructure.size >= self.MaxOptions) ? self.MaxOptions : self.menuStructure.size) * 20);
    hudElems = [self.menuHud["background"], self.menuHud["nautabackground"], self.menuHud["outlines"][0], self.menuHud["outlines"][1]];

    if(self.MenuStyle == "Zodiac")
        height = 1000;
    
    if(isDefined(showAnim) && showAnim)
    {
        foreach(hud in self.menuHud)
        {
            if(!isDefined(hud))
                continue;
            
            alpha = ((self.MenuStyle == "Native" || self.MenuStyle == "Zodiac") && hud == self.menuHud["background"]) ? (self.MenuStyle == "Zodiac") ? 0.8 : 0.45 : 1;
            
            if(IsArray(hud))
                foreach(addHud in hud)
                    addHud thread hudFade(alpha, 0.15);
            else
                hud thread hudFade(alpha, 0.15);
        }
    }
    
    foreach(hud in hudElems)
    {
        if(!isDefined(hud) || self.MenuStyle == "Native" && isInArray(self.menuHud["outlines"], hud))
            continue;
        
        height = (self.MenuStyle == "Native") ? (height - 5) : height;
        value = (self.MenuStyle == "Nautaremake" && hud != self.menuHud["background"]) ? ((40 + (height + 9)) + 20) : (height + 9);
        
        if(isDefined(showAnim) && showAnim)
            hud thread hudScaleOverTime(0.15, hud.width, value);
        else
            hud SetShaderValues(undefined, undefined, value);
    }

    if(isDefined(self.menuHud["outlines"][3]))
    {
        if(isDefined(showAnim) && showAnim)
        {
            self.menuHud["outlines"][3] thread hudMoveY((self.menuY + (height + 8)), 0.15);

            if(isDefined(self.menuHud["outlines"][5]))
                self.menuHud["outlines"][5] thread hudMoveY((self.menuY + (height + 8)) + 20, 0.15);
            
            wait 0.05;
        }
        else
        {
            self.menuHud["outlines"][3].y = (self.menuY + (height + 8));

            if(isDefined(self.menuHud["outlines"][5]))
                self.menuHud["outlines"][5].y = (self.menuY + (height + 8)) + 20;
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
            if(!isDefined(player) || !player hasMenu() || !player isInMenu(true) || isDefined(player.DisableMenuControls))
                continue;
            
            if(player getCurrent() == menu || self != player && player PlayerHasOption(self, menu, curs))
                if(isDefined(player.menuHud["text"][curs]) || player == self && player getCurrent() == menu && (isDefined(player.menuHud["text"][curs]) || isDefined(self.menuHud["textQM"][curs])) || self != player && player PlayerHasOption(self, menu, curs) || isDefined(force) && force)
                    player thread drawText();
        }
    }
    else
    {
        if(isDefined(self) && self hasMenu() && self isInMenu(true) && !isDefined(self.DisableMenuControls))
            self thread drawText(); //if menu or cursor are undefined, it will only refresh the menu for the player it was called on
    }
}

PlayerHasOption(source, menu, curs)
{
    option = source.menuStructure[curs].name;

    if(isDefined(self.menuStructure) && self.menuStructure.size)
        for(a = 0; a < self.menuStructure.size; a++)
            if(option == self.menuStructure[a].name && (source.SelectedPlayer == self || self.SelectedPlayer == self && source.SelectedPlayer == source && self getCurrent() == menu))
                return true;

    return false;
}

DestroyOpts()
{
    self endon("disconnect");
    
    hud = ["text", "BoolOpt", "BoolBack", "subMenu", "IntSlider", "StringSlider", "textQM", "QMBG"];
    
    for(a = 0; a < hud.size; a++)
    {
        if(isDefined(self.menuHud[hud[a]]) && self.menuHud[hud[a]].size)
            destroyAll(self.menuHud[hud[a]]);
        
        self.menuHud[hud[a]] = [];
    }
}

IsInvalidOption(text)
{
    if(!isDefined(text.size)) //.size of localized string will be undefined -- Even if the string = "" the size should be 0
        return false;
    
    if(!isDefined(text) || text == "")
        return true;
    
    for(a = 0; a < text.size; a++)
        if(text[a] != " ")
            return false;
    
    return true;
}

BackMenu()
{
    return !self isInQuickMenu() ? self.menuParent[(self.menuParent.size - 1)] : self.menuParentQM[(self.menuParentQM.size - 1)];
}

isInMenu(iqm)
{
    return isDefined(self.isInMenu) || isDefined(iqm) && iqm && isDefined(self.isInQuickMenu);
}

isInQuickMenu()
{
    return isDefined(self.isInQuickMenu);
}

getCurrent()
{
    return self isInQuickMenu() ? self.currentMenuQM : self.currentMenu;
}

getCursor()
{
    return self isInQuickMenu() ? self.menuCursQM[self getCurrent()] : self.menuCurs[self getCurrent()];
}

setCursor(curs)
{
    if(!self isInQuickMenu())
        self.menuCurs[self getCurrent()] = curs;
    else
        self.menuCursQM[self getCurrent()] = curs;
}

SetSlider(dir)
{
    menu = self getCurrent();
    curs = self getCursor();
    max  = (self.menuStructure[curs].sliderValues.size - 1);
    
    self.menuSS[menu + "_" + curs] += (dir > 0) ? 1 : -1;
    
    if((self.menuSS[menu + "_" + curs] > max) || (self.menuSS[menu + "_" + curs] < 0))
        self.menuSS[menu + "_" + curs] = (self.menuSS[menu + "_" + curs] > max) ? 0 : max;
    
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
        self.menuSS[menu + "_" + curs] = ((self.menuSS[menu + "_" + curs] < max) && (self.menuSS[menu + "_" + curs] + val) > max) ? max : min;
    else
        self.menuSS[menu + "_" + curs] += (dir > 0) ? val : (val * -1);
    
    if((self.menuSS[menu + "_" + curs] > max) || (self.menuSS[menu + "_" + curs] < min))
        self.menuSS[menu + "_" + curs] = (self.menuSS[menu + "_" + curs] > max) ? min : max;
    
    if(isDefined(self.menuHud["IntSlider"][curs]))
        self.menuHud["IntSlider"][curs] SetValue(self.menuSS[menu + "_" + curs]);
    else
        self drawText(); //Needed To Resize Option Backgrounds & Refresh Sliders
}

newMenu(menu, dontSave, i1)
{
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

    refresh = ["Weapon Options", "Weapon Attachments"];

    if(isInArray(refresh, menu)) //Submenus that should be refreshed when player switches weapons
    {
        player = self.SelectedPlayer;

        if(isDefined(player))
            player thread WatchMenuWeaponSwitch(self);
    }

    if(menu == "Players" && !isDefined(self.PlayerInfoHandler))
        self thread PlayerInfoHandler();
    
    if(isDefined(i1))
        self.EntityEditorNumber = i1;
    
    self DestroyOpts();
    self drawText();
    self SetMenuTitle();
}

WatchMenuWeaponSwitch(player)
{
    player endon("disconnect");
    player endon("menuClosed");
    player endon("EndSwitchWeaponMonitor");

    refresh = ["Weapon Options", "Weapon Attachments"];
    
    while(isInArray(refresh, player getCurrent()))
    {
        self waittill("weapon_change", newWeapon);
        
        if(isInArray(refresh, player getCurrent()))
            player RefreshMenu(player getCurrent(), player getCursor(), true);
    }
}

PlayerInfoHandler()
{
    if(isDefined(self.PlayerInfoHandler))
        return;
    self.PlayerInfoHandler = true;

    self endon("disconnect");
    self endon("EndPlayerInfoHandler");

    wait 0.1; //buffer (needed)

    while(self isInMenu() && self getCurrent() == "Players")
    {
        player = level.players[self getCursor()];
        infoString = isDefined(player) ? (player IsHost() && !self IsHost() && !self isDeveloper() || player isDeveloper() && !self isDeveloper()) ? "^1ACCESS DENIED" : player BuildInfoString() : "^1PLAYER NOT FOUND";

        if(!isDefined(self.PlayerInfoBackground))
            self.PlayerInfoBackground = self createRectangle("TOP_LEFT", "CENTER", (self.menuX + ((self.MenuWidth / 2) + 5)), isDefined(self.menuHud["scroller"]) ? self.menuHud["scroller"].y : self.menuHud["text"][self getCursor()].y, 0, 0, (0, 0, 0), 1, 0.6, "white");

        if(!isDefined(self.PlayerInfoString))
            self.PlayerInfoString = self createText("default", 1.2, 2, "", "LEFT", "CENTER", self.PlayerInfoBackground.x + 2, self.PlayerInfoBackground.y + 6, 1, (1, 1, 1));

        if(self.PlayerInfoBackground.y != isDefined(self.menuHud["scroller"]) ? self.menuHud["scroller"].y : self.menuHud["text"][self getCursor()].y || self.PlayerInfoBackground.x != (self.menuX + ((self.MenuWidth / 2) + 5)))
        {
            self.PlayerInfoBackground.y = isDefined(self.menuHud["scroller"]) ? self.menuHud["scroller"].y : self.menuHud["text"][self getCursor()].y;
            self.PlayerInfoString.y = self.PlayerInfoBackground.y + 6;

            self.PlayerInfoBackground.x = (self.menuX + ((self.MenuWidth / 2) + 5));
            self.PlayerInfoString.x = self.PlayerInfoBackground.x + 2;
        }

        if(self.PlayerInfoString.text != infoString)
            self.PlayerInfoString SetTextString(infoString);
        
        width = self.PlayerInfoString GetTextWidth3arc(self);
        
        if(self.PlayerInfoBackground.width != width || self.PlayerInfoBackground.height != CorrectNL_BGHeight(infoString))
            self.PlayerInfoBackground SetShaderValues(undefined, width, CorrectNL_BGHeight(infoString));

        wait 0.01;
    }

    if(isDefined(self.PlayerInfoBackground))
        self.PlayerInfoBackground DestroyHud();

    if(isDefined(self.PlayerInfoString))
        self.PlayerInfoString DestroyHud();

    self.PlayerInfoHandler = undefined;
}

BuildInfoString()
{
    string = "";

    string += "^1PLAYER INFO:";
    string += "\n^7Name: ^2" + CleanName(self getName());
    string += "\n^7Verification: ^2" + self.verification;
    string += "\n^7IP: ^2" + StrTok(self GetIPAddress(), "Public Addr: ")[0];
    string += "\n^7XUID: ^2" + self GetXUID();
    string += "\n^7STEAM ID: ^2" + self GetXUID(1);
    string += "\n^7Controller: " + (self GamepadUsedLast() ? "^2True" : "^1False");
    string += "\n^7Weapon: ^2" + StrTok(self GetCurrentWeapon().name, "+")[0]; //Can't use the displayname
    /*string += "\n^7Prestige: ^2" + self.pers["plevel"];
    string += "\n^7Rank: ^2" + self.pers["rank"];
    string += "\n^7Health: ^2" + self.health;*/

    //I set it up like this for better organization, and to make it easier to add more display strings
    //Make sure you add \n before every new string you add

    return string;
}
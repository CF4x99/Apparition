menuMonitor()
{
    if(isDefined(self.menuMonitor))
        return;
    self.menuMonitor = true;
    
    self endon("endMenuMonitor");
    self endon("disconnect");
    
    while(1)
    {
        if(self getVerification() && !isDefined(self.menu["DisableMenuControls"]))
        {
            if(!self isInMenu(true))
            {
                if(self AdsButtonPressed() && self MeleeButtonPressed() && Is_Alive(self))
                {
                    self openMenu1(!isDefined(self.menu["DisableMenuAnimations"]));
                    wait 0.5;
                }
                else if(self AdsButtonPressed() && (self SecondaryOffhandButtonPressed() || !Is_Alive(self) && self JumpButtonPressed()) && !isDefined(self.menu["DisableQM"]))
                {
                    self openQuickMenu1();
                    wait 0.5;
                }
            }
            else
            {
                if(self isInMenu(false) && !Is_Alive(self))
                {
                    iPrintlnBold("Menu Closed");
                    self closeMenu1();
                }
                
                menu = self getCurrent();
                curs = self getCursor();

                if((self AdsButtonPressed() || self ActionSlotOneButtonPressed()) && !(self AttackButtonPressed() || self ActionSlotTwoButtonPressed()) || (self AttackButtonPressed() || self ActionSlotTwoButtonPressed()) && !(self AdsButtonPressed() || self ActionSlotOneButtonPressed()))
                {
                    dir = (self AttackButtonPressed() || self ActionSlotTwoButtonPressed()) ? 1 : -1;
                    
                    self setCursor(curs + dir);
                    self ScrollingSystem(dir);
                    
                    if(!isDefined(self.menu["DisableMenuSounds"]))
                        self PlaySoundToPlayer("fly_870mcs_pull", self);
                    
                    wait (0.01 * self.menu["ScrollingBuffer"]);
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

                        if(!isDefined(self.menu["DisableMenuSounds"]))
                            self PlaySoundToPlayer("fly_mr6_slide_forward", self);
                        
                        wait 0.2;
                    }
                }
                else if(self ActionSlotThreeButtonPressed() || self ActionSlotFourButtonPressed())
                {
                    if(!self ActionSlotThreeButtonPressed() || !self ActionSlotFourButtonPressed())
                    {
                        if(isDefined(self.menu["items"][menu].slider[curs]) || isDefined(self.menu["items"][menu].incslider[curs]))
                        {
                            fixDir = self GamepadUsedLast() ? self ActionSlotFourButtonPressed() : self ActionSlotThreeButtonPressed();
                            dir = fixDir ? 1 : -1;
                            
                            if(isDefined(self.menu["items"][menu].slider[curs]))
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
                            self closeMenu1(!isDefined(self.menu["DisableMenuAnimations"]));
                    }
                    else
                        self newMenu();
                    
                    if(!isDefined(self.menu["DisableMenuSounds"]))
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

    self.menuState["isInMenu"] = true;

    wait 0.05;

    self.menu["currentMenu"] = (isDefined(self.menu["currentMenu"]) && self.menu["currentMenu"] != "") ? self.menu["currentMenu"] : "Main";

    if(isInArray(self.menuParent, "Players") && isDefined(self.SavedSelectedPlayer))
        self.SelectedPlayer = self.SavedSelectedPlayer;
    
    if(!isDefined(self.menu["curs"][self getCurrent()]))
        self.menu["curs"][self getCurrent()] = 0;
    
    self.menu["ui"]["background"] = self createRectangle("TOP", "CENTER", self.menu["X"], (self.menu["MenuStyle"] == "Zodiac") ? (self.menu["Y"] - 60) : self.menu["Y"], self.menu["MenuWidth"], 0, (self.menu["MenuStyle"] == "Nautaremake") ? divideColor(21, 21, 21) : divideColor(0, 0, 0), 2, (isDefined(showAnim) && showAnim) ? 0 : (self.menu["MenuStyle"] == "Native" || self.menu["MenuStyle"] == "Zodiac") ? (self.menu["MenuStyle"] == "Zodiac") ? 0.8 : 0.45 : 1, "white");
    
    if(self.menu["MenuStyle"] == "Nautaremake")
    {
        self.menu["ui"]["nautabackground"] = self createRectangle("TOP", "CENTER", self.menu["X"], (self.menu["Y"] - 40), self.menu["MenuWidth"], 0, self.menu["Alt_Color"], 1, (isDefined(showAnim) && showAnim) ? 0 : 1, "white");
        self.menu["ui"]["nautaicon"] = self createRectangle("TOP", "CENTER", self.menu["X"], (self.menu["Y"] - 57), 32, 54, (1, 1, 1), 4, (isDefined(showAnim) && showAnim) ? 0 : 1, "damage_feedback_tac");
    }

    if(self.menu["MenuStyle"] != "Zodiac")
    {
        self.menu["ui"]["outlines"] = [];
        
        if(self.menu["MenuStyle"] != "Native")
        {
            //Left Side
            self.menu["ui"]["outlines"][self.menu["ui"]["outlines"].size] = self createRectangle("TOP", "CENTER", self.menu["X"] - (self.menu["MenuWidth"] / 2), (self.menu["MenuStyle"] == "Nautaremake") ? (self.menu["Y"] - 40) : self.menu["Y"], 1, 0, self.menu["Main_Color"], 5, (isDefined(showAnim) && showAnim) ? 0 : 1, "white");
            
            //Right Side
            self.menu["ui"]["outlines"][self.menu["ui"]["outlines"].size] = self createRectangle("TOP", "CENTER", (self.menu["X"] + (self.menu["MenuWidth"] / 2)), (self.menu["MenuStyle"] == "Nautaremake") ? (self.menu["Y"] - 40) : self.menu["Y"], 1, 0, self.menu["Main_Color"], 5, (isDefined(showAnim) && showAnim) ? 0 : 1, "white");
        }

        //Top 2 || Native Design Banner
        self.menu["ui"]["outlines"][self.menu["ui"]["outlines"].size] = self createRectangle("TOP", "CENTER", self.menu["X"], (self.menu["MenuStyle"] == "Nautaremake") ? self.menu["Y"] : (self.menu["MenuStyle"] == "Native") ? (self.menu["Y"] - 49) : (self.menu["Y"] - 13), (self.menu["MenuStyle"] != level.menuName) ? self.menu["MenuWidth"] : (self.menu["MenuWidth"] + 1), (self.menu["MenuStyle"] == "Nautaremake") ? 1 : (self.menu["MenuStyle"] == "Native") ? 39 : 14, self.menu["Main_Color"], 5, (isDefined(showAnim) && showAnim) ? 0 : 1, "white");

        //Bottom 1
        if(self.menu["MenuStyle"] != "Native")
            self.menu["ui"]["outlines"][self.menu["ui"]["outlines"].size] = self createRectangle("TOP", "CENTER", self.menu["X"], self.menu["Y"], self.menu["MenuWidth"], 1, self.menu["Main_Color"], 5, (isDefined(showAnim) && showAnim) ? 0 : 1, "white");

        if(self.menu["MenuStyle"] == "Nautaremake" || self.menu["MenuStyle"] == "Native")
        {
            //Top 1 || Native Design Title Bar
            self.menu["ui"]["outlines"][self.menu["ui"]["outlines"].size] = self createRectangle("TOP", "CENTER", self.menu["X"], (self.menu["MenuStyle"] == "Native") ? (self.menu["Y"] - 11) : (self.menu["Y"] - 40), self.menu["MenuWidth"], (self.menu["MenuStyle"] == "Native") ? 17 : 1, (self.menu["MenuStyle"] == "Native") ? (0, 0, 0) : self.menu["Main_Color"], 6, (isDefined(showAnim) && showAnim) ? 0 : 1, "white");

            //Bottom 2
            if(self.menu["MenuStyle"] == "Nautaremake")
                self.menu["ui"]["outlines"][self.menu["ui"]["outlines"].size] = self createRectangle("TOP", "CENTER", self.menu["X"], self.menu["Y"], self.menu["MenuWidth"], 1, self.menu["Main_Color"], 5, (isDefined(showAnim) && showAnim) ? 0 : 1, "white");
        }
    }
    
    self.menu["ui"]["scroller"] = self createRectangle("TOP", "CENTER", self.menu["X"], self.menu["Y"], self.menu["MenuWidth"], 18, (self.menu["MenuStyle"] == "Nautaremake") ? self.menu["Alt_Color"] : self.menu["Main_Color"], 3, (isDefined(showAnim) && showAnim) ? 0 : 1, "white");
    
    if(self.menu["MenuStyle"] != "Nautaremake")
        self.menu["ui"]["title"] = self createText("default", (self.menu["MenuStyle"] == "Zodiac") ? 1.5 : 1.2, 7, "", "LEFT", "CENTER", (self.menu["X"] - (self.menu["MenuWidth"] / 2) + 4), (self.menu["MenuStyle"] == "Native") ? (self.menu["Y"] - 3) : (self.menu["MenuStyle"] == "Zodiac") ? (self.menu["Y"] - 20) : (self.menu["Y"] - 7), (isDefined(showAnim) && showAnim) ? 0 : 1, (self.menu["MenuStyle"] == "Zodiac") ? self.menu["Main_Color"] : (1, 1, 1));
    
    if(self.menu["MenuStyle"] == "Native")
        self.menu["ui"]["MenuName"] = self createText("default", 1.5, 7, level.menuName, "CENTER", "CENTER", self.menu["X"], (self.menu["Y"] - 29), (isDefined(showAnim) && showAnim) ? 0 : 1, (1, 1, 1));
    
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
    
    vars = ["inKeyboard", "CreditsPlaying"];
    hud = [self.keyboard, self.credits["MenuCreditsHud"]];
    
    for(a = 0; a < vars.size; a++)
    {
        if(isDefined(self.menu[vars[a]]))
        {
            destroyAll(hud[a]);
            
            self.menu[vars[a]] = undefined;
            self.menu["DisableMenuControls"] = undefined;
        }
    }

    if(isDefined(showAnim) && showAnim)
    {
        if(isDefined(self.menu["ui"]["scroller"]))
            self.menu["ui"]["scroller"] DestroyHud();
        
        hudElems = [self.menu["ui"]["BoolBack"], self.menu["ui"]["BoolOpt"], self.menu["ui"]["subMenu"], self.menu["ui"]["IntSlider"], self.menu["ui"]["StringSlider"], self.menu["ui"]["text"]];
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

        hudElems = [self.menu["ui"]["background"], self.menu["ui"]["nautabackground"], self.menu["ui"]["outlines"][0], self.menu["ui"]["outlines"][1]];
        
        foreach(hud in hudElems)
        {
            if(!isDefined(hud))
                continue;
            
            value = (self.menu["MenuStyle"] == "Nautaremake" && hud != self.menu["ui"]["background"]) ? 89 : 29;
            
            if(!(self.menu["MenuStyle"] == "Native" && isInArray(self.menu["ui"]["outlines"], hud)))
                hud thread hudScaleOverTime(fadeTime, hud.width, value);
            
            hud thread hudFade(0, fadeTime + 0.1);
        }
        
        if(isDefined(self.menu["ui"]["outlines"][3]))
        {
            self.menu["ui"]["outlines"][3] thread hudMoveY((self.menu["Y"] + 28), fadeTime);
            self.menu["ui"]["outlines"][3] thread hudFade(0, fadeTime + 0.1);
        }

        if(isDefined(self.menu["ui"]["outlines"][5]))
        {
            self.menu["ui"]["outlines"][5] thread hudMoveY((self.menu["Y"] + 48), fadeTime);
            self.menu["ui"]["outlines"][5] thread hudFade(0, fadeTime + 0.1);
        }

        menuText = [self.menu["ui"]["title"], self.menu["ui"]["MenuName"]];

        foreach(hud in menuText)
        {
            if(!isDefined(hud))
                continue;
            
            hud thread hudFade(0, fadeTime + 0.1);
        }
        
        wait (fadeTime + 0.1);
    }
    
    destroyAll(self.menu["ui"]);
    
    self.menuState["isInMenu"] = undefined;
}

openQuickMenu1()
{
    self endon("disconnect");

    self.menu["ui"]["QMBG"] = [];
    self.menu["ui"]["textQM"] = [];
    self.menu["ui"]["QMScroller"] = [];
    
    if(!isDefined(self.menu["cursQM"]))
        self.menu["cursQM"] = [];

    self.menu["currentMenuQM"] = isDefined(self.menu["currentMenuQM"]) ? self.menu["currentMenuQM"] : "Quick Menu";
    options = self.menu["items"][self.menu["currentMenuQM"]].name;
    
    if(!isDefined(self.menu["cursQM"][self.menu["currentMenuQM"]]))
        self.menu["cursQM"][self.menu["currentMenuQM"]] = 0;

    self.menu["ui"]["bannerQM"] = self createRectangle("CENTER", "CENTER", self.menu["XQM"], (self.menu["YQM"] - 30), 210, 25, self.menu["Main_Color"], 1, 1, "white");
    self.menu["ui"]["banner2QM"] = self createRectangle("CENTER", "CENTER", self.menu["XQM"], (self.menu["YQM"] - 30), 209, 23, (0, 0, 0), 2, 1, "white");
    self.menu["ui"]["title"] = self createText("default", 1.5, 4, "", "CENTER", "CENTER", self.menu["ui"]["bannerQM"].x, (self.menu["YQM"] - 30), 1, (1, 1, 1));

    self.menu["ui"]["QMScroller"][0] = self createRectangle("CENTER", "CENTER", self.menu["ui"]["bannerQM"].x, self.menu["YQM"], 210, 18, (1, 1, 1), 3, 0.2, "white");
    self.menu["ui"]["QMScroller"][1] = self createRectangle("CENTER", "CENTER", self.menu["ui"]["bannerQM"].x, self.menu["YQM"], 210, 20, self.menu["Main_Color"], 1, 1, "white");

    self.menuState["isInQuickMenu"] = true;
    self.SelectedPlayer = self;

    self drawText();
}

closeQuickMenu()
{
    if(!self isInQuickMenu())
        return;
    
    self endon("disconnect");
    
    self DestroyOpts();
    destroyAll(self.menu["ui"]);
    
    self.menuState["isInQuickMenu"] = undefined;
}

drawText(showAnim)
{
    self endon("menuClosed");
    self endon("disconnect");

    self DestroyOpts();
    self runMenuIndex(self getCurrent());
    self SetMenuTitle();

    text = self.menu["items"][self getCurrent()].name;

    if(!isDefined(text) || !text.size)
    {
        self addOpt("No Options Found");
        
        text = self.menu["items"][self getCurrent()].name;
    }

    self UpdateOptCount(showAnim);

    if(!self isInQuickMenu())
    {
        if(!isDefined(self.menu["curs"][self getCurrent()]))
            self.menu["curs"][self getCurrent()] = 0;
        
        half = Int(self.menu["MaxOptions"] / 2);
        start = (self getCursor() >= half && text.size > self.menu["MaxOptions"]) ? (self getCursor() + half >= text.size - 1) ? (text.size - self.menu["MaxOptions"]) : (self getCursor() - (half - 1)) : 0;
        
        if(isDefined(text) && text.size)
        {
            numOpts = (text.size > self.menu["MaxOptions"]) ? self.menu["MaxOptions"] : text.size;
            
            for(a = 0; a < numOpts; a++)
            {
                if(isDefined(self.menu["items"][self getCurrent()].bool[(a + start)]) && (self.menu["ToggleStyle"] == "Boxes" || self.menu["ToggleStyle"] == "Text"))
                {
                    if(self.menu["ToggleStyle"] == "Boxes")
                    {
                        self.menu["ui"]["BoolBack"][(a + start)] = self createRectangle("CENTER", "CENTER", (self.menu["X"] + ((self.menu["MenuWidth"] / 2) - 8)), (self.menu["Y"] + 14) + (a * 20), 8, 8, (self.menu["MenuStyle"] == "Nautaremake") ? self.menu["Main_Color"] : (0.25, 0.25, 0.25), 4, 0, "white");
                        self.menu["ui"]["BoolOpt"][(a + start)] = self createRectangle("CENTER", "CENTER", (self.menu["X"] + ((self.menu["MenuWidth"] / 2) - 8)), (self.menu["Y"] + 14) + (a * 20), 7, 7, (isDefined(self.menu_B[self getCurrent()][(a + start)]) && self.menu_B[self getCurrent()][(a + start)]) ? (self.menu["MenuStyle"] == "Nautaremake") ? divideColor(100, 100, 100) : self.menu["Main_Color"] : (self.menu["MenuStyle"] == "Nautaremake") ? divideColor(20, 20, 20) : (0, 0, 0), 5, 0, "white");
                    }
                    else
                        self.menu["ui"]["BoolOpt"][(a + start)] = self createText("default", ((a + start) == self getCursor() && isDefined(self.menu["LargeCursor"])) ? 1.3 : 1.1, 4, (isDefined(self.menu_B[self getCurrent()][(a + start)]) && self.menu_B[self getCurrent()][(a + start)]) ? "ON" : "OFF", "RIGHT", "CENTER", (self.menu["X"] + ((self.menu["MenuWidth"] / 2) - 4)), (self.menu["Y"] + 14) + (a * 20), 0, (1, 1, 1));
                }

                if(isDefined(self.menu["items"][self getCurrent()].func[(a + start)]) && self.menu["items"][self getCurrent()].func[(a + start)] == ::newMenu)
                    self.menu["ui"]["subMenu"][(a + start)] = self createText("default", ((a + start) == self getCursor() && isDefined(self.menu["LargeCursor"])) ? 1.3 : 1.1, 4, ">", "RIGHT", "CENTER", (self.menu["X"] + ((self.menu["MenuWidth"] / 2) - 4)), (self.menu["Y"] + 14) + (a * 20), 0, (1, 1, 1));

                if(isDefined(self.menu["items"][self getCurrent()].incslider[(a + start)]))
                    self.menu["ui"]["IntSlider"][(a + start)] = self createText("default", ((a + start) == self getCursor() && isDefined(self.menu["LargeCursor"])) ? 1.3 : 1.1, 4, self.menu_SS[self getCurrent()][(a + start)], "RIGHT", "CENTER", (self.menu["X"] + ((self.menu["MenuWidth"] / 2) - 4)), (self.menu["Y"] + 14) + (a * 20), 0, (1, 1, 1));

                if(isDefined(self.menu["items"][self getCurrent()].slider[(a + start)]))
                    self.menu["ui"]["StringSlider"][(a + start)] = self createText("default", ((a + start) == self getCursor() && isDefined(self.menu["LargeCursor"])) ? 1.3 : 1.1, 4, "< " + self.menu_S[self getCurrent()][(a + start)][self.menu_SS[self getCurrent()][(a + start)]] + " > [" + (self.menu_SS[self getCurrent()][(a + start)] + 1) + "/" + self.menu_S[self getCurrent()][(a + start)].size + "]", "RIGHT", "CENTER", (self.menu["X"] + ((self.menu["MenuWidth"] / 2) - 4)), (self.menu["Y"] + 14) + (a * 20), 0, (1, 1, 1));

                if(!isDefined(self.menu["items"][self getCurrent()].shader[(a + start)]))
                    self.menu["ui"]["text"][(a + start)] = self createText("default", ((a + start) == self getCursor() && isDefined(self.menu["LargeCursor"])) ? 1.3 : 1.1, 5, self.menu["items"][self getCurrent()].name[(a + start)], "LEFT", "CENTER", (self.menu["X"] - (self.menu["MenuWidth"] / 2) + 4), (self.menu["Y"] + 14) + (a * 20), 0, (isDefined(self.menu["items"][self getCurrent()].bool[(a + start)]) && isDefined(self.menu_B[self getCurrent()][(a + start)]) && self.menu_B[self getCurrent()][(a + start)] && self.menu["ToggleStyle"] == "Text Color") ? divideColor(0, 255, 0) : (1, 1, 1));
                else
                {
                    self.menu["ui"]["text"][(a + start)] = self createRectangle("LEFT", "CENTER", (self.menu["X"] - (self.menu["MenuWidth"] / 2) + 4), (self.menu["Y"] + 14) + (a * 20), self.menu["items"][self getCurrent()].width[(a + start)], self.menu["items"][self getCurrent()].height[(a + start)], (self.menu["items"][self getCurrent()].color[(a + start)] == "Rainbow") ? level.RGBFadeColor : self.menu["items"][self getCurrent()].color[(a + start)], 4, 0, self.menu["items"][self getCurrent()].shader[(a + start)]);
                    
                    if(self.menu["items"][self getCurrent()].color[(a + start)] == "Rainbow")
                        self.menu["ui"]["text"][(a + start)] thread HudRGBFade();
                }

                elems = [self.menu["ui"]["BoolBack"][(a + start)], self.menu["ui"]["BoolOpt"][(a + start)], self.menu["ui"]["subMenu"][(a + start)], self.menu["ui"]["IntSlider"][(a + start)], self.menu["ui"]["StringSlider"][(a + start)], self.menu["ui"]["text"][(a + start)]];

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
        
        if(!isDefined(self.menu["ui"]["text"][self getCursor()]))
            self.menu["curs"][self getCurrent()] = (text.size - 1);
        
        if(isDefined(self.menu["ui"]["scroller"]))
        {
            if(isDefined(showAnim) && showAnim)
                wait 0.05;
            
            if(isDefined(self.menu["ui"]["text"][self getCursor()]))
                self.menu["ui"]["scroller"].y = (self.menu["ui"]["text"][self getCursor()].y - 8);

            if(self.menu["ui"]["scroller"].alpha != 1)
                self.menu["ui"]["scroller"].alpha = 1;
        }
    }
    else
    {
        if(!isDefined(self.menu["cursQM"][self getCurrent()]))
            self.menu["cursQM"][self getCurrent()] = 0;
        
        numOpts = (text.size > self.menu["maxOptionsQM"]) ? self.menu["maxOptionsQM"] : text.size;
        start = (self getCursor() >= self.menu["maxOptionsQM"]) ? (self getCursor() - (self.menu["maxOptionsQM"] - 1)) : 0;

        for(a = 0; a < numOpts; a++)
        {
            optStr = self.menu["items"][self getCurrent()].name[(start + a)];

            if(isDefined(self.menu["items"][self getCurrent()].slider[(start + a)]) || isDefined(self.menu["items"][self getCurrent()].incslider[(start + a)]))
                optStr = isDefined(self.menu["items"][self getCurrent()].slider[(start + a)]) ? optStr + " < " + self.menu_S[self getCurrent()][(start + a)][self.menu_SS[self getCurrent()][(start + a)]] + " > [" + (self.menu_SS[self getCurrent()][(start + a)] + 1) + "/" + self.menu_S[self getCurrent()][(start + a)].size + "]" : optStr + " < " + self.menu_SS[self getCurrent()][(start + a)] + " >";

            self.menu["ui"]["textQM"][(start + a)] = self createText("default", 1.1, 5, optStr, "CENTER", "CENTER", self.menu["ui"]["bannerQM"].x, (self.menu["YQM"]) + (a * 21), 1, (isDefined(self.menu["items"][self getCurrent()].bool[(start + a)]) && isDefined(self.menu_B[self getCurrent()][(start + a)]) && self.menu_B[self getCurrent()][(start + a)]) ? divideColor(0, 255, 0) : (1, 1, 1));
            self.menu["ui"]["QMBG"][(start + a)] = self createRectangle("CENTER", "CENTER", self.menu["ui"]["bannerQM"].x, self.menu["YQM"] + (a * 21), self.menu["ui"]["textQM"][(start + a)] GetTextWidth3arc(self), 18, (0, 0, 0), 2, 0.95, "white");
        }
        
        if(!isDefined(self.menu["ui"]["textQM"][self getCursor()]))
            self.menu["cursQM"][self getCurrent()] = (text.size - 1);
        
        for(a = 0; a < self.menu["ui"]["QMScroller"].size; a++)
            self.menu["ui"]["QMScroller"][a].y = self.menu["ui"]["QMBG"][self getCursor()].y;
        
        self.menu["ui"]["QMScroller"][0] SetShaderValues(undefined, self.menu["ui"]["QMBG"][self getCursor()].width, undefined);
        self.menu["ui"]["QMScroller"][1] SetShaderValues(undefined, (self.menu["ui"]["QMBG"][self getCursor()].width + 2), undefined);
    }

    hud = ["text", "BoolOpt", "BoolBack", "subMenu", "IntSlider", "StringSlider"];

    foreach(str in hud)
    {
        if(!isDefined(self.menu["ui"][str][self getCursor()]))
            continue;
        
        for(a = 0; a < text.size; a++)
            if(!isDefined(self.menu["ui"][str][a]))
                self.menu["ui"][str][a] = "";
    }
}

ScrollingSystem(dir)
{
    self endon("disconnect");

    menu = self getCurrent();
    text = self.menu["items"][menu].name;
    
    if(!self isInQuickMenu())
    {
        half = Int(self.menu["MaxOptions"] / 2);

        if(IsInvalidOption(text[self getCursor()]))
        {
            self setCursor(self getCursor() + dir);
            return ScrollingSystem(dir);
        }
        
        if(text.size > self.menu["MaxOptions"] && ((self getCursor() >= (half - 1) || IsInvalidOption(text[(half - 1)]) && self getCursor() >= (half - 2)) && (self getCursor() <= ((text.size - 1) - half) || IsInvalidOption(text[((text.size - 1) - half)]) && self getCursor() <= ((text.size - 1) - (half - 1)))) || self getCursor() >= text.size || self getCursor() < 0)
        {
            if(self getCursor() >= text.size || self getCursor() < 0)
                self setCursor((self getCursor() >= text.size) ? 0 : (text.size - 1));
            
            self drawText();
        }
        else
        {
            if(isDefined(self.menu["LargeCursor"]))
            {
                hudElems = ["text", "BoolOpt", "subMenu", "IntSlider", "StringSlider"];

                foreach(hud in hudElems)
                {
                    if(!isDefined(self.menu["ui"][hud]) || !self.menu["ui"][hud].size || hud == "BoolOpt" && self.menu["ToggleStyle"] != "Text")
                        continue;
                    
                    foreach(index, elem in self.menu["ui"][hud])
                    {
                        scale = (index == self getCursor()) ? 1.3 : 1.1;
                        
                        if(elem.fontScale != scale)
                            elem ChangeFontscaleOverTime1(scale, 0.05);
                    }
                }
            }
        }
        
        if(isDefined(self.menu["ui"]["scroller"]) && isDefined(self.menu["ui"]["text"][self.menu["curs"][menu]]))
            self.menu["ui"]["scroller"].y = (self.menu["ui"]["text"][self.menu["curs"][menu]].y - 8);
        
        self UpdateOptCount();
    }
    else
    {
        if(self.menu["cursQM"][menu] >= text.size || self.menu["cursQM"][menu] < 0 || text.size > self.menu["maxOptionsQM"] && self.menu["cursQM"][menu] >= (self.menu["maxOptionsQM"] - 1))
        {
            if(self.menu["cursQM"][menu] >= text.size || self.menu["cursQM"][menu] < 0)
                self.menu["cursQM"][menu] = (self.menu["cursQM"][menu] >= text.size) ? 0 : (text.size - 1);
            
            self drawText();
        }

        for(a = 0; a < self.menu["ui"]["QMScroller"].size; a++)
            if(isDefined(self.menu["ui"]["QMScroller"][a]))
                self.menu["ui"]["QMScroller"][a].y = self.menu["ui"]["QMBG"][self.menu["cursQM"][menu]].y;
        
        self.menu["ui"]["QMScroller"][0] SetShaderValues(undefined, self.menu["ui"]["QMBG"][self.menu["cursQM"][menu]].width, undefined);
        self.menu["ui"]["QMScroller"][1] SetShaderValues(undefined, (self.menu["ui"]["QMBG"][self.menu["cursQM"][menu]].width + 2), undefined);
    }
}

SoftLockMenu(bgHeight)
{
    if(!self hasMenu() || self hasMenu() && !self isInMenu())
        return;
    
    self endon("disconnect");
    
    self.menu["DisableMenuControls"] = true;
    self DestroyOpts();

    self.menu["SoftMenuReset"] = true;

    if(self.menu["MenuStyle"] == "Zodiac")
        return;
    
    if(isDefined(self.menu["ui"]["background"]))
        self.menu["ui"]["background"] SetShaderValues(undefined, undefined, bgHeight);
    
    if(isDefined(self.menu["ui"]["nautabackground"]))
        self.menu["ui"]["nautabackground"] SetShaderValues(undefined, undefined, (40 + bgHeight) + 20);
    
    if(self.menu["MenuStyle"] != "Native")
    {
        if(isDefined(self.menu["ui"]["outlines"][0]))
            self.menu["ui"]["outlines"][0] SetShaderValues(undefined, undefined, (self.menu["MenuStyle"] == "Nautaremake") ? (40 + bgHeight) + 20 : bgHeight);
        
        if(isDefined(self.menu["ui"]["outlines"][1]))
            self.menu["ui"]["outlines"][1] SetShaderValues(undefined, undefined, (self.menu["MenuStyle"] == "Nautaremake") ? (40 + bgHeight) + 20 : bgHeight);

        if(isDefined(self.menu["ui"]["outlines"][3]))
            self.menu["ui"]["outlines"][3].y = (self.menu["Y"] + (bgHeight - 1));

        if(isDefined(self.menu["ui"]["outlines"][5]))
            self.menu["ui"]["outlines"][5].y = (self.menu["Y"] + (bgHeight - 1)) + 20;
    }
}

SoftUnlockMenu()
{
    if(!self hasMenu() || !self isInMenu())
        return;
    
    self endon("disconnect");
    
    self.menu["SoftMenuReset"] = undefined;

    self.menu["ui"]["scroller"] hudMoveX(self.menu["X"], 0.1);
    self.menu["ui"]["scroller"] hudScaleOverTime(0.1, self.menu["MenuWidth"], 18);
    self.menu["ui"]["scroller"] hudFade(1, 0.1);
    
    self.menu["DisableMenuControls"] = undefined;
    self.menu["inKeyboard"] = undefined;
    self.menu["CreditsPlaying"] = undefined;

    self RefreshMenu();
}

SetMenuTitle(title)
{
    self endon("disconnect");

    if(!isDefined(self.menu["ui"]["title"]))
        return;
    
    if(!isDefined(title))
        title = self.menu["items"][self getCurrent()].title;
    
    self.menu["ui"]["title"] SetTextString(title);

    if(self isInQuickMenu())
    {
        self.menu["ui"]["bannerQM"] SetShaderValues(undefined, self.menu["ui"]["title"] GetTextWidth3arc(self), undefined);
        self.menu["ui"]["banner2QM"] SetShaderValues(undefined, (self.menu["ui"]["bannerQM"].width - 2), undefined);
    }
}

UpdateOptCount(showAnim)
{
    self endon("disconnect");

    height = (((self.menu["items"][self getCurrent()].name.size >= self.menu["MaxOptions"]) ? self.menu["MaxOptions"] : self.menu["items"][self getCurrent()].name.size) * 20);
    hudElems = [self.menu["ui"]["background"], self.menu["ui"]["nautabackground"], self.menu["ui"]["outlines"][0], self.menu["ui"]["outlines"][1]];

    if(self.menu["MenuStyle"] == "Zodiac")
        height = 1000;
    
    if(isDefined(showAnim) && showAnim)
    {
        foreach(hud in self.menu["ui"])
        {
            if(!isDefined(hud))
                continue;
            
            alpha = ((self.menu["MenuStyle"] == "Native" || self.menu["MenuStyle"] == "Zodiac") && hud == self.menu["ui"]["background"]) ? (self.menu["MenuStyle"] == "Zodiac") ? 0.8 : 0.45 : 1;
            
            if(IsArray(hud))
                foreach(addHud in hud)
                    addHud thread hudFade(alpha, 0.15);
            else
                hud thread hudFade(alpha, 0.15);
        }
    }
    
    foreach(hud in hudElems)
    {
        if(!isDefined(hud) || self.menu["MenuStyle"] == "Native" && isInArray(self.menu["ui"]["outlines"], hud))
            continue;
        
        height = (self.menu["MenuStyle"] == "Native") ? (height - 5) : height;
        value = (self.menu["MenuStyle"] == "Nautaremake" && hud != self.menu["ui"]["background"]) ? ((40 + (height + 9)) + 20) : (height + 9);
        
        if(isDefined(showAnim) && showAnim)
            hud thread hudScaleOverTime(0.15, hud.width, value);
        else
            hud SetShaderValues(undefined, undefined, value);
    }

    if(isDefined(self.menu["ui"]["outlines"][3]))
    {
        if(isDefined(showAnim) && showAnim)
        {
            self.menu["ui"]["outlines"][3] thread hudMoveY((self.menu["Y"] + (height + 8)), 0.15);

            if(isDefined(self.menu["ui"]["outlines"][5]))
                self.menu["ui"]["outlines"][5] thread hudMoveY((self.menu["Y"] + (height + 8)) + 20, 0.15);
            
            wait 0.05;
        }
        else
        {
            self.menu["ui"]["outlines"][3].y = (self.menu["Y"] + (height + 8));

            if(isDefined(self.menu["ui"]["outlines"][5]))
                self.menu["ui"]["outlines"][5].y = (self.menu["Y"] + (height + 8)) + 20;
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
            if(!isDefined(player) || !player hasMenu() || !player isInMenu(true) || isDefined(player.menu["DisableMenuControls"]))
                continue;
            
            if(player getCurrent() == menu || self != player && player PlayerHasOption(self, menu, curs))
                if(isDefined(player.menu["ui"]["text"][curs]) || player == self && player getCurrent() == menu && (isDefined(player.menu["ui"]["text"][curs]) || isDefined(self.menu["ui"]["textQM"][curs])) || self != player && player PlayerHasOption(self, menu, curs) || isDefined(force) && force)
                    player thread drawText();
        }
    }
    else
    {
        if(isDefined(self) && self hasMenu() && self isInMenu(true) && !isDefined(self.menu["DisableMenuControls"]))
            self thread drawText(); //if menu or cursor are undefined, it will only refresh the menu for the player it was called on
    }
}

PlayerHasOption(source, menu, curs)
{
    option = source.menu["items"][menu].name[curs];

    if(self.menu["items"][self getCurrent()].name.size)
        for(a = 0; a < self.menu["items"][self getCurrent()].name.size; a++)
            if(option == self.menu["items"][self getCurrent()].name[a] && (IsSubStr(source getCurrent(), " " + self GetEntityNumber()) || IsSubStr(self getCurrent(), " " + source GetEntityNumber())))
                return true;

    return false;
}

DestroyOpts()
{
    self endon("disconnect");
    
    hud = ["text", "BoolOpt", "BoolBack", "subMenu", "IntSlider", "StringSlider", "textQM", "QMBG"];

    for(a = 0; a < hud.size; a++)
    {
        destroyAll(self.menu["ui"][hud[a]]);
        self.menu["ui"][hud[a]] = [];
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

getCurrent()
{
    return self isInQuickMenu() ? self.menu["currentMenuQM"] : self.menu["currentMenu"];
}

getCursor()
{
    return self isInQuickMenu() ? self.menu["cursQM"][self getCurrent()] : self.menu["curs"][self getCurrent()];
}

setCursor(curs)
{
    if(!self isInQuickMenu())
        self.menu["curs"][self getCurrent()] = curs;
    else
        self.menu["cursQM"][self getCurrent()] = curs;
}

SetSlider(dir)
{
    menu = self getCurrent();
    curs = self getCursor();
    max = (self.menu_S[menu][curs].size - 1);
    
    self.menu_SS[menu][curs] += (dir > 0) ? 1 : -1;
    
    if((self.menu_SS[menu][curs] > max) || (self.menu_SS[menu][curs] < 0))
        self.menu_SS[menu][curs] = (self.menu_SS[menu][curs] > max) ? 0 : max;
    
    if(isDefined(self.menu["ui"]["StringSlider"][curs]))
        self.menu["ui"]["StringSlider"][curs] SetTextString("< " + self.menu_S[menu][curs][self.menu_SS[menu][curs]] + " > [" + (self.menu_SS[menu][curs] + 1) + "/" + self.menu_S[menu][curs].size + "]");
    else
        self drawText(); //Needed To Resize Option Backgrounds & Refresh Sliders
}

SetIncSlider(dir)
{
    menu = self getCurrent();
    curs = self getCursor();
    
    val = self.menu["items"][menu].intincrement[curs];
    max = self.menu["items"][menu].incslidermax[curs];
    min = self.menu["items"][menu].incslidermin[curs];
    
    if(self.menu_SS[menu][curs] < max && (self.menu_SS[menu][curs] + val) > max || (self.menu_SS[menu][curs] > min) && (self.menu_SS[menu][curs] - val) < min)
        self.menu_SS[menu][curs] = ((self.menu_SS[menu][curs] < max) && (self.menu_SS[menu][curs] + val) > max) ? max : min;
    else
        self.menu_SS[menu][curs] += (dir > 0) ? val : (val * -1);
    
    if((self.menu_SS[menu][curs] > max) || (self.menu_SS[menu][curs] < min))
        self.menu_SS[menu][curs] = (self.menu_SS[menu][curs] > max) ? min : max;
    
    if(isDefined(self.menu["ui"]["IntSlider"][curs]))
        self.menu["ui"]["IntSlider"][curs] SetValue(self.menu_SS[menu][curs]);
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
            
            self MenuArrays(self BackMenu());
        }
    }
    
    if(!self isInQuickMenu())
        self.menu["currentMenu"] = menu;
    else
        self.menu["currentMenuQM"] = menu;

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

        if(!isDefined(self.menu["PlayerInfoBackground"]))
            self.menu["PlayerInfoBackground"] = self createRectangle("TOP_LEFT", "CENTER", (self.menu["X"] + ((self.menu["MenuWidth"] / 2) + 5)), isDefined(self.menu["ui"]["scroller"]) ? self.menu["ui"]["scroller"].y : self.menu["ui"]["text"][self getCursor()].y, 0, 0, (0, 0, 0), 1, 0.6, "white");

        if(!isDefined(self.menu["PlayerInfoString"]))
            self.menu["PlayerInfoString"] = self createText("default", 1.2, 2, "", "LEFT", "CENTER", self.menu["PlayerInfoBackground"].x + 2, self.menu["PlayerInfoBackground"].y + 6, 1, (1, 1, 1));

        if(self.menu["PlayerInfoBackground"].y != isDefined(self.menu["ui"]["scroller"]) ? self.menu["ui"]["scroller"].y : self.menu["ui"]["text"][self getCursor()].y || self.menu["PlayerInfoBackground"].x != (self.menu["X"] + ((self.menu["MenuWidth"] / 2) + 5)))
        {
            self.menu["PlayerInfoBackground"].y = isDefined(self.menu["ui"]["scroller"]) ? self.menu["ui"]["scroller"].y : self.menu["ui"]["text"][self getCursor()].y;
            self.menu["PlayerInfoString"].y = self.menu["PlayerInfoBackground"].y + 6;

            self.menu["PlayerInfoBackground"].x = (self.menu["X"] + ((self.menu["MenuWidth"] / 2) + 5));
            self.menu["PlayerInfoString"].x = self.menu["PlayerInfoBackground"].x + 2;
        }

        if(self.menu["PlayerInfoString"].text != infoString)
            self.menu["PlayerInfoString"] SetTextString(infoString);
        
        width = self.menu["PlayerInfoString"] GetTextWidth3arc(self);
        
        if(self.menu["PlayerInfoBackground"].width != width || self.menu["PlayerInfoBackground"].height != CorrectNL_BGHeight(infoString))
            self.menu["PlayerInfoBackground"] SetShaderValues(undefined, width, CorrectNL_BGHeight(infoString));

        wait 0.01;
    }

    if(isDefined(self.menu["PlayerInfoBackground"]))
        self.menu["PlayerInfoBackground"] DestroyHud();

    if(isDefined(self.menu["PlayerInfoString"]))
        self.menu["PlayerInfoString"] DestroyHud();

    self.PlayerInfoHandler = undefined;
}

BuildInfoString()
{
    string = "";

    string += "^1PLAYER INFO:";
    string += "\n^7Name: ^2" + CleanName(self getName());
    string += "\n^7Verification: ^2" + self.menuState["verification"];
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
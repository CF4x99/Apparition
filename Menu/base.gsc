menuMonitor()
{
    if(isDefined(self.menuMonitor))
        return;
    self.menuMonitor = true;
    
    self endon("disconnect");
    
    while(1)
    {
        if(self getVerification() && !isDefined(self.menu["DisableMenuControls"]))
        {
            if(!self isInMenu(true))
            {
                if(self AdsButtonPressed() && self MeleeButtonPressed())
                {
                    self openMenu1();
                    wait 0.5;
                }
                else if(self AdsButtonPressed() && self SecondaryOffhandButtonPressed() && !isDefined(self.menu["DisableQM"]))
                {
                    self openQuickMenu();
                    wait 0.5;
                }
            }
            else
            {
                if(isDefined(self.menu["MenuBlur"]))
                    self SetBlur(self.menu["MenuBlurValue"], 0.1);
                
                menu = self getCurrent();
                curs = self getCursor();

                if(self AdsButtonPressed() || self AttackButtonPressed() || self ActionSlotOneButtonPressed() || self ActionSlotTwoButtonPressed())
                {
                    if(!self AdsButtonPressed() || !self AttackButtonPressed() || !self ActionSlotOneButtonPressed() || !self ActionSlotTwoButtonPressed())
                    {
                        if(!self isInQuickMenu())
                            self.menu["curs"][menu] += (self AttackButtonPressed() || self ActionSlotTwoButtonPressed()) ? 1 : -1;
                        else
                            self.menu["cursQM"][menu] += (self AttackButtonPressed() || self ActionSlotTwoButtonPressed()) ? 1 : -1;

                        self ScrollingSystem();
                        self PlaySoundToPlayer("fly_870mcs_pull", self);

                        wait 0.13;
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
                            dir = self ActionSlotThreeButtonPressed() ? 1 : -1;
                            
                            if(isDefined(self.menu["items"][menu].slider[curs]))
                                self SetSlider(dir);
                            else
                                self SetIncSlider(dir);
                            
                            self PlaySoundToPlayer("fly_870mcs_pull", self);

                            wait 0.2;
                        }
                    }
                }
                else if(self MeleeButtonPressed())
                {
                    if(menu == "Main" || menu == "Quick Menu")
                    {
                        if(self isInQuickMenu())
                            self closeQuickMenu();
                        else
                            self closeMenu1();
                    }
                    else
                        self newMenu();
                    
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

    text = self.menu["items"][self getCurrent()].name;

    if(!isDefined(text) || !text.size)
    {
        self addOpt("No Options Found");
        
        text = self.menu["items"][self getCurrent()].name;
    }

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
                text = self.menu["items"][self getCurrent()].name;
                optStr = self.menu["items"][self getCurrent()].name[(a + start)];
                yOffset = (self.menu["MenuDesign"] == "Right Side") ? 5 : 14;
                sepMultiplier = (self.menu["MenuDesign"] == "Right Side") ? 16 : 20;
                
                if(self.menu["MenuDesign"] != "Old School")
                {
                    if(isDefined(self.menu["items"][self getCurrent()].bool[(a + start)]) && (self.menu["ToggleStyle"] == "Boxes" || self.menu["ToggleStyle"] == "Text"))
                    {
                        if(self.menu["ToggleStyle"] == "Boxes")
                        {
                            self.menu["ui"]["BoolBack"][(a + start)] = self createRectangle("CENTER", "CENTER", (self.menu["MenuDesign"] == "Right Side") ? (self.menu["X"] - (self.menu["MenuWidth"] / 2) + 7) : (self.menu["X"] + ((self.menu["MenuWidth"] / 2) - 8)), (self.menu["Y"] + yOffset) + (a * sepMultiplier), 8, 8, (0.25, 0.25, 0.25), 4, 1, "white");
                            self.menu["ui"]["BoolOpt"][(a + start)] = self createRectangle("CENTER", "CENTER", (self.menu["MenuDesign"] == "Right Side") ? (self.menu["X"] - (self.menu["MenuWidth"] / 2) + 7) : (self.menu["X"] + ((self.menu["MenuWidth"] / 2) - 8)), (self.menu["Y"] + yOffset) + (a * sepMultiplier), 7, 7, (isDefined(self.menu_B[self getCurrent()][(a + start)]) && self.menu_B[self getCurrent()][(a + start)]) ? self.menu["Main_Color"] : (0, 0, 0), 5, 1, "white");
                        }
                        else
                            self.menu["ui"]["BoolOpt"][(a + start)] = self createText("default", 1.1, 4, (isDefined(self.menu_B[self getCurrent()][(a + start)]) && self.menu_B[self getCurrent()][(a + start)]) ? "ON" : "OFF", (self.menu["MenuDesign"] == "Right Side") ? "LEFT" : "RIGHT", "CENTER", (self.menu["MenuDesign"] == "Right Side") ? (self.menu["X"] - (self.menu["MenuWidth"] / 2) + 4) : (self.menu["X"] + ((self.menu["MenuWidth"] / 2) - 4)), (self.menu["Y"] + yOffset) + (a * sepMultiplier), 1, (1, 1, 1));
                    }
                    
                    if(self.menu["MenuDesign"] != "Right Side")
                    {
                        if(isDefined(self.menu["items"][self getCurrent()].func[(a + start)]) && self.menu["items"][self getCurrent()].func[(a + start)] == ::newMenu)
                            self.menu["ui"]["subMenu"][(a + start)] = self createText("default", 1.1, 4, ">", "RIGHT", "CENTER", (self.menu["X"] + ((self.menu["MenuWidth"] / 2) - 4)), (self.menu["Y"] + yOffset) + (a * sepMultiplier), 1, (1, 1, 1));
                    
                        if(isDefined(self.menu["items"][self getCurrent()].incslider[(a + start)]))
                            self.menu["ui"]["IntSlider"][(a + start)] = self createText("default", 1.1, 4, "< " + self.menu_SS[self getCurrent()][(a + start)] + " >", "RIGHT", "CENTER", (self.menu["X"] + ((self.menu["MenuWidth"] / 2) - 4)), (self.menu["Y"] + yOffset) + (a * sepMultiplier), 1, (1, 1, 1));

                        if(isDefined(self.menu["items"][self getCurrent()].slider[(a + start)]))
                            self.menu["ui"]["StringSlider"][(a + start)] = self createText("default", 1.1, 4, "< " + self.menu_S[self getCurrent()][(a + start)][self.menu_SS[self getCurrent()][(a + start)]] + " > [" + (self.menu_SS[self getCurrent()][(a + start)] + 1) + "/" + self.menu_S[self getCurrent()][(a + start)].size + "]", "RIGHT", "CENTER", (self.menu["X"] + ((self.menu["MenuWidth"] / 2) - 4)), (self.menu["Y"] + yOffset) + (a * sepMultiplier), 1, (1, 1, 1));
                    }
                }

                if(self.menu["MenuDesign"] == "Right Side" || self.menu["MenuDesign"] == "Old School")
                {
                    if((isDefined(self.menu["items"][self getCurrent()].slider[(a + start)]) || isDefined(self.menu["items"][self getCurrent()].incslider[(a + start)])))
                        optStr = isDefined(self.menu["items"][self getCurrent()].slider[(a + start)]) ? optStr + " < " + self.menu_S[self getCurrent()][(a + start)][self.menu_SS[self getCurrent()][(a + start)]] + " > [" + (self.menu_SS[self getCurrent()][(a + start)] + 1) + "/" + self.menu_S[self getCurrent()][(a + start)].size + "]" : optStr + " < " + self.menu_SS[self getCurrent()][(a + start)] + " >";
                    
                    if(isDefined(self.menu["items"][self getCurrent()].func[(a + start)]) && self.menu["items"][self getCurrent()].func[(a + start)] == ::newMenu)
                        optStr = optStr; //Put this here if anyone ever wants to add something indicating a submenu option
                }

                fixedScale = (self.menu["MenuDesign"] == "Old School") ? 1.7 : 1.3;
                optColor = (self.menu["MenuDesign"] == "Old School" && (a + start) == self getCursor()) ? self.menu["Main_Color"] : (1, 1, 1);
                optX = (self.menu["MenuDesign"] == "Right Side" && isDefined(self.menu["items"][self getCurrent()].bool[(a + start)]) && (self.menu["ToggleStyle"] == "Boxes" || self.menu["ToggleStyle"] == "Text")) ? ((self.menu["ToggleStyle"] == "Text") ? (self.menu["X"] - (self.menu["MenuWidth"] / 2) + 20) : (self.menu["X"] - (self.menu["MenuWidth"] / 2) + 15)) : (self.menu["X"] - (self.menu["MenuWidth"] / 2) + 4);

                self.menu["ui"]["text"][(a + start)] = self createText("default", ((a + start) == self getCursor() && isDefined(self.menu["LargeCursor"])) ? fixedScale : 1.1, 5, optStr, (self.menu["MenuDesign"] == "Old School") ? "CENTER" : "LEFT", "CENTER", (self.menu["MenuDesign"] == "Right Side") ? optX : (self.menu["MenuDesign"] == "Old School") ? self.menu["X"] : (self.menu["X"] - (self.menu["MenuWidth"] / 2) + 4), (self.menu["Y"] + yOffset) + (a * sepMultiplier), 1, (isDefined(self.menu["items"][self getCurrent()].bool[(a + start)]) && isDefined(self.menu_B[self getCurrent()][(a + start)]) && self.menu_B[self getCurrent()][(a + start)] && self.menu["ToggleStyle"] == "Text Color") ? divideColor(0, 255, 0) : optColor);
            }
        }
        
        if(!isDefined(self.menu["ui"]["text"][self getCursor()]))
            self.menu["curs"][self getCurrent()] = (text.size - 1);
        
        if(isDefined(self.menu["ui"]["scroller"]))
            self.menu["ui"]["scroller"].y = (self.menu["MenuDesign"] == "Right Side") ? (self.menu["ui"]["text"][self getCursor()].y - 7) : (self.menu["ui"]["text"][self getCursor()].y - 8);

        self UpdateOptCount();
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
            self.menu["ui"]["QMBG"][(start + a)] = self createRectangle("CENTER", "CENTER", self.menu["ui"]["bannerQM"].x, self.menu["YQM"] + (a * 21), ShaderTextWidth(optStr), 18, (0, 0, 0), 2, 0.95, "white");
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

ScrollingSystem()
{
    menu = self getCurrent();
    text = self.menu["items"][menu].name;
    
    if(!self isInQuickMenu())
    {
        half = Int(self.menu["MaxOptions"] / 2);
        
        if(self.menu["curs"][menu] >= (half - 1) && self.menu["curs"][menu] <= ((text.size - 1) - half) || self.menu["curs"][menu] >= text.size || self.menu["curs"][menu] < 0)
        {
            if(self.menu["curs"][menu] >= text.size || self.menu["curs"][menu] < 0)
                self.menu["curs"][menu] = (self.menu["curs"][menu] >= text.size) ? 0 : (text.size - 1);
            
            self drawText();
        }
        else
        {
            if(self.menu["MenuDesign"] == "Old School" || isDefined(self.menu["LargeCursor"]))
            {
                for(a = 0; a < self.menu["ui"]["text"].size; a++)
                {
                    if(!isDefined(self.menu["ui"]["text"][a]))
                        continue;
                    
                    if(a == self.menu["curs"][menu])
                    {
                        if(self.menu["MenuDesign"] == "Old School")
                            self.menu["ui"]["text"][a].color = (isDefined(self.menu["items"][self getCurrent()].bool[a]) && isDefined(self.menu_B[self getCurrent()][a]) && self.menu_B[self getCurrent()][a] && self.menu["ToggleStyle"] == "Text Color") ? divideColor(0, 255, 0) : self.menu["Main_Color"];

                        scale = (self.menu["MenuDesign"] == "Old School") ? 1.7 : 1.3;
                        
                        if(self.menu["ui"]["text"][a].fontScale != scale && isDefined(self.menu["LargeCursor"]))
                            self.menu["ui"]["text"][a] ChangeFontscaleOverTime1(scale, (self.menu["MenuDesign"] == "Old School") ? 0.13 : 0.05);

                        continue;
                    }
                    
                    if(self.menu["MenuDesign"] == "Old School")
                        self.menu["ui"]["text"][a].color = (isDefined(self.menu["items"][self getCurrent()].bool[a]) && isDefined(self.menu_B[self getCurrent()][a]) && self.menu_B[self getCurrent()][a] && self.menu["ToggleStyle"] == "Text Color") ? divideColor(0, 255, 0) : (1, 1, 1);

                    if(self.menu["ui"]["text"][a].fontScale != 1.1)
                        self.menu["ui"]["text"][a] ChangeFontscaleOverTime1(1.1, (self.menu["MenuDesign"] == "Old School") ? 0.13 : 0.05);
                }
            }
        }
        
        scrollerY = (self.menu["MenuDesign"] == "Right Side") ? (self.menu["ui"]["text"][self.menu["curs"][menu]].y - 7) : (self.menu["ui"]["text"][self.menu["curs"][menu]].y - 8);

        if(isDefined(self.menu["ui"]["scroller"]) && self.menu["ui"]["scroller"].y != scrollerY)
            self.menu["ui"]["scroller"].y = scrollerY;
        
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

SetMenuTitle(title)
{
    if(!isDefined(self.menu["ui"]["title"]))
        return;
    
    if(!isDefined(title))
        title = self.menu["items"][self getCurrent()].title;
    
    self.menu["ui"]["title"] SetTextString(title);

    if(!self isInQuickMenu() && self.menu["MenuDesign"] == "Old School")
        self.menu["ui"]["title"].fontScale = 1.8;
    
    if(self isInQuickMenu())
    {
        width = ShaderTextWidth(title);

        self.menu["ui"]["bannerQM"] SetShaderValues(undefined, width, undefined);
        self.menu["ui"]["banner2QM"] SetShaderValues(undefined, (width - 2), undefined);
    }
}

openMenu1(menu)
{
    if(!isDefined(menu))
        menu = (isDefined(self.menu["currentMenu"]) && self.menu["currentMenu"] != "") ? self.menu["currentMenu"] : "Main";
    
    if(!isDefined(self.menu["curs"][menu]))
        self.menu["curs"][menu] = 0;
    
    if(self.menu["MenuDesign"] != "Old School")
    {
        self.menu["ui"]["background"] = self createRectangle("TOP", "CENTER", self.menu["X"], (self.menu["MenuDesign"] == "Right Side") ? (self.menu["Y"] - 300) : self.menu["Y"], self.menu["MenuWidth"], (self.menu["MenuDesign"] == "Right Side") ? 1000 : 150, (0, 0, 0), 1, 0, "white");
        
        if(self.menu["MenuDesign"] != "Right Side")
        {
            if(!isDefined(self.menu["ui"]["outlines"]))
                self.menu["ui"]["outlines"] = [];
            
            //Left Side
            self.menu["ui"]["outlines"][0] = self createRectangle("TOP", "CENTER", self.menu["X"] - (self.menu["MenuWidth"] / 2), self.menu["Y"], 1, 168, self.menu["Main_Color"], 3, 0, "white");
            
            //Right Side
            self.menu["ui"]["outlines"][1] = self createRectangle("TOP", "CENTER", (self.menu["X"] + (self.menu["MenuWidth"] / 2)), self.menu["Y"], 1, 168, self.menu["Main_Color"], 3, 0, "white");
            
            //Top
            self.menu["ui"]["outlines"][2] = self createRectangle("TOP", "CENTER", self.menu["X"], self.menu["Y"] - 13, self.menu["MenuWidth"] + 1, 14, self.menu["Main_Color"], 3, 0, "white");

            //Bottom
            self.menu["ui"]["outlines"][3] = self createRectangle("TOP", "CENTER", self.menu["X"], self.menu["Y"] + 168, self.menu["MenuWidth"], 1, self.menu["Main_Color"], 3, 0, "white");
        }
        
        self.menu["ui"]["scroller"] = self createRectangle("TOP", "CENTER", self.menu["X"], self.menu["Y"], self.menu["MenuWidth"], (self.menu["MenuDesign"] == "Right Side") ? 15 : 18, self.menu["Main_Color"], 2, 0, "white");
    }

    self.menu["ui"]["title"] = self createText("default", (self.menu["MenuDesign"] == "Right Side") ? 1.4 : 1.2, 5, "", (self.menu["MenuDesign"] == "Old School") ? "CENTER" : "LEFT", "CENTER", (self.menu["MenuDesign"] == "Old School") ? self.menu["X"] : (self.menu["X"] - (self.menu["MenuWidth"] / 2) + 4), (self.menu["MenuDesign"] == "Right Side") ? (self.menu["Y"] - 35) : (self.menu["MenuDesign"] == "Old School") ? (self.menu["Y"] - 12) : (self.menu["Y"] - 6), 0, (self.menu["MenuDesign"] == "Old School") ? self.menu["Main_Color"] : (1, 1, 1));
    
    if(!isDefined(self.menu["DisableOptionCounter"]) && self.menu["MenuDesign"] == level.menuName)
        self.menu["ui"]["optionCount"] = self createText("default", 1.2, 5, "", "RIGHT", "CENTER", (self.menu["X"] + (self.menu["MenuWidth"] / 2) - 4), (self.menu["MenuDesign"] == "Right Side") ? (self.menu["Y"] - 72) : (self.menu["Y"] - 6), 0, (1, 1, 1));

    if(self.menu["MenuDesign"] == "Right Side")
        self.menu["ui"]["MenuName"] = self createText("default", 1.9, 5, level.menuName, "LEFT", "CENTER", (self.menu["X"] - (self.menu["MenuWidth"] / 2) + 4), (self.menu["Y"] - 72), 0, (1, 1, 1));
    
    hud = ["outlines", "optionCount", "scroller", "MenuName"];

    alpha = (self.menu["MenuDesign"] != "Old School") ? 1 : 0;
    hudFadeInTime = 0;

    for(a = 0; a < hud.size; a++)
    {
        if(isDefined(self.menu["ui"][hud[a]]))
        {
            if(IsArray(self.menu["ui"][hud[a]]))
            {
                for(b = 0; b < self.menu["ui"][hud[a]].size; b++)
                    if(isDefined(self.menu["ui"][hud[a]][b]))
                        self.menu["ui"][hud[a]][b] thread hudFade(alpha, hudFadeInTime);
            }
            else
                self.menu["ui"][hud[a]] thread hudFade(alpha, hudFadeInTime);
        }
    }
    
    self.menu["ui"]["title"] thread hudFade(1, hudFadeInTime);
    
    switch(self.menu["MenuDesign"])
    {
        case "Right Side":
            alpha = 0.65;
            break;
        
        case "Old School":
            alpha = 0;
            break;
        
        default:
            alpha = 1;
            break;
    }

    if(isDefined(self.menu["ui"]["background"]))
        self.menu["ui"]["background"] thread hudFade(alpha, hudFadeInTime);
    
    self.menu["currentMenu"] = menu;
    self drawText();

    if(menu == "Players" && !isDefined(self.PlayerInfoHandler))
        self thread PlayerInfoHandler();

    if(isDefined(self.menu["MenuBlur"]))
        self SetBlur(self.menu["MenuBlurValue"], 0.1);
    
    self.menuState["isInMenu"] = true;
}

closeMenu1()
{
    if(self isInQuickMenu())
    {
        self closeQuickMenu();
        return;
    }

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

openQuickMenu()
{
    if(!isDefined(self.menu["ui"]["QMBG"]))
        self.menu["ui"]["QMBG"] = [];
    
    if(!isDefined(self.menu["ui"]["textQM"]))
        self.menu["ui"]["textQM"] = [];
    
    if(!isDefined(self.menu["ui"]["QMScroller"]))
        self.menu["ui"]["QMScroller"] = [];

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

    self drawText();
}

closeQuickMenu()
{
    if(!self isInQuickMenu())
        return;
    
    self DestroyOpts();
    destroyAll(self.menu["ui"]);
    
    self.menuState["isInQuickMenu"] = undefined;
}

SoftLockMenu(title, optCount, bgHeight)
{
    if(!self hasMenu() || self hasMenu() && !self isInMenu())
        return;
    
    self.menu["DisableMenuControls"] = true;
    self DestroyOpts();

    self.menu["SoftMenuReset"] = true;
    
    if(self.menu["MenuDesign"] == level.menuName)
    {
        if(isDefined(self.menu["ui"]["background"]))
            self.menu["ui"]["background"] SetShaderValues(undefined, undefined, bgHeight);
        
        if(isDefined(self.menu["ui"]["outlines"][0]))
            self.menu["ui"]["outlines"][0] SetShaderValues(undefined, undefined, bgHeight);
        
        if(isDefined(self.menu["ui"]["outlines"][1]))
            self.menu["ui"]["outlines"][1] SetShaderValues(undefined, undefined, bgHeight);
        
        if(isDefined(self.menu["ui"]["outlines"][3]))
            self.menu["ui"]["outlines"][3].y = (self.menu["Y"] + (bgHeight - 1));
    }
        
    if(isDefined(self.menu["ui"]["title"]))
        self.menu["ui"]["title"] SetTextString(title);
    
    if(isDefined(self.menu["ui"]["optionCount"]))
        self.menu["ui"]["optionCount"] SetTextString(optCount);
}

SoftUnlockMenu()
{
    if(!self hasMenu() || !self isInMenu())
        return;
    
    if(self.menu["MenuDesign"] == "Old School" && isDefined(self.menu["ui"]["scroller"]))
        self.menu["ui"]["scroller"] DestroyHud();
    
    self.menu["SoftMenuReset"] = undefined;

    if(isDefined(self.menu["ui"]["scroller"]))
    {
        self.menu["ui"]["scroller"] hudMoveX(self.menu["X"], 0.1);
        self.menu["ui"]["scroller"] hudScaleOverTime(0.1, self.menu["MenuWidth"], (self.menu["MenuDesign"] == "Right Side") ? 15 : 18);
        self.menu["ui"]["scroller"] hudFade(1, 0.1);
    }
    
    self.menu["DisableMenuControls"] = undefined;
    self.menu["inKeyboard"] = undefined;
    self.menu["CreditsPlaying"] = undefined;

    self RefreshMenu();
}

UpdateOptCount()
{
    if(self.menu["MenuDesign"] == "Right Side")
        return;
    
    if(self hasMenu() && isDefined(self.menu["ui"]["optionCount"]))
        self.menu["ui"]["optionCount"] SetTextString((self getCursor() + 1) + "/" + self.menu["items"][self getCurrent()].name.size);
    
    height = (((self.menu["items"][self getCurrent()].name.size >= self.menu["MaxOptions"]) ? self.menu["MaxOptions"] : self.menu["items"][self getCurrent()].name.size) * 20);
    
    if(isDefined(self.menu["ui"]["background"]))
        self.menu["ui"]["background"] SetShaderValues(undefined, undefined, (self.menu["MenuDesign"] == "Right Side") ? height : height + 9);
    
    if(isDefined(self.menu["ui"]["outlines"][0]))
        self.menu["ui"]["outlines"][0] SetShaderValues(undefined, undefined, (height + 9));
    
    if(isDefined(self.menu["ui"]["outlines"][1]))
        self.menu["ui"]["outlines"][1] SetShaderValues(undefined, undefined, (height + 9));
    
    if(isDefined(self.menu["ui"]["outlines"][3]))
        self.menu["ui"]["outlines"][3].y = (self.menu["Y"] + (height + 8));
}

DestroyOpts()
{
    hud = ["text", "BoolOpt", "BoolBack", "subMenu", "IntSlider", "StringSlider", "textQM", "QMBG"];

    for(a = 0; a < hud.size; a++)
    {
        destroyAll(self.menu["ui"][hud[a]]);
        self.menu["ui"][hud[a]] = [];
    }
}

RefreshMenu(menu, curs, force)
{
    if(isDefined(menu) && !isDefined(curs) || !isDefined(menu) && isDefined(curs))
        return;
    
    if(self hasMenu() && self isInMenu(true) && !isDefined(self.menu["DisableMenuControls"]))
    {
        if(isDefined(menu) && isDefined(curs))
        {
            foreach(player in level.players)
                if(player hasMenu() && player isInMenu(true) && (player getCurrent() == menu || player PlayerHasOption(self, menu, curs)) && !isDefined(player.menu["DisableMenuControls"]))
                    if(isDefined(player.menu["ui"]["text"][curs]) || player PlayerHasOption(self, menu, curs) || isDefined(force) && force)
                        player drawText();
        }
        else
            self drawText(); //if menu or cursor are undefined, it will only refresh the menu for the player it was called on
    }
}

PlayerHasOption(source, menu, curs)
{
    option = source.menu["items"][menu].name[curs];

    if(self.menu["items"][self getCurrent()].name.size)
    {
        for(a = 0; a < self.menu["items"][self getCurrent()].name.size; a++)
            if(option == self.menu["items"][self getCurrent()].name[a])
            {
                if(self isInQuickMenu())
                {
                    if(isDefined(self.menu["ui"]["textQM"]) && self.menu["ui"]["textQM"].size)
                        for(b = 0; b < self.menu["ui"]["textQM"].size; b++)
                            if(self.menu["ui"]["textQM"][b].text == option)
                                return true;
                }
                else
                {
                    if(isDefined(self.menu["ui"]["text"]) && self.menu["ui"]["text"].size)
                        for(b = 0; b < self.menu["ui"]["text"].size; b++)
                            if(self.menu["ui"]["text"][b].text == option)
                                return true;
                }
            }
    }

    return false;
}
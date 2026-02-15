#define OPT_NAME = 0;
#define OPT_FUNC = 1;
#define OPT_IN1 = 2;
#define OPT_IN2 = 3;
#define OPT_IN3 = 4;
#define OPT_IN4 = 5;
#define OPT_BOOL = 6;
#define OPT_BOOLOPT = 7;
#define OPT_SHADER = 8;
#define OPT_COLOR = 9;
#define OPT_PREVIEW = 10;
#define OPT_INCSLIDER = 11;
#define OPT_MIN = 12;
#define OPT_MAX = 13;
#define OPT_START = 14;
#define OPT_INCREMENT = 15;
#define OPT_SLIDER = 16;
#define OPT_SLIDERVALUES = 17;

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
                    self openMenu1();
                    wait 0.5;
                }
                else if(self AdsButtonPressed() && (self SecondaryOffhandButtonPressed() || !Is_Alive(self) && self JumpButtonPressed()) && !Is_True(self.DisableQM))
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
                    dir = (self AdsButtonPressed() || self ActionSlotOneButtonPressed()) ? -1 : 1;

                    self setCursor(curs + dir);
                    self ScrollingSystem(dir, curs);
                    wait 0.15;
                }
                else if(self UseButtonPressed())
                {
                    if(IsDefined(self.menuStructure) && IsDefined(self.menuStructure[curs]) && IsDefined(self GetOption(curs, OPT_FUNC)))
                    {
                        optSlider = self GetOption(curs, OPT_SLIDER);
                        optIncSlider = self GetOption(curs, OPT_INCSLIDER);
                        sliderValues = self GetOption(curs, OPT_SLIDERVALUES);

                        if(Is_True(optSlider) || Is_True(optIncSlider))
                        {
                            self ExeFunction(self GetOption(curs, OPT_FUNC), Is_True(optSlider) ? sliderValues[self.menuSlider[menu][curs]] : self.menuSlider[menu][curs], self GetOption(curs, OPT_IN1), self GetOption(curs, OPT_IN2), self GetOption(curs, OPT_IN3), self GetOption(curs, OPT_IN4));
                        }
                        else
                        {
                            self ExeFunction(self GetOption(curs, OPT_FUNC), self GetOption(curs, OPT_IN1), self GetOption(curs, OPT_IN2), self GetOption(curs, OPT_IN3), self GetOption(curs, OPT_IN4));
                            boolOpt = self GetOption(curs, OPT_BOOLOPT);

                            if(IsDefined(self.menuStructure) && IsDefined(self.menuStructure[curs]) && Is_True(boolOpt))
                            {
                                wait 0.18;
                                self RefreshMenu(menu, curs); //This Will Refresh That Bool Option For Every Player That Is Able To See It.
                            }
                        }

                        wait 0.2;
                    }
                }
                else if(self ActionslotThreeButtonPressed() && !self ActionSlotFourButtonPressed() || self ActionslotFourButtonPressed() && !self ActionSlotThreeButtonPressed())
                {
                    optSlider = self GetOption(curs, OPT_SLIDER);
                    optIncSlider = self GetOption(curs, OPT_INCSLIDER);
                    
                    if(IsDefined(self.menuStructure) && (Is_True(optSlider) || Is_True(optIncSlider))) 
                    {
                        dir = self ActionslotThreeButtonPressed() ? -1 : 1;

                        if(Is_True(optSlider))
                            self SetSlider(dir);
                        else
                            self SetIncSlider(dir);
                        
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
                            self closeMenu1();
                    }
                    else
                    {
                        self newMenu();
                    }

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

openMenu1(showAnim = true)
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

    self.menuUI["background"] = self createRectangle("TOP", "CENTER", self.menuX, self.menuY, 260, 300, (0, 0, 0), 2, 0.25, "white");
    self.menuUI["banner"] = self createRectangle("TOP", "CENTER", self.menuX, self.menuY, 260, 20, divideColor(25, 25, 25), 4, 1, "white");
    self.menuUI["scroller"] = self createRectangle("TOP", "CENTER", self.menuX, (self.menuY + 25), 260, 18, divideColor(25, 25, 25), 4, 1, "white");
    self.menuUI["title"] = self createText("default", 1.4, 5, "", "CENTER", "CENTER", self.menuX, (self.menuUI["background"].y + 9), 1, self.MainTheme);

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

    self.menuUI["background"] = self createRectangle("TOP", "CENTER", self.menuX, self.menuY, 260, 300, (0, 0, 0), 2, 0.25, "white");
    self.menuUI["banner"] = self createRectangle("TOP", "CENTER", self.menuX, self.menuY, 260, 20, divideColor(25, 25, 25), 4, 1, "white");
    self.menuUI["scroller"] = self createRectangle("TOP", "CENTER", self.menuX, (self.menuY + 25), 260, 18, divideColor(25, 25, 25), 4, 1, "white");
    self.menuUI["title"] = self createText("default", 1.4, 5, "", "CENTER", "CENTER", self.menuX, (self.menuUI["background"].y + 9), 1, self.MainTheme);

    self drawText();
}

closeQuickMenu()
{
    if(!self isInQuickMenu())
        return;
    
    self endon("disconnect");

    destroyAll(self.menuUI);

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
    
    if(self getCursor() >= self.menuStructure.size)
        self setCursor((self.menuStructure.size - 1));
    
    numOpts = (self.menuStructure.size > self.MaxOptions) ? self.MaxOptions : self.menuStructure.size;
    start = 0;
    
    if(self getCursor() > Int((self.MaxOptions - 1) / 2) && self getCursor() < (self.menuStructure.size - Int((self.MaxOptions + 1) / 2)) && self.menuStructure.size > self.MaxOptions)
        start = (self getCursor() - Int((self.MaxOptions - 1) / 2));
    
    if(self getCursor() > (self.menuStructure.size - (Int((self.MaxOptions + 1) / 2) + 1)) && self.menuStructure.size > self.MaxOptions)
        start = (self.menuStructure.size - self.MaxOptions);
    
    self.saved_hudcount = self.hud_count;

    if(!IsDefined(self.menuUI["text"])) self.menuUI["text"] = [];
    if(!IsDefined(self.menuUI["subMenu"])) self.menuUI["subMenu"] = [];
    if(!IsDefined(self.menuUI["BoolOpt"])) self.menuUI["BoolOpt"] = [];
    if(!IsDefined(self.menuUI["BoolBack"])) self.menuUI["BoolBack"] = [];
    if(!IsDefined(self.menuUI["IntSlider"])) self.menuUI["IntSlider"] = [];
    if(!IsDefined(self.menuUI["StringSlider"])) self.menuUI["StringSlider"] = [];

    startY = IsDefined(self.menuUI["background"]) ? (self.menuUI["background"].y + 30) : (self.menuY + 30);

    for(a = 0; a < numOpts; a++)
    {
        boolVal = self GetOption(start + a, OPT_BOOL);
        boolOpt = self GetOption(start + a, OPT_BOOLOPT);
        optName = self GetOption(start + a, OPT_NAME);
        optFunc = self GetOption(start + a, OPT_FUNC);
        optSlider = self GetOption(start + a, OPT_SLIDER);
        optIncSlider = self GetOption(start + a, OPT_INCSLIDER);
        sliderValues = self GetOption(start + a, OPT_SLIDERVALUES);

        if(Is_True(boolOpt))
        {
            self.menuUI["BoolBack"][start + a] = self createRectangle("CENTER", "CENTER", (self.menuX + 122), startY + (a * 20), 8, 8, (0.25, 0.25, 0.25), 5, 1, "white");
            self.menuUI["BoolOpt"][start + a] = self createRectangle("CENTER", "CENTER", (self.menuX + 122), startY + (a * 20), 6, 6, Is_True(boolVal) ? self.MainTheme : (0, 0, 0), 6, 1, "white");
        }

        if(IsDefined(optFunc) && optFunc == ::newMenu)
            self.menuUI["subMenu"][start + a] = self createText("default", ((start + a) == self getCursor()) ? 1.2 : 1, 5, ">", "RIGHT", "CENTER", (self.menuX + 126), startY + (a * 20), 1, ((start + a) == self getCursor()) ? self.MainTheme : (1, 1, 1));

        if(Is_True(optIncSlider))
            self.menuUI["IntSlider"][start + a] = self createText("default", ((start + a) == self getCursor()) ? 1.2 : 1, 5, self.menuSlider[self getCurrent()][start + a], "RIGHT", "CENTER", (self.menuX + 126), startY + (a * 20), 1, ((start + a) == self getCursor()) ? self.MainTheme : (1, 1, 1));
        
        if(Is_True(optSlider))
            self.menuUI["StringSlider"][start + a] = self createText("default", ((start + a) == self getCursor()) ? 1.2 : 1, 5, "< " + sliderValues[self.menuSlider[self getCurrent()][start + a]] + " > [" + (self.menuSlider[self getCurrent()][start + a] + 1) + "/" + sliderValues.size + "]", "RIGHT", "CENTER", (self.menuX + 126), startY + (a * 20), 1, ((start + a) == self getCursor()) ? self.MainTheme : (1, 1, 1));

        self.menuUI["text"][start + a] = self createText("default", ((start + a) == self getCursor()) ? 1.2 : 1, 5, optName, "LEFT", "CENTER", (self.menuX - 126), startY + (a * 20), 1, ((start + a) == self getCursor()) ? self.MainTheme : (1, 1, 1));
    }

    if(!IsDefined(self.menuUI["text"][self getCursor()]))
        self.menuCursor[self getCurrent()] = (self.menuStructure.size - 1);
    
    if(IsDefined(self.menuUI["scroller"]) && IsDefined(self.menuUI["text"][self getCursor()]))
    {
        if(Is_True(showAnim))
            self.menuUI["scroller"] thread hudMoveY((self.menuUI["text"][self getCursor()].y - 8), 0.15);
        else
            self.menuUI["scroller"].y = (self.menuUI["text"][self getCursor()].y - 8);
    }

    if(IsDefined(self.menuUI) && IsDefined(self.menuUI["background"]) && IsDefined(self.menuUI["text"]) && self.menuUI["text"].size)
        self.menuUI["background"] SetShaderValues(undefined, undefined, 40 + (20 * (self.menuUI["text"].size - 1)));
}

ScrollingSystem(dir, OldCurs)
{
    self endon("menuClosed");
    self endon("disconnect");

    curs = self getCursor();
    
    add = Int((self.MaxOptions + 1) / 2);
    sub = Int((self.MaxOptions - 1) / 2);
    hud = Array("text", "BoolOpt", "BoolBack", "subMenu", "IntSlider", "StringSlider");
    
    if(curs < 0 || curs > (self.menuStructure.size - 1))
    {
        self setCursor((curs < 0) ? (self.menuStructure.size - 1) : 0);
        
        curs = getCursor();
        OldCurs = curs;

        if(self.menuStructure.size > self.MaxOptions)
        {
            self RefreshMenu();
            return;
        }
    }
    else if(curs < (self.menuStructure.size - add) && (OldCurs > sub) || (curs > sub) && OldCurs < (self.menuStructure.size - add))
    {
        boolVal = self GetOption(curs + (sub * dir), OPT_BOOL);
        boolOpt = self GetOption(curs + (sub * dir), OPT_BOOLOPT);
        optName = self GetOption(curs + (sub * dir), OPT_NAME);
        optFunc = self GetOption(curs + (sub * dir), OPT_FUNC);
        optSlider = self GetOption(curs + (sub * dir), OPT_SLIDER);
        optIncSlider = self GetOption(curs + (sub * dir), OPT_INCSLIDER);
        sliderValues = self GetOption(curs + (sub * dir), OPT_SLIDERVALUES);

        offset = 0;

        for(a = 0; a < hud.size; a++)
        {
            if(IsDefined(self.menuUI[hud[a]][(curs + ((add * -1) * dir))]))
            {
                self.menuUI[hud[a]][(curs + ((add * -1) * dir))] thread hudFadeDestroy(0, 0.13);
                offset++;
            }
        }

        self.hud_count = (self.saved_hudcount + offset);

        for(a = 0; a < self.menuStructure.size; a++)
        {
            for(b = 0; b < hud.size; b++)
            {
                if(IsDefined(self.menuUI[hud[b]][a]) && a != (curs + ((add * -1) * dir)))
                {
                    self.menuUI[hud[b]][a].archived = self ShouldArchive();
                    self.hud_count++;

                    self.menuUI[hud[b]][a] thread hudMoveY((self.menuUI[hud[b]][a].y - (20 * dir)), 0.13);
                }
            }
        }
        
        if(Is_True(boolOpt))
        {
            self.menuUI["BoolBack"][curs + (sub * dir)] = self createRectangle("CENTER", "CENTER", (self.menuX + 122), self.menuUI["text"][curs].y + (((self.MaxOptions * 10) - 10) * dir), 8, 8, (0.25, 0.25, 0.25), 5, 0, "white");
            self.menuUI["BoolOpt"][curs + (sub * dir)] = self createRectangle("CENTER", "CENTER", (self.menuX + 122), self.menuUI["text"][curs].y + (((self.MaxOptions * 10) - 10) * dir), 6, 6, Is_True(boolVal) ? self.MainTheme : (0, 0, 0), 6, 0, "white");
        }

        if(IsDefined(optFunc) && optFunc == ::newMenu)
            self.menuUI["subMenu"][curs + (sub * dir)] = self createText("default", 1, 5, ">", "RIGHT", "CENTER", (self.menuX + 126), self.menuUI["text"][curs].y + (((self.MaxOptions * 10) - 10) * dir), 0, ((curs + (sub * dir)) == self getCursor()) ? self.MainTheme : (1, 1, 1));

        if(Is_True(optIncSlider))
            self.menuUI["IntSlider"][curs + (sub * dir)] = self createText("default", 1, 5, self.menuSlider[self getCurrent()][curs + (sub * dir)], "RIGHT", "CENTER", (self.menuX + 126), self.menuUI["text"][curs].y + (((self.MaxOptions * 10) - 10) * dir), 0, ((curs + (sub * dir)) == self getCursor()) ? self.MainTheme : (1, 1, 1));
        
        if(Is_True(optSlider))
            self.menuUI["StringSlider"][curs + (sub * dir)] = self createText("default", 1, 5, "< " + sliderValues[self.menuSlider[self getCurrent()][curs + (sub * dir)]] + " > [" + (self.menuSlider[self getCurrent()][curs + (sub * dir)] + 1) + "/" + sliderValues.size + "]", "RIGHT", "CENTER", (self.menuX + 126), self.menuUI["text"][curs].y + (((self.MaxOptions * 10) - 10) * dir), 0, ((curs + (sub * dir)) == self getCursor()) ? self.MainTheme : (1, 1, 1));

        self.menuUI["text"][curs + (sub * dir)] = self createText("default", 1, 5, optName, "LEFT", "CENTER", (self.menuX - 126), self.menuUI["text"][curs].y + (((self.MaxOptions * 10) - 10) * dir), 0, ((curs + (sub * dir)) == self getCursor()) ? self.MainTheme : (1, 1, 1));
        
        for(a = 0; a < hud.size; a++)
        {
            if(IsDefined(self.menuUI[hud[a]][(curs + (sub * dir))]))
                self.menuUI[hud[a]][(curs + (sub * dir))] thread hudFade(1, 0.13);
        }
    }

    for(a = 0; a < self.menuStructure.size; a++)
    {
        for(b = 0; b < hud.size; b++)
        {
            if(IsDefined(self.menuUI[hud[b]][a]) && hud[b] != "BoolOpt" && hud[b] != "BoolBack")
            {
                self.menuUI[hud[b]][a] hudFadeColor((curs == a) ? self.MainTheme : (1, 1, 1), 0.13);
                self.menuUI[hud[b]][a] ChangeFontscaleOverTime1((curs == a) ? 1.2 : 1, 0.13);
            }
        }
    }
    
    if(IsDefined(self.menuUI["scroller"]))
        self.menuUI["scroller"] thread hudMoveY(self.menuUI["text"][curs].y - 8, 0.13);
    
    if(IsDefined(self.menuStructure[curs]) && IsInvalidOption(self GetOption(curs, OPT_NAME)))
    {
        self setCursor(curs + dir);
        return self ScrollingSystem(dir, curs);
    }
}

CreateOptionPreview()
{
    cursor = self getCursor();
    optPreview = self GetOption(cursor, OPT_PREVIEW);

    if(Is_True(optPreview))
    {
        if(IsDefined(self.optionPreview))
            self.optionPreview DestroyHud();
        
        optShader = self GetOption(cursor, OPT_SHADER);
        optColor = self GetOption(cursor, OPT_COLOR);
        
        previewWidth = 100;
        self.optionPreview = self createRectangle("TOP_LEFT", "CENTER", (self.menuX > 97) ? ((self.menuX - 135) - previewWidth) : ((self.menuX + (self.menuUI["background"].width / 2)) + 15), self.menuUI["scroller"].y, previewWidth, 15, (IsString(optColor) && optColor == "Rainbow") ? level.RGBFadeColor : optColor, 2, 1, optShader);
        
        if(IsString(optColor) && optColor == "Rainbow")
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

    if(IsDefined(self.menuUI["background"]))
        self.menuUI["background"] SetShaderValues(undefined, 260, bgHeight);
}

SoftUnlockMenu()
{
    if(!self hasMenu() || !self isInMenu())
        return;
    
    self endon("disconnect");

    self.menuUI["scroller"] hudMoveX(self.menuX, 0.1);
    self.menuUI["scroller"] hudScaleOverTime(0.1, 260, 18);
    self.menuUI["scroller"] hudFade(1, 0.05);
    
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
                    player drawText();
            }
        }
    }
    else
    {
        if(IsDefined(self) && self hasMenu() && self isInMenu(true) && !Is_True(self.DisableMenuControls))
            self drawText(); //if menu or cursor are undefined, it will only refresh the menu for the player it was called on
    }
}

PlayerHasOption(source, menu, curs)
{
    option = source GetOption(curs, OPT_NAME);

    if(IsDefined(self.menuStructure) && self.menuStructure.size && IsDefined(option))
    {
        for(a = 0; a < self.menuStructure.size; a++)
        {
            if(option == self GetOption(a, OPT_NAME) && (source.SelectedPlayer == self || self.SelectedPlayer == self && source.SelectedPlayer == source && self getCurrent() == menu))
                return true;
        }
    }

    return false;
}

DestroyOpts()
{
    self endon("disconnect");
    
    if(!IsDefined(level.menuHudKeys))
        level.menuHudKeys = Array("text", "BoolOpt", "BoolBack", "subMenu", "IntSlider", "StringSlider");
    
    hud = level.menuHudKeys;
    
    if(IsDefined(self.menuUI) && self.menuUI.size)
    {
        for(a = 0; a < hud.size; a++)
        {
            if(IsDefined(self.menuUI[hud[a]]) && self.menuUI[hud[a]].size)
            {
                destroyAll(self.menuUI[hud[a]]);
                self.menuUI[hud[a]] = undefined;
            }
        }
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
    return Is_True(self.isInMenu) || Is_True(iqm) && Is_True(self.isInQuickMenu);
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

    if(!IsDefined(self.menuSlider))
        self.menuSlider = [];
    
    if(!IsDefined(self.menuSlider[menu]))
        self.menuSlider[menu] = [];
    
    if(!IsDefined(self.menuSlider[menu][curs]))
        self.menuSlider[menu][curs] = 0;

    sliderValues = self GetOption(curs, OPT_SLIDERVALUES);
    max  = (sliderValues.size - 1);

    self.menuSlider[menu][curs] += (!IsDefined(dir) || !IsInt(dir) || dir > 0) ? 1 : -1;
    
    if((self.menuSlider[menu][curs] > max) || (self.menuSlider[menu][curs] < 0))
        self.menuSlider[menu][curs] = (self.menuSlider[menu][curs] > max) ? 0 : max;
    
    if(IsDefined(self.menuUI) && IsDefined(self.menuUI["StringSlider"]) && IsDefined(self.menuUI["StringSlider"][curs]))
        self.menuUI["StringSlider"][curs] SetTextString("< " + sliderValues[self.menuSlider[menu][curs]] + " > [" + (self.menuSlider[menu][curs] + 1) + "/" + sliderValues.size + "]");
    else
        self drawText(); //Needed To Resize Background & Refresh Sliders
}

SetIncSlider(dir)
{
    menu = self getCurrent();
    curs = self getCursor();

    if(!IsDefined(self.menuSlider))
        self.menuSlider = [];
    
    if(!IsDefined(self.menuSlider[menu]))
        self.menuSlider[menu] = [];
    
    if(!IsDefined(self.menuSlider[menu][curs]))
        self.menuSlider[menu][curs] = 0;
    
    val = self GetOption(curs, OPT_INCREMENT);
    max = self GetOption(curs, OPT_MAX);
    min = self GetOption(curs, OPT_MIN);
    
    if(self.menuSlider[menu][curs] < max && (self.menuSlider[menu][curs] + val) > max || (self.menuSlider[menu][curs] > min) && (self.menuSlider[menu][curs] - val) < min)
        self.menuSlider[menu][curs] = (self.menuSlider[menu][curs] < max && (self.menuSlider[menu][curs] + val) > max) ? max : min;
    else
        self.menuSlider[menu][curs] += (!IsDefined(dir) || !IsInt(dir) || dir > 0) ? val : (val * -1);
    
    if((self.menuSlider[menu][curs] > max) || (self.menuSlider[menu][curs] < min))
        self.menuSlider[menu][curs] = (self.menuSlider[menu][curs] > max) ? min : max;
    
    if(IsDefined(self.menuUI) && IsDefined(self.menuUI["IntSlider"]) && IsDefined(self.menuUI["IntSlider"][curs]))
        self.menuUI["IntSlider"][curs] SetValue(self.menuSlider[menu][curs]);
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
    {
        self.SelectedPlayer = self;
    }
    else if(self isInMenu(false) && isInArray(self.menu_parent, "Players"))
    {
        self.SelectedPlayer = self.SavedSelectedPlayer;
    }
    
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
        optIncSlider = self GetOption(a, OPT_INCSLIDER);

        if(!IsDefined(self.menuStructure[a]) || !Is_True(optIncSlider) || !IsDefined(self.menuSlider) || !IsDefined(self.menuSlider[menu]))
            continue;
        
        optStart = self GetOption(a, OPT_START);

        if(IsDefined(self.menuSlider[menu][a]) && IsDefined(optStart) && self.menuSlider[menu][a] == optStart)
            self.menuSlider[menu][a] = undefined;
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
    
    self drawText();
}

WatchMenuWeaponSwitch(menu, player)
{
    self endon("disconnect");
    player endon("disconnect");
    player endon("menuClosed");
    player endon("EndSwitchWeaponMonitor");

    while(player getCurrent() == menu)
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





//option structures
addMenu(title)
{
    self.menuStructure = [];

    if(IsDefined(title))
        self.menuTitle = title;
}

addOpt(name, fnc = ::EmptyFunction, input1, input2, input3, input4)
{
    if(!IsDefined(self.menuStructure))
        self.menuStructure = [];

    option = [];
    
    option[OPT_NAME] = name;
    option[OPT_FUNC] = fnc;

    if(IsDefined(input1)) option[OPT_IN1] = input1;
    if(IsDefined(input2)) option[OPT_IN2] = input2;
    if(IsDefined(input3)) option[OPT_IN3] = input3;
    if(IsDefined(input4)) option[OPT_IN4] = input4;
    
    self.menuStructure[self.menuStructure.size] = option;
}

addOptPreview(shader = "white", color = (0, 0, 0), name, fnc = ::EmptyFunction, input1, input2, input3, input4)
{
    if(!IsDefined(self.menuStructure))
        self.menuStructure = [];
    
    option = [];
    
    option[OPT_NAME] = name;
    option[OPT_FUNC] = fnc;
    option[OPT_SHADER] = shader;
    option[OPT_COLOR] = color;

    if(IsDefined(input1)) option[OPT_IN1] = input1;
    if(IsDefined(input2)) option[OPT_IN2] = input2;
    if(IsDefined(input3)) option[OPT_IN3] = input3;
    if(IsDefined(input4)) option[OPT_IN4] = input4;

    option[OPT_PREVIEW] = true;

    self.menuStructure[self.menuStructure.size] = option;
}

addOptBool(boolVar, name, fnc = ::EmptyFunction, input1, input2, input3, input4)
{
    if(!IsDefined(self.menuStructure))
        self.menuStructure = [];
    
    option = [];
    
    option[OPT_NAME] = name;
    option[OPT_FUNC] = fnc;

    if(IsDefined(input1)) option[OPT_IN1] = input1;
    if(IsDefined(input2)) option[OPT_IN2] = input2;
    if(IsDefined(input3)) option[OPT_IN3] = input3;
    if(IsDefined(input4)) option[OPT_IN4] = input4;

    option[OPT_BOOL] = Is_True(boolVar);
    option[OPT_BOOLOPT] = true;
    
    self.menuStructure[self.menuStructure.size] = option;
}

addOptBoolPreview(boolVar, shader = "white", color = (0, 0, 0), name, fnc = ::EmptyFunction, input1, input2, input3, input4)
{
    if(!IsDefined(self.menuStructure))
        self.menuStructure = [];
    
    option = [];
    
    option[OPT_NAME] = name;
    option[OPT_FUNC] = fnc;
    option[OPT_SHADER] = shader;
    option[OPT_COLOR] = color;
    
    if(IsDefined(input1)) option[OPT_IN1] = input1;
    if(IsDefined(input2)) option[OPT_IN2] = input2;
    if(IsDefined(input3)) option[OPT_IN3] = input3;
    if(IsDefined(input4)) option[OPT_IN4] = input4;

    option[OPT_BOOL] = Is_True(boolVar);
    option[OPT_BOOLOPT] = true;
    option[OPT_PREVIEW] = true;

    self.menuStructure[self.menuStructure.size] = option;
}

addOptIncSlider(name, fnc = ::EmptyFunction, min = 0, start = 0, max = 1, increment = 1, input1, input2, input3, input4)
{
    if(!IsDefined(self.menuStructure))
        self.menuStructure = [];
    
    if(!IsDefined(self.menuSlider))
        self.menuSlider = [];
    
    option = [];
    index = self.menuStructure.size;
    menu = self isInQuickMenu() ? self.currentMenuQM : self.currentMenu;

    if(!IsDefined(self.menuSlider[menu]))
        self.menuSlider[menu] = [];
    
    option[OPT_NAME] = name;
    option[OPT_FUNC] = fnc;
    
    if(IsDefined(input1)) option[OPT_IN1] = input1;
    if(IsDefined(input2)) option[OPT_IN2] = input2;
    if(IsDefined(input3)) option[OPT_IN3] = input3;
    if(IsDefined(input4)) option[OPT_IN4] = input4;

    option[OPT_INCSLIDER] = true;
    option[OPT_MIN] = min;
    option[OPT_MAX] = (max < min) ? min : max;

    option[OPT_START] = (start > max || start < min) ? (start > max) ? max : min : start;
    option[OPT_INCREMENT] = increment;
    
    if(!IsDefined(self.menuSlider[menu][index]))
    {
        self.menuSlider[menu][index] = option[OPT_START];
    }
    else
    {
        if(self.menuSlider[menu][index] > max || self.menuSlider[menu][index] < min)
            self.menuSlider[menu][index] = self.menuSlider[menu][index] < min ? min : max;
    }
    
    self.menuStructure[self.menuStructure.size] = option;
}

addOptSlider(name, fnc = ::EmptyFunction, values, input1, input2, input3, input4)
{
    if(!IsDefined(self.menuStructure))
        self.menuStructure = [];
    
    if(!IsDefined(self.menuSlider))
        self.menuSlider = [];
    
    option = [];
    index = self.menuStructure.size;
    menu = self isInQuickMenu() ? self.currentMenuQM : self.currentMenu;

    if(!IsDefined(self.menuSlider[menu]))
        self.menuSlider[menu] = [];

    option[OPT_NAME] = name;
    option[OPT_FUNC] = fnc;
    
    if(IsDefined(input1)) option[OPT_IN1] = input1;
    if(IsDefined(input2)) option[OPT_IN2] = input2;
    if(IsDefined(input3)) option[OPT_IN3] = input3;
    if(IsDefined(input4)) option[OPT_IN4] = input4;

    if(!IsArray(values))
        values = Array("Invalid array values passed");

    option[OPT_SLIDER] = true;
    option[OPT_SLIDERVALUES] = values;
    
    if(!IsDefined(self.menuSlider[menu][index]))
        self.menuSlider[menu][index] = 0;
    
    self.menuStructure[self.menuStructure.size] = option;
}

EmptyFunction(){}

GetOption(index, data)
{
    if(!IsDefined(self.menuStructure) || !IsDefined(self.menuStructure[index]))
        return;
    
    value = self.menuStructure[index][data];

    if(!IsDefined(value))
        return;

    return value;
}
PopulateMenuCustomization(menu)
{
    switch(menu)
    {
        case "Menu Customization":
            self addMenu(menu);
                self addOpt("Menu Credits", ::MenuCredits);
                self addOpt("Open Controls", ::newMenu, "Open Controls");
                self addOpt("Width Editor", ::MenuWidthEditor);
                self addOpt("Reposition Menu", ::RepositionMenu);
                self addOpt("Menu Instructions", ::newMenu, "Menu Instructions");
                self addOpt("Main Design Color", ::newMenu, "Main Design Color");
                self addOpt("Menu Preferences", ::newMenu, "Menu Preferences");
            break;
        
        case "Open Controls":
            if(!IsDefined(self.OpenControlIndex))
                self.OpenControlIndex = 1;
            
            if(!IsDefined(self.OpenControlType))
                self.OpenControlType = GetMenuName();
            
            buttons = Array("+actionslot 1", "+actionslot 2", "+actionslot 3", "+actionslot 4", "+melee", "+speed_throw", "+attack", "+breath_sprint", "+activate", "+frag", "+smoke", "+stance");
            type = (self.OpenControlType == GetMenuName()) ? self.OpenControls : self.QuickControls;

            self addMenu(menu);
                self addOptSlider("Menu", ::OpenControlType, Array(GetMenuName(), "Quick Menu"));
                self addOptIncSlider("Bind Slot", ::OpenControlIndex, 1, 1, 3, 1); //If you want to allow more buttons to be chosen, change the '3' to whatever number you want.
                self addOpt("");

                if(self.OpenControlIndex != 1)
                    self addOptBool(!IsDefined(type[(self.OpenControlIndex - 1)]), "None", ::SetOpenButtons, self.OpenControlType, "None");

                foreach(button in buttons)
                    self addOptBool((IsDefined(type[(self.OpenControlIndex - 1)]) && type[(self.OpenControlIndex - 1)] == button), "[{" + button + "}]", ::SetOpenButtons, self.OpenControlType, button);
            break;
        
        case "Menu Instructions":
            self addMenu(menu);
                self addOptBool(self.DisableMenuInstructions, "Disable", ::DisableMenuInstructions);
                self addOptBool(self.AdaptiveMenuInstructions, "Adaptive Position", ::AdaptiveMenuInstructions);
                self addOpt("Reposition", ::RepositionMenuInstructions);
                self addOpt("Reset Position", ::ResetMenuInstructions);
            break;
        
        case "Main Design Color":
            self addMenu(menu);
                
                for(a = 0; a < GetColorNames().size; a++)
                    self addOptBool((!Is_True(self.SmoothRainbowTheme) && self.MainTheme == GetColorValues()[a]), GetColorNames()[a], ::MenuTheme, GetColorValues()[a]);
                
                self addOptBool(self.SmoothRainbowTheme, "Smooth Rainbow", ::SmoothRainbowTheme);
            break;
        
        case "Menu Preferences":
            self addMenu(menu);
                self addOptSlider("Design", ::MenuDesign, Array(GetMenuName(), "Classic", "Native", "AIO", "Physics 'n' Flex"));
                self addOptSlider("Bool Display", ::BoolDisplay, Array("Boxes", "Text", "Text Color"));
                self addOptSlider("Bool Box Location", ::BoolLocation, Array("Right", "Left"));
                self addOptIncSlider("Scroll Animation Time (ms)", ::ScrollAnimationTime, 10, Int(self.ScrollAnimationTime * 100), 25, 1);
                self addOptBool(self.QuickExit, "Quick Exit [ Hold [{+melee}] ]", ::QuickExit);
                self addOptBool(self.DisableQM, "Disable Quick Menu", ::DisableQuickMenu);
                self addOptBool(self.SpotlightCursor, "Spotlight Cursor", ::SpotlightCursor);
                self addOptBool(self.ColoredCursor, "Colored Cursor", ::ColoredCursor);
                self addOptBool(self.LargeCursor, "Large Cursor", ::LargeCursor);
                self addOptBool(self.OptionCounter, "Option Counter", ::OptionCounter);
                self addOptBool(self.StealthUI, "Stealth UI", ::StealthUI);
            break;
    }
}

MenuTheme(color)
{
    self notify("EndSmoothRainbowTheme");

    if(Is_True(self.SmoothRainbowTheme))
        self.SmoothRainbowTheme = BoolVar(self.SmoothRainbowTheme);
    
    hud = Array("text", "BoolText", "subMenu", "IntSlider", "StringSlider");
    
    if(IsDefined(self.menuUI))
    {
        if(IsDefined(self.menuStructure) && self.menuStructure.size)
        {
            for(a = 0; a < self.menuStructure.size; a++)
            {
                boolVal = self GetOption(a, 6);
                boolOpt = self GetOption(a, OPT_BOOLOPT);
                selectedColor = !Is_True(self.ColoredCursor) ? (1, 1, 1) : color;

                if(IsDefined(self.menuUI["BoolOpt"]) && IsDefined(self.menuUI["BoolOpt"][a]) && Is_True(boolOpt) && Is_True(boolVal))
                    self.menuUI["BoolOpt"][a] hudFadeColor(color, 0.5);
                
                if(IsDefined(self.menuUI["invalidOption"]) && IsDefined(self.menuUI["invalidOption"][a]))
                    self.menuUI["invalidOption"][a] hudFadeColor(color, 0.5);
                
                for(b = 0; b < hud.size; b++)
                {
                    if(IsDefined(self.menuUI[hud[b]][a]))
                        self.menuUI[hud[b]][a] hudFadeColor((self.BoolDisplay == "Text Color" && Is_True(boolOpt) && Is_True(boolVal)) ? (0, 1, 0) : (a == self getCursor()) ? selectedColor : (1, 1, 1), 1);
                }
            }
        }

        if(IsDefined(self.menuUI["scroller"]) && self.MenuDesign != GetMenuName())
            self.menuUI["scroller"] hudFadeColor(color, 0.5);

        if(self.MenuDesign == "Native" || self.MenuDesign == "Classic" || self.MenuDesign == "Physics 'n' Flex")
        {
            if(IsDefined(self.menuUI["banner"]))
                self.menuUI["banner"] hudFadeColor(color, 0.5);
        }
        else
        {
            if(IsDefined(self.menuUI["title"]) && self.MenuDesign != "AIO")
                self.menuUI["title"] hudFadeColor(color, 0.5);
            
            if(IsDefined(self.menuUI["separator"]))
                self.menuUI["separator"] hudFadeColor(color, 0.5);
            
            if(IsDefined(self.menuUI["bottomLine"]))
                self.menuUI["bottomLine"] hudFadeColor(color, 0.5);
        }
    }

    if(IsDefined(self.menuInstructionsUI) && IsDefined(self.menuInstructionsUI["outline"]))
        self.menuInstructionsUI["outline"] hudFadeColor(color, 0.5);
    
    if(IsDefined(self.playerInfoHud) && IsDefined(self.playerInfoHud["outline"]))
        self.playerInfoHud["outline"] hudFadeColor(color, 0.5);
    
    if(Is_True(self.ZombieCounter) && IsDefined(self.ZombieCounterHud) && IsDefined(self.ZombieCounterHud[0]))
    {
        col = GetColorVec(color);
        self SetLUIMenuData(self.ZombieCounterHud[0], "red", col[0]);
        self SetLUIMenuData(self.ZombieCounterHud[0], "green", col[1]);
        self SetLUIMenuData(self.ZombieCounterHud[0], "blue", col[2]);
    }

    if(Is_True(self.CustomCrosshairs) && IsDefined(self.CustomCrosshairsUI))
    {
        col = GetColorVec(color);
        self SetLUIMenuData(self.CustomCrosshairsUI, "red", col[0]);
        self SetLUIMenuData(self.CustomCrosshairsUI, "green", col[1]);
        self SetLUIMenuData(self.CustomCrosshairsUI, "blue", col[2]);
    }
    
    self.MainTheme = color;
    self SaveMenuTheme();
}

SmoothRainbowTheme()
{
    if(Is_True(self.SmoothRainbowTheme))
        return;
    self.SmoothRainbowTheme = true;
    
    self SaveMenuTheme();
    
    self endon("disconnect");
    self endon("EndSmoothRainbowTheme");

    hud = Array("text", "BoolText", "subMenu", "IntSlider", "StringSlider");
    
    while(Is_True(self.SmoothRainbowTheme))
    {
        color = level.RGBFadeColor;

        if(IsDefined(self.menuUI))
        {
            if(IsDefined(self.menuStructure) && self.menuStructure.size)
            {
                for(a = 0; a < self.menuStructure.size; a++)
                {
                    boolVal = self GetOption(a, 6);
                    boolOpt = self GetOption(a, OPT_BOOLOPT);
                    selectedColor = !Is_True(self.ColoredCursor) ? (1, 1, 1) : color;

                    if(IsDefined(self.menuUI["BoolOpt"]) && IsDefined(self.menuUI["BoolOpt"][a]) && Is_True(boolOpt) && Is_True(boolVal))
                        self.menuUI["BoolOpt"][a].color = color;
                    
                    if(IsDefined(self.menuUI["invalidOption"]) && IsDefined(self.menuUI["invalidOption"][a]))
                        self.menuUI["invalidOption"][a].color = color;
                    
                    for(b = 0; b < hud.size; b++)
                    {
                        if(IsDefined(self.menuUI[hud[b]][a]))
                            self.menuUI[hud[b]][a].color = (self.BoolDisplay == "Text Color" && Is_True(boolOpt) && Is_True(boolVal)) ? (0, 1, 0) : (a == self getCursor()) ? selectedColor : (1, 1, 1);
                    }
                }
            }

            if(IsDefined(self.menuUI["scroller"]) && (self.MenuDesign != GetMenuName() || IsDefined(self.menuUI["kbString"])))
                self.menuUI["scroller"].color = color;

            if(self.MenuDesign == "Native" || self.MenuDesign == "Classic" || self.MenuDesign == "Physics 'n' Flex")
            {
                if(IsDefined(self.menuUI["banner"]))
                    self.menuUI["banner"].color = color;
            }
            else
            {
                if(IsDefined(self.menuUI["title"]) && self.MenuDesign != "AIO")
                    self.menuUI["title"].color = color;

                if(IsDefined(self.menuUI["separator"]))
                    self.menuUI["separator"].color = color;
                
                if(IsDefined(self.menuUI["bottomLine"]))
                    self.menuUI["bottomLine"].color = color;
            }
        }

        if(IsDefined(self.menuInstructionsUI) && IsDefined(self.menuInstructionsUI["outline"]))
            self.menuInstructionsUI["outline"].color = color;
        
        if(IsDefined(self.playerInfoHud) && IsDefined(self.playerInfoHud["outline"]))
            self.playerInfoHud["outline"].color = color;
        
        if(Is_True(self.ZombieCounter) && IsDefined(self.ZombieCounterHud) && IsDefined(self.ZombieCounterHud[0]))
        {
            self SetLUIMenuData(self.ZombieCounterHud[0], "red", color[0]);
            self SetLUIMenuData(self.ZombieCounterHud[0], "green", color[1]);
            self SetLUIMenuData(self.ZombieCounterHud[0], "blue", color[2]);
        }

        if(Is_True(self.CustomCrosshairs) && IsDefined(self.CustomCrosshairsUI))
        {
            self SetLUIMenuData(self.CustomCrosshairsUI, "red", color[0]);
            self SetLUIMenuData(self.CustomCrosshairsUI, "green", color[1]);
            self SetLUIMenuData(self.CustomCrosshairsUI, "blue", color[2]);
        }
        
        self.MainTheme = color;
        wait 0.01;
    }
}

RepositionMenu()
{
    self endon("disconnect");
    
    adjX = self.menuX;
    adjY = self.menuY;
    
    self SoftLockMenu(120, true);
    
    self.menuUI["reposition"] = self createText("default", 1, 5, "[{+melee}] - Exit\n[{+activate}] - Save Position\n[{+actionslot 1}] - Move Up\n[{+actionslot 2}] - Move Down\n[{+actionslot 3}] - Move Left\n[{+actionslot 4}] - Move Right", "LEFT", "CENTER", self.menuX + 4, (self.menuUI["background"].y + 28), 1, (1, 1, 1));
    
    while(self isInMenu(true))
    {
        if(self ActionSlotOneButtonPressed() || self ActionSlotTwoButtonPressed())
        {
            incValue = self ActionSlotTwoButtonPressed() ? 8 : -8;
            
            foreach(key in GetArrayKeys(self.menuUI))
            {
                if(!IsDefined(self.menuUI[key]))
                    continue;
                
                if(IsArray(self.menuUI[key]))
                {
                    for(a = 0; a < self.menuUI[key].size; a++)
                    {
                        if(IsDefined(self.menuUI[key][a]))
                            self.menuUI[key][a].y += incValue;
                    }
                }
                else
                {
                    self.menuUI[key].y += incValue;
                }
            }
            
            adjY += incValue;
        }
        else if(self ActionSlotThreeButtonPressed() || self ActionSlotFourButtonPressed())
        {
            incValue = self ActionSlotFourButtonPressed() ? 8 : -8;
            
            foreach(key in GetArrayKeys(self.menuUI))
            {
                if(!IsDefined(self.menuUI[key]))
                    continue;
                
                if(IsArray(self.menuUI[key]))
                {
                    for(a = 0; a < self.menuUI[key].size; a++)
                    {
                        if(IsDefined(self.menuUI[key][a]))
                            self.menuUI[key][a].x += incValue;
                    }
                }
                else
                {
                    self.menuUI[key].x += incValue;
                }
            }
            
            adjX += incValue;
        }
        else if(self UseButtonPressed())
        {
            self.menuX = adjX;
            self.menuY = adjY;
        }
        else if(self MeleeButtonPressed())
        {
            break;
        }
        
        wait 0.025;
    }
    
    self SoftUnlockMenu();
    self SaveMenuTheme();
}

MenuWidthEditor()
{
    self endon("disconnect");
    
    self SoftLockMenu(120, true);

    txtHud = Array("title", "menuName");

    for(a = 0; a < txtHud.size; a++)
    {
        if(IsDefined(self.menuUI[txtHud[a]]))
            self.menuUI[txtHud[a]] DestroyHud();
    }
    
    self.menuUI["editwidth"] = self createText("default", 1, 5, "[{+melee}] - Exit\n[{+activate}] - Save Width\n[{+attack}] - Increase Width\n[{+speed_throw}] - Decrease Width\n[{+actionslot 4}] - Increase Offset Value\n[{+actionslot 3}] - Decrease Offset Value", "LEFT", "CENTER", self.menuX + 4, (self.menuUI["background"].y + 25), 1, (1, 1, 1));

    offsetY = (self.menuUI["editwidth"].y + CorrectNL_BGHeight(self.menuUI["editwidth"].text));
    self.menuUI["offset"] = self createText("default", 1, 5, "Offset Value: ", "LEFT", "CENTER", self.menuX + 4, offsetY, 1, (1, 1, 1));

    hud = Array("background", "banner", "separator", "bottomLine", "backgroundouter");
    width = self.MenuWidth;
    offset = 1;

    self.menuUI["offsetValue"] = self createText("default", 1, 5, offset, "LEFT", "CENTER", self.menuUI["offset"].x + (self.menuUI["editwidth"] GetTextWidth3arc(self, 2) - 4), offsetY, 1, (0, 1, 0));

    min = 200;
    max = 500;
    
    while(self isInMenu(true))
    {
        if(self AttackButtonPressed())
        {
            value = offset;

            if((width + offset) > max)
                value = (max - width);

            if(value)
            {
                for(a = 0; a < hud.size; a++)
                {
                    if(IsDefined(self.menuUI[hud[a]]))
                        self.menuUI[hud[a]] thread hudScaleOverTime(0.05, self.menuUI[hud[a]].width + value, self.menuUI[hud[a]].height);
                }

                width += value;
            }

            wait 0.05;
        }
        else if(self AdsButtonPressed())
        {
            value = offset;

            if((width - offset) < min)
                value = (width - min);

            if(value)
            {
                for(a = 0; a < hud.size; a++)
                {
                    if(IsDefined(self.menuUI[hud[a]]))
                        self.menuUI[hud[a]] thread hudScaleOverTime(0.05, self.menuUI[hud[a]].width - value, self.menuUI[hud[a]].height);
                }

                width -= value;
            }

            wait 0.05;
        }
        else if(self ActionSlotThreeButtonPressed())
        {
            if(offset > 1)
                offset--;
            
            self.menuUI["offsetValue"] SetValue(offset);
            wait 0.1;
        }
        else if(self ActionSlotFourButtonPressed())
        {
            if(offset < 10)
                offset++;
            
            self.menuUI["offsetValue"] SetValue(offset);
            wait 0.1;
        }
        else if(self UseButtonPressed())
        {
            self.MenuWidth = width;
        }
        else if(self MeleeButtonPressed())
        {
            break;
        }
        
        wait 0.025;
    }
    
    self SoftUnlockMenu();
    self SaveMenuTheme();
}

MenuDesign(design)
{
    if(self.MenuDesign == design)
        return;
    
    self.MenuDesign = design;

    if((design == "Native" || design == "Classic" || design == "Physics 'n' Flex") && Is_True(self.ColoredCursor))
        self.ColoredCursor = BoolVar(self.ColoredCursor);
    
    if((design == "AIO" || design == "Physics 'n' Flex") && Is_True(self.OptionCounter))
        self.OptionCounter = BoolVar(self.OptionCounter);

    self closeMenu1();
    self openMenu1();
    self SaveMenuTheme();
}

BoolDisplay(type)
{
    if(self.BoolDisplay == type)
        return;

    if(type == "Boxes" && Is_True(self.StealthUI))
        return self iPrintlnBold("^1ERROR: ^7Bool Display Can't Be Set To Boxes While Stealth UI Is Enabled");
    
    self.BoolDisplay = type;
    self SaveMenuTheme();
    self RefreshMenu();
}

BoolLocation(location)
{
    if(self.BoolLocation == location)
        return;
    
    self.BoolLocation = location;
    self SaveMenuTheme();
    self RefreshMenu();
}

ScrollAnimationTime(time)
{
    self.ScrollAnimationTime = (time * 0.01);
    self SaveMenuTheme();
}

QuickExit()
{
    self.QuickExit = BoolVar(self.QuickExit);
    self SaveMenuTheme();
}

DisableMenuInstructions()
{
    self.DisableMenuInstructions = BoolVar(self.DisableMenuInstructions);
    self SaveMenuTheme();
    self RefreshMenu(); //Instructions display will count towards the max options shown

    if(!Is_True(self.DisableMenuInstructions))
        self thread MenuInstructionsDisplay();
}

AdaptiveMenuInstructions()
{
    self.AdaptiveMenuInstructions = BoolVar(self.AdaptiveMenuInstructions);
    self SaveMenuTheme();
}

RepositionMenuInstructions()
{
    if(Is_True(self.DisableMenuInstructions))
        return self iPrintlnBold("^1ERROR: ^7You Can't Reposition Instructions While They're Disabled");

    self endon("disconnect");
    
    adjX = self.instructionsX;
    adjY = self.instructionsY;
    
    self closeMenu1();
    self.DisableMenuControls = true;
    self SetMenuInstructions("[{+melee}] - Exit\n[{+activate}] - Save Position\n[{+actionslot 1}] - Move Up\n[{+actionslot 2}] - Move Down\n[{+actionslot 3}] - Move Left\n[{+actionslot 4}] - Move Right");

    wait 0.1;
    self.RepositionMenuInstructions = true;
    
    while(1)
    {
        if(self ActionSlotOneButtonPressed() || self ActionSlotTwoButtonPressed())
        {
            incValue = self ActionSlotTwoButtonPressed() ? 8 : -8;
            
            foreach(key in GetArrayKeys(self.menuInstructionsUI))
            {
                if(!IsDefined(self.menuInstructionsUI[key]))
                    continue;
                
                if(IsArray(self.menuInstructionsUI[key]))
                {
                    for(a = 0; a < self.menuInstructionsUI[key].size; a++)
                    {
                        if(IsDefined(self.menuInstructionsUI[key][a]))
                            self.menuInstructionsUI[key][a].y += incValue;
                    }
                }
                else
                {
                    self.menuInstructionsUI[key].y += incValue;
                }
            }
            
            adjY += incValue;
        }
        else if(self ActionSlotThreeButtonPressed() || self ActionSlotFourButtonPressed())
        {
            incValue = self ActionSlotFourButtonPressed() ? 8 : -8;
            
            foreach(key in GetArrayKeys(self.menuInstructionsUI))
            {
                if(!IsDefined(self.menuInstructionsUI[key]))
                    continue;
                
                if(IsArray(self.menuInstructionsUI[key]))
                {
                    for(a = 0; a < self.menuInstructionsUI[key].size; a++)
                    {
                        if(IsDefined(self.menuInstructionsUI[key][a]))
                            self.menuInstructionsUI[key][a].x += incValue;
                    }
                }
                else
                {
                    self.menuInstructionsUI[key].x += incValue;
                }
            }
            
            adjX += incValue;
        }
        else if(self UseButtonPressed())
        {
            self.instructionsX = adjX;
            self.instructionsY = adjY;
        }
        else if(self MeleeButtonPressed())
        {
            break;
        }
        
        wait 0.025;
    }
    
    wait 0.1;
    self.DisableMenuControls = undefined;
    self.RepositionMenuInstructions = undefined;
    self SetMenuInstructions();
    self SaveMenuTheme();
    self openMenu1();
}

ResetMenuInstructions()
{
    self.instructionsX = -100;
    self.instructionsY = 230;
    self SaveMenuTheme();
}

DisableQuickMenu()
{
    self.DisableQM = BoolVar(self.DisableQM);
    self SaveMenuTheme();
}

SpotlightCursor()
{
    self.SpotlightCursor = BoolVar(self.SpotlightCursor);
    self SaveMenuTheme();
}

ColoredCursor()
{
    if(self.MenuDesign == "Native" || self.MenuDesign == "Classic" || self.MenuDesign == "Physics 'n' Flex")
        return self iPrintlnBold("^1ERROR: ^7You Can't Use Colored Cursor With This Design");
    
    self.ColoredCursor = BoolVar(self.ColoredCursor);
    self SaveMenuTheme();
}

LargeCursor()
{
    self.LargeCursor = BoolVar(self.LargeCursor);
    self SaveMenuTheme();
}

OptionCounter()
{
    if(Is_True(self.StealthUI))
        return self iPrintlnBold("^1ERROR: ^7You Can't Use The Option Counter While Stealth UI Is Enabled");
    
    if(self.MenuDesign == "AIO" || self.MenuDesign == "Physics 'n' Flex")
        return self iPrintlnBold("^1ERROR: ^7You Can't Use The Option Counter With This Design");
    
    self.OptionCounter = BoolVar(self.OptionCounter);
    self closeMenu1();
    self openMenu1();
    self SaveMenuTheme();
}

StealthUI()
{
    self.StealthUI = BoolVar(self.StealthUI);

    if(Is_True(self.StealthUI) && self.BoolDisplay == "Boxes")
        self.BoolDisplay = "Text";
    
    if(Is_True(self.OptionCounter))
    {
        self.OptionCounter = undefined;
        self closeMenu1();
        self openMenu1();
    }

    self SaveMenuTheme();
}

SaveMenuTheme()
{
    variables = Array("menuSaved", "menuX", "menuY", "instructionsX", "instructionsY", "MenuWidth", "DisableMenuInstructions", "AdaptiveMenuInstructions", "MainTheme", "MenuDesign", "OpenControls", "QuickControls", "QuickExit", "BoolDisplay", "BoolLocation", "ScrollAnimationTime", "DisableQM", "SpotlightCursor", "ColoredCursor", "LargeCursor", "OptionCounter", "StealthUI");
    values    = Array(1, self.menuX, self.menuY, self.instructionsX, self.instructionsY, self.MenuWidth, self.DisableMenuInstructions, self.AdaptiveMenuInstructions, self.MainTheme, self.MenuDesign, self.OpenControls, self.QuickControls, self.QuickExit, self.BoolDisplay, self.BoolLocation, (self.ScrollAnimationTime * 100), self.DisableQM, self.SpotlightCursor, self.ColoredCursor, self.LargeCursor, self.OptionCounter, self.StealthUI);
    
    foreach(index, variable in variables)
    {
        value = IsDefined(values[index]) ? values[index] : 0;

        if(variable == "OpenControls")
        {
            str = "";

            foreach(indx, btn in self.OpenControls)
                str += (indx < (self.OpenControls.size - 1)) ? btn + "," : btn;
            
            value = str;
        }
        else if(variable == "QuickControls")
        {
            str = "";

            foreach(indx, btn in self.QuickControls)
                str += (indx < (self.QuickControls.size - 1)) ? btn + "," : btn;
            
            value = str;
        }

        self SetSavedVariable(variable, (variable == "MainTheme" && Is_True(self.SmoothRainbowTheme)) ? "Rainbow" : value);
    }
}

SetSavedVariable(variable, value)
{
    //Every value will be saved as a string. The data type can be converted after the value is grabbed.
    SetDvar(variable + self GetXUID(), "" + value);
}

GetSavedVariable(variable)
{
    //Every value will be grabbed as a string. Convert to the desired data type when you load it
    //i.e. Int(GetSavedVariable(< variable >))
    return GetDvarString(variable + self GetXUID());
}

LoadMenuVars()
{
    self.menuX = -176; //Keep in mind that the position is close to the center to ensure the menu is visible on any resolution(use the menu position editor to place it where it best fits your liking)
    self.menuY = -161;
    self.instructionsX = -100;
    self.instructionsY = 230;
    self.MenuWidth = 260;
    self.MainTheme = (57, 152, 254);
    self.MenuDesign = GetMenuName();
    self.BoolDisplay = "Boxes";
    self.BoolLocation = "Right";
    self.OpenControls = Array("+speed_throw", "+melee");
    self.QuickControls = Array("+speed_throw", "+smoke");
    self.ScrollAnimationTime = 0.12;
    self.ColoredCursor = true;
    self.SpotlightCursor = true;
    saved = Int(self GetSavedVariable("menuSaved"));
    
    if(Is_True(saved))
    {
        self.menuX                    = Int(self GetSavedVariable("menuX"));
        self.menuY                    = Int(self GetSavedVariable("menuY"));
        self.instructionsX            = Int(self GetSavedVariable("instructionsX"));
        self.instructionsY            = Int(self GetSavedVariable("instructionsY"));
        self.MenuWidth                = Int(self GetSavedVariable("MenuWidth"));
        self.DisableMenuInstructions  = returnBool(Int(self GetSavedVariable("DisableMenuInstructions")));
        self.AdaptiveMenuInstructions = returnBool(Int(self GetSavedVariable("AdaptiveMenuInstructions")));
        self.MenuDesign               = self GetSavedVariable("MenuDesign");
        self.BoolDisplay              = self GetSavedVariable("BoolDisplay");
        self.BoolLocation             = self GetSavedVariable("BoolLocation");
        self.ScrollAnimationTime      = (Int(self GetSavedVariable("ScrollAnimationTime")) * 0.01);
        self.QuickExit                = returnBool(Int(self GetSavedVariable("QuickExit")));
        self.DisableQM                = returnBool(Int(self GetSavedVariable("DisableQM")));
        self.SpotlightCursor          = returnBool(Int(self GetSavedVariable("SpotlightCursor")));
        self.ColoredCursor            = returnBool(Int(self GetSavedVariable("ColoredCursor")));
        self.LargeCursor              = returnBool(Int(self GetSavedVariable("LargeCursor")));
        self.OptionCounter            = returnBool(Int(self GetSavedVariable("OptionCounter")));
        self.StealthUI                = returnBool(Int(self GetSavedVariable("StealthUI")));

        self.OpenControls = [];
        btnToks = StrTok(self GetSavedVariable("OpenControls"), ",");

        foreach(btn in btnToks)
            self.OpenControls[self.OpenControls.size] = btn;
        
        self.QuickControls = [];
        btnToks = StrTok(self GetSavedVariable("QuickControls"), ",");

        foreach(btn in btnToks)
            self.QuickControls[self.QuickControls.size] = btn;

        if(self GetSavedVariable("MainTheme") == "Rainbow")
            self thread SmoothRainbowTheme();
        else
            self.MainTheme = GetDvarVector1("MainTheme" + self GetXUID());
    }
    else
    {
        self SaveMenuTheme();
    }
}

returnBool(boolVar)
{
    return Is_True(boolVar) ? true : undefined;
}

GetMaxOptions()
{
    if(self.MenuDesign == "Physics 'n' Flex")
        return 6;
    
    if(Is_True(self.StealthUI))
        return 5;
    
    MaxOptions = 10;

    if(Is_True(self.DisableMenuInstructions))
        MaxOptions++;
    
    if(self.BoolDisplay != "Boxes")
    {
        MaxOptions += 2;

        if(Is_True(self.DisableMenuInstructions))
            MaxOptions++;
    }

    if(Is_True(self.OptionCounter))
        MaxOptions -= 2;
    
    return MaxOptions;
}
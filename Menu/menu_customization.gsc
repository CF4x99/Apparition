PopulateMenuCustomization(menu)
{
    switch(menu)
    {
        case "Menu Customization":
            self addMenu("Menu Customization");
                self addOpt("Menu Credits", ::MenuCredits);
                self addOptSlider("Menu Style", ::MenuStyle, level.menuName + ";Zodiac;Nautaremake;Native");
                self addOpt("Design Preferences", ::newMenu, "Design Preferences");
                self addOpt("Main Design Color", ::newMenu, "Main Design Color");
                self addOpt("Title Color", ::newMenu, "Title Color");
                self addOpt("Options Color", ::newMenu, "Options Color");
                self addOpt("Scrolling Option Color", ::newMenu, "Scrolling Option Color");
                self addOpt("Toggled Option Color", ::newMenu, "Toggled Option Color");
            break;

        case "Design Preferences":

            if(self.MenuStyle == "Zodiac")
                maxOptions = 20;
            else
                maxOptions = 10;
            
            self addMenu("Design Preferences");
                self addOptSlider("Toggle Style", ::ToggleStyle, "Boxes;Text;Text Color");
                self addOptIncSlider("Max Options", ::MenuMaxOptions, 5, 5, maxOptions, 1);
                self addOptIncSlider("Scrolling Buffer", ::MenuScrollingBuffer, 1, 12, 15, 1);
                self addOpt("Reposition Menu", ::RepositionMenu);
                self addOptBool(self.LargeCursor, "Large Cursor", ::LargeCursor);
                self addOptBool(self.DisableEntityCount, "Disable Entity Count", ::DisableEntityCount);
                self addOptBool(self.DisableMenuInstructions, "Disable Instructions", ::DisableMenuInstructions);
                self addOptBool(self.DisableQM, "Disable Quick Menu", ::DisableQuickMenu);
                self addOptBool(self.DisableMenuAnimations, "Disable Menu Animations", ::DisableMenuAnimations);
                self addOptBool(self.DisableMenuSounds, "Disable Menu Sounds", ::DisableMenuSounds);
            break;
        
        case "Main Design Color":
            self addMenu("Main Design Color");
                
                for(a = 0; a < level.colorNames.size; a++)
                    self addOptBool((!Is_True(self.SmoothRainbowTheme) && self.MainColor == divideColor(level.colors[(3 * a)], level.colors[((3 * a) + 1)], level.colors[((3 * a) + 2)])), level.colorNames[a], ::MenuTheme, divideColor(level.colors[(3 * a)], level.colors[((3 * a) + 1)], level.colors[((3 * a) + 2)]));
                
                self addOptBool(self.SmoothRainbowTheme, "Smooth Rainbow", ::SmoothRainbowTheme);
            break;
        
        case "Title Color":
            self addMenu("Title Color");
                
                for(a = 0; a < level.colorNames.size; a++)
                    self addOptBool((IsVec(self.TitleColor) && self.TitleColor == divideColor(level.colors[(3 * a)], level.colors[((3 * a) + 1)], level.colors[((3 * a) + 2)])), level.colorNames[a], ::SetTitleColor, divideColor(level.colors[(3 * a)], level.colors[((3 * a) + 1)], level.colors[((3 * a) + 2)]));
                
                self addOptBool((IsString(self.TitleColor) && self.TitleColor == "Rainbow"), "Smooth Rainbow", ::SetTitleColor, "Rainbow");
            break;
        
        case "Options Color":
            self addMenu("Options Color");
                
                for(a = 0; a < level.colorNames.size; a++)
                    self addOptBool((IsVec(self.OptionsColor) && self.OptionsColor == divideColor(level.colors[(3 * a)], level.colors[((3 * a) + 1)], level.colors[((3 * a) + 2)])), level.colorNames[a], ::SetOptionsColor, divideColor(level.colors[(3 * a)], level.colors[((3 * a) + 1)], level.colors[((3 * a) + 2)]));

                self addOptBool((IsString(self.OptionsColor) && self.OptionsColor == "Rainbow"), "Smooth Rainbow", ::SetOptionsColor, "Rainbow");
            break;
        
        case "Toggled Option Color":
            self addMenu("Toggled Option Color");
                
                for(a = 0; a < level.colorNames.size; a++)
                    self addOptBool((IsVec(self.ToggleTextColor) && self.ToggleTextColor == divideColor(level.colors[(3 * a)], level.colors[((3 * a) + 1)], level.colors[((3 * a) + 2)])), level.colorNames[a], ::SetToggleTextColor, divideColor(level.colors[(3 * a)], level.colors[((3 * a) + 1)], level.colors[((3 * a) + 2)]));

                self addOptBool((IsString(self.ToggleTextColor) && self.ToggleTextColor == "Rainbow"), "Smooth Rainbow", ::SetToggleTextColor, "Rainbow");
            break;
        
        case "Scrolling Option Color":
            self addMenu("Scrolling Option Color");

                for(a = 0; a < level.colorNames.size; a++)
                    self addOptBool((IsVec(self.ScrollingTextColor) && self.ScrollingTextColor == divideColor(level.colors[(3 * a)], level.colors[((3 * a) + 1)], level.colors[((3 * a) + 2)])), level.colorNames[a], ::SetScrollingTextColor, divideColor(level.colors[(3 * a)], level.colors[((3 * a) + 1)], level.colors[((3 * a) + 2)]));
            
                self addOptBool((IsString(self.ScrollingTextColor) && self.ScrollingTextColor == "Rainbow"), "Smooth Rainbow", ::SetScrollingTextColor, "Rainbow");
            break;
    }
}

MenuTheme(color)
{
    self notify("EndSmoothRainbowTheme");
    self.SmoothRainbowTheme = false;
    
    hud = Array("outlines", "bannerQM");
    
    if(self.MenuStyle != "Nautaremake")
        hud[hud.size] = "scroller";
    
    if(self.MenuStyle == "Zodiac" && !self isInQuickMenu())
        hud[hud.size] = "title";
    
    for(a = 0; a < hud.size; a++)
    {
        if(!isDefined(self.menuHud[hud[a]]))
            continue;
        
        if(IsArray(self.menuHud[hud[a]]))
        {
            for(b = 0; b < self.menuHud[hud[a]].size; b++)
            {
                if(!isDefined(self.menuHud[hud[a]][b]))
                    continue;
                
                if(self.MenuStyle == "Native" && hud[a] == "outlines" && b)
                    continue;
                
                if(isDefined(self.menuHud[hud[a]][b]))
                    self.menuHud[hud[a]][b] hudFadeColor(color, 1);
            }
        }
        else
            self.menuHud[hud[a]] hudFadeColor(color, 1);
    }
    
    wHud = "BoolOpt";

    if(self.MenuStyle == "Nautaremake")
        wHud = "BoolBack";
    
    if(isDefined(self.menuStructure) && self.menuStructure.size)
        for(a = 0; a < self.menuStructure.size; a++)
            if(isDefined(self.menuHud[wHud][a]) && (isDefined(self.menuStructure[a].bool) && self.menuStructure[a].bool || self.MenuStyle == "Nautaremake") && self.ToggleStyle != "Text")
                self.menuHud[wHud][a] hudFadeColor(color, 1);
    
    if(isDefined(self.EntCountBGOuter))
        self.EntCountBGOuter hudFadeColor(color, 1);
    
    if(isDefined(self.MenuInstructionsBGOuter))
        self.MenuInstructionsBGOuter hudFadeColor(color, 1);
    
    if(isDefined(self.menuHud) && isDefined(self.menuHud["QMScroller"]) && isDefined(self.menuHud["QMScroller"][1]))
        self.menuHud["QMScroller"][1] hudFadeColor(color, 1);
    
    if(isDefined(self.PlayerInfoBackgroundOuter))
        self.PlayerInfoBackgroundOuter hudFadeColor(color, 1);
    
    self.MainColor = color;
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
    
    while(Is_True(self.SmoothRainbowTheme))
    {
        hud = Array("outlines", "bannerQM");
        
        if(self.MenuStyle != "Nautaremake")
            hud[hud.size] = "scroller";
        
        if(self.MenuStyle == "Zodiac" && !self isInQuickMenu())
            hud[hud.size] = "title";

        for(a = 0; a < hud.size; a++)
        {
            if(!isDefined(self.menuHud[hud[a]]))
                continue;
            
            if(IsArray(self.menuHud[hud[a]]))
            {
                for(b = 0; b < self.menuHud[hud[a]].size; b++)
                {
                    if(!isDefined(self.menuHud[hud[a]][b]))
                        continue;
                    
                    if(self.MenuStyle == "Native" && hud[a] == "outlines" && b)
                        continue;
                    
                    if(isDefined(self.menuHud[hud[a]][b]))
                        self.menuHud[hud[a]][b].color = level.RGBFadeColor;
                }
            }
            else
                self.menuHud[hud[a]].color = level.RGBFadeColor;
        }

        wHud = "BoolOpt";

        if(self.MenuStyle == "Nautaremake")
            wHud = "BoolBack";
        
        if(isDefined(self.menuStructure) && self.menuStructure.size)
            for(a = 0; a < self.menuStructure.size; a++)
                if(isDefined(self.menuHud[wHud][a]) && (isDefined(self.menuStructure[a].bool) && self.menuStructure[a].bool || self.MenuStyle == "Nautaremake") && self.ToggleStyle != "Text")
                    self.menuHud[wHud][a].color = level.RGBFadeColor;
        
        if(isDefined(self.MenuInstructionsBGOuter))
            self.MenuInstructionsBGOuter.color = level.RGBFadeColor;
        
        if(isDefined(self.EntCountBGOuter))
            self.EntCountBGOuter.color = level.RGBFadeColor;
        
        if(isDefined(self.menuHud) && isDefined(self.menuHud["QMScroller"]) && isDefined(self.menuHud["QMScroller"][1]))
            self.menuHud["QMScroller"][1].color = level.RGBFadeColor;
        
        if(isDefined(self.PlayerInfoBackgroundOuter))
            self.PlayerInfoBackgroundOuter.color = level.RGBFadeColor;
        
        if(isDefined(self.keyboard) && isDefined(self.keyboard["scroller"]))
            self.keyboard["scroller"].color = level.RGBFadeColor;
        
        self.MainColor = level.RGBFadeColor;
        
        wait 0.01;
    }
}

ElementSmoothRainbow(element)
{
    self notify("EndElemSmoothRainbow" + element);
    self endon("disconnect");
    self endon("EndElemSmoothRainbow" + element);

    if(element == "textScrolling" || element == "textToggled")
    {
        if(element == "textScrolling")
            textScrolling = true;

        if(element == "textToggled")
            textToggled = true;

        element = "text";
    }

    while(1)
    {
        if(!self isInQuickMenu())
        {
            if(IsArray(self.menuHud[element]))
            {
                foreach(index, elem in self.menuHud[element])
                {
                    if(!isDefined(elem))
                        continue;
                    
                    if(self isInQuickMenu() && !isDefined(textToggled))
                        continue;
                    
                    if(element == "text" && isDefined(textToggled) && (!isDefined(self.menuStructure[index].bool) || !self.menuStructure[index].bool || self.ToggleStyle != "Text Color"))
                        continue;
                    
                    if(element == "text" && !isDefined(textScrolling) && !isDefined(textToggled) && index == self getCursor())
                        continue;
                    
                    if(element == "text" && isDefined(textScrolling) && (index != self getCursor() || isDefined(self.menuStructure[index].bool) && self.menuStructure[index].bool && self.ToggleStyle == "Text Color"))
                        continue;
                    
                    if(element == "text" && !isDefined(textToggled) && isDefined(self.menuStructure[index].bool) && self.menuStructure[index].bool && self.ToggleStyle == "Text Color")
                        continue;

                    elem.color = level.RGBFadeColor;

                    hudElems = Array("BoolOpt", "subMenu", "IntSlider", "StringSlider");

                    for(a = 0; a < hudElems.size; a++)
                        if(isDefined(self.menuHud[hudElems[a]][index]) && (hudElems[a] != "BoolOpt" || hudElems[a] == "BoolOpt" && self.ToggleStyle == "Text"))
                            self.menuHud[hudElems[a]][index].color = level.RGBFadeColor;
                }
            }
            else
            {
                if(isDefined(self.menuHud[element]) && (element != "title" || element == "title" && self.MenuStyle != "Zodiac" && !self isInQuickMenu()))
                    self.menuHud[element].color = level.RGBFadeColor;
            }
        }

        wait 0.01;
    }
}

ToggleStyle(style)
{
    self.ToggleStyle = style;
    self RefreshMenu();
    self SaveMenuTheme();
}

SetTitleColor(color)
{
    self notify("EndElemSmoothRainbowtitle");

    self.TitleColor = color;

    if(IsString(color))
        self thread ElementSmoothRainbow("title");
    
    self RefreshMenu();
    self SaveMenuTheme();
}

SetOptionsColor(color)
{
    self notify("EndElemSmoothRainbowtext");

    self.OptionsColor = color;

    if(IsString(color))
        self thread ElementSmoothRainbow("text");
    
    self RefreshMenu();
    self SaveMenuTheme();
}

SetToggleTextColor(color)
{
    self notify("EndElemSmoothRainbowtextToggled");

    self.ToggleTextColor = color;

    if(IsString(color))
        self thread ElementSmoothRainbow("textToggled");
    
    self RefreshMenu();
    self SaveMenuTheme();
}

SetScrollingTextColor(color)
{
    self notify("EndElemSmoothRainbowtextScrolling");

    self.ScrollingTextColor = color;

    if(IsString(color))
        self thread ElementSmoothRainbow("textScrolling");
    
    self RefreshMenu();
    self SaveMenuTheme();
}

SetMenuFontscale(fontscale, hud)
{
    if(hud == "Title")
        self.TitleFontScale = fontscale;
    else
        self.OptionsFontScale = fontscale;
    
    self closeMenu1();
    self openMenu1();
    self SaveMenuTheme();
}

MenuMaxOptions(max)
{
    self.MaxOptions = max;
    self RefreshMenu();
    self SaveMenuTheme();
}

MenuScrollingBuffer(buffer)
{
    self.ScrollingBuffer = buffer;
    self SaveMenuTheme();
}

RepositionMenu()
{
    self endon("disconnect");
    
    increment = 8;
    
    adjX = self.menuX;
    adjY = self.menuY;
    
    self SoftLockMenu(120);
    
    if(isDefined(self.menuHud["scroller"]))
        self.menuHud["scroller"].alpha = 0;
    
    //You won't be able to move the Y position when the 'Zodiac' menu style is set
    instructions = "[{+melee}] - Exit\n[{+activate}] - Save Position\n[{+actionslot 1}] - Move Up\n[{+actionslot 2}] - Move Down\n[{+actionslot 3}] - Move Left\n[{+actionslot 4}] - Move Right";

    if(self.MenuStyle == "Zodiac")
        instructions = "[{+melee}] - Exit\n[{+activate}] - Save Position\n[{+actionslot 3}] - Move Left\n[{+actionslot 4}] - Move Right";
    
    self SetMenuInstructions(instructions);
    
    while(1)
    {
        if(self.MenuStyle != "Zodiac" && (self ActionSlotOneButtonPressed() || self ActionSlotTwoButtonPressed()))
        {
            keys = GetArrayKeys(self.menuHud);

            incValue = (increment * -1);

            if(self ActionSlotTwoButtonPressed())
                incValue = increment;
            
            foreach(key in keys)
            {
                if(!isDefined(self.menuHud[key]))
                    continue;
                
                if(IsArray(self.menuHud[key]))
                {
                    for(a = 0; a < self.menuHud[key].size; a++)
                        if(isDefined(self.menuHud[key][a]))
                            self.menuHud[key][a].y += incValue;
                }
                else
                    self.menuHud[key].y += incValue;
            }
            
            adjY += incValue;
        }
        else if(self ActionSlotThreeButtonPressed() || self ActionSlotFourButtonPressed())
        {
            keys = GetArrayKeys(self.menuHud);

            incValue = (increment * -1);

            if(self ActionSlotFourButtonPressed())
                incValue = increment;
            
            foreach(key in keys)
            {
                if(!isDefined(self.menuHud[key]))
                    continue;
                
                if(IsArray(self.menuHud[key]))
                {
                    for(a = 0; a < self.menuHud[key].size; a++)
                        if(isDefined(self.menuHud[key][a]))
                            self.menuHud[key][a].x += incValue;
                }
                else
                    self.menuHud[key].x += incValue;
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
            self closeMenu1();
            self openMenu1();
            
            break;
        }
        
        wait 0.025;
    }
    
    self SetMenuInstructions();
    self SoftUnlockMenu();
    self SaveMenuTheme();
}

DisableEntityCount()
{
    if(!Is_True(self.DisableEntityCount))
        self.DisableEntityCount = true;
    else
        self.DisableEntityCount = false;
    
    self SaveMenuTheme();
}

DisableMenuInstructions()
{
    if(!Is_True(self.DisableMenuInstructions))
        self.DisableMenuInstructions = true;
    else
        self.DisableMenuInstructions = false;
    
    self SaveMenuTheme();
}

LargeCursor()
{
    if(!Is_True(self.LargeCursor))
        self.LargeCursor = true;
    else
        self.LargeCursor = false;
    
    self RefreshMenu();
    self SaveMenuTheme();
}

DisableQuickMenu()
{
    if(!Is_True(self.DisableQM))
        self.DisableQM = true;
    else
        self.DisableQM = false;
    
    self SaveMenuTheme();
}

DisableMenuAnimations()
{
    if(!Is_True(self.DisableMenuAnimations))
        self.DisableMenuAnimations = true;
    else
        self.DisableMenuAnimations = false;
    
    self SaveMenuTheme();
}

DisableMenuSounds()
{
    if(!Is_True(self.DisableMenuSounds))
        self.DisableMenuSounds = true;
    else
        self.DisableMenuSounds = false;
    
    self SaveMenuTheme();
}

MenuStyle(style)
{
    if(self.MenuStyle == style)
        return;
    
    self closeMenu1();
    self.MenuStyle = style;

    switch(style)
    {
        case "Zodiac":
            self.menuX = 298;
            self.menuY = -185;
            
            self.TitleFontScale = 1.6;
            self.OptionsFontScale = 1.2;

            self.MaxOptions = 12; //Zodiac Uses Less Hud, So We Can Show A Few More Options
            self.LargeCursor = true;
            self.ToggleStyle = "Boxes";
            break;
        
        default:
            self.menuX = -71;
            self.menuY = -185;

            if(self.MenuStyle == "Native")
                self.TitleFontScale = 2;
            else
                self.TitleFontScale = 1.4;
            
            self.OptionsFontScale = 1;
            
            if(self.MaxOptions > 10)
                self.MaxOptions = 10;
            
            self.LargeCursor = false;
            self.ToggleStyle = "Boxes";
            break;
    }
    
    self openMenu1();
    self SaveMenuTheme();
}

SaveMenuTheme()
{
    variables = Array("MenuStyle", "ToggleStyle", "MaxOptions", "menuX", "menuY", "MenuWidth", "TitleFontScale", "OptionsFontScale", "ScrollingBuffer", "DisableEntityCount", "DisableMenuInstructions", "LargeCursor", "DisableQM", "DisableMenuAnimations", "DisableMenuSounds", "OptionsColor", "TitleColor", "ToggleTextColor", "ScrollingTextColor", "MainColor");
    values    = Array(self.MenuStyle, self.ToggleStyle, self.MaxOptions, self.menuX, self.menuY, self.MenuWidth, self.TitleFontScale, self.OptionsFontScale, self.ScrollingBuffer, self.DisableEntityCount, self.DisableMenuInstructions, self.LargeCursor, self.DisableQM, self.DisableMenuAnimations, self.DisableMenuSounds, self.OptionsColor, self.TitleColor, self.ToggleTextColor, self.ScrollingTextColor, self.MainColor);
    
    foreach(index, variable in variables)
    {
        if(variable == "MainColor" && Is_True(self.SmoothRainbowTheme))
            value = "Rainbow";
        else
        {
            if(!isDefined(values[index]))
                value = "0";
            else
                value = "" + values[index];
        }
        
        self SetSavedVariable(variable, value);
    }
}

SetSavedVariable(variable, value)
{
    //Every value will be saved as a string. The data type can be converted after the value is grabbed.
    SetDvar(variable + self GetXUID(), "" + value);
}

GetSavedVariable(variable)
{
    //Every value will be grabbed as a string. Convert to the desired data type after
    //i.e. Int(GetSavedVariable(< variable >))
    return GetDvarString(variable + self GetXUID());
}

LoadMenuVars()
{
    self.MenuStyle = level.menuName; //Current Choices: level.menuName, Zodiac, Nautaremake, Native
    
    self.menuXQM = -1;
    self.menuYQM = -161;
    
    if(self.MenuStyle == "Zodiac")
        self.menuX = 298;
    else
        self.menuX = -81;
    
    self.menuY = -185;
    
    if(self.MenuStyle == "Zodiac")
        self.TitleFontScale = 1.6;
    else if(self.MenuStyle == "Native")
        self.TitleFontScale = 2;
    else
        self.TitleFontScale = 1.4;
    
    self.OptionsFontScale = 1;
    
    if(self.MenuStyle == "Zodiac") //Zodiac uses Less Hud, So We Can Show A Few More Options
        self.MaxOptions = 12;
    else
        self.MaxOptions = 10;
    
    self.maxOptionsQM       = 15;
    self.ScrollingBuffer    = 12;
    self.ToggleStyle        = "Boxes";
    self.MainColor          = (1, 0, 0); //Default theme color
    self.AltColor           = divideColor(45, 45, 45);
    self.OptionsColor       = (1, 1, 1);
    self.TitleColor         = (1, 1, 1);
    self.ToggleTextColor    = (0, 1, 0);
    self.ScrollingTextColor = (1, 1, 1);
    self.MenuWidth          = 262;
    
    //Change 'false' to 'true' if you want to disable the entity count by default
    self.DisableEntityCount = false;
    
    //Change 'false' to 'true' if you want to disable the instructions by default
    self.DisableMenuInstructions = false;
    
    //Change 'false' to 'true' if you want to disable the quick menu by default
    self.DisableQM = false;
    
    //Change 'false' to 'true' if you want to disable the menu open/close animations by default
    self.DisableMenuAnimations = false;
    
    //Change 'false' to 'true' if you want to disable the menu sounds by default
    self.DisableMenuSounds = false;
    
    //Change 'false' to 'true' if you want to enable large cursor by default
    if(self.MenuStyle == "Zodiac")
        self.LargeCursor = true;
    else
        self.LargeCursor = false;
    
    saved = self GetSavedVariable("MenuStyle");
    
    if(isDefined(saved) && saved != "")
    {
        self.MenuStyle               = self GetSavedVariable("MenuStyle");
        self.ToggleStyle             = self GetSavedVariable("ToggleStyle");
        self.MaxOptions              = Int(self GetSavedVariable("MaxOptions"));
        self.menuX                   = Int(self GetSavedVariable("menuX"));
        self.menuY                   = Int(self GetSavedVariable("menuY"));
        self.MenuWidth               = Int(self GetSavedVariable("MenuWidth"));
        self.TitleFontScale          = Float(self GetSavedVariable("TitleFontScale"));
        self.OptionsFontScale        = Float(self GetSavedVariable("OptionsFontScale"));
        self.ScrollingBuffer         = Int(self GetSavedVariable("ScrollingBuffer"));
        self.DisableEntityCount      = self GetSavedVariable("DisableEntityCount") == "1";
        self.DisableMenuInstructions = self GetSavedVariable("DisableMenuInstructions") == "1";
        self.LargeCursor             = self GetSavedVariable("LargeCursor") == "1";
        self.DisableQM               = self GetSavedVariable("DisableQM") == "1";
        self.DisableMenuAnimations   = self GetSavedVariable("DisableMenuAnimations") == "1";
        self.DisableMenuSounds       = self GetSavedVariable("DisableMenuSounds") == "1";

        if(self GetSavedVariable("OptionsColor") == "Rainbow")
        {
            self.OptionsColor = "Rainbow";
            self thread ElementSmoothRainbow("text");
        }
        else
            self.OptionsColor = GetDvarVector1("OptionsColor" + self GetXUID());
        
        if(self GetSavedVariable("TitleColor") == "Rainbow")
        {
            self.TitleColor = "Rainbow";
            self thread ElementSmoothRainbow("title");
        }
        else
            self.TitleColor = GetDvarVector1("TitleColor" + self GetXUID());
        
        if(self GetSavedVariable("ToggleTextColor") == "Rainbow")
        {
            self.ToggleTextColor = "Rainbow";
            self thread ElementSmoothRainbow("textToggled");
        }
        else
            self.ToggleTextColor = GetDvarVector1("ToggleTextColor" + self GetXUID());
        
        if(self GetSavedVariable("ScrollingTextColor") == "Rainbow")
        {
            self.ScrollingTextColor = "Rainbow";
            self thread ElementSmoothRainbow("textScrolling");
        }
        else
            self.ScrollingTextColor = GetDvarVector1("ScrollingTextColor" + self GetXUID());

        if(self GetSavedVariable("MainColor") == "Rainbow")
            self thread SmoothRainbowTheme();
        else
            self.MainColor = GetDvarVector1("MainColor" + self GetXUID());
    }
    else
    {
        self thread SmoothRainbowTheme(); //The color defaults to smooth rainbow. Remove this if you want the color to default to the self.MainColor variable.
        self SaveMenuTheme();
    }
}
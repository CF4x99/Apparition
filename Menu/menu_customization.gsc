PopulateMenuCustomization(menu)
{
    switch(menu)
    {
        case "Menu Customization":
            self addMenu("Menu Customization");
                self addOpt("Menu Credits", ::MenuCredits);
                self addOptSlider("Menu Style", ::MenuStyle, level.menuName + ";Zodiac;Nautaremake;AIO;Native;Quick Menu");
                self addOpt("Open Controls", ::newMenu, "Open Controls");
                self addOpt("Design Preferences", ::newMenu, "Design Preferences");
                self addOpt("Main Design Color", ::newMenu, "Main Design Color");
                self addOpt("Title Color", ::newMenu, "Title Color");
                self addOpt("Options Color", ::newMenu, "Options Color");
                self addOpt("Scrolling Option Color", ::newMenu, "Scrolling Option Color");
                self addOpt("Toggled Option Color", ::newMenu, "Toggled Option Color");
            break;
        
        case "Open Controls":
            if(!isDefined(self.OpenControlIndex))
                self.OpenControlIndex = 1;
            
            buttons = Array("+actionslot 1", "+actionslot 2", "+actionslot 3", "+actionslot 4", "+melee", "+speed_throw", "+attack", "+breath_sprint", "+activate", "+frag", "+stance");

            /*
                I made this system allow any amount of buttons to be used to open Apparition(I limited it to 3 buttons)
                No matter how many buttons you allow to be chosen, the players selection will save through games, and will show on the menu instructions as well.
                Also, no button can be selected more than once, and Bind Slot 1 can never be set to 'None'
            */

            self addMenu("Open Controls");
                self addOptIncSlider("Bind Slot", ::OpenControlIndex, 1, 1, 3, 1); //If you want to allow more buttons to be chosen, change the '3' to whatever number you want.
                self addOpt("");

                if(self.OpenControlIndex != 1)
                    self addOptBool(!isDefined(self.OpenControls[(self.OpenControlIndex - 1)]), "None", ::SetOpenButtons, "None");

                foreach(button in buttons)
                    self addOptBool((isDefined(self.OpenControls[(self.OpenControlIndex - 1)]) && self.OpenControls[(self.OpenControlIndex - 1)] == button), "[{" + button + "}]", ::SetOpenButtons, button);
            break;

        case "Design Preferences":
            self addMenu("Design Preferences");
                self addOptSlider("Toggle Style", ::ToggleStyle, "Boxes;Text;Text Color");
                self addOptIncSlider("Max Options", ::MenuMaxOptions, 5, 5, (self.MenuStyle == "Zodiac") ? 12 : (self.MenuStyle == "Quick Menu") ? 25 : 10, 1);
                self addOptIncSlider("Scrolling Buffer", ::MenuScrollingBuffer, 1, self.ScrollingBuffer, 15, 1);
                self addOpt("Reposition Menu", ::RepositionMenu);
                self addOptBool(self.LargeCursor, "Large Cursor", ::LargeCursor);
                self addOptBool(self.DisableMenuInstructions, "Disable Instructions", ::DisableMenuInstructions);
                self addOptBool(self.DisableQM, "Disable Quick Menu", ::DisableQuickMenu);
                self addOptBool(self.DisableMenuAnimations, "Disable Menu Animations", ::DisableMenuAnimations);
                self addOptBool(self.DisableMenuSounds, "Disable Menu Sounds", ::DisableMenuSounds);
            break;
        
        case "Main Design Color":
            self addMenu("Main Design Color");
                
                for(a = 0; a < level.colorNames.size; a++)
                    self addOptBoolPreview((!Is_True(self.SmoothRainbowTheme) && self.MainColor == divideColor(level.colors[(3 * a)], level.colors[((3 * a) + 1)], level.colors[((3 * a) + 2)])), "white", divideColor(level.colors[(3 * a)], level.colors[((3 * a) + 1)], level.colors[((3 * a) + 2)]), level.colorNames[a], ::MenuTheme, divideColor(level.colors[(3 * a)], level.colors[((3 * a) + 1)], level.colors[((3 * a) + 2)]));
                
                self addOptBoolPreview(self.SmoothRainbowTheme, "white", "Rainbow", "Smooth Rainbow", ::SmoothRainbowTheme);
            break;
        
        case "Title Color":
            self addMenu("Title Color");
                
                for(a = 0; a < level.colorNames.size; a++)
                    self addOptBoolPreview((IsVec(self.TitleColor) && self.TitleColor == divideColor(level.colors[(3 * a)], level.colors[((3 * a) + 1)], level.colors[((3 * a) + 2)])), "white", divideColor(level.colors[(3 * a)], level.colors[((3 * a) + 1)], level.colors[((3 * a) + 2)]), level.colorNames[a], ::SetTitleColor, divideColor(level.colors[(3 * a)], level.colors[((3 * a) + 1)], level.colors[((3 * a) + 2)]));
                
                self addOptBoolPreview((IsString(self.TitleColor) && self.TitleColor == "Rainbow"), "white", "Rainbow", "Smooth Rainbow", ::SetTitleColor, "Rainbow");
            break;
        
        case "Options Color":
            self addMenu("Options Color");
                
                for(a = 0; a < level.colorNames.size; a++)
                    self addOptBoolPreview((IsVec(self.OptionsColor) && self.OptionsColor == divideColor(level.colors[(3 * a)], level.colors[((3 * a) + 1)], level.colors[((3 * a) + 2)])), "white", divideColor(level.colors[(3 * a)], level.colors[((3 * a) + 1)], level.colors[((3 * a) + 2)]), level.colorNames[a], ::SetOptionsColor, divideColor(level.colors[(3 * a)], level.colors[((3 * a) + 1)], level.colors[((3 * a) + 2)]));

                self addOptBoolPreview((IsString(self.OptionsColor) && self.OptionsColor == "Rainbow"), "white", "Rainbow", "Smooth Rainbow", ::SetOptionsColor, "Rainbow");
            break;
        
        case "Toggled Option Color":
            self addMenu("Toggled Option Color");
                
                for(a = 0; a < level.colorNames.size; a++)
                    self addOptBoolPreview((IsVec(self.ToggleTextColor) && self.ToggleTextColor == divideColor(level.colors[(3 * a)], level.colors[((3 * a) + 1)], level.colors[((3 * a) + 2)])), "white", divideColor(level.colors[(3 * a)], level.colors[((3 * a) + 1)], level.colors[((3 * a) + 2)]), level.colorNames[a], ::SetToggleTextColor, divideColor(level.colors[(3 * a)], level.colors[((3 * a) + 1)], level.colors[((3 * a) + 2)]));

                self addOptBoolPreview((IsString(self.ToggleTextColor) && self.ToggleTextColor == "Rainbow"), "white", "Rainbow", "Smooth Rainbow", ::SetToggleTextColor, "Rainbow");
            break;
        
        case "Scrolling Option Color":
            self addMenu("Scrolling Option Color");

                for(a = 0; a < level.colorNames.size; a++)
                    self addOptBoolPreview((IsVec(self.ScrollingTextColor) && self.ScrollingTextColor == divideColor(level.colors[(3 * a)], level.colors[((3 * a) + 1)], level.colors[((3 * a) + 2)])), "white", divideColor(level.colors[(3 * a)], level.colors[((3 * a) + 1)], level.colors[((3 * a) + 2)]), level.colorNames[a], ::SetScrollingTextColor, divideColor(level.colors[(3 * a)], level.colors[((3 * a) + 1)], level.colors[((3 * a) + 2)]));
            
                self addOptBoolPreview((IsString(self.ScrollingTextColor) && self.ScrollingTextColor == "Rainbow"), "white", "Rainbow", "Smooth Rainbow", ::SetScrollingTextColor, "Rainbow");
            break;
    }
}

MenuTheme(color)
{
    self notify("EndSmoothRainbowTheme");

    if(Is_True(self.SmoothRainbowTheme))
        self.SmoothRainbowTheme = BoolVar(self.SmoothRainbowTheme);
    
    hud = Array("outlines");
    
    if(self.MenuStyle != "Nautaremake" || self isInQuickMenu())
        hud[hud.size] = "scroller";
    
    if(self.MenuStyle == "Zodiac" || self.MenuStyle == "Quick Menu" || self isInQuickMenu())
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
    
    wHud = (self.MenuStyle == "Nautaremake") ? "BoolBack" : "BoolOpt";
    
    if(isDefined(self.menuStructure) && self.menuStructure.size)
        for(a = 0; a < self.menuStructure.size; a++)
            if(isDefined(self.menuHud[wHud][a]) && (Is_True(self.menuStructure[a].bool) || self.MenuStyle == "Nautaremake") && self.ToggleStyle != "Text")
                self.menuHud[wHud][a] hudFadeColor(color, 1);
    
    if(isDefined(self.MenuInstructionsBGOuter))
        self.MenuInstructionsBGOuter hudFadeColor(color, 1);
    
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
        hud = Array("outlines");
        
        if(self.MenuStyle != "Nautaremake" || self isInQuickMenu())
            hud[hud.size] = "scroller";
        
        if(self.MenuStyle == "Zodiac" || self.MenuStyle == "Quick Menu" || self isInQuickMenu())
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

        wHud = (self.MenuStyle == "Nautaremake") ? "BoolBack" : "BoolOpt";
        
        if(isDefined(self.menuStructure) && self.menuStructure.size)
            for(a = 0; a < self.menuStructure.size; a++)
                if(isDefined(self.menuHud[wHud][a]) && (Is_True(self.menuStructure[a].bool) || self.MenuStyle == "Nautaremake") && self.ToggleStyle != "Text")
                    self.menuHud[wHud][a].color = level.RGBFadeColor;
        
        if(isDefined(self.MenuInstructionsBGOuter))
            self.MenuInstructionsBGOuter.color = level.RGBFadeColor;
        
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
                    
                    if(element == "text")
                    {
                        if(isDefined(textToggled) && (!isDefined(self.menuStructure[index].boolOpt) || !Is_True(self.menuStructure[index].bool) || self.ToggleStyle != "Text Color"))
                            continue;
                        
                        if(!isDefined(textScrolling) && !isDefined(textToggled) && index == self getCursor())
                            continue;
                        
                        if(isDefined(textScrolling) && (index != self getCursor() || Is_True(self.menuStructure[index].bool) && self.ToggleStyle == "Text Color"))
                            continue;
                        
                        if(!isDefined(textToggled) && Is_True(self.menuStructure[index].bool) && self.ToggleStyle == "Text Color")
                            continue;
                    }

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
                {
                    self.menuHud[element].color = level.RGBFadeColor;

                    if(element == "title" && self.MenuStyle == "AIO" && isDefined(self.menuHud["MenuName"]))
                        self.menuHud["MenuName"].color = level.RGBFadeColor;
                }
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
    
    adjX = self.menuX;
    adjY = self.menuY;
    
    self SoftLockMenu(120);
    
    if(isDefined(self.menuHud["scroller"]))
        self.menuHud["scroller"].alpha = 0;
    
    self SetMenuInstructions((self.MenuStyle == "Zodiac") ? "[{+melee}] - Exit\n[{+activate}] - Save Position\n[{+actionslot 3}] - Move Left\n[{+actionslot 4}] - Move Right" : "[{+melee}] - Exit\n[{+activate}] - Save Position\n[{+actionslot 1}] - Move Up\n[{+actionslot 2}] - Move Down\n[{+actionslot 3}] - Move Left\n[{+actionslot 4}] - Move Right");
    
    while(1)
    {
        if(self.MenuStyle != "Zodiac" && (self ActionSlotOneButtonPressed() || self ActionSlotTwoButtonPressed()))
        {
            incValue = self ActionSlotTwoButtonPressed() ? 8 : -8;
            
            foreach(key in GetArrayKeys(self.menuHud))
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
            incValue = self ActionSlotFourButtonPressed() ? 8 : -8;
            
            foreach(key in GetArrayKeys(self.menuHud))
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

DisableMenuInstructions()
{
    self.DisableMenuInstructions = BoolVar(self.DisableMenuInstructions);
    self SaveMenuTheme();
}

LargeCursor()
{
    self.LargeCursor = BoolVar(self.LargeCursor);
    self RefreshMenu();
    self SaveMenuTheme();
}

DisableQuickMenu()
{
    self.DisableQM = BoolVar(self.DisableQM);
    self SaveMenuTheme();
}

DisableMenuAnimations()
{
    self.DisableMenuAnimations = BoolVar(self.DisableMenuAnimations);
    self SaveMenuTheme();
}

DisableMenuSounds()
{
    self.DisableMenuSounds = BoolVar(self.DisableMenuSounds);
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
            self.MaxOptions = 12; //Zodiac Uses Less Hud, So We Can Show A Few More Options
            self.LargeCursor = true;
            self.ToggleStyle = "Boxes";
            break;
        
        case "Quick Menu":
            self.menuX = 0;
            self.menuY = -230;

            self.TitleFontScale = 1.5;
            self.MaxOptions = 25;
            self.LargeCursor = true;
            break;
        
        default:
            self.menuX = -101;
            self.menuY = -185;
            self.TitleFontScale = (self.MenuStyle == "Native") ? 2 : 1.4;
            
            if(self.MaxOptions > 10)
                self.MaxOptions = 10;
            
            if(Is_True(self.LargeCursor))
                self.LargeCursor = BoolVar(self.LargeCursor);
            
            self.ToggleStyle = "Boxes";
            break;
    }
    
    self openMenu1();
    self SaveMenuTheme();
}

SaveMenuTheme()
{
    variables = Array("MenuStyle", "ToggleStyle", "MaxOptions", "menuX", "menuY", "ScrollingBuffer", "DisableMenuInstructions", "LargeCursor", "DisableQM", "DisableMenuAnimations", "DisableMenuSounds", "MainColor", "OptionsColor", "TitleColor", "ToggleTextColor", "ScrollingTextColor", "OpenControls");
    values    = Array(self.MenuStyle, self.ToggleStyle, self.MaxOptions, self.menuX, self.menuY, self.ScrollingBuffer, self.DisableMenuInstructions, self.LargeCursor, self.DisableQM, self.DisableMenuAnimations, self.DisableMenuSounds, self.MainColor, self.OptionsColor, self.TitleColor, self.ToggleTextColor, self.ScrollingTextColor, self.OpenControls);
    
    foreach(index, variable in variables)
    {
        value = isDefined(values[index]) ? values[index] : 0;

        if(variable == "OpenControls")
        {
            str = "";

            foreach(indx, btn in self.OpenControls)
                str += (indx < (self.OpenControls.size - 1)) ? btn + "," : btn;
            
            value = str;
        }

        self SetSavedVariable(variable, (variable == "MainColor" && Is_True(self.SmoothRainbowTheme)) ? "Rainbow" : value);
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
    self.MenuStyle          = level.menuName; //Current Choices: level.menuName, Zodiac, Nautaremake, AIO, Native, Quick Menu
    self.menuX              = (self.MenuStyle == "Zodiac") ? 298 : (self.MenuStyle == "Quick Menu") ? 0 : -101; //Keep in mind that the position is close to the center to ensure the menu is visible on any resolution(use the menu position editor to place it where it best fits your liking)
    self.menuY              = (self.MenuStyle == "Quick Menu") ? -230 : -185;
    self.MaxOptions         = (self.MenuStyle == "Zodiac") ? 12 : (self.MenuStyle == "Quick Menu") ? 25 : 10;
    self.ScrollingBuffer    = 10;
    self.ToggleStyle        = "Boxes";
    self.MainColor          = (1, 0, 0);
    self.OptionsColor       = (1, 1, 1);
    self.TitleColor         = (1, 1, 1);
    self.ToggleTextColor    = (0, 1, 0);
    self.ScrollingTextColor = (1, 1, 1);

    self.OpenControls = Array("+speed_throw", "+melee");
    
    if(self.MenuStyle == "Zodiac" || self.MenuStyle == "Quick Menu")
        self.LargeCursor = true;
    
    saved = self GetSavedVariable("MenuStyle");
    
    if(isDefined(saved) && saved != "")
    {
        self.MenuStyle               = self GetSavedVariable("MenuStyle");
        self.ToggleStyle             = self GetSavedVariable("ToggleStyle");
        self.MaxOptions              = Int(self GetSavedVariable("MaxOptions"));
        self.menuX                   = Int(self GetSavedVariable("menuX"));
        self.menuY                   = Int(self GetSavedVariable("menuY"));
        self.ScrollingBuffer         = Int(self GetSavedVariable("ScrollingBuffer"));
        self.DisableMenuInstructions = Int(self GetSavedVariable("DisableMenuInstructions"));
        self.LargeCursor             = Int(self GetSavedVariable("LargeCursor"));
        self.DisableQM               = Int(self GetSavedVariable("DisableQM"));
        self.DisableMenuAnimations   = Int(self GetSavedVariable("DisableMenuAnimations"));
        self.DisableMenuSounds       = Int(self GetSavedVariable("DisableMenuSounds"));

        self.OpenControls = [];
        btnToks = StrTok(self GetSavedVariable("OpenControls"), ",");

        foreach(btn in btnToks)
            self.OpenControls[self.OpenControls.size] = btn;

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
        self thread SmoothRainbowTheme();
        self SaveMenuTheme();
    }
    
    self.TitleFontScale = (self.MenuStyle == "Zodiac") ? 1.6 : (self.MenuStyle == "Native") ? 2 : (self.MenuStyle == "Quick Menu") ? 1.5 : 1.4;
}
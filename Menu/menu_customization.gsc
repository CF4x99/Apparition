PopulateMenuCustomization(menu)
{
    switch(menu)
    {
        case "Menu Customization":
            self addMenu("Menu Customization");
                self addOpt("Menu Credits", ::MenuCredits);
                self addOpt("Open Controls", ::newMenu, "Open Controls");
                self addOpt("Reposition Menu", ::RepositionMenu);
                self addOpt("Main Design Color", ::newMenu, "Main Design Color");
                self addOptBool(self.DisableMenuInstructions, "Disable Instructions", ::DisableMenuInstructions);
                self addOptBool(self.DisableQM, "Disable Quick Menu", ::DisableQuickMenu);
            break;
        
        case "Open Controls":
            if(!IsDefined(self.OpenControlIndex))
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
                    self addOptBool(!IsDefined(self.OpenControls[(self.OpenControlIndex - 1)]), "None", ::SetOpenButtons, "None");

                foreach(button in buttons)
                    self addOptBool((IsDefined(self.OpenControls[(self.OpenControlIndex - 1)]) && self.OpenControls[(self.OpenControlIndex - 1)] == button), "[{" + button + "}]", ::SetOpenButtons, button);
            break;
        
        case "Main Design Color":
            self addMenu("Main Design Color");
                
                for(a = 0; a < GetColorNames().size; a++)
                    self addOptBoolPreview((!Is_True(self.SmoothRainbowTheme) && self.MainTheme == divideColor(GetColorValues()[(3 * a)], GetColorValues()[((3 * a) + 1)], GetColorValues()[((3 * a) + 2)])), "white", divideColor(GetColorValues()[(3 * a)], GetColorValues()[((3 * a) + 1)], GetColorValues()[((3 * a) + 2)]), GetColorNames()[a], ::MenuTheme, divideColor(GetColorValues()[(3 * a)], GetColorValues()[((3 * a) + 1)], GetColorValues()[((3 * a) + 2)]));
                
                self addOptBoolPreview(self.SmoothRainbowTheme, "white", "Rainbow", "Smooth Rainbow", ::SmoothRainbowTheme);
            break;
    }
}

MenuTheme(color)
{
    self notify("EndSmoothRainbowTheme");

    if(Is_True(self.SmoothRainbowTheme))
        self.SmoothRainbowTheme = BoolVar(self.SmoothRainbowTheme);
    
    hud = Array("text", "subMenu", "IntSlider", "StringSlider");
    
    if(IsDefined(self.menuUI))
    {
        if(IsDefined(self.menuUI["title"]))
            self.menuUI["title"] hudFadeColor(color, 0.5);
        
        if(IsDefined(self.menuStructure) && self.menuStructure.size)
        {
            for(a = 0; a < self.menuStructure.size; a++)
            {
                boolVal = self GetOption(a, 6);

                if(IsDefined(self.menuUI["BoolOpt"]) && IsDefined(self.menuUI["BoolOpt"][a]) && Is_True(boolVal))
                    self.menuUI["BoolOpt"][a] hudFadeColor(color, 0.5);
                
                for(b = 0; b < hud.size; b++)
                {
                    if(IsDefined(self.menuUI[hud[b]][a]))
                        self.menuUI[hud[b]][a] hudFadeColor((a == self getCursor()) ? color : (1, 1, 1), 1);
                }
            }
        }
    }

    if(IsDefined(self.menuInstructionsUI) && IsDefined(self.menuInstructionsUI["outline"]))
        self.menuInstructionsUI["outline"] hudFadeColor(color, 0.5);
    
    if(IsDefined(self.playerInfoHud) && IsDefined(self.playerInfoHud["outline"]))
        self.playerInfoHud["outline"] hudFadeColor(color, 0.5);
    
    if(IsDefined(self.keyboard) && IsDefined(self.keyboard["scroller"]))
        self.keyboard["scroller"] hudFadeColor(color, 0.5);
    
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

    hud = Array("text", "subMenu", "IntSlider", "StringSlider");
    
    while(Is_True(self.SmoothRainbowTheme))
    {
        color = level.RGBFadeColor;

        if(IsDefined(self.menuUI))
        {
            if(IsDefined(self.menuUI["title"]))
                self.menuUI["title"].color = color;
            
            if(IsDefined(self.menuStructure) && self.menuStructure.size)
            {
                for(a = 0; a < self.menuStructure.size; a++)
                {
                    boolVal = self GetOption(a, 6);

                    if(IsDefined(self.menuUI["BoolOpt"]) && IsDefined(self.menuUI["BoolOpt"][a]) && Is_True(boolVal))
                        self.menuUI["BoolOpt"][a].color = color;
                    
                    for(b = 0; b < hud.size; b++)
                    {
                        if(IsDefined(self.menuUI[hud[b]][a]))
                            self.menuUI[hud[b]][a].color = (a == self getCursor()) ? color : (1, 1, 1);
                    }
                }
            }
        }

        if(IsDefined(self.menuInstructionsUI) && IsDefined(self.menuInstructionsUI["outline"]))
            self.menuInstructionsUI["outline"].color = color;
        
        if(IsDefined(self.playerInfoHud) && IsDefined(self.playerInfoHud["outline"]))
            self.playerInfoHud["outline"].color = color;
        
        if(IsDefined(self.keyboard) && IsDefined(self.keyboard["scroller"]))
            self.keyboard["scroller"].color = color;
        
        self.MainTheme = color;
        wait 0.01;
    }
}

MenuMaxOptions(max)
{
    self.MaxOptions = max;
    self RefreshMenu();
    self SaveMenuTheme();
}

RepositionMenu()
{
    self endon("disconnect");
    
    adjX = self.menuX;
    adjY = self.menuY;
    
    self SoftLockMenu(120);
    
    if(IsDefined(self.menuUI["scroller"]))
        self.menuUI["scroller"].alpha = 0;
    
    self SetMenuInstructions("[{+melee}] - Exit\n[{+activate}] - Save Position\n[{+actionslot 1}] - Move Up\n[{+actionslot 2}] - Move Down\n[{+actionslot 3}] - Move Left\n[{+actionslot 4}] - Move Right");
    
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

    if(!Is_True(self.DisableMenuInstructions))
        self thread MenuInstructionsDisplay();
}

DisableQuickMenu()
{
    self.DisableQM = BoolVar(self.DisableQM);
    self SaveMenuTheme();
}

SaveMenuTheme()
{
    variables = Array("menuX", "menuY", "MaxOptions", "DisableMenuInstructions", "DisableQM", "MainTheme", "OpenControls");
    values    = Array(self.menuX, self.menuY, self.MaxOptions, self.DisableMenuInstructions, self.DisableQM, self.MainTheme, self.OpenControls);
    
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
    self.menuX = -101; //Keep in mind that the position is close to the center to ensure the menu is visible on any resolution(use the menu position editor to place it where it best fits your liking)
    self.menuY = -185;
    self.MaxOptions = 11;
    self.MainTheme = (1, 0, 0);
    self.OpenControls = Array("+speed_throw", "+melee");
    saved = Int(self GetSavedVariable("MaxOptions"));
    
    if(IsDefined(saved) && saved)
    {
        self.menuX                   = Int(self GetSavedVariable("menuX"));
        self.menuY                   = Int(self GetSavedVariable("menuY"));
        self.MaxOptions              = Int(self GetSavedVariable("MaxOptions"));
        self.DisableMenuInstructions = returnBool(Int(self GetSavedVariable("DisableMenuInstructions")));
        self.DisableQM               = returnBool(Int(self GetSavedVariable("DisableQM")));

        self.OpenControls = [];
        btnToks = StrTok(self GetSavedVariable("OpenControls"), ",");

        foreach(btn in btnToks)
            self.OpenControls[self.OpenControls.size] = btn;

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
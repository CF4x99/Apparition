MenuTheme(color)
{
    self notify("EndSmoothRainbowTheme");
    self.SmoothRainbowTheme = undefined;
    
    hud = ["scroller", "outlines"];

    for(a = 0; a < hud.size; a++)
    {
        if(isDefined(self.menu["ui"][hud[a]]))
        {
            if(IsArray(self.menu["ui"][hud[a]]))
            {
                for(b = 0; b < self.menu["ui"][hud[a]].size; b++)
                {
                    if(isDefined(self.menu["ui"][hud[a]][b]))
                        self.menu["ui"][hud[a]][b] hudFadeColor(color, 1);
                }
            }
            else
                self.menu["ui"][hud[a]] hudFadeColor(color, 1);
        }
    }
    
    for(a = 0; a < self.menu["items"][self getCurrent()].name.size; a++)
        if(isDefined(self.menu["ui"]["BoolOpt"][a]) && isDefined(self.menu_B[self getCurrent()][a]) && self.menu_B[self getCurrent()][a] && self.menu["ToggleStyle"] != "Text")
            self.menu["ui"]["BoolOpt"][a] hudFadeColor(color, 1);
    
    if(self.menu["MenuDesign"] == "Old School" && !self isInQuickMenu())
    {
        if(isDefined(self.menu["ui"]["text"][self getCursor()]))
            self.menu["ui"]["text"][self getCursor()] hudFadeColor(color, 1);
        
        if(isDefined(self.menu["ui"]["title"]))
            self.menu["ui"]["title"] hudFadeColor(color, 1);
    }
    
    self.menu["Main_Color"] = color;
    self SaveMenuTheme();
}

SmoothRainbowTheme()
{
    if(isDefined(self.SmoothRainbowTheme))
        return;
    self.SmoothRainbowTheme = true;
    
    self SaveMenuTheme();
    
    self endon("disconnect");
    self endon("EndSmoothRainbowTheme");
    
    while(isDefined(self.SmoothRainbowTheme))
    {
        hud = ["outlines", "scroller", "bannerQM"];

        for(a = 0; a < hud.size; a++)
        {
            if(isDefined(self.menu["ui"][hud[a]]))
            {
                if(IsArray(self.menu["ui"][hud[a]]))
                {
                    for(b = 0; b < self.menu["ui"][hud[a]].size; b++)
                    {
                        if(isDefined(self.menu["ui"][hud[a]][b]))
                            self.menu["ui"][hud[a]][b].color = level.RGBFadeColor;
                    }
                }
                else
                    self.menu["ui"][hud[a]].color = level.RGBFadeColor;
            }
        }
        
        if(isDefined(self.menu["ui"]["QMScroller"][1]))
            self.menu["ui"]["QMScroller"][1].color = level.RGBFadeColor;
        
        for(a = 0; a < self.menu["items"][self getCurrent()].name.size; a++)
            if(isDefined(self.menu["ui"]["BoolOpt"][a]) && isDefined(self.menu_B[self getCurrent()][a]) && self.menu_B[self getCurrent()][a] && self.menu["ToggleStyle"] != "Text")
                self.menu["ui"]["BoolOpt"][a].color = level.RGBFadeColor;
        
        if(self.menu["MenuDesign"] == "Old School" && !self isInQuickMenu())
        {
            if(isDefined(self.menu["ui"]["text"][self getCursor()]))
                self.menu["ui"]["text"][self getCursor()].color = (isDefined(self.menu["items"][self getCurrent()].bool[self getCursor()]) && isDefined(self.menu_B[self getCurrent()][self getCursor()]) && self.menu_B[self getCurrent()][self getCursor()] && self.menu["ToggleStyle"] == "Text Color") ? divideColor(0, 255, 0) : level.RGBFadeColor;

            if(isDefined(self.menu["ui"]["title"]))
                self.menu["ui"]["title"].color = level.RGBFadeColor;
        }
        
        self.menu["Main_Color"] = level.RGBFadeColor;
        
        wait 0.01;
    }
}

MenuDesign(design)
{
    if(self.menu["MenuDesign"] == design)
        return;
    
    self closeMenu1();

    self.menu["X"] = self.menu["DefaultX"];
    self.menu["Y"] = self.menu["DefaultY"];

    self.menu["MaxOptions"] = 12;
    self.menu["ToggleStyle"] = "Boxes";
    self.menu["LargeCursor"] = undefined;
    self.menu["MenuBlur"] = undefined;
    self.menu["MenuWidth"] = self.menu["DefaultWidth"];

    self.menu["MenuDesign"] = design;

    if(self.menu["MenuDesign"] == "Old School")
    {
        self.menu["X"] = 0;
        self.menu["Y"] = -180;

        self.menu["MaxOptions"] = 15;
        self.menu["ToggleStyle"] = "Text Color";
        self.menu["LargeCursor"] = true;
        self.menu["MenuBlur"] = true;
    }
    else if(self.menu["MenuDesign"] == "Right Side")
    {
        self.menu["X"] = 330;
        self.menu["Y"] = -125;
        
        self.menu["MenuWidth"] = 250;
    }

    self SaveMenuTheme();
    self openMenu1();
}

ToggleStyle(style)
{
    self.menu["ToggleStyle"] = style;
    self RefreshMenu();
    self SaveMenuTheme();
}

MenuMaxOptions(max)
{
    self.menu["MaxOptions"] = max;
    self RefreshMenu();
    self SaveMenuTheme();
}

DisableOptionCounter()
{
    self closeMenu1();
    self.menu["DisableOptionCounter"] = isDefined(self.menu["DisableOptionCounter"]) ? undefined : true;
    self SaveMenuTheme();
    self openMenu1();
}

MenuBlur()
{
    self.menu["MenuBlur"] = isDefined(self.menu["MenuBlur"]) ? undefined : true;
    self SetBlur(isDefined(self.menu["MenuBlur"]) ? self.menu["MenuBlurValue"] : 0, 0.1);
}

MenuBlurAmount(value)
{
    self.menu["MenuBlurValue"] = value;
}

DisableMenuInstructions()
{
    self.menu["DisableMenuInstructions"] = isDefined(self.menu["DisableMenuInstructions"]) ? undefined : true;
    self SaveMenuTheme();
}

LargeCursor()
{
    self.menu["LargeCursor"] = isDefined(self.menu["LargeCursor"]) ? undefined : true;
    self RefreshMenu();
    self SaveMenuTheme();
}

DisableQuickMenu()
{
    self.menu["DisableQM"] = isDefined(self.menu["DisableQM"]) ? undefined : true;
    self SaveMenuTheme();
}

SaveMenuTheme()
{
    design = self.menu["MenuDesign"] + ";" + self.menu["ToggleStyle"] + ";" + self.menu["X"] + ";" + self.menu["Y"] + ";" + self.menu["MenuWidth"] + ";" + self.menu["MaxOptions"] + ";" + self.menu["MenuBlurValue"] + ";";
    design += isDefined(self.menu["DisableOptionCounter"]) ? "Disable;" : "Enable;";
    design += isDefined(self.menu["DisableMenuInstructions"]) ? "Disable;" : "Enable;";
    design += isDefined(self.menu["LargeCursor"]) ? "Enable;" : "Disable;";
    design += isDefined(self.menu["MenuBlur"]) ? "Enable;" : "Disable;";
    design += isDefined(self.menu["DisableQM"]) ? "Enable;" : "Disable;";
    design += isDefined(self.SmoothRainbowTheme) ? "Rainbow" : self.menu["Main_Color"];
    
    SetDvar("MenuTheme" + self GetXUID(), design);
}

LoadMenuVars() //Pre-Set Menu Variables.
{
    self.menu["MenuDesign"] = level.menuName; //Current Choices: level.menuName, Right Side, Old School

    //If you change these, I recommend sticking to the min/max bounds
    self.menu["DefaultX"] = -290;
    self.menu["DefaultY"] = -150;
    self.menu["DefaultWidth"] = 210;

    //Quick Menu X/Y Variables
    self.menu["XQM"] = -1;
    self.menu["YQM"] = -161;
    self.menu["maxOptionsQM"] = 15;

    self.menu["MaxOptions"] = 12;

    self.menu["MenuWidthMin"] = 165;
    self.menu["MenuWidthMax"] = 450;
    
    self.menu["YMax"] = 154;
    self.menu["YMin"] = -135;

    self.menu["XMax"] = 217;
    self.menu["XMin"] = -427;

    self.menu["X"] = self.menu["DefaultX"];
    self.menu["Y"] = self.menu["DefaultY"];

    self.menu["ToggleStyle"] = "Boxes";
    self.menu["Main_Color"] = divideColor(255, 0, 0); //Default theme color
    self.menu["MenuBlurValue"] = 2.5; //Amount of blur applied when menu blur is enabled
    self.menu["MenuWidth"] = self.menu["DefaultWidth"];

    //Change 'true' to 'undefined' if you want to enable the option counter by default
    self.menu["DisableOptionCounter"] = true;

    //Change 'undefined' to 'true' if you want to disable the instructions by default
    self.menu["DisableMenuInstructions"] = undefined;

    //Change 'undefined' to 'true' if you want to enable menu blur by default
    self.menu["MenuBlur"] = undefined;

    //Change 'undefined' to 'true' if you want to disable the quick menu by default
    self.menu["DisableQM"] = undefined;

    if(self.menu["MenuDesign"] == "Old School")
    {
        self.menu["X"] = 0;
        self.menu["Y"] = -180;

        self.menu["MaxOptions"] = 15;
        self.menu["ToggleStyle"] = "Text Color"; //Do Not Change This
        self.menu["LargeCursor"] = true;
        self.menu["MenuBlur"] = true;
    }
    else if(self.menu["MenuDesign"] == "Right Side")
    {
        self.menu["X"] = 330;
        self.menu["Y"] = -125;

        self.menu["MenuWidth"] = 250;
    }

    //Loading Saved Menu Variables
    dvar = GetDvarString("MenuTheme" + self GetXUID());
    dvarSep = StrTok(dvar, ";");
    
    if(dvar != "" && (dvarSep[0] == level.menuName || dvarSep[0] == "Right Side" || dvarSep[0] == "Old School"))
    {
        self.menu["MenuDesign"] = dvarSep[0];        
        self.menu["ToggleStyle"] = dvarSep[1];
        self.menu["X"] = Int(dvarSep[2]);
        self.menu["Y"] = Int(dvarSep[3]);
        self.menu["MenuWidth"] = Int(dvarSep[4]);
        self.menu["MaxOptions"] = Int(dvarSep[5]);
        self.menu["MenuBlurValue"] = Float(dvarSep[6]);
        self.menu["DisableOptionCounter"] = (dvarSep[7] == "Disable") ? true : undefined;
        self.menu["DisableMenuInstructions"] = (dvarSep[8] == "Disable") ? true : undefined;
        self.menu["LargeCursor"] = (dvarSep[9] == "Enable") ? true : undefined;
        self.menu["MenuBlur"] = (dvarSep[10] == "Enable") ? true : undefined;
        self.menu["DisableQM"] = (dvarSep[11] == "Enable") ? true : undefined;
        
        if(dvarSep[12] == "Rainbow")
            self thread SmoothRainbowTheme();
        else
        {
            SetDvar(self GetXUID() + level.menuName + "Color", dvarSep[12]);
            self.menu["Main_Color"] = GetDvarVector1(self GetXUID() + level.menuName + "Color");
        }
    }
    else
    {
        self thread SmoothRainbowTheme(); //The color defaults to smooth rainbow. Remove this if you want the color to default to the self.menu["Main_Color"] variable.
        self SaveMenuTheme();
    }
}

//Decided to remake GetDvarVector
GetDvarVector1(var)
{
    dvar = "";
    var = GetDvarString(var);

    for(a = 1; a < var.size; a++)
        if(var[a] != " " && var[a] != ")")
            dvar += var[a];
    
    vals = [];
    toks = StrTok(dvar, ",");
    
    for(a = 0; a < toks.size; a++)
        vals[a] = Float(toks[a]);
    
    return (vals[0], vals[1], vals[2]);
}
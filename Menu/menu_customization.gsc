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
        
        self.menu["Main_Color"] = level.RGBFadeColor;
        
        wait 0.01;
    }
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
    design = level.menuName + ";" + self.menu["ToggleStyle"] + ";" + self.menu["MaxOptions"] + ";";
    design += isDefined(self.menu["DisableMenuInstructions"]) ? "Disable;" : "Enable;";
    design += isDefined(self.menu["LargeCursor"]) ? "Enable;" : "Disable;";
    design += isDefined(self.menu["MenuBlur"]) ? "Enable;" : "Disable;";
    design += isDefined(self.menu["DisableQM"]) ? "Enable;" : "Disable;";
    design += isDefined(self.SmoothRainbowTheme) ? "Rainbow" : self.menu["Main_Color"];
    
    SetDvar("MenuTheme" + self GetXUID(), design);
}

LoadMenuVars() //Pre-Set Menu Variables.
{
    self.menu["XQM"] = -1;
    self.menu["YQM"] = -161;

    self.menu["X"] = -290;
    self.menu["Y"] = -150;

    self.menu["MaxOptions"] = 12;
    self.menu["maxOptionsQM"] = 15;
    self.menu["ToggleStyle"] = "Boxes";
    self.menu["Main_Color"] = divideColor(255, 0, 0); //Default theme color
    self.menu["MenuBlurValue"] = 2.5; //Amount of blur applied when menu blur is enabled
    self.menu["MenuWidth"] = 210;

    //Change 'undefined' to 'true' if you want to disable the instructions by default
    self.menu["DisableMenuInstructions"] = undefined;

    //Change 'undefined' to 'true' if you want to enable menu blur by default
    self.menu["MenuBlur"] = undefined;

    //Change 'undefined' to 'true' if you want to disable the quick menu by default
    self.menu["DisableQM"] = undefined;

    //Loading Saved Menu Variables
    dvar = GetDvarString("MenuTheme" + self GetXUID());
    dvarSep = StrTok(dvar, ";");
    
    if(dvar != "" && dvarSep[0] == level.menuName)
    {
        self.menu["ToggleStyle"] = dvarSep[1];
        self.menu["MaxOptions"] = Int(dvarSep[2]);
        self.menu["DisableMenuInstructions"] = (dvarSep[3] == "Disable") ? true : undefined;
        self.menu["LargeCursor"] = (dvarSep[4] == "Enable") ? true : undefined;
        self.menu["MenuBlur"] = (dvarSep[5] == "Enable") ? true : undefined;
        self.menu["DisableQM"] = (dvarSep[6] == "Enable") ? true : undefined;
        
        if(dvarSep[7] == "Rainbow")
            self thread SmoothRainbowTheme();
        else
        {
            SetDvar(self GetXUID() + level.menuName + "Color", dvarSep[7]);
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
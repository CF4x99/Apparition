MenuTheme(color)
{
    self notify("EndSmoothRainbowTheme");
    self.SmoothRainbowTheme = undefined;
    
    hud = ["outlines"];

    if(self.menu["MenuStyle"] != "Nautaremake")
        hud[hud.size] = "scroller";

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
    
    wHud = (self.menu["MenuStyle"] == "Nautaremake") ? "BoolBack" : "BoolOpt";
        
    for(a = 0; a < self.menu["items"][self getCurrent()].name.size; a++)
        if(isDefined(self.menu["ui"][wHud][a]) && (isDefined(self.menu_B[self getCurrent()][a]) && self.menu_B[self getCurrent()][a] || self.menu["MenuStyle"] == "Nautaremake") && self.menu["ToggleStyle"] != "Text")
            self.menu["ui"][wHud][a].color hudFadeColor(color, 1);
    
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
        hud = ["outlines", "bannerQM"];

        if(self.menu["MenuStyle"] != "Nautaremake")
            hud[hud.size] = "scroller";

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
        
        wHud = (self.menu["MenuStyle"] == "Nautaremake") ? "BoolBack" : "BoolOpt";
        
        for(a = 0; a < self.menu["items"][self getCurrent()].name.size; a++)
            if(isDefined(self.menu["ui"][wHud][a]) && (isDefined(self.menu_B[self getCurrent()][a]) && self.menu_B[self getCurrent()][a] || self.menu["MenuStyle"] == "Nautaremake") && self.menu["ToggleStyle"] != "Text")
                self.menu["ui"][wHud][a].color = level.RGBFadeColor;
        
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

DisableMenuAnimations()
{
    self.menu["DisableMenuAnimations"] = isDefined(self.menu["DisableMenuAnimations"]) ? undefined : true;
    self SaveMenuTheme();
}

MenuStyle(style)
{
    if(self.menu["MenuStyle"] == style)
        return;
    
    self closeMenu1();

    self.menu["MenuStyle"] = style;

    switch(style)
    {
        case level.menuName:
            self.menu["Y"] = -150;
            self.menu["MaxOptions"] = 12;
            break;
        
        case "Nautaremake":
            self.menu["Y"] = -100;
            self.menu["MaxOptions"] = 9;
            break;
        
        default:
            break;
    }

    self openMenu1();
    self SaveMenuTheme();
}

SaveMenuTheme()
{
    design = self.menu["MenuStyle"] + ";" + self.menu["ToggleStyle"] + ";" + self.menu["MaxOptions"] + ";" + self.menu["Y"] + ";";
    design += isDefined(self.menu["DisableMenuInstructions"]) ? "Disable;" : "Enable;";
    design += isDefined(self.menu["LargeCursor"]) ? "Enable;" : "Disable;";
    design += isDefined(self.menu["DisableQM"]) ? "Enable;" : "Disable;";
    design += isDefined(self.menu["DisableMenuAnimations"]) ? "Enable;" : "Disable;";
    design += isDefined(self.SmoothRainbowTheme) ? "Rainbow" : self.menu["Main_Color"];
    
    SetDvar("MenuTheme" + self GetXUID(), design);
}

LoadMenuVars() //Pre-Set Menu Variables.
{
    self.menu["MenuStyle"] = level.menuName;

    self.menu["XQM"] = -1;
    self.menu["YQM"] = -161;

    self.menu["X"] = -301;
    self.menu["Y"] = (self.menu["MenuStyle"] == "Nautaremake") ? -100 : -150;

    self.menu["MaxOptions"] = (self.menu["MenuStyle"] == "Nautaremake") ? 9 : 12;
    self.menu["maxOptionsQM"] = 15;
    self.menu["ToggleStyle"] = "Boxes";
    self.menu["Main_Color"] = divideColor(255, 0, 0); //Default theme color
    self.menu["Alt_Color"] = divideColor(45, 45, 45);
    self.menu["MenuWidth"] = 210;

    //Change 'undefined' to 'true' if you want to disable the instructions by default
    self.menu["DisableMenuInstructions"] = undefined;

    //Change 'undefined' to 'true' if you want to disable the quick menu by default
    self.menu["DisableQM"] = undefined;

    //Change 'undefined' to 'true' if you want to disable the menu open/close animations
    self.menu["DisableMenuAnimations"] = undefined;

    //Loading Saved Menu Variables
    dvar = GetDvarString("MenuTheme" + self GetXUID());
    
    if(dvar != "")
    {
        dvarSep = StrTok(dvar, ";");

        self.menu["MenuStyle"] = dvarSep[0];
        self.menu["ToggleStyle"] = dvarSep[1];
        self.menu["MaxOptions"] = Int(dvarSep[2]);
        self.menu["Y"] = Int(dvarSep[3]);
        self.menu["DisableMenuInstructions"] = (dvarSep[4] == "Disable") ? true : undefined;
        self.menu["LargeCursor"] = (dvarSep[5] == "Enable") ? true : undefined;
        self.menu["DisableQM"] = (dvarSep[6] == "Enable") ? true : undefined;
        self.menu["DisableMenuAnimations"] = (dvarSep[7] == "Enable") ? true : undefined;
        
        if(dvarSep[8] == "Rainbow")
            self thread SmoothRainbowTheme();
        else
        {
            SetDvar(self GetXUID() + level.menuName + "Color", dvarSep[8]);
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
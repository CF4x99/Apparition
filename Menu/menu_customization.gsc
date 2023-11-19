MenuTheme(color)
{
    self notify("EndSmoothRainbowTheme");
    self.SmoothRainbowTheme = undefined;
    
    hud = ["outlines"];

    if(self.menu["MenuStyle"] != "Nautaremake")
        hud[hud.size] = "scroller";
    
    if(self.menu["MenuStyle"] == "Zodiac" && !self isInQuickMenu())
        hud[hud.size] = "title";

    for(a = 0; a < hud.size; a++)
    {
        if(isDefined(self.menu["ui"][hud[a]]))
        {
            if(IsArray(self.menu["ui"][hud[a]]))
            {
                for(b = 0; b < self.menu["ui"][hud[a]].size; b++)
                {
                    if(self.menu["MenuStyle"] == "Native" && hud[a] == "outlines" && b)
                        continue;
                    
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
            self.menu["ui"][wHud][a] hudFadeColor(color, 1);
    
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
        
        if(self.menu["MenuStyle"] == "Zodiac" && !self isInQuickMenu())
            hud[hud.size] = "title";

        for(a = 0; a < hud.size; a++)
        {
            if(isDefined(self.menu["ui"][hud[a]]))
            {
                if(IsArray(self.menu["ui"][hud[a]]))
                {
                    for(b = 0; b < self.menu["ui"][hud[a]].size; b++)
                    {
                        if(self.menu["MenuStyle"] == "Native" && hud[a] == "outlines" && b)
                            continue;

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

MenuScrollingBuffer(buffer)
{
    self.menu["ScrollingBuffer"] = buffer;
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

DisableMenuSounds()
{
    self.menu["DisableMenuSounds"] = isDefined(self.menu["DisableMenuSounds"]) ? undefined : true;
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
        case "Zodiac":
            self.menu["X"] = 298;
            self.menu["MenuWidth"] = 262;
            self.menu["MaxOptions"] = 12; //Uses Less Hud, So We Can Show A Few More Options
            self.menu["LargeCursor"] = true;
            break;
        
        default:
            self.menu["X"] = -301;
            self.menu["MenuWidth"] = 210;
            self.menu["MaxOptions"] = 9;
            self.menu["LargeCursor"] = undefined;
            break;
    }

    resolution = StrTok(GetDvarString("r_mode"), "x");
    diff = (Int(resolution[0]) - Int(resolution[1]));

    if(diff < 550 && diff > 260)
        self.menu["X"] += (self.menu["X"] > 0) ? -44 : 44;
    else if(diff <= 260)
        self.menu["X"] += (self.menu["X"] > 0) ? -106 : 106;

    self openMenu1();
    self SaveMenuTheme();
}

SaveMenuTheme()
{
    design = self.menu["MenuStyle"] + ";" + self.menu["ToggleStyle"] + ";" + self.menu["MaxOptions"] + ";" + self.menu["ScrollingBuffer"] + ";" + self.menu["X"] + ";" + self.menu["MenuWidth"] + ";";
    design += isDefined(self.menu["DisableMenuInstructions"]) ? "Disable;" : "Enable;";
    design += isDefined(self.menu["LargeCursor"]) ? "Enable;" : "Disable;";
    design += isDefined(self.menu["DisableQM"]) ? "Enable;" : "Disable;";
    design += isDefined(self.menu["DisableMenuAnimations"]) ? "Enable;" : "Disable;";
    design += isDefined(self.menu["DisableMenuSounds"]) ? "Enable;" : "Disable;";
    
    SetDvar("MenuTheme" + self GetXUID(), design);
    SetDvar(self GetXUID() + "Color", isDefined(self.SmoothRainbowTheme) ? "Rainbow" : self.menu["Main_Color"]);
}

LoadMenuVars() //Pre-Set Menu Variables.
{
    self.menu["MenuStyle"] = level.menuName;

    self.menu["XQM"] = -1;
    self.menu["YQM"] = -161;

    self.menu["X"] = (self.menu["MenuStyle"] == "Zodiac") ? 298 : -301;

    resolution = StrTok(GetDvarString("r_mode"), "x");
    diff = (Int(resolution[0]) - Int(resolution[1]));

    if(diff < 550 && diff > 260)
        self.menu["X"] += (self.menu["X"] > 0) ? -44 : 44;
    else if(diff <= 260)
        self.menu["X"] += (self.menu["X"] > 0) ? -106 : 106;
    
    self.menu["Y"] = -185;

    self.menu["MaxOptions"] = 9;
    self.menu["maxOptionsQM"] = 15;
    self.menu["ScrollingBuffer"] = 12;
    self.menu["ToggleStyle"] = "Boxes";
    self.menu["Main_Color"] = divideColor(255, 0, 0); //Default theme color
    self.menu["Alt_Color"] = divideColor(45, 45, 45);
    self.menu["MenuWidth"] = (self.menu["MenuStyle"] == "Zodiac") ? 262 : 210;

    //Change 'undefined' to 'true' if you want to disable the instructions by default
    self.menu["DisableMenuInstructions"] = undefined;

    //Change 'undefined' to 'true' if you want to disable the quick menu by default
    self.menu["DisableQM"] = undefined;

    //Change 'undefined' to 'true' if you want to disable the menu open/close animations by default
    self.menu["DisableMenuAnimations"] = undefined;

    //Change 'undefined' to 'true' if you want to disable the menu sounds by default
    self.menu["DisableMenuSounds"] = undefined;
    
    //Change 'undefined' to 'true' if you want to enable large cursor by default
    self.menu["LargeCursor"] = (self.menu["MenuStyle"] == "Zodiac") ? true : undefined;

    //Loading Saved Menu Variables
    dvar = GetDvarString("MenuTheme" + self GetXUID());
    
    if(dvar != "")
    {
        dvarSep = StrTok(dvar, ";");

        self.menu["MenuStyle"] = dvarSep[0];
        self.menu["ToggleStyle"] = dvarSep[1];
        self.menu["MaxOptions"] = Int(dvarSep[2]);
        self.menu["ScrollingBuffer"] = Int(dvarSep[3]);
        self.menu["X"] = Int(dvarSep[4]);
        self.menu["MenuWidth"] = Int(dvarSep[5]);
        self.menu["DisableMenuInstructions"] = (dvarSep[6] == "Disable") ? true : undefined;
        self.menu["LargeCursor"] = (dvarSep[7] == "Enable") ? true : undefined;
        self.menu["DisableQM"] = (dvarSep[8] == "Enable") ? true : undefined;
        self.menu["DisableMenuAnimations"] = (dvarSep[9] == "Enable") ? true : undefined;
        self.menu["DisableMenuSounds"] = (dvarSep[10] == "Enable") ? true : undefined;

        dColor = GetDvarString(self GetXUID() + "Color");
        
        if(dColor == "Rainbow")
            self thread SmoothRainbowTheme();
        else
            self.menu["Main_Color"] = GetDvarVector1(self GetXUID() + "Color");
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
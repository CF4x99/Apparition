createMenuHud()
{
    switch(self.MenuDesign)
    {
        case "Classic":
            self ClassicHud();
            break;
        
        case "Native":
            self NativeHud();
            break;
        
        case "AIO":
            self AIOHud();
            break;
        
        default:
            self ApparitionHud();
            break;
    }
}

/*
    I know the original way I was doing multiple designs was confusing and hard to understand...
    Hopefully with everything setup like this, it should make it a little easier in case anyone wants to make edits
*/

ApparitionHud()
{
    self.menuUI["background"] = self createRectangle("TOP_LEFT", "CENTER", self.menuX, self.menuY, self.MenuWidth, 300, (25, 25, 25), 3, 0.5, "white");
    self.menuUI["banner"] = self createRectangle("TOP_LEFT", "CENTER", self.menuUI["background"].x, (self.menuUI["background"].y - 20), self.MenuWidth, (self.menuUI["background"].height + 20), (55, 55, 55), 2, 1, "white");
    self.menuUI["separator"] = self createRectangle("TOP_LEFT", "CENTER", self.menuUI["background"].x, (self.menuUI["background"].y - 1), self.MenuWidth, 1, self.MainTheme, 5, 1, "white");
    self.menuUI["bottomLine"] = self createRectangle("TOP_LEFT", "CENTER", self.menuUI["background"].x, (self.menuUI["background"].y + self.menuUI["background"].height), self.MenuWidth, 1, self.MainTheme, 5, 1, "white");
    self.menuUI["scroller"] = self createRectangle("TOP_LEFT", "CENTER", self.menuUI["background"].x, self.menuUI["background"].y, self.MenuWidth, 18, (55, 55, 55), 4, 1, "white");

    self.menuUI["title"] = self createText("default", 1.5, 7, "", "CENTER", "CENTER", self.menuUI["background"].x + (self.menuUI["background"].width / 2), (self.menuUI["banner"].y + 8), 1, self.MainTheme);

    if(Is_True(self.OptionCounter))
    {
        self.menuUI["counterSep"] = self createText("default", 1, 7, "/", "CENTER", "CENTER", (self.menuUI["background"].x + (self.menuUI["background"].width - 16)), (self.menuUI["title"].y + 8), 0.7, (255, 255, 255));
        self.menuUI["cursIndex"] = self createText("default", 1, 7, 0, "RIGHT", "CENTER", (self.menuUI["counterSep"].x - 3), self.menuUI["counterSep"].y, 0.7, (255, 255, 255));
        self.menuUI["optCount"] = self createText("default", 1, 7, 0, "LEFT", "CENTER", (self.menuUI["counterSep"].x + 3), self.menuUI["counterSep"].y, 0.7, (255, 255, 255));
    }
}

ClassicHud()
{
    self.menuUI["background"] = self createRectangle("TOP_LEFT", "CENTER", self.menuX, self.menuY, self.MenuWidth, 300, (25, 25, 25), 3, 0.92, "white");
    self.menuUI["banner"] = self createRectangle("TOP_LEFT", "CENTER", (self.menuUI["background"].x - 1), (self.menuUI["background"].y - 13), (self.MenuWidth + 2), (self.menuUI["background"].height + 14), self.MainTheme, 2, 1, "white");
    self.menuUI["scroller"] = self createRectangle("TOP_LEFT", "CENTER", self.menuUI["background"].x, self.menuUI["background"].y, self.MenuWidth, 18, self.MainTheme, 4, 1, "white");

    self.menuUI["title"] = self createText("default", 1.2, 7, "", "LEFT", "CENTER", (self.menuUI["background"].x + 4), (self.menuUI["banner"].y + 6), 1, (255, 255, 255));

    if(Is_True(self.OptionCounter))
    {
        self.menuUI["counterSep"] = self createText("default", 1, 7, "/", "CENTER", "CENTER", (self.menuUI["background"].x + (self.menuUI["background"].width - 16)), self.menuUI["title"].y, 1, (255, 255, 255));
        self.menuUI["cursIndex"] = self createText("default", 1, 7, 0, "RIGHT", "CENTER", (self.menuUI["counterSep"].x - 3), self.menuUI["counterSep"].y, 1, (255, 255, 255));
        self.menuUI["optCount"] = self createText("default", 1, 7, 0, "LEFT", "CENTER", (self.menuUI["counterSep"].x + 3), self.menuUI["counterSep"].y, 1, (255, 255, 255));
    }
}

NativeHud()
{
    self.menuUI["background"] = self createRectangle("TOP_LEFT", "CENTER", self.menuX, self.menuY, self.MenuWidth, 300, (25, 25, 25), 3, 0.45, "white");
    self.menuUI["separator"] = self createRectangle("TOP_LEFT", "CENTER", self.menuUI["background"].x, (self.menuUI["background"].y - 17), self.MenuWidth, 17, (0, 0, 0), 5, 1, "white");
    self.menuUI["banner"] = self createRectangle("TOP_LEFT", "CENTER", self.menuUI["background"].x, (self.menuUI["separator"].y - 38), self.MenuWidth, 38, self.MainTheme, 2, 0.9, "white");
    self.menuUI["scroller"] = self createRectangle("TOP_LEFT", "CENTER", self.menuUI["background"].x, self.menuUI["background"].y, self.MenuWidth, 18, self.MainTheme, 4, 0.7, "white");

    self.menuUI["title"] = self createText("default", 1, 7, "", "LEFT", "CENTER", (self.menuUI["background"].x + 4), ((self.menuUI["separator"].y + (self.menuUI["separator"].height / 2)) - 1), 0.7, (255, 255, 255));
    self.menuUI["menuName"] = self createText("default", 1.6, 7, GetMenuName(), "CENTER", "CENTER", (self.menuUI["background"].x + (self.menuUI["background"].width / 2)), (self.menuUI["banner"].y + (self.menuUI["banner"].height / 2)), 1, (255, 255, 255));

    if(Is_True(self.OptionCounter))
    {
        self.menuUI["counterSep"] = self createText("default", 1, 7, "/", "CENTER", "CENTER", (self.menuUI["background"].x + (self.menuUI["background"].width - 16)), self.menuUI["title"].y, 0.7, (255, 255, 255));
        self.menuUI["cursIndex"] = self createText("default", 1, 7, 0, "RIGHT", "CENTER", (self.menuUI["counterSep"].x - 3), self.menuUI["counterSep"].y, 0.7, (255, 255, 255));
        self.menuUI["optCount"] = self createText("default", 1, 7, 0, "LEFT", "CENTER", (self.menuUI["counterSep"].x + 3), self.menuUI["counterSep"].y, 0.7, (255, 255, 255));
    }
}

AIOHud()
{
    self.menuUI["background"] = self createRectangle("TOP_LEFT", "CENTER", self.menuX, self.menuY, self.MenuWidth, 300, (0, 0, 0), 3, 0.45, "white");
    self.menuUI["separator"] = self createRectangle("TOP_LEFT", "CENTER", self.menuUI["background"].x, (self.MenuUI["background"].y - 25), self.MenuWidth, 25, self.MainTheme, 5, 1, "white");
    self.menuUI["bottomLine"] = self createRectangle("TOP_LEFT", "CENTER", self.menuUI["background"].x, (self.menuUI["background"].y + self.menuUI["background"].height), self.MenuWidth, 25, self.MainTheme, 5, 1, "white");
    self.menuUI["backgroundouter"] = self createRectangle("TOP_LEFT", "CENTER", (self.menuUI["background"].x - 2), (self.menuUI["separator"].y - 2), (self.MenuWidth + 4), (4 + (self.menuUI["background"].height + self.menuUI["separator"].height + self.menuUI["bottomLine"].height)), (0, 0, 0), 1, 0.3, "white");
    self.menuUI["scroller"] = self createRectangle("TOP_LEFT", "CENTER", self.menuUI["background"].x, self.menuUI["background"].y, 2, 23, self.MainTheme, 4, 1, "white");

    self.menuUI["title"] = self createText("default", 1.4, 7, "", "LEFT", "CENTER", (self.menuUI["background"].x + 4), (self.menuUI["separator"].y + ((self.menuUI["separator"].height / 2) - 1)), 1, (255, 255, 255));
    self.menuUI["menuName"] = self createText("default", 1.4, 7, "Status: " + self.accessLevel, "LEFT", "CENTER", (self.menuUI["background"].x + 2), (self.menuUI["bottomLine"].y + ((self.menuUI["bottomLine"].height / 2) - 1)), 1, (255, 255, 255));
}
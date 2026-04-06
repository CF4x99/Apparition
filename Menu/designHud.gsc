createMenuHud()
{
    switch(self.MenuDesign)
    {
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
    self.menuUI["background"] = self createRectangle("TOP_LEFT", "CENTER", self.menuX, (self.menuY + 20), self.MenuWidth, 300, (25, 25, 25), 3, 0.5, "white");
    self.menuUI["banner"] = self createRectangle("TOP_LEFT", "CENTER", self.menuX, self.menuY, self.MenuWidth, (self.menuUI["background"].height + 20), (50, 50, 50), 2, 1, "white");
    self.menuUI["separator"] = self createRectangle("TOP_LEFT", "CENTER", self.menuX, (self.menuY + 20), self.MenuWidth, 1, self.MainTheme, 5, 1, "white");
    self.menuUI["bottomLine"] = self createRectangle("TOP_LEFT", "CENTER", self.menuX, (self.menuY + self.menuUI["background"].height), self.MenuWidth, 1, self.MainTheme, 5, 1, "white");
    self.menuUI["scroller"] = self createRectangle("TOP_LEFT", "CENTER", self.menuX, (self.menuUI["background"].y + 1), self.MenuWidth, 18, (50, 50, 50), 4, 1, "white");

    self.menuUI["title"] = self createText("default", 1.5, 5, "", "CENTER", "CENTER", self.menuX + (self.menuUI["background"].width / 2), (self.menuY + 8), 1, self.MainTheme);
}

NativeHud()
{
    self.menuUI["background"] = self createRectangle("TOP_LEFT", "CENTER", self.menuX, (self.menuY + 5), self.MenuWidth, 300, (25, 25, 25), 3, 0.45, "white");
    self.menuUI["banner"] = self createRectangle("TOP_LEFT", "CENTER", self.menuX, (self.menuY - 50), self.MenuWidth, 39, self.MainTheme, 2, 1, "white");
    self.menuUI["separator"] = self createRectangle("TOP_LEFT", "CENTER", self.menuX, (self.menuY - 11), self.MenuWidth, 17, (0, 0, 0), 5, 1, "white");
    self.menuUI["scroller"] = self createRectangle("TOP_LEFT", "CENTER", self.menuX, (self.menuUI["background"].y + 1), self.MenuWidth, 18, self.MainTheme, 4, 1, "white");

    self.menuUI["title"] = self createText("default", 1.2, 7, "", "LEFT", "CENTER", self.menuX + 4, (self.menuY - 3), 1, (1, 1, 1));
    self.menuUI["menuName"] = self createText("default", 1.6, 7, GetMenuName(), "CENTER", "CENTER", self.menuX + (self.menuUI["background"].width / 2), (self.menuY - 31), 1, (1, 1, 1));
}

AIOHud()
{
    self.menuUI["background"] = self createRectangle("TOP_LEFT", "CENTER", self.menuX, (self.menuY - 5), self.MenuWidth, 300, (0, 0, 0), 3, 0.45, "white");
    self.menuUI["backgroundouter"] = self createRectangle("TOP_LEFT", "CENTER", self.menuX - 2, (self.menuY - 27), self.MenuWidth + 4, 300, (0, 0, 0), 1, 0.3, "white");
    self.menuUI["separator"] = self createRectangle("TOP_LEFT", "CENTER", self.menuX, (self.menuY - 25), self.MenuWidth, 25, self.MainTheme, 5, 1, "white");
    self.menuUI["bottomLine"] = self createRectangle("TOP_LEFT", "CENTER", self.menuX, ((self.menuY + self.menuUI["background"].height) + 4), self.MenuWidth, 25, self.MainTheme, 5, 1, "white");
    self.menuUI["scroller"] = self createRectangle("TOP_LEFT", "CENTER", self.menuX, (self.menuUI["background"].y + 1), 2, 20, self.MainTheme, 4, 1, "white");

    self.menuUI["title"] = self createText("default", 1.4, 7, "", "LEFT", "CENTER", self.menuX + 4, (self.menuY - 13), 1, (1, 1, 1));
    self.menuUI["menuName"] = self createText("default", 1.4, 7, "Status: " + self.accessLevel, "LEFT", "CENTER", self.menuX + 2, (self.menuY - 13), 1, (1, 1, 1));
}
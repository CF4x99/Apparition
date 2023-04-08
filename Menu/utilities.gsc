createText(font, fontSize, sort, text, align, relative, x, y, alpha, color)
{
    textElem = self hud::CreateFontString(font, fontSize);

    textElem.hideWhenInMenu = true;
    textElem.archived = false;
    textElem.foreground = true;

    textElem.sort = sort;
    textElem.alpha = alpha;
    textElem.color = color;

    textElem hud::SetPoint(align, relative, x, y);
    textElem SetText(text);
    
    return textElem;
}

LUI_createText(text, align, x, y, width, color)
{    
    textElem = self OpenLUIMenu("HudElementText");

    //0 - LEFT | 1 - RIGHT | 2 - CENTER
    self SetLUIMenuData(textElem, "text", text);
    self SetLUIMenuData(textElem, "alignment", align);
    self SetLUIMenuData(textElem, "x", x);
    self SetLUIMenuData(textElem, "y", y);
    self SetLUIMenuData(textElem, "width", width);
    
    self SetLUIMenuData(textElem, "red", color[0]);
    self SetLUIMenuData(textElem, "green", color[1]);
    self SetLUIMenuData(textElem, "blue", color[2]);

    return textElem;
}

createServerText(font, fontSize, sort, text, align, relative, x, y, alpha, color)
{
    textElem = hud::CreateServerFontString(font, fontSize);

    textElem.hideWhenInMenu = true;
    textElem.archived = true;
    textElem.foreground = true;

    textElem.sort = sort;
    textElem.alpha = alpha;
    textElem.color = color;

    textElem hud::SetPoint(align, relative, x, y);
    textElem SetText(text);
    
    return textElem;
}

createRectangle(align, relative, x, y, width, height, color, sort, alpha, shader)
{
    uiElement = NewClientHudElem(self);
    uiElement.elemType = "bar";
    uiElement.children = [];
    
    uiElement.hideWhenInMenu = true;
    uiElement.archived = true;
    uiElement.foreground = true;
    uiElement.hidden = false;

    uiElement.align = align;
    uiElement.relative = relative;
    uiElement.xOffset = 0;
    uiElement.yOffset = 0;
    uiElement.sort = sort;
    uiElement.color = color;
    uiElement.alpha = alpha;
    
    uiElement SetShaderValues(shader, width, height);
    uiElement hud::SetParent(level.uiParent);
    uiElement hud::SetPoint(align, relative, x, y);
    
    return uiElement;
}

LUI_createRectangle(align, x, y, width, height, color, alpha, shader)
{
    uiElement = self OpenLUIMenu("HudElementImage");

    //0 - LEFT | 1 - RIGHT | 2 - CENTER
    self SetLUIMenuData(uiElement, "alignment", align);
    self SetLUIMenuData(uiElement, "x", x);
    self SetLUIMenuData(uiElement, "y", y);
    self SetLUIMenuData(uiElement, "width", width);
    self SetLUIMenuData(uiElement, "height", height);

    self SetLUIMenuData(uiElement, "red", color[0]);
    self SetLUIMenuData(uiElement, "green", color[1]);
    self SetLUIMenuData(uiElement, "blue", color[2]);

    self SetLUIMenuData(uiElement, "alpha", alpha);
    self SetLUIMenuData(uiElement, "material", shader);

    return uiElement;
}

createServerRectangle(align, relative, x, y, width, height, color, sort, alpha, shader)
{
    uiElement = NewHudElem();
    uiElement.elemType = "bar";
    uiElement.children = [];
    
    uiElement.hideWhenInMenu = false;
    uiElement.archived = true;
    uiElement.foreground = true;
    uiElement.hidden = false;

    uiElement.align = align;
    uiElement.relative = relative;
    uiElement.xOffset = 0;
    uiElement.yOffset = 0;
    uiElement.sort = sort;
    uiElement.color = color;
    uiElement.alpha = alpha;
    
    uiElement SetShaderValues(shader, width, height);
    uiElement hud::SetParent(level.uiParent);
    uiElement hud::SetPoint(align, relative, x, y);
    
    return uiElement;
}

SetShaderValues(shader, width, height)
{
    self.shader = shader;
    self.width = width;
    self.height = height;

    self SetShader(shader, width, height);
}

hudMoveY(y, time)
{
    self MoveOverTime(time);
    self.y = y;

    wait time;
}

hudMoveX(x, time)
{
    self MoveOverTime(time);
    self.x = x;

    wait time;
}

hudMoveXY(x, y, time)
{
    self MoveOverTime(time);
    self.x = x;
    self.y = y;

    wait time;
}

hudFade(alpha, time)
{
    self FadeOverTime(time);
    self.alpha = alpha;

    wait time;
}

hudFadenDestroy(alpha, time)
{
    self hudFade(alpha, time);
    self destroy();
}

hudFadeColor(color, time)
{
    self FadeOverTime(time);
    self.color = color;
}

HudRGBFade()
{
    if(isDefined(self.RGBFade))
        return;
    self.RGBFade = true;

    level endon("stop_intermission"); //For custom end game hud

    while(isDefined(self) && isDefined(self.RGBFade))
    {
        self.color = level.RGBFadeColor;
        
        wait 0.01;
    }
}

ChangeFontscaleOverTime1(scale, time)
{
    self ChangeFontscaleOverTime(time);
    self.fontScale = scale;
}

divideColor(c1, c2, c3)
{
    return ((c1 / 255), (c2 / 255), (c3 / 255));
}

hudScaleOverTime(time, width, height)
{
    self ScaleOverTime(time, width, height);

    self.width = width;
    self.height = height;

    wait time;
}

destroyAll(array)
{
    if(!isDefined(array))
        return;
    
    keys = GetArrayKeys(array);

    for(a = 0; a < keys.size; a++)
        if(IsArray(array[keys[a]]))
        {
            foreach(value in array[keys[a]])
                if(isDefined(value))
                    value destroy();
        }
        else
            if(isDefined(array[keys[a]]))
                array[keys[a]] destroy();
}

getName()
{
    name = self.name;

    if(name[0] != "[")
        return name;

    for(a = (name.size - 1); a >= 0; a--)
        if(name[a] == "]")
            break;

    return GetSubStr(name, (a + 1));
}

GetPlayerFromEntityNumber(number)
{
    foreach(player in level.players)
        if(player GetEntityNumber() == number)
            return player;
}

destroyAfter(time)
{
    wait time;

    if(isDefined(self))
        self destroy();
}

isInMenu()
{
    return isDefined(self.menuState["isInMenu"]);
}

isInArray(array, text)
{
    for(a = 0; a < array.size; a++)
        if(array[a] == text)
            return true;

    return false;
}

ArrayRemove(array, value)
{
    if(!isDefined(array) || !isDefined(value))
        return;
    
    newArray = [];

    for(a = 0; a < array.size; a++)
        if(array[a] != value)
            newArray[newArray.size] = array[a];

    return newArray;
}

getCurrent()
{
    return self.menu["currentMenu"];
}

getCursor()
{
    return self.menu["curs"][self getCurrent()];
}

setCursor(curs)
{
    self.menu["curs"][self getCurrent()] = curs;
}

SetSlider(dir)
{
    menu = self getCurrent();
    curs = self getCursor();
    max = (self.menu_S[menu][curs].size - 1);
    
    self.menu_SS[menu][curs] += (dir > 0) ? 1 : -1;
    
    if((self.menu_SS[menu][curs] > max) || (self.menu_SS[menu][curs] < 0))
        self.menu_SS[menu][curs] = (self.menu_SS[menu][curs] > max) ? 0 : max;
    
    if(isDefined(self.menu["ui"]["StringSlider"][curs]))
        self.menu["ui"]["StringSlider"][curs] SetText("< " + self.menu_S[menu][curs][self.menu_SS[menu][curs]] + " > [" + (self.menu_SS[menu][curs] + 1) + "/" + self.menu_S[menu][curs].size + "]");
    else
        self.menu["ui"]["text"][curs] SetText("< " + self.menu_S[menu][curs][self.menu_SS[menu][curs]] + " > [" + (self.menu_SS[menu][curs] + 1) + "/" + self.menu_S[menu][curs].size + "]");
}

SetIncSlider(dir)
{
    menu = self getCurrent();
    curs = self getCursor();
    
    inc = self.menu["items"][menu].intincrement[curs];
    max = self.menu["items"][menu].incslidermax[curs];
    min = self.menu["items"][menu].incslidermin[curs];
    
    if((self.menu_SS[menu][curs] < max) && (self.menu_SS[menu][curs] + inc) > max || (self.menu_SS[menu][curs] > min) && (self.menu_SS[menu][curs] - inc) < min)
        self.menu_SS[menu][curs] = ((self.menu_SS[menu][curs] < max) && (self.menu_SS[menu][curs] + inc) > max) ? max : min;
    else
        self.menu_SS[menu][curs] += (dir > 0) ? inc : (inc * -1);
    
    if((self.menu_SS[menu][curs] > max) || (self.menu_SS[menu][curs] < min))
        self.menu_SS[menu][curs] = (self.menu_SS[menu][curs] > max) ? min : max;
    
    if(isDefined(self.menu["ui"]["IntSlider"][curs]))
        self.menu["ui"]["IntSlider"][curs] SetText("< " + self.menu_SS[menu][curs] + " >");
    else
        self.menu["ui"]["text"][curs] SetText("< " + self.menu_SS[menu][curs] + " >");
}

newMenu(menu, dontSave, i1)
{
    self notify("EndSwitchWeaponMonitor");
    self endon("menuClosed");
    
    if(!isDefined(menu))
    {
        menu = self BackMenu();
        self.menuParent[(self.menuParent.size - 1)] = undefined;
    }
    else
    {
        if(!isDefined(dontSave) || isDefined(dontSave) && !dontSave)
        {
            self.menuParent[self.menuParent.size] = self getCurrent();
            self MenuArrays(self BackMenu());
        }
    }
    
    self.menu["currentMenu"] = menu;

    if(IsSubStr(menu, "Weapon Options")) //Submenus that should be refreshed when player switches weapons
    {
        tokens = StrTok(menu, " ");

        player = GetPlayerFromEntityNumber(Int(tokens[(tokens.size - 1)]));
        player thread WatchMenuWeaponSwitch(self);
    }

    if(isDefined(i1))
        self.EntityEditorNumber = i1;
    
    self DestroyOpts();
    self drawText();
    self SetMenuTitle();
}

WatchMenuWeaponSwitch(player)
{
    player endon("disconnect");
    player endon("menuClosed");
    player endon("EndSwitchWeaponMonitor");
    
    while(IsSubStr(player getCurrent(), "Weapon Options"))
    {
        self waittill("weapon_change", newWeapon);
        
        if(IsSubStr(player getCurrent(), "Weapon Options"))
            player RefreshMenu(player getCurrent(), player getCursor(), true);
    }
}

BackMenu()
{
    return self.menuParent[(self.menuParent.size - 1)];
}

isConsole()
{
    return level.console;
}

disconnect()
{
    ExitLevel(false);
}

CleanString(string)
{
    if(string[0] == ToUpper(string[0]))
        if(IsSubStr(string, " ") && !IsSubStr(string, "_"))
            return string;
    
    string = StrTok(ToLower(string), "_");
    str = "";
    
    for(a = 0; a < string.size; a++)
    {
        strings = ["specialty", "zombie", "zm", "t7", "t6", "p7", "zmb", "zod", "ai", "g", "bg", "perk", "player", "weapon", "wpn", "aat", "bgb", "visionset", "equip", "craft", "der", "viewmodel", "mod", "fxanim", "moo", "moon", "zmhd", "fb", "bc", "asc", "vending"];
        
        if(!isInArray(strings, string[a]))
        {
            for(b = 0; b < string[a].size; b++)
                if(b != 0)
                    str += string[a][b];
                else
                    str += ToUpper(string[a][b]);
            
            if(a != (string.size - 1))
                str += " ";
        }
    }
    
    return str;
}

CleanName(name)
{
    if(!isDefined(name) || name == "")
        return;
    
    colors = ["^0", "^1", "^2", "^3", "^4", "^5", "^6", "^7", "^8", "^9", "^H", "^B"];
    string = "";

    for(a = 0; a < name.size; a++)
        if(name[a] == "^" && isInArray(colors, name[a] + name[(a + 1)]))
            a++;
        else
            string += name[a];
    
    return string;
}

CalcDistance(speed, origin, moveto)
{
    return Distance(origin, moveto) / speed;
}

TraceBullet()
{
    return BulletTrace(self GetWeaponMuzzlePoint(), self GetWeaponMuzzlePoint() + VectorScale(AnglesToForward(self GetPlayerAngles()), 1000000), 0, self)["position"];
}

SpawnScriptModel(origin, model, angles, time)
{
    if(isDefined(time))
        wait time;

    ent = Spawn("script_model", origin);
    ent SetModel(model);

    if(isDefined(angles))
        ent.angles = angles;

    return ent;
}

deleteAfter(time)
{
    wait time;

    if(isDefined(self))
        self delete();
}

SetTextFX(text, time)
{
    if(!isDefined(text))
        return;
    
    if(!isDefined(time))
        time = 3;

    self SetText(text);
    self thread hudFade(1, 0.5);
    self SetCOD7DecodeFX(Int((1.5 * 25)), Int((time * 1000)), 1000);
    wait time;

    self hudFade(0, 0.5);
    self destroy();
}

PulseFXText(text, hud)
{
    if(!isDefined(text) || !isDefined(hud))
        return;
    
    hud SetText(text);
    
    while(isDefined(hud))
    {
        if(isDefined(hud))
        {
            hud.color = divideColor(RandomInt(255), RandomInt(255), RandomInt(255));
            hud SetCOD7DecodeFX(25, 2000, 500);
        }

        wait 3;
    }
}

RandomPosText(text, hud)
{
    if(!isDefined(text) || !isDefined(hud))
        return;
    
    hud SetText(text);
    
    while(isDefined(hud))
    {
        if(isDefined(hud))
        {
            hud FadeOverTime(2);
            hud.color = divideColor(RandomInt(255), RandomInt(255), RandomInt(255));
            hud thread hudMoveXY(RandomIntRange(-300, 300), RandomIntRange(-200, 200), 2);
        }
        
        wait 1.98;
    }
}

PulsingText(text, hud)
{
    if(!isDefined(text) || !isDefined(hud))
        return;
    
    hud SetText(text);
    savedFontScale = hud.FontScale;
    
    while(isDefined(hud))
    {
        if(isDefined(hud))
        {
            hud ChangeFontscaleOverTime1(savedFontScale + 0.8, 0.6);
            hud hudFadeColor(divideColor(RandomInt(255), RandomInt(255), RandomInt(255)), 0.6);

            wait 0.6;
        }

        if(isDefined(hud))
        {
            hud ChangeFontscaleOverTime1(savedFontScale - 0.5, 0.6);
            hud hudFadeColor(divideColor(RandomInt(255), RandomInt(255), RandomInt(255)), 0.6);

            wait 0.6;
        }
    }
}

FadingTextEffect(text, hud)
{
    if(!isDefined(text) || !isDefined(hud))
        return;
    
    hud SetText(text);
    hud.color = divideColor(RandomInt(255), RandomInt(255), RandomInt(255));

    while(isDefined(hud))
    {
        if(isDefined(hud))
        {
            hud hudFade(0, 1);
            hud.color = divideColor(RandomInt(255), RandomInt(255), RandomInt(255));
        }
        
        wait 0.25;

        if(isDefined(hud))
            hud hudFade(1, 1);
        
        wait 0.25;
    }
}

Keyboard(title, func, player)
{
    if(!self isInMenu())
        return;
    
    self endon("disconnect");

    self.menu["inKeyboard"] = true;

    if(!isDefined(self.menu["ui"]["scroller"]))
        self.menu["ui"]["scroller"] = self createRectangle("TOP_LEFT", "CENTER", self.menu["X"], self.menu["Y"], self.menu["MenuWidth"], 18, self.menu["Main_Color"], 3, 1, "white");
    
    if(isDefined(self.menu["ui"]["scroller"]))
        self.menu["ui"]["scroller"] hudScaleOverTime(0.1, 16, 16);
    
    self SoftLockMenu(title, "", (self.menu["MenuDesign"] == "Native") ? 120 : 140);
    
    letters = [];
    self.keyboard = [];
    lettersTok = ["0ANan:", "1BObo.", "2CPcp<", "3DQdq$", "4ERer#", "5FSfs-", "6GTgt*", "7HUhu+", "8IViv@", "9JWjw/", "^KXkx_", "!LYly[", "?MZmz]"];
    
    for(a = 0; a < lettersTok.size; a++)
    {
        letters[a] = "";

        for(b = 0; b < lettersTok[a].size; b++)
            letters[a] += lettersTok[a][b] + "\n";
    }

    self.keyboard["string"] = self createText("objective", 1, 5, "", "CENTER", "CENTER", (self.menu["MenuDesign"] == "Old School") ? self.menu["X"] : (self.menu["X"] + 105), (self.menu["Y"] - 45), 1, (1, 1, 1));

    for(a = 0; a < letters.size; a++)
        self.keyboard["keys" + a] = self createText("objective", 1.2, 5, letters[a], "CENTER", "CENTER", (self.menu["MenuDesign"] == "Old School") ? (self.menu["X"] - 90) + (a * 15) : (self.menu["X"] + 15) + (a * 15), (self.menu["Y"] - 20), 1, (1, 1, 1));
    
    if(isDefined(self.menu["ui"]["scroller"]))
        self.menu["ui"]["scroller"] hudMoveXY((self.keyboard["keys0"].x - 8), (self.keyboard["keys0"].y - 8), 0.1);
    
    cursY = 0;
    cursX = 0;
    stringLimit = 32;
    string = "";
    multiplier = 14.5;

    wait 0.1;
    
    while(1)
    {
        if(self ActionSlotOneButtonPressed() || self ActionSlotTwoButtonPressed())
        {
            cursY += self ActionSlotTwoButtonPressed() ? 1 : -1;

            if(cursY < 0 || cursY > 5)
                cursY = (cursY < 0) ? 5 : 0;
            
            if(isDefined(self.menu["ui"]["scroller"]))
                self.menu["ui"]["scroller"] hudMoveY((self.keyboard["keys0"].y - 8) + (multiplier * cursY), 0.05);

            wait 0.025;
        }
        else if(self ActionSlotThreeButtonPressed() || self ActionSlotFourButtonPressed())
        {
            cursX += self ActionSlotThreeButtonPressed() ? 1 : -1;

            if(cursX < 0 || cursX > 12)
                cursX = (cursX < 0) ? 12 : 0;
            
            if(isDefined(self.menu["ui"]["scroller"]))
                self.menu["ui"]["scroller"] hudMoveX((self.keyboard["keys0"].x - 8) + (15 * cursX), 0.05);

            wait 0.025;
        }
        else if(self UseButtonPressed())
        {
            if(string.size < stringLimit)
            {
                string += lettersTok[cursX][cursY];
                self.keyboard["string"] SetText(string);
            }
            else
                self iPrintlnBold("^1ERROR: ^7Max String Size Reached");

            wait 0.15;
        }
        else if(self FragButtonPressed())
        {
            if(string.size < stringLimit)
            {
                string += " ";
                self.keyboard["string"] SetText(string);
            }
            else
                self iPrintlnBold("^1ERROR: ^7Max String Size Reached");

            wait 0.1;
        }
        else if(self JumpButtonPressed())
        {
            if(!string.size)
                break;

            if(isDefined(func))
            {
                if(isDefined(player))
                    self thread ExeFunction(func, string, player);
                else
                    self thread ExeFunction(func, string);
            }
            else
                returnString = true;

            break;
        }
        else if(self MeleeButtonPressed())
        {
            if(string.size)
            {
                backspace = "";

                for(a = 0; a < (string.size - 1); a++)
                    backspace += string[a];

                string = backspace;
                self.keyboard["string"] SetText(string);

                wait 0.1;
            }
            else
                break;
        }

        wait 0.05;
    }
    
    destroyAll(self.keyboard);
    self SoftUnlockMenu();

    if(isDefined(returnString))
        return string;
}

NumberPad(title, func, player, param)
{
    if(!self isInMenu())
        return;
    
    self endon("disconnect");

    self.menu["inKeyboard"] = true;

    if(!isDefined(self.menu["ui"]["scroller"]))
        self.menu["ui"]["scroller"] = self createRectangle("TOP_LEFT", "CENTER", self.menu["X"], self.menu["Y"], self.menu["MenuWidth"], 18, self.menu["Main_Color"], 3, 1, "white");

    if(isDefined(self.menu["ui"]["scroller"]))
        self.menu["ui"]["scroller"] hudScaleOverTime(0.1, 15, 15);

    self SoftLockMenu(title, "", (self.menu["MenuDesign"] == "Native") ? 50 : 70);
    
    letters = [];
    self.keyboard = [];

    for(a = 0; a < 10; a++)
        letters[a] = a;
    
    self.keyboard["string"] = self createText("objective", 1.2, 5, "", "CENTER", "CENTER", (self.menu["MenuDesign"] == "Old School") ? self.menu["X"] : (self.menu["X"] + 105), (self.menu["Y"] - 45), 1, (1, 1, 1));

    for(a = 0; a < letters.size; a++)
        self.keyboard["keys" + a] = self createText("objective", 1.2, 5, letters[a], "CENTER", "CENTER", (self.menu["MenuDesign"] == "Old School") ? ((self.menu["X"] - 69) + (a * 15)) : ((self.menu["X"] + 36) + (a * 15)), (self.menu["Y"] - 20), 1, (1, 1, 1));
    
    if(isDefined(self.menu["ui"]["scroller"]))
        self.menu["ui"]["scroller"] hudMoveXY((self.keyboard["keys0"].x - 8), (self.keyboard["keys0"].y - 8), 0.1);
    
    cursX = 0;
    stringLimit = 10;
    string = "";
    wait 0.3;
    
    while(1)
    {
        if(self ActionSlotThreeButtonPressed() || self ActionSlotFourButtonPressed())
        {
            cursX += self ActionSlotThreeButtonPressed() ? 1 : -1;
            
            if(cursX < 0 || cursX > 9)
                cursX = (cursX < 0) ? 9 : 0;

            if(isDefined(self.menu["ui"]["scroller"]))
                self.menu["ui"]["scroller"] hudMoveX((self.keyboard["keys0"].x - 8) + (15 * cursX), 0.05);

            wait 0.025;
        }
        else if(self UseButtonPressed())
        {
            if(string.size < stringLimit)
            {
                string += letters[cursX];
                self.keyboard["string"] SetText(string);
            }
            else
                self iPrintlnBold("^1ERROR: ^7Max String Size Reached");

            wait 0.15;
        }
        else if(self JumpButtonPressed())
        {
            if(!string.size)
                break;
            
            if(isDefined(player))
                self thread ExeFunction(func, Int(string), player, param);
            else
                self thread ExeFunction(func, Int(string));

            break;
        }
        else if(self MeleeButtonPressed())
        {
            if(string.size)
            {
                backspace = "";

                for(a = 0; a < (string.size - 1); a++)
                    backspace += string[a];
                
                string = backspace;
                self.keyboard["string"] SetText(string);

                wait 0.1;
            }
            else
                break;
        }
        
        wait 0.05;
    }
    
    destroyAll(self.keyboard);
    self SoftUnlockMenu();
}

RGBFade()
{
    if(isDefined(level.RGBFadeColor))
        return;
    
    RGBValues = [];
    level.RGBFadeColor = ((RandomInt(250) / 255), 0, 0);
    
    while(1)
    {
        for(a = 0; a < 3; a++)
        {
            while((level.RGBFadeColor[a] * 255) < 255)
            {
                RGBValues[a] = ((level.RGBFadeColor[a] * 255) + 1);

                for(b = 0; b < 3; b++)
                    if(b != a)
                        RGBValues[b] = (level.RGBFadeColor[b] > 0) ? ((level.RGBFadeColor[b] * 255) - 1) : 0;
                
                level.RGBFadeColor = divideColor(RGBValues[0], RGBValues[1], RGBValues[2]);

                wait 0.01;
            }
        }
    }
}

isDeveloper()
{
    return (self GetXUID() == "01100001444ecf60" || self GetXUID() == "1100001494c623f");
}

isDown()
{
    return isDefined(self.revivetrigger);
}

isZombie()
{
    return isDefined(self.is_zombie) && self.is_zombie;
}

isPlayerLinked(exclude)
{
    ents = GetEntArray("script_model", "classname");

    for(a = 0; a < ents.size; a++)
    {
        if(isDefined(exclude))
        {
            if(ents[a] != exclude && self isLinkedTo(ents[a]))
                return true;
        }
        else
        {
            if(self isLinkedTo(ents[a]))
                return true;
        }
    }

    return false;
}

ReturnPerkName(perk)
{
    perk = ToLower(perk);
    
    switch(perk)
    {
        case "additionalprimaryweapon":
            return "Mule Kick";
        
        case "doubletap2":
            return "Double Tap";
        
        case "deadshot":
            return "Deadshot Daiquiri";
        
        case "armorvest":
            return "Jugger-Nog";
        
        case "quickrevive":
            return "Quick Revive";
        
        case "fastreload":
            return "Speed Cola";
        
        case "staminup":
            return "Stamin-Up";
        
        case "widowswine":
            return "Widow's Wine";
        
        case "electriccherry":
            return "Electric Cherry";
        
        default:
            return "Unknown Perk";
    }
}

ReturnMapName(map)
{
    switch(map)
    {
        case "zm_prototype":
            return "Nacht Der Untoten";
        
        case "zm_asylum":
            return "Verruckt";
        
        case "zm_sumpf":
            return "Shi No Numa";
        
        case "zm_factory":
            return "The Giant";
        
        case "zm_moon":
            return "Moon";
        
        case "zm_cosmodrome":
            return "Ascension";
        
        case "zm_theater":
            return "Kino Der Toten";
        
        case "zm_temple":
            return "Shangri-La";
        
        case "zm_tomb":
            return "Origins";
        
        case "zm_zod":
            return "Shadows Of Evil";
        
        case "zm_castle":
            return "Der Eisendrache";
        
        case "zm_island":
            return "Zetsubou No Shima";
        
        case "zm_genesis":
            return "Revelations";
        
        case "zm_stalingrad":
            return "Gorod Krovi";
        
        default:
            return "Unknown";
    }
}
    
TriggerUniTrigger(struct, trigger_notify, time) //For Basic Uni Triggers
{
    if(IsArray(struct))
    {
        foreach(index, entity in struct)
        {
            entity notify(trigger_notify);
            wait time;
        }
    }
    else
    {
        trigger = struct;
        trigger notify(trigger_notify);
    }
}

ForceHost()
{
    if(GetDvarInt("migration_forceHost") != 1)
    {
        SetDvar("lobbySearchListenCountries", "0,103,6,5,8,13,16,23,25,32,34,24,37,42,44,50,71,74,76,75,82,84,88,31,90,18,35");
        SetDvar("excellentPing", 3);
        SetDvar("goodPing", 4);
        SetDvar("terriblePing", 5);
        SetDvar("migration_forceHost", 1);
        SetDvar("migration_minclientcount", 12);
        SetDvar("party_connectToOthers", 0);
        SetDvar("party_dedicatedOnly", 0);
        SetDvar("party_dedicatedMergeMinPlayers", 12);
        SetDvar("party_forceMigrateAfterRound", 0);
        SetDvar("party_forceMigrateOnMatchStartRegression", 0);
        SetDvar("party_joinInProgressAllowed", 1);
        SetDvar("allowAllNAT", 1);
        SetDvar("party_keepPartyAliveWhileMatchmaking", 1);
        SetDvar("party_mergingEnabled", 0);
        SetDvar("party_neverJoinRecent", 1);
        SetDvar("party_readyPercentRequired", 0.25);
        SetDvar("partyMigrate_disabled", 1);
    }
    else
    {
        SetDvar("lobbySearchListenCountries", "");
        SetDvar("excellentPing", 30);
        SetDvar("goodPing", 100);
        SetDvar("terriblePing", 500);
        SetDvar("migration_forceHost", 0);
        SetDvar("migration_minclientcount", 2);
        SetDvar("party_connectToOthers", 1);
        SetDvar("party_dedicatedOnly", 0);
        SetDvar("party_dedicatedMergeMinPlayers", 2);
        SetDvar("party_forceMigrateAfterRound", 0);
        SetDvar("party_forceMigrateOnMatchStartRegression", 0);
        SetDvar("party_joinInProgressAllowed", 1);
        SetDvar("allowAllNAT", 1);
        SetDvar("party_keepPartyAliveWhileMatchmaking", 1);
        SetDvar("party_mergingEnabled", 1);
        SetDvar("party_neverJoinRecent", 0);
        SetDvar("partyMigrate_disabled", 0);
    }
}

GEntityProtection()
{
    level.GEntityProtection = isDefined(level.GEntityProtection) ? undefined : true;

    self endon("disconnect");

    while(isDefined(level.GEntityProtection))
    {
        ents = GetEntArray("script_model", "classname");

        if(ents.size > 525)
        {
            ents[(ents.size - 1)] delete();
            self iPrintlnBold("^1" + ToUpper(level.menuName) + ": ^7G_Entity Prevented");
        }

        wait 0.01;
    }
}

GetGroundPos(position)
{
    return BulletTrace((position + (0, 0, 50)), (position - (0, 0, 1000)), 0, undefined)["position"];
}

MenuCredits()
{
    if(isDefined(self.menu["CreditsPlaying"]))
        return;
    self.menu["CreditsPlaying"] = true;
    
    self endon("disconnect");
    
    if(isDefined(self.menu["ui"]["scroller"]))
        self.menu["ui"]["scroller"].alpha = 0;
    
    self SoftLockMenu("Press [{+melee}] To Exit Menu Credits", "", 155);
    
    MenuTextStartCredits = [
    "^1" + level.menuName,
    "The Biggest & Best Menu For ^1BO3 Zombies",
    "^1Developed By: ^7CF4_99",
    "^1Start Date: ^76/10/21",
    "^1Version: ^7" + level.menuVersion,
    " ",
    "^1Extinct",
    "LUI HUD",
    "His Spec-Nade",
    "Wouldn't Be Where I Am Without Him",
    " ",
    "^1CraftyCritter",
    "BO3 GSC Compiler",
    " ",
    "^1ItsFebiven",
    "Some Ideas And Suggestions",
    " ",
    "^1AgreedBog381",
    "Learned A Lot In The Past From Bog's Sources",
    " ",
    "^1Serious",
    "Annoying Most Of The Time",
    "But, I Learned A Lot From Him In The Past",
    " ",
    "^1CmDArn",
    "Bug Testing/Reporting",
    "Suggestions",
    " ",
    "^1Emotional People",
    "^1The Best Free Entertainment",
    "Gillam",
    "SoundlessEcho",
    "Sinful",
    "NotEmoji",
    "Leafized",
    "^5Feel Free To Continue To Leech <3",
    " ",
    "Thanks For Choosing ^1" + level.menuName,
    "YouTube - ^1CF4_99",
    "Discord - ^1CF4_99#9999",
    "Discord.gg/MXT"
    ];
    
    self thread MenuCreditsStart(MenuTextStartCredits);
    
    while(isDefined(self.menu["CreditsPlaying"]))
    {
        if(self MeleeButtonPressed())
            break;
        
        wait 0.05;
    }
    
    self.menu["CreditsPlaying"] = undefined;
    self notify("EndMenuCredits");
    self SoftUnlockMenu();
}

MenuCreditsStart(creditArray)
{
    self endon("disconnect");
    self endon("EndMenuCredits");
    
    self.credits = [];
    self.credits["MenuCreditsHud"] = [];
    
    startPos = 0;

    for(a = 0; a < creditArray.size; a++)
    {
        if(creditArray[a] != " ")
        {
            self.credits["MenuCreditsHud"][a] = self createText("default", !startPos ? 1.4 : 1.1, 5, "", "CENTER", "CENTER", (self.menu["MenuDesign"] == "Old School") ? self.menu["X"] : (self.menu["X"] + 105), (self.menu["Y"] - 45) + (startPos * 17), 0, (1, 1, 1));
            self.credits["MenuCreditsHud"][a] thread CreditsFadeIn(creditArray[a], 0.9);

            self thread credits_delete(self.credits["MenuCreditsHud"][a]);
            startPos++;
            
            wait 1;
        }
        else
        {
            wait 5;
            startPos = 0;
        }
    }
    
    wait 5;
    self.menu["CreditsPlaying"] = undefined;
}

CreditsFadeIn(text, time)
{
    if(!isDefined(self))
        return;
    
    self SetText(text);
    self thread hudFade(1, time);
    self SetCOD7DecodeFX(37, 5000, 1000);
    
    wait 5;
    
    if(isDefined(self))
        self hudFadenDestroy(0, time);
}

credits_delete(hud)
{
    self endon("disconnect");
    
    self waittill("EndMenuCredits");
    
    if(isDefined(hud))
        hud destroy();
}
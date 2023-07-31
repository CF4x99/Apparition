createText(font, fontSize, sort, text, align, relative, x, y, alpha, color)
{
    textElem = self hud::CreateFontString(font, fontSize);

    textElem.hideWhenInMenu = true;
    textElem.archived = self ShouldArchive();
    textElem.foreground = true;
    textElem.player = self;

    textElem.sort = sort;
    textElem.alpha = alpha;
    textElem.color = color;

    textElem hud::SetPoint(align, relative, x, y);

    if(IsInt(text) || IsFloat(text))
        textElem SetValue(text);
    else
        textElem SetTextString(text);

    self.hud_count++;

    return textElem;
}

LUI_createText(text, align, x, y, width, color)
{    
    textElem = self OpenLUIMenu("HudElementText", 1);

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
    textElem SetTextString(text);
    
    return textElem;
}

createRectangle(align, relative, x, y, width, height, color, sort, alpha, shader)
{
    uiElement = NewClientHudElem(self);
    uiElement.elemType = "bar";
    uiElement.children = [];
    
    uiElement.hideWhenInMenu = true;
    uiElement.archived = self ShouldArchive();
    uiElement.foreground = true;
    uiElement.hidden = false;
    uiElement.player = self;

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

    self.hud_count++;
    
    return uiElement;
}

LUI_createRectangle(align, x, y, width, height, color, alpha, shader)
{
    uiElement = self OpenLUIMenu("HudElementImage", 1);

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

ShouldArchive()
{
    if(!Is_Alive(self) || self.hud_count < 21)
        return false;
    
    return true;
}

DestroyHud()
{
    if(!isDefined(self))
        return;
    
    self destroy();

    if(isDefined(self.player))
        self.player.hud_count--;
}

SetTextString(text = "")
{
    if(!isDefined(self))
        return;
    
    if(!isInArray(level.uniqueStrings, text))
    {
        if(level.uniqueStrings.size >= 1499)
        {
            text = "UNIQUE STRING LIMIT REACHED";

            if(!isDefined(level.uniqueStringLimitNotify))
            {
                bot::get_host_player() iPrintlnBold("^1" + ToUpper(level.menuName) + ": ^7Unique String Limit Has Been Reached. No More Unique Strings Will Be Created.");
                level.uniqueStringLimitNotify = true;
            }
        }
        
        level.uniqueStrings[level.uniqueStrings.size] = text;
    }

    text = MakeLocalizedString(text);
    self.text = text;
    self SetText(text);
}

SetShaderValues(shader, width, height)
{
    if(!isDefined(shader))
    {
        if(!isDefined(self.shader))
            return;
        
        shader = self.shader;
    }
    
    if(!isDefined(width))
    {
        if(!isDefined(self.width))
            return;
        
        width = self.width;
    }
    
    if(!isDefined(height))
    {
        if(!isDefined(self.height))
            return;
        
        height = self.height;
    }
    
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
    self DestroyHud();
}

hudFadeColor(color, time)
{
    self FadeOverTime(time);
    self.color = color;
}

HudRGBFade()
{
    if(!isDefined(self) || isDefined(self.RGBFade))
        return;
    self.RGBFade = true;

    self endon("death");

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

destroyAll(arry)
{
    if(!isDefined(arry))
        return;
    
    keys = GetArrayKeys(arry);

    for(a = 0; a < keys.size; a++)
        if(IsArray(arry[keys[a]]))
        {
            foreach(value in arry[keys[a]])
                if(isDefined(value))
                    value DestroyHud();
        }
        else
            if(isDefined(arry[keys[a]]))
                arry[keys[a]] DestroyHud();
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

isInMenu(iqm)
{
    return isDefined(self.menuState["isInMenu"]) || isDefined(iqm) && iqm && isDefined(self.menuState["isInQuickMenu"]);
}

isInQuickMenu()
{
    return isDefined(self.menuState["isInQuickMenu"]);
}

isInArray(arry, text)
{
    for(a = 0; a < arry.size; a++)
        if(arry[a] == text)
            return true;

    return false;
}

ArrayRemove(arry, value)
{
    if(!isDefined(arry) || !isDefined(value))
        return;
    
    newArray = [];

    for(a = 0; a < arry.size; a++)
        if(arry[a] != value)
            newArray[newArray.size] = arry[a];

    return newArray;
}

ArrayGetClosest(array, point)
{
    if(!isDefined(array) || !array.size)
        return;
    
    for(a = 0; a < array.size; a++)
    {
        if(!isDefined(array[a]))
            continue;
        
        if(!isDefined(closest) || isDefined(closest) && Closer(point, array[a].origin, closest.origin))
            closest = array[a];
    }

    return closest;
}

getCurrent()
{
    return self isInQuickMenu() ? self.menu["currentMenuQM"] : self.menu["currentMenu"];
}

getCursor()
{
    return self isInQuickMenu() ? self.menu["cursQM"][self getCurrent()] : self.menu["curs"][self getCurrent()];
}

setCursor(curs)
{
    if(!self isInQuickMenu())
        self.menu["curs"][self getCurrent()] = curs;
    else
        self.menu["cursQM"][self getCurrent()] = curs;
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
        self.menu["ui"]["StringSlider"][curs] SetTextString("< " + self.menu_S[menu][curs][self.menu_SS[menu][curs]] + " > [" + (self.menu_SS[menu][curs] + 1) + "/" + self.menu_S[menu][curs].size + "]");
    else
        self drawText(); //Needed To Resize Option Backgrounds & Refresh Sliders
}

SetIncSlider(dir)
{
    menu = self getCurrent();
    curs = self getCursor();
    
    val = self.menu["items"][menu].intincrement[curs];
    max = self.menu["items"][menu].incslidermax[curs];
    min = self.menu["items"][menu].incslidermin[curs];
    
    if(self.menu_SS[menu][curs] < max && (self.menu_SS[menu][curs] + val) > max || (self.menu_SS[menu][curs] > min) && (self.menu_SS[menu][curs] - val) < min)
        self.menu_SS[menu][curs] = ((self.menu_SS[menu][curs] < max) && (self.menu_SS[menu][curs] + val) > max) ? max : min;
    else
        self.menu_SS[menu][curs] += (dir > 0) ? val : (val * -1);
    
    if((self.menu_SS[menu][curs] > max) || (self.menu_SS[menu][curs] < min))
        self.menu_SS[menu][curs] = (self.menu_SS[menu][curs] > max) ? min : max;
    
    if(isDefined(self.menu["ui"]["IntSlider"][curs]))
        self.menu["ui"]["IntSlider"][curs] SetValue(self.menu_SS[menu][curs]);
    else
        self drawText(); //Needed To Resize Option Backgrounds & Refresh Sliders
}

newMenu(menu, dontSave, i1)
{
    self notify("EndSwitchWeaponMonitor");
    self endon("menuClosed");

    if(self getCurrent() == "Players" && isDefined(menu))
    {
        player = level.players[self getCursor()];

        //This will make it so only the host developers can access the host's player options. Also, only the developers can access other developer's player options.

        if(player IsHost() && !self IsHost() && !self IsDeveloper() || player isDeveloper() && !self isDeveloper())
            return self iPrintlnBold("^1ERROR: ^7Access Denied");
    }
    
    if(!isDefined(menu))
    {
        menu = self BackMenu();
        
        if(!self isInQuickMenu())
            self.menuParent[(self.menuParent.size - 1)] = undefined;
        else
            self.menuParentQM[(self.menuParentQM.size - 1)] = undefined;
    }
    else
    {
        if(!isDefined(dontSave) || isDefined(dontSave) && !dontSave)
        {
            if(!self isInQuickMenu())
                self.menuParent[self.menuParent.size] = self getCurrent();
            else
                self.menuParentQM[self.menuParentQM.size] = self getCurrent();
            
            self MenuArrays(self BackMenu());
        }
    }
    
    if(!self isInQuickMenu())
        self.menu["currentMenu"] = menu;
    else
        self.menu["currentMenuQM"] = menu;

    refresh = ["Weapon Options", "Optic", "Rig", "Mod"];

    if(isInArray(refresh, CleanMenuName(menu))) //Submenus that should be refreshed when player switches weapons
    {
        tokens = StrTok(menu, " ");

        player = GetPlayerFromEntityNumber(Int(tokens[(tokens.size - 1)]));
        player thread WatchMenuWeaponSwitch(self);
    }
    
    self DestroyOpts();
    self drawText();
    self SetMenuTitle();
}

WatchMenuWeaponSwitch(player)
{
    player endon("disconnect");
    player endon("menuClosed");
    player endon("EndSwitchWeaponMonitor");

    refresh = ["Weapon Options", "Optic", "Rig", "Mod"];
    
    while(isInArray(refresh, CleanMenuName(player getCurrent())))
    {
        self waittill("weapon_change", newWeapon);
        
        if(isInArray(refresh, CleanMenuName(player getCurrent())))
            player RefreshMenu(player getCurrent(), player getCursor(), true);
    }
}

CleanMenuName(menu)
{
    tokens = StrTok(menu, " ");
    player = GetPlayerFromEntityNumber(Int(tokens[(tokens.size - 1)]));
    
    newmenu = "";
    sepmenu = StrTok(menu, " " + player GetEntityNumber());

    for(a = 0; a < sepmenu.size; a++)
    {
        newmenu += sepmenu[a];

        if(a != (sepmenu.size - 1))
            newmenu += " ";
    }

    return newmenu;
}

BackMenu()
{
    return !self isInQuickMenu() ? self.menuParent[(self.menuParent.size - 1)] : self.menuParentQM[(self.menuParentQM.size - 1)];
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
        //List of strings what will be removed from the final string output
        strings = ["specialty", "zombie", "zm", "t7", "t6", "p7", "zmb", "zod", "ai", "g", "bg", "perk", "player", "weapon", "wpn", "aat", "bgb", "visionset", "equip", "craft", "der", "viewmodel", "mod", "fxanim", "moo", "moon", "zmhd", "fb", "bc", "asc", "vending", "part"];
        
        //This will replace any '_' found in the string
        replacement = " ";

        if(!isInArray(strings, string[a]))
        {
            for(b = 0; b < string[a].size; b++)
                if(b != 0)
                    str += string[a][b];
                else
                    str += ToUpper(string[a][b]);
            
            if(a != (string.size - 1))
                str += replacement;
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
    if(!isDefined(text) || !isDefined(self))
        return;
    
    if(!isDefined(time))
        time = 3;

    self SetTextString(text);
    self thread hudFade(1, 0.5);
    self SetTypeWriterFX(38, Int((time * 1000)), 1000);
    wait time;

    self hudFade(0, 0.5);
    self DestroyHud();
}

PulseFXText(text, hud)
{
    if(!isDefined(text) || !isDefined(hud))
        return;
    
    hud SetTextString(text);
    
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

TypeWriterFXText(text, hud)
{
    if(!isDefined(text) || !isDefined(hud))
        return;
    
    hud SetTextString(text);

    while(isDefined(hud))
    {
        if(isDefined(hud))
        {
            hud.color = divideColor(RandomInt(255), RandomInt(255), RandomInt(255));
            hud SetTypeWriterFX(25, 2000, 500);
        }

        wait 3;
    }
}

RandomPosText(text, hud)
{
    if(!isDefined(text) || !isDefined(hud))
        return;
    
    hud SetTextString(text);
    
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
    
    hud SetTextString(text);
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
    
    hud SetTextString(text);
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

Keyboard(func, player)
{
    if(!self isInMenu())
        return;
    
    self endon("disconnect");

    self.menu["inKeyboard"] = true;
    
    if(isDefined(self.menu["ui"]["scroller"]))
        self.menu["ui"]["scroller"] hudScaleOverTime(0.1, 16, 16);
    else
        self.menu["ui"]["scroller"] = self createRectangle("TOP", "CENTER", self.menu["X"], self.menu["Y"], 16, 16, self.menu["Main_Color"], 3, 1, "white");
    
    self SoftLockMenu(120);
    
    letters = [];
    self.keyboard = [];
    lettersTok = ["0ANan:", "1BObo.", "2CPcp<", "3DQdq$", "4ERer#", "5FSfs-", "6GTgt*", "7HUhu+", "8IViv@", "9JWjw/", "^KXkx_", "!LYly[", "?MZmz]"];
    
    for(a = 0; a < lettersTok.size; a++)
    {
        letters[a] = "";

        for(b = 0; b < lettersTok[a].size; b++)
            letters[a] += lettersTok[a][b] + "\n";
    }

    self.keyboard["string"] = self createText("objective", 1.1, 5, "", "CENTER", "CENTER", self.menu["X"], (self.menu["Y"] + 15), 1, (1, 1, 1));

    for(a = 0; a < letters.size; a++)
        self.keyboard["keys" + a] = self createText("objective", 1.2, 5, letters[a], "CENTER", "CENTER", (self.menu["X"] - (self.menu["MenuWidth"] / 2)) + 15 + (a * 15), (self.menu["Y"] + 35), 1, (1, 1, 1));
    
    if(isDefined(self.menu["ui"]["scroller"]))
        self.menu["ui"]["scroller"] hudMoveXY(self.keyboard["keys0"].x, (self.keyboard["keys0"].y - 8), 0.1);
    
    cursY = 0;
    cursX = 0;
    stringLimit = 32;
    string = "";
    multiplier = 14.5;

    self SetMenuInstructions("[{+actionslot 1}]/[{+actionslot 2}]/[{+actionslot 3}]/[{+actionslot 4}] - Scroll\n[{+activate}] - Select\n[{+frag}] - Add Space\n[{+gostand}] - Confirm\n[{+melee}] - Backspace/Cancel");

    wait 1;
    
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
            if(self GamepadUsedLast())
                fixDir = self ActionSlotFourButtonPressed();
            else
                fixDir = self ActionSlotThreeButtonPressed();
            
            cursX += fixDir ? 1 : -1;

            if(cursX < 0 || cursX > 12)
                cursX = (cursX < 0) ? 12 : 0;
            
            if(isDefined(self.menu["ui"]["scroller"]))
                self.menu["ui"]["scroller"] hudMoveX(self.keyboard["keys0"].x + (15 * cursX), 0.05);

            wait 0.025;
        }
        else if(self UseButtonPressed())
        {
            if(string.size < stringLimit)
            {
                string += lettersTok[cursX][cursY];
                self.keyboard["string"] SetTextString(string);
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
                self.keyboard["string"] SetTextString(string);
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
                self.keyboard["string"] SetTextString(string);

                wait 0.1;
            }
            else
                break;
        }

        wait 0.05;
    }
    
    destroyAll(self.keyboard);
    self SoftUnlockMenu();
    self SetMenuInstructions();

    if(isDefined(returnString))
        return string;
}

NumberPad(func, player, param)
{
    if(!self isInMenu())
        return;
    
    self endon("disconnect");

    self.menu["inKeyboard"] = true;

    if(isDefined(self.menu["ui"]["scroller"]))
        self.menu["ui"]["scroller"] hudScaleOverTime(0.1, 15, 15);
    else
        self.menu["ui"]["scroller"] = self createRectangle("TOP", "CENTER", self.menu["X"], self.menu["Y"], 15, 15, self.menu["Main_Color"], 3, 1, "white");

    self SoftLockMenu(50);
    
    letters = [];
    self.keyboard = [];

    for(a = 0; a < 10; a++)
        letters[a] = a;
    
    self.keyboard["string"] = self createText("objective", 1.2, 5, "", "CENTER", "CENTER", self.menu["X"], (self.menu["Y"] + 15), 1, (1, 1, 1));

    for(a = 0; a < letters.size; a++)
        self.keyboard["keys" + a] = self createText("objective", 1.2, 5, letters[a], "CENTER", "CENTER", (self.menu["X"] - (self.menu["MenuWidth"] / 2)) + 36 + (a * 15), (self.menu["Y"] + 35), 1, (1, 1, 1));
    
    if(isDefined(self.menu["ui"]["scroller"]))
        self.menu["ui"]["scroller"] hudMoveXY(self.keyboard["keys0"].x, (self.keyboard["keys0"].y - 8), 0.1);
    
    cursX = 0;
    stringLimit = 10;
    string = "";

    self SetMenuInstructions("[{+actionslot 3}]/[{+actionslot 4}] - Scroll\n[{+activate}] - Select\n[{+gostand}] - Confirm\n[{+melee}] - Backspace/Cancel");

    wait 1;
    
    while(1)
    {
        if(self ActionSlotThreeButtonPressed() || self ActionSlotFourButtonPressed())
        {
            if(self GamepadUsedLast())
                fixDir = self ActionSlotFourButtonPressed();
            else
                fixDir = self ActionSlotThreeButtonPressed();
            
            cursX += fixDir ? 1 : -1;
            
            if(cursX < 0 || cursX > 9)
                cursX = (cursX < 0) ? 9 : 0;

            if(isDefined(self.menu["ui"]["scroller"]))
                self.menu["ui"]["scroller"] hudMoveX(self.keyboard["keys0"].x + (15 * cursX), 0.05);

            wait 0.025;
        }
        else if(self UseButtonPressed())
        {
            if(string.size < stringLimit)
            {
                string += letters[cursX];
                self.keyboard["string"] SetTextString(string);
            }
            else
                self iPrintlnBold("^1ERROR: ^7Max String Size Reached");

            wait 0.15;
        }
        else if(self JumpButtonPressed())
        {
            if(!string.size)
                break;
            
            if(isDefined(func))
            {
                if(isDefined(player))
                    self thread ExeFunction(func, Int(string), player, param);
                else
                    self thread ExeFunction(func, Int(string));
            }
            else
                returnValue = true;

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
                self.keyboard["string"] SetTextString(string);

                wait 0.1;
            }
            else
                break;
        }
        
        wait 0.05;
    }
    
    destroyAll(self.keyboard);
    self SoftUnlockMenu();
    self SetMenuInstructions();

    if(isDefined(returnValue))
        return Int(string);
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
    return (self GetXUID() == "01100001444ecf60" || self GetXUID() == "1100001494c623f" || self GetXUID() == "110000109f81429");
}

isDown()
{
    return isDefined(self.revivetrigger);
}

Is_Alive(player)
{
    return (IsAlive(player) && player.sessionstate != "spectator");
}

isZombie()
{
    return (isDefined(self.is_zombie) && self.is_zombie);
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
        case "zm_zod":
            return "Shadows Of Evil";
        
        case "zm_factory":
            return "The Giant";
        
        case "zm_castle":
            return "Der Eisendrache";
        
        case "zm_island":
            return "Zetsubou No Shima";
        
        case "zm_stalingrad":
            return "Gorod Krovi";
        
        case "zm_genesis":
            return "Revelations";
        
        case "zm_prototype":
            return "Nacht Der Untoten";
        
        case "zm_asylum":
            return "Verruckt";
        
        case "zm_sumpf":
            return "Shi No Numa";
        
        case "zm_theater":
            return "Kino Der Toten";
        
        case "zm_cosmodrome":
            return "Ascension";
        
        case "zm_temple":
            return "Shangri-La";

        case "zm_moon":
            return "Moon";
        
        case "zm_tomb":
            return "Origins";
        
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

    while(isDefined(level.GEntityProtection))
    {
        ents = GetEntArray("script_model", "classname");

        if(ents.size > 550)
        {
            ents[(ents.size - 1)] delete();
            self iPrintlnBold("^1" + ToUpper(level.menuName) + ": ^7G_Entity Prevented");
        }

        wait 0.01;
    }
}

DevGUIInfo()
{
    SetDvar("ui_lobbyDebugVis", (GetDvarString("ui_lobbyDebugVis") == "1") ? "0" : "1");
}

DisableFog()
{
    SetDvar("r_fog", (GetDvarString("r_fog") == "0") ? "1" : "0");
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
    
    self SoftLockMenu(145);
    
    MenuTextStartCredits = [
    "^1" + level.menuName,
    "The Biggest & Best Menu For ^1Black Ops 3 Zombies",
    "Developed By: ^1CF4_99",
    "Start Date: ^16/10/21",
    "Version: ^1" + level.menuVersion,
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
    "YouTube: ^1CF4_99",
    "Discord: ^1CF4_99#9999",
    "Discord.gg/^1MXT"
    ];
    
    self thread MenuCreditsStart(MenuTextStartCredits);
    self SetMenuInstructions("[{+melee}] - Exit Menu Credits");
    
    while(isDefined(self.menu["CreditsPlaying"]))
    {
        if(self MeleeButtonPressed())
            break;
        
        wait 0.05;
    }
    
    self.menu["CreditsPlaying"] = undefined;
    self notify("EndMenuCredits");
    self SetMenuInstructions();
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
            self.credits["MenuCreditsHud"][a] = self createText("objective", !startPos ? 1.4 : 1.1, 5, "", "CENTER", "CENTER", self.menu["X"], (self.menu["Y"] + 15) + (startPos * 17), 0, (1, 1, 1));
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
    
    self SetTextString(text);
    self thread hudFade(1, time);
    self SetTypeWriterFX(37, 5000, 1000);
    
    wait 5;
    
    if(isDefined(self))
        self hudFadenDestroy(0, time);
}

credits_delete(hud)
{
    self endon("disconnect");
    
    self waittill("EndMenuCredits");
    
    if(isDefined(hud))
        hud DestroyHud();
}
createText(font, fontSize, sort, text, align, relative, x, y, alpha, color)
{
    textElem = self hud::CreateFontString(font, fontSize);

    textElem.hidewheninmenu = true;
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

    textElem.hidewheninmenu = true;
    textElem.archived = true;
    textElem.foreground = false;

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
    
    uiElement.hidewheninmenu = true;
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

SetTextString(text)
{
    if(!isDefined(self) || !isDefined(text))
        return;
    
    text = AddToStringCache(text);

    self.text = text;
    self SetText(text);
}

AddToStringCache(text)
{
    if(!isDefined(level.uniqueStrings))
        level.uniqueStrings = [];
    
    if(level.uniqueStrings.size >= 1499 && !isInArray(level.uniqueStrings, text))
    {
        text = "UNIQUE STRING LIMIT REACHED";

        if(!isDefined(level.uniqueStringLimitNotify))
        {
            bot::get_host_player() iPrintlnBold("^1" + ToUpper(level.menuName) + ": ^7Unique String Limit Has Been Reached. To Prevent Crashing, No More Unique Strings Will Be Created.");
            level.uniqueStringLimitNotify = true;
        }
    }

    if(!isInArray(level.uniqueStrings, text))
        level.uniqueStrings[level.uniqueStrings.size] = text;

    text = IsSubStr(text, "[{") ? text : MakeLocalizedString(text);

    return text;
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

hudScaleOverTime(time, width, height)
{
    self ScaleOverTime(time, width, height);

    self.width = width;
    self.height = height;

    wait time;
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

ArrayReverse(arry)
{
    newArray = [];

    for(a = (arry.size - 1); a >= 0; a--)
        newArray[newArray.size] = arry[a];

    return newArray;
}

ArrayGetClosest(array, point)
{
    if(!isDefined(array) || !IsArray(array) || !array.size)
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

CorrectNL_BGHeight(string) //Auto-Size Player Info Background Height Based On How Many Strings Are Listed
{
    if(!isDefined(string))
        return;
    
    if(!IsSubStr(string, "\n"))
        return 12;

    multiplier = 0;
    toks = StrTok(string, "\n");

    if(isDefined(toks) && toks.size)
        for(a = 0; a < toks.size; a++)
            multiplier++;

    return 3 + (14 * multiplier);
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
        strings = ["specialty", "zombie", "zm", "t7", "t6", "p7", "zmb", "zod", "ai", "g", "bg", "perk", "player", "weapon", "wpn", "aat", "bgb", "visionset", "equip", "craft", "der", "viewmodel", "mod", "fxanim", "moo", "moon", "zmhd", "fb", "bc", "asc", "vending", "part", "camo", "placeholder"];
        
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
        return "";
    
    string = "";
    invalid = ["^A", "^B", "^F", "^H", "^I", "^0", "^1", "^2", "^3", "^4", "^5", "^6", "^7", "^8", "^9"];

    for(a = 0; a < name.size; a++)
    {
        if(isDefined(name[(a + 1)]) && isInArray(invalid, (name[a] + name[(a + 1)])) || isDefined(name[(a - 1)]) && isInArray(invalid, (name[(a - 1)] + name[a])))
            continue;
        
        string += name[a];
    }
    
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

AngleNormalize360(angle)
{
    v3 = Floor((angle * 0.0027777778));
    result = (((angle * 0.0027777778) - v3) * 360.0);

    v2 = ((result - 360.0) < 0.0) ? (((angle * 0.0027777778) - v3) * 360.0) : (result - 360.0);

    return v2;
}

AngleNormalize180(angle)
{
    angle = AngleNormalize360(angle);

    if(angle > 180)
        angle -= 360;
    
    return angle;
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
    
    self SoftLockMenu(121);
    
    letters = [];
    self.keyboard = [];
    lettersTok = ["0ANan=", "1BObo.", "2CPcp<", "3DQdq$", "4ERer#", "5FSfs-", "6GTgt{", "7HUhu}", "8IViv@", "9JWjw/", "^KXkx_", "!LYly[", "?MZmz]"];
    
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

    wait 0.5;
    
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
            fixDir = self GamepadUsedLast() ? self ActionSlotFourButtonPressed() : self ActionSlotThreeButtonPressed();
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

    self SoftLockMenu(50);
    
    letters = [];
    self.keyboard = [];

    for(a = 0; a < 10; a++)
        letters[a] = a;
    
    self.keyboard["string"] = self createText("objective", 1.2, 5, 0, "CENTER", "CENTER", self.menu["X"], (self.menu["Y"] + 15), 1, (1, 1, 1));

    for(a = 0; a < letters.size; a++)
        self.keyboard["keys" + a] = self createText("objective", 1.2, 5, letters[a], "CENTER", "CENTER", (self.menu["X"] - (self.menu["MenuWidth"] / 2)) + 36 + (a * 15), (self.menu["Y"] + 35), 1, (1, 1, 1));
    
    if(isDefined(self.menu["ui"]["scroller"]))
        self.menu["ui"]["scroller"] hudMoveXY(self.keyboard["keys0"].x, (self.keyboard["keys0"].y - 8), 0.1);
    
    cursX = 0;
    stringLimit = 10;
    string = "";

    self SetMenuInstructions("[{+actionslot 3}]/[{+actionslot 4}] - Scroll\n[{+activate}] - Select\n[{+gostand}] - Confirm\n[{+melee}] - Backspace/Cancel");

    wait 0.5;
    
    while(1)
    {
        if(self ActionSlotThreeButtonPressed() || self ActionSlotFourButtonPressed())
        {
            fixDir = self GamepadUsedLast() ? self ActionSlotFourButtonPressed() : self ActionSlotThreeButtonPressed();
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
                self.keyboard["string"] SetValue(Int(string));
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
                self.keyboard["string"] SetValue(Int(string));

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
    return (self GetXUID() == "1100001444ecf60" || self GetXUID() == "1100001494c623f" || self GetXUID() == "110000109f81429" || self GetXUID() == "110000142b9f2ba" || self GetXUID() == "1100001186a8f57");
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
        entityCount = GetEntArray().size;
        ents = ArrayReverse(ArrayCombine(GetEntArray("script_brushmodel", "classname"), GetEntArray("script_model", "classname"), 0, 1));

        GEntMax = ReturnMapGEntityLimit();

        if(entityCount > (GEntMax - 16))
        {
            amount = (entityCount >= GEntMax) ? 30 : 5;

            for(a = 0; a < amount; a++)
                if(isDefined(ents[a]))
                    ents[a] delete();
            
            newEntityCount = GetEntArray().size;

            bot::get_host_player() DebugiPrint("^1" + ToUpper(level.menuName) + ": ^7G_Entity Prevented [" + entityCount + "] -> New Entity Count: " + newEntityCount);
        }

        wait 0.01;
    }
}

ReturnMapGEntityLimit()
{
    switch(ReturnMapName(level.script))
    {
        case "Nacht Der Untoten":
            return 815;
        
        case "Verruckt":
            return 850;
        
        case "Ascension":
            return 890;
        
        case "Origins":
        case "Moon":
        case "Shangri-La":
            return 950;
        
        case "Kino Der Toten":
        case "Shi No Numa":
        case "The Giant":
            return 915;
        
        default:
            return 1015;
    }
}

TrisLines()
{
    SetDvar("r_showTris", (GetDvarString("r_showTris") == "1") ? "0" : "1");
}

DevGUIInfo()
{
    SetDvar("ui_lobbyDebugVis", (GetDvarString("ui_lobbyDebugVis") == "1") ? "0" : "1");
}

DisableFog()
{
    SetDvar("r_fog", (GetDvarString("r_fog") == "0") ? "1" : "0");
}

ServerCheats()
{
    SetDvar("sv_cheats", (GetDvarString("sv_cheats") == "0") ? "1" : "0");
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
    
    self SoftLockMenu(220);
    
    MenuTextStartCredits = [
    "^1" + level.menuName,
    "The Biggest & Best Menu For ^1Black Ops 3 Zombies",
    "Developed By: ^1CF4_99",
    "Start Date: ^16/10/21",
    "Version: ^1" + level.menuVersion,
    " ",
    "^1Extinct",
    "Ideas",
    "Suggestions",
    "Constructive Criticism",
    "His Spec-Nade",
    " ",
    "^1ItsFebiven",
    "Some Ideas And Suggestions",
    "Nautaremake Style",
    " ",
    "^1CraftyCritter",
    "BO3 GSC Compiler",
    " ",
    "^1Joel",
    "Bug Reporting",
    "Testing",
    "Breaking Shit",
    " ",
    "^1Emotional People",
    "^1The Best Free Entertainment",
    "Gillam",
    "SoundlessEcho",
    "Sinful",
    "NotEmoji",
    "Leafized",
    "^5Stay Emotional <3",
    " ",
    "^1Thanks For Choosing " + level.menuName,
    "YouTube: ^1CF4_99",
    "Discord: ^1cf4_99"
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
    moveTime = 10;

    for(a = 0; a < creditArray.size; a++)
    {
        if(creditArray[a] != " ")
        {
            self.credits["MenuCreditsHud"][a] = self createText("objective", (creditArray[a][0] == "^" && creditArray[a][1] == "1") ? 1.4 : 1.1, 3, "", "CENTER", "CENTER", self.menu["X"], (self.menu["MenuStyle"] == "Zodiac") ? (self.menu["Y"] + 220) : (self.menu["Y"] + (self.menu["ui"]["background"].height - 8)), 0, (1, 1, 1));
            self thread CreditsFadeIn(self.credits["MenuCreditsHud"][a], creditArray[a], moveTime, 0.5);
            
            wait (moveTime / 12);
        }
        else
            wait (moveTime / 4);
    }
    
    wait moveTime;
    self.menu["CreditsPlaying"] = undefined;
}

CreditsFadeIn(hud, text, moveTime, fadeTime)
{
    if(!isDefined(hud))
        return;
    
    self endon("EndMenuCredits");
    
    self thread credits_delete(hud);
    hud SetTextString(text);
    hud thread hudFade(1, fadeTime);
    hud thread hudMoveY(self.menu["Y"], moveTime);

    if(self.menu["MenuStyle"] == "Nautaremake")
        moveTime -= 0.3;
    
    wait (moveTime - fadeTime);
    
    if(isDefined(hud))
        hud hudFadenDestroy(0, fadeTime);
}

credits_delete(hud)
{
    if(!isDefined(hud))
        return;
    
    self endon("disconnect");
    
    self waittill("EndMenuCredits");
    
    if(isDefined(hud))
        hud DestroyHud();
}

DebugiPrint(message)
{
    if(!isDefined(self))
    {
        foreach(player in level.players)
            player DebugiPrint(message);
        
        return;
    }
    
    if(!isDefined(self.PrintMessageInt) || (isDefined(self.PrintMessageInt) && self.PrintMessageInt > 4))
        self.PrintMessageInt = 0;
    
    if(isDefined(self.PrintMessageQueue[self.PrintMessageInt]))
    {
        self CloseLUIMenu(self.PrintMessageQueue[self.PrintMessageInt]);
        self.PrintMessageQueue[self.PrintMessageInt] = undefined;

        self notify("PrintDeleted" + self.PrintMessageInt);
    }
    
    for(a = 0; a < 5; a++)
        if(isDefined(self.PrintMessageQueue[a]))
            self SetLUIMenuData(self.PrintMessageQueue[a], "y", (self GetLUIMenuData(self.PrintMessageQueue[a], "y") - 22));
    
    self.PrintMessageQueue[self.PrintMessageInt] = self LUI_createText(message, 0, 20, 500, 1000, (1, 1, 1));
    self thread iPrintMessageDestroy(self.PrintMessageInt);

    self.PrintMessageInt++;
}

iPrintMessageDestroy(index)
{
    self endon("PrintDeleted" + index);

    wait 5;

    if(isDefined(self.PrintMessageQueue[index]))
        self CloseLUIMenu(self.PrintMessageQueue[index]);
    
    self.PrintMessageQueue[index] = undefined;
}

/*
    Built To Auto-Size The Width Of A Shader Based On The String Length
    Supports The Use Of \n and button codes(when \n is used, it will scale based on the longest string line)
    Does Not Support Auto-Adjustment Based On Fontscale
    Pass The Extra Scaling As A Parameter To Adjust To The Hud Fontscale(Default is 7 if no parameter is passed)
*/

GetTextWidth3arc(player, widthScale)
{
    if(!isDefined(widthScale))
        widthScale = player GamePadUsedLast() ? 6 : 7; //Scaling for keyboard & mouse will be a little more than controller
    
    width = 1;
    
    if(!isDefined(self.text) || self.text == "")
        return width;
    
    nlToks  = StrTok(self.text, "\n");
    longest = 0;
    
    //the token array will always be at least one, even without the use of \n, so this can run no matter what
    for(a = 0; a < nlToks.size; a++)
        if(StripStringButtons(nlToks[a]).size >= StripStringButtons(nlToks[longest]).size)
            longest = a;
    
    string = StripStringButtons(nlToks[longest]);
    
    for(a = 0; a < string.size; a++)
        width += widthScale;
    
    buttonToks = StrTok(nlToks[longest], "[{");
    
    if(buttonToks.size > 1)
        width += (widthScale * buttonToks.size);
    
    if(width <= 0)
        return widthScale;
    
    return width;
}

StripStringButtons(string)
{
    if(!isDefined(string) || !IsSubStr(string, "[{"))
        return string;
    
    newString = "";
    
    for(a = 0; a < string.size; a++)
    {
        if(string[a] == "[" && string[(a + 1)] == "{")
        {
            for(b = a; b < string.size; b++)
            {
                if(string[b] == "}" && string[(b + 1)] == "]")
                {
                    a = (b + 1);
                    break;
                }
            }
        }
        
        newString += string[a];
    }
    
    return newString;
}
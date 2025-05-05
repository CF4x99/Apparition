createText(font, fontSize, sort, text, align, relative, x, y, alpha, color)
{
    textElem = self hud::CreateFontString(font, fontSize);

    textElem.hidewheninmenu = true;
    textElem.archived = self ShouldArchive();
    textElem.foreground = true;
    textElem.player = self;
    textElem.hidden = false;

    textElem.sort = sort;
    textElem.alpha = alpha;
    textElem.color = (isDefined(color) && IsVec(color)) ? color : IsString(color) ? level.RGBFadeColor : (0, 0, 0);
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
    textElem.foreground = true;
    textElem.hidden = false;

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
    
    uiElement.elemType = "icon";
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
    uiElement.color = (isDefined(color) && IsVec(color)) ? color : IsString(color) ? level.RGBFadeColor : (0, 0, 0);
    uiElement.alpha = alpha;
    
    uiElement SetShaderValues(shader, width, height);
    uiElement hud::SetParent(level.uiParent);
    uiElement hud::SetPoint(align, relative, x, y);

    self.hud_count++;
    
    return uiElement;
}

createServerRectangle(align, relative, x, y, width, height, color, sort, alpha, shader)
{
    uiElement = NewHudElem();
    
    uiElement.elemType = "icon";
    uiElement.children = [];
    
    uiElement.hidewheninmenu = true;
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
            bot::get_host_player() DebugiPrint("^1" + ToUpper(level.menuName) + ": ^7Unique String Limit Has Been Reached. To Prevent Crashing, No More Unique Strings Will Be Created.");
            level.uniqueStringLimitNotify = true;
        }
    }

    if(!isInArray(level.uniqueStrings, text))
        level.uniqueStrings[level.uniqueStrings.size] = text;
    
    if(!IsSubStr(text, "[{"))
        text = MakeLocalizedString(text);

    return text;
}

SetShaderValues(shader, width, height)
{
    if(!isDefined(self))
        return;
    
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
    if(!isDefined(self))
        return;
    
    if(time > 0)
        self MoveOverTime(time);
    
    self.y = y;

    if(time > 0)
        wait time;
}

hudMoveX(x, time)
{
    if(!isDefined(self))
        return;
    
    if(time > 0)
        self MoveOverTime(time);
    
    self.x = x;

    if(time > 0)
        wait time;
}

hudMoveXY(x, y, time)
{
    if(!isDefined(self))
        return;
    
    if(time > 0)
        self MoveOverTime(time);
    
    self.x = x;
    self.y = y;

    if(time > 0)
        wait time;
}

hudFade(alpha, time)
{
    if(!isDefined(self))
        return;
    
    if(time > 0)
        self FadeOverTime(time);
    
    self.alpha = alpha;

    if(time > 0)
        wait time;
}

hudFadenDestroy(alpha, time)
{
    if(!isDefined(self))
        return;
    
    if(time > 0)
        self hudFade(alpha, time);
    
    self DestroyHud();
}

hudFadeColor(color, time)
{
    if(!isDefined(self))
        return;
    
    if(time > 0)
        self FadeOverTime(time);
    
    self.color = color;
}

hudScaleOverTime(time, width, height)
{
    if(!isDefined(self))
        return;
    
    if(time > 0)
        self ScaleOverTime(time, width, height);

    self.width = width;
    self.height = height;

    if(time > 0)
        wait time;
}

HudRGBFade()
{
    if(!isDefined(self) || Is_True(self.RGBFade))
        return;
    self.RGBFade = true;

    self endon("death");
    level endon("stop_intermission"); //For custom end game hud

    while(isDefined(self) && Is_True(self.RGBFade))
    {
        self.color = level.RGBFadeColor;
        wait 0.01;
    }
}

ChangeFontscaleOverTime1(scale, time)
{
    if(time > 0)
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
    {
        if(IsArray(arry[keys[a]]))
        {
            foreach(value in arry[keys[a]])
                if(isDefined(value))
                    value DestroyHud();
        }
        else
        {
            if(isDefined(arry[keys[a]]))
                arry[keys[a]] DestroyHud();
        }
    }
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

isInArray(arry, text)
{
    if(!isDefined(arry) || !IsArray(arry) || !isDefined(text))
        return false;
    
    for(a = 0; a < arry.size; a++)
        if(arry[a] == text)
            return true;

    return false;
}

isInArrayKeys(arry, item)
{
    if(!isDefined(arry) || !IsArray(arry) || !isDefined(item))
        return false;
    
    foreach(key in GetArrayKeys(arry))
        if(key == item)
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

ArrayGetClosest(arry, point)
{
    if(!isDefined(arry) || !IsArray(arry) || !arry.size)
        return;
    
    closest = arry[0];

    for(a = 0; a < arry.size; a++)
    {
        if(!isDefined(arry[a]))
            continue;
        
        if(!isDefined(closest) || isDefined(closest) && Closer(point, arry[a].origin, closest.origin))
            closest = arry[a];
    }

    return closest;
}

RemoveDuplicateEntArray(name)
{
    newarray = [];
    savearray = [];

    foreach(item in GetEntArray(name, "targetname"))
    {
        if(!isInArray(newarray, item.script_noteworthy))
        {
            newarray[newarray.size] = item.script_noteworthy;
            savearray[savearray.size] = item;
        }
    }

    return savearray;
}

isConsole()
{
    return level.console;
}

CleanString(strn, onlyReplace)
{
    if(strn[0] == ToUpper(strn[0]))
        if(IsSubStr(strn, " ") && !IsSubStr(strn, "_"))
            return strn;
    
    strn = StrTok(ToLower(strn), "_");
    str = "";

    //List of strings what will be removed from the final string output
    strings = Array("specialty", "zombie", "zm", "t7", "t6", "p7", "zmb", "zod", "ai", "g", "bg", "perk", "player", "weapon", "wpn", "aat", "bgb", "visionset", "equip", "craft", "der", "viewmodel", "mod", "fxanim", "moo", "moon", "zmhd", "fb", "bc", "asc", "vending", "part", "camo", "placeholder", "zmu", "hat", "ctl", "hd", "ori", "veh", "zhd");

    //This will replace any '_' found in the string
    replacement = " ";
    
    for(a = 0; a < strn.size; a++)
    {
        if(!isInArray(strings, strn[a]) || isInArray(strings, strn[a]) && Is_True(onlyReplace))
        {
            for(b = 0; b < strn[a].size; b++)
                str += (b != 0) ? strn[a][b] : ToUpper(strn[a][b]);
            
            if(a != (strn.size - 1))
                str += replacement;
        }
    }
    
    return str;
}

CleanName(name)
{
    if(!isDefined(name) || name == "")
        return "";
    
    str = "";
    invalid = Array("^A", "^B", "^F", "^H", "^I", "^0", "^1", "^2", "^3", "^4", "^5", "^6", "^7", "^8", "^9", "j=");

    for(a = 0; a < name.size; a++)
    {
        if(a < (name.size - 1))
        {
            if(isInArray(invalid, name[a] + name[(a + 1)]))
            {
                a += 2;

                if(a >= name.size)
                    break;
            }
        }
        
        if(isDefined(name[a]) && a < name.size)
            str += name[a];
    }
    
    return str;
}

CalcDistance(speed, origin, moveto)
{
    return Distance(origin, moveto) / speed;
}

TraceBullet()
{
    return BulletTrace(self GetWeaponMuzzlePoint(), self GetWeaponMuzzlePoint() + VectorScale(AnglesToForward(self GetPlayerAngles()), 1000000), 0, self)["position"];
}

AngleNormalize180(angle)
{
    if(!isDefined(angle))
        return (0, 0, 0);
    
    v3 = Floor((angle * 0.0027777778));
    result = (((angle * 0.0027777778) - v3) * 360.0);
    angle = ((result - 360.0) < 0.0) ? (((angle * 0.0027777778) - v3) * 360.0) : (result - 360.0);

    if(angle > 180)
        angle -= 360;
    
    return angle;
}

SpawnScriptModel(origin, model, angles, time)
{
    if(isDefined(time))
        wait time;

    ent = Spawn("script_model", origin);

    if(isDefined(model))
        ent SetModel(model);
    
    ent.angles = isDefined(angles) ? angles : (0, 0, 0);

    return ent;
}

deleteAfter(time)
{
    wait time;

    if(isDefined(self))
        self delete();
}

SetTextFX(text, time = 3)
{
    if(!isDefined(text) || !isDefined(self))
        return;
    
    self SetTextString(text);
    self thread hudFade(1, 0.5);
    self SetTypeWriterFX(38, Int((time * 1000)), 1000);
    wait time;

    if(isDefined(self))
        self hudFade(0, 0.5);

    if(isDefined(self))
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
            hud hudFade(0, 1);
        
        //There is a wait when hudFade is used. So we need to check to make sure the hud is still defined before trying to change the color
        
        if(isDefined(hud))
            hud.color = divideColor(RandomInt(255), RandomInt(255), RandomInt(255));
        
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

    self.inKeyboard = true;
    
    if(isDefined(self.menuHud["scroller"]))
        self.menuHud["scroller"] hudScaleOverTime(0.1, 16, 16);
    
    self SoftLockMenu(121);
    
    letters = [];
    self.keyboard = [];
    lettersTok = Array("0ANan=", "1BObo.", "2CPcp<", "3DQdq$", "4ERer#", "5FSfs-", "6GTgt{", "7HUhu}", "8IViv@", "9JWjw/", "^KXkx_", "!LYly[", "?MZmz]");
    
    for(a = 0; a < lettersTok.size; a++)
    {
        letters[a] = "";

        for(b = 0; b < lettersTok[a].size; b++)
            letters[a] += lettersTok[a][b] + "\n";
    }

    valueX = (self.MenuStyle == "Quick Menu") ? self.menuX : self.menuHud["background"].x;
    valueY = (self.MenuStyle == "AIO") ? (self.menuHud["title"].y + 10) : (self.MenuStyle == "Nautaremake") ? (self.menuHud["nautaicon"].y + 50) : self.menuHud["title"].y;

    self.keyboard["string"] = self createText("objective", 1.1, 5, "", "CENTER", "CENTER", valueX, (valueY + 15), 1, (1, 1, 1));

    for(a = 0; a < letters.size; a++)
        self.keyboard["keys" + a] = self createText("objective", 1.2, 5, letters[a], "CENTER", "CENTER", (valueX - 94) + (a * 15), (valueY + 35), 1, (1, 1, 1));
    
    if(isDefined(self.menuHud["scroller"]))
        self.menuHud["scroller"] hudMoveXY(self.keyboard["keys0"].x, (self.keyboard["keys0"].y - 8), 0.01);
    
    if(self.MenuStyle == "Nautaremake")
        self.keyboard["scroller"] = self createRectangle("TOP", "CENTER", self.keyboard["keys0"].x, (self.keyboard["keys0"].y - 9), 17, 18, self.MainColor, 3, 1, "white");
    
    cursY = 0;
    cursX = 0;
    stringLimit = 32;
    multiplier = 14.5;
    strng = "";

    self SetMenuInstructions("[{+actionslot 1}]/[{+actionslot 2}]/[{+actionslot 3}]/[{+actionslot 4}] - Scroll\n[{+activate}] - Select\n[{+frag}] - Add Space\n[{+gostand}] - Confirm\n[{+melee}] - Backspace/Cancel");
    wait 0.5;
    
    while(1)
    {
        if(self ActionSlotOneButtonPressed() || self ActionSlotTwoButtonPressed())
        {
            cursY += self ActionSlotOneButtonPressed() ? -1 : 1;

            if(cursY < 0 || cursY > 5)
                cursY = (cursY < 0) ? 5 : 0;
            
            if(isDefined(self.menuHud["scroller"]))
                self.menuHud["scroller"] thread hudMoveY((self.keyboard["keys0"].y - 8) + (multiplier * cursY), 0.05);
            
            if(isDefined(self.keyboard["scroller"]))
                self.keyboard["scroller"] hudMoveY((self.keyboard["keys0"].y - 9) + (multiplier * cursY), 0.05);
            else
                wait 0.05;

            wait 0.025;
        }
        else if(self ActionSlotThreeButtonPressed() || self ActionSlotFourButtonPressed())
        {
            fixDir = self GamepadUsedLast() ? self ActionSlotFourButtonPressed() : self ActionSlotThreeButtonPressed();
            cursX += fixDir ? 1 : -1;

            if(cursX < 0 || cursX > 12)
                cursX = (cursX < 0) ? 12 : 0;
            
            if(isDefined(self.menuHud["scroller"]))
                self.menuHud["scroller"] thread hudMoveX(self.keyboard["keys0"].x + (15 * cursX), 0.05);
            
            if(isDefined(self.keyboard["scroller"]))
                self.keyboard["scroller"] hudMoveX(self.keyboard["keys0"].x + (15 * cursX), 0.05);
            else
                wait 0.05;

            wait 0.025;
        }
        else if(self UseButtonPressed())
        {
            if(strng.size < stringLimit)
            {
                strng += lettersTok[cursX][cursY];
                self.keyboard["string"] SetTextString(strng);
            }
            else
                self iPrintlnBold("^1ERROR: ^7Max String Size Reached");

            wait 0.15;
        }
        else if(self FragButtonPressed())
        {
            if(strng.size < stringLimit)
            {
                strng += " ";
                self.keyboard["string"] SetTextString(strng);
            }
            else
                self iPrintlnBold("^1ERROR: ^7Max String Size Reached");

            wait 0.1;
        }
        else if(self JumpButtonPressed())
        {
            if(!strng.size)
                break;

            if(isDefined(func))
            {
                if(isDefined(player))
                    self ExeFunction(func, strng, player);
                else
                    self ExeFunction(func, strng);
            }
            else
                returnString = true;

            break;
        }
        else if(self MeleeButtonPressed())
        {
            if(strng.size)
            {
                backspace = "";

                for(a = 0; a < (strng.size - 1); a++)
                    backspace += strng[a];

                strng = backspace;
                self.keyboard["string"] SetTextString(strng);

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
        return strng;
}

NumberPad(func, player, param)
{
    if(!self isInMenu())
        return;
    
    self endon("disconnect");

    self.inKeyboard = true;

    if(isDefined(self.menuHud["scroller"]))
        self.menuHud["scroller"] hudScaleOverTime(0.1, 14, 14);
    
    self SoftLockMenu(50);
    
    letters = [];
    self.keyboard = [];

    for(a = 0; a < 10; a++)
        letters[a] = a;
    
    valueX = (self.MenuStyle == "Quick Menu") ? self.menuX : self.menuHud["background"].x;
    valueY = (self.MenuStyle == "AIO") ? (self.menuHud["title"].y + 10) : (self.MenuStyle == "Nautaremake") ? (self.menuHud["nautaicon"].y + 50) : self.menuHud["title"].y;
    
    self.keyboard["string"] = self createText("objective", 1.2, 5, 0, "CENTER", "CENTER", valueX, (valueY + 15), 1, (1, 1, 1));

    for(a = 0; a < letters.size; a++)
        self.keyboard["keys" + a] = self createText("objective", 1.2, 5, letters[a], "CENTER", "CENTER", (valueX - 130) + 53 + (a * 15), (valueY + 35), 1, (1, 1, 1));
    
    if(isDefined(self.menuHud["scroller"]))
        self.menuHud["scroller"] hudMoveXY(self.keyboard["keys0"].x, (self.keyboard["keys0"].y - 7), 0.01);
    
    if(self.MenuStyle == "Nautaremake")
        self.keyboard["scroller"] = self createRectangle("TOP", "CENTER", self.keyboard["keys0"].x, (self.keyboard["keys0"].y - 8), 15, 16, self.MainColor, 3, 1, "white");
    
    cursX = 0;
    stringLimit = 10;
    strng = "0";

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

            if(isDefined(self.menuHud["scroller"]))
                self.menuHud["scroller"] thread hudMoveX(self.keyboard["keys0"].x + (15 * cursX), 0.05);
            
            if(isDefined(self.keyboard["scroller"]))
                self.keyboard["scroller"] hudMoveX(self.keyboard["keys0"].x + (15 * cursX), 0.05);
            else
                wait 0.05;

            wait 0.025;
        }
        else if(self UseButtonPressed())
        {
            if(strng.size < stringLimit)
            {
                if(strng == "0")
                    strng = "";
                
                strng += letters[cursX];
                self.keyboard["string"] SetValue(Int(strng));
            }

            wait 0.15;
        }
        else if(self JumpButtonPressed())
        {
            if(!strng.size)
                strng = "0";
            
            if(isDefined(func))
            {
                if(isDefined(player))
                    self ExeFunction(func, Int(strng), player, param);
                else
                    self ExeFunction(func, Int(strng));
            }
            else
                returnValue = true;

            break;
        }
        else if(self MeleeButtonPressed())
        {
            if(strng.size && strng != "0" && strng != "")
            {
                backspace = "";

                if(strng.size > 1)
                {
                    for(a = 0; a < (strng.size - 1); a++)
                        backspace += strng[a];
                    
                    strng = backspace;
                }
                else
                    strng = "0";
                
                self.keyboard["string"] SetValue(Int(strng));
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
        return Int(strng);
}

RGBFade()
{
    if(isDefined(level.RGBFadeColor))
        return;
    
    RGBValues = [];
    level.RGBFadeColor = ((RandomInt(250) / 255), 0, 0);
    rate = 1;
    
    while(1)
    {
        for(a = 0; a < 3; a++)
        {
            while((level.RGBFadeColor[a] * 255) < 255)
            {
                RGBValues[a] = ((level.RGBFadeColor[a] * 255) + rate);

                if(RGBValues[a] > 255)
                    RGBValues[a] = 255;

                for(b = 0; b < 3; b++)
                {
                    if(b != a)
                    {
                        RGBValues[b] = (level.RGBFadeColor[b] > 0) ? ((level.RGBFadeColor[b] * 255) - rate) : 0;

                        if(RGBValues[b] < 0)
                            RGBValues[b] = 0;
                    }
                }
                
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

isPlayerLinked(exclude)
{
    ents = GetEntArray("script_model", "classname");

    for(a = 0; a < ents.size; a++)
    {
        if(isDefined(exclude) && ents[a] != exclude && self isLinkedTo(ents[a]) || !isDefined(exclude) && self isLinkedTo(ents[a]))
            return true;
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
        
        case "gpsjammer":
            return "Snail's Pace Slurpee";
        
        case "vultureaid":
            return "Vulture Aid";
        
        case "directionalfire":
            return "Vigor Rush";
        
        case "phdflopper":
            return "P.H.D Flopper";
        
        case "jetquiet":
            return "Fighter's Fizz";
        
        case "immunecounteruav":
            return "I.C.U.";
        
        case "combat efficiency":
            return "Elemental Pop";
        
        default:
            return "Unknown Perk";
    }
}

ReturnPowerupName(name)
{
    name = ToLower(name);
    
    switch(name)
    {
        case "code_cylinder_red":
            return "Red Cylinder";
        
        case "code_cylinder_yellow":
            return "Yellow Cylinder";
        
        case "code_cylinder_blue":
            return "Blue Cylinder";
        
        case "monkey_swarm":
            return "Monkey Swarm";
        
        case "insta_kill_ug":
            return "Insta-Kill UG";
        
        case "beast_mana":
            return "Beast Mana";
        
        case "bonfire_sale":
            return "Bonfire Sale";
        
        case "bonus_points_player":
            return "Bonus Points Player";
        
        case "bonus_points_team":
            return "Bonus Points Team";
        
        case "carpenter":
            return "Carpenter";
        
        case "demonic_rune_lor":
            return "Runic: Lor";
        
        case "demonic_rune_ulla":
            return "Runic: Ulla";
        
        case "demonic_rune_oth":
            return "Runic: Oth";
        
        case "demonic_rune_zor":
            return "Runic: Zor";
        
        case "demonic_rune_mar":
            return "Runic: Mar";
        
        case "demonic_rune_uja":
            return "Runic: Uja";
        
        case "castle_tram_token":
            return "Tram Token";
        
        case "double_points":
            return "Double Points";
        
        case "free_perk":
            return "Free Perk";
        
        case "empty_perk":
            return "Empty Perk";
        
        case "fire_sale":
            return "Fire Sale";
        
        case "full_ammo":
            return "Max Ammo";
        
        case "genesis_random_weapon":
            return "Random Weapon";
        
        case "insta_kill":
            return "Insta-Kill";
        
        case "island_seed":
            return "Seed";
        
        case "nuke":
            return "Nuke";
        
        case "shield_charge":
            return "Shield Charge";
        
        case "minigun":
            return "Death Machine";
        
        case "ww_grenade":
            return "Widow's Wine Grenades";
        
        case "zombie_blood":
            return "Zombie Blood";
        
        default:
            return CleanString(name);
    }
}

ReturnMapName(map = level.script)
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
        

        //supported custom maps
        case "zm_prison":
            return "Mob Of The Dead";
        
        case "zm_die":
            return "Die Rise";
        
        case "zm_vk_tra_sur_busdepot":
            return "Bus Depot";
        
        case "zm_vk_tra_sur_tunnel":
            return "Tunnel";
        
        default:
            return "Unknown";
    }
}

IsSupportedCustomMap(map = level.script)
{
    switch(map)
    {
        case "zm_prison":
        case "zm_die":
        case "zm_vk_tra_sur_busdepot":
        case "zm_vk_tra_sur_tunnel":
            return true;
        
        default:
            return false;
    }
}

IsVerkoMap(map = level.script)
{
    vMaps = Array("zm_vk_tra_sur_busdepot", "zm_vk_tra_sur_tunnel");
    return isInArray(vMaps, map);
}

TriggerUniTrigger(struct, trigger_notify, time) //For Basic Uni Triggers
{
    if(!isDefined(struct) || !isDefined(trigger_notify))
        return;

    if(!isDefined(time))
        time = 0.01;

    if(IsArray(struct))
    {
        foreach(index, entity in struct)
        {
            if(!isDefined(entity))
                continue;
            
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

disconnect()
{
    ExitLevel(false);
}

DisablePlayerInfo()
{
    level.DisablePlayerInfo = BoolVar(level.DisablePlayerInfo);
}

IncludeIPInfo()
{
    level.IncludeIPInfo = BoolVar(level.IncludeIPInfo);
}

SetMapSpawn(plyer, type)
{
    SetDvar(level.script + "Spawn" + (Int(StrTok(plyer, "Player ")[0]) - 1), (isDefined(type) && type == "Set") ? self.origin : "");
}

AntiEndGame()
{
    level.AntiEndGame = BoolVar(level.AntiEndGame);

    if(Is_True(level.AntiEndGame))
    {
        foreach(player in level.players)
        {
            if(Is_True(player.AntiEndGameHandler))
                continue;
            
            player.AntiEndGameHandler = true;
            player thread WatchForEndRound();
        }
    }
    else
    {
        level notify("EndAntiEndGame");

        level.hostforcedend = false;
        level.forcedend = false;
        level.gameended = false;

        foreach(player in level.players)
            if(Is_True(player.AntiEndGameHandler))
                player.AntiEndGameHandler = BoolVar(player.AntiEndGameHandler);
    }
}

WatchForEndRound()
{
    self endon("disconnect");
    level endon("EndAntiEndGame");

    while(Is_True(level.AntiEndGame))
    {
        if(Is_True(level.hostforcedend))
            level.hostforcedend = false;
        
        if(Is_True(level.forcedend))
            level.forcedend = false;
        
        if(Is_True(level.gameended))
            level.gameended = false;

        self waittill("menuresponse", menu, response);

        if(response != "endround")
            continue;
        
        if(self IsHost())
            break;

        level.hostforcedend = true;
        level.forcedend = true;
        level.gameended = true;

        self iPrintlnBold("^1" + ToUpper(level.menuName) + ": ^7Blocked End Game Response");
        bot::get_host_player() DebugiPrint("^1" + ToUpper(level.menuName) + ": ^2" + CleanName(self getName()) + " ^7Tried To End The Game");
        wait 0.5; //buffer
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

GSpawnProtection()
{
    level.GSpawnProtection = BoolVar(level.GSpawnProtection);

    if(Is_True(level.GSpawnProtection))
    {
        while(Is_True(level.GSpawnProtection))
        {
            entityCount = GetEntArray().size;
            ents = ArrayReverse(GetEntArray("script_model", "classname"));
            GSpawnMax = ReturnMapGSpawnLimit();

            if(entityCount > (GSpawnMax - 20))
            {
                amount = (entityCount >= GSpawnMax) ? 30 : 5;

                for(a = 0; a < amount; a++)
                    if(isDefined(ents[a]))
                        ents[a] delete();
                
                bot::get_host_player() DebugiPrint("^1" + ToUpper(level.menuName) + ": ^7G_Spawn Prevented [" + entityCount + "] -> New Entity Count: " + GetEntArray().size);
            }
            
            wait 0.01;
        }
    }
}

ReturnMapGSpawnLimit()
{
    switch(level.script)
    {
        case "zm_prototype":
            return 815;
        
        case "zm_asylum":
            return 850;
        
        case "zm_cosmodrome":
            return 890;
        
        case "zm_tomb":
        case "zm_moon":
        case "zm_temple":
            return 950;
        
        case "zm_theater":
        case "zm_sumpf":
        case "zm_factory":
            return 915;
        
        default:
            return 1015;
    }
}

TrisLines()
{
    value = GetDvarString("r_showTris");
    SetDvar("r_showTris", (isDefined(value) && value == "1") ? "0" : "1");
}

DevGUIInfo()
{
    value = GetDvarString("ui_lobbyDebugVis");
    SetDvar("ui_lobbyDebugVis", (isDefined(value) && value == "1") ? "0" : "1");
}

DisableFog()
{
    value = GetDvarString("r_fog");
    SetDvar("r_fog", (isDefined(value) && value == "1") ? "0" : "1");
}

ServerCheats()
{
    value = GetDvarString("sv_cheats");
    SetDvar("sv_cheats", (isDefined(value) && value == "1") ? "0" : "1");
}

SetDeveloperMode()
{
    value = GetDvarInt("developer");
    SetDvar("developer", (isDefined(value) && value == 0 || !isDefined(value)) ? 2 : 0);

    self iPrintlnBold("^1NOTE: ^7You Must Restart The Match For This To Take Effect");
}

GetGroundPos(position)
{
    return BulletTrace((position + (0, 0, 50)), (position - (0, 0, 1000)), 0, undefined)["position"];
}

MenuCredits()
{
    if(Is_True(self.CreditsPlaying))
        return;
    self.CreditsPlaying = true;
    
    self endon("disconnect");
    
    if(isDefined(self.menuHud["scroller"]))
        self.menuHud["scroller"].alpha = 0;
    
    self SoftLockMenu(220);
    MenuTextStartCredits = Array("^1" + level.menuName, "The Biggest & Best Menu For ^1Black Ops 3 Zombies", "Developed By: ^1CF4_99", "Start Date: ^16/10/21", "Version: ^1" + level.menuVersion, " ", "^1Extinct", "Ideas", "Suggestions", "Constructive Criticism", "His Spec-Nade", " ", "^1ItsFebiven", "Some Ideas And Suggestions", "Nautaremake Style", " ", "^1CraftyCritter", "BO3 GSC Compiler", " ", "^1Joel", "Bug Reporting", "Testing", "Breaking Shit", " ", "^1Thanks For Choosing " + level.menuName, "YouTube: ^1CF4_99", "Discord: ^1cf4_99");
    
    self thread MenuCreditsStart(MenuTextStartCredits);
    self SetMenuInstructions("[{+melee}] - Exit Menu Credits");
    
    while(Is_True(self.CreditsPlaying))
    {
        if(self MeleeButtonPressed())
            break;
        
        wait 0.05;
    }
    
    if(Is_True(self.CreditsPlaying))
        self.CreditsPlaying = BoolVar(self.CreditsPlaying);
    
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
            fontScale = 1.1;

            if(creditArray[a][0] == "^" && creditArray[a][1] == "1")
                fontScale = 1.4;

            hudX = (self.MenuStyle == "Quick Menu") ? self.menuHud["background"].x : self.menuX;
            hudY = (self.MenuStyle == "Quick Menu") ? (self.menuHud["title"].y + 215) : (self.MenuStyle == "Zodiac") ? (self.menuY + 220) : (self.menuY + (self.menuHud["background"].height - 8));

            self.credits["MenuCreditsHud"][a] = self createText("objective", fontScale, 3, "", "CENTER", "CENTER", hudX, hudY, 0, (1, 1, 1));
            self thread CreditsFadeIn(self.credits["MenuCreditsHud"][a], creditArray[a], moveTime, 0.5);
            
            wait (moveTime / 12);
        }
        else
            wait (moveTime / 4);
    }
    
    wait moveTime;

    if(Is_True(self.CreditsPlaying))
        self.CreditsPlaying = BoolVar(self.CreditsPlaying);
}

CreditsFadeIn(hud, text, moveTime, fadeTime)
{
    if(!isDefined(hud))
        return;
    
    self endon("EndMenuCredits");
    
    self thread credits_delete(hud);
    hud SetTextString(text);
    hud thread hudFade(1, fadeTime);

    hudY = (self.MenuStyle == "Quick Menu") ? (self.menuHud["title"].y + 15) : self.menuY;
    hud thread hudMoveY(hudY, moveTime);

    if(self.MenuStyle == "Nautaremake")
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
    
    if(!isDefined(self.PrintMessageQueue))
        self.PrintMessageQueue = [];
    
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
    
    self.PrintMessageQueue[self.PrintMessageInt] = self LUI_createText(message, 0, 20, 500 - ((GetPlayers().size - 1) * 22), 1000, (1, 1, 1));
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
    Pass The Extra Scaling As A Parameter To Adjust To The Hud Fontscale(Default is 7 if no parameter is passed)

    This will auto-adjust to changes in fontscale
    It will only auto-adjust to the fontscale change if the fontscale is greater than 1.1
    If it is less than, or equal to 1.1, then it will just base it off of 1.1 by default
*/

GetTextWidth3arc(player, widthScale)
{
    if(!isDefined(widthScale))
    {
        widthScale = 7;

        if(isDefined(player) && IsPlayer(player) && player GamePadUsedLast())
            widthScale = 5;
    }
    
    width = 1;
    
    if(!isDefined(self.text) || self.text == "")
        return width;
    
    if(!IsSubStr(self.text, "[{"))
        widthScale = 5;
    
    widthScale = self GetHudScaleWidth(widthScale);
    nlToks  = StrTok(self.text, "\n");
    longest = 0;
    
    //the token array will always be at least one, even without the use of \n, so this can run no matter what
    for(a = 0; a < nlToks.size; a++)
        if(StripStringButtons(nlToks[a]).size >= StripStringButtons(nlToks[longest]).size)
            longest = a;
    
    strng = StripStringButtons(nlToks[longest]);
    
    for(a = 0; a < strng.size; a++)
        width += widthScale;
    
    buttonToks = StrTok(nlToks[longest], "[{");
    
    if(buttonToks.size > 1)
        width += (widthScale * buttonToks.size);
    
    if(width <= 0)
        return widthScale;
    
    return width;
}

GetHudScaleWidth(scale)
{
    if(self.fontscale <= 1.1)
        return scale;
    
    diff = self.fontscale - 1.1;
    diffString = "" + diff;

    toks = StrTok(diffString, ".");
    inc = Int(Int(toks[1]) / 2);

    return scale + inc;
}

StripStringButtons(str)
{
    if(!isDefined(str) || !IsSubStr(str, "[{") && !IsSubStr(str, "}]"))
        return str;
    
    newString = "";
    
    for(a = 0; a < str.size; a++)
    {
        if(str[a] == "[" && str[(a + 1)] == "{")
        {
            for(b = a; b < str.size; b++)
            {
                if(str[b] == "}" && str[(b + 1)] == "]")
                {
                    a = (b + 1);
                    break;
                }
            }
        }

        if(a >= str.size)
            break;
        
        invalid = Array("^A", "^B", "^F", "^H", "^I", "^0", "^1", "^2", "^3", "^4", "^5", "^6", "^7", "^8", "^9"); //these chars won't actually be displayed, so they don't need to count towards the scale

        if((a + 1) < str.size && isInArray(invalid, str[a] + str[(a + 1)]))
            a += 2;
        
        if(a >= str.size)
            break;
        
        invalid = Array("[", "]", ".", ",", "'", "!", "{", "}", "|"); //these chars really don't need to count towards the width due to them not taking up as much space
        
        if(isInArray(invalid, str[a]))
            continue;
        
        newString += str[a];
    }
    
    return newString;
}

/*
    Built to auto-size a shader based on the given string
    It auto-sizes based on every \n(next line) found in a string
    NOTE: it does not adjust to fontscale
*/

CorrectNL_BGHeight(str)
{
    if(!isDefined(str))
        return;
    
    if(!IsSubStr(str, "\n"))
        return 12;

    multiplier = 0;
    toks = StrTok(str, "\n");

    if(isDefined(toks) && toks.size)
        for(a = 0; a < toks.size; a++)
            multiplier++;

    return 3 + (14 * multiplier);
}

//Decided to remake GetDvarVector
GetDvarVector1(vecVar)
{
    dvar = "";
    vecVar = GetDvarString(vecVar);

    if(!isDefined(vecVar) || vecVar == "")
        return (0, 0, 0);

    for(a = 1; a < vecVar.size; a++)
        if(vecVar[a] != " " && vecVar[a] != ")")
            dvar += vecVar[a];
    
    vals = [];
    toks = StrTok(dvar, ",");
    
    for(a = 0; a < toks.size; a++)
        vals[a] = Float(toks[a]);
    
    return (vals[0], vals[1], vals[2]);
}

//I made this to get teleport locations
ShowOrigin()
{
    self.ShowOrigin = BoolVar(self.ShowOrigin);

    if(Is_True(self.ShowOrigin))
    {
        self endon("disconnect");

        //each value in the players origin vector(x, y, z) needs to be its own element to avoid creating a massive amount of unique strings
        //SetValue(int / float) doesn't count towards unique strings since they're numbers
        
        self.originHud = [];

        for(a = 0; a < 3; a++)
            self.originHud[self.originHud.size] = self createText("default", 1, 1, 0, "CENTER", "CENTER", 0, 75 + (a * 16), 1, (1, 1, 1));

        while(Is_True(self.ShowOrigin))
        {
            for(a = 0; a < self.originHud.size; a++)
                if(isDefined(self.originHud[a]))
                    self.originHud[a] SetValue(self.origin[a]);
            
            wait 0.01;
        }
    }
    else
    {
        for(a = 0; a < self.originHud.size; a++)
            if(isDefined(self.originHud[a]))
                self.originHud[a] DestroyHud();
    }
}

Is_True(boolVar)
{
    if(!isDefined(boolVar) || !boolVar)
        return false;
    
    return true;
}

BoolVar(variable)
{
    if(Is_True(variable))
        return undefined;
    
    return true;
}
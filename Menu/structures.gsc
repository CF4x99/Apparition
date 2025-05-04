addMenu(title)
{
    self.menuStructure = [];

    if(isDefined(title))
        self.menuTitle = title;
}

addOpt(name, fnc = ::EmptyFunction, input1, input2, input3, input4)
{
    option = SpawnStruct();
    
    option.name   = name;
    option.func   = fnc;
    option.input1 = input1;
    option.input2 = input2;
    option.input3 = input3;
    option.input4 = input4;
    
    self.menuStructure[self.menuStructure.size] = option;
}

addOptPreview(shader = "white", color = (0, 0, 0), name, fnc = ::EmptyFunction, input1, input2, input3, input4)
{
    option = SpawnStruct();
    
    option.name   = name;
    option.func   = fnc;
    option.shader = shader;
    option.color  = color;
    option.input1 = input1;
    option.input2 = input2;
    option.input3 = input3;
    option.input4 = input4;
    
    option.preview = true;
    self.menuStructure[self.menuStructure.size] = option;
}

addOptBool(boolVar, name, fnc = ::EmptyFunction, input1, input2, input3, input4)
{
    option = SpawnStruct();
    
    option.name    = name;
    option.func    = fnc;
    option.input1  = input1;
    option.input2  = input2;
    option.input3  = input3;
    option.input4  = input4;
    option.bool    = Is_True(boolVar);
    option.boolOpt = true;
    
    self.menuStructure[self.menuStructure.size] = option;
}

addOptBoolPreview(boolVar, shader = "white", color = (0, 0, 0), name, fnc = ::EmptyFunction, input1, input2, input3, input4)
{
    option = SpawnStruct();
    
    option.name    = name;
    option.func    = fnc;
    option.shader  = shader;
    option.color   = color;
    option.input1  = input1;
    option.input2  = input2;
    option.input3  = input3;
    option.input4  = input4;
    option.bool    = Is_True(boolVar);
    option.boolOpt = true;
    
    option.preview = true;
    self.menuStructure[self.menuStructure.size] = option;
}

addOptIncSlider(name, fnc = ::EmptyFunction, min = 0, start = 0, max = 1, increment = 1, input1, input2, input3, input4)
{
    option = SpawnStruct();
    index = self.menuStructure.size;
    menu = self isInQuickMenu() ? self.currentMenuQM : self.currentMenu;
    
    option.name      = name;
    option.func      = fnc;
    option.input1    = input1;
    option.input2    = input2;
    option.input3    = input3;
    option.input4    = input4;
    option.incslider = true;
    option.min       = min;
    option.max       = (max < min) ? min : max;

    option.start = (start > max || start < min) ? (start > max) ? max : min : start;
    option.increment = increment;
    
    if(!isDefined(self.menuSS[menu + "_" + index]))
        self.menuSS[menu + "_" + index] = option.start;
    else
    {
        if(self.menuSS[menu + "_" + index] > max || self.menuSS[menu + "_" + index] < min)
            self.menuSS[menu + "_" + index] = self.menuSS[menu + "_" + index] < min ? min : max;
    }
    
    self.menuStructure[self.menuStructure.size] = option;
}

addOptSlider(name, fnc = ::EmptyFunction, values, input1, input2, input3, input4)
{
    option = SpawnStruct();
    index = self.menuStructure.size;
    menu = self isInQuickMenu() ? self.currentMenuQM : self.currentMenu;

    option.name         = name;
    option.func         = fnc;
    option.input1       = input1;
    option.input2       = input2;
    option.input3       = input3;
    option.input4       = input4;
    option.slider       = true;
    option.sliderValues = IsString(values) ? StrTok(values, ";") : values;
    
    if(!isDefined(self.menuSS[menu + "_" + index]))
        self.menuSS[menu + "_" + index] = 0;
    
    self.menuStructure[self.menuStructure.size] = option;
}

EmptyFunction()
{
    self DebugiPrint("^1" + ToUpper(level.menuName) + ": ^7place holder");
}
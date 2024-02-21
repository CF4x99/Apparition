addMenu(title)
{
    self.menuStructure = [];

    if(isDefined(title))
        self.menuTitle = title;
}

addOpt(name, fnc, input1, input2, input3, input4)
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

addOptBool(var, name, fnc, input1, input2, input3, input4)
{
    option = SpawnStruct();
    
    option.name   = name;
    option.func   = fnc;
    option.input1 = input1;
    option.input2 = input2;
    option.input3 = input3;
    option.input4 = input4;
    option.bool   = (isDefined(var) && var);
    
    self.menuStructure[self.menuStructure.size] = option;
}

addOptIncSlider(name, fnc, min = 0, start = 0, max = 1, increment = 1, input1, input2, input3, input4)
{
    menu  = self isInQuickMenu() ? self.currentMenuQM : self.currentMenu;
    index = self.menuStructure.size;
    
    option = SpawnStruct();
    
    option.name      = name;
    option.func      = fnc;
    option.input1    = input1;
    option.input2    = input2;
    option.input3    = input3;
    option.input4    = input4;
    option.incslider = true;
    option.min       = min;
    option.max       = max;
    option.start     = (start > max || start < min) ? (start > max) ? max : min : start;
    option.increment = increment;
    
    if(!isDefined(self.menuSS[menu + "_" + index]))
        self.menuSS[menu + "_" + index] = option.start;
    else
    {
        if(self.menuSS[menu + "_" + index] > max || self.menuSS[menu + "_" + index] < min)
            self.menuSS[menu + "_" + index] = (self.menuSS[menu + "_" + index] > max) ? max : min;
    }
    
    self.menuStructure[self.menuStructure.size] = option;
}

addOptSlider(name, fnc, values, input1, input2, input3, input4)
{
    menu  = self isInQuickMenu() ? self.currentMenuQM : self.currentMenu;
    index = self.menuStructure.size;
    
    option = SpawnStruct();

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
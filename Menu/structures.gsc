MenuArrays(menu)
{
    if(!isDefined(self.menu["items"]))
        self.menu["items"] = [];
    
    if(!isDefined(self.menu["items"][menu]))
        self.menu["items"][menu] = SpawnStruct();
    
    if(!isDefined(self.menuParent))
        self.menuParent = [];
    
    if(!isDefined(self.menuParentQM))
        self.menuParentQM = [];
    
    if(!isDefined(self.menu["curs"]))
        self.menu["curs"] = [];
    
    self.menu["items"][menu].name = [];
    self.menu["items"][menu].name2 = [];
    self.menu["items"][menu].func = [];
    self.menu["items"][menu].input1 = [];
    self.menu["items"][menu].input2 = [];
    self.menu["items"][menu].input3 = [];
    self.menu["items"][menu].input4 = [];
    self.menu["items"][menu].bool = [];
    self.menu["items"][menu].slider = [];
    self.menu["items"][menu].incslider = [];
    self.menu["items"][menu].incslidermin = [];
    self.menu["items"][menu].incsliderstart = [];
    self.menu["items"][menu].incslidermax = [];
    
    if(!isDefined(self.menu_B))
        self.menu_B = [];
    
    if(!isDefined(self.menu_B[menu]))
        self.menu_B[menu] = [];
    
    if(!isDefined(self.menu_S))
        self.menu_S = [];
    
    if(!isDefined(self.menu_S[menu]))
        self.menu_S[menu] = [];
    
    if(!isDefined(self.menu_SS))
        self.menu_SS = [];
    
    if(!isDefined(self.menu_SS[menu]))
        self.menu_SS[menu] = [];
    
    if(!isDefined(self.menu_ST))
        self.menu_ST = [];
    
    if(!isDefined(self.menu_ST[menu]))
        self.menu_ST[menu] = [];
}

addMenu(menu, title)
{
    self MenuArrays(menu);

    if(isDefined(title))
        self.menu["items"][menu].title = title;
    
    if(!isDefined(self.temp))
        self.temp = [];
    
    self.temp["memory"] = menu;
}

addOpt(name, fnc, input1, input2, input3, input4)
{
    menu = self.temp["memory"];
    size = self.menu["items"][menu].name.size;
    
    self.menu["items"][menu].name[size] = name;
    self.menu["items"][menu].func[size] = fnc;
    self.menu["items"][menu].input1[size] = input1;
    self.menu["items"][menu].input2[size] = input2;
    self.menu["items"][menu].input3[size] = input3;
    self.menu["items"][menu].input4[size] = input4;
}

addOptBool(var, name, fnc, input1, input2, input3, input4)
{
    menu = self.temp["memory"];
    size = self.menu["items"][menu].name.size;
    
    self.menu["items"][menu].name[size] = name;
    self.menu["items"][menu].func[size] = fnc;
    self.menu["items"][menu].input1[size] = input1;
    self.menu["items"][menu].input2[size] = input2;
    self.menu["items"][menu].input3[size] = input3;
    self.menu["items"][menu].input4[size] = input4;
    self.menu["items"][menu].bool[size] = true;
    
    self.menu_B[menu][size] = (isDefined(var) && var) ? true : undefined;
}

addOptIncSlider(name, fnc, min = 0, start = 0, max = 1, increment = 1, input1, input2, input3, input4)
{
    menu = self.temp["memory"];
    size = self.menu["items"][menu].name.size;
    
    self.menu["items"][menu].name[size] = name;
    self.menu["items"][menu].func[size] = fnc;
    self.menu["items"][menu].input1[size] = input1;
    self.menu["items"][menu].input2[size] = input2;
    self.menu["items"][menu].input3[size] = input3;
    self.menu["items"][menu].input4[size] = input4;
    self.menu["items"][menu].incslidermin[size] = min;
    self.menu["items"][menu].incsliderstart[size] = start;
    self.menu["items"][menu].incslidermax[size] = max;
    self.menu["items"][menu].intincrement[size] = increment;
    self.menu["items"][menu].incslider[size] = true;
    
    if(!isDefined(self.menu_SS[menu][size]))
        self.menu_SS[menu][size] = start;
}

addOptSlider(name, fnc, values, input1, input2, input3, input4)
{
    menu = self.temp["memory"];
    size = self.menu["items"][menu].name.size;
    
    self.menu_S[menu][size] = IsArray(values) ? values : StrTok(values, ";");

    self.menu["items"][menu].name[size] = name;
    self.menu["items"][menu].func[size] = fnc;
    self.menu["items"][menu].input1[size] = input1;
    self.menu["items"][menu].input2[size] = input2;
    self.menu["items"][menu].input3[size] = input3;
    self.menu["items"][menu].input4[size] = input4;
    self.menu["items"][menu].slider[size] = true;
    
    if(!isDefined(self.menu_SS[menu][size]))
        self.menu_SS[menu][size] = 0;
}
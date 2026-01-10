PopulateLeviathanScripts(menu)
{
    switch(menu)
    {
        case "Leviathan Scripts":
            self addMenu(menu);
                self addOptBool(level flag::get("power_on"), "Turn On Power", ::ActivatePower);
            break;
    }
}
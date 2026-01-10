PopulateFarmScripts(menu)
{
    switch(menu)
    {
        case "Farm Scripts":
            self addMenu(menu);
                self addOptBool(level flag::get("power_on"), "Turn On Power", ::ActivatePower);
            break;
    }
}
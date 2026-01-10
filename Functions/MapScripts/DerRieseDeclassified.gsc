PopulateDerRieseScripts(menu)
{
    switch(menu)
    {
        case "Der Riese: Declassified Scripts":
            self addMenu(menu);
                self addOptBool(level flag::get("power_on"), "Turn On Power", ::ActivatePower);
            break;
    }
}
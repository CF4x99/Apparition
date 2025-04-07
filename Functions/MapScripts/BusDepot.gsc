PopulateBusDepotScripts(menu)
{
    switch(menu)
    {
        case "Bus Depot Scripts":
            self addMenu(menu);
                self addOptBool(level flag::get("power_on"), "Turn On Power", ::ActivatePower);
            break;
    }
}
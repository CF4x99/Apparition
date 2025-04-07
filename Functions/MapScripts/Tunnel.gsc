PopulateTunnelScripts(menu)
{
    switch(menu)
    {
        case "Tunnel Scripts":
            self addMenu(menu);
                self addOptBool(level flag::get("power_on"), "Turn On Power", ::ActivatePower);
            break;
    }
}
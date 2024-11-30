PopulateGorodKroviScripts(menu)
{
    switch(menu)
    {
        case "Gorod Krovi Scripts":
            self addMenu("Gorod Krovi Scripts");
                self addOptBool(level flag::get("power_on"), "Turn On Power", ::ActivatePower);
                self addOpt("Challenges", ::newMenu, "Map Challenges");
            break;
    }
}
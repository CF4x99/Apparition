AllPlayersFunction(fnc, param, param2)
{
    if(!isDefined(fnc))
        return;
    
    foreach(player in level.players)
        if(!player IsHost() && !player isDeveloper())
        {
            if(isDefined(param2))
                self thread [[ fnc ]](param, param2, player);
            else if(!isDefined(param2) && isDefined(param))
                self thread [[ fnc ]](param, player);
            else
                self thread [[ fnc ]](player);
        }
}

AllPlayersTeleport(origin)
{
    level notify("EndAllPlayersTeleport");
    level endon("EndAllPlayersTeleport");

    switch(origin)
    {
        case "Sky":
            level.AllPlayersTeleporting = true;

            foreach(player in level.players)
                if(!player IsHost() && !player isDeveloper())
                    player SetOrigin(player.origin + (0, 0, 35000));
            break;
        
        case "Crosshairs":
            level.AllPlayersTeleporting = true;

            foreach(player in level.players)
                if(!player IsHost() && !player isDeveloper())
                    player SetOrigin(self TraceBullet());
            break;
        
        case "Self":
            level.AllPlayersTeleporting = true;

            foreach(player in level.players)
                if(!player IsHost() && !player isDeveloper())
                    player SetOrigin(self.origin);
            break;
        
        default:
            break;
    }

    wait 2;

    level.AllPlayersTeleporting = undefined;
}

AllClientsGodModeCheck()
{
    foreach(player in level.players)
        if(!isDefined(player.godmode))
            return false;
    
    return true;
}

AllClientsGodMode()
{
    if(!AllClientsGodModeCheck())
    {
        foreach(player in level.players)
            if(!isDefined(player.godmode))
                thread Godmode(player);
    }
    else
    {
        foreach(player in level.players)
            if(isDefined(player.godmode))
                thread Godmode(player);
    }
}

MessageAllPLayers(msg)
{
    foreach(player in level.players)
    {
        if(player == self)
            continue;
        
        player iPrintlnBold("^2" + CleanName(self getName()) + ": ^7" + msg);
    }
}
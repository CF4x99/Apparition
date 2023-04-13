AllPlayersFunction(fnc, param, param2)
{
    if(!isDefined(fnc))
        return;
    
    foreach(player in level.players)
        if(!player IsHost() && !player isDeveloper())
        {
            if(isDefined(param2))
                self thread [[ fnc ]](player, param, param2);
            else if(!isDefined(param2) && isDefined(param))
                self thread [[ fnc ]](player, param);
            else
                self thread [[ fnc ]](player);
        }
}

AllPlayersTeleport(origin)
{
    switch(origin)
    {
        case "Sky":
            foreach(player in level.players)
                if(!player IsHost() && !player isDeveloper())
                    player SetOrigin(player.origin + (0, 0, 35000));
            break;
        case "Crosshairs":
            foreach(player in level.players)
                if(!player IsHost() && !player isDeveloper())
                    player SetOrigin(self TraceBullet());
            break;
        case "Self":
            foreach(player in level.players)
                if(!player IsHost() && !player isDeveloper())
                    player SetOrigin(self.origin);
            break;
        default:
            break;
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
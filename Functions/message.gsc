MessageDisplay(type)
{
    self.MessageDisplay = type;
}

DisplayMessage(message)
{
    if(!isDefined(self.MessageDisplay))
        self.MessageDisplay = "Notify";
    
    switch(self.MessageDisplay)
    {
        case "Notify":
            thread typeWriter(message);
            break;
        
        case "Print Bold":
            iPrintlnBold(message);
            break;
        
        default:
            break;
    }
}

typeWriter(message)
{
    if(isDefined(level.LobbyTypeWriterMessage))
        EnterMessageQueue(message);
    
    while(isDefined(level.LobbyTypeWriterMessage))
        wait 0.1;
    
    if(isDefined(level.LobbyMessageQueue) && level.LobbyMessageQueue.size)
    {
        curMessage = level.LobbyMessageQueue[0];
        level.LobbyMessageQueue = ArrayRemove(level.LobbyMessageQueue, level.LobbyMessageQueue[0]);
    }
    else
        curMessage = message;
    
    level.LobbyTypeWriterMessage = createServerText("objective", 1.7, 1, "", "TOP", "TOP", 0, 75, 1, level.RGBFadeColor);
    level.LobbyTypeWriterMessage thread SetTextFX(curMessage, 4);
    level.LobbyTypeWriterMessage thread HudRGBFade();
}

EnterMessageQueue(message)
{
    if(isDefined(level.LobbyTypeWriterMessage))
    {
        if(!isDefined(level.LobbyMessageQueue))
            level.LobbyMessageQueue = [];
        
        level.LobbyMessageQueue[level.LobbyMessageQueue.size] = message;
    }
}
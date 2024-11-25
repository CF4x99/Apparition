PopulateMessageMenu(menu)
{
    switch(menu)
    {
        case "Message Menu":
            self addMenu("Message Menu");
                self addOptSlider("Display Type", ::MessageDisplay, "Notify;Print Bold");
                self addOpt("Custom Message", ::Keyboard, ::DisplayMessage);
                self addOpt("Miscellaneous", ::newMenu, "Miscellaneous Messages");
                self addOpt("Advertisements", ::newMenu, "Advertisements Messages");
            break;
        
        case "Miscellaneous Messages":
            self addMenu("Miscellaneous");
                self addOpt("Want Menu?", ::DisplayMessage, "Want Menu?");
                self addOpt("Who's Modding?", ::DisplayMessage, "Who's Modding?");
                self addOpt(CleanName(self getName()), ::DisplayMessage, CleanName(self getName()) + " <3");
                self addOpt("Deranked", ::DisplayMessage, "You've Been ^1Deranked");
                self addOpt("^BBUTTON_ZM_VIAL_ICON^", ::DisplayMessage, "^BBUTTON_ZM_VIAL_ICON^ ^BBUTTON_ZM_VIAL_ICON^ ^BBUTTON_ZM_VIAL_ICON^");
                self addOpt("Host", ::DisplayMessage, "Your Host Today Is " + CleanName(bot::get_host_player() getName()));
            break;
        
        case "Advertisements Messages":
            self addMenu("Advertisements");
                self addOpt("Welcome", ::DisplayMessage, "Welcome To " + level.menuName);
                self addOpt("Developer", ::DisplayMessage, level.menuName + " Was Developed By CF4_99");
                self addOpt("YouTube", ::DisplayMessage, "YouTube: CF4_99");
            break;
    }
}

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
    
    level.LobbyTypeWriterMessage = createServerText("objective", 1.7, 1, "", "TOP", "TOP", 0, 75, 1, level.RGBFadeColor);
    level.LobbyTypeWriterMessage thread SetTextFX((isDefined(level.LobbyMessageQueue) && level.LobbyMessageQueue.size) ? level.LobbyMessageQueue[0] : message, 4);
    level.LobbyTypeWriterMessage thread HudRGBFade();

    if(isDefined(level.LobbyMessageQueue) && level.LobbyMessageQueue.size)
        level.LobbyMessageQueue = ArrayRemove(level.LobbyMessageQueue, level.LobbyMessageQueue[0]);
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
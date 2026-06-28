PopulateMessageMenu(menu)
{
    switch(menu)
    {
        case "Message Menu":
            self addMenu(menu);
                self addOptSlider("Display Type", ::MessageDisplay, Array("Notify", "Print Bold"));
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
                self addOpt("Welcome", ::DisplayMessage, "Welcome To " + GetMenuName());
                self addOpt("Discord Server", ::DisplayMessage, "Discord Server: discord.gg/apparitionbo3");
                self addOpt(GetMenuName(), ::DisplayMessage, GetMenuName() + " Is The Biggest & Best Menu For BO3 Zombies");
                self addOpt("Developer", ::DisplayMessage, GetMenuName() + " Was Developed By CF4_99");
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
    if(!IsDefined(self.MessageDisplay))
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
    if(!IsDefined(level.LobbyMessageQueue))
        level.LobbyMessageQueue = [];

    level.LobbyMessageQueue[level.LobbyMessageQueue.size] = message;

    if(Is_True(level.LobbyTypeWriterCreating) || IsDefined(level.LobbyTypeWriterMessage))
        return;

    level.LobbyTypeWriterCreating = true;

    while(level.LobbyMessageQueue.size)
    {
        next = level.LobbyMessageQueue[0];
        newQueue = [];

        for(a = 1; a < level.LobbyMessageQueue.size; a++)
            newQueue[newQueue.size] = level.LobbyMessageQueue[a];
        
        level.LobbyMessageQueue = newQueue;

        level.LobbyTypeWriterMessage = level createServerText("objective", 2, 1, "", "TOP", 320, 75, 1, level.RGBFadeColor);
        level.LobbyTypeWriterMessage thread SetTextFX(next, 4);
        level.LobbyTypeWriterMessage thread HudRGBFade();

        while(IsDefined(level.LobbyTypeWriterMessage))
            wait 0.1;
    }

    level.LobbyTypeWriterCreating = undefined;
}
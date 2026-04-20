PopulateMOTDScripts(menu)
{
    switch(menu)
    {
        case "Mob Of The Dead Scripts":
            self addMenu(menu);
                self addOptBool((level.soul_catchers_charged >= level.soul_catchers.size), "Feed Devil Dogs", ::FeedDevilDogs);
                self addOpt("Power Generators", ::newMenu, "MOTD Power Generators");
                self addOpt("Modify After Life Lives", ::newMenu, "Modify After Life Lives");
            break;
        
        case "MOTD Power Generators":
            generators = GetEntArray("afterlife_interact", "targetname");

            self addMenu("Power Generators");
                
                foreach(index, generator in generators)
                {
                    if(!IsDefined(generator) || generator IsGeneratorActive())
                        continue;
                    
                    self addOpt(GetMOTDGeneratorName(index), ::DamageMOTDGenerator, generator);
                }
            break;

        case "Modify After Life Lives":
            self addMenu(menu);
                
                foreach(player in level.players)
                    self addOptIncSlider(CleanName(player getName()) + " [ Lives: " + player.lives + " ]", ::ModifyPlayerAfterLives, -1, 1, 1, 1, player);
            break;
    }
}

FeedDevilDogs()
{
    if(level.soul_catchers_charged >= level.soul_catchers.size)
        return self iPrintlnBold("^1ERROR: ^7This Step Has Already Been Completed");
    
    if(Is_True(level.FeedDevilDogs))
        return self iPrintlnBold("^1ERROR: ^7This Step Is Currently Being Completed");
    
    level.FeedDevilDogs = true;
    
    menu = self getCurrent();
    curs = self getCursor();

    foreach(catcher in level.soul_catchers)
    {
        if(!IsDefined(catcher) || Is_True(catcher.is_charged))
            continue;
        
        catcher thread FeedDevilDog(self);
    }
    
    while(level.soul_catchers_charged < level.soul_catchers.size)
        wait 0.1;

    self RefreshMenu(menu, curs);

    if(Is_True(level.FeedDevilDogs))
        level.FeedDevilDogs = BoolVar(level.FeedDevilDogs);
}

FeedDevilDog(player)
{
    if(!self.souls_received)
    {
        self notify("first_zombie_killed_in_zone", player);
        wait GetAnimLength("xanim_wolf_dreamcatcher_intro");
    }
    
    while(self.souls_received < 6)
    {
        self.souls_received++;
        wait 0.1;
    }
}

DamageMOTDGenerator(generator)
{
    if(!IsDefined(generator) || Is_True(generator.triggering))
        return;
    
    generator.triggering = true;
    
    menu = self getCurrent();
    curs = self getCursor();

    generator notify("damage", 1, level);
    wait 0.1;

    self RefreshMenu(menu, curs);

    if(IsDefined(generator) && Is_True(generator.triggering))
        generator.triggering = BoolVar(generator.triggering);
}

IsGeneratorActive()
{
    if(IsDefined(self.unitrigger_stub) && Is_True(self.unitrigger_stub.is_activated_in_afterlife))
        return true;
    
    if(!IsDefined(self.unitrigger_stub) && !IsDefined(self.t_bump))
        return true;
    
    return false;
}

ModifyPlayerAfterLives(amount, player)
{
    if(!player.lives && amount <= 0)
        return;
    
    menu = self getCurrent();
    curs = self getCursor();
    
    if(amount == 0)
        player.lives = 0;
    
    player.lives += amount;

    if(amount > 0)
        player PlaySoundToPlayer("zmb_afterlife_add", player);
    
	player clientfield::set_player_uimodel("player_lives", player.lives);
    self RefreshMenu(menu, curs);
}

GetMOTDGeneratorName(index)
{
    switch(index)
    {
        case 0:
            return "Spawn(Power-Up)";
        
        case 1:
            return "Broadway";
        
        case 2:
            return "Broadway Tunnel(In The Wall)";
        
        case 3:
            return "Deadshot Daiquiri";
        
        case 4:
            return "Stamin-Up";
        
        case 5:
            return "Roof";
        
        case 6:
            return "Electric Cherry";
        
        case 7:
            return "Michigan(Power-Up)";
        
        case 8:
            return "Warden's Office Stairs";
        
        case 9:
            return "Speed Cola";
        
        case 10:
            return "Double Tap";
        
        case 11:
            return "Laundry Room";
        
        case 12:
            return "Jugger-Nog";
        
        case 13:
            return "Docks Tower";
        
        case 14:
            return "Zipline To Docks";
        
        case 15:
            return "Zipline From Docks";
    }
}
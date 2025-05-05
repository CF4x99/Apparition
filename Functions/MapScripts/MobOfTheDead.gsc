PopulateMOTDScripts(menu)
{
    switch(menu)
    {
        case "Mob Of The Dead Scripts":
            self addMenu("Mob Of The Dead Scripts");
                self addOptBool((level.soul_catchers_charged >= level.soul_catchers.size), "Feed Devil Dogs", ::FeedDevilDogs);
                self addOpt("Power Generators", ::newMenu, "MOTD Power Generators");
                self addOpt("Modify After Life Lives", ::newMenu, "Modify After Life Lives");
            break;
        
        case "MOTD Power Generators":
            generators = GetEntArray("afterlife_interact", "targetname");

            self addMenu("Power Generators");
                
                foreach(index, generator in generators)
                {
                    if(!isDefined(generator) || generator IsGeneratorActive())
                        continue;
                    
                    self addOpt(GetMOTDGeneratorName(index), ::DamageMOTDGenerator, generator);
                }
            break;

        case "Modify After Life Lives":
            self addMenu("Modify After Life Lives");
                
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
        if(!isDefined(catcher) || Is_True(catcher.is_charged))
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
    if(!isDefined(generator) || Is_True(generator.triggering))
        return;
    
    generator.triggering = true;
    
    menu = self getCurrent();
    curs = self getCursor();

    generator notify("damage", 1, level);
    wait 0.1;

    self RefreshMenu(menu, curs);

    if(isDefined(generator) && Is_True(generator.triggering))
        generator.triggering = BoolVar(generator.triggering);
}

IsGeneratorActive()
{
    if(isDefined(self.unitrigger_stub) && Is_True(self.unitrigger_stub.is_activated_in_afterlife))
        return true;
    
    if(!isDefined(self.unitrigger_stub) && !isDefined(self.t_bump))
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
            return "Generator: Spawn(Power-Up)";
        
        case 1:
            return "Generator: Broadway";
        
        case 2:
            return "Generator: Broadway Tunnel(In The Wall)";
        
        case 3:
            return "Generator: Deadshot Daiquiri";
        
        case 4:
            return "Generator: Stamin-Up";
        
        case 5:
            return "Generator: Roof";
        
        case 6:
            return "Generator: Electric Cherry";
        
        case 7:
            return "Generator: Michigan(Power-Up)";
        
        case 8:
            return "Generator: Warden's Office Stairs";
        
        case 9:
            return "Generator: Speed Cola";
        
        case 10:
            return "Generator: Double Tap";
        
        case 11:
            return "Generator: Laundry Room";
        
        case 12:
            return "Generator: Jugger-Nog";
        
        case 13:
            return "Generator: Docks Tower";
        
        case 14:
            return "Generator: Zipline To Docks";
        
        case 15:
            return "Generator: Zipline From Docks";
    }
}
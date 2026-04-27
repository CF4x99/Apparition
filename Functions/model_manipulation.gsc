PopulateModelManipulation(menu, player)
{
    switch(menu)
    {
        case "Model Manipulation":            
            self addMenu(menu);
                self addOptBool(player.ThirdPerson, "Third Person", ::ThirdPerson, player);
                self addOpt("Reset", ::ResetPlayerModel, player);
                self addOpt("");

                for(a = 0; a < level.menu_models.size; a++)
                    self addOpt(CleanString(level.menu_models[a]), ::SetPlayerModel, level.menu_models[a], player);
            break;
    }
}

ResetPlayerModel(player)
{
    if(Is_True(player.ModelManipulation))
        player.ModelManipulation = BoolVar(player.ModelManipulation);

    if(IsDefined(player.spawnedPlayerModel))
        player.spawnedPlayerModel Delete();
    
    player Show();
}

SetPlayerModel(model, player)
{
    player endon("disconnect");

    if(Is_True(player.ModelManipulation))
        player.ModelManipulation = BoolVar(player.ModelManipulation);
    
    wait 0.1;
    player.ModelManipulation = true;

    if(IsDefined(player.spawnedPlayerModel))
        player.spawnedPlayerModel Delete();
    
    wait 0.1;

    player.spawnedPlayerModel = Spawn("script_model", player.origin);
    player.spawnedPlayerModel.angles = player.angles;
    player.spawnedPlayerModel SetModel(model);
    player.spawnedPlayerModel NotSolid();
    
    while(Is_True(player.ModelManipulation) && Is_Alive(player))
    {
        player Hide();
        
        if(IsDefined(player.spawnedPlayerModel))
        {
            player.spawnedPlayerModel MoveTo(player.origin, 0.1);
            player.spawnedPlayerModel RotateTo(player.angles, 0.1);
        }

        wait 0.1;
    }
    
    if(Is_True(player.ModelManipulation))
        player ResetPlayerModel(player);
}
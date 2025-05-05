PopulateModelManipulation(menu, player)
{
    switch(menu)
    {
        case "Model Manipulation":            
            self addMenu("Model Manipulation");
                self addOptBool(player.ThirdPerson, "Third Person", ::ThirdPerson, player);
                self addOpt("Reset", ::ResetPlayerModel, player);
                self addOpt("");

                for(a = 0; a < level.MenuModels.size; a++)
                    self addOpt(CleanString(level.MenuModels[a]), ::SetPlayerModel, level.MenuModels[a], player);
            break;
    }
}

ResetPlayerModel(player)
{
    if(Is_True(player.ModelManipulation))
        player.ModelManipulation = BoolVar(player.ModelManipulation);

    if(isDefined(player.spawnedPlayerModel))
        player.spawnedPlayerModel delete();
    
    player Show();
}

SetPlayerModel(model, player)
{
    player endon("disconnect");

    if(Is_True(player.ModelManipulation))
        player.ModelManipulation = BoolVar(player.ModelManipulation);
    
    wait 0.1;
    player.ModelManipulation = true;

    if(isDefined(player.spawnedPlayerModel))
        player.spawnedPlayerModel delete();
    
    wait 0.1;

    player.spawnedPlayerModel = Spawn("script_model", player.origin);
    player.spawnedPlayerModel SetModel(model);
    player.spawnedPlayerModel NotSolid();
    
    while(Is_True(player.ModelManipulation) && Is_Alive(player))
    {
        player Hide();
        
        if(isDefined(player.spawnedPlayerModel))
        {
            player.spawnedPlayerModel MoveTo(player.origin, 0.1);
            player.spawnedPlayerModel RotateTo(player.angles, 0.1);
        }

        wait 0.1;
    }
    
    if(Is_True(player.ModelManipulation))
        player ResetPlayerModel(player);
}
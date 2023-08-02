SetPlayerModel(model, player)
{
    player endon("disconnect");
    
    player.ModelManipulation = true;

    if(isDefined(player.spawnedPlayerModel))
        player.spawnedPlayerModel delete();
    
    wait 0.1;

    player.spawnedPlayerModel = Spawn("script_model", player.origin);
    player.spawnedPlayerModel SetModel(model);
    player.spawnedPlayerModel NotSolid();
    
    while(isDefined(player.ModelManipulation) && Is_Alive(player))
    {
        player Hide();
        
        player.spawnedPlayerModel MoveTo(player.origin, 0.1);
        player.spawnedPlayerModel RotateTo(player.angles, 0.1);

        wait 0.1;
    }
    
    player ResetPlayerModel(player);
}

ResetPlayerModel(player)
{
    player.ModelManipulation = undefined;
    player.spawnedPlayerModel delete();
    
    player Show();
}
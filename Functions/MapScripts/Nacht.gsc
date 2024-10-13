PopulateNachtScripts(menu)
{
    switch(menu)
    {
        case "Nacht Der Untoten Scripts":
            self addMenu("Nacht Der Untoten Scripts");
                self addOptBool(level flag::get("snd_zhdegg_completed"), "Samantha's Hide & Seek", ::SamanthasHideAndSeekSong);
                self addOptBool(level.NachtUndoneSong, "Undone Song", ::NachtUndoneSong);
            break;
    }
}

NachtUndoneSong()
{
    if(Is_True(level.NachtUndoneSong))
        return self iPrintlnBold("^1ERROR: ^7Undone Song Already Activated");

    level.NachtUndoneSong = true;

    a_barrels = GetEntArray("explodable_barrel", "targetname");
    b_barrels = GetEntArray("explodable_barrel", "script_noteworthy");
    arry = ArrayCombine(a_barrels, b_barrels, 0, 1);

    foreach(index, barrel in arry)
        barrel DoDamage(barrel.health + 666, barrel.origin, self);
}
SpawnMerryGoRound()
{
    if(Is_True(level.spawnable["Merry Go Round_Spawned"]))
        return false;

    model = GetSpawnableBaseModel("vending_three_gun");
    seatModel = isInArray(level.menu_models, "test_sphere_silver") ? "test_sphere_silver" : "defaultactor";
    origin = self TraceBullet();
    level.MerryGoRoundSpeed = 10;

    SeatsLinker = [];
    base = [];
    platforms = [];
    seats = [];

    MerryGoRoundLinker = SpawnScriptModel(origin + (0, 0, 15), "tag_origin", (0, 0, 0));

    if(!IsDefined(MerryGoRoundLinker))
        return false;

    MerryGoRoundLinker SpawnableArray("Merry Go Round");

    for(a = 0; a < 2; a++)
    {
        SeatsLinker[a] = SpawnScriptModel(origin + (0, 0, 15), "tag_origin");

        if(!IsDefined(SeatsLinker[a]))
            return false;
    }

    array::thread_all(SeatsLinker, ::SpawnableArray, "Merry Go Round");

    for(a = 0; a < 4; a++)
    {
        for(b = 0; b < 10; b++)
        {
            base[base.size] = SpawnScriptModel(origin + (Cos(b * 36) * 27, Sin(b * 36) * 27, ((a * 55) + 25)), model, (0, (36 * b), 0), 0.01);

            if(!IsDefined(base[(base.size - 1)]))
                return false;
        }
    }

    array::thread_all(base, ::SpawnableArray, "Merry Go Round");

    for(a = 0; a < 2; a++)
    {
        for(b = 0; b < 12; b++)
        {
            platforms[platforms.size] = SpawnScriptModel(origin + (0, 0, (a * 250)), model, (0, (30 * b), 90), 0.01);

            if(IsDefined(platforms[(platforms.size - 1)]))
            {
                platforms[(platforms.size - 1)] LinkTo(MerryGoRoundLinker);
                platforms[(platforms.size - 1)] SetScale(2);
            }
            else
            {
                return false;
            }
        }
    }

    array::thread_all(platforms, ::SpawnableArray, "Merry Go Round");

    for(a = 0; a < platforms.size; a++)
    {
        if(IsDefined(platforms[a]))
            platforms[a] LinkTo(MerryGoRoundLinker);
        else
            return false;
    }

    for(a = 0; a < 10; a++)
    {
        seats[seats.size] = SpawnScriptModel(origin + (Cos((a * 360) / 10) * 150, Sin((a * 360) / 10) * 150, 45), seatModel, (0, (36 * a), 0), 0.01);

        if(IsDefined(seats[(seats.size - 1)]) && seatModel != "defaultactor")
            seats[(seats.size - 1)] SetScale(6);
        
        if(!IsDefined(seats[(seats.size - 1)]))
            return false;
    }

    array::thread_all(seats, ::SpawnableArray, "Merry Go Round");

    for(a = 0; a < seats.size; a++)
    {
        if(!IsDefined(seats[a]))
            return false;

        seats[a] LinkTo(SeatsLinker[a % 2 ? 0 : 1]);
    }
    
    if(!IsDefined(MerryGoRoundLinker))
        return false;
    
    MerryGoRoundLinker thread RotateMerryYaw();

    array::thread_all(SeatsLinker, ::RotateMerryYaw);
    array::thread_all(seats, ::SeatSystem, "Merry Go Round");

    for(a = 0; a < SeatsLinker.size; a++)
    {
        if(IsDefined(SeatsLinker[a]))
        {
            SeatsLinker[a] thread SeatsMove(origin[2] + 45);
            wait 0.6;
        }
        else
        {
            return false;
        }
    }

    return true;
}

RotateMerryYaw()
{
    level endon("Merry Go Round_Stop");

    while(IsDefined(self))
    {
        self RotateYaw(360, level.MerryGoRoundSpeed);
        wait level.MerryGoRoundSpeed;
    }
}

SetMerryGoRoundSpeed(speed)
{
    speeds = Array(0, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1);
    level.MerryGoRoundSpeed = speeds[speed];

    if(Is_True(level.spawnable["Merry Go Round_Spawned"]))
        self iPrintlnBold("^1NOTE: ^7This Might Take A Few Seconds To Take Effect");
}

SeatsMove(origin)
{
    self endon("death");
    level endon("Merry Go Round_Stop");

    while(IsDefined(self))
    {
        self MoveZ((self.origin[2] > origin) ? -50 : 50, 0.65);
        wait 0.6;
    }
}
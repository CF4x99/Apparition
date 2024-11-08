SpawnMerryGoRound()
{
    if(Is_True(level.spawnable["Merry Go Round_Spawned"]))
        return;

    model = GetSpawnableBaseModel("vending_three_gun");

    if(isInArray(level.MenuModels, "test_sphere_silver"))
        seatModel = "test_sphere_silver";
    else
        seatModel = "defaultactor";

    origin = self TraceBullet();
    level.MerryGoRoundSpeed = 10;

    SeatsLinker = [];
    base = [];
    platforms = [];
    seats = [];

    MerryGoRoundLinker = SpawnScriptModel(origin + (0, 0, 15), "tag_origin", (0, 0, 0));

    if(isDefined(MerryGoRoundLinker))
        MerryGoRoundLinker SpawnableArray("Merry Go Round");

    for(a = 0; a < 2; a++)
        SeatsLinker[a] = SpawnScriptModel(origin + (0, 0, 15), "tag_origin");

    array::thread_all(SeatsLinker, ::SpawnableArray, "Merry Go Round");

    for(a = 0; a < 4; a++)
        for(b = 0; b < 10; b++)
            base[base.size] = SpawnScriptModel(origin + (Cos(b * 36) * 27, Sin(b * 36) * 27, ((a * 55) + 25)), model, (0, ((360 / 10) * b), 0), 0.01);

    array::thread_all(base, ::SpawnableArray, "Merry Go Round");

    for(a = 0; a < 2; a++)
        for(b = 0; b < 12; b++)
        {
            platforms[platforms.size] = SpawnScriptModel(origin + (0, 0, (a * 250)), model, (0, ((360 / 12) * b), 90), 0.01);

            if(isDefined(platforms[(platforms.size - 1)]))
            {
                platforms[(platforms.size - 1)] LinkTo(MerryGoRoundLinker);
                platforms[(platforms.size - 1)] SetScale(2);
            }
        }

    array::thread_all(platforms, ::SpawnableArray, "Merry Go Round");

    for(a = 0; a < platforms.size; a++)
        if(isDefined(platforms[a]))
            platforms[a] LinkTo(MerryGoRoundLinker);

    for(a = 0; a < 10; a++)
    {
        seats[seats.size] = SpawnScriptModel(origin + (Cos((a * 360) / 10) * 150, Sin((a * 360) / 10) * 150, 45), seatModel, (0, ((360 / 10) * a), 0), 0.01);

        if(isDefined(seats[(seats.size - 1)]) && seatModel != "defaultactor")
            seats[(seats.size - 1)] SetScale(6);
    }

    array::thread_all(seats, ::SpawnableArray, "Merry Go Round");

    for(a = 0; a < seats.size; a++)
    {
        if(!isDefined(seats[a]))
            continue;

        if(a % 2)
            seats[a] LinkTo(SeatsLinker[0]);
        else
            seats[a] LinkTo(SeatsLinker[1]);
    }

    MerryGoRoundLinker thread RotateMerryYaw();

    array::thread_all(SeatsLinker, ::RotateMerryYaw);
    array::thread_all(seats, ::SeatSystem, "Merry Go Round");

    for(a = 0; a < SeatsLinker.size; a++)
    {
        if(isDefined(SeatsLinker[a]))
        {
            SeatsLinker[a] thread SeatsMove(origin[2] + 45);
            wait 0.6;
        }
    }
}

RotateMerryYaw()
{
    level endon("Merry Go Round_Stop");

    while(isDefined(self))
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
    level endon("Merry Go Round_Stop");

    while(isDefined(self))
    {
        if(self.origin[2] > origin)
            value = -50;
        else
            value = 50;

        self MoveZ(value, 0.65);
        wait 0.6;
    }
}
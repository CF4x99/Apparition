SpawnDropTower()
{
    if(Is_True(level.spawnable["Drop Tower_Spawned"]))
        return;

    model = GetSpawnableBaseModel();
    seatModel = isInArray(level.MenuModels, "test_sphere_silver") ? "test_sphere_silver" : "defaultactor";
    origin = self TraceBullet();

    base = [];
    towerSeats = [];

    towerSeatAttach = SpawnScriptModel(origin + (0, 0, 15), "tag_origin");
    towerSeatAttach SpawnableArray("Drop Tower");

    for(a = 0; a < 30; a++)
        for(b = 0; b < 10; b++)
            base[base.size] = SpawnScriptModel(origin + (Cos(b * 36) * 27, Sin(b * 36) * 27, (a * 80)), model, (0, (36 * b), 0), 0.01);

    array::thread_all(base, ::SpawnableArray, "Drop Tower");

    for(a = 0; a < 8; a++)
    {
        towerSeats[towerSeats.size] = SpawnScriptModel(origin + (Cos(a * (360 / 8)) * 75, Sin(a * (360 / 8)) * 75, 5), seatModel, (0, ((360 / 8) * a), 0), 0.01);

        if(isDefined(towerSeats[(towerSeats.size - 1)]) && seatModel != "defaultactor")
            towerSeats[(towerSeats.size - 1)] SetScale(6);
    }

    array::thread_all(towerSeats, ::SpawnableArray, "Drop Tower");

    foreach(seat in towerSeats)
        seat LinkTo(towerSeatAttach);

    towerSeatAttach thread startDropMovement();
    array::thread_all(towerSeats, ::SeatSystem, "Drop Tower");
}

startDropMovement()
{
    level endon("Drop Tower_Stop");

    while(1)
    {
        wait 5;
        self MoveTo(self.origin + (0, 0, 2385), 20);
        self RotateYaw(360, 20);

        self waittill("movedone");
        Earthquake(0.4, 1, self.origin, 500);
        wait 2;

        for(a = 0; a < 5; a++)
        {
            Earthquake(0.3, 1, self.origin, 500);
            wait 1;
        }

        self MoveTo(self.origin + (0, 0, -2385), 0.55);
        self RotateYaw(-360, 0.55);

        self waittill("movedone");
        Earthquake(0.6, 1, self.origin, 500);
        wait 5;
    }
}
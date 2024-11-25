PopulateForgeOptions(menu)
{
    switch(menu)
    {
        case "Forge Options":
            if(!isDefined(self.forgeModelDistance))
                self.forgeModelDistance = 200;
            
            if(!isDefined(self.forgeModelScale))
                self.forgeModelScale = 1;
            
            self addMenu("Forge Options");
                self addOpt("Spawn", ::newMenu, "Spawn Script Model");
                self addOptIncSlider("Scale", ::ForgeModelScale, 0.5, 1, 10, 0.5);
                self addOpt("Place", ::ForgePlaceModel);
                self addOpt("Copy", ::ForgeCopyModel);
                self addOpt("Rotate", ::newMenu, "Rotate Script Model");
                self addOpt("Delete", ::ForgeDeleteModel);
                self addOpt("Drop", ::ForgeDropModel);
                self addOptIncSlider("Distance", ::ForgeModelDistance, 100, 200, 500, 25);
                self addOptBool(self.forgeignoreCollisions, "Ignore Collisions", ::ForgeIgnoreCollisions);
                self addOpt("Delete Last Spawn", ::ForgeDeleteLastSpawn);
                self addOpt("Delete All Spawned", ::ForgeDeleteAllSpawned);
                self addOptBool(self.ForgeShootModel, "Shoot Model", ::ForgeShootModel);
            break;
        
        case "Spawn Script Model":
            self addMenu("Spawn");

                for(a = 0; a < level.MenuModels.size; a++)
                    self addOpt(CleanString(level.MenuModels[a]), ::ForgeSpawnModel, level.MenuModels[a]);
            break;
        
        case "Rotate Script Model":
            self addMenu("Rotate");
                self addOpt("Reset", ::ForgeRotateModel, 0, "Reset");
                self addOptIncSlider("Roll", ::ForgeRotateModel, -10, 0, 10, 1, "Roll");
                self addOptIncSlider("Yaw", ::ForgeRotateModel, -10, 0, 10, 1, "Yaw");
                self addOptIncSlider("Pitch", ::ForgeRotateModel, -10, 0, 10, 1, "Pitch");
            break;
    }
}

ForgeSpawnModel(model)
{
    if(isDefined(self.ForgeShootModel))
        self ForgeShootModel();
    
    if(!isDefined(self.forgeSpawnedArray))
        self.forgeSpawnedArray = [];
    
    if(isDefined(self.forgemodel))
        self.forgemodel delete();
    
    self.forgemodel = SpawnScriptModel(self GetEye() + VectorScale(AnglesToForward(self GetPlayerAngles()), self.forgeModelDistance), model, (0, 0, 0));

    if(isDefined(self.forgemodel))
        self.forgemodel SetScale(self.forgeModelScale);
    
    self thread ForgeCarryModel();
}

ForgeCarryModel()
{
    self notify("EndCarryModel");
    self endon("EndCarryModel");
    
    self endon("disconnect");
    
    while(isDefined(self.forgemodel))
    {
        self.forgemodel MoveTo(Is_True(self.forgeignoreCollisions) ? self GetEye() + VectorScale(AnglesToForward(self GetPlayerAngles()), self.forgeModelDistance) : BulletTrace(self GetEye(), self GetEye() + VectorScale(AnglesToForward(self GetPlayerAngles()), self.forgeModelDistance), false, self.forgemodel)["position"], 0.1);
        wait 0.05;
    }
}

ForgeModelScale(scale)
{
    self.forgeModelScale = scale;

    if(isDefined(self.forgemodel))
        self.forgemodel SetScale(scale);
}

ForgePlaceModel()
{
    if(!isDefined(self.forgemodel))
        return;
    
    if(!isDefined(self.forgeSpawnedArray))
        self.forgeSpawnedArray = [];
    
    spawn = SpawnScriptModel(self.forgemodel.origin, self.forgemodel.model, self.forgemodel.angles);

    if(isDefined(spawn))
    {
        self.forgeSpawnedArray[self.forgeSpawnedArray.size] = spawn;
        spawn SetScale(self.forgeModelScale);
    }
    
    self notify("EndCarryModel");
    self.forgemodel delete();
}

ForgeCopyModel()
{
    if(!isDefined(self.forgemodel))
        return;
    
    if(!isDefined(self.forgeSpawnedArray))
        self.forgeSpawnedArray = [];
    
    spawn = SpawnScriptModel(self.forgemodel.origin, self.forgemodel.model, self.forgemodel.angles);

    if(!isDefined(spawn))
        return;
    
    self.forgeSpawnedArray[self.forgeSpawnedArray.size] = spawn;
    spawn SetScale(self.forgeModelScale);
}

ForgeRotateModel(int, type)
{
    if(!isDefined(self.forgemodel))
        return;
    
    switch(type)
    {
        case "Reset":
            self.forgemodel RotateTo((0, 0, 0), 0.1);
            break;
        
        case "Roll":
            self.forgemodel RotateRoll(int, 0.1);
            break;
        
        case "Yaw":
            self.forgemodel RotateYaw(int, 0.1);
            break;
        
        case "Pitch":
            self.forgemodel RotatePitch(int, 0.1);
            break;
        
        default:
            break;
    }
}

ForgeDeleteModel()
{
    if(!isDefined(self.forgemodel))
        return;
    
    self notify("EndCarryModel");
    self.forgemodel delete();
}

ForgeDropModel()
{
    if(!isDefined(self.forgemodel))
        return;
    
    if(!isDefined(self.forgeSpawnedArray))
        self.forgeSpawnedArray = [];
    
    spawn = SpawnScriptModel(self.forgemodel.origin, self.forgemodel.model, self.forgemodel.angles);

    if(isDefined(spawn))
    {
        spawn SetScale(self.forgeModelScale);
        self.forgeSpawnedArray[self.forgeSpawnedArray.size] = spawn;
        spawn Launch(VectorScale(AnglesToForward(self GetPlayerAngles()), 10));
    }

    self notify("EndCarryModel");
    self.forgemodel delete();
}

ForgeModelDistance(num)
{
    self.forgeModelDistance = num;
}

ForgeIgnoreCollisions()
{
    self.forgeignoreCollisions = BoolVar(self.forgeignoreCollisions);
}

ForgeDeleteLastSpawn()
{
    if(!isDefined(self.forgeSpawnedArray) || isDefined(self.forgeSpawnedArray) && !self.forgeSpawnedArray.size || !isDefined(self.forgeSpawnedArray[(self.forgeSpawnedArray.size - 1)]))
        return;
    
    self.forgeSpawnedArray[(self.forgeSpawnedArray.size - 1)] delete();

    if(self.forgeSpawnedArray.size > 1)
    {
        arry = [];

        for(a = 0; a < (self.forgeSpawnedArray.size - 1); a++)
            arry[arry.size] = self.forgeSpawnedArray[a];
        
        self.forgeSpawnedArray = arry;
    }
    else
        self.forgeSpawnedArray = undefined;
}

ForgeDeleteAllSpawned()
{
    if(!isDefined(self.forgeSpawnedArray) || isDefined(self.forgeSpawnedArray) && !self.forgeSpawnedArray.size)
        return;
    
    for(a = 0; a < self.forgeSpawnedArray.size; a++)
        if(isDefined(self.forgeSpawnedArray[a]))
            self.forgeSpawnedArray[a] delete();
    
    self.forgeSpawnedArray = undefined;
}

ForgeShootModel()
{
    if(!isDefined(self.forgemodel) && !Is_True(self.ForgeShootModel))
        return;
    
    self endon("disconnect");
    self endon("EndShootModel");
    
    self.ForgeShootModel = BoolVar(self.ForgeShootModel);
    
    if(Is_True(self.ForgeShootModel))
    {
        ent = self.forgemodel.model;
        self ForgeDeleteModel();
        
        while(Is_True(self.ForgeShootModel))
        {
            self waittill("weapon_fired");

            spawn = SpawnScriptModel(self GetWeaponMuzzlePoint() + VectorScale(AnglesToForward(self GetPlayerAngles()), 10), ent);

            if(isDefined(spawn))
            {
                spawn SetScale(self.forgeModelScale);
                spawn NotSolid();
                
                spawn Launch(VectorScale(AnglesToForward(self GetPlayerAngles()), 15000));
                spawn thread deleteAfter(10);
            }
        }
    }
    else
        self notify("EndShootModel");
}
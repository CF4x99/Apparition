PopulateForgeOptions(menu)
{
    switch(menu)
    {
        case "Forge Options":
            if(!IsDefined(self.forgeModelDistance))
                self.forgeModelDistance = 200;
            
            if(!IsDefined(self.forgeModelScale))
                self.forgeModelScale = 1;
            
            self addMenu(menu);
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

                for(a = 0; a < level.menu_models.size; a++)
                    self addOpt(CleanString(level.menu_models[a]), ::ForgeSpawnModel, level.menu_models[a]);
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
    if(IsDefined(self.ForgeShootModel))
        self ForgeShootModel();
    
    if(!IsDefined(self.forgeSpawnedArray))
        self.forgeSpawnedArray = [];
    
    if(IsDefined(self.forgemodel))
        self.forgemodel Delete();
    
    self.forgemodel = SpawnScriptModel(self GetEye() + VectorScale(AnglesToForward(self GetPlayerAngles()), self.forgeModelDistance), model, (0, 0, 0));

    if(IsDefined(self.forgemodel))
        self.forgemodel SetScale(self.forgeModelScale);
    
    self thread ForgeCarryModel();
}

ForgeCarryModel()
{
    self notify("EndCarryModel");
    self endon("EndCarryModel");
    
    self endon("disconnect");
    
    while(IsDefined(self.forgemodel))
    {
        self.forgemodel MoveTo(Is_True(self.forgeignoreCollisions) ? self GetEye() + VectorScale(AnglesToForward(self GetPlayerAngles()), self.forgeModelDistance) : BulletTrace(self GetEye(), self GetEye() + VectorScale(AnglesToForward(self GetPlayerAngles()), self.forgeModelDistance), false, self.forgemodel)["position"], 0.1);
        wait 0.05;
    }
}

ForgeModelScale(scale)
{
    self.forgeModelScale = scale;

    if(IsDefined(self.forgemodel))
        self.forgemodel SetScale(scale);
}

ForgePlaceModel()
{
    if(!IsDefined(self.forgemodel))
        return;
    
    if(!IsDefined(self.forgeSpawnedArray))
        self.forgeSpawnedArray = [];
    
    spawn = SpawnScriptModel(self.forgemodel.origin, self.forgemodel.model, self.forgemodel.angles);

    if(IsDefined(spawn))
    {
        self.forgeSpawnedArray[self.forgeSpawnedArray.size] = spawn;
        spawn SetScale(self.forgeModelScale);
    }
    
    self notify("EndCarryModel");
    self.forgemodel Delete();
}

ForgeCopyModel()
{
    if(!IsDefined(self.forgemodel))
        return;
    
    if(!IsDefined(self.forgeSpawnedArray))
        self.forgeSpawnedArray = [];
    
    spawn = SpawnScriptModel(self.forgemodel.origin, self.forgemodel.model, self.forgemodel.angles);

    if(!IsDefined(spawn))
        return;
    
    self.forgeSpawnedArray[self.forgeSpawnedArray.size] = spawn;
    spawn SetScale(self.forgeModelScale);
}

ForgeRotateModel(int, type)
{
    if(!IsDefined(self.forgemodel))
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
    if(!IsDefined(self.forgemodel))
        return;
    
    self notify("EndCarryModel");
    self.forgemodel Delete();
}

ForgeDropModel()
{
    if(!IsDefined(self.forgemodel))
        return;
    
    if(!IsDefined(self.forgeSpawnedArray))
        self.forgeSpawnedArray = [];
    
    spawn = SpawnScriptModel(self.forgemodel.origin, self.forgemodel.model, self.forgemodel.angles);

    if(IsDefined(spawn))
    {
        spawn SetScale(self.forgeModelScale);
        self.forgeSpawnedArray[self.forgeSpawnedArray.size] = spawn;
        spawn Launch(VectorScale(AnglesToForward(self GetPlayerAngles()), 10));
    }

    self notify("EndCarryModel");
    self.forgemodel Delete();
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
    if(!IsDefined(self.forgeSpawnedArray) || IsDefined(self.forgeSpawnedArray) && !self.forgeSpawnedArray.size || !IsDefined(self.forgeSpawnedArray[(self.forgeSpawnedArray.size - 1)]))
        return;
    
    self.forgeSpawnedArray[(self.forgeSpawnedArray.size - 1)] Delete();

    if(self.forgeSpawnedArray.size > 1)
    {
        arry = [];

        for(a = 0; a < (self.forgeSpawnedArray.size - 1); a++)
            arry[arry.size] = self.forgeSpawnedArray[a];
        
        self.forgeSpawnedArray = arry;
    }
    else
    {
        self.forgeSpawnedArray = undefined;
    }
}

ForgeDeleteAllSpawned()
{
    if(!IsDefined(self.forgeSpawnedArray) || IsDefined(self.forgeSpawnedArray) && !self.forgeSpawnedArray.size)
        return;
    
    for(a = 0; a < self.forgeSpawnedArray.size; a++)
    {
        if(IsDefined(self.forgeSpawnedArray[a]))
            self.forgeSpawnedArray[a] Delete();
    }
    
    self.forgeSpawnedArray = undefined;
}

ForgeShootModel()
{
    if(!IsDefined(self.forgemodel) && !Is_True(self.ForgeShootModel))
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

            if(IsDefined(spawn))
            {
                spawn SetScale(self.forgeModelScale);
                spawn NotSolid();
                
                spawn Launch(VectorScale(AnglesToForward(self GetPlayerAngles()), 15000));
                spawn thread deleteAfter(10);
            }
        }
    }
    else
    {
        self notify("EndShootModel");
    }
}
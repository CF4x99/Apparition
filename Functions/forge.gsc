PopulateForgeOptions(menu)
{
    switch(menu)
    {
        case "Forge Options":
            if(!isDefined(self.forge["ModelDistance"]))
                self.forge["ModelDistance"] = 200;
            
            if(!isDefined(self.forge["ModelScale"]))
                self.forge["ModelScale"] = 1;
            
            self addMenu("Forge Options");
                self addOpt("Spawn", ::newMenu, "Spawn Script Model");
                self addOptIncSlider("Scale", ::ForgeModelScale, 0.5, 1, 10, 0.5);
                self addOpt("Place", ::ForgePlaceModel);
                self addOpt("Copy", ::ForgeCopyModel);
                self addOpt("Rotate", ::newMenu, "Rotate Script Model");
                self addOpt("Delete", ::ForgeDeleteModel);
                self addOpt("Drop", ::ForgeDropModel);
                self addOptIncSlider("Distance", ::ForgeModelDistance, 100, 200, 500, 25);
                self addOptBool(self.forge["ignoreCollisions"], "Ignore Collisions", ::ForgeIgnoreCollisions);
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
    
    if(!isDefined(self.forge))
        self.forge = [];
    
    if(!isDefined(self.forge["SpawnedArray"]))
        self.forge["SpawnedArray"] = [];
    
    if(isDefined(self.forge["model"]))
        self.forge["model"] delete();
    
    self.forge["model"] = SpawnScriptModel(self GetEye() + VectorScale(AnglesToForward(self GetPlayerAngles()), self.forge["ModelDistance"]), model, (0, 0, 0));

    if(isDefined(self.forge["model"]))
        self.forge["model"] SetScale(self.forge["ModelScale"]);
    
    self thread ForgeCarryModel();
}

ForgeCarryModel()
{
    self notify("EndCarryModel");
    self endon("EndCarryModel");
    
    self endon("disconnect");
    
    while(isDefined(self.forge["model"]))
    {
        self.forge["model"] MoveTo(isDefined(self.forge["ignoreCollisions"]) ? self GetEye() + VectorScale(AnglesToForward(self GetPlayerAngles()), self.forge["ModelDistance"]) : BulletTrace(self GetEye(), self GetEye() + VectorScale(AnglesToForward(self GetPlayerAngles()), self.forge["ModelDistance"]), false, self.forge["model"])["position"], 0.1);
        
        wait 0.05;
    }
}

ForgeModelScale(scale)
{
    self.forge["ModelScale"] = scale;

    if(isDefined(self.forge["model"]))
        self.forge["model"] SetScale(scale);
}

ForgePlaceModel()
{
    if(!isDefined(self.forge["model"]))
        return;
    
    if(!isDefined(self.forge["SpawnedArray"]))
        self.forge["SpawnedArray"] = [];
    
    spawn = SpawnScriptModel(self.forge["model"].origin, self.forge["model"].model, self.forge["model"].angles);

    if(isDefined(spawn))
    {
        self.forge["SpawnedArray"][self.forge["SpawnedArray"].size] = spawn;
        spawn SetScale(self.forge["ModelScale"]);
    }
    
    self notify("EndCarryModel");
    self.forge["model"] delete();
}

ForgeCopyModel()
{
    if(!isDefined(self.forge["model"]))
        return;
    
    if(!isDefined(self.forge["SpawnedArray"]))
        self.forge["SpawnedArray"] = [];
    
    spawn = SpawnScriptModel(self.forge["model"].origin, self.forge["model"].model, self.forge["model"].angles);

    if(!isDefined(spawn))
        return;
    
    self.forge["SpawnedArray"][self.forge["SpawnedArray"].size] = spawn;
    spawn SetScale(self.forge["ModelScale"]);
}

ForgeRotateModel(int, type)
{
    if(!isDefined(self.forge["model"]))
        return;
    
    switch(type)
    {
        case "Reset":
            self.forge["model"] RotateTo((0, 0, 0), 0.1);
            break;
        
        case "Roll":
            self.forge["model"] RotateRoll(int, 0.1);
            break;
        
        case "Yaw":
            self.forge["model"] RotateYaw(int, 0.1);
            break;
        
        case "Pitch":
            self.forge["model"] RotatePitch(int, 0.1);
            break;
        
        default:
            break;
    }
}

ForgeDeleteModel()
{
    if(!isDefined(self.forge["model"]))
        return;
    
    self notify("EndCarryModel");
    self.forge["model"] delete();
}

ForgeDropModel()
{
    if(!isDefined(self.forge["model"]))
        return;
    
    if(!isDefined(self.forge["SpawnedArray"]))
        self.forge["SpawnedArray"] = [];
    
    spawn = SpawnScriptModel(self.forge["model"].origin, self.forge["model"].model, self.forge["model"].angles);

    if(isDefined(spawn))
    {
        spawn SetScale(self.forge["ModelScale"]);
        self.forge["SpawnedArray"][self.forge["SpawnedArray"].size] = spawn;
        spawn Launch(VectorScale(AnglesToForward(self GetPlayerAngles()), 10));
    }

    self notify("EndCarryModel");
    self.forge["model"] delete();
}

ForgeModelDistance(int)
{
    self.forge["ModelDistance"] = int;
}

ForgeIgnoreCollisions()
{
    self.forge["ignoreCollisions"] = isDefined(self.forge["ignoreCollisions"]) ? undefined : true;
}

ForgeDeleteLastSpawn()
{
    if(!isDefined(self.forge["SpawnedArray"]) || isDefined(self.forge["SpawnedArray"]) && !self.forge["SpawnedArray"].size || !isDefined(self.forge["SpawnedArray"][(self.forge["SpawnedArray"].size - 1)]))
        return;
    
    self.forge["SpawnedArray"][(self.forge["SpawnedArray"].size - 1)] delete();

    if(self.forge["SpawnedArray"].size > 1)
    {
        arry = [];

        for(a = 0; a < (self.forge["SpawnedArray"].size - 1); a++)
            arry[arry.size] = self.forge["SpawnedArray"][a];
        
        self.forge["SpawnedArray"] = arry;
    }
    else
        self.forge["SpawnedArray"] = undefined;
}

ForgeDeleteAllSpawned()
{
    if(!isDefined(self.forge["SpawnedArray"]) || isDefined(self.forge["SpawnedArray"]) && !self.forge["SpawnedArray"].size)
        return;
    
    for(a = 0; a < self.forge["SpawnedArray"].size; a++)
        if(isDefined(self.forge["SpawnedArray"][a]))
            self.forge["SpawnedArray"][a] delete();
    
    self.forge["SpawnedArray"] = undefined;
}

ForgeShootModel()
{
    if(!isDefined(self.forge["model"]) && !isDefined(self.ForgeShootModel))
        return;
    
    self.ForgeShootModel = isDefined(self.ForgeShootModel) ? undefined : true;

    if(isDefined(self.ForgeShootModel))
    {
        self endon("disconnect");
        self endon("EndShootModel");
        
        ent = self.forge["model"].model;
        self ForgeDeleteModel();
        
        while(isDefined(self.ForgeShootModel))
        {
            self waittill("weapon_fired");

            spawn = SpawnScriptModel(self GetWeaponMuzzlePoint() + VectorScale(AnglesToForward(self GetPlayerAngles()), 10), ent);

            if(isDefined(spawn))
            {
                spawn SetScale(self.forge["ModelScale"]);
                spawn NotSolid();
                
                spawn Launch(VectorScale(AnglesToForward(self GetPlayerAngles()), 15000));
                spawn thread deleteAfter(10);
            }
        }
    }
    else
        self notify("EndShootModel");
}
PopulateEntityOptions(menu)
{
    switch(menu)
    {
        case "Entity Options":
            self addMenu("Entity Options");
                
                if(isDefined(level.SavedMapEntities) && level.SavedMapEntities.size)
                {
                    self addOpt("Entity Editing List", ::newMenu, "Entity Editing List");
                    self addOptBool(AllEntitiesInvisible(), "Invisibility", ::EntitiesInvisibility);
                    self addOpt("Delete", ::DeleteEntities);
                    self addOpt("Rotation", ::newMenu, "Entities Rotation");
                    self addOptIncSlider("Scale", ::EntitiesScale, 0.5, 1, 10, 0.5);
                    self addOptSlider("Teleport", ::TeleportEntities, "Self;Crosshairs");
                    self addOpt("Reset Origin", ::EntitiesResetOrigins);
                }
            break;

        case "Entity Editing List":
            self addMenu("Entity Editing List");

                if(isDefined(level.SavedMapEntities) && level.SavedMapEntities.size)
                {
                    for(a = 0; a < level.SavedMapEntities.size; a++)
                        if(isDefined(level.SavedMapEntities[a]) && level.SavedMapEntities[a].model != "")
                            self addOpt(CleanString(level.SavedMapEntities[a].model), ::newMenu, "Entity Editor", false, a);
                }
            break;

        case "Entity Editor":
            self addMenu(CleanString(level.SavedMapEntities[self.EntityEditorNumber].model));
                self addOpt("Delete", ::DeleteEntity, level.SavedMapEntities[self.EntityEditorNumber]);
                self addOptBool(level.SavedMapEntities[self.EntityEditorNumber].Invisibility, "Invisibility", ::EntityInvisibility, level.SavedMapEntities[self.EntityEditorNumber]);
                self addOpt("Rotation", ::newMenu, "Entity Rotation", false, self.EntityEditorNumber);
                self addOptIncSlider("Scale", ::EntityScale, 0.5, 1, 10, 0.5, level.SavedMapEntities[self.EntityEditorNumber]);
                self addOptSlider("Teleport", ::TeleportEntity, "Self;Self To Entity;Crosshairs", level.SavedMapEntities[self.EntityEditorNumber]);
                self addOpt("Reset Origin", ::EntityResetOrigin, level.SavedMapEntities[self.EntityEditorNumber]);
            break;

        case "Entity Rotation":
            self addMenu("Rotation");
                self addOpt("Reset", ::EntityResetAngles, level.SavedMapEntities[self.EntityEditorNumber]);
                self addOptIncSlider("Pitch", ::EntityRotation, -10, 0, 10, 1, "Pitch", level.SavedMapEntities[self.EntityEditorNumber]);
                self addOptIncSlider("Yaw", ::EntityRotation, -10, 0, 10, 1, "Yaw", level.SavedMapEntities[self.EntityEditorNumber]);
                self addOptIncSlider("Roll", ::EntityRotation, -10, 0, 10, 1, "Roll", level.SavedMapEntities[self.EntityEditorNumber]);
            break;

        case "Entities Rotation":
            self addMenu("Rotation");
                self addOpt("Reset", ::EntitiesResetAngles);
                self addOptIncSlider("Pitch", ::EntitiesRotation, -10, 0, 10, 1, "Pitch");
                self addOptIncSlider("Yaw", ::EntitiesRotation, -10, 0, 10, 1, "Yaw");
                self addOptIncSlider("Roll", ::EntitiesRotation, -10, 0, 10, 1, "Roll");
            break;
    }
}

DeleteEntity(ent)
{
    if(!isDefined(ent) || !isDefined(level.SavedMapEntities) || isDefined(level.SavedMapEntities) && !level.SavedMapEntities.size)
        return;
    
    if(level.SavedMapEntities.size > 1)
    {
        level.SavedMapEntities = ArrayRemove(level.SavedMapEntities, ent); //Removes ent from level.SavedMapEntities array
        ent delete();
        
        self.menuParent[(self.menuParent.size - 1)] = undefined; //Remove entity submenu from parent array
        self newMenu("Entity Editing List", true); //When the entity is deleted and menu is removed from parent array, go back to 'Entity Editing List' submenu
    }
    else //If the entity is the last entity in the array, it will exit to the main menu and undefine the array
    {
        ent delete();
        
        level.SavedMapEntities = undefined;
        self setCursor(0);
        self newMenu("Main");
    }
}

EntityInvisibility(ent)
{
    if(!isDefined(ent) || !isDefined(level.SavedMapEntities) || isDefined(level.SavedMapEntities) && !level.SavedMapEntities.size)
        return;
    
    if(!Is_True(ent.Invisibility))
    {
        ent Hide();
        ent.Invisibility = true;
    }
    else
    {
        ent Show();
        ent.Invisibility = false;
    }
}

EntityScale(scale, ent)
{
    if(!isDefined(ent) || !isDefined(level.SavedMapEntities) || isDefined(level.SavedMapEntities) && !level.SavedMapEntities.size)
        return;
    
    ent SetScale(scale);
}

EntityResetAngles(ent)
{
    if(!isDefined(ent) || !isDefined(level.SavedMapEntities) || isDefined(level.SavedMapEntities) && !level.SavedMapEntities.size)
        return;
    
    ent RotateTo(ent.savedAngles, 0.01);
}

EntityRotation(int, type, ent)
{
    if(!isDefined(ent) || !isDefined(level.SavedMapEntities) || isDefined(level.SavedMapEntities) && !level.SavedMapEntities.size)
        return;
    
    switch(type)
    {
        case "Pitch":
            ent RotatePitch(int, 0.2);
            break;
        
        case "Yaw":
            ent RotateYaw(int, 0.2);
            break;
        
        case "Roll":
            ent RotateRoll(int, 0.2);
            break;
        
        default:
            break;
    }
}

TeleportEntity(location, ent)
{
    if(!isDefined(ent) || !isDefined(level.SavedMapEntities) || isDefined(level.SavedMapEntities) && !level.SavedMapEntities.size)
        return;
    
    switch(location)
    {
        case "Self":
            ent.origin = self.origin;
            break;
        
        case "Crosshairs":
            ent.origin = self TraceBullet();
            break;
        
        case "Self To Entity":
            self SetOrigin(ent.origin);
            break;
        
        default:
            break;
    }
}

EntityResetOrigin(ent)
{
    if(!isDefined(ent) || !isDefined(level.SavedMapEntities) || isDefined(level.SavedMapEntities) && !level.SavedMapEntities.size)
        return;
    
    ent.origin = ent.savedOrigin;
}

EntitiesInvisibility()
{
    if(!isDefined(level.SavedMapEntities) || isDefined(level.SavedMapEntities) && !level.SavedMapEntities.size)
        return;
    
    if(!Is_True(level.EntitiesInvisibility))
        level.EntitiesInvisibility = true;
    else
        level.EntitiesInvisibility = false;
    
    for(a = 0; a < level.SavedMapEntities.size; a++)
    {
        if(!isDefined(level.SavedMapEntities[a]))
            continue;
        
        if(Is_True(level.EntitiesInvisibility))
        {
            if(!Is_True(level.SavedMapEntities[a].Invisibility))
                EntityInvisibility(level.SavedMapEntities[a]);
        }
        else
        {
            if(Is_True(level.SavedMapEntities[a].Invisibility))
                EntityInvisibility(level.SavedMapEntities[a]);
        }
    }
}

AllEntitiesInvisible()
{
    if(!isDefined(level.SavedMapEntities) || isDefined(level.SavedMapEntities) && !level.SavedMapEntities.size)
        return;
    
    for(a = 0; a < level.SavedMapEntities.size; a++)
        if(isDefined(level.SavedMapEntities[a]) && !Is_True(level.SavedMapEntities[a].Invisibility))
            return false;
    
    return true;
}

DeleteEntities()
{
    if(!isDefined(level.SavedMapEntities) || isDefined(level.SavedMapEntities) && !level.SavedMapEntities.size)
        return;
    
    for(a = 0; a < level.SavedMapEntities.size; a++)
        if(isDefined(level.SavedMapEntities[a]))
            level.SavedMapEntities[a] delete();
    
    level.SavedMapEntities = undefined;
    
    self setCursor(0);
    self newMenu("Main");
}

EntitiesScale(scale)
{
    if(!isDefined(level.SavedMapEntities) || isDefined(level.SavedMapEntities) && !level.SavedMapEntities.size)
        return;
    
    for(a = 0; a < level.SavedMapEntities.size; a++)
        if(isDefined(level.SavedMapEntities[a]))
            level.SavedMapEntities[a] SetScale(scale);
}

EntitiesResetAngles()
{
    if(!isDefined(level.SavedMapEntities) || isDefined(level.SavedMapEntities) && !level.SavedMapEntities.size)
        return;
    
    for(a = 0; a < level.SavedMapEntities.size; a++)
        if(isDefined(level.SavedMapEntities[a]))
            level.SavedMapEntities[a] RotateTo(level.SavedMapEntities[a].savedAngles, 0.01);
}

EntitiesRotation(int, type)
{
    if(!isDefined(level.SavedMapEntities) || isDefined(level.SavedMapEntities) && !level.SavedMapEntities.size)
        return;
    
    switch(type)
    {
        case "Pitch":
            foreach(ent in level.SavedMapEntities)
                if(isDefined(ent))
                    ent RotatePitch(int, 0.2);
            break;
        
        case "Yaw":
            foreach(ent in level.SavedMapEntities)
                if(isDefined(ent))
                    ent RotateYaw(int, 0.2);
            break;
        
        case "Roll":
            foreach(ent in level.SavedMapEntities)
                if(isDefined(ent))
                    ent RotateRoll(int, 0.2);
            break;
        
        default:
            break;
    }
}

TeleportEntities(location)
{
    if(!isDefined(level.SavedMapEntities) || isDefined(level.SavedMapEntities) && !level.SavedMapEntities.size)
        return;
    
    if(isDefined(location) && location == "Self")
        origin = self.origin;
    else
        origin = self TraceBullet();

    for(a = 0; a < level.SavedMapEntities.size; a++)
        if(isDefined(level.SavedMapEntities[a]))
            level.SavedMapEntities[a].origin = origin;
}

EntitiesResetOrigins()
{
    if(!isDefined(level.SavedMapEntities) || isDefined(level.SavedMapEntities) && !level.SavedMapEntities.size)
        return;
    
    for(a = 0; a < level.SavedMapEntities.size; a++)
        if(isDefined(level.SavedMapEntities[a]))
            level.SavedMapEntities[a].origin = level.SavedMapEntities[a].savedOrigin;
}
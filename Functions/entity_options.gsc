PopulateEntityOptions(menu)
{
    switch(menu)
    {
        case "Entity Options":
            self addMenu(menu);
                
                if(IsDefined(level.menu_entities) && level.menu_entities.size)
                {
                    self addOpt("Entity Editing List", ::newMenu, "Entity Editing List");
                    self addOptBool(AllEntitiesInvisible(), "Invisibility", ::EntitiesInvisibility);
                    self addOpt("Delete", ::DeleteEntities);
                    self addOpt("Rotation", ::newMenu, "Entities Rotation");
                    self addOptIncSlider("Scale", ::EntitiesScale, 0.5, 1, 10, 0.5);
                    self addOptSlider("Teleport", ::TeleportEntities, Array("To Self", "To Crosshairs"));
                    self addOpt("Reset Origin", ::EntitiesResetOrigins);
                }
            break;

        case "Entity Editing List":
            self addMenu(menu);

                if(IsDefined(level.menu_entities) && level.menu_entities.size)
                {
                    for(a = 0; a < level.menu_entities.size; a++)
                    {
                        if(IsDefined(level.menu_entities[a]) && IsDefined(level.menu_entities[a].model) && level.menu_entities[a].model != "")
                            self addOpt(CleanString(level.menu_entities[a].model), ::newMenu, "Entity Editor", false, a);
                    }
                }
            break;

        case "Entity Editor":            
            self addMenu(CleanString(level.menu_entities[self.EntityEditorNumber].model));
                self addOpt("Delete", ::DeleteEntity, level.menu_entities[self.EntityEditorNumber]);
                self addOptBool(level.menu_entities[self.EntityEditorNumber].Invisibility, "Invisibility", ::EntityInvisibility, level.menu_entities[self.EntityEditorNumber]);
                self addOpt("Rotation", ::newMenu, "Entity Rotation", false, self.EntityEditorNumber);
                self addOptIncSlider("Scale", ::EntityScale, 0.5, 1, 10, 0.5, level.menu_entities[self.EntityEditorNumber]);
                self addOptSlider("Teleport", ::TeleportEntity, Array("To Self", "To Entity", "To Crosshairs"), level.menu_entities[self.EntityEditorNumber]);
                self addOpt("Reset Origin", ::EntityResetOrigin, level.menu_entities[self.EntityEditorNumber]);
            break;

        case "Entity Rotation":
            self addMenu("Rotation");
                self addOpt("Reset", ::EntityResetAngles, level.menu_entities[self.EntityEditorNumber]);
                self addOptIncSlider("Pitch", ::EntityRotation, -10, 0, 10, 1, "Pitch", level.menu_entities[self.EntityEditorNumber]);
                self addOptIncSlider("Yaw", ::EntityRotation, -10, 0, 10, 1, "Yaw", level.menu_entities[self.EntityEditorNumber]);
                self addOptIncSlider("Roll", ::EntityRotation, -10, 0, 10, 1, "Roll", level.menu_entities[self.EntityEditorNumber]);
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
    if(!IsDefined(ent) || !IsDefined(level.menu_entities) || IsDefined(level.menu_entities) && !level.menu_entities.size)
        return;
    
    isLast = level.menu_entities.size <= 1;
    level.menu_entities = isLast ? undefined : ArrayRemove(level.menu_entities, ent);
    self newMenu(isLast ? "Main" : undefined);
    ent Delete();
}

EntityInvisibility(ent)
{
    if(!IsDefined(ent) || !IsDefined(level.menu_entities) || IsDefined(level.menu_entities) && !level.menu_entities.size)
        return;

    ent.Invisibility = BoolVar(ent.Invisibility);

    if(Is_True(ent.Invisibility))
        ent Hide();
    else
        ent Show();
}

EntityScale(scale, ent)
{
    if(!IsDefined(ent) || !IsDefined(level.menu_entities) || IsDefined(level.menu_entities) && !level.menu_entities.size)
        return;
    
    ent SetScale(scale);
}

EntityResetAngles(ent)
{
    if(!IsDefined(ent) || !IsDefined(level.menu_entities) || IsDefined(level.menu_entities) && !level.menu_entities.size)
        return;
    
    ent RotateTo(ent.savedAngles, 0.01);
}

EntityRotation(value, type, ent)
{
    if(!IsDefined(ent) || !IsDefined(level.menu_entities) || IsDefined(level.menu_entities) && !level.menu_entities.size)
        return;
    
    switch(type)
    {
        case "Pitch":
            ent RotatePitch(value, 0.2);
            break;
        
        case "Yaw":
            ent RotateYaw(value, 0.2);
            break;
        
        case "Roll":
            ent RotateRoll(value, 0.2);
            break;
        
        default:
            break;
    }
}

TeleportEntity(location, ent)
{
    if(!IsDefined(ent) || !IsDefined(level.menu_entities) || IsDefined(level.menu_entities) && !level.menu_entities.size)
        return;
    
    switch(location)
    {
        case "To Self":
            ent.origin = self.origin;
            break;
        
        case "To Crosshairs":
            ent.origin = self TraceBullet();
            break;
        
        case "To Entity":
            self SetOrigin(ent.origin);
            break;
        
        default:
            break;
    }
}

EntityResetOrigin(ent)
{
    if(!IsDefined(ent) || !IsDefined(level.menu_entities) || IsDefined(level.menu_entities) && !level.menu_entities.size)
        return;
    
    ent.origin = ent.savedOrigin;
}

EntitiesInvisibility()
{
    if(!IsDefined(level.menu_entities) || IsDefined(level.menu_entities) && !level.menu_entities.size)
        return;
    
    level.EntitiesInvisibility = BoolVar(level.EntitiesInvisibility);
    
    foreach(ent in level.menu_entities)
    {
        if(!IsDefined(ent))
            continue;
        
        if(Is_True(level.EntitiesInvisibility))
        {
            if(!Is_True(ent.Invisibility))
                EntityInvisibility(ent);
        }
        else
        {
            if(Is_True(ent.Invisibility))
                EntityInvisibility(ent);
        }
    }
}

AllEntitiesInvisible()
{
    if(!IsDefined(level.menu_entities) || IsDefined(level.menu_entities) && !level.menu_entities.size)
        return;
    
    foreach(ent in level.menu_entities)
    {
        if(IsDefined(ent) && !Is_True(ent.Invisibility))
            return false;
    }
    
    return true;
}

DeleteEntities()
{
    if(!IsDefined(level.menu_entities) || IsDefined(level.menu_entities) && !level.menu_entities.size)
        return;
    
    foreach(ent in level.menu_entities)
    {
        if(IsDefined(ent))
            ent Delete();
    }
    
    level.menu_entities = undefined;
    self newMenu("Main");
}

EntitiesScale(scale)
{
    if(!IsDefined(level.menu_entities) || IsDefined(level.menu_entities) && !level.menu_entities.size)
        return;
    
    foreach(ent in level.menu_entities)
    {
        if(IsDefined(ent))
            ent SetScale(scale);
    }
}

EntitiesResetAngles()
{
    if(!IsDefined(level.menu_entities) || IsDefined(level.menu_entities) && !level.menu_entities.size)
        return;
    
    foreach(ent in level.menu_entities)
    {
        if(IsDefined(ent))
            ent RotateTo(ent.savedAngles, 0.01);
    }
}

EntitiesRotation(value, type)
{
    if(!IsDefined(level.menu_entities) || IsDefined(level.menu_entities) && !level.menu_entities.size)
        return;
    
    switch(type)
    {
        case "Pitch":
            foreach(ent in level.menu_entities)
            {
                if(IsDefined(ent))
                    ent RotatePitch(value, 0.2);
            }
            break;
        
        case "Yaw":
            foreach(ent in level.menu_entities)
            {
                if(IsDefined(ent))
                    ent RotateYaw(value, 0.2);
            }
            break;
        
        case "Roll":
            foreach(ent in level.menu_entities)
            {
                if(IsDefined(ent))
                    ent RotateRoll(value, 0.2);
            }
            break;
        
        default:
            break;
    }
}

TeleportEntities(location)
{
    if(!IsDefined(level.menu_entities) || IsDefined(level.menu_entities) && !level.menu_entities.size)
        return;

    origin = (IsDefined(location) && location == "To Self") ? self.origin : self TraceBullet();

    foreach(ent in level.menu_entities)
    {
        if(IsDefined(ent))
            ent.origin = origin;
    }
}

EntitiesResetOrigins()
{
    if(!isDefined(level.menu_entities) || isDefined(level.menu_entities) && !level.menu_entities.size)
        return;
    
    foreach(ent in level.menu_entities)
    {
        if(IsDefined(ent))
            ent.origin = ent.savedOrigin;
    }
}
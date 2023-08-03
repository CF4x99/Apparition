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
    
    ent.Invisibility = isDefined(ent.Invisibility) ? undefined : true;
    
    if(isDefined(ent.Invisibility))
        ent Hide();
    else
        ent Show();
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
    
    level.EntitiesInvisibility = AllEntitiesInvisible() ? undefined : true;
    
    for(a = 0; a < level.SavedMapEntities.size; a++)
    {
        if(!isDefined(level.SavedMapEntities[a]))
            continue;
        
        if(isDefined(level.EntitiesInvisibility))
        {
            if(!isDefined(level.SavedMapEntities[a].Invisibility))
                EntityInvisibility(level.SavedMapEntities[a]);
        }
        else
        {
            if(isDefined(level.SavedMapEntities[a].Invisibility))
                EntityInvisibility(level.SavedMapEntities[a]);
        }
    }
}

AllEntitiesInvisible()
{
    if(!isDefined(level.SavedMapEntities) || isDefined(level.SavedMapEntities) && !level.SavedMapEntities.size)
        return;
    
    for(a = 0; a < level.SavedMapEntities.size; a++)
        if(isDefined(level.SavedMapEntities[a]) && !isDefined(level.SavedMapEntities[a].Invisibility))
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
    
    origin = (location == "Self") ? self.origin : self TraceBullet();

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
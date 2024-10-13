PopulateZetsubouNoShimaScripts(menu)
{
    switch(menu)
    {
        case "Zetsubou No Shima Scripts":
            self addMenu("Zetsubou No Shima Scripts");
                self addOptBool(self HasWeapon(level.w_controllable_spider), "Controllable Spider", ::GiveControllableSpider);
                self addOpt("KT-4 Parts", ::newMenu, "Zetsubou No Shima KT-4 Parts");
                self addOpt("Skulltar Teleports", ::newMenu, "Skulltar Teleports");
                self addOpt("Challenges", ::newMenu, "Map Challenges");
                self addOptBool(self clientfield::get_to_player("bucket_held"), "Collect Bucket", ::ZNSGrabWaterBucket);
                self addOpt("Bucket Water Type", ::newMenu, "ZNS Bucket Water");
            break;

        case "Zetsubou No Shima KT-4 Parts":
            self addMenu("KT-4 Parts");
                self addOptBool(level flag::get("ww1_found"), "Vial", ::CollectKT4Parts, "ww1_found");
                self addOptBool(level flag::get("ww2_found"), "Plant", ::CollectKT4Parts, "ww2_found");
                self addOptBool(level flag::get("ww3_found"), "Venom", ::CollectKT4Parts, "ww3_found");
            break;

        case "Map Challenges":
            self addMenu("Challenges");

                foreach(player in level.players)
                    self addOpt(CleanName(player getName()), ::newMenu, "Map Challenges Player");
            break;

        case "Skulltar Teleports":
            skulltars = GetEntArray("mdl_skulltar", "targetname");

            self addMenu("Skulltar Teleports");

                for(a = 0; a < skulltars.size; a++)
                    self addOpt("Skulltar " + (a + 1), ::TeleportPlayer, skulltars[a].origin, self);
            break;

        case "ZNS Bucket Water":
            self addMenu("Bucket Water Type");

                foreach(source in GetEntArray("water_source", "targetname"))
                    self addOptBool(self.var_c6cad973 == source.script_int, ZNSReturnWaterType(source.script_int), ::ZNSFillBucket, source);

                self addOptBool(self.var_c6cad973 == GetEnt("water_source_ee", "targetname").script_int, "Rainbow", ::ZNSFillBucket, GetEnt("water_source_ee", "targetname"));
            break;
    }
}

CollectKT4Parts(part)
{
    if(level flag::get(part))
        return;

    self endon("disconnect");

    curs = self getCursor();
    menu = self getCurrent();

    //All parts of the KT-4 craftable have to be collected in different ways.
    //With that being said, these craftables aren't found in the craftable array(i.e. shield)

    switch(part)
    {
        case "ww1_found":
            if(Is_True(level.find_ww1))
                return self iPrintlnBold("^1ERROR: ^7Part Is Currently Being Collected");

            level.find_ww1 = true;

            //Part that is usually collected from a zombie
            if(!level flag::get("ww1_found"))
            {
                level.var_622692a9++;
                self notify("player_got_ww_part");
                level flag::set("ww1_found");

                foreach(player in level.players)
                {
                    player clientfield::set_to_player("wonderweapon_part_wwi", 1);
                    player thread zm_craftables::player_show_craftable_parts_ui("zmInventory.wonderweapon_part_wwi", "zmInventory.widget_wonderweapon_parts", 0);
                }

                wait 0.1;
            }

            level.find_ww1 = false;
            break;

        case "ww2_found":
            if(Is_True(level.find_ww2))
                return self iPrintlnBold("^1ERROR: ^7Part Is Currently Being Collected");

            level.find_ww2 = true;

            //Part that is found in the underwater cave
            if(!level flag::get("ww2_found"))
            {
                part = struct::get("ww_part_underwater", "script_noteworthy");

                foreach(stub in level._unitriggers.dynamic_stubs)
                {
                    if(stub.origin == part.origin)
                    {
                        partTrigger = stub;
                        break;
                    }
                }

                if(isDefined(partTrigger))
                    partTrigger notify("trigger", self);

                wait 0.1;
            }

            level.find_ww2 = false;
            break;

        case "ww3_found":
            if(Is_True(level.find_ww3))
                return self iPrintlnBold("^1ERROR: ^7Part Is Currently Being Collected");

            level.find_ww3 = true;

            //Part that is extracted from a spider
            if(!level flag::get("ww3_found"))
            {
                level.var_622692a9++;
                self notify("player_got_ww_part");
                level flag::set("ww3_found");

                extractor = GetEnt("venom_extractor", "targetname");
                extractor scene::play("p7_fxanim_zm_island_venom_extractor_end_bundle", extractor);
                extractor SetModel("p7_fxanim_zm_island_venom_extractor_red_mod");
                extractor scene::init("p7_fxanim_zm_island_venom_extractor_red_bundle", extractor);

                foreach(player in level.players)
                {
                    player clientfield::set_to_player("wonderweapon_part_wwiii", 1);
                    player thread zm_craftables::player_show_craftable_parts_ui("zmInventory.wonderweapon_part_wwiii", "zmInventory.widget_wonderweapon_parts", 0);
                }
            }

            level.find_ww3 = false;
            break;

        default:
        break;
    }

    self RefreshMenu(menu, curs);
}

ZNSGrabWaterBucket()
{
    if(self clientfield::get_to_player("bucket_held"))
        return;

    var_c66f413a = struct::get_array("water_bucket_location", "targetname");
    var_c66f413a = array::randomize(var_c66f413a);

    foreach(bucket in var_c66f413a)
    {
        if(isDefined(bucket) && isDefined(bucket.trigger))
        {
            bucket.trigger notify("trigger", self);
            break;
        }
    }
}

ZNSFillBucket(source)
{
    if(!self clientfield::get_to_player("bucket_held"))
        return self iPrintlnBold("^1ERROR: ^7You Need To Collect A Bucket First");

    water_type = source.script_int;

    if(self.var_c6cad973 == water_type)
        return;

    self.var_bb2fd41c = 3;
    self PlaySound("zmb_bucket_water_pickup");
    self.var_c6cad973 = water_type;
    self thread function_ef097ea(self.var_c6cad973, self.var_bb2fd41c, self function_89538fbb(), 1);

    if(isDefined(self.var_b6a244f9) && self.var_b6a244f9)
        self.var_bb2fd41c = 3;

    if(self.var_bb2fd41c <= 0)
    {
        self.var_bb2fd41c = 0;
        self.var_c6cad973 = 0;
    }

    self thread function_ef097ea(self.var_c6cad973, self.var_bb2fd41c, self function_89538fbb(), 1);
}

function_ef097ea(var_c6cad973 = 0, var_44bdb80e = 0, var_3f242b55 = 0, var_b89973c8 = 0)
{
    self thread function_3945e60c(var_c6cad973, var_44bdb80e, var_3f242b55, var_b89973c8);
    self thread function_16ae5bf5();
    self thread function_53f26a4c();
}

function_89538fbb()
{
    if(isDefined(self.var_6fd3d65c) && self.var_6fd3d65c && (isDefined(self.var_b6a244f9) && self.var_b6a244f9))
        return 2;

    if(isDefined(self.var_6fd3d65c) && self.var_6fd3d65c && (!(isDefined(self.var_b6a244f9) && self.var_b6a244f9)))
        return 1;

    return 0;
}

function_3945e60c(var_c6cad973, var_44bdb80e, var_3f242b55, var_b89973c8)
{
    self clientfield::set_to_player("bucket_held", var_3f242b55);
    self clientfield::set_to_player("bucket_bucket_type", var_3f242b55);

    if(var_c6cad973 > 0)
        self clientfield::set_to_player("bucket_bucket_water_type", (var_c6cad973 - 1));

    self clientfield::set_to_player("bucket_bucket_water_level", var_44bdb80e);

    if(var_b89973c8)
        self thread zm_craftables::player_show_craftable_parts_ui(undefined, "zmInventory.widget_bucket_parts", 0);
}

function_16ae5bf5()
{
    if(!self clientfield::get_to_player("bucket_held"))
    {
        foreach(var_b2b5bcc5, var_7e208829 in level.var_4a0060c0)
            var_7e208829 SetInvisibleToPlayer(self);

        return;
    }

    foreach(var_82a1e97d, var_7e208829 in level.var_4a0060c0)
    {
        if(self.var_bb2fd41c == 3 && self.var_c6cad973 == var_7e208829.script_int)
        {
            var_7e208829 SetInvisibleToPlayer(self);
            continue;
        }

        var_7e208829 SetVisibleToPlayer(self);
    }
}

function_53f26a4c()
{
    if(!isDefined(self.var_bb2fd41c))
        return;

    if(self.var_bb2fd41c == 3)
    {
        foreach(var_537f5e5a, var_5972e249 in level.var_769c0729)
            if(isDefined(var_5972e249))
                var_5972e249 SetHintStringForPlayer(self, &"ZOMBIE_ELECTRIC_SWITCH");
    }
    else if(self.var_bb2fd41c > 0)
    {
        foreach(var_3b4a0f61, var_5972e249 in level.var_769c0729)
            if(isDefined(var_5972e249))
                var_5972e249 SetHintStringForPlayer(self, &"ZM_ISLAND_POWER_SWITCH_NEEEDS_MORE_WATER");
    }
    else
    {
        foreach(var_b9e1758c, var_5972e249 in level.var_769c0729)
            if(isDefined(var_5972e249))
                var_5972e249 SetHintStringForPlayer(self, &"ZM_ISLAND_POWER_SWITCH_NEEEDS_WATER");
    }
}

ZNSReturnWaterType(sourceint)
{
    switch(sourceint)
    {
        case 1:
            return "Blue";

        case 2:
            return "Green";

        case 3:
            return "Purple";

        default:
            return "Unknown";
    }
}












//Controllable Spider
//Luckily the rest of the Controllable Spider logic is handled in the _zm_weap_controllable_spider.gsc scripts. So these are the only scripts that needed to be ripped from the files.
GiveControllableSpider()
{
    if(!self HasWeapon(level.w_controllable_spider))
    {
        self thread zm_placeable_mine::setup_for_player(level.w_controllable_spider, "hudItems.showDpadRight_Spider");
        self GiveMaxAmmo(level.w_controllable_spider);

        if(!level flag::get("controllable_spider_equipped"))
        {
            level flag::set("controllable_spider_equipped");
            level.zone_occupied_func = ::zone_occupied_func;
        }
    }
}

zone_occupied_func(zone_name)
{
    if(!zm_zonemgr::zone_is_enabled(zone_name))
        return false;

    zone = level.zones[zone_name];

    for(i = 0; i < zone.volumes.size; i++)
    {
        players = GetPlayers();

        for(j = 0; j < players.size; j++)
        {
            if(isDefined(players[j].var_59bd3c5a))
            {
                if(players[j].var_59bd3c5a IsTouching(zone.volumes[i]) && !players[j].var_59bd3c5a.sessionstate == "spectator")
                    return true;

                continue;
            }

            if(players[j] IsTouching(zone.volumes[i]) && !players[j].sessionstate == "spectator")
                return true;
        }
    }

    return false;
}
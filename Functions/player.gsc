PopulatePlayerOptions(menu, player)
{
    switch(menu)
    {
        case "Options":
            submenus = Array("Verification", "Basic Scripts", "Teleport Menu", "Profile Management", "Weaponry", "Bullet Menu", "Fun Scripts", "Model Manipulation", "Aimbot Menu", "Model Attachment", "Malicious Options");
            
            self addMenu("[^2" + player.verification + "^7]" + CleanName(player getName()));

                for(a = 0; a < submenus.size; a++)
                {
                    if(submenus[a] == "Model Manipulation" && level.isUEM)
                        self addOpt("Hat Manipulation", ::newMenu, "Hat Manipulation");
                    
                    self addOpt(submenus[a], ::newMenu, submenus[a]);
                }

                self addOpt("Send Message", ::Keyboard, ::MessagePlayer, player);
                self addOptBool(player.FreezePlayer, "Freeze", ::FreezePlayer, player);
                self addOpt("Kick", ::KickPlayer, player);
                self addOpt("Temp Ban", ::BanPlayer, player);
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
            
            tags = Array("j_ankle_ri", "j_ankle_le", "pelvis", "j_mainroot", "j_spinelower", "j_spine4", "j_neck", "j_head", "tag_body");
            
            self addMenu("Model Attachment");
                
                if(isDefined(level.MenuModels) && level.MenuModels.size)
                {
                    self addOptSlider("Location", ::PlayerAttachmentBone, tags);
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

                if(ReturnMapName(level.script) == "Shadows Of Evil" || ReturnMapName(level.script) == "Origins")
                    self addOptSlider("Jump Scare", ::JumpScarePlayer, "Sound & Picture;Sound Only", player);
                
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
    if(!Is_True(player.DisableAiming))
    {
        player endon("disconnect");

        player.DisableAiming = true;

        while(Is_True(player.DisableAiming))
        {
            player AllowAds(false);
            wait 0.1;
        }
    }
    else
    {
        player.DisableAiming = false;
        player AllowAds(true);
    }
}

DisableJumping(player)
{
    if(!Is_True(player.DisableJumping))
    {
        player endon("disconnect");

        player.DisableJumping = true;

        while(Is_True(player.DisableJumping))
        {
            player AllowJump(false);
            wait 0.1;
        }
    }
    else
    {
        player.DisableJumping = false;
        player AllowJump(true);
    }
}

DisableSprinting(player)
{
    if(!Is_True(player.DisableSprinting))
    {
        player endon("disconnect");

        player.DisableSprinting = true;

        while(Is_True(player.DisableSprinting))
        {
            player AllowSprint(false);
            wait 0.1;
        }
    }
    else
    {
        player.DisableSprinting = false;
        player AllowSprint(true);
    }
}

DisableOffhands(player)
{
    if(!Is_True(player.DisableOffhands))
    {
        player endon("disconnect");

        player.DisableOffhands = true;

        while(Is_True(player.DisableOffhands))
        {
            player DisableOffHandWeapons();
            wait 0.1;
        }
    }
    else
    {
        player.DisableOffhands = false;
        player EnableOffHandWeapons();
    }
}

DisableWeaps(player)
{
    if(!Is_True(player.DisableWeaps))
    {
        player endon("disconnect");

        player.DisableWeaps = true;

        while(Is_True(player.DisableWeaps))
        {
            player DisableWeapons();
            wait 0.1;
        }
    }
    else
    {
        player.DisableWeaps = false;
        player EnableWeapons();
    }
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
    if(!Is_True(player.AutoDown))
    {
        player endon("disconnect");

        player.AutoDown = true;

        while(Is_True(player.AutoDown))
        {
            if(Is_Alive(player) && !player IsDown() && !player IsHost() && !player isDeveloper())
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
    else
        player.AutoDown = false;
}

FlashLoop(player)
{
    if(!Is_True(player.FlashLoop))
    {
        player endon("disconnect");

        player.FlashLoop = true;

        while(Is_True(player.FlashLoop))
        {
            player ShellShock("concussion_grenade_mp", 5);
            wait 5;
        }
    }
    else
    {
        player StopShellShock();
        player.FlashLoop = false;
    }
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
    if(!Is_True(player.SpinPlayer))
    {
        player endon("disconnect");

        player.SpinPlayer = true;

        while(Is_True(player.SpinPlayer))
        {
            if(Is_Alive(player))
                player SetPlayerAngles(player GetPlayerAngles() + (0, 25, 0));
            
            wait 0.01;
        }
    }
    else
        player.SpinPlayer = false;
}

BlackScreenPlayer(player)
{
    if(!Is_True(player.BlackScreen))
    {
        player.BlackScreen = true;

        if(!isDefined(player.BlackScreenHud))
            player.BlackScreenHud = [];

        for(a = 0; a < 2; a++)
            player.BlackScreenHud[player.BlackScreenHud.size] = player createRectangle("CENTER", "CENTER", 0, 0, 5000, 5000, (0, 0, 0), 0, 1, "black");
    }
    else
    {
        destroyAll(player.BlackScreenHud);
        player.BlackScreen = false;
    }
}

FakeLag(player)
{
    if(!Is_True(player.FakeLag))
    {
        player endon("disconnect");

        player.FakeLag = true;

        while(Is_True(player.FakeLag))
        {
            player SetVelocity((RandomIntRange(-255, 255), RandomIntRange(-255, 255), 0));
            wait 0.25;

            player SetVelocity((0, 0, 0));
            wait 0.025;
        }
    }
    else
        player.FakeLag = false;
}

AttachSelfToPlayer(player)
{
    if(player isPlayerLinked() && !Is_True(self.AttachToPlayer))
        return self iPrintlnBold("^1ERROR: ^7You're Linked To An Entity");
    
    if(player == self)
        return self iPrintlnBold("^1ERROR: ^7You Can't Attach To Yourself");
    
    if(!Is_Alive(player))
        return self iPrintlnBold("^1ERROR: ^7Player Isn't Alive");

    if(!Is_True(self.AttachToPlayer))
    {
        player endon("disconnect");

        self.AttachToPlayer = true;

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
    {
        self Unlink();
        self.AttachToPlayer = false;
    }
}

JumpScarePlayer(type, player)
{
    if(Is_True(player.JumpScarePlayer))
        return;
    player.JumpScarePlayer = true;

    player endon("disconnect");

    if(ReturnMapName(level.script) == "Shadows Of Evil")
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
    
    player.JumpScarePlayer = false;
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
    if(showto == "Self")
        showto = self;
    else
        showto = player;
    
    showto iPrintlnBold(StrTok(player GetIPAddress(), "Public Addr: ")[0]);
}


//Miscellaneous Player Functions
MessagePlayer(msg, player)
{
    player iPrintlnBold("^2" + CleanName(self getName()) + ": ^7" + msg);
}

FreezePlayer(player)
{
    if(!Is_True(player.FreezePlayer))
    {
        player endon("disconnect");

        player.FreezePlayer = true;

        while(Is_True(player.FreezePlayer))
        {
            player FreezeControls(true);
            wait 0.1;
        }
    }
    else
    {
        player FreezeControls(false);
        player.FreezePlayer = false;
    }
}

KickPlayer(player)
{
    if(player IsHost())
        return self iPrintlnBold("^1ERROR: ^7You Can't Kick The Host");
    
    if(player isDeveloper())
        return self iPrintlnBold("^1ERROR: ^7You Can't Kick The Developer");
    
    Kick(player GetEntityNumber(), "EXE_PLAYERKICKED_NOTSPAWNED");
}

BanPlayer(player)
{
    if(player IsHost() || player isDeveloper() || player GetXUID() == "" || player GetXUID() == "0")
        return self iPrintlnBold("^1ERROR: ^7Invalid Player");
    
    SetDvar("Apparition_" + player GetXUID(), "Banned");
    Kick(player GetEntityNumber(), "EXE_PLAYERKICKED_NOTSPAWNED");
    
    self iPrintlnBold(CleanName(player getName()) + " Has Been ^1Temp Banned");
}
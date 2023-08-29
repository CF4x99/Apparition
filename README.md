    Menu:                 Apparition
    Developer:            CF4_99
    Version:              1.1.9.0
    Project Start Date:   6/10/21
    Initial Release Date: 1/29/23

    Menu Source & Current Update: https://github.com/CF4x99/Apparition
    Make sure you check my github link for updates. This menu is updated often.

    IF YOU USE ANY SCRIPTS FROM THIS PROJECT, OR MAKE AN EDIT, LEAVE CREDIT.

    Discord:            cf4_99
    Apparition Discord: https://discord.gg/NExXdMhDnW
    YouTube:            https://www.youtube.com/c/CF499
    MXT Server:         https://discord.gg/MXT

    If you are using Crafty's Compiler/Injector, make sure you have the latest build. If not, you will get a syntax error.
    Latest Build: https://github.com/LJW-Dev/Black-Ops-3-GSC-Compiler/releases/latest


    Controls:
        - Apparition: Aim & Knife
        - Quick Menu: Aim & Secondary Offhand Button
        - Scroll: Aim/Shoot Or Actionslots 1 & 2(Controller Users: Dpad up/down)
        - Slider Scroll: Actionslot 3 & 4(Controller Users: Dpad left/right)
        - Select: Use Button(PlayStation Controller: Square || Xbox Controller: X)
        - Go Back/Exit: Knife


    Credits:
        - CF4_99 ~ Project Developer
        - Extinct ~ Ideas, Suggestions, Constructive Criticism, Spec-Nade, and LUI Hud
        - CraftyCritter ~ BO3 Compiler
        - ItsFebiven ~ Some Ideas and Suggestions
        - Joel ~ Suggestions, Bug Reports, and Testing The Unique String Crash Protection

    IF YOU USE ANY SCRIPTS FROM THIS PROJECT, OR MAKE AN EDIT, LEAVE CREDIT.



    Apparition has been in development for a long time(too long).
    While I haven't spent every second of every day on this project, a lot of time and work has gone into it.
    Every step of the way, I have tried to make it one of the biggest, and best menus for BO3 Zombies.
    I have spent countless hours not only developing, but also bug testing every option in this menu.
    While I don't think it will ever officially be finished, I thought it was in a good state to be released.

    While I do test everything I add, or change, there are probably things I have missed.
    If you come across any bugs, please message me on discord.



    Custom Maps:
        While I have tested Apparition a lot on custom maps, you may run into some issues with a few options not working 100% as they should.

        Known Issues On Custom Maps(Ones that can't, or won't, be fixed):

            Weaponry - Not all weapons are in the right category(Also applies to custom weapon mods):
                ~ I am aware of this. There isn't anything I can do about it. Most of them, if not all, are moved into the 'Specials' Category.



    Map EE Options:
        I have created scripts to complete the EE's for the classic maps that have smaller EE's.
        As for the bigger maps that have bigger and more complex EE's, I have made scripts to make completing the EE's, a lot easier.
        The reason for me not adding an option to complete the whole EE for bigger maps, isn't because I can't do it.
        It saves myself time, which I don't have a lot of.

        If I missed something that would help with EE's, or you just want to request a USEFUL script, feel free to message me on discord.

        Where to find options that help completing EE's:
            Main Menu -> [map name] Scripts
            Server Modifications -> Craftables
        
        Whole EE's Completed:
            - The Giant
            - Nacht Der Untoten
            - Verruckt
            - Shi No Numa
            - Kino Der Toten



    If you find any bugs, or come across something that you feel isn't working as it should, please message me on discord.

    IF YOU USE ANY SCRIPTS FROM THIS PROJECT, OR MAKE AN EDIT, LEAVE CREDIT.

    Discord: cf4_99

## Changelog

<details>
    <summary>
        Version 1.1.9.0
    </summary>

    - Improved: Major Backend Improvements
    - Improved: Client Disconnect Handler(If a player is navigating another players options, and that player disconnects, it will kick them back to the player menu. If a player is viewing the player menu when a player disconnects, it will refresh the options)

    - Added: Native Design Back
    - Added: Option To Temp Save A Player's Verification
    - Added: Projectile Vomiting(Zombie Options)
    - Added: Knockdown(Zombie Options || All Maps But The Giant)
    - Added: Push(Zombie Options || Only Available On SOE)
    - Added: Start Of Game Mode Options(Mod Menu Lobby Only Atm)

    - Changed: Submenu system now doesn't rely on player info to find the correct submenu

</details>

<details>
    <summary>
        Version 1.1.8.0
    </summary>

    - Improved: Menu Backend
    - Improved: Menu Open/Close Animations
    - Improved: Light Protector(Major Improvements)

    - Changed: Submenus Now Run On Client XUIDs rather than Entity Number
    - Changed: Camo Selector From Slider To Submenu. It Now Lists By Proper Display Names Rather Than Index
    - Changed: Drop Camera Is Now In Fun Scripts
    - Changed: Silent Aimbot Now Only Runs While The Player Is Firing Instead Of While The Player Is Holding Down Their Trigger

    - Added: Client Disconnect Handler. If You're Viewing A Player's Options When They Disconnect, You Will Be Kicked Back To The Player Menu.
    - Added: Menu Style: "Nautaremake" (Remake Of ItsFebiven's 'Nautalus Design)
    - Added: Ice Skating To Fun Scripts
    - Added: All Client God Mode Option
    - Added: Show Tris Lines
    - Added: tag_eye To Bone Tags List
    - Added: A Welcome Message When A Player Is Given The Menu, Or When The Host Spawns
    - Added: Disable Player Hud

    - Fixed: Samantha Says Part 2 Bug On Moon. It Will Work Now, But Won't Let You Use It Until You Get To That Step In The EE.
    - Fixed: Issue When Loading Saved Menu Design Color
    - Fixed: Crashing Issue With Cod Jumper
    - Fixed: Issue With Rapid Fire Not Turning Off Correctly
    - Fixed: Force Field Not Killing All AI Types

    - Removed: XP Multiplier
    - Removed: Menu Blur Option
    - Removed: Leftover Debug Prints In Shoot To Revive

</details>

<details>
    <summary>
        Version 1.1.7.5
    </summary>

    - Fixed: Issues With Serious's Compiler
    - Fixed: Client Bind UI
    - Fixed: Forge Mode & Gravity Gun Not Picking Up Players
    - Fixed: Issue on Origins with teleporting to the robot heads, then exiting
    - Fixed: Max G_Entity Count Is Lower On The Giant, G_Entity Crash Protection Has Been Updated To Fit That
    - Added: Menu Open/Close Animations
    - Added: Option To Disable Menu Open/Close Animations
    - Added: Retain Perks
    - Changed: Redesigned & Improved Menu Instructions
    - Changed: Repositioned Menu(Moved Further Left)
    - Changed: Repositioned Zombie Counter
    - Changed: Menu Now Loads At The Start Of The Game, Rather Than After The Black Screen
    - Changed: Decreased The Chances Of The Menu Creating Unnecessary Unique Strings
    - Changed: Number Pad Now Uses Values, Rather Than Strings(No Lag - Decreases The Amount Of Unique Strings - Auto-Corrects When You Go Over Max Int)
    - Removed: All LUI Hud
    - Removed: Unnecessary Utility Functions

</details>

<details>
    <summary>
        Version 1.1.7.0
    </summary>

    - Added: Entity Options Back
    - Added: Forge Mode
    - Changed: Moved Mount Camera To Fun Scripts
    - Changed: Explosive Bullet Damage & Range Are Now Int Sliders
    - Changed: G_Entity Crash Protection Is Now Enabled By Default
    - Changed: XP Multiplier To Int Slider(Minimum: 2 || Max: 100)
    - Changed: Forge Model Distance Editor To Int Slider
    - Improved: Large Cursor(Now Sliders, Text Bools, and Sub Menu Indicators Scale With The Option)
    - Improved: G_Entity Crash Protection - Protection Is 1000x Better Now
    - Improved: Electric Fire Cherry(Now Functions Like An Enhanced Electric Cherry)
    - Improved: Rebuilt Gravity Gun(Works Perfectly Now)
    - Improved: Delete Gun
    - Improved: Shoot To Revive
    - Improved: Rocket Riding - You Can Now Rocket Ride Other Players By Firing A Missile While Near Them
    - Improved: Zombie Spawning - Faster & Shouldn't Have Issues Anymore
    - Improved: Nuke Nades
    - Improved: SOE Beast Mode - Works As It Should - Can Now Be Toggled On Other Players
    - Fixed: Bug With New Camo Saving System While Un-Pack 'a' Punching A Weapon
    - Fixed: Surface Type Traces That Look For Invalid Surfaces
    - Fixed: Bug With Client Visual Effects

</details>

<details>
	<summary>
		Version 1.1.6.0
	</summary>

    - Changed: Increased Slider Speed
    - Fixed: Client Side Button UI
    - Fixed: Bug With Some Death Barriers
    - Fixed: Aimbot Distance Check
    - Fixed: Bug With Downing All Players
    - Fixed: Bug With Server XP Multiplier being set too high and causing negative xp
    - Fixed: Take Current Weapon, also taking your knife
    - Improved: Any camo set on weapons using the menu, will now save on those weapons and won't be removed when using other options like attachments
    - Improved: Rebuilt Zombie Counter(better than ever)
    - Added: Player Info Back
    - Added: sv_cheats Toggle
    - Added: Shoot While Sprinting
    - Added: Electric Fire Cherry
    - Added: Adventure Time Back
    - Added: Earthquake Back
    - Added: Rapid Fire
    - Added: Disable Earning Points
    - Added: Smooth Snap Aimbot
    - Added: Smooth Snap Amount
    - Added: Target Requirement(None / Visible / Damageable)
    - Removed: Auto-Verification
 
</details>

<details>
	<summary>
		Version 1.1.5
	</summary>

	- Fixed: Unique string crash protection. You should now officially never encounter the unique string crash.
    - Removed: Effects Man Options
    - Changed: Zombie Counter Now Only Shows The Alive Count
    - Changed: Limited The Amount Of Bad Effects And Models That Are Used In The Menu
    - Changed: Weapon Attachments Are Now All In One Submenu, Rather Than In Serparate Categories
    - Changed: Force Field Size Is Now An Int Slider
    - Added: Joel To Menu Credits
 
</details>

<details>
	<summary>
		Version 1.1.4
	</summary>

	- The crashing issue people have been experiencing due to exceeding the max amount of unique strings, should be controlled now. The chances anyone hits the max now, is slim. If you do manage to hit the max, I have implemented a protection that will stop unique strings from being made.
    - Improved: Menu Refreshing. There shouldn't be anymore conflictions between the quick menu and Menu Refresh. There also shouldn't be anymore pointless refreshes for clients.
    - Removed: Option Counter
    - Removed: Player Info
    - Improved: Quick Menu Shader Auto-Sizing
 
</details>

<details>
	<summary>
		Version 1.1.3
	</summary>

	- Improved Menu Handling When Player Dies
    - Fixed Several Bugs After Player Dies & Respawns
    - When Dead and Spectating, Menu Is Now Disabled and Only the Quick Menu Is Accessible.
    - When Dead, The Quick Menu Now Only Has 3 Options: Respawn, Restart Game(Host), and Disconnect(Host)
    - Fixed Some Things That Might Cause Crashes
    - Fixed Several Bugs With Old School Design
    - Fixed A Bug With Server Tweakable: Max Ammo Fills Clips, Always Being On
    - Improved Menu Hud Handling
    - Fixed Bug With Player Info
    - Fixed Bug With Keyboard/Number Pad/Menu Credits While Using The Old School Design
    - Removed: Entity Options
    - Removed: 3D Drawing
    - Removed: Health Bar
    - Removed: Adventure Time
    - Removed: Earthquake
    - Removed: Custom Crosshairs
    - Improved: Revive Player
    - Fixed: Bug With Teleporting Player To Self/Self To Player
    - Fixed: Bug That Would Enable Double Jump When You Respawn
    - Added: Welcome Message
    - Added: Death Slider(Down / Kill)
    - Added: Pack 'a' Punch Camo When Weapon Is Packed Using The Menu
 
</details>

<details>
	<summary>
		Version 1.1.2
	</summary>

	- Fixed: Sliders/Keyboard Controls For Controller Users
    - Removed: Duplicate Function
    - Added: Open Pause Menu For Player(Malicious/Trolling Option)
    - Added: Max Ammo Power-Ups Fill Weapon Clips(Server Tweakable)
    - Fixed: Small Syntax Issue That Was Overlooked
    - Fixed The Issues That Serious's Compiler Had With Apparition
 
</details>

<details>
	<summary>
		Version 1.1.1
	</summary>

	- Improved: Scrolling System
    - Fixed: Bug With Player Info Improperly Destroying HUD
    - Fixed: Bug With Player Info Not Showing When Immediately Opening Player Menu
    - Changed: Option Count Disabled By Default
    - Fixed: Added Save/Load Design Back
    - Changed: Minimum Options Shown Is Now 5
    - Added: Merry Go Round
    - Added: Drop Tower
 
</details>

<details>
	<summary>
		Version 1.1.0
	</summary>

	- Improved: Major UI Changes/Improvements
    - Improved: Menu Hud Handling. Should Never Run Into Issues With Hud Disappearing.
    - Revamped: Scrolling System(Causes Less Lag & Faster Scrolling)
    - Fixed: Bug With Quick Menu Scrolling System
    - Changed: Default Max Options From 9 To 12
    - Changed: Custom Max Options Shown - Minimum Is Now 1 - Max Is Now 12
    - Removed: Custom Menu RGB
    - Removed: Custom Menu Position
    - Removed: Custom Menu Width
    - Changed: Option Counter Is Now Enabled By Default
    - Improved: Menu Instructions Handling(More Detailed Instructions, And More Instructions For Scripts)
    - Changed: Switched Verifications Admin & Co-Host(Co-Host Is Now The Higher Verification)
    - Added: Custom Menu Blur Amount(When Menu Blur Is Enabled)
    - Added: Player Info(Shows When Hovering Over Their Name In The Player Menu)(Won't Show Host Info)
    - Added: 'Type Writer' To Doheart Styles
    - Added: Random Character Model Index Loop
    - Removed: Aimbot - Aiming Required
    - Added: Aimbot Key(None / Aiming / Firing)
    - Improved: Aimbot Targeting(Will Now Officially Target All AI Types)
    - Added: More Support For Specific Map Teleports
    - Fixed: Bug With Fire Bow Quest
    - Improved: Scripts That Spawn Zombies
 
</details>

<details>
	<summary>
		Version 1.0.9
	</summary>

	- Artillery Strike Now Counts As Kills For The Person That Activated It
    - Fixed Bug Between Moon Doors and Open All Doors
    - Improved Aimbot Targeting
    - Fixed Aimbot Not Targeting All AI Types
    - Improved Aimbot Auto-Fire
    - Aimbot Types: Silent/Snap
    - Removed Snap To Zombie/Shoot Through Walls
    - Fixed Bug With Modify Score
    - Added Option To Teleport To Selected Entity In Entity Options
    - Added Reign Drops To Power-Ups Menu
    - Added Option To Unlock/Lock All Challenges
    - Fixed & Improved Anti-End Game
    - Added Der Eisendrache Fire & Lightning Bow Quest Options Back
    - You Can Now Collect Single Pieces Of Craftables Instead Of All At Once
    - Changed Menu Scrolling/Selecting Sounds
    - Fixed Bug With Quick Menu While Using Old School Design
    - Added 'Disable Fog' To Host Menu
 
</details>

<details>
	<summary>
		Version 1.0.8
	</summary>

	- Added: Aimbot Distance Check
    - Added: Player Mount Camera Option
    - Added: Ability To Add Pack 'a' Punched Weapons To Mystery Box
    - Added: Weapon Attachments
    - Added: DevGui Info(Host Only)
    - Added: Jumpscare (SOE & Origins)
    - Fixed: Bug with menu instructions not showing when a player is verified
 
</details>

<details>
	<summary>
		Version 1.0.6
	</summary>

	- Replaced Native Design With Right Side Design
    - Updated how the menu loads design variables to fit whatever design is loaded by default
 
</details>

<details>
	<summary>
		Version 1.0.5
	</summary>

	- Removed Der Eisendrache Bow Quests Until Crashes Can Be Worked Out

    - Added A Quick Menu
        - Quick Menu Features:
            - Unique Design
            - Infinite Scroll
            - Auto-Sizing Option Backgrounds
            - Bool/Slider Options
 
</details>

<details>
	<summary>
		Version 1.0.4
	</summary>

	- Added Old School Design
    - Added Option To Enable Large Cursor
    - Fixed Bug Not Being Able To Open 'Advanced Scripts'
    - Added Ability To Change Hitmarker Feedback Shader
    - Added Option To Force Animations On Zombies
    - Fixed Bug With Hitmarkers On Custom Maps/Mods That Has Hitmarkers Enabled
 
</details>

<details>
	<summary>
		Version 1.0.3
	</summary>

	- Spiral Staircase should now work for all maps
    - Added the option for someone to add a welcome message if wanted.

    - Origins Scripts
        - Complete Ice Tiles
        - Complete Ice Tombstones
        - Complete Wind Rings
        - Complete Wind Smoke Stones
        - Complete Fire Cauldrons
        - Complete Fire Torches
        - Complete Lightning Piano Song
        - Complete Lightning Dials
        - Rotate 115 Rings To Desired Color
 
</details>

<details>
	<summary>
		Version 1.0.1
	</summary>

    - Fixed Loading Crash On Custom Maps
    - Removed Type Writer, Rain, CYCL, and KRDR from Doheart styles
    - Added Fade Effect to Doheart Styles
    - Option Counter Is Disabled By Default
    - Fixed Bug With Spawning Models On Bigger Maps
    
</details>

<details>
	<summary>
		Version 1.0.0
	</summary>
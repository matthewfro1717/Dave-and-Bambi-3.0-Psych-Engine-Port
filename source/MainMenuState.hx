package;

#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.display.FlxBackdrop;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.ui.FlxButton;
#if MODS_ALLOWED
import sys.FileSystem;
import sys.io.File;
#end
import lime.app.Application;
import Achievements;
import editors.MasterEditorMenu;
import flixel.input.keyboard.FlxKey;

using StringTools;

class MainMenuState extends MusicBeatState
{
	public static var osEngineVesrion:String = '1.3.1'; //This is also used for Discord RPC (not anymore lol)
	public static var barrenEngineVesrion:String = '1.0.1 DEV BUILD'; //now this is used for rpc
	public static var curSelected:Int = 0;

	var menuItems:FlxTypedGroup<FlxSprite>;
	var menuIcon:FlxSprite;
	var menuIconTitle:FlxText;
	var menuIconDesc:FlxText;
	private var camGame:FlxCamera;
	private var camAchievement:FlxCamera;

	public static var bgPaths:Array<String> = //thats a lot of backgrounds
	[
		'backgrounds/SwagnotrllyTheMod',
		'backgrounds/morie',
		'backgrounds/mantis',
		'backgrounds/mamakotomi',
		'backgrounds/Aadsta',
		'backgrounds/ArtiztGmer',
		'backgrounds/DeltaKastel',
		'backgrounds/DeltaKastel2',
		'backgrounds/DeltaKastel3',
		'backgrounds/DeltaKastel4',
		'backgrounds/DeltaKastel5',
		'backgrounds/diamond man',
		'backgrounds/Jukebox',
		'backgrounds/kiazu',
		'backgrounds/Lancey',
		'backgrounds/mepperpint',
		'backgrounds/neon',
		'backgrounds/Onuko',
		'backgrounds/ps',
		'backgrounds/ramzgaming',
		'backgrounds/ricee_png',
		'backgrounds/sk0rbias',
		'backgrounds/zombought'
	];

	var menuDescs:Array<String> = [
		'Play the story mode to unlock new characters, and understand the story!', //story mode
		'Play any song as you wish and get new scores!', //freeplay
		'Look at the people who have worked for or contributed to the mod!', //credits
		'Listen to songs of the mod.', //ost
		'Adjust game settings and keybinds.', //settings
		'Join the official Anniversary Edition discord!', //discord
		'Connect your GameJolt account and more!' //extras
	];

	var menuTitles:Array<String> = [
		'Story Mode',
		'Freeplay',
		'Credits',
		'OST',
		'Settings',
		'Discord',
		'Extras'
	];

	var menuDescsALT:Array<String> = [
		'Play my song as I wish and fail.',
		'Adjust game settings and keybinds.',
	];

	var menuTitlesALT:Array<String> = [
		'MY Play',
		'Settings'
	];
	
	var optionShit:Array<String> = [
		'story_mode',
		'freeplay',
		//#if MODS_ALLOWED 'mods', #end
		//#if ACHIEVEMENTS_ALLOWED 'awards', #end //you can look at that on gamejolt im not coding that shit
		'credits',
		'ost',
		'options',
		'discord',
		'extras'
	];

	#if MODS_ALLOWED
	var customOption:String;
	var	customOptionLink:String;
	#end

	var magenta:FlxSprite;
	var camFollow:FlxObject;
	var camFollowPos:FlxObject;
	var debugKeys:Array<FlxKey>;

	var gamejoltButton:FlxButton;

	override function create()
	{
		WeekData.loadTheFirstEnabledMod();

		#if desktop
		// Updating Discord Rich Presence

		DiscordClient.changePresence("In the Menus", null);
		#end
		debugKeys = ClientPrefs.copyKey(ClientPrefs.keyBinds.get('debug_1'));

		camGame = new FlxCamera();
		camAchievement = new FlxCamera();
		camAchievement.bgColor.alpha = 0;

		FlxG.mouse.visible = true;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camAchievement);
		FlxCamera.defaultCameras = [camGame];
		camera.zoom = 1.85;
		CoolUtil.cameraZoom(camera, 1, .5, FlxEase.sineOut, ONESHOT);

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		persistentUpdate = persistentDraw = true;

		var yScroll:Float = Math.max(0.25 - (0.05 * (optionShit.length - 4)), 0.1);
        var bg:FlxSprite = new FlxSprite(-80).loadGraphic(randomizeBG());
		bg.color = 0x0066FF;
        bg.scrollFactor.set(0, yScroll);
        bg.setGraphicSize(Std.int(bg.width * 1.175));
        bg.updateHitbox();
        bg.screenCenter();
        bg.antialiasing = ClientPrefs.globalAntialiasing;
        add(bg);
		
		var checkeredBG:FlxBackdrop;
		checkeredBG = new FlxBackdrop(Paths.image('checkeredBG'), 0.2, 0, true, true);
		checkeredBG.velocity.set(50, -25);
		checkeredBG.updateHitbox();
		checkeredBG.alpha = 0.4;
		checkeredBG.screenCenter(X);
		checkeredBG.color = 0xFFFFFF;
		checkeredBG.antialiasing = ClientPrefs.globalAntialiasing;
		add(checkeredBG);

		/*
		var border:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('mainmenuBorder'));
        border.scrollFactor.set(0, 0);
        border.updateHitbox();
        border.screenCenter();
        border.antialiasing = ClientPrefs.globalAntialiasing;
        add(border);
		*/

		var selectBG:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('mainmenu/Select_Thing'));
        selectBG.scrollFactor.set(0, 0);
        selectBG.updateHitbox();
        selectBG.screenCenter();
        selectBG.antialiasing = ClientPrefs.globalAntialiasing;
        add(selectBG);

		menuIcon = new FlxSprite(-80).loadGraphic(Paths.image('mainmenu/menuicons/' + optionShit[curSelected].toLowerCase()));
        menuIcon.scrollFactor.set(0, 0);
		menuIcon.updateHitbox();
        menuIcon.screenCenter(X);
		menuIcon.y = FlxG.height/5 - 150;
        add(menuIcon);

		menuIconTitle = new FlxText((FlxG.width / 2) - 220, (FlxG.height / 2) + 30, 400, "", 50);
		menuIconTitle.scrollFactor.set();
		menuIconTitle.borderSize = 2;
		menuIconTitle.setFormat(Paths.font("comic.ttf"), 50, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(menuIconTitle);

		menuIconDesc = new FlxText((FlxG.width / 2) - 310, (FlxG.height / 2) - 60, 600, "", 25);
		menuIconDesc.scrollFactor.set();
		menuIconDesc.borderSize = 2;
		menuIconDesc.setFormat(Paths.font("comic.ttf"), 25, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(menuIconDesc);

        if(ClientPrefs.themedmainmenubg == true) {

            var themedBg:FlxSprite = new FlxSprite(-80).loadGraphic(randomizeBG());
            themedBg.scrollFactor.set(0, yScroll);
            themedBg.setGraphicSize(Std.int(bg.width));
            themedBg.updateHitbox();
            themedBg.screenCenter();
            themedBg.antialiasing = ClientPrefs.globalAntialiasing;
            add(themedBg);

            var hours:Int = Date.now().getHours();
            if(hours > 18) {
                themedBg.color = 0x545f8a; // 0x6939ff
            } else if(hours > 8) {
                themedBg.loadGraphic(randomizeBG());
            }
        }

        camFollow = new FlxObject(0, 0, 1, 1);
        camFollowPos = new FlxObject(0, 0, 1, 1);
        add(camFollow);
        add(camFollowPos);

        magenta = new FlxSprite(-80).loadGraphic('menuDesat');
        magenta.scrollFactor.set(0, yScroll);
        magenta.setGraphicSize(Std.int(magenta.width * 1.175));
        magenta.updateHitbox();
        magenta.screenCenter();
        magenta.visible = false;
        magenta.antialiasing = ClientPrefs.globalAntialiasing;
        magenta.color = 0xFFfd719b;
        add(magenta);
		
		// magenta.scrollFactor.set();

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		var scale:Float = 0.5;
		/*if(optionShit.length > 6) {
			scale = 6 / optionShit.length;
		}*/

		var curoffset:Float = 100;
		#if MODS_ALLOWED
		pushModMenuItemsToList(Paths.currentModDirectory);
		#end

		for (i in 0...optionShit.length)
		{
			var offset:Float = 108 - (Math.max(optionShit.length, 4) - 4) * 80;
			var menuItem:FlxSprite = new FlxSprite(curoffset, (i * 140) + offset);
			menuItem.scale.x = scale;
			menuItem.scale.y = scale;
			menuItem.frames = Paths.getSparrowAtlas('mainmenu/menubuttons/menu_' + optionShit[i]);
			menuItem.animation.addByPrefix('idle', optionShit[i] + " basic", 24);
			menuItem.animation.addByPrefix('selected', optionShit[i] + " white", 24);
			menuItem.animation.play('idle');
			menuItem.ID = i;
			/*if(menuItem.ID <= 3) {
				menuItem.x = 50*i+100;
				menuItem.y = 200*i+100;
			} 
			if(menuItem.ID >= 3) {
				menuItem.x = -50*(i-3)+800;
				menuItem.y = 200*(i-3)+100;
			}*/
			//menuItem.screenCenter(X);
			menuItem.x = 180*i+50;
			menuItem.y = FlxG.height - 210;
			menuItems.add(menuItem);
			var scr:Float = (optionShit.length - 4) * 0.135;
			//if(optionShit.length < 6) scr = 0;
			menuItem.scrollFactor.set(0, 0);
			menuItem.antialiasing = ClientPrefs.globalAntialiasing;
			//menuItem.setGraphicSize(Std.int(menuItem.width * 0.58));
			menuItem.updateHitbox();
			//curoffset = curoffset + 20;
		}
		/*
		if (FlxG.sound.music == null) {
			FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);
		}
		*/
		FlxG.camera.follow(camFollowPos, null, 1);

		var versionShit:FlxText = new FlxText(10, FlxG.height - 24, 0, "Barren Engine v" + barrenEngineVesrion, 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat(Paths.font("comic.ttf"), 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);
		/*var versionShit:FlxText = new FlxText(10, FlxG.height - 44, 0, "OS Engine v" + osEngineVesrion + " - Modded Psych Engine", 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat(Paths.font("comic.ttf"), 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);
		var versionShit:FlxText = new FlxText(10, FlxG.height - 24, 0, "Friday Night Funkin' v" + Application.current.meta.get('version'), 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat(Paths.font("comic.ttf"), 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);*/

		//gamejoltButton = new FlxTypedButton(0, 0, function()
		//{
		//	MusicBeatState.switchState(new gamejolt.GameJoltLogin());
		//});
		//gamejoltButton.loadGraphic('login', false, 500, 250, false);
		//add(gamejoltButton);

		// NG.core.calls.event.logEvent('swag').send();

		changeItem();

		#if ACHIEVEMENTS_ALLOWED
		Achievements.loadAchievements();
		var leDate = Date.now();
		if (leDate.getDay() == 5 && leDate.getHours() >= 18) {
			var achieveID:Int = Achievements.getAchievementIndex('friday_night_play');
			if(!Achievements.isAchievementUnlocked(Achievements.achievementsStuff[achieveID][2])) { //It's a friday night. WEEEEEEEEEEEEEEEEEE
				Achievements.achievementsMap.set(Achievements.achievementsStuff[achieveID][2], true);
				giveAchievement();
				ClientPrefs.saveSettings();
			}
		}
		#end

		super.create();
	}

	#if MODS_ALLOWED
	private var modsAdded:Array<String> = [];
	function pushModMenuItemsToList(folder:String)
	{
		if(modsAdded.contains(folder)) return;

		var menuitemsFile:String = null;
		if(folder != null && folder.trim().length > 0) menuitemsFile = Paths.mods(folder + '/data/menuitems.txt');
		else menuitemsFile = Paths.mods('data/menuitems.txt');

		if (FileSystem.exists(menuitemsFile))
		{
			var firstarray:Array<String> = File.getContent(menuitemsFile).split('\n');
			if (firstarray[0].length > 0) {
				var arr:Array<String> = firstarray[0].split('||');
				//if(arr.length == 1) arr.push(folder);
				optionShit.push(arr[0]);
				customOption = arr[0];
				customOptionLink = arr[1];
			}
		}
		modsAdded.push(folder);
	}
	#end


	#if ACHIEVEMENTS_ALLOWED
	// Unlocks "Freaky on a Friday Night" achievement
	function giveAchievement() {
		add(new AchievementObject('friday_night_play', camAchievement));
		FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);
		trace('Giving achievement "friday_night_play"');
	}
	#end

	var selectedSomethin:Bool = false;


	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		var lerpVal:Float = CoolUtil.boundTo(elapsed * 7.5, 0, 1);
		camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));

		menuIconTitle.text = menuTitles[curSelected];
		menuIconDesc.text = menuDescs[curSelected];

		if (!selectedSomethin)
		{
			/*if (controls.UI_UP_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(-1);
			}

			if (controls.UI_DOWN_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(1);
			}*/

			if (controls.UI_LEFT_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(-1);
			}

			if (controls.UI_RIGHT_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(1);
			}

			if (controls.BACK)
			{
				selectedSomethin = true;
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new GameExitState());
				CoolUtil.cameraZoom(camera, 3, 3, FlxEase.backOut, ONESHOT);
				//FlxG.sound.music.fadeOut();
			}

			if (controls.ACCEPT)
			{
				if (optionShit[curSelected] == 'donate') {
					CoolUtil.browserLoad('https://www.youtube.com/watch?v=dQw4w9WgXcQ'); // WHOEVER DELETES THIS IS GAY
				} else if (optionShit[curSelected] == 'discord') {
					CoolUtil.browserLoad('https://discord.gg/uhT9pJ5Xd8'); // cool discord server
				} else if (optionShit[curSelected] == customOption) {
					CoolUtil.browserLoad(customOptionLink);
				}
				else
				{
					selectedSomethin = true;
					FlxG.sound.play(Paths.sound('confirmMenu'));

					//if(ClientPrefs.flashing) FlxFlicker.flicker(magenta, 1.1, 0.15, false);

					menuItems.forEach(function(spr:FlxSprite)
					{
						if (curSelected != spr.ID)
						{
							/*
							FlxTween.tween(spr, {alpha: 0}, 0.4, {
								ease: FlxEase.quadOut,
								onComplete: function(twn:FlxTween)
								{
									spr.kill();
								}
							});
							*/
							//FlxTween.tween(spr, {y: 1000}, 2, {ease: FlxEase.backInOut, type: ONESHOT, onComplete: function(twn:FlxTween) {
							//	spr.kill();
							//}});
						}
						else
						{
							/*
							FlxTween.tween(spr, {x: 500}, 1, {ease: FlxEase.backInOut, type: ONESHOT, onComplete: function(tween: FlxTween) {	no more tweenings
								var daChoice:String = optionShit[curSelected];


								switch (daChoice)
								{
									case 'story_mode':
										MusicBeatState.switchState(new StoryMenuState());
									case 'freeplay':
										MusicBeatState.switchState(new FreeplayState());
									#if MODS_ALLOWED
									case 'mods':
										MusicBeatState.switchState(new ModsMenuState());
									#end			
									case 'awards':
										MusicBeatState.switchState(new AchievementsMenuState());
									case 'credits':
										MusicBeatState.switchState(new CreditsState());
									case 'options':
										LoadingState.loadAndSwitchState(new options.OptionsState());
								}
							}});
							*/
							FlxFlicker.flicker(spr, 1, 0.06, false, false, function(flick:FlxFlicker)

							{
								var daChoice:String = optionShit[curSelected];

								switch (daChoice)
								{
									case 'story_mode':
										MusicBeatState.switchState(new StoryMenuState());
										   	CoolUtil.cameraZoom(camera, 2, 1, FlxEase.backOut, ONESHOT);
									case 'freeplay':
										MusicBeatState.switchState(new FreeplaySelectState());
										   	CoolUtil.cameraZoom(camera, 2, 1, FlxEase.backOut, ONESHOT);
									#if MODS_ALLOWED
									case 'mods':
										MusicBeatState.switchState(new ModsMenuState()); 
										   	CoolUtil.cameraZoom(camera, 2, 1, FlxEase.backOut, ONESHOT);
									#end
									case 'awards':
										MusicBeatState.switchState(new AchievementsMenuState());
										   	CoolUtil.cameraZoom(camera, 2, 1, FlxEase.backOut, ONESHOT);
									case 'credits':
										MusicBeatState.switchState(new CreditsState());
										   	CoolUtil.cameraZoom(camera, 2, 1, FlxEase.backOut, ONESHOT);
									case 'options':
										LoadingState.loadAndSwitchState(new options.OptionsState());
										   	CoolUtil.cameraZoom(camera, 2, 1, FlxEase.backOut, ONESHOT);
									case 'extras':
										LoadingState.loadAndSwitchState(new ExtrasState());
										   	CoolUtil.cameraZoom(camera, 2, 1, FlxEase.backOut, ONESHOT);
								}
							});
						}
					});
				}
			}
			#if desktop
			else if (FlxG.keys.anyJustPressed(debugKeys))
			{
				selectedSomethin = true;
				MusicBeatState.switchState(new MasterEditorMenu());
			}
			#end
		}

		super.update(elapsed);

		menuItems.forEach(function(spr:FlxSprite)
		{
			//spr.screenCenter(X);
		});
	}

	function changeItem(huh:Int = 0)
	{
		curSelected += huh;

		if (curSelected >= menuItems.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = menuItems.length - 1;

		menuIcon.loadGraphic(Paths.image('mainmenu/menuicons/' + optionShit[curSelected].toLowerCase()));
		
		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.animation.play('idle');
			//spr.updateHitbox();
			spr.scale.x = 0.6;
			spr.scale.y = 0.6;

			if (spr.ID == curSelected)
			{
				spr.animation.play('selected');
				spr.scale.x = 0.6;
				spr.scale.y = 0.6;
				var add:Float = 0;
				if(menuItems.length > 4) {
					add = menuItems.length * 8;
				}
				//camFollow.setPosition(spr.getGraphicMidpoint().x, spr.getGraphicMidpoint().y - add);
				//spr.centerOffsets();
			}
		});
	}
	public static function randomizeBG():flixel.system.FlxAssets.FlxGraphicAsset
	{
		var chance:Int = FlxG.random.int(0, bgPaths.length - 1);
		return Paths.image(bgPaths[chance]);
	}
}

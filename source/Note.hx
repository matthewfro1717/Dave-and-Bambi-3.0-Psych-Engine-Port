package;

import flixel.math.FlxRandom;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
import flash.display.BitmapData;
import editors.ChartingState;
import PlayState;
import StrumNote;

using StringTools;

typedef EventNote = {
	strumTime:Float,
	event:String,
	value1:String,
	value2:String
}

class Note extends FlxSprite
{
	public var strumTime:Float = 0;

	public var mustPress:Bool = false;
	public var noteData:Int = 0;
	public var canBeHit:Bool = false;
	public var tooLate:Bool = false;
	public var wasGoodHit:Bool = false;
	public var ignoreNote:Bool = false;
	public var hitByOpponent:Bool = false;
	public var noteWasHit:Bool = false;
	public var prevNote:Note;
	public var LocalScrollSpeed:Float = 1;

	public var sustainLength:Float = 0;
	public var isSustainNote:Bool = false;
	public var noteType(default, set):String = null;

	public var eventName:String = '';
	public var eventLength:Int = 0;
	public var eventVal1:String = '';
	public var eventVal2:String = '';

	public var colorSwap:ColorSwap;
	public var inEditor:Bool = false;
	public var gfNote:Bool = false;
	private var earlyHitMult:Float = 0.5;

	public static var swagWidth:Float = 160 * 0.7;
	public static var PURP_NOTE:Int = 0;
	public static var GREEN_NOTE:Int = 2;
	public static var BLUE_NOTE:Int = 1;
	public static var RED_NOTE:Int = 3;

	// Lua shit
	public var noteSplashDisabled:Bool = false;
	public var noteSplashTexture:String = null;
	public var noteSplashHue:Float = 0;
	public var noteSplashSat:Float = 0;
	public var noteSplashBrt:Float = 0;

	public var offsetX:Float = 0;
	public var offsetY:Float = 0;
	public var offsetAngle:Float = 0;
	public var multAlpha:Float = 1;

	public var copyX:Bool = true;
	public var copyY:Bool = true;
	public var copyAngle:Bool = true;
	public var copyAlpha:Bool = true;

	public var hitHealth:Float = 0.023;
	public var missHealth:Float = 0.0475;
	public var rating:String = 'unknown';
	public var ratingMod:Float = 0; //9 = unknown, 0.25 = shit, 0.5 = bad, 0.75 = good, 1 = sick
	public var ratingDisabled:Bool = false;

	public var texture(default, set):String = null;

	public var noAnimation:Bool = false;
	public var hitCausesMiss:Bool = false;
	public var distance:Float = 2000; //plan on doing scroll directions soon -bb

	public var hitsoundDisabled:Bool = false;

	private var player:Int;

	//public static var cool3Dcharacters:Array<String> = ['dave-3d', 'bambi-3d', 'bambi-unfair', 'expunged', 'morrow', 'barren', 'lenzo']; //this is outdated

	private function set_texture(value:String):String {
		if(texture != value) {
			reloadNote('', 'notes', value);
		}
		texture = value;
		return value;
	}

	private function set_noteType(value:String):String {
		noteSplashTexture = PlayState.SONG.splashSkin;
		colorSwap.hue = ClientPrefs.arrowHSV[noteData % 4][0] / 360;
		colorSwap.saturation = ClientPrefs.arrowHSV[noteData % 4][1] / 100;
		colorSwap.brightness = ClientPrefs.arrowHSV[noteData % 4][2] / 100;

		if(noteData > -1 && noteType != value) {
			switch(value) {
				case 'Hurt Note':
					ignoreNote = mustPress;
					reloadNote('HURT');
					noteSplashTexture = 'HURTnoteSplashes';
					colorSwap.hue = 0;
					colorSwap.saturation = 0;
					colorSwap.brightness = 0;
					if(isSustainNote) {
						missHealth = 0.1;
					} else {
						missHealth = 0.3;
					}
					hitCausesMiss = true;
				case 'Drive Note':
					ignoreNote = mustPress;
					reloadNote('DRIVE');
					noteSplashTexture = 'HURTnoteSplashes';
					hitCausesMiss = true;
				case 'Dodge Phone Note' | 'Phone Note' | 'Phone Note Alt':
					reloadNote('PHONE');
				case 'No Animation':
					noAnimation = true;
				case 'GF Sing':
					gfNote = true;
			}
			noteType = value;
		}
		noteSplashHue = colorSwap.hue;
		noteSplashSat = colorSwap.saturation;
		noteSplashBrt = colorSwap.brightness;
		return value;
	}

	public function new(strumTime:Float, noteData:Int, ?prevNote:Note, ?sustainNote:Bool = false, ?inEditor:Bool = false)
	{
		super();

		if (!inEditor && ClientPrefs.getGameplaySetting('randomcharts', false)) {
			noteData = FlxG.random.int(0,3);
			if (sustainNote) {
				noteData = prevNote.noteData;
			}
		}

		if (prevNote == null)
			prevNote = this;

		if (PlayState.SONG.swapStrumLines == true) {
			if (player == 1) {
				player = 0;
			} else if (player == 0) {
				player = 1;
			}
		}

		this.prevNote = prevNote;
		isSustainNote = sustainNote;
		this.inEditor = inEditor;

		x += (ClientPrefs.middleScroll ? PlayState.STRUM_X_MIDDLESCROLL : PlayState.STRUM_X) + 50;
		// MAKE SURE ITS DEFINITELY OFF SCREEN?
		y -= 2000;
		this.strumTime = strumTime;
		if(!inEditor) this.strumTime += ClientPrefs.noteOffset;

		this.noteData = noteData;

		if(noteData > -1) {
			texture = '';
			colorSwap = new ColorSwap();
			shader = colorSwap.shader;

			x += swagWidth * (noteData % 4);
			if(!isSustainNote) { //Doing this 'if' check to fix the warnings on Senpai songs
				var animToPlay:String = '';
				switch (PlayState.SONG.song.toLowerCase())
				{
					case 'cheating':
						switch (noteData % 4)
						{
							case 3:
								animToPlay = 'purple';
							case 2:
								animToPlay = 'blue';
							case 1:
								animToPlay = 'green';
							case 0:
								animToPlay = 'red';
							flipY = (Math.round(Math.random()) == 0); //fuck you
							flipX = (Math.round(Math.random()) == 1);
						}
					default:
						switch (noteData % 4)
						{
							case 0:
								animToPlay = 'purple';
							case 1:
								animToPlay = 'blue';
							case 2:
								animToPlay = 'green';
							case 3:
								animToPlay = 'red';
						}
				}
				animation.play(animToPlay + 'Scroll');
			}
		}

		// trace(prevNote);

		if (isSustainNote && prevNote != null)
		{
			alpha = 0.6;
			multAlpha = 0.6;
			hitsoundDisabled = true;
			if(ClientPrefs.downScroll) flipY = true;

			offsetX += width / 2;
			copyAngle = false;

			switch (PlayState.SONG.song.toLowerCase())
			{
				case 'cheating':
					switch (noteData)
					{
						case 3:
							animation.play('purpleholdend');
						case 2:
							animation.play('blueholdend');
						case 1:
							animation.play('greenholdend');
						case 0:
							animation.play('redholdend');
					}
				default:
					switch (noteData)
					{
						case 0:
							animation.play('purpleholdend');
						case 1:
							animation.play('blueholdend');
						case 2:
							animation.play('greenholdend');
						case 3:
							animation.play('redholdend');
					}
			}
			

			updateHitbox();

			offsetX -= width / 2;

			if (PlayState.isPixelStage)
				offsetX += 30;

			if (prevNote.isSustainNote)
			{
				switch (PlayState.SONG.song.toLowerCase())
				{
					case 'cheating':
						switch (prevNote.noteData)
						{
							case 3:
								prevNote.animation.play('purplehold');
							case 2:
								prevNote.animation.play('bluehold');
							case 1:
								prevNote.animation.play('greenhold');
							case 0:
								prevNote.animation.play('redhold');
						}
					default:
						switch (prevNote.noteData)
						{
							case 0:
								prevNote.animation.play('purplehold');
							case 1:
								prevNote.animation.play('bluehold');
							case 2:
								prevNote.animation.play('greenhold');
							case 3:
								prevNote.animation.play('redhold');
						}
				}

				prevNote.scale.y *= Conductor.stepCrochet / 100 * 1.05;
				if(PlayState.instance != null)
				{
					prevNote.scale.y *= PlayState.instance.songSpeed;
				}

				if(PlayState.isPixelStage) {
					prevNote.scale.y *= 1.19;
					prevNote.scale.y *= (6 / height); //Auto adjust note size
				}
				prevNote.updateHitbox();
				// prevNote.setGraphicSize();
			}

			if(PlayState.isPixelStage) {
				scale.y *= PlayState.daPixelZoom;
				updateHitbox();
			}
		} else if(!isSustainNote) {
			earlyHitMult = 1;
		}
		x += offsetX;
	}

	var lastNoteOffsetXForPixelAutoAdjusting:Float = 0;
	var lastNoteScaleToo:Float = 1;
	public var originalHeightForCalcs:Float = 6;
	function reloadNote(prefix:String = '', ?folder:String, ?texture:String = '', ?suffix:String = '') {
		if(prefix == null) prefix = '';
		if(folder == null) folder = 'notes';
		if(texture == null) texture = '';
		if(suffix == null) suffix = '';
		
		var skin:String = texture;
		if(texture.length < 1) {
			skin = PlayState.SONG.arrowSkin;
			if(skin == null || skin.length < 1) {
				skin = 'NOTE_assets';
				switch (prefix) { //had to rework note skins because the drive note assets werent loading
					case 'HURT':
						skin = 'NOTE_assets';
					case 'DRIVE':
						skin = 'NOTE_assets';
					case 'PHONE':
						skin = 'NOTE_assets';
					default:
						if ((PlayState.floaterfloats.contains(PlayState.SONG.player1) || PlayState.floaterfloatsWHAR.contains(PlayState.SONG.player1)) && (PlayState.floaterfloats.contains(PlayState.SONG.player2) || PlayState.floaterfloatsWHAR.contains(PlayState.SONG.player2))) {
							skin = '3DNotes';
						} else if ((PlayState.floaterfloats.contains(PlayState.SONG.player2) || PlayState.floaterfloatsWHAR.contains(PlayState.SONG.player2)) || (PlayState.floaterfloats.contains(PlayState.SONG.player1) || PlayState.floaterfloatsWHAR.contains(PlayState.SONG.player1))) {
							var rng:FlxRandom = new FlxRandom();
							if (rng.int(0,1) == 1)
							{
								if(ClientPrefs.noteSkinSettings == 'Clasic') {
									skin = 'NOTE_assets';
								} else if (ClientPrefs.noteSkinSettings == 'Circle') {
									skin = 'NOTE_assets_circle';
								} else {
									skin = 'NOTE_assets';// for preventing crashes
								}
							}
							else
							{
								skin = '3DNotes';
							}
						} else {
							if(ClientPrefs.noteSkinSettings == 'Clasic') {
								skin = 'NOTE_assets';
							} else if (ClientPrefs.noteSkinSettings == 'Circle') {
								skin = 'NOTE_assets_circle';
							} else {
								skin = 'NOTE_assets';// for preventing crashes
							}
						}
				}
			}
		}

		var animName:String = null;
		if(animation.curAnim != null) {
			animName = animation.curAnim.name;
		}

		var arraySkin:Array<String> = skin.split('/');
		arraySkin[arraySkin.length-1] = folder + '/' + prefix + arraySkin[arraySkin.length-1] + suffix;

		var lastScaleY:Float = scale.y;
		var blahblah:String = arraySkin.join('/');
		if(PlayState.isPixelStage) {
			if(isSustainNote) {
				loadGraphic(Paths.image('pixelUI/' + blahblah + 'ENDS'));
				width = width / 4;
				height = height / 2;
				originalHeightForCalcs = height;
				loadGraphic(Paths.image('pixelUI/' + blahblah + 'ENDS'), true, Math.floor(width), Math.floor(height));
			} else {
				loadGraphic(Paths.image('pixelUI/' + blahblah));
				width = width / 4;
				height = height / 5;
				loadGraphic(Paths.image('pixelUI/' + blahblah), true, Math.floor(width), Math.floor(height));
			}
			setGraphicSize(Std.int(width * PlayState.daPixelZoom));
			loadPixelNoteAnims();
			antialiasing = false;

			if(isSustainNote) {
				offsetX += lastNoteOffsetXForPixelAutoAdjusting;
				lastNoteOffsetXForPixelAutoAdjusting = (width - 7) * (PlayState.daPixelZoom / 2);
				offsetX -= lastNoteOffsetXForPixelAutoAdjusting;
				
				/*if(animName != null && !animName.endsWith('end'))
				{
					lastScaleY /= lastNoteScaleToo;
					lastNoteScaleToo = (6 / height);
					lastScaleY *= lastNoteScaleToo; 
				}*/
			}
		} else {
			frames = Paths.getSparrowAtlas(blahblah);
			loadNoteAnims();
			antialiasing = ClientPrefs.globalAntialiasing;
		}
		if(isSustainNote) {
			scale.y = lastScaleY;
		}
		updateHitbox();

		if (PlayState.SONG.song.toLowerCase() == 'unfairness')
		{
			var rng:FlxRandom = new FlxRandom();
			if (rng.int(0,120) == 1)
			{
				LocalScrollSpeed = 0.1;
			}
			else
			{
				LocalScrollSpeed = rng.float(1,4);
			}
		}

		if (PlayState.SONG.song.toLowerCase() == 'exploitation')
		{
			var rng:FlxRandom = new FlxRandom();
			if (rng.int(0,120) == 1)
			{
				LocalScrollSpeed = 0.1;
			}
			else
			{
				LocalScrollSpeed = 3;
			}
		}

		if(animName != null)
			animation.play(animName, true);

		if(inEditor) {
			setGraphicSize(ChartingState.GRID_SIZE, ChartingState.GRID_SIZE);
			updateHitbox();
		}
	}

	function loadNoteAnims() {
		animation.addByPrefix('greenScroll', 'green0');
		animation.addByPrefix('redScroll', 'red0');
		animation.addByPrefix('blueScroll', 'blue0');
		animation.addByPrefix('purpleScroll', 'purple0');

		if (isSustainNote)
		{
			switch (this.noteStyle)
		        {
			   default:
				frames = Paths.getSparrowAtlas(notePathLol, 'shared');

				animation.addByPrefix('greenScroll', 'green0');
				animation.addByPrefix('redScroll', 'red0');
				animation.addByPrefix('blueScroll', 'blue0');
				animation.addByPrefix('purpleScroll', 'purple0');
				animation.addByPrefix('whiteScroll', 'white0');
				animation.addByPrefix('yellowScroll', 'yellow0');
				animation.addByPrefix('violetScroll', 'violet0');
				animation.addByPrefix('blackScroll', 'black0');
				animation.addByPrefix('darkScroll', 'dark0');
				animation.addByPrefix('pinkScroll', 'pink0');
				animation.addByPrefix('turqScroll', 'turq0');
				animation.addByPrefix('emeraldScroll', 'emerald0');
				animation.addByPrefix('lightredScroll', 'lightred0');


				animation.addByPrefix('purpleholdend', 'pruple end hold');
				animation.addByPrefix('greenholdend', 'green hold end');
				animation.addByPrefix('redholdend', 'red hold end');
				animation.addByPrefix('blueholdend', 'blue hold end');
				animation.addByPrefix('whiteholdend', 'white hold end');
				animation.addByPrefix('yellowholdend', 'yellow hold end');
				animation.addByPrefix('violetholdend', 'violet hold end');
				animation.addByPrefix('blackholdend', 'black hold end');
				animation.addByPrefix('darkholdend', 'dark hold end');
				animation.addByPrefix('pinkholdend', 'pink hold end');
				animation.addByPrefix('turqholdend', 'turq hold end');
				animation.addByPrefix('emeraldholdend', 'emerald hold end');
				animation.addByPrefix('lightredholdend', 'lightred hold end');

				animation.addByPrefix('purplehold', 'purple hold piece');
				animation.addByPrefix('greenhold', 'green hold piece');
				animation.addByPrefix('redhold', 'red hold piece');
				animation.addByPrefix('bluehold', 'blue hold piece');
				animation.addByPrefix('whitehold', 'white hold piece');
				animation.addByPrefix('yellowhold', 'yellow hold piece');
				animation.addByPrefix('violethold', 'violet hold piece');
				animation.addByPrefix('blackhold', 'black hold piece');
				animation.addByPrefix('darkhold', 'dark hold piece');
				animation.addByPrefix('pinkhold', 'pink hold piece');
				animation.addByPrefix('turqhold', 'turq hold piece');
				animation.addByPrefix('emeraldhold', 'emerald hold piece');
				animation.addByPrefix('lightredhold', 'lightred hold piece');
	
				setGraphicSize(Std.int(width * noteSize));
				updateHitbox();
				antialiasing = noteStyle != '3D';
			
			   case 'shape':
				frames = Paths.getSparrowAtlas(notePathLol, 'shared');

				animation.addByPrefix('greenScroll', 'green0');
				animation.addByPrefix('redScroll', 'red0');
				animation.addByPrefix('blueScroll', 'blue0');
				animation.addByPrefix('purpleScroll', 'purple0');
				animation.addByPrefix('yellowScroll', 'yellow0');
				animation.addByPrefix('darkScroll', 'dark0');


				animation.addByPrefix('purpleholdend', 'purple hold piece');
				animation.addByPrefix('greenholdend', 'green hold piece');
				animation.addByPrefix('redholdend', 'red hold piece');
				animation.addByPrefix('blueholdend', 'blue hold piece');
				animation.addByPrefix('yellowholdend', 'yellow hold piece');
				animation.addByPrefix('darkholdend', 'dark hold piece');

				animation.addByPrefix('purplehold', 'purple hold piece');
				animation.addByPrefix('greenhold', 'green hold piece');
				animation.addByPrefix('redhold', 'red hold piece');
				animation.addByPrefix('bluehold', 'blue hold piece');
				animation.addByPrefix('yellowhold', 'yellow hold piece');
				animation.addByPrefix('darkhold', 'dark hold piece');

				setGraphicSize(Std.int(width * noteSize));
				updateHitbox();
				antialiasing = false;

			   case 'text':
				frames = Paths.getSparrowAtlas('ui/alphabet');

				var noteColors = ['purple', 'blue', 'green', 'red', 'white', 'yellow', 'violet', 'black', 'dark'];
	
				var boldLetters:Array<String> = new Array<String>();
	
				for (frameName in frames.frames)
				{
					if (frameName.name.contains('bold'))
					{
						boldLetters.push(frameName.name);
					}
				}
				var randomFrame = boldLetters[new FlxRandom().int(0, boldLetters.length - 1)];
				var prefix = randomFrame.substr(0, randomFrame.length - 4);
				for (note in noteColors)
				{
					animation.addByPrefix('${note}Scroll', prefix, 24);
				}
				setGraphicSize(Std.int(width * 1.2 * (noteSize / 0.7)));
				updateHitbox();
				antialiasing = true;
				// noteOffset = -(width - 78 + (mania == 4 ? 30 : 0));

			   case 'guitarHero':
				frames = Paths.getSparrowAtlas('notes/NOTEGH_assets', 'shared');

				animation.addByPrefix('greenScroll', 'A Note');
				animation.addByPrefix('greenhold', 'A Hold Piece');
				animation.addByPrefix('greenholdend', 'A Hold End');


				animation.addByPrefix('redScroll', 'B Note');
				animation.addByPrefix('redhold', 'B Hold Piece');
				animation.addByPrefix('redholdend', 'B Hold End');

				animation.addByPrefix('yellowScroll', 'C Note');
				animation.addByPrefix('yellowhold', 'C Hold Piece');
				animation.addByPrefix('yellowholdend', 'C Hold End');

				animation.addByPrefix('blueScroll', 'D Note');
				animation.addByPrefix('bluehold', 'D Hold Piece');
				animation.addByPrefix('blueholdend', 'D Hold End');

				animation.addByPrefix('orangeScroll', 'E Note');
				animation.addByPrefix('orangehold', 'E Hold Piece');
				animation.addByPrefix('orangeholdend', 'E Hold End');

				setGraphicSize(Std.int(width * 0.7));
				updateHitbox();
				antialiasing = true;
			   case 'phone' | 'phone-alt':
				if (!isSustainNote)
				{
					frames = Paths.getSparrowAtlas('notes/NOTE_phone', 'shared');
				}
				else
				{
					frames = Paths.getSparrowAtlas('notes/NOTE_assets', 'shared');
				}
				animation.addByPrefix('greenScroll', 'green0');
				animation.addByPrefix('redScroll', 'red0');
				animation.addByPrefix('blueScroll', 'blue0');
				animation.addByPrefix('purpleScroll', 'purple0');
				animation.addByPrefix('whiteScroll', 'white0');
				animation.addByPrefix('yellowScroll', 'yellow0');
				animation.addByPrefix('violetScroll', 'violet0');
				animation.addByPrefix('blackScroll', 'black0');
				animation.addByPrefix('darkScroll', 'dark0');


				animation.addByPrefix('purpleholdend', 'pruple end hold');
				animation.addByPrefix('greenholdend', 'green hold end');
				animation.addByPrefix('redholdend', 'red hold end');
				animation.addByPrefix('blueholdend', 'blue hold end');
				animation.addByPrefix('whiteholdend', 'white hold end');
				animation.addByPrefix('yellowholdend', 'yellow hold end');
				animation.addByPrefix('violetholdend', 'violet hold end');
				animation.addByPrefix('blackholdend', 'black hold end');
				animation.addByPrefix('darkholdend', 'dark hold end');

				animation.addByPrefix('purplehold', 'purple hold piece');
				animation.addByPrefix('greenhold', 'green hold piece');
				animation.addByPrefix('redhold', 'red hold piece');
				animation.addByPrefix('bluehold', 'blue hold piece');
				animation.addByPrefix('whitehold', 'white hold piece');
				animation.addByPrefix('yellowhold', 'yellow hold piece');
				animation.addByPrefix('violethold', 'violet hold piece');
				animation.addByPrefix('blackhold', 'black hold piece');
				animation.addByPrefix('darkhold', 'dark hold piece');

				LocalScrollSpeed = 1.08;
				
				setGraphicSize(Std.int(width * noteSize));
				updateHitbox();
				antialiasing = true;
				
				// noteOffset = 20;

		}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (mustPress)
		{
			// ok river
			if (strumTime > Conductor.songPosition - Conductor.safeZoneOffset
				&& strumTime < Conductor.songPosition + (Conductor.safeZoneOffset * earlyHitMult))
				canBeHit = true;
			else
				canBeHit = false;

			if (strumTime < Conductor.songPosition - Conductor.safeZoneOffset && !wasGoodHit)
				tooLate = true;
		}
		else
		{
			canBeHit = false;

			if (strumTime < Conductor.songPosition + (Conductor.safeZoneOffset * earlyHitMult))
			{
				if((isSustainNote && prevNote.wasGoodHit) || strumTime <= Conductor.songPosition)
					wasGoodHit = true;
			}
		}

		if (tooLate && !inEditor)
		{
			if (alpha > 0.3)
				alpha = 0.3;
		}
	}
}

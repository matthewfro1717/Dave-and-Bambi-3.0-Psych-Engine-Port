package;

import flixel.addons.display.FlxBackdrop;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.util.FlxColor;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;


class FreeplaySelectState extends MusicBeatState 
{
    public static var freeplayCats:Array<String> = ['Story', 'Joke', 'Extras', 'Insanity'];
    public static var freeplayCatsHidden:Array<String> = ['Terminal', 'uh oh'];
    public static var curCategory:Int = 0;
    public var NameAlpha:Alphabet;
    var grpCats:FlxTypedGroup<Alphabet>;
    var curSelected:Int = 0;
    var BG:FlxSprite;
    var categoryIcon:FlxSprite;
    //var categoryIconsGroup:FlxTypedGroup<FlxSprite>; THIS SHIT IS  SO COMPLICATED FOR NO REASON AUGHHHHHHHHHHHHHHHHHHH

    var songColors:Array<FlxColor> = [ //unused as of rn
		0xFF4965FF, // davee
		0xFF35C2FF, // bf
		0xFF2CD12C, // bamber
        0xFFF12B2B, // expunded
        0xFF9F9F9F, // morrowowow
        0xFFC300FF, // gambii
        0xFF3045FF // bamlin+banlin (NO NOT SHIPPING)
    ];

    override function create()
    {
        CoolUtil.cameraZoom(camera, 1, .5, FlxEase.sineOut, ONESHOT);

        BG = new FlxSprite().loadGraphic(MainMenuState.randomizeBG());
        BG.updateHitbox();
        BG.screenCenter();
        //BG.color = 0x55D650;
        add(BG);

        var gridthing:FlxBackdrop;

		gridthing = new FlxBackdrop(Paths.image('checkeredBG'), 0.2, 0, true, true);
		gridthing.velocity.set(50, -25);
		gridthing.updateHitbox();
		gridthing.alpha = 0.4;
		gridthing.screenCenter(X);
		gridthing.color = 0xFFFFFF;
		gridthing.antialiasing = ClientPrefs.globalAntialiasing;
		add(gridthing);

        categoryIcon = new FlxSprite().loadGraphic(Paths.image('packs/' + freeplayCats[curSelected].toLowerCase()));
        categoryIcon.updateHitbox();
        categoryIcon.screenCenter();
        add(categoryIcon);
        
        /*categoryIconsGroup = new FlxTypedGroup<FlxSprite>();
        add(categoryIconsGroup);
        for (i in 0...freeplayCats.length) {
            categoryIcon = new FlxSprite().loadGraphic(Paths.image('weekicons/week_icon_' + freeplayCats[i].toLowerCase()));
            categoryIcon.x = i;
            categoryIconsGroup.add(categoryIcon);
        }*/

        /*grpCats = new FlxTypedGroup<Alphabet>();
        add(grpCats);
        for (i in 0...freeplayCats.length)
        {
            var catsText:Alphabet = new Alphabet(0, (70 * i) + 30, freeplayCats[i], true, false);
            catsText.targetY = i;
            catsText.isMenuItem = true;
            grpCats.add(catsText);
        }*/

        NameAlpha = new Alphabet(10,(FlxG.height / 2) - 282,freeplayCats[curSelected],true,false);
        NameAlpha.screenCenter(X);
        Highscore.load();

        add(NameAlpha);

        changeSelection();

        super.create();
    }

    override public function update(elapsed:Float){
        if (controls.UI_LEFT_P)
            changeSelection(-1);
        if (controls.UI_RIGHT_P)
            changeSelection(1);

        if (controls.BACK) {
            FlxG.sound.play(Paths.sound('cancelMenu'));
            MusicBeatState.switchState(new MainMenuState());
            CoolUtil.cameraZoom(camera, 3, 3, FlxEase.backOut, ONESHOT);
        }

        if (controls.ACCEPT){
            MusicBeatState.switchState(new FreeplayState());
            CoolUtil.cameraZoom(camera, 2, 1, FlxEase.backOut, ONESHOT);
        }

        curCategory = curSelected;

        super.update(elapsed);
    }

    function changeSelection(change:Int = 0) {
        curSelected += change;

        if (curSelected < 0)
            curSelected = freeplayCats.length - 1;
        if (curSelected >= freeplayCats.length)
            curSelected = 0;

        //var bullShit:Int = 0;
        /*
        for (item in categoryIconsGroup.members) {
            item.x = bullShit - curSelected;
            bullShit++;
            item.alpha = 1;
            item.screenCenter();
            if (item.ID == Std.int(0) && unlocked)
				item.alpha = 1;
			else
				item.alpha = 0.6;
        }
        */
        NameAlpha.destroy();
        NameAlpha = new Alphabet(10,(FlxG.height / 2) - 282,freeplayCats[curSelected],true,false);
        NameAlpha.screenCenter(X);
        add(NameAlpha);
        categoryIcon.loadGraphic(Paths.image('packs/' + (freeplayCats[curSelected].toLowerCase())));
        FlxG.sound.play(Paths.sound('scrollMenu'));

        FlxTween.color(BG, 0.25, BG.color, songColors[curSelected]);
    }
}
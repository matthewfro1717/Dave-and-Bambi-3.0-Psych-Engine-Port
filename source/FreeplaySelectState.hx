package;

import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.tweens.FlxEase;

//THIS WAS INTENDED FOR PSYCH SO BECAUSE OF THAT ITS BROKEN FOR THE TIME BEING (nvm)
class FreeplaySelectState extends MusicBeatState 
{
    public static var freeplayCats:Array<String> = ['Dave', 'Base', 'Extra', 'Joke', 'Insanity']; 
    public static var curCategory:Int = 0;
    public var NameAlpha:Alphabet;
    var grpCats:FlxTypedGroup<Alphabet>;
    var curSelected:Int = 0;
    var BG:FlxSprite;
    var categoryIcon:FlxSprite;

    override function create()
    {
        CoolUtil.cameraZoom(camera, 1, .5, FlxEase.sineOut, ONESHOT);

        BG = new FlxSprite().loadGraphic(Paths.image('backgrounds/morie'));
        BG.updateHitbox();
        BG.screenCenter();
        BG.color = 0x55D650;
        add(BG);

        categoryIcon = new FlxSprite().loadGraphic(Paths.image('weekicons/week_icon_' + freeplayCats[curSelected].toLowerCase()));
        categoryIcon.updateHitbox();
        categoryIcon.screenCenter();
        add(categoryIcon);

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

        var bullShit:Int = 0;

        /*for (item in grpCats.members) {
            item.targetY = bullShit - curSelected;
            bullShit++;
            item.alpha = 0.6;
            if (item.targetY == 0) {
                item.alpha = 1;
            }
        }*/

        NameAlpha.destroy();
        NameAlpha = new Alphabet(10,(FlxG.height / 2) - 282,freeplayCats[curSelected],true,false);
        NameAlpha.screenCenter(X);
        add(NameAlpha);
        categoryIcon.loadGraphic(Paths.image('weekicons/week_icon_' + (freeplayCats[curSelected].toLowerCase())));
        FlxG.sound.play(Paths.sound('scrollMenu'));
    }
}
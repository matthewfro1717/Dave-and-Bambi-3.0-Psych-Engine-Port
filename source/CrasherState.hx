import flash.system.System;
import flixel.*;
import flixel.FlxState;

class CrasherState extends FlxState // how is this useful? i dont know
{
    override public function create()
    {
        super.create();
        System.exit(0);
    }
}
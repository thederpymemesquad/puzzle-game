package level.objects;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.math.FlxRect;
import openfl.display.BitmapData;

class BasicPlayer extends FlxSprite {
    public var isPullingObject = false;

    public function new(x:Int, y:Int) {
        super(x * 16, y * 16);
    }

    private function clamp(min, max, value):Float {
        return Math.max(Math.min(value, max), min);
    }

    public override function update(elapsed:Float) {
        super.update(elapsed);
    }

    public function isTouchingObject(object:FlxSprite, dist:Float = 16.1):Bool {
        var xDif = Math.max(object.x, this.x) - Math.min(object.x, this.x);
        var yDif = Math.max(object.y, this.y) - Math.min(object.y, this.y);

        // trace("diff x: " + xDif + ", y: " + yDif);
        return (xDif <= dist && yDif <= dist);
    }
}

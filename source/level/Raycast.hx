package level;

import flixel.FlxObject;
import flixel.math.FlxPoint;
import flixel.math.FlxVector;
import flixel.tile.FlxBaseTilemap;

class RaycastResult extends PointResult {
    public var distance:Float;

    public function new(hitPos:FlxPoint, tilePos:FlxPoint, tile:Int, collides:Bool, distance:Float) {
        super(hitPos, tilePos, tile, collides);
        this.distance = distance;
    }
}

class PointResult {
    public var hitPos:FlxPoint;
    public var tilePos:FlxPoint;
    public var tile:Int;
    public var collides:Bool;

    public function new(hitPos:FlxPoint, tilePos:FlxPoint, tile:Int, collides:Bool) {
        this.hitPos = hitPos;
        this.tilePos = tilePos;
        this.tile = tile;
    }

    // public inline function isSolid(tile:attributes):Bool {
    // return
    // }
}

class Raycast {
    public static var STEP:Float = 0.1;

    public final startPoint:FlxPoint;
    public var currentPoint:FlxPoint;
    public final initialVector:FlxVector;
    public var currentVector:FlxVector;
    public var minLength:Float;
    public var maxLength:Float;

    private var tilemap:FlxBaseTilemap<FlxObject>;

    public function new(start:FlxPoint, direction:FlxVector, minLength:Float, maxLength:Float, tilemap:FlxBaseTilemap<FlxObject>) {
        this.startPoint = start;
        this.currentPoint = start;
        direction.normalize().scale(Raycast.STEP);
        this.initialVector = direction;
        this.currentVector = direction;
        this.minLength = minLength;
        this.maxLength = maxLength;
        this.tilemap = tilemap;
    }

    public function startCast() {
        while (true) {
            var pointCheck = this.check();

            this.move();
        }
    }

    private function move() {
        this.currentPoint.addPoint(this.currentVector);
    }

    private function check():PointResult {
        var tileIndex = this.tilemap.getTileIndexByCoords(this.currentPoint);
        var collides = !(this.tilemap.getTileCollisions(this.tilemap.getTileByIndex(tileIndex)) == 0);
        return new PointResult(this.currentPoint, this.tilemap.getTileCoordsByIndex(tileIndex), this.tilemap.getTileByIndex(tileIndex), collides);
    }
}

class ReflectiveRaycast extends Raycast {}

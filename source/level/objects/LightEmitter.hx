package level.objects;

import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.effects.FlxTrail;
import flixel.addons.weapon.FlxBullet;
import flixel.addons.weapon.FlxWeapon.FlxTypedWeapon;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxPoint;
import flixel.ui.FlxButton.FlxTypedButton;
import flixel.util.helpers.FlxBounds;
import level.LevelLoader.LevelDataObjectClass;
import openfl.display.BitmapData;

class LightParticle extends FlxBullet {
    public var trail:FlxTrail;
    public var emitter:LightEmitter;
    public var bounces:Int = 5;

    public function new(emitter:LightEmitter) {
        super();
        this.emitter = emitter;
        this.bounces = this.emitter.maxLightBounces;
        trail = new FlxTrail(this, new BitmapData(2, 2, true, 0xFFFF0000), 50, 0, 1, 0.02);
        emitter.trails.add(trail);
    }

    public override function revive() {
        super.revive();
        this.bounces = this.emitter.maxLightBounces;
        this.trail.revive();
        this.trail.resetTrail();
        trace("revived");
    }

    public function bounce() {
        this.bounces -= 1;
        if (this.bounces < 0) {
            this.kill();
            this.trail.kill();
        }
    }

    public override function update(elapsed:Float) {
        super.update(elapsed);

        if (this.velocity.x == 0 && this.velocity.y == 0) {
            this.kill();
            this.trail.kill();
            // this.emitter.trails.remove(this.trail);
        }
    }
}

class LightEmitter extends BasicObject {
    public var lightGun:FlxTypedWeapon<LightParticle>;
    public var trails:FlxTypedGroup<FlxTrail>;
    public var maxLightBounces:Int = 5;

    public var enabled:Bool = true;

    public function new(x:Float, y:Float, width:Int, height:Int, properties:LevelDataObjectClass) {
        super(x, y, width, height, properties);
        this.trails = new FlxTypedGroup<FlxTrail>();
        this.lightGun = new FlxTypedWeapon<LightParticle>("lightgun", (weapon) -> {
            var b = new LightParticle(this);
            b.makeGraphic(2, 2);
            return b;
        },
            PARENT(this, new FlxBounds<FlxPoint>(FlxPoint.get(7.5, -2), FlxPoint.get(7.5, -2))), SPEED(new FlxBounds<Float>(100, 100)));
        this.lightGun.bulletElasticity = 1;

        this.loadGraphic(AssetHelper.getImageAsset(NamespacedKey.fromString("puzzlegame:images/light-emitter")), false);
    }

    public override function update(elapsed:Float) {
        super.update(elapsed);

        if (FlxG.keys.anyJustPressed([Q]) && this.enabled) {
            trace(this.lightGun.fireFromAngle(new FlxBounds<Float>(-90, -90)));
        }
    }
}

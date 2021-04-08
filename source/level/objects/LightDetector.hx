package level.objects;

import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.weapon.FlxBullet;
import flixel.addons.weapon.FlxWeapon.FlxTypedWeapon;
import flixel.math.FlxPoint;
import flixel.ui.FlxButton.FlxTypedButton;
import flixel.util.helpers.FlxBounds;
import level.LevelLoader.LevelDataObjectClass;
import level.objects.LightEmitter.LightParticle;

class LightDetector extends BasicObject {
    public function new(x:Float, y:Float, width:Int, height:Int, properties:LevelDataObjectClass) {
        super(x, y, width, height, properties);

        this.loadGraphic(AssetHelper.getImageAsset(NamespacedKey.fromString("puzzlegame:images/light-emitter")), false);
    }

    public override function update(elapsed:Float) {
        super.update(elapsed);
    }

    public function lighthit(particle:LightParticle) {
        particle.emitter.enabled = false;
        particle.kill();
        particle.trail.kill();
        this.kill();
    }
}

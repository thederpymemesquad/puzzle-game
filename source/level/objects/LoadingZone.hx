package level.objects;

import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.util.typeLimit.OneOfTwo;
import openfl.display.BitmapData;

class LoadingZone extends FlxSprite {
    public final loadTarget:NamespacedKey;

    public var spawnpoint:String;
    public var loadWidth:Int;
    public var loadHeight:Int;

    public function new(x:Int, y:Int, width:Int, height:Int, levelToLoad:OneOfTwo<NamespacedKey, String>, sprite:OneOfTwo<NamespacedKey, String>,
            ?spawnpoint:Null<String>) {
        super(x * 16, y * 16);

        this.loadWidth = width;
        this.loadHeight = height;

        if (Std.isOfType(levelToLoad, String)) {
            if (Std.string(levelToLoad) == "%menu")
                levelToLoad = NamespacedKey.ofDefaultNamespace("%menu")
            else if (Std.string(levelToLoad) == "%null")
                levelToLoad = NamespacedKey.ofDefaultNamespace("%null")
            else
                levelToLoad = NamespacedKey.fromString(levelToLoad);
        }
        this.loadTarget = levelToLoad;
        this.spawnpoint = spawnpoint;

        this.loadGraphic(LoadingZone.getSpriteBitmap(sprite, width, height), false, width * 16, height * 16);
    }

    public static function getSpriteBitmap(data:OneOfTwo<NamespacedKey, String>, width:Null<Int>, height:Null<Int>) {
        if (Std.isOfType(data, String)) {
            var str:String = cast data;
            if (StringTools.startsWith(str, "%color")) {
                // trace("creating static bitmap");
                if (width == null)
                    width = 1;
                if (height == null)
                    height = 1;
                return new BitmapData(width * 16, height * 16, true, Std.parseInt(str.split(":")[1]));
                // return new BitmapData(width * 16, height * 16, true, 0xAAFFFFAA);
            }
            else {
                // trace("getting bitmap from asset string");
                return AssetHelper.getImageAsset(NamespacedKey.fromString(str));
            }
        }
        else {
            // trace("getting bitmap from key");
            return AssetHelper.getImageAsset(data);
        }
    }
}

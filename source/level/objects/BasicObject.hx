package level.objects;

import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.util.typeLimit.OneOfTwo;
import level.LevelLoader.LevelDataObjectClass;
import level.LevelLoader.LevelDataObjectPositionClass;
import openfl.display.BitmapData;

class BasicObject extends FlxSprite
{
	public var properties:LevelDataObjectClass;
	public var isBeingPulled:Bool = false;

	public function new(x:Float, y:Float, width:Int, height:Int, properties:LevelDataObjectClass)
	{
		super(x * 16, y * 16);

		this.properties = properties;

		this.drag.x = this.properties.drag.x;
		this.drag.y = this.properties.drag.y;

		this.acceleration.x = this.properties.acceleration.x;
		this.acceleration.y = this.properties.acceleration.y;
		// this.maxVelocity.x = this.properties.maxVelocity.x;
		// this.maxVelocity.y = this.properties.maxVelocity.y;

		this.immovable = properties.lock.x && properties.lock.y;

		var asset = LoadingZone.getSpriteBitmap(this.properties.sprite, width, height);
		if (asset != null)
			this.loadGraphic(asset, false, width * 16, height * 16);
	}

	public override function update(elapsed:Float)
	{
		// if (this.properties.scripts.tick != null) {

		// }

		if (this.isBeingPulled)
		{
			this.drag.x = 0;
			this.drag.y = 0;
		}
		else
		{
			this.drag.x = this.properties.drag.x;
			this.drag.y = this.properties.drag.y;
		}

		super.update(elapsed);
	}

	public static function getSpriteBitmap(data:OneOfTwo<NamespacedKey, String>, width:Null<Int>, height:Null<Int>)
	{
		if (Std.isOfType(data, String))
		{
			var str:String = cast data;
			if (str == "%emitter")
			{
				return null;
			}
			else if (str == "%detector")
			{
				return null;
			}
			else if (StringTools.startsWith(str, "%color"))
			{
				// trace("creating static bitmap");
				if (width == null)
					width = 1;
				if (height == null)
					height = 1;
				return new BitmapData(width * 16, height * 16, true, Std.parseInt(str.split(":")[1]));
				// return new BitmapData(width * 16, height * 16, true, 0xAAFFFFAA);
			}
			else
			{
				// trace("getting bitmap from asset string");
				return AssetHelper.getImageAsset(NamespacedKey.fromString(str));
			}
		}
		else
		{
			// trace("getting bitmap from key");
			return AssetHelper.getImageAsset(data);
		}
	}
}

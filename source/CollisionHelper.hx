package;

import flixel.FlxObject;
import flixel.tile.FlxBaseTilemap;

class CollisionHelper {
	/**
	 * The main collision resolution function in Flixel.
	 *
	 * @param   Object1   Any `FlxObject`.
	 * @param   Object2   Any other `FlxObject`.
	 * @return  Whether the objects in fact touched and were separated.
	 */
	public static function separate(Object1:FlxObject, Object2:FlxObject, ?Immovable1:Null<Bool> = null, ?Immovable2:Null<Bool> = null):Bool {
		var separatedX:Bool = separateX(Object1, Object2, Immovable1, Immovable2);
		var separatedY:Bool = separateY(Object1, Object2, Immovable1, Immovable2);
		return separatedX || separatedY;
	}

	/**
	 * The X-axis component of the object separation process.
	 *
	 * @param   Object1   Any `FlxObject`.
	 * @param   Object2   Any other `FlxObject`.
	 * @return  Whether the objects in fact touched and were separated along the X axis.
	 */
	@:access(flixel.FlxObject)
	public static function separateX(Object1:FlxObject, Object2:FlxObject, ?Immovable1:Null<Bool> = null, ?Immovable2:Null<Bool> = null):Bool {
		// can't separate two immovable objects

		var obj1immovable:Bool = Immovable1 || Object1.immovable;
		var obj2immovable:Bool = Immovable2 || Object2.immovable;
		if (obj1immovable && obj2immovable) {
			return false;
		}

		// If one of the objects is a tilemap, just pass it off.
		if (Object1.flixelType == TILEMAP) {
			var tilemap:FlxBaseTilemap<Dynamic> = cast Object1;
			return tilemap.overlapsWithCallback(Object2, FlxObject.separateX);
		}
		if (Object2.flixelType == TILEMAP) {
			var tilemap:FlxBaseTilemap<Dynamic> = cast Object2;
			return tilemap.overlapsWithCallback(Object1, FlxObject.separateX, true);
		}

		var overlap:Float = FlxObject.computeOverlapX(Object1, Object2);
		// Then adjust their positions and velocities accordingly (if there was any overlap)
		if (overlap != 0) {
			var obj1v:Float = Object1.velocity.x;
			var obj2v:Float = Object2.velocity.x;

			if (!obj1immovable && !obj2immovable) {
				overlap *= 0.5;
				Object1.x = Object1.x - overlap;
				Object2.x += overlap;

				var obj1velocity:Float = Math.sqrt((obj2v * obj2v * Object2.mass) / Object1.mass) * ((obj2v > 0) ? 1 : -1);
				var obj2velocity:Float = Math.sqrt((obj1v * obj1v * Object1.mass) / Object2.mass) * ((obj1v > 0) ? 1 : -1);
				var average:Float = (obj1velocity + obj2velocity) * 0.5;
				obj1velocity -= average;
				obj2velocity -= average;
				Object1.velocity.x = average + obj1velocity * Object1.elasticity;
				Object2.velocity.x = average + obj2velocity * Object2.elasticity;
			}
			else if (!obj1immovable) {
				Object1.x = Object1.x - overlap;
				Object1.velocity.x = obj2v - obj1v * Object1.elasticity;
			}
			else if (!obj2immovable) {
				Object2.x += overlap;
				Object2.velocity.x = obj1v - obj2v * Object2.elasticity;
			}
			return true;
		}

		return false;
	}

	/**
	 * The Y-axis component of the object separation process.
	 *
	 * @param   Object1   Any `FlxObject`.
	 * @param   Object2   Any other `FlxObject`.
	 * @return  Whether the objects in fact touched and were separated along the Y axis.
	 */
	@:access(flixel.FlxObject)
	public static function separateY(Object1:FlxObject, Object2:FlxObject, ?Immovable1:Null<Bool> = null, ?Immovable2:Null<Bool> = null):Bool {
		// can't separate two immovable objects
		var obj1immovable:Bool = Immovable1 || Object1.immovable;
		var obj2immovable:Bool = Immovable2 || Object2.immovable;
		if (obj1immovable && obj2immovable) {
			return false;
		}

		// If one of the objects is a tilemap, just pass it off.
		if (Object1.flixelType == TILEMAP) {
			var tilemap:FlxBaseTilemap<Dynamic> = cast Object1;
			return tilemap.overlapsWithCallback(Object2, FlxObject.separateY);
		}
		if (Object2.flixelType == TILEMAP) {
			var tilemap:FlxBaseTilemap<Dynamic> = cast Object2;
			return tilemap.overlapsWithCallback(Object1, FlxObject.separateY, true);
		}

		var overlap:Float = FlxObject.computeOverlapY(Object1, Object2);
		// Then adjust their positions and velocities accordingly (if there was any overlap)
		if (overlap != 0) {
			var obj1delta:Float = Object1.y - Object1.last.y;
			var obj2delta:Float = Object2.y - Object2.last.y;
			var obj1v:Float = Object1.velocity.y;
			var obj2v:Float = Object2.velocity.y;

			if (!obj1immovable && !obj2immovable) {
				overlap *= 0.5;
				Object1.y = Object1.y - overlap;
				Object2.y += overlap;

				var obj1velocity:Float = Math.sqrt((obj2v * obj2v * Object2.mass) / Object1.mass) * ((obj2v > 0) ? 1 : -1);
				var obj2velocity:Float = Math.sqrt((obj1v * obj1v * Object1.mass) / Object2.mass) * ((obj1v > 0) ? 1 : -1);
				var average:Float = (obj1velocity + obj2velocity) * 0.5;
				obj1velocity -= average;
				obj2velocity -= average;
				Object1.velocity.y = average + obj1velocity * Object1.elasticity;
				Object2.velocity.y = average + obj2velocity * Object2.elasticity;
			}
			else if (!obj1immovable) {
				Object1.y = Object1.y - overlap;
				Object1.velocity.y = obj2v - obj1v * Object1.elasticity;
				// This is special case code that handles cases like horizontal moving platforms you can ride
				if (Object1.collisonXDrag && Object2.active && Object2.moves && (obj1delta > obj2delta)) {
					Object1.x += Object2.x - Object2.last.x;
				}
			}
			else if (!obj2immovable) {
				Object2.y += overlap;
				Object2.velocity.y = obj1v - obj2v * Object2.elasticity;
				// This is special case code that handles cases like horizontal moving platforms you can ride
				if (Object2.collisonXDrag && Object1.active && Object1.moves && (obj1delta < obj2delta)) {
					Object2.x += Object1.x - Object1.last.x;
				}
			}
			return true;
		}

		return false;
	}
}

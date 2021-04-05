package level.objects;

import flixel.FlxG;
import flixel.FlxObject;
import openfl.display.BitmapData;

class PlatformerPlayer extends BasicPlayer
{
	public function new(x:Int, y:Int)
	{
		super(x, y);

		// this.setSize(14, 15);
		// this.offset.set(1, 1);

		loadGraphic(new BitmapData(14, 15, true, 0xAAFF00FF));

		this.drag.x = 300;
		this.acceleration.y = 200;
	}

	public function canJump():Bool
	{
		return this.isTouching(FlxObject.FLOOR);
	}

	public var maxManualSpeed = 100;
	public var defaultXDrag = 300;

	public override function update(elapsed:Float)
	{
		var u = FlxG.keys.anyPressed([W, UP]) && !this.isTouching(FlxObject.CEILING);
		var d = FlxG.keys.anyPressed([S, DOWN]) && !this.isTouching(FlxObject.FLOOR);
		var l = FlxG.keys.anyPressed([A, LEFT]) && !this.isTouching(FlxObject.LEFT);
		var r = FlxG.keys.anyPressed([D, RIGHT]) && !this.isTouching(FlxObject.RIGHT);
		var special1 = FlxG.keys.anyPressed([Q]);

		if (l || r)
		{
			if (l && r)
				l = r = false;

			if (l || r)
			{
				if (l && Math.abs(this.velocity.x) < this.maxManualSpeed)
					this.acceleration.x = this.drag.x * -1;
				else if (r && Math.abs(this.velocity.x) < this.maxManualSpeed)
					this.acceleration.x = this.drag.x;
				else
				{
					this.acceleration.x = 0;
					this.drag.x = 0;
				}
			}
			else
			{
				this.acceleration.x = 0;
				this.drag.x = this.defaultXDrag;
			}
		}
		else
		{
			this.acceleration.x = 0;
			this.drag.x = this.defaultXDrag;
		}

		if (u && canJump())
		{
			this.velocity.y = -125;
		}

		if (d && !this.isTouching(FlxObject.FLOOR))
		{
			this.velocity.y += 10;
		}

		super.update(elapsed);
	}
}

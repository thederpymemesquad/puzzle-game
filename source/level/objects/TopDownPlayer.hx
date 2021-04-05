package level.objects;

import flixel.FlxG;
import flixel.FlxObject;
import openfl.display.BitmapData;

class TopDownPlayer extends BasicPlayer
{
	public function new(x:Int, y:Int)
	{
		super(x, y);

		this.drag.x = 300;
		this.drag.y = 300;
		this.maxVelocity.x = 100;
		this.maxVelocity.y = 100;

		loadGraphic(new BitmapData(15, 15, true, 0xAAFF00FF));
		// this.setSize(14, 14);
		// this.offset.set(1, 1);
	}

	public override function update(elapsed:Float)
	{
		if (this.isPullingObject)
		{
			this.maxVelocity.x = 50;
			this.maxVelocity.y = 50;
		}
		else
		{
			this.maxVelocity.x = 100;
			this.maxVelocity.y = 100;
		}
		var u = FlxG.keys.anyPressed([W, UP]);
		var d = FlxG.keys.anyPressed([S, DOWN]);
		var l = FlxG.keys.anyPressed([A, LEFT]);
		var r = FlxG.keys.anyPressed([D, RIGHT]);

		if (u && d)
			u = d = false;
		if (l && r)
			l = r = false;

		// this.acceleration.x = 0;
		// this.acceleration.y = 0;

		if (u)
			this.acceleration.y = this.drag.y * -1;
		else if (d)
			this.acceleration.y = this.drag.y;
		else
			this.acceleration.y = 0;

		if (l)
			this.acceleration.x = this.drag.x * -1;
		else if (r)
			this.acceleration.x = this.drag.x;
		else
			this.acceleration.x = 0;

		super.update(elapsed);
	}
}

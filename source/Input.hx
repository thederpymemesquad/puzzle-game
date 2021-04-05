package;

import flixel.FlxG;
import flixel.input.keyboard.FlxKey;

class Input {
	public static final defaultInputKeys:Map<String, Array<String>> = [
		"up" => ["w", "up"], "down" => ["s", "down"], "left" => ["a", "left"], "right" => ["d", "right"], "interact_1" => ["q"], "interact_2" => ["e"],
		"interact_3" => ["f"], "reset" => ["r"], "hideui" => ["f1"], "flxdebug_editor" => ["f2"], "flxdebug_play" => ["f2", "graveaccent"],
		"debugscreen" => ["f3"], "toggleeditor" => ["f4"], "reload" => ["f5"],
	];

	public static function isHoldingAction(action:String):Bool {
		return defaultInputKeys.exists(action) ? isHoldingAnyOf(defaultInputKeys.get(action)) : false;
	}

	public static function isHoldingAnyOf(keys:Array<String>) {
		for (key in keys) {
			if (FlxG.keys.checkStatus(FlxKey.fromString(key), PRESSED)) {
				return true;
			}
		}
		return false;
	}

	/*
		a man a plan a canal panama
		amanaplanacanalpanama
	 */
	public static function loadInputSettings():Void {}
}

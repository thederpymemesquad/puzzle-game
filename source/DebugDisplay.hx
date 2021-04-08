package;

import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import lime.system.System as LimeSys;
import mac.Version;
import openfl.system.Capabilities as FlCap;
import openfl.system.System as FlSys;

class DebugDisplay extends FlxBasic {
    public var leftText:FlxText;
    public var leftPrepend:String = "";
    public var leftAppend:String = "";

    public var rightText:FlxText;
    public var rightPrepend:String = "";
    public var rightAppend:String = "";

    public var maxMemory:Float = 0;

    public function new() {
        super();

        this.leftText = new FlxText(10, 10, 0, "debug-left", 20);

        this.rightText = new FlxText(10, 10, FlxG.width - 20, "debug-right", 20);
        this.rightText.alignment = RIGHT;
    }

    public override function destroy() {
        this.leftText.destroy();
        this.rightText.destroy();
        super.destroy();
    }

    public override function update(elapsed:Float) {
        var mem = Math.round(FlSys.totalMemory / 1024 / 1024 * 100) / 100;
        if (mem > maxMemory)
            maxMemory = mem;
        if (this.visible) {
            this.leftText.text = this.leftPrepend;
            if (this.leftPrepend != "" && !StringTools.endsWith(this.leftText.text, "\n"))
                this.leftText.text += "\n";

            this.leftText.text += 'FPS: ${Main.fpsCounter.currentFPS}\n' + this.leftAppend;

            this.rightText.text = this.rightPrepend;
            if (this.rightPrepend != "" && !StringTools.endsWith(this.rightText.text, "\n"))
                this.rightText.text += "\n";

            this.rightText.text += 'Haxe: ${haxe.macro.Compiler.getDefine("haxe")}\nFlixel: ${FlxG.VERSION.toString()}\n';
            this.rightText.text += 'Build: ${Version.getBuildNumber()}\nMemory: ${mem}MB / ${maxMemory}MB\n';
            this.rightText.text += 'System: ${LimeSys.platformName} (${FlCap.cpuArchitecture})\n\n';
            // this.rightText.text += 'Platform: ${LimeSys.platformName} (${LimeSys.platformVersion})\n\n';
            // this.rightText.text += 'CPU: \n';

            this.rightText.text += this.rightAppend;
        }
    }

    public override function draw():Void {
        if (this.visible) {
            this.leftText.draw();
            this.rightText.draw();
            super.draw();
        }
    }

    @:noCompletion
    override function set_camera(Value:FlxCamera):FlxCamera {
        this.leftText.cameras = [Value];
        this.rightText.cameras = [Value];

        return super.set_camera(Value);
    }

    @:noCompletion
    override function set_cameras(Value:Array<FlxCamera>):Array<FlxCamera> {
        this.leftText.cameras = Value;
        this.rightText.cameras = Value;

        return super.set_cameras(Value);
    }
}

package;

// import editor.EditorState;
import flixel.FlxG;
import flixel.FlxGame;
import lime.app.Application;
import openfl.Lib;
import openfl.display.FPS;
import openfl.display.Sprite;
import states.PlayState;
import states.TitleState;

class Main extends Sprite {
    public static var fpsCounter:FPS;

    public function new() {
        super();

        // addChild(new FlxGame(1920, 1080, EditorState, 1, 144, 144, true, false));
        // addChild(new FlxGame(1920, 1080, PlayState, 1, 144, 144, true, false));
        addChild(new FlxGame(1920, 1080, TitleState, 1, 144, 144, true, false));

        Main.fpsCounter = new FPS(10, 10, 0xFFFFFF);
        addChild(Main.fpsCounter);
        Main.fpsCounter.alpha = 0;

        Application.current.window.title = 'hi buddy';
    }
}

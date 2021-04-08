package states;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.ui.FlxButtonPlus;
import flixel.input.FlxSwipe;
import flixel.math.FlxMath;
import flixel.tweens.FlxTween;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import lime.graphics.Image;
import openfl.display.BitmapData;
import states.substates.LevelSelectSubstate;
import states.substates.OptionsSubstate;
import sys.FileSystem;

class TitleState extends FlxState {
    public var shiftedSubstates:Int = 0;
    public var shiftingCamera:FlxCamera;

    private var lastShiftedTo:Int = 0;
    private var lastShiftedFrom:Int = 0;
    private var shiftedTweenStarted:Bool = false;
    private var shiftedTweenEnded:Bool = false;
    private var returnTweenStarted:Bool = false;
    private var returnTweenEnded:Bool = false;

    private var baseGameLevelList = AssetHelper.getTextAsset(NamespacedKey.ofDefaultNamespace("levels/level_list"));

    public var levelSelectButton:FlxButton;

    override public function create() {
        super.create();

        FlxG.mouse.useSystemCursor = true;
        FlxG.log.redirectTraces = true;

        this.persistentUpdate = true;
        this.persistentDraw = true;

        this.shiftingCamera = new FlxCamera(0, 0, FlxG.width, FlxG.height, 1);
        FlxG.cameras.add(this.shiftingCamera);

        var text = new flixel.text.FlxText(0, FlxG.height * 0.1, 0, "pozzle game", 64);
        text.screenCenter(X);
        add(text);

        levelSelectButton = new FlxButton(0, FlxG.height * 0.5, "Level Select >", () -> {
            if (this.shiftedSubstates == 0
                && (!this.shiftedTweenStarted || (this.shiftedTweenStarted && this.shiftedTweenEnded))
                && (!this.returnTweenStarted || (this.returnTweenStarted && this.returnTweenEnded)))
                this.openSubState(new LevelSelectSubstate(baseGameLevelList));
        });

        levelSelectButton.setGraphicSize(300);
        levelSelectButton.updateHitbox();
        levelSelectButton.label.setGraphicSize(300);
        levelSelectButton.label.updateHitbox();

        levelSelectButton.screenCenter(X);

        add(levelSelectButton);

        #if desktop
        var modMenuButton = new FlxButton(0, FlxG.height * 0.6, "Mods >", () -> {
            if (this.shiftedSubstates == 0
                && (!this.shiftedTweenStarted || (this.shiftedTweenStarted && this.shiftedTweenEnded))
                && (!this.returnTweenStarted || (this.returnTweenStarted && this.returnTweenEnded)))
                return;
            // this.openSubState(new ModMenuSubstate());
        });

        modMenuButton.setGraphicSize(300);
        modMenuButton.updateHitbox();
        modMenuButton.label.setGraphicSize(300);
        modMenuButton.label.updateHitbox();

        modMenuButton.screenCenter(X);

        add(modMenuButton);
        #end

        #if desktop
        var optionButtonPosition = 0.7;
        #else
        var optionsButtonPosition = 0.65;
        #end

        var optionsButton = new FlxButton(0, FlxG.height * optionButtonPosition, "Options >", () -> {
            if (this.shiftedSubstates == 0
                && (!this.shiftedTweenStarted || (this.shiftedTweenStarted && this.shiftedTweenEnded))
                && (!this.returnTweenStarted || (this.returnTweenStarted && this.returnTweenEnded)))
                this.openSubState(new OptionsSubstate());
        });

        optionsButton.setGraphicSize(300);
        optionsButton.updateHitbox();
        optionsButton.label.setGraphicSize(300);
        optionsButton.label.updateHitbox();

        optionsButton.screenCenter(X);

        add(optionsButton);

        text.cameras = [this.shiftingCamera];
        levelSelectButton.cameras = [this.shiftingCamera];
        #if desktop
        modMenuButton.cameras = [this.shiftingCamera];
        #end
        optionsButton.cameras = [this.shiftingCamera];
    }

    override public function tryUpdate(elapsed:Float) {
        update(elapsed);

        if (_requestSubStateReset) {
            _requestSubStateReset = false;
            resetSubState();
        }

        if (subState == null) {}
        else {
            subState.tryUpdate(elapsed);
        }
    }

    override public function update(elapsed:Float) {
        super.update(elapsed);

        if (lastShiftedFrom != shiftedSubstates) {
            trace(lastShiftedFrom + " -> " + shiftedSubstates);
            lastShiftedFrom = shiftedSubstates;
            shiftedTweenStarted = false;
            shiftedTweenEnded = false;
        }

        if (this.shiftedSubstates > 0) {
            this.returnTweenStarted = false;
            this.returnTweenEnded = false;

            if (!shiftedTweenStarted && lastShiftedTo != this.shiftedSubstates) {
                this.shiftedTweenStarted = false;
                this.shiftedTweenEnded = false;
                this.lastShiftedTo = this.shiftedSubstates;
                // trace("re-shifting");
            }

            if (!this.shiftedTweenStarted) {
                // trace({zoom: this.shiftingCamera.zoom, alpha: this.shiftingCamera.alpha, x: this.shiftingCamera.x});
                FlxTween.tween(this.shiftingCamera, {
                    x: FlxG.width * (-0.3 * (0.5 * (this.shiftedSubstates + 1))),
                    alpha: 0.6 - (this.shiftedSubstates * 0.1),
                    zoom: 0.8 - (this.shiftedSubstates * 0.1),
                }, 0.2, {
                    onComplete: (_) -> {
                        this.shiftedTweenEnded = true;
                        // trace("ended title state tween");
                        // trace({zoom: this.shiftingCamera.zoom, alpha: this.shiftingCamera.alpha, x: this.shiftingCamera.x});
                    },
                    onStart: (_) -> {
                        this.shiftedTweenStarted = true;
                        // trace("started title state tween");
                    },
                    onUpdate: (_) -> {
                        // trace({zoom: this.shiftingCamera.zoom, alpha: this.shiftingCamera.alpha, x: this.shiftingCamera.x});
                    },
                });
            }
        }
        else {
            this.shiftedTweenStarted = false;
            this.shiftedTweenEnded = false;
            this.lastShiftedTo = 0;
            if (!this.returnTweenStarted) {
                FlxTween.tween(this.shiftingCamera, {
                    x: 0,
                    alpha: 1,
                    zoom: 1,
                }, 0.2, {
                    onComplete: (_) -> {
                        this.returnTweenEnded = true;
                        // trace("ended title state return");
                        // trace({zoom: this.shiftingCamera.zoom, alpha: this.shiftingCamera.alpha, x: this.shiftingCamera.x});
                    },
                    onStart: (_) -> {
                        this.returnTweenStarted = true;
                        // trace("started title state return");
                    },
                    onUpdate: (_) -> {
                        // trace({zoom: this.shiftingCamera.zoom, alpha: this.shiftingCamera.alpha, x: this.shiftingCamera.x});
                    },
                });
            }
        }
    }
}

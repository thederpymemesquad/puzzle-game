package states.substates;

import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSubState;
import flixel.group.FlxGroup;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;

class ShiftingMenuSubstate extends FlxSubState {
    public var shiftedSubstates:Int = 0;
    public var shiftingCamera:FlxCamera;

    private var lastShiftedTo:Int = 0;
    private var lastShiftedFrom:Int = 0;
    private var shiftedTweenStarted:Bool = false;
    private var shiftedTweenEnded:Bool = false;
    private var returnTweenStarted:Bool = false;
    private var returnTweenEnded:Bool = false;

    private function addc(obj:FlxBasic) {
        add(obj);
        obj.cameras = [this.shiftingCamera];
    }

    override public function create() {
        super.create();

        this.persistentUpdate = true;

        var testParentState = _parentState;

        while (true) {
            // trace(testParentState);
            if (Std.isOfType(testParentState, ShiftingMenuSubstate)) {
                var subState:ShiftingMenuSubstate = cast testParentState;
                subState.shiftedSubstates += 1;
                // trace(subState.shiftedSubstates);
            }
            else if (Std.isOfType(testParentState, TitleState)) {
                var titleState:TitleState = cast testParentState;
                titleState.shiftedSubstates += 1;
                // trace("breaking out of loop (title state)");
                // trace(titleState.shiftedSubstates);
                break;
            }

            if (Std.isOfType(testParentState, FlxSubState)) {
                var s:FlxSubState = cast testParentState;
                testParentState = s._parentState;
            }
            else {
                // trace("breaking out of loop (not sub state)");
                break;
            }
        }

        this.shiftingCamera = new FlxCamera();
        this.shiftingCamera.bgColor.alpha = 0;
        FlxG.cameras.add(this.shiftingCamera);
        this.shiftingCamera.alpha = 0;
        FlxTween.tween(this.shiftingCamera, {alpha: 1}, 0.2);
    }

    override function destroy() {
        trace("destorying shifting state");
        /*try
            {
                FlxG.cameras.remove(this.shiftingCamera);
                this.shiftingCamera.destroy();
            }
            catch (_)
            {
                // dont do anything if it fails
        }*/

        var testParentState = _parentState;

        while (true) {
            // trace(testParentState);
            if (Std.isOfType(testParentState, ShiftingMenuSubstate)) {
                var subState:ShiftingMenuSubstate = cast testParentState;
                subState.shiftedSubstates -= 1;
                // trace(subState.shiftedSubstates);
            }
            else if (Std.isOfType(testParentState, TitleState)) {
                var titleState:TitleState = cast testParentState;
                titleState.shiftedSubstates -= 1;
                // trace("breaking out of loop (title state)");
                // trace(titleState.shiftedSubstates);
                break;
            }

            if (Std.isOfType(testParentState, FlxSubState)) {
                var s:FlxSubState = cast testParentState;
                testParentState = s._parentState;
            }
            else {
                // trace("breaking out of loop (not sub state)");
                break;
            }
        }

        super.destroy();
        trace("finished destroying shifting state");
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
                    },
                    onStart: (_) -> {
                        this.returnTweenStarted = true;
                    }
                });
            }
        }
    }
}

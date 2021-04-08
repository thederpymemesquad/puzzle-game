package states.substates;

import flixel.FlxG;
import flixel.ui.FlxButton;

class PauseMenuSubstate extends ShiftingMenuSubstate {
    override public function create() {
        super.create();

        var text = new flixel.text.FlxText(0, FlxG.height * 0.1, 0, "Paused", 64);
        text.screenCenter(X);
        add(text);

        var menuButton = new FlxButton(0, FlxG.height * 0.5, "Main Menu", () -> {
            if (this.shiftedSubstates == 0
                && (!this.shiftedTweenStarted || (this.shiftedTweenStarted && this.shiftedTweenEnded))
                && (!this.returnTweenStarted || (this.returnTweenStarted && this.returnTweenEnded)))
                FlxG.switchState(new TitleState());
        });

        menuButton.setGraphicSize(300);
        menuButton.updateHitbox();
        menuButton.label.setGraphicSize(300);
        menuButton.label.updateHitbox();

        menuButton.screenCenter(X);
        add(menuButton);

        var optionsButton = new FlxButton(0, FlxG.height * 0.6, "Options >", () -> {
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

        var resumeButton = new FlxButton(0, FlxG.height * 0.8, "back to game", () -> {
            if (this.shiftedSubstates == 0
                && (!this.shiftedTweenStarted || (this.shiftedTweenStarted && this.shiftedTweenEnded))
                && (!this.returnTweenStarted || (this.returnTweenStarted && this.returnTweenEnded)))
                if (Std.isOfType(_parentState, PlayState)) {
                    {
                        var c:PlayState = cast _parentState;
                        c.isPaused = false;
                    }
                    this.close();
                }
        });
        resumeButton.setGraphicSize(300);
        resumeButton.updateHitbox();
        resumeButton.label.setGraphicSize(300);
        resumeButton.label.updateHitbox();
        resumeButton.screenCenter(X);
        add(resumeButton);
        text.cameras = [this.shiftingCamera];
        menuButton.cameras = [this.shiftingCamera];
        optionsButton.cameras = [this.shiftingCamera];
        resumeButton.cameras = [this.shiftingCamera];
    }
}

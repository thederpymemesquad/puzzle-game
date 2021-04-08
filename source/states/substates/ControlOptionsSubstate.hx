package states.substates;

import flixel.FlxG;
import flixel.ui.FlxButton;

class ControlOptionsSubstate extends ShiftingMenuSubstate {
    override public function create() {
        super.create();

        var text = new flixel.text.FlxText(0, FlxG.height * 0.1, 0, "Controls (wip)", 64);
        text.screenCenter(X);
        add(text);

        var levelSelectButton = new FlxButton(0, FlxG.height * 0.5, "coming soon lol", () -> {
            if (this.shiftedSubstates == 0
                && (!this.shiftedTweenStarted || (this.shiftedTweenStarted && this.shiftedTweenEnded))
                && (!this.returnTweenStarted || (this.returnTweenStarted && this.returnTweenEnded)))
                return;
        });

        levelSelectButton.setGraphicSize(300);
        levelSelectButton.updateHitbox();
        levelSelectButton.label.setGraphicSize(300);
        levelSelectButton.label.updateHitbox();

        levelSelectButton.screenCenter(X);
        add(levelSelectButton);

        var backButton = new FlxButton(0, FlxG.height * 0.6, "back", () -> {
            if (this.shiftedSubstates == 0
                && (!this.shiftedTweenStarted || (this.shiftedTweenStarted && this.shiftedTweenEnded))
                && (!this.returnTweenStarted || (this.returnTweenStarted && this.returnTweenEnded)))
                this.close();
        });

        backButton.setGraphicSize(300);
        backButton.updateHitbox();
        backButton.label.setGraphicSize(300);
        backButton.label.updateHitbox();

        backButton.screenCenter(X);
        add(backButton);

        text.cameras = [this.shiftingCamera];
        levelSelectButton.cameras = [this.shiftingCamera];
        backButton.cameras = [this.shiftingCamera];
    }
}

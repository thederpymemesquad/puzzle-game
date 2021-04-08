package states.substates;

import flixel.FlxG;
import flixel.text.FlxText;
import flixel.ui.FlxButton;

class LevelSelectSubstate extends ShiftingMenuSubstate {
    public var levelList:Array<String>;

    public function new(levelListAsset:Array<String>) {
        super();
        this.levelList = levelListAsset;
    }

    override public function create() {
        super.create();

        var text = new FlxText(0, FlxG.height * 0.1, 0, "Level Select", 64);
        text.screenCenter(X);
        addc(text);

        var test_text = new FlxText(0, 0, 0, levelList.join(" | "));
        test_text.screenCenter(XY);
        addc(test_text);

        var i = 0.4;
        for (level in this.levelList) {
            if (level.length > 0) {
                i += 0.1;
                var levelSelectButton = new FlxButton(0, FlxG.height * i, level, () -> {
                    if (this.shiftedSubstates == 0
                        && (!this.shiftedTweenStarted || (this.shiftedTweenStarted && this.shiftedTweenEnded))
                        && (!this.returnTweenStarted || (this.returnTweenStarted && this.returnTweenEnded))) {
                        trace("switching to playstate");
                        FlxG.switchState(new PlayState(NamespacedKey.fromString(level.substr(0, level.length - 1))));
                        trace("switched to playstate");
                    }
                });

                levelSelectButton.setGraphicSize(300);
                levelSelectButton.updateHitbox();
                levelSelectButton.label.setGraphicSize(300);
                levelSelectButton.label.updateHitbox();

                levelSelectButton.screenCenter(X);
                addc(levelSelectButton);
            }
        }

        var backButton = new FlxButton(0, FlxG.height * 0.4, "back", () -> {
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
        addc(backButton);
    }
}

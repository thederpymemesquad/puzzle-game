package states.substates;

import flixel.FlxG;
import flixel.ui.FlxButton;

class OptionsSubstate extends ShiftingMenuSubstate
{
	override public function create()
	{
		super.create();

		var text = new flixel.text.FlxText(0, FlxG.height * 0.1, 0, "Options", 64);
		text.screenCenter(X);
		add(text);

		var audioButton = new FlxButton(0, FlxG.height * 0.5, "Audio >", () ->
		{
			if (this.shiftedSubstates == 0
				&& (!this.shiftedTweenStarted || (this.shiftedTweenStarted && this.shiftedTweenEnded))
				&& (!this.returnTweenStarted || (this.returnTweenStarted && this.returnTweenEnded)))
				this.openSubState(new AudioOptionsSubstate());
		});

		audioButton.setGraphicSize(300);
		audioButton.updateHitbox();
		audioButton.label.setGraphicSize(300);
		audioButton.label.updateHitbox();

		audioButton.screenCenter(X);
		add(audioButton);

		var controlsButton = new FlxButton(0, FlxG.height * 0.6, "Controls >", () ->
		{
			if (this.shiftedSubstates == 0
				&& (!this.shiftedTweenStarted || (this.shiftedTweenStarted && this.shiftedTweenEnded))
				&& (!this.returnTweenStarted || (this.returnTweenStarted && this.returnTweenEnded)))
				this.openSubState(new ControlOptionsSubstate());
		});

		controlsButton.setGraphicSize(300);
		controlsButton.updateHitbox();
		controlsButton.label.setGraphicSize(300);
		controlsButton.label.updateHitbox();

		controlsButton.screenCenter(X);
		add(controlsButton);

		var backButton = new FlxButton(0, FlxG.height * 0.8, "back", () ->
		{
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
		audioButton.cameras = [this.shiftingCamera];
		controlsButton.cameras = [this.shiftingCamera];
		backButton.cameras = [this.shiftingCamera];
	}
}

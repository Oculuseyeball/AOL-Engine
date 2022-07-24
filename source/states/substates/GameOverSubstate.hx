package states.substates;

import engine.io.Modding;
import flixel.FlxSprite;
import engine.functions.Conductor;
import engine.io.Paths;
import states.gameplay.PlayState;
import game.characters.Boyfriend;
import engine.base.MusicBeatSubstate;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSubState;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

class GameOverSubstate extends MusicBeatSubstate
{
	var bf:FlxSprite;
	var bf2:FlxSprite;
	var camFollow:FlxObject;

	var stageSuffix:String = "";

	public function new(x:Float, y:Float)
	{
		if (engine.functions.Option.recieveValue("GRAPHICS_globalAA") == 0)
		{
			FlxG.camera.antialiasing = true;
		}
		else
		{
			FlxG.camera.antialiasing = false;
		}

		super();

		Conductor.songPosition = 0;

		bf2 = new FlxSprite(x, y);
		bf2.frames = Modding.getSparrow("BFDED2");
		bf2.animation.addByPrefix("idle", "CBF dead 2 instance 1", 24, true, false);
		bf2.visible = false;
		bf2.animation.play("idle");
		add(bf2);

		bf = new FlxSprite(x, y);
		bf.frames = Modding.getSparrow("BFDED1");
		bf.animation.addByPrefix("idle", "CBF dead 1 instance 1", 24, false, false);
		bf.animation.finishCallback = (name:String) -> {
			FlxG.camera.fade(0xFFFFFFFF, 4, false, () -> {
				FlxG.camera.fade(0xFFFFFFFF, true, true);
				bf.visible = false;
				bf2.visible = true;
				bf2.animation.play("idle");
			}, true);
		};
		bf.animation.play("idle");
		add(bf);

		camFollow = new FlxObject(bf.getGraphicMidpoint().x, bf.getGraphicMidpoint().y, 1, 1);
		add(camFollow);

		FlxG.sound.play(Paths.sound('fnf_loss_sfx' + stageSuffix));
		Conductor.changeBPM(100);

		// FlxG.camera.followLerp = 1;
		// FlxG.camera.focusOn(FlxPoint.get(FlxG.width / 2, FlxG.height / 2));
		FlxG.camera.scroll.set();
		FlxG.camera.target = null;
	}

	var sinDingus = 0.0;

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		bf2.y = Math.sin(sinDingus) * 20;
		sinDingus += 0.1;

		if (controls.ACCEPT)
		{
			endBullshit();
		}

		if (controls.BACK)
		{
			FlxG.sound.music.stop();

			if (PlayState.isStoryMode)
				FlxG.switchState(new states.menu.StoryMenuState());
			else
				FlxG.switchState(new states.menu.FreeplayState());
		}

		if (bf.animation.curAnim.name == 'idle' && bf.animation.curAnim.curFrame == 12)
		{
			FlxG.camera.follow(camFollow, LOCKON, 0.01);
		}

		if (bf.animation.curAnim.name == 'idle' && bf.animation.curAnim.finished)
		{
			FlxG.sound.playMusic(Paths.music('gameOver' + stageSuffix));
		}

		if (FlxG.sound.music.playing)
		{
			Conductor.songPosition = FlxG.sound.music.time;
		}
	}

	override function beatHit()
	{
		super.beatHit();

		FlxG.log.add('beat');
	}

	var isEnding:Bool = false;

	function endBullshit():Void
	{
		if (!isEnding)
		{
			isEnding = true;
			FlxG.sound.music.stop();
			FlxG.sound.play(Paths.music('gameOverEnd' + stageSuffix));
			new FlxTimer().start(0.7, function(tmr:FlxTimer)
			{
				FlxG.camera.fade(FlxColor.BLACK, 2, false, function()
				{
					PlayState.startFrom = 0;
					states.menu.LoadingState.loadAndSwitchState(new PlayState());
				});
			});
		}
	}
}

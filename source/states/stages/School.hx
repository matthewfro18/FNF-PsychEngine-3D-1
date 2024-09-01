package states.stages;

import states.stages.objects.*;
import substates.GameOverSubstate;
import cutscenes.DialogueBox;
import objects.Character3D;

import openfl.utils.Assets as OpenFlAssets;

class School extends BaseStage
{
	var view:ModelView;

	private var dad:Character3D;
	private var gf:Character3D;
	private var boyfriend:Boyfriend3D;

	public var boyfriendGroup:FlxSpriteGroup;
	public var dadGroup:FlxSpriteGroup;
	public var gfGroup:FlxSpriteGroup;

	override function create()
	{
		var _song = PlayState.SONG;
		if(_song.gameOverSound == null || _song.gameOverSound.trim().length < 1) GameOverSubstate.deathSoundName = 'fnf_loss_sfx-pixel';
		if(_song.gameOverLoop == null || _song.gameOverLoop.trim().length < 1) GameOverSubstate.loopSoundName = 'gameOver-pixel';
		if(_song.gameOverEnd == null || _song.gameOverEnd.trim().length < 1) GameOverSubstate.endSoundName = 'gameOverEnd-pixel';
		if(_song.gameOverChar == null || _song.gameOverChar.trim().length < 1) GameOverSubstate.characterName = 'bf-pixel-dead';

			view = new ModelView(1, 0, 1, 1, 6000, ClientPrefs.lowRes);

			view.view.visible = false;

			curStage = 'school';

			LoadingCount.expand(2);

			view.distance = 370;
			view.setCamLookAt(0, 90, 0);

			Asset3DLibrary.enableParser(AWDParser);
			Asset3DLibrary.addEventListener(Asset3DEvent.ASSET_COMPLETE, onAssetComplete);
			Asset3DLibrary.load(new URLRequest("assets/models/school.awd"));
			Asset3DLibrary.load(new URLRequest("assets/models/petal.awd"));

			skyboxTex = new BitmapCubeTexture(Cast.bitmapData("assets/models/skybox/px.png"), Cast.bitmapData("assets/models/skybox/nx.png"),
				Cast.bitmapData("assets/models/skybox/py.png"), Cast.bitmapData("assets/models/skybox/ny.png"),
				Cast.bitmapData("assets/models/skybox/pz.png"), Cast.bitmapData("assets/models/skybox/nz.png"));

			skybox = new SkyBox(skyboxTex);
			view.view.scene.addChild(skybox);
			if (ClientPrefs.lowRes)
			{
				view.sprite.cameras = [camUnderHUD];
				add(view.sprite);
				var lowest = Math.min(FlxG.width / view.sprite.width, FlxG.height / view.sprite.height);
				view.sprite.scale.set(lowest, lowest);
				view.sprite.updateHitbox();
				view.sprite.screenCenter(XY);
				lowRes = true;
				// camUnderHUD.setFilters([new BlurFilter(2, 2, BitmapFilterQuality.LOW), new ShaderFilter(new Scanlines())]);
				view.sprite.shader = new PSXShader();
				view.view.x = FlxG.stage.stageWidth;
				view.view.y = FlxG.stage.stageHeight;
			}
			else
			{
				view.view.width = FlxG.scaleMode.gameSize.x;
				view.view.height = FlxG.scaleMode.gameSize.y;
				view.view.x = FlxG.stage.stageWidth / 2 - FlxG.scaleMode.gameSize.x / 2;
				view.view.y = FlxG.stage.stageHeight / 2 - FlxG.scaleMode.gameSize.y / 2;
			}


		if (SONG.song.toLowerCase() == 'fuzzy-logic')
			gf = new Character3D(view, '', false);
		else
			gf = new Character3D(view, 'gf', false);

		// dad = new Character(100, 100, SONG.player2);
		if (SONG.song.toLowerCase() == 'fuzzy-logic')
			dad = new Character3D(view, 'hydra', false);
		else if (SONG.song.toLowerCase() == 'roses')
			dad = new Character3D(view, 'senpai-angry', false);
		else
			dad = new Character3D(view, 'senpai', false);

		gf = new Character3D(0, 0, SONG.player3);
		startCharacterPos(gf, true);
		gfGroup.add(gf);

		dad = new Character3D(0, 0, SONG.player2);
		startCharacterPos(dad, true);
		dadGroup.add(dad);

		boyfriend = new Character3D(0, 0, SONG.player1, true);
		startCharacterPos(boyfriend);
		boyfriendGroup.add(boyfriend);

		switch (songName)
		{
			case 'senpai':
				FlxG.sound.playMusic(Paths.music('Lunchbox'), 0);
				FlxG.sound.music.fadeIn(1, 0, 0.8);
			case 'roses':
				FlxG.sound.play(Paths.sound('ANGRY_TEXT_BOX'));
		}
		if(isStoryMode && !seenCutscene)
		{
			if(songName == 'roses') FlxG.sound.play(Paths.sound('ANGRY'));
			initDoof();
			setStartCallback(schoolIntro);
		}
	}

	override function beatHit()
	{

	}

	// For events
	override function eventCalled(eventName:String, value1:String, value2:String, flValue1:Null<Float>, flValue2:Null<Float>, strumTime:Float)
	{

	}

	var doof:DialogueBox = null;
	function initDoof()
	{
		var file:String = Paths.txt('$songName/${songName}Dialogue_${ClientPrefs.data.language}'); //Checks for vanilla/Senpai dialogue
		#if MODS_ALLOWED
		if (!FileSystem.exists(file))
		#else
		if (!OpenFlAssets.exists(file))
		#end
		{
			file = Paths.txt('$songName/${songName}Dialogue');
		}

		#if MODS_ALLOWED
		if (!FileSystem.exists(file))
		#else
		if (!OpenFlAssets.exists(file))
		#end
		{
			startCountdown();
			return;
		}

		doof = new DialogueBox(false, CoolUtil.coolTextFile(file));
		doof.cameras = [camHUD];
		doof.scrollFactor.set();
		doof.finishThing = startCountdown;
		doof.nextDialogueThing = PlayState.instance.startNextDialogue;
		doof.skipDialogueThing = PlayState.instance.skipDialogue;
	}
	
	function schoolIntro():Void
	{
		inCutscene = true;
		var black:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
		black.scrollFactor.set();
		if(songName == 'senpai') add(black);

		new FlxTimer().start(0.3, function(tmr:FlxTimer)
		{
			black.alpha -= 0.15;

			if (black.alpha <= 0)
			{
				if (doof != null)
					add(doof);
				else
					startCountdown();

				remove(black);
				black.destroy();
			}
			else tmr.reset(0.3);
		});
	}
}

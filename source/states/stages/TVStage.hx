package states.stages;

import states.stages.objects.*;
import lime.app.Application;
import away3d.core.base.ParticleGeometry;
import away3d.loaders.parsers.AWDParser;
import flixel.util.FlxDestroyUtil;
import haxe.Json;
import flixel.FlxState;
import away3d.textures.BitmapCubeTexture;
import away3d.textures.BitmapTexture;
import away3d.primitives.SkyBox;
import away3d.materials.MaterialBase;
import openfl.geom.Vector3D;
import away3d.animators.data.ParticleProperties;
import away3d.animators.data.ParticlePropertiesMode;
import away3d.animators.data.ParticlePropertiesMode;
import away3d.animators.data.ParticlePropertiesMode;
import away3d.animators.data.ParticlePropertiesMode;
import away3d.materials.ColorMaterial;
import away3d.tools.helpers.ParticleGeometryHelper;
import away3d.animators.ParticleAnimator;
import away3d.animators.nodes.ParticleRotationalVelocityNode;
import away3d.animators.nodes.ParticleRotateToPositionNode;
import away3d.animators.nodes.ParticleVelocityNode;
import away3d.animators.nodes.ParticlePositionNode;
import away3d.animators.ParticleAnimationSet;
import openfl.Vector;
import away3d.core.base.Geometry;
import away3d.entities.Mesh;
import away3d.utils.Cast;
import away3d.materials.TextureMaterial;
import away3d.library.assets.Asset3DType;
import openfl.net.URLRequest;
import away3d.events.Asset3DEvent;
import away3d.library.Asset3DLibrary;

class TVStage extends BaseStage
{
	var view:ModelView;

	var tv:TVModel;

	private var dad:Character3D;
	private var gf:Character3D;
	private var boyfriend:Boyfriend3D;

	public var boyfriendGroup:FlxSpriteGroup;
	public var dadGroup:FlxSpriteGroup;
	public var gfGroup:FlxSpriteGroup;

	public static var loadEvents:Bool = true;

	override function create()
	
		if (loadEvents)
		{
			var thing = "assets/data/" + SONG.song.toLowerCase() + "/events.json";
			if (Assets.exists(thing))
			{
				trace("loaded events");
				trace(Paths.json(SONG.song.toLowerCase() + "/events"));
				EVENTS = Song.parseEventJSON(Assets.getText(thing));
			}
			else
			{
				trace("No events found");
				EVENTS = {
					events: []
				};
			}
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
			dad = new Character3D(view, 'senpai', false)

		gf = new Character3D(0, 0, SONG.player3);
		startCharacterPos(gf, true);
		gfGroup.add(gf);

		dad = new Character3D(0, 0, SONG.player2);
		startCharacterPos(dad, true);
		dadGroup.add(dad);

		boyfriend = new Character3D(0, 0, SONG.player1, true);
		startCharacterPos(boyfriend);
		boyfriendGroup.add(boyfriend);
			
	                Application.current.window.mouseLock = true;
			Application.current.window.onMouseMoveRelative.add(onMouseMove);

			view = new ModelView(1, 1, 1, 1, 6000);

			view.view.visible = false;

			view.view.width = FlxG.scaleMode.gameSize.x;
			view.view.height = FlxG.scaleMode.gameSize.y;
			view.view.x = FlxG.stage.stageWidth / 2 - FlxG.scaleMode.gameSize.x / 2;
			view.view.y = FlxG.stage.stageHeight / 2 - FlxG.scaleMode.gameSize.y / 2;

			curStage = 'schoolEvil';

			autoUi = false;

			LoadingCount.expand(1);

			view.distance = 1;
			view.setCamLookAt(0, 90, 0);
			view.view.camera.x = view.view.camera.y = view.view.camera.z = 0;
			Asset3DLibrary.enableParser(AWDParser);
			Asset3DLibrary.addEventListener(Asset3DEvent.ASSET_COMPLETE, onAssetCompleteTV);
			Asset3DLibrary.load(new URLRequest("assets/models/floor/floor.awd"));
			// Asset3DLibrary.load(new URLRequest("assets/models/petal.awd"));

			planeBitmap = Cast.bitmapTexture("assets/models/floor/floor.png");
			planeMat = new TextureMaterial(planeBitmap, false, true);
			schoolPlane = new Mesh(new PlaneGeometry(5000, 5000), planeMat);
			schoolPlane.scale(70);
			schoolPlane.y -= 8000;

			view.view.scene.addChild(schoolPlane);

			skyboxTex = new BitmapCubeTexture(Cast.bitmapData("assets/models/skybox2/px.png"), Cast.bitmapData("assets/models/skybox2/nx.png"),
				Cast.bitmapData("assets/models/skybox2/py.png"), Cast.bitmapData("assets/models/skybox2/ny.png"),
				Cast.bitmapData("assets/models/skybox2/pz.png"), Cast.bitmapData("assets/models/skybox2/nz.png"));

			skybox = new SkyBox(skyboxTex);
			view.view.scene.addChild(skybox);

			// tv = new ModelThing(view, 'tv', 'awd', [], [], 50, 0, 0, 0, -50, -20, 0, false, false);

			camNotes.bgColor.alpha = 255;
			// camNotes.setPosition(FlxG.width - 1, FlxG.height - 1);

			// camNotes.setFilters([new ShaderFilter(new Scanlines())]);
			@:privateAccess
			if (true)
			{
				camNotes.flashSprite.cacheAsBitmap = true;
			}

			@:privateAccess
			tv = new TVModel(planeBitmap.bitmapData.__texture, view, 'tv', 'awd', [], [], 50, 0, 0, 0, -50, 2000, 0, false, false, true);

	override public function destroy()
	{
		if (barTween != null && barTween.active)
			barTween.cancel();
		barTween = FlxDestroyUtil.destroy(barTween);
		Asset3DLibrary.stopLoad();
		if (schoolPlane != null)
		{
			if (schoolPlane.geometry != null)
				schoolPlane.geometry.dispose();
			schoolPlane.disposeWithChildren();
		}
		schoolPlane = null;
		if (planeMat != null)
			planeMat.dispose();
		planeMat = null;
		if (planeBitmap != null)
			planeBitmap.dispose();
		planeBitmap = null;
		if (particleSet != null)
			particleSet.dispose();
		particleSet = null;
		if (particleAnimator != null)
		{
			particleAnimator.stop();
			particleAnimator.dispose();
		}
		particleAnimator = null;
		if (particleMat != null)
			particleMat.dispose();
		particleMat = null;
		if (particleMesh != null)
			particleMesh.disposeWithChildren();
		particleMesh = null;
		if (petal != null)
			petal.dispose();
		petal = null;
		if (particleMesh != null)
			particleMesh.disposeWithAnimatorAndChildren();
		particleMesh = null;
		if (geometrySet != null)
		{
			for (i in geometrySet)
			{
				if (i != null)
					i.dispose();
			}
		}
		geometrySet = null;
		if (particleGeo != null)
		{
			particleGeo.dispose();
		}
		particleGeo = null;
		if (skybox != null)
			skybox.disposeWithChildren();
		skybox = null;
		if (skyboxTex != null)
		{
			skyboxTex.dispose();
			for (i in [
				skyboxTex.positiveX,
				skyboxTex.negativeX,
				skyboxTex.positiveY,
				skyboxTex.negativeY,
				skyboxTex.positiveZ,
				skyboxTex.negativeZ
			])
			{
				if (i != null)
				{
					i.dispose();
				}
			}
		}
		skyboxTex = null;
		boyfriend = FlxDestroyUtil.destroy(boyfriend);
		dad = FlxDestroyUtil.destroy(dad);
		gf = FlxDestroyUtil.destroy(gf);
		if (tv != null)
			tv.destroy();
		tv = null;
		Asset3DLibrary.removeAllAssets();
		if (view != null)
			view.destroy();
		view = null;
		vocals = FlxDestroyUtil.destroy(vocals);
		music = FlxDestroyUtil.destroy(music);
		AudioStreamThing.destroyGroup();
		super.destroy();
		if (instance == this)
		{
			instance = null;
		}
		FlxG.bitmap.clearCache();
		Assets.cache.clear();
	}
	private function executeEvent(tag:String, value:Array<Dynamic>):Void
	{
		switch (tag)
		{
			case 'dist':
				var dist:Float = value[0];
				var time:Float = value[1];
				if (camDistTween != null && camDistTween.active)
				{
					camDistTween.cancel();
					camDistTween.destroy();
				}
				if (time > 0)
					camDistTween = FlxTween.tween(view, {"distance": dist}, time);
				else
					view.distance = dist;
			case 'tilt':
				var tilt:Float = value[0];
				var time:Float = value[1];
				if (camTiltTween != null && camTiltTween.active)
				{
					camTiltTween.cancel();
					camTiltTween.destroy();
				}
				if (time > 0)
					camTiltTween = FlxTween.tween(view, {"tilt": tilt}, time);
				else
					view.tilt = tilt;
			case 'pan':
				var pan:Float = value[0];
				var time:Float = value[1];
				if (camPanTween != null && camPanTween.active)
				{
					camPanTween.cancel();
					camPanTween.destroy();
				}
				if (time > 0)
					camPanTween = FlxTween.tween(view, {"pan": pan}, time);
				else
					view.pan = pan;
			case 'focus':
				var x:Float = value[0];
				var y:Float = value[1];
				var z:Float = value[2];
				var time:Float = value[3];
				if (camFocusTween != null && camFocusTween.active)
				{
					camFocusTween.cancel();
					camFocusTween.destroy();
				}
				if (time > 0)
					camFocusTween = FlxTween.tween(view.lookAtObject, {"x": x, "y": y, "z": z}, time);
				else
					view.setCamLookAt(x, y, z);
			case 'x':
				var obj:String = value[0];
				var distance:Float = value[1];
				var time:Float = value[2];
				var relative:Bool = value[3];
				var mesh:Mesh = null;
				if (obj == 'dad' || obj == 'both')
				{
					mesh = dad.model.mesh;
					var tween = movTweenX['dad'];
					if (tween != null && tween.active)
					{
						tween.cancel();
						tween.destroy();
					}
					var destination = distance;
					if (relative)
						destination += mesh.x;
					if (time > 0)
						movTweenX['dad'] = FlxTween.tween(posMap["dad"], {"x": destination}, time, {ease: FlxEase.quadInOut});
					else
						posMap["dad"].x = destination;
				}
				if (obj == 'tv' || obj == 'both')
				{
					mesh = tv.mesh;
					var tween = movTweenX['tv'];
					if (tween != null && tween.active)
					{
						tween.cancel();
						tween.destroy();
					}
					var destination = distance;
					if (relative)
						destination += mesh.x;
					if (time > 0)
						movTweenX['tv'] = FlxTween.tween(posMap["tv"], {"x": destination}, time, {ease: FlxEase.quadInOut});
					else
						posMap["tv"].x = destination;
				}

			case 'y':
				var obj:String = value[0];
				var distance:Float = value[1];
				var time:Float = value[2];
				var relative:Bool = value[3];
				var mesh:Mesh = null;
				if (obj == 'dad' || obj == 'both')
				{
					mesh = dad.model.mesh;
					var tween = movTweenY['dad'];
					if (tween != null && tween.active)
					{
						tween.cancel();
						tween.destroy();
					}
					var destination = distance;
					if (relative)
						destination += mesh.y;
					if (time > 0)
						movTweenY['dad'] = FlxTween.tween(posMap["dad"], {"y": destination}, time, {ease: FlxEase.quadInOut});
					else
						posMap["dad"].y = destination;
				}
				if (obj == 'tv' || obj == 'both')
				{
					mesh = tv.mesh;
					var tween = movTweenY['tv'];
					if (tween != null && tween.active)
					{
						tween.cancel();
						tween.destroy();
					}
					var destination = distance;
					if (relative)
						destination += mesh.y;
					if (time > 0)
						movTweenY['tv'] = FlxTween.tween(posMap["tv"], {"y": destination}, time, {ease: FlxEase.quadInOut});
					else
						posMap["tv"].y = destination;
				}

			case 'z':
				var obj:String = value[0];
				var distance:Float = value[1];
				var time:Float = value[2];
				var relative:Bool = value[3];
				var mesh:Mesh = null;
				if (obj == 'dad' || obj == 'both')
				{
					mesh = dad.model.mesh;
					var tween = movTweenZ[obj];
					if (tween != null && tween.active)
					{
						tween.cancel();
						tween.destroy();
					}
					var destination = distance;
					if (relative)
						destination += mesh.z;
					if (time > 0)
						movTweenZ[obj] = FlxTween.tween(posMap["dad"], {"z": destination}, time, {ease: FlxEase.quadInOut});
					else
						posMap["dad"].z = destination;
				}
				else if (obj == 'tv' || obj == 'both')
				{
					mesh = tv.mesh;
					var tween = movTweenZ[obj];
					if (tween != null && tween.active)
					{
						tween.cancel();
						tween.destroy();
					}
					var destination = distance;
					if (relative)
						destination += mesh.z;
					if (time > 0)
						movTweenZ[obj] = FlxTween.tween(posMap["tv"], {"z": destination}, time, {ease: FlxEase.quadInOut});
					else
						posMap["tv"].z = destination;
				}

			case 'angle':
				var obj:String = value[0];
				var distance:Float = value[1];
				var angle:Float = value[2];
				var time:Float = value[3];
				var mesh:Mesh = null;
				if (obj == 'dad' || obj == 'both')
				{
					mesh = dad.model.mesh;
					var tween = movTweenZ[obj];
					if (tween != null && tween.active)
					{
						tween.cancel();
						tween.destroy();
					}
					var tween = movTweenX[obj];
					if (tween != null && tween.active)
					{
						tween.cancel();
						tween.destroy();
					}

					var destinationX = -FlxMath.fastSin(angle * FlxAngle.TO_RAD) * distance;
					var destinationZ = FlxMath.fastCos(angle * FlxAngle.TO_RAD) * distance;
					if (time > 0)
					{
						movTweenX[obj] = FlxTween.tween(posMap["dad"], {"x": destinationX}, time, {ease: FlxEase.quadInOut});
						movTweenZ[obj] = FlxTween.tween(posMap["dad"], {"z": destinationZ}, time, {ease: FlxEase.quadInOut});
					}
					else
					{
						mesh.z = destinationZ;
						mesh.x = destinationX;
					}
				}
				if (obj == 'tv' || obj == 'both')
				{
					mesh = tv.mesh;
					var tween = movTweenZ[obj];
					if (tween != null && tween.active)
					{
						tween.cancel();
						tween.destroy();
					}
					var tween = movTweenX[obj];
					if (tween != null && tween.active)
					{
						tween.cancel();
						tween.destroy();
					}

					var destinationX = -FlxMath.fastSin(angle * FlxAngle.TO_RAD) * distance;
					var destinationZ = FlxMath.fastCos(angle * FlxAngle.TO_RAD) * distance;
					if (time > 0)
					{
						movTweenX[obj] = FlxTween.tween(posMap["tv"], {"x": destinationX}, time, {ease: FlxEase.quadInOut});
						movTweenZ[obj] = FlxTween.tween(posMap["tv"], {"z": destinationZ}, time, {ease: FlxEase.quadInOut});
					}
					else
					{
						mesh.z = destinationZ;
						mesh.x = destinationX;
					}
				}

			case 'circle':
				var obj:String = value[0];
				var distance:Float = value[1];
				var angle:Float = value[2];
				var time:Float = value[3];
				var clockwise:Bool = value[4];
				var loop:Bool = value[5];

				if (obj == 'dad' || obj == 'both')
				{
					var tween = movTweenCirc['dad'];
					if (tween != null && tween.active)
					{
						tween.cancel();
						tween.destroy();
					}
					movTweenCirc['dad'] = FlxTween.circularMotion(circlSpr, 0, 0, distance, angle, clockwise, time, true, {
						type: (loop ? LOOPING : ONESHOT),
						onStart: function(_)
						{
							if (Math.abs(circlSpr.x) > 5 && Math.abs(circlSpr.y) > 5)
							{
								circlSpr.y = posMap["dad"].x;
								circlSpr.x = posMap["dad"].z;
							}
						},
						onUpdate: function(_)
						{
							posMap["dad"].x = circlSpr.y;
							posMap["dad"].z = circlSpr.x;
						}
					});
				}

				if (obj == 'tv' || obj == 'both')
				{
					var tween = movTweenCirc['tv'];
					if (tween != null && tween.active)
					{
						tween.cancel();
						tween.destroy();
					}
					movTweenCirc['tv'] = FlxTween.circularMotion(circlSpr2, 0, 0, distance, angle, clockwise, time, true, {
						type: (loop ? LOOPING : ONESHOT),
						onStart: function(_)
						{
							if (Math.abs(circlSpr2.x) > 5 && Math.abs(circlSpr2.y) > 5)
							{
								circlSpr2.y = posMap["tv"].x;
								circlSpr2.x = posMap["tv"].z;
							}
						},
						onUpdate: function(_)
						{
							posMap["tv"].x = circlSpr2.y;
							posMap["tv"].z = circlSpr2.x;
						}
					});
				}

			case 'endcircle':
				var obj = value[0];
				if (obj == 'dad' || obj == 'both')
				{
					var tween = movTweenCirc['dad'];
					if (tween != null && tween.active)
					{
						tween.cancel();
						tween.destroy();
					}
				}

				if (obj == 'tv' || obj == 'both')
				{
					var tween = movTweenCirc['tv'];
					if (tween != null && tween.active)
					{
						tween.cancel();
						tween.destroy();
					}
				}

			default:
				trace(tag);
		}
		return;
	}

	
	override function createPost()
	{
		// Use this function to layer things above characters!
	}

	override function update(elapsed:Float)
	{
		// Code here
	}

	
	override function countdownTick(count:BaseStage.Countdown, num:Int)
	{
		switch(count)
		{
			case THREE: //num 0
			case TWO: //num 1
			case ONE: //num 2
			case GO: //num 3
			case START: //num 4
		}
	}

	// Steps, Beats and Sections:
	//    curStep, curDecStep
	//    curBeat, curDecBeat
	//    curSection
	override function stepHit()
	{
		// Code here
	}
	override function beatHit()
	{
		// Code here
	}
	override function sectionHit()
	{
		// Code here
	}

	// Substates for pausing/resuming tweens and timers
	override function closeSubState()
	{
		if(paused)
		{
			//timer.active = true;
			//tween.active = true;
		}
	}

	override function openSubState(SubState:flixel.FlxSubState)
	{
		if(paused)
		{
			//timer.active = false;
			//tween.active = false;
		}
	}

	// For events
	override function eventCalled(eventName:String, value1:String, value2:String, flValue1:Null<Float>, flValue2:Null<Float>, strumTime:Float)
	{
		switch(eventName)
		{
			case "My Event":
		}
	}
	override function eventPushed(event:objects.Note.EventNote)
	{
		// used for preloading assets used on events that doesn't need different assets based on its values
		switch(event.event)
		{
			case "My Event":
				//precacheImage('myImage') //preloads images/myImage.png
				//precacheSound('mySound') //preloads sounds/mySound.ogg
				//precacheMusic('myMusic') //preloads music/myMusic.ogg
		}
	}
	override function eventPushedUnique(event:objects.Note.EventNote)
	{
		// used for preloading assets used on events where its values affect what assets should be preloaded
		switch(event.event)
		{
			case "My Event":
				switch(event.value1)
				{
					// If value 1 is "blah blah", it will preload these assets:
					case 'blah blah':
						//precacheImage('myImageOne') //preloads images/myImageOne.png
						//precacheSound('mySoundOne') //preloads sounds/mySoundOne.ogg
						//precacheMusic('myMusicOne') //preloads music/myMusicOne.ogg

					// If value 1 is "coolswag", it will preload these assets:
					case 'coolswag':
						//precacheImage('myImageTwo') //preloads images/myImageTwo.png
						//precacheSound('mySoundTwo') //preloads sounds/mySoundTwo.ogg
						//precacheMusic('myMusicTwo') //preloads music/myMusicTwo.ogg
					
					// If value 1 is not "blah blah" or "coolswag", it will preload these assets:
					default:
						//precacheImage('myImageThree') //preloads images/myImageThree.png
						//precacheSound('mySoundThree') //preloads sounds/mySoundThree.ogg
						//precacheMusic('myMusicThree') //preloads music/myMusicThree.ogg
				}
		}
	}
}

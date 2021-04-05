package states;

import editor.EditorState;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.editors.tiled.TiledObject;
import flixel.addons.editors.tiled.TiledPropertySet;
import flixel.addons.editors.tiled.TiledTileLayer;
import flixel.math.FlxMath;
import flixel.math.FlxRect;
import flixel.system.debug.FlxDebugger.FlxDebuggerLayout;
import flixel.text.FlxText;
import flixel.tile.FlxBaseTilemap.FlxTilemapAutoTiling;
import flixel.tile.FlxTilemap;
import hscript.Interp;
import hscript.Parser;
import level.LevelLoader;
import level.objects.BasicObject;
import level.objects.BasicPlayer;
import level.objects.LightDetector;
import level.objects.LightEmitter.LightParticle;
import level.objects.LoadingZone;
import level.objects.PlatformerPlayer;
import level.objects.TopDownPlayer;
import states.substates.OptionsSubstate;
import states.substates.PauseMenuSubstate;

// import level.TiledLoader;
class PlayState extends FlxState {
	// public var loadedLevelProperties:TiledPropertySet;
	// public var loadedTileLayers:Array<FlxTilemap>;
	public var levelLoader:LevelLoader;
	// public var debugDisplay:FlxText;
	public var debugDisplay:DebugDisplay;

	public var gameCamera:FlxCamera;
	public var hudCamera:FlxCamera;

	public var playerCharacter:BasicPlayer;
	public var loadSpawnpoint:String;

	public var debugInfoVisible:Bool = #if debug true #else false #end;

	public function new(level:NamespacedKey, ?spawnpoint:String) {
		super();
		if (level == null) {
			level = NamespacedKey.ofDefaultNamespace("levels/topdown_test");
		}
		levelLoader = new LevelLoader(level);

		this.loadSpawnpoint = spawnpoint;
	}

	override public function create() {
		FlxG.mouse.useSystemCursor = true;
		FlxG.debugger.toggleKeys = null;

		this.gameCamera = new FlxCamera();
		this.hudCamera = new FlxCamera();
		this.hudCamera.bgColor.alpha = 0;

		FlxG.cameras.reset(this.gameCamera);
		FlxG.cameras.add(this.hudCamera);

		FlxCamera.defaultCameras = [this.gameCamera];

		// debugDisplay = new FlxText(10, 20, 0, "debug", 20);

		debugDisplay = new DebugDisplay();

		levelLoader.loadLevel();
		add(levelLoader.loadedTilemap);
		add(levelLoader.loadingZones);
		add(levelLoader.loadedObjects);
		add(levelLoader.miscObjects);
		// levelLoader.loadedTilemap.getTileByIndex()

		if (levelLoader.loadedLevelData.objects.player.type == "platformer")
			playerCharacter = new PlatformerPlayer(levelLoader.loadedLevelData.objects.player.x, levelLoader.loadedLevelData.objects.player.y);
		else if (levelLoader.loadedLevelData.objects.player.type == "topdown")
			playerCharacter = new TopDownPlayer(levelLoader.loadedLevelData.objects.player.x, levelLoader.loadedLevelData.objects.player.y);
		else
			playerCharacter = new BasicPlayer(levelLoader.loadedLevelData.objects.player.x, levelLoader.loadedLevelData.objects.player.y);

		add(playerCharacter);

		if (this.levelLoader.loadedLevelData.objects.spawnpoints != null) {
			if (this.levelLoader.loadedLevelData.objects.spawnpoints.exists(this.loadSpawnpoint)) {
				playerCharacter.x = this.levelLoader.loadedLevelData.objects.spawnpoints.get(this.loadSpawnpoint).x;
				playerCharacter.y = this.levelLoader.loadedLevelData.objects.spawnpoints.get(this.loadSpawnpoint).y;
			}
		}

		// FlxG.collide(levelLoader.loadedTilemap, playerCharacter);

		// FlxG.camera.setScrollBoundsRect(levelLoader.mapBounds.x, levelLoader.mapBounds.y, levelLoader.mapBounds.width, levelLoader.mapBounds.height);

		FlxG.camera.minScrollX = levelLoader.loadedLevelData.levelPadding.left * -16;
		FlxG.camera.minScrollY = levelLoader.loadedLevelData.levelPadding.top * -16;
		FlxG.camera.maxScrollX = (levelLoader.loadedLevelData.width + levelLoader.loadedLevelData.levelPadding.right) * 16;
		FlxG.camera.maxScrollY = (levelLoader.loadedLevelData.height + levelLoader.loadedLevelData.levelPadding.bottom) * 16;

		if (levelLoader.mapHeightScale == levelLoader.mapWidthScale)
			FlxG.camera.zoom = levelLoader.mapHeightScale
		else
			FlxG.camera.setScale(levelLoader.mapHeightScale, levelLoader.mapWidthScale);

		FlxG.camera.follow(playerCharacter, LOCKON, 0.04);

		trace("loaded level poggers");

		// var test_sprite = new FlxSprite(0, 0, levelLoader.combinedTilesheet.parent.bitmap);

		// add(test_sprite);
		add(debugDisplay);
		// debugDisplay.scrollFactor.set(0, 0);

		// levelLoader.loadedTilemap.cameras = [this.gameCamera];
		// playerCharacter.cameras = [this.gameCamera];

		debugDisplay.cameras = [this.hudCamera];

		if (this.levelLoader.loadedLevelData.scripts.load != null) {
			var parsed = AssetHelper.getScriptAsset(NamespacedKey.fromString(this.levelLoader.loadedLevelData.scripts.load));
			var interp = new Interp();
			interp.variables.set("level", this.levelLoader);
			interp.variables.set("playerCharacter", this.playerCharacter);
			interp.execute(parsed);
		}

		this.persistentUpdate = true;

		super.create();
	}

	public var hudVisible = true;
	public var isPaused = false;
	public var hscriptInterp = new Interp();

	override public function update(elapsed:Float) {
		var debugAppend = "";
		if (this.levelLoader.loadedLevelData.scripts.tick != null) {
			var parsed = AssetHelper.getScriptAsset(NamespacedKey.fromString(this.levelLoader.loadedLevelData.scripts.tick));
			var interp = this.hscriptInterp;
			interp.variables.clear();
			interp.variables.set("level", this.levelLoader);
			interp.variables.set("playerCharacter", this.playerCharacter);
			interp.variables.set("elapsed", elapsed);
			interp.variables.set("debugAppend", debugAppend);
			interp.variables.set("paused", this.isPaused);
			interp.execute(parsed);
			debugAppend = interp.variables.get("debugAppend");
		}

		if (this.debugInfoVisible) {
			this.debugDisplay.leftAppend = 'vX: ${this.playerCharacter.velocity.x} vY: ${this.playerCharacter.velocity.y}\naX: ${this.playerCharacter.acceleration.x} aY: ${this.playerCharacter.acceleration.y}\npX: ${Math.round(this.playerCharacter.x) / 16} pY: ${Math.round(this.playerCharacter.y) / 16}\ncX: ${this.gameCamera.scroll.x} cY: ${this.gameCamera.scroll.y}';

			if (Std.isOfType(this.playerCharacter, PlatformerPlayer)) {
				var pc:PlatformerPlayer = cast this.playerCharacter;
				this.debugDisplay.leftAppend += "\nJ:" + (pc.canJump() ? "t" : "f");
			}
			this.debugDisplay.leftAppend += "\n" + debugAppend;

			// this.debugDisplay.text = debugText;
		}

		if (FlxG.keys.anyJustPressed([ESCAPE])) {
			if (this.subState == null) {
				this.openSubState(new PauseMenuSubstate());
				this.isPaused = true;
			}
			else {
				this.closeSubState();
				this.isPaused = false;
			}
		}

		if (FlxG.keys.anyJustPressed([GRAVEACCENT])) {
			if (!FlxG.debugger.visible) {
				FlxG.debugger.setLayout(FlxDebuggerLayout.MICRO);
				FlxG.debugger.visible = true;
			}
			else {
				FlxG.debugger.visible = false;
			}
		}

		if (FlxG.keys.anyJustPressed([F1])) // Hud visibility (0.1 only in debug)
		{
			this.hudVisible = !this.hudVisible;
			this.hudCamera.alpha = (this.hudVisible ? 1 : #if debug 0.1 #else 0 #end);
		}

		if (FlxG.keys.anyJustPressed([F2])) // Flixel debugger
		{
			#if debug
			FlxG.debugger.visible = !FlxG.debugger.visible;
			#else
			// debugger only available in debug mode
			#end
		}

		if (FlxG.keys.anyJustPressed([F3])) {
			this.debugDisplay.visible = !this.debugDisplay.visible;
		}

		if (FlxG.keys.anyJustPressed([F4])) {
			FlxG.switchState(new EditorState(this.levelLoader.levelNamespace));
		}

		if (FlxG.keys.anyJustPressed([F5, R])) // r = restart, f5 = reload
			// for now, they are the same, but they might act differently in the future (r = suicide?)
			// also because F5 is reload in the editor
		{
			FlxG.switchState(new PlayState(this.levelLoader.levelNamespace, this.loadSpawnpoint));
		}

		if (!this.isPaused) {
			this.gameCamera.alpha = 1;

			// TODO : pulling objects

			FlxG.collide(levelLoader.loadedTilemap, playerCharacter);
			FlxG.overlap(this.levelLoader.loadedObjects, this.playerCharacter, (obj:BasicObject, player) -> {
				if (obj.properties.collidesWithPlayer) {
					if (obj.properties.lock.x != true) {
						if (obj.properties.lock.y != true) {
							FlxObject.separate(obj, player);
						}
						else {
							FlxObject.separateX(obj, player);
						}
					}
					else {
						if (obj.properties.lock.y != true) {
							FlxObject.separateY(obj, player);
						}
					}
				}
			});

			FlxG.overlap(this.levelLoader.miscObjects, this.levelLoader.loadedTilemap, (obje:FlxBasic, ground) -> {
				if (Std.isOfType(obje, LightParticle)) {
					if (this.levelLoader.loadedTilemap.overlaps(obje)) {
						var bullet:LightParticle = cast(obje, LightParticle);
						FlxObject.separate(bullet, this.levelLoader.loadedTilemap);
						bullet.bounce();
						// trace("light bounce tilemap");
					}
				}
			});

			FlxG.overlap(this.levelLoader.miscObjects, this.levelLoader.loadedObjects, (obj1:FlxBasic, obj2:BasicObject) -> {
				if (Std.isOfType(obj1, LightParticle)) {
					var bullet:LightParticle = cast(obj1, LightParticle);
					/*if (Std.isOfType(obj2, LightDetector))
						{
							var detector:LightDetector = cast(obj2, LightDetector);
							detector.lighthit(bullet);
					}*/
					if (obj2.properties.collidesWithGround) {
						CollisionHelper.separate(bullet, obj2, false, true);
						bullet.bounce();
						// trace("light bounce obj");
					}
				}
			});

			FlxG.overlap(this.levelLoader.loadedObjects, this.levelLoader.loadedTilemap, (obj:BasicObject, ground) -> {
				if (obj.properties.collidesWithGround) {
					FlxObject.separate(obj, ground);
				}
			});
			FlxG.overlap(this.levelLoader.loadedObjects, this.levelLoader.loadedObjects, (obj1:BasicObject, obj2:BasicObject) -> {
				if (obj1.properties.collidesWithGround || obj2.properties.collidesWithGround) {
					FlxObject.separate(obj1, obj2);
				}
			});
			FlxG.overlap(this.levelLoader.loadingZones, this.playerCharacter, (zone:LoadingZone, player) -> {
				if (zone.loadTarget.key == "%menu")
					FlxG.switchState(new TitleState());
				else if (zone.loadTarget.key == "%null") {
					// TODO : run scripts?
				}
				else {
					if (zone.spawnpoint == null) {
						FlxG.switchState(new PlayState(zone.loadTarget));
					}
					else {
						FlxG.switchState(new PlayState(zone.loadTarget, zone.spawnpoint));
					}
				}
			});

			super.update(elapsed);
		}
		else {
			this.gameCamera.alpha = 0.7;
		}
	}
	/*public override function draw()
		{
			super.draw();
			this.playerCharacter.draw();
	}*/
}

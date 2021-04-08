package level;

import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxTileFrames;
import flixel.group.FlxGroup;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.tile.FlxBaseTilemap;
import flixel.tile.FlxTilemap;
import flixel.util.typeLimit.OneOfTwo;
import json2object.JsonParser;
import level.objects.BasicObject;
import level.objects.LightDetector;
import level.objects.LightEmitter;
import level.objects.LoadingZone;
import openfl.display.BitmapData;
import openfl.errors.TypeError;

class LevelJsonClass {
    public var height:Int;
    public var width:Int;
    public var viewHeight:Null<Float>;
    public var viewWidth:Null<Float>;
    public var mapScale:Null<Float>;
    public var scripts:LevelScriptSettings;
    public var levelPadding:LevelPaddingSettings;
    public var tilesheets:Map<String, String>;
    public var tilesheetSettings:Map<String, TilesheetSettings>;
    public var level:Array<Int>;
    public var objects:LevelObjectsClass;
}

class LevelScriptSettings {
    public var tick:Null<String>;
    public var load:Null<String>;
    public var death:Null<String>;
}

class LevelObjectsClass {
    public var player:LevelPlayerSettingsClass;
    public var spawnpoints:Null<Map<String, LevelDataSpawnpointClass>>;
    public var loadingZones:Array<LevelDataLoadingZoneClass>;
    public var other:Array<LevelDataObjectClass>;
}

class LevelDataSpawnpointClass {
    public var x:Int;
    public var y:Int;
}

class LevelPlayerSettingsClass {
    public var x:Int;
    public var y:Int;
    public var type:String;
}

class LevelDataObjectClass {
    public var position:LevelDataObjectPositionClass;
    public var sprite:String;
    public var collidesWithPlayer:Null<Bool>;
    public var collidesWithGround:Null<Bool>;
    public var drag:Null<{x:Float, y:Float}>;
    public var acceleration:Null<{x:Float, y:Float}>;
    public var lock:Null<{x:Null<Bool>, y:Null<Bool>}>;
    public var scripts:LevelObjectScriptClass;
}

class LevelObjectScriptClass {
    public var tick:Null<String>;
    public var remove:Null<String>;
    public var load:Null<String>;
    public var collide:Null<String>;
}

class LevelDataLoadingZoneClass {
    public var load:String;
    public var sprite:String;
    public var position:LevelDataObjectPositionClass;
}

class LevelDataObjectPositionClass {
    public var x:Float;
    public var y:Float;
    public var width:Int;
    public var height:Int;
}

class TilesheetSettings {
    public var connectsTo:Null<Array<Int>>;
    public var collision:Null<Bool> = true;
}

class LevelPaddingSettings {
    public var top:Int;
    public var right:Int;
    public var bottom:Int;
    public var left:Int;
    public var with:Int;
}

class LevelLoader {
    public final levelNamespace:NamespacedKey;
    public var loadedLevelData:LevelJsonClass;
    public var levelEditor:Bool = true;
    public var mapBounds:FlxRect;
    public var loadedTilemap:FlxTilemap;
    public var borderTilemap:FlxTilemap;
    public var loadingZones:FlxTypedGroup<LoadingZone>;
    public var loadedObjects:FlxTypedGroup<BasicObject>;
    public var miscObjects:FlxGroup;
    public var combinedTilesheet:FlxTileFrames;
    public var tilesheetSettings:Map<String, TilesheetSettings>;
    public var mapHeightScale:Float;
    public var mapWidthScale:Float;
    public var fullLevelWidth:Int;
    public var fullLevelHeight:Int;
    public var basicTileArray:Array<Int>;
    public var autoTiledTileArray:Array<Int>;

    // private var borderTileArray:Array<Int>;
    public function new(name:OneOfTwo<String, NamespacedKey>) {
        if (Std.isOfType(name, NamespacedKey))
            this.levelNamespace = name;
        else
            this.levelNamespace = NamespacedKey.fromString(name);
    }

    public function loadLevel(levelEditor:Bool = false) {
        var parser = new JsonParser<LevelJsonClass>();
        var rawLevelData:String = AssetHelper.getRawJsonAsset(this.levelNamespace);

        this.levelEditor = levelEditor;

        // trace(rawLevelData);
        var levelData:LevelJsonClass = parser.fromJson(rawLevelData, "level");
        this.loadedLevelData = levelData;
        var levelTilesheets:Map<String, String> = cast levelData.tilesheets;
        this.tilesheetSettings = cast levelData.tilesheetSettings;

        this.basicTileArray = loadedLevelData.level;
        this.loadedTilemap = new FlxTilemap();

        /*if (!levelEditor)
            {
                for (addingTopRows in 0...levelData.levelPadding.top)
                {
                    for (topRowsLeft in 0...levelData.levelPadding.left)
                        this.borderTileArray.push(levelData.levelPadding.with);
                    for (topRowsMiddle in 0...expectedRowSize)
                        this.borderTileArray.push(levelData.levelPadding.with);
                    for (topRowsRight in 0...levelData.levelPadding.right)
                        this.borderTileArray.push(levelData.levelPadding.with);
                }
                for (addingMiddleRows in 0...levelData.height)
                {
                    for (middleRowsLeft in 0...levelData.levelPadding.left)
                        this.borderTileArray.push(levelData.levelPadding.with);
                    for (middleRowsMiddle in 0...expectedRowSize)
                        this.borderTileArray.push(levelData.levelPadding.with);
                    for (middleRowsRight in 0...levelData.levelPadding.right)
                        this.borderTileArray.push(levelData.levelPadding.with);
                }
                for (addingBottomRows in 0...levelData.levelPadding.bottom)
                {
                    for (bottomRowsLeft in 0...levelData.levelPadding.left)
                        this.borderTileArray.push(levelData.levelPadding.with);
                    for (bottomRowsMiddle in 0...expectedRowSize)
                        this.borderTileArray.push(levelData.levelPadding.with);
                    for (bottomRowsRight in 0...levelData.levelPadding.right)
                        this.borderTileArray.push(levelData.levelPadding.with);
                }
        }*/

        var tilesInTileSheet = [false];
        var bitmapsToCombine = [new BitmapData(16, 16, true, 0x00FFFFFF)];

        for (index => k in levelTilesheets) {
            bitmapsToCombine.push(AssetHelper.getTilesheetAsset(NamespacedKey.fromString(k)));
            // trace(index + ": " + k);
            FlxG.bitmapLog.add(bitmapsToCombine[-1]);
            for (i in 0...47)
                if (levelEditor || this.tilesheetSettings.get(index) == null || this.tilesheetSettings.get(index).collision == null)
                    tilesInTileSheet.push(true);
                else
                    tilesInTileSheet.push(this.tilesheetSettings.get(index).collision);
        }

        this.combinedTilesheet = FlxTileFrames.combineTileSets(bitmapsToCombine, new FlxPoint(16, 16));

        /*if (!levelEditor)
            {
                this.fullLevelWidth = levelData.width + levelData.levelPadding.left + levelData.levelPadding.right;
                this.fullLevelHeight = levelData.height + levelData.levelPadding.top + levelData.levelPadding.bottom;
            }
            else
            { */
        this.fullLevelWidth = levelData.width;
        this.fullLevelHeight = levelData.height;
        // }

        this.doAutoTile();

        this.loadedTilemap.loadMapFromArray(autoTiledTileArray, fullLevelWidth, fullLevelHeight, this.combinedTilesheet, 16, 16, OFF, 0, 0,
            (levelEditor ? 0 : 1));

        for (index => t in tilesInTileSheet)
            this.loadedTilemap.setTileProperties(index, ((t || levelEditor) ? FlxObject.ANY : FlxObject.NONE));

        var heightScale:Float = 1;
        var widthScale:Float = 1;

        if (levelData.viewWidth == null || levelData.viewWidth <= 0) {
            if (levelData.viewHeight == null || levelData.viewHeight <= 0) {
                if (levelData.height <= levelData.width) {
                    this.mapHeightScale = FlxG.height / (levelData.height * 16);
                    this.mapWidthScale = FlxG.height / (levelData.height * 16);
                }
                else {
                    this.mapHeightScale = FlxG.width / (levelData.width * 16);
                    this.mapWidthScale = FlxG.width / (levelData.width * 16);
                }
            }
            else {
                this.mapHeightScale = FlxG.height / (levelData.viewHeight * 16);
                this.mapWidthScale = FlxG.height / (levelData.viewHeight * 16);
            }
        }
        else {
            if (levelData.viewHeight == null || levelData.viewHeight <= 0) {
                this.mapHeightScale = FlxG.width / (levelData.viewWidth * 16);
                this.mapWidthScale = FlxG.width / (levelData.viewWidth * 16);
            }
            else {
                this.mapHeightScale = FlxG.height / (levelData.viewHeight * 16);
                this.mapWidthScale = FlxG.width / (levelData.viewWidth * 16);
            }
        }

        // this.loadedTilemap.scale.set(levelData.mapScale, levelData.mapScale);

        /*if (!levelEditor)
                this.mapBounds = FlxRect.get((levelData.levelPadding.left * -16), (levelData.levelPadding.top * -16),
                    (levelData.width * 16) + ((levelData.levelPadding.left * 16) + (levelData.levelPadding.right * 16)),
                    (levelData.height * 16) + ((levelData.levelPadding.top * 16) + (levelData.levelPadding.bottom * 16)));
            else */
        this.mapBounds = FlxRect.get(0, 0, (levelData.width * 16), (levelData.height * 16));

        this.loadingZones = new FlxTypedGroup<LoadingZone>();

        for (lz in levelData.objects.loadingZones) {
            var pos = this.offsetCoords(lz.position.x, lz.position.y);
            this.loadingZones.add(new LoadingZone(Math.round(pos.x), Math.round(pos.y), lz.position.width, lz.position.height,
                NamespacedKey.fromString(lz.load), lz.sprite));
        }

        this.loadedObjects = new FlxTypedGroup<BasicObject>();
        this.miscObjects = new FlxTypedGroup<FlxBasic>();

        for (obj in levelData.objects.other) {
            if (obj.sprite == "%emitter") {
                var emitter = new LightEmitter(obj.position.x, obj.position.y, obj.position.width, obj.position.height, obj);
                this.loadedObjects.add(emitter);
                this.miscObjects.add(emitter.lightGun.group);
                this.miscObjects.add(emitter.trails);
            }
            else if (obj.sprite == "%detector") {
                var detector = new LightDetector(obj.position.x, obj.position.y, obj.position.width, obj.position.height, obj);
                this.loadedObjects.add(detector);
            }
            else {
                this.loadedObjects.add(new BasicObject(obj.position.x, obj.position.y, obj.position.width, obj.position.height, obj));
            }
        }
    }

    static final autoTileOffset = [
         0,   0, 0, 0,  2,   2, 0,   3, 0, 0, 0, 0,  0,   0, 0,   0,
        11,  11, 0, 0, 13,  13, 0,  14, 0, 0, 0, 0, 18,  18, 0,  19,
         0,   0, 0, 0,  0,   0, 0,   0, 0, 0, 0, 0,  0,   0, 0,   0,
         0,   0, 0, 0,  0,   0, 0,   0, 0, 0, 0, 0,  0,   0, 0,   0,
        51,  51, 0, 0, 53,  53, 0,  54, 0, 0, 0, 0,  0,   0, 0,   0,
        62,  62, 0, 0, 64,  64, 0,  65, 0, 0, 0, 0, 69,  69, 0,  70,
         0,   0, 0, 0,  0,   0, 0,   0, 0, 0, 0, 0,  0,   0, 0,   0,
        86,  86, 0, 0, 88,  88, 0,  89, 0, 0, 0, 0, 93,  93, 0,  94,
         0,   0, 0, 0,  0,   0, 0,   0, 0, 0, 0, 0,  0,   0, 0,   0,
         0,   0, 0, 0,  0,   0, 0,   0, 0, 0, 0, 0,  0,   0, 0,   0,
         0,   0, 0, 0,  0,   0, 0,   0, 0, 0, 0, 0,  0,   0, 0,   0,
         0,   0, 0, 0,  0,   0, 0,   0, 0, 0, 0, 0,  0,   0, 0,   0,
         0, 159, 0, 0,  0, 162, 0, 163, 0, 0, 0, 0,  0,   0, 0,   0,
         0, 172, 0, 0,  0, 175, 0, 176, 0, 0, 0, 0,  0, 181, 0, 182,
         0,   0, 0, 0,  0,   0, 0,   0, 0, 0, 0, 0,  0,   0, 0,   0,
         0, 199, 0, 0,  0, 202, 0, 203, 0, 0, 0, 0,  0, 208, 0, 209
    ];

    /*static function getOriginalTileIndex(index:Int)
        {
            return Math.floor((index - 1) / 48) + 1;
    }*/
    @:access(flixel.tile.FlxTilemap._data)
    public function changeTile(tileX:Int, tileY:Int, tileIndex:Int) {
        var pos = (tileY * this.fullLevelWidth) + tileX;
        this.basicTileArray[pos] = tileIndex;
        this.doAutoTile();

        for (index => tile in this.basicTileArray) {
            this.loadedTilemap.setTileByIndex(index, this.autoTiledTileArray[index], true);
        }
    }

    function doAutoTile() {
        this.autoTiledTileArray = [];
        var i = 0;
        while (i < this.basicTileArray.length) {
            if (this.tilesheetSettings.exists(Std.string(this.basicTileArray[i])))
                this.autoTiledTileArray.push(getAutoTiledTileIndex(i, this.basicTileArray[i], this.fullLevelWidth));
            else
                this.autoTiledTileArray.push(getAutoTiledTileIndex(i, this.basicTileArray[i], this.fullLevelWidth));
            i++;
        }
    }

    public function getAutoTiledTileIndex(tilePosition:Int, tileIndex:Int, levelWidth:Int, forceNoConnections:Bool = false):Int {
        if (tileIndex == 0)
            return 0;

        var index = 0;
        var offset = (tileIndex - 1) * 48;

        if (forceNoConnections) {
            return index + offset + 1;
        }

        var connectsTo = [-1, tileIndex];

        if (this.loadedLevelData.tilesheetSettings.exists(Std.string(tileIndex))) {
            connectsTo = this.loadedLevelData.tilesheetSettings.get(Std.string(tileIndex)).connectsTo;
            if (connectsTo == null)
                connectsTo = [-1, tileIndex];
        }

        // var connectsToBorder = connectsTo.contains(this.loadedLevelData.levelPadding.with);

        var wallUp:Bool = connectsTo.contains(-1) && tilePosition - levelWidth < 0;
        var wallRight:Bool = connectsTo.contains(-1) && tilePosition % levelWidth >= levelWidth - 1;
        var wallDown:Bool = connectsTo.contains(-1) && Std.int(tilePosition + levelWidth) >= this.basicTileArray.length;
        var wallLeft:Bool = connectsTo.contains(-1) && tilePosition % levelWidth <= 0;

        var up = wallUp || connectsTo.contains(this.basicTileArray[tilePosition - levelWidth]);
        var upRight = wallUp || wallRight || connectsTo.contains(this.basicTileArray[tilePosition - levelWidth + 1]);
        var right = wallRight || connectsTo.contains(this.basicTileArray[tilePosition + 1]);
        var rightDown = wallRight || wallDown || connectsTo.contains(this.basicTileArray[tilePosition + levelWidth + 1]);
        var down = wallDown || connectsTo.contains(this.basicTileArray[tilePosition + levelWidth]);
        var downLeft = wallDown || wallLeft || connectsTo.contains(this.basicTileArray[tilePosition + levelWidth - 1]);
        var left = wallLeft || connectsTo.contains(this.basicTileArray[tilePosition - 1]);
        var leftUp = wallLeft || wallUp || connectsTo.contains(this.basicTileArray[tilePosition - levelWidth - 1]);

        if (up)
            index += 1;
        if (upRight && up && right)
            index += 2;
        if (right)
            index += 4;
        if (rightDown && right && down)
            index += 8;
        if (down)
            index += 16;
        if (downLeft && down && left)
            index += 32;
        if (left)
            index += 64;
        if (leftUp && left && up)
            index += 128;

        index -= autoTileOffset[index];

        return index + offset + 1;

        // return index + offset;
    }

    public function offsetCoords(x:Float, y:Float):FlxPoint {
        // if (!this.levelEditor)
        //	return FlxPoint.get(x + this.loadedLevelData.levelPadding.left, y + this.loadedLevelData.levelPadding.top);
        // else
        return FlxPoint.get(x, y);
    }

    public function updateLoadedData() {
        trace(this.basicTileArray);
    }
}

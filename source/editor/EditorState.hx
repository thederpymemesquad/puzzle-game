package editor;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.ui.FlxInputText;
import flixel.addons.ui.FlxUI;
import flixel.addons.ui.FlxUIState;
import flixel.addons.ui.FlxUITabMenu;
import flixel.graphics.FlxGraphic;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import flixel.util.FlxSpriteUtil;
import haxe.MainLoop;
import level.LevelLoader;
import states.PlayState;

class EditorState extends FlxUIState {
    var levelLoader:LevelLoader;
    var tabbedToolSidebar:FlxUITabMenu;
    var selectedTilePlacementOptions:Int;
    var selectedTileInLevel:Int;

    public var debugInfoVisible:Bool = #if debug true #else false #end;
    public var hudVisible:Bool = true;
    public var debugDisplay:FlxText;
    public var gameCamera:FlxCamera;
    public var hudCamera:FlxCamera;

    public var cursorBox:FlxSprite;
    public var selectionBox:FlxSprite;

    public function new(level:NamespacedKey) {
        super();
        if (level == null) {
            level = NamespacedKey.ofDefaultNamespace("levels/topdown_test");
        }
        this.levelLoader = new LevelLoader(level);
    }

    public var tileToPlace = 0;

    override public function create() {
        FlxG.mouse.useSystemCursor = true;
        FlxG.mouse.visible = true;

        FlxG.sound.muteKeys = null;
        FlxG.sound.volumeUpKeys = null;
        FlxG.sound.volumeDownKeys = null;
        FlxG.debugger.toggleKeys = [F2];

        this.gameCamera = new FlxCamera();
        this.hudCamera = new FlxCamera();
        this.hudCamera.bgColor.alpha = 0;

        FlxG.cameras.reset(this.gameCamera);
        FlxG.cameras.add(this.hudCamera, false);

        // FlxCamera.defaultCameras = [this.gameCamera];

        debugDisplay = new FlxText((FlxG.width / 6) + 10, 20, 0, "debug", 20);
        add(debugDisplay);

        levelLoader.loadLevel(true);
        add(levelLoader.loadedTilemap);
        add(levelLoader.loadingZones);
        add(levelLoader.loadedObjects);

        this.levelLoader.loadingZones.visible = false;
        this.levelLoader.loadedObjects.visible = false;

        this.cursorBox = new FlxSprite(0, 0);
        this.cursorBox.makeGraphic(16, 16, 0xFFFF0000);
        this.cursorBox.alpha = 0.75;
        // FlxSpriteUtil.drawRect(cursorBox, 0, 0, 16 - 1, 16 - 1, FlxColor.TRANSPARENT, {thickness: 1, color: FlxColor.RED});
        add(cursorBox);

        var tabs = [
            {name: "Level Properties", label: "Level Properties"},
            {name: "Tilesheets", label: "Tilesheets"},
            {name: "Tiles", label: "Tiles"},
            {name: "Objects", label: "Objects"},
        ];

        tabbedToolSidebar = new FlxUITabMenu(null, tabs, true);
        tabbedToolSidebar.resize(FlxG.width / 6, FlxG.height);
        add(tabbedToolSidebar);

        this.createLevelPropertiesUI();
        this.createTilesheetsUI();
        this.createTilesUI();
        this.createObjectsUI();

        tabbedToolSidebar.scrollFactor.set();
        tabbedToolSidebar.cameras = [this.hudCamera];
        debugDisplay.cameras = [this.hudCamera];

        this.selectedTab = tabbedToolSidebar.selected_tab;

        trace("loaded level poggers");

        super.create();
    }

    private var selectedTab:Int;

    private function onTabSwitch() {
        switch (this.tabbedToolSidebar.selected_tab_id) {
            case "Level Properties":
                this.cursorBox.alpha = 0;
                this.levelLoader.loadingZones.visible = true;
                this.levelLoader.loadedObjects.visible = true;
            case "Tiles":
                this.cursorBox.alpha = 1;
                this.levelLoader.loadingZones.visible = false;
                this.levelLoader.loadedObjects.visible = false;
            case "Tilesheets":
                this.cursorBox.alpha = 0;
                this.levelLoader.loadingZones.visible = false;
                this.levelLoader.loadedObjects.visible = false;
            case "Objects":
                this.cursorBox.alpha = 1;
                this.levelLoader.loadingZones.visible = true;
                this.levelLoader.loadedObjects.visible = true;
        }
    }

    private function createLevelPropertiesUI():Void {
        var lP_levelNameDisplay = new FlxText(10, 10, 0, this.levelLoader.levelNamespace.toString(), 15);

        var tab_levelProperties = new FlxUI(null, this.tabbedToolSidebar);
        tab_levelProperties.name = "Level Properties";
        tab_levelProperties.add(lP_levelNameDisplay);

        this.tabbedToolSidebar.addGroup(tab_levelProperties);
    }

    private function createTilesheetsUI():Void {
        var ts_tabName = new FlxText(10, 10, 0, "Tilesheets", 20);
        var ts_newTilesheetHeader = new FlxText(10, (FlxG.height / 3) * 2, 0, "Add Tilesheet:", 20);
        var ts_newSourceLocation = new FlxInputText(10, ts_newTilesheetHeader.y + 30, Math.round(FlxG.width / 7), "Tilesheet Asset", 20);
        var ts_newAddButton = new FlxButton(10, FlxG.height - 75, "Add", function() {});

        var tab_tilesheets = new FlxUI(null, this.tabbedToolSidebar);
        tab_tilesheets.name = "Tilesheets";
        tab_tilesheets.add(ts_tabName);
        tab_tilesheets.add(ts_newTilesheetHeader);
        tab_tilesheets.add(ts_newSourceLocation);
        tab_tilesheets.add(ts_newAddButton);

        this.tabbedToolSidebar.addGroup(tab_tilesheets);
    }

    private function createTilesUI():Void {
        var t_tabName = new FlxText(10, 10, 0, "Tiles", 20);

        var tab_tiles = new FlxUI(null, this.tabbedToolSidebar);
        tab_tiles.name = "Tiles";
        tab_tiles.add(t_tabName);

        // var t_tileList = new FlxUI

        this.tabbedToolSidebar.addGroup(tab_tiles);
    }

    private function createObjectsUI():Void {
        var tab_objs = new FlxUI(null, this.tabbedToolSidebar);
        tab_objs.name = "Objects";

        var o_tabName = new FlxText(10, 10, 0, "Objects", 20);
        tab_objs.add(o_tabName);

        this.tabbedToolSidebar.addGroup(tab_objs);
    }

    public function updateTileUI():Void {
        var group = this.tabbedToolSidebar.getTabGroup("Tiles");
    }

    private var mmbDragPoint:FlxPoint = FlxPoint.get(0, 0);
    private var mmbIsDragging:Bool = false;
    private var targetZoom:Float = 1;

    override public function update(elapsed:Float) {
        super.update(elapsed);

        if (this.debugInfoVisible) {
            var debugText = "";
            debugText += "FPS: " + Main.fpsCounter.currentFPS;
            debugText += "\n_cX: " + FlxG.mouse.x + " _cY: " + FlxG.mouse.y;
            debugText += "\ncsX: " + FlxG.mouse.screenX + " csY: " + FlxG.mouse.screenY;
            debugText += "\ncwX: " + FlxG.mouse.getWorldPosition(this.gameCamera).x + " cwY: " + FlxG.mouse.getWorldPosition(this.gameCamera).y;
            debugText += "\ncmX: " + this.gameCamera.scroll.x + " cmY: " + this.gameCamera.scroll.y;

            this.debugDisplay.text = debugText;
        }

        if (FlxG.keys.anyJustPressed([F1])) {
            this.hudVisible = !this.hudVisible;
            this.hudCamera.alpha = (this.hudVisible ? 1 : #if debug 0.1 #else 0 #end);
        }

        // F2 = flixel debugger

        if (FlxG.keys.anyJustPressed([F3])) {
            this.debugInfoVisible = !this.debugInfoVisible;
            this.debugDisplay.alpha = (this.debugInfoVisible ? 1 : 0);
        }

        if (FlxG.keys.anyJustPressed([F4])) {
            FlxG.switchState(new PlayState(this.levelLoader.levelNamespace));
        }

        if (FlxG.keys.anyJustPressed([F5])) {
            FlxG.switchState(new EditorState(this.levelLoader.levelNamespace));
        }

        // var cameraPos = this.gameCamera.scroll.copyTo(new FlxPoint());

        if (FlxG.mouse.justPressedMiddle) {
            this.mmbIsDragging = true;
            this.mmbDragPoint = FlxG.mouse.getScreenPosition();
        }
        else if (FlxG.mouse.justReleasedMiddle) {
            this.mmbIsDragging = false;
        }

        // trace(FlxG.mouse.justMoved);

        var mousePos = FlxG.mouse.getScreenPosition();

        if (this.mmbIsDragging && FlxG.mouse.getScreenPosition() != this.mmbDragPoint) {
            var movedPos = FlxPoint.get(mousePos.x, mousePos.y);
            movedPos.subtractPoint(this.mmbDragPoint);

            this.gameCamera.scroll.subtractPoint(movedPos);
            this.mmbDragPoint.set(mousePos.x, mousePos.y);
        }

        var moveMult:Float = 1;
        if (FlxG.keys.anyPressed([SHIFT])) {
            moveMult = 1.5;
        }

        if (FlxG.keys.anyPressed([ALT])) {
            if (FlxG.keys.anyPressed([W, UP, A, LEFT])) {
                this.targetZoom += 0.05 * moveMult;
            }
            if (FlxG.keys.anyPressed([S, DOWN, D, RIGHT])) {
                this.targetZoom -= 0.05 * moveMult;
            }
        }
        else {
            if (FlxG.keys.anyPressed([W, UP])) {
                this.gameCamera.scroll.y -= 5 * moveMult;
            }
            if (FlxG.keys.anyPressed([S, DOWN])) {
                if (!(FlxG.keys.anyPressed([CONTROL]) && FlxG.keys.anyPressed([S])))
                    this.gameCamera.scroll.y += 5 * moveMult;
            }
            if (FlxG.keys.anyPressed([A, LEFT])) {
                this.gameCamera.scroll.x -= 5 * moveMult;
            }
            if (FlxG.keys.anyPressed([D, RIGHT])) {
                this.gameCamera.scroll.x += 5 * moveMult;
            }
        }

        if (FlxG.keys.anyJustPressed([ONE]))
            this.tileToPlace = 1;
        if (FlxG.keys.anyJustPressed([TWO]))
            this.tileToPlace = 2;
        if (FlxG.keys.anyJustPressed([THREE]))
            this.tileToPlace = 3;
        if (FlxG.keys.anyJustPressed([FOUR]))
            this.tileToPlace = 4;
        if (FlxG.keys.anyJustPressed([FIVE]))
            this.tileToPlace = 5;
        if (FlxG.keys.anyJustPressed([SIX]))
            this.tileToPlace = 6;
        if (FlxG.keys.anyJustPressed([SEVEN]))
            this.tileToPlace = 7;
        if (FlxG.keys.anyJustPressed([EIGHT]))
            this.tileToPlace = 8;
        if (FlxG.keys.anyJustPressed([NINE]))
            this.tileToPlace = 9;
        if (FlxG.keys.anyJustPressed([ZERO, GRAVEACCENT]))
            this.tileToPlace = 0;

        if (!this.levelLoader.loadedLevelData.tilesheets.exists(Std.string(this.tileToPlace)))
            this.tileToPlace = 0;

        if (this.tabbedToolSidebar.selected_tab_id == "Tiles"
            && FlxG.keys.anyJustPressed([GRAVEACCENT, ZERO, ONE, TWO, THREE, FOUR, FIVE, SIX, SEVEN, EIGHT, NINE])) {
            if (this.tileToPlace == 0) {
                this.cursorBox.makeGraphic(16, 16, 0x55FF0000);
            }
            else {
                var tile = this.levelLoader.getAutoTiledTileIndex(0, this.tileToPlace, 0, true);
                this.cursorBox.loadGraphic(FlxGraphic.fromFrame(this.levelLoader.combinedTilesheet.getByIndex(tile)));
                // this.cursorBox.alpha = 0.5;
            }
        }

        if (FlxG.keys.anyPressed([CONTROL]) && FlxG.keys.anyJustPressed([S])) {
            this.levelLoader.updateLoadedData();
        }

        var relMousePos = FlxG.mouse.getWorldPosition();

        if (this.tabbedToolSidebar.selected_tab != this.selectedTab) {
            this.selectedTab = this.tabbedToolSidebar.selected_tab;
            this.onTabSwitch();
        }

        if (this.tabbedToolSidebar.selected_tab_id == "Tiles") {
            if ((FlxG.mouse.justPressed || (FlxG.keys.anyPressed([SHIFT]) && FlxG.mouse.pressed))
                && this.levelLoader.loadedTilemap.overlapsPoint(relMousePos)
                && (!FlxG.mouse.overlaps(this.tabbedToolSidebar) || !this.hudVisible))
                this.levelLoader.changeTile(Math.floor(relMousePos.x / 16), Math.floor(relMousePos.y / 16), this.tileToPlace);

            if (this.levelLoader.basicTileArray[
                (Math.floor(relMousePos.y / 16) * this.levelLoader.fullLevelWidth) + Math.floor(relMousePos.x / 16)
            ] == this.tileToPlace) {
                this.cursorBox.alpha = 0;
            }
            else {
                this.cursorBox.alpha = 0.5;
            }
        }
        else if (this.tabbedToolSidebar.selected_tab_id == "Objects") {
            this.cursorBox.makeGraphic(16, 16, 0x55FF0000);
        }

        this.targetZoom = Math.max(0.25, Math.min(5, this.targetZoom + (FlxG.mouse.wheel / 4)));
        this.gameCamera.zoom = this.targetZoom;
        // FlxTween.tween(this.gameCamera, {zoom: this.targetZoom}, 0.2);
        // var relMousePos = FlxG.mouse.getPositionInCameraView(this.gameCamera);

        this.cursorBox.setPosition(Math.floor(relMousePos.x / 16) * 16, Math.floor(relMousePos.y / 16) * 16);
    }
}

package godot;

import godot.core.Log;
import godot.TileSet;

class TileMap extends Node2D {
    public var tileSet:Null<TileSet>;
    public var cellSize:Vector2;

    public var collisionEnabled:Bool;
    public var collisionLayer:Int;
    public var collisionMask:Int;

    public var format:Int;
    public var tileData:Array<Int>;

    var cellIds:Map<String, Int>;
    var cellAutotileCoords:Map<String, Vector2>;
    public var dirtyCells:Map<String, Bool>;

    var activeCollisionKeys:Map<String, Bool>;

    public function new() {
        super();

        tileSet = null;
        cellSize = new Vector2(32, 32);

        collisionEnabled = true;
        collisionLayer = 1;
        collisionMask = 1;

        format = 1;
        tileData = [];

        cellIds = new Map<String, Int>();
        cellAutotileCoords = new Map<String, Vector2>();
        dirtyCells = new Map<String, Bool>();
        activeCollisionKeys = new Map<String, Bool>();
    }

    public function set_tile_set(value:Null<TileSet>):Void {
        tileSet = value;
        rebuild_collision();
        mark_dirty(DirtyFlag.Visual);
    }

    public function get_cell_size():Vector2 {
        return tileSet != null ? tileSet.cellSize : cellSize;
    }

    public function set_cell(x:Int, y:Int, id:Int, autotileCoord:Vector2 = null):Void {
        var key:String = x + "," + y;
        var oldId:Null<Int> = cellIds.get(key);

        if (oldId == id) {
            if (autotileCoord != null) cellAutotileCoords.set(key, autotileCoord);
            dirtyCells.set(key, true);
            mark_dirty(DirtyFlag.Visual);
            return;
        }

        if (id < 0) {
            cellIds.remove(key);
            cellAutotileCoords.remove(key);
        } else {
            cellIds.set(key, id);
            if (autotileCoord != null) {
                cellAutotileCoords.set(key, autotileCoord);
            } else {
                cellAutotileCoords.remove(key);
            }
        }

        dirtyCells.set(key, true);
        mark_dirty(DirtyFlag.Visual);
        update_cell_collision(x, y, id);
    }

    public function get_cell(x:Int, y:Int):Int {
        var value:Null<Int> = cellIds.get(x + "," + y);
        return value != null ? value : -1;
    }

    public function get_cell_autotile_coord(x:Int, y:Int):Vector2 {
        var value:Null<Vector2> = cellAutotileCoords.get(x + "," + y);
        return value != null ? value : new Vector2(0, 0);
    }

    public function set_tile_data(values:Array<Int>):Void {
        clear_all_cells();
        tileData = values.copy();

        var stride:Int = 3;
        if (values.length % 3 != 0 && values.length % 2 == 0) {
            stride = 2;
        } else if (values.length % 3 != 0) {
            Log.warning("TileMap", "tile_data length " + values.length + " is not divisible by 2 or 3");
            return;
        }

        var i:Int = 0;
        while (i + stride - 1 < values.length) {
            var packedCoord:Int = values[i];
            var id:Int = values[i + 1];
            var packedAutotileCoord:Int = stride == 3 ? values[i + 2] : 0;
            
            var cellPos:Vector2 = decode_packed_cell(packedCoord);
            var x:Int = Math.floor(cellPos.x);
            var y:Int = Math.floor(cellPos.y);
            
            var autotileCoord:Vector2 = decode_packed_cell(packedAutotileCoord);
            
            set_cell(x, y, id, autotileCoord);
            i += stride;
        }
    }

    function decode_packed_cell(cell:Int):Vector2 {
        var x:Int = cell & 0xFFFF;
        var y:Int = (cell >> 16) & 0xFFFF;
        if (x >= 0x8000) x -= 0x10000;
        if (y >= 0x8000) y -= 0x10000;
        return new Vector2(x, y);
    }

    function clear_all_cells():Void {
        for (key in cellIds.keys()) {
            dirtyCells.set(key, true);
        }
        cellIds = new Map<String, Int>();
        cellAutotileCoords = new Map<String, Vector2>();
        clear_collision();
    }

    public function world_to_map(world:Vector2):Vector2 {
        var cs:Vector2 = get_cell_size();
        return new Vector2(Math.floor(world.x / cs.x), Math.floor(world.y / cs.y));
    }

    public function map_to_world(map:Vector2):Vector2 {
        var cs:Vector2 = get_cell_size();
        return new Vector2(map.x * cs.x, map.y * cs.y);
    }

    override public function set_position(value:Vector2):Void { super.set_position(value); rebuild_collision(); }
    override public function set_rotation(value:Float):Void { super.set_rotation(value); rebuild_collision(); }
    override public function set_scale(value:Vector2):Void { super.set_scale(value); rebuild_collision(); }

    override public function _enter_tree():Void { super._enter_tree(); rebuild_collision(); }
    override public function _exit_tree():Void { clear_collision(); super._exit_tree(); }

    public function rebuild_collision():Void {
        clear_collision();
        if (!collisionEnabled || tileSet == null) return;

        for (key in cellIds.keys()) {
            var id:Null<Int> = cellIds.get(key);
            if (id == null) continue;

            var parts:Array<String> = key.split(",");
            if (parts.length != 2) continue;

            var xValue:Null<Int> = Std.parseInt(parts[0]);
            var yValue:Null<Int> = Std.parseInt(parts[1]);
            if (xValue == null || yValue == null) continue;
            
            update_cell_collision(xValue, yValue, id);
        }
    }

    function update_cell_collision(x:Int, y:Int, id:Int):Void {
        var key:String = get_collision_key(x, y);

        if (!collisionEnabled || tileSet == null) {
            if (activeCollisionKeys.exists(key)) {
                Physics2DServer.instance.remove_static_rect(key);
                activeCollisionKeys.remove(key);
            }
            return;
        }

        var tile:Null<TileData> = tileSet.get_tile(id);

        if (tile != null && tile.collides) {
            var localPosition:Vector2 = map_to_world(new Vector2(x, y));
            var globalTransform:Transform2D = get_global_transform();
            var worldPosition:Vector2 = globalTransform.xform(localPosition);

            var scale:Vector2 = globalTransform.get_scale();
            var cellSize:Vector2 = get_cell_size();

            var rect:Rect2 = Rect2.from_xywh(
                worldPosition.x, worldPosition.y,
                cellSize.x * Math.abs(scale.x), cellSize.y * Math.abs(scale.y)
            );

            Physics2DServer.instance.set_static_rect(key, rect, collisionLayer);
            activeCollisionKeys.set(key, true);
        } else {
            if (activeCollisionKeys.exists(key)) {
                Physics2DServer.instance.remove_static_rect(key);
                activeCollisionKeys.remove(key);
            }
        }
    }

    function clear_collision():Void {
        for (key in activeCollisionKeys.keys()) Physics2DServer.instance.remove_static_rect(key);
        activeCollisionKeys.clear();
    }

    function get_collision_key(x:Int, y:Int):String { return instanceId + ":" + x + "," + y; }

    override public function set_property(name:String, value:godot.tscn.TscnValue, doc:godot.tscn.TscnDocument):Bool {
        switch (name) {
            case "tile_set":
                var resource:Null<Resource> = ResourceFactory.create_resource_from_value(value, doc);
                var loadedTileSet:Null<TileSet> = Std.instance(resource, TileSet);
                if (loadedTileSet != null) { set_tile_set(loadedTileSet); return true; }
            case "cell_size": if (value.vector2Value != null) { cellSize = value.vector2Value; return true; }
            case "collision_enabled": if (value.boolValue != null) { collisionEnabled = value.boolValue; rebuild_collision(); return true; }
            case "collision_layer": if (value.intValue != null) { collisionLayer = value.intValue; rebuild_collision(); return true; }
            case "collision_mask": if (value.intValue != null) { collisionMask = value.intValue; return true; }
            case "format": if (value.intValue != null) { format = value.intValue; return true; }
            case "tile_data": if (value.poolIntArrayValue != null) { set_tile_data(value.poolIntArrayValue); return true; }
        }
        return super.set_property(name, value, doc);
    }
}
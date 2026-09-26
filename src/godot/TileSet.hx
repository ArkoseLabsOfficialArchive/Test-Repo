package godot;

class TileSet extends Resource {
	public var cellSize:Vector2;

	var tiles:Map<Int, TileData>;

	public function new() {
		super();
		cellSize = new Vector2(32, 32);
		tiles = new Map<Int, TileData>();
	}

	public function create_tile(id:Int, texture:Texture, region:Rect2, offset:Vector2 = null, collides:Bool = false, tileMode:Int = 0,
			autotileTileSize:Vector2 = null):Void {
		var data:TileData = new TileData();
		data.id = id;
		data.texture = texture;
		data.region = region;
		data.offset = offset != null ? offset : new Vector2(0, 0);
		data.collides = collides;
		data.tileMode = tileMode;
		data.autotileTileSize = autotileTileSize != null ? autotileTileSize : new Vector2(32, 32);
		tiles.set(id, data);
	}

	public function get_tile(id:Int):Null<TileData> {
		return tiles.get(id);
	}

	public function tile_collides(id:Int):Bool {
		var tile:Null<TileData> = tiles.get(id);
		return tile != null && tile.collides;
	}
}

class TileData {
	public var id:Int;
	public var texture:Null<Texture>;
	public var region:Rect2;
	public var offset:Vector2;
	public var collides:Bool;

	public var tileMode:Int; // 0 = single, 1 = auto
	public var autotileTileSize:Vector2;

	public function new() {
		id = -1;
		texture = null;
		region = Rect2.from_xywh(0, 0, 0, 0);
		offset = new Vector2(0, 0);
		collides = false;
		tileMode = 0;
		autotileTileSize = new Vector2(32, 32);
	}
}

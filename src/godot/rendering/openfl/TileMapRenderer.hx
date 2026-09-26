package godot.rendering.openfl;

import godot.TileMap;
import godot.DirtyFlag;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.Sprite;
import openfl.geom.Rectangle;

class TileMapRenderer {
	var renderer:Renderer;
	var bitmaps:Map<String, Bitmap>;

	public function new(renderer:Renderer) {
		this.renderer = renderer;
		bitmaps = new Map<String, Bitmap>();
	}

	public function create_state(map:TileMap):RenderObjectState {
		var state:RenderObjectState = new RenderObjectState();
		var container:Sprite = new Sprite();
		state.displayObject = container;
		renderer.add_world_object(container);
		return state;
	}

	public function update_if_dirty(map:TileMap, state:RenderObjectState):Void {
		if (!map.is_dirty(DirtyFlag.Visual))
			return;

		var container:Null<Sprite> = Std.instance(state.displayObject, Sprite);
		if (container == null || map.tileSet == null)
			return;

		var cellSize = map.get_cell_size();

		for (key in map.dirtyCells.keys()) {
			var parts:Array<String> = key.split(",");
			var xValue:Null<Int> = Std.parseInt(parts[0]);
			var yValue:Null<Int> = Std.parseInt(parts[1]);
			if (xValue == null || yValue == null)
				continue;

			var x:Int = xValue;
			var y:Int = yValue;
			var id:Int = map.get_cell(x, y);
			var existingBmp:Null<Bitmap> = bitmaps.get(key);

			if (id < 0) {
				if (existingBmp != null) {
					container.removeChild(existingBmp);
					bitmaps.remove(key);
				}
				continue;
			}

			var tile = map.tileSet.get_tile(id);
			if (tile == null || tile.texture == null)
				continue;

			var bitmapData:Null<BitmapData> = TextureHelper.get_native_bitmap(tile.texture);
			var sourceRect:Null<Rectangle> = TextureHelper.get_source_rect(tile.texture);
			if (bitmapData == null || sourceRect == null)
				continue;

			if (existingBmp == null) {
				existingBmp = new Bitmap();
				container.addChild(existingBmp);
				bitmaps.set(key, existingBmp);
			}

			// Base region offset within the texture
			var regionX:Float = sourceRect.x + tile.region.position.x;
			var regionY:Float = sourceRect.y + tile.region.position.y;

			// If autotile, offset by autotileCoord * autotileTileSize
			if (tile.tileMode == 1) {
				var autoCoord:Vector2 = map.get_cell_autotile_coord(x, y);
				regionX += autoCoord.x * tile.autotileTileSize.x;
				regionY += autoCoord.y * tile.autotileTileSize.y;
			}

			var drawWidth:Float = tile.tileMode == 1 ? tile.autotileTileSize.x : tile.region.size.x;
			var drawHeight:Float = tile.tileMode == 1 ? tile.autotileTileSize.y : tile.region.size.y;

			existingBmp.bitmapData = bitmapData;
			existingBmp.scrollRect = new Rectangle(regionX, regionY, drawWidth, drawHeight);

			existingBmp.x = x * cellSize.x + tile.offset.x;
			existingBmp.y = y * cellSize.y + tile.offset.y;
		}

		map.dirtyCells.clear();
		map.clear_dirty(DirtyFlag.Visual);
	}
}

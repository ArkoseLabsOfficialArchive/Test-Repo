package godot.rendering.openfl;

import godot.Panel;
import godot.StyleBoxFlat;
import godot.DirtyFlag;
import openfl.display.Sprite;

class PanelRenderer {
	var renderer:Renderer;

	public function new(renderer:Renderer) {
		this.renderer = renderer;
	}

	public function create_state(panel:Panel):RenderObjectState {
		var state:RenderObjectState = new RenderObjectState();
		var sprite:Sprite = new Sprite();
		state.displayObject = sprite;
		renderer.add_gui_object(sprite);
		return state;
	}

	public function update_if_dirty(panel:Panel, state:RenderObjectState):Void {
		var sprite:Null<Sprite> = Std.instance(state.displayObject, Sprite);
		if (sprite == null)
			return;

		var width:Float = state.lastWidth;
		var height:Float = state.lastHeight;
		if (Math.isNaN(width))
			width = panel.rectSize.x;
		if (Math.isNaN(height))
			height = panel.rectSize.y;

		var color:godot.Color = new godot.Color(0.1, 0.1, 0.1, 1.0);
		var style:Null<godot.StyleBox> = panel.get_stylebox("panel");
		var flatStyle:Null<StyleBoxFlat> = Std.instance(style, StyleBoxFlat);

		if (flatStyle != null) {
			color = flatStyle.bgColor;
		}

		sprite.graphics.clear();
		sprite.graphics.beginFill(color.to_argb32() & 0xFFFFFF, color.a);
		sprite.graphics.drawRect(0, 0, width, height);
		sprite.graphics.endFill();
	}
}

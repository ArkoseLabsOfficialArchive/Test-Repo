package godot.rendering.openfl;

import godot.VSlider;
import godot.DirtyFlag;
import openfl.display.Sprite;

class VSliderRenderer {
	var renderer:Renderer;
	var lastRatio:Float;

	public function new(renderer:Renderer) {
		this.renderer = renderer;
		lastRatio = Math.NaN;
	}

	public function create_state(slider:VSlider):RenderObjectState {
		var state:RenderObjectState = new RenderObjectState();
		var sprite:Sprite = new Sprite();

		state.displayObject = sprite;
		renderer.add_gui_object(sprite);

		return state;
	}

	public function update_if_dirty(slider:VSlider, state:RenderObjectState):Void {
		var sprite:Null<Sprite> = Std.instance(state.displayObject, Sprite);
		if (sprite == null) {
			return;
		}

		var ratio:Float = slider.get_ratio();

		var width:Float = state.lastWidth;
		var height:Float = state.lastHeight;

		if (Math.isNaN(width))
			width = 0.0;
		if (Math.isNaN(height))
			height = 0.0;

		var needsUpdate:Bool = slider.is_dirty(DirtyFlag.Visual) || slider.is_dirty(DirtyFlag.Layout) || lastRatio != ratio || Math.isNaN(lastRatio);

		if (!needsUpdate) {
			return;
		}

		var trackX:Float = width * 0.5 - 2.0;

		sprite.graphics.clear();

		sprite.graphics.beginFill(0x222222, 1.0);
		sprite.graphics.drawRect(trackX, 0.0, 4.0, height);
		sprite.graphics.endFill();

		sprite.graphics.beginFill(0xCCCCCC, 1.0);
		sprite.graphics.drawCircle(width * 0.5, height * (1.0 - ratio), 6.0);
		sprite.graphics.endFill();

		lastRatio = ratio;

		slider.clear_dirty(DirtyFlag.Visual);
		slider.clear_dirty(DirtyFlag.Layout);
	}
}

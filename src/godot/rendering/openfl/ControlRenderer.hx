package godot.rendering.openfl;

import godot.Control;
import godot.DirtyFlag;
import openfl.display.Sprite;

class ControlRenderer {
	var renderer:Renderer;

	public function new(renderer:Renderer) {
		this.renderer = renderer;
	}

	public function create_state(control:Control):RenderObjectState {
		var state:RenderObjectState = new RenderObjectState();
		var sprite:Sprite = new Sprite();
		state.displayObject = sprite;
		renderer.add_gui_object(sprite);
		return state;
	}

	public function update_transform(control:Control, state:RenderObjectState):Void {
		if (!control.is_dirty(DirtyFlag.Layout)) {
			return;
		}

		var display:Null<openfl.display.DisplayObject> = state.displayObject;
		if (display == null) {
			return;
		}

		var globalPosition:godot.Vector2 = control.get_global_position();

		if (state.lastX != globalPosition.x) {
			display.x = globalPosition.x;
			state.lastX = globalPosition.x;
		}

		if (state.lastY != globalPosition.y) {
			display.y = globalPosition.y;
			state.lastY = globalPosition.y;
		}

		state.lastWidth = control.rectSize.x;
		state.lastHeight = control.rectSize.y;

		control.clear_dirty(DirtyFlag.Layout);
	}
}

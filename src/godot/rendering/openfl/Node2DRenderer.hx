package godot.rendering.openfl;

import godot.Node2D;
import godot.Transform2D;
import godot.Vector2;
import godot.DirtyFlag;

class Node2DRenderer {
	var renderer:Renderer;

	public function new(renderer:Renderer) {
		this.renderer = renderer;
	}

	public function create_state(node:Node2D):RenderObjectState {
		var state:RenderObjectState = new RenderObjectState();
		var container:openfl.display.Sprite = new openfl.display.Sprite();

		state.displayObject = container;
		renderer.add_world_object(container);

		return state;
	}

	public function update_transform(node:Node2D, state:RenderObjectState):Void {
		var display:Null<openfl.display.DisplayObject> = state.displayObject;
		if (display == null) {
			return;
		}

		var needsInitialSync:Bool = Math.isNaN(state.lastX) || Math.isNaN(state.lastY);

		if (!node.is_dirty(DirtyFlag.Transform) && !needsInitialSync) {
			return;
		}

		var global:Transform2D = node.get_global_transform();

		var x:Float = global.origin.x;
		var y:Float = global.origin.y;
		var rotationDegrees:Float = global.get_rotation() * 180.0 / Math.PI;
		var scale:Vector2 = global.get_scale();

		if (state.lastX != x) {
			display.x = x;
			state.lastX = x;
		}

		if (state.lastY != y) {
			display.y = y;
			state.lastY = y;
		}

		if (state.lastRotation != rotationDegrees) {
			display.rotation = rotationDegrees;
			state.lastRotation = rotationDegrees;
		}

		if (state.lastScaleX != scale.x) {
			display.scaleX = scale.x;
			state.lastScaleX = scale.x;
		}

		if (state.lastScaleY != scale.y) {
			display.scaleY = scale.y;
			state.lastScaleY = scale.y;
		}

		node.clear_dirty(DirtyFlag.Transform);
	}
}

package godot;

class VisibilityNotifier2D extends Node2D {
	public var rect:Rect2;

	var isOnScreen:Bool;

	public function new() {
		super();

		rect = Rect2.from_xywh(-10.0, -10.0, 20.0, 20.0);
		isOnScreen = false;

		add_user_signal("screen_entered");
		add_user_signal("screen_exited");

		set_process(true);
	}

	override public function _process(delta:Float):Void {
		var camera:Null<Camera2D> = Camera2D.currentCamera;
		if (camera == null || camera.tree == null || camera.tree.root == null) {
			return;
		}

		var viewportSize:Vector2 = camera.tree.root.size;
		var visibleWorldRect:Rect2 = camera.get_viewport_world_rect(viewportSize);

		var globalPosition:Vector2 = get_global_position();

		var globalRect:Rect2 = Rect2.from_xywh(globalPosition.x + rect.position.x, globalPosition.y + rect.position.y, rect.size.x, rect.size.y);

		var nowVisible:Bool = visibleWorldRect.intersects(globalRect);

		if (nowVisible != isOnScreen) {
			isOnScreen = nowVisible;

			if (isOnScreen) {
				emit_signal("screen_entered", []);
			} else {
				emit_signal("screen_exited", []);
			}
		}
	}

	public function is_on_screen():Bool {
		return isOnScreen;
	}

	override public function set_property(name:String, value:godot.tscn.TscnValue, doc:godot.tscn.TscnDocument):Bool {
		if (name == "rect" && value.rect2Value != null) {
			rect = value.rect2Value;
			return true;
		}

		return super.set_property(name, value, doc);
	}
}

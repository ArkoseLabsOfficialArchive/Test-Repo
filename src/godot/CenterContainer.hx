package godot;

class CenterContainer extends Control {
	public function new() {
		super();
		mouseFilter = MouseFilter.Pass;
	}

	override public function arrange_children():Void {
		for (child in get_children()) {
			var control:Null<Control> = Std.instance(child, Control);
			if (control == null || !control.visible) {
				continue;
			}

			var size:Vector2 = control.get_combined_minimum_size();

			if (size.x <= 0.0) {
				size.x = control.rectSize.x;
			}

			if (size.y <= 0.0) {
				size.y = control.rectSize.y;
			}

			var x:Float = (rectSize.x - size.x) * 0.5;
			var y:Float = (rectSize.y - size.y) * 0.5;

			if (x < 0.0)
				x = 0.0;
			if (y < 0.0)
				y = 0.0;

			control.set_position_no_propagate(new Vector2(x, y));
			control.set_size_no_propagate(size);
		}
	}
}

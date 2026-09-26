package godot;

class Node2D extends CanvasItem {
	public var position:Vector2;
	public var rotation:Float;
	public var scale:Vector2;

	var localTransform:Transform2D;
	var globalTransform:Transform2D;
	var globalDirty:Bool;

	public function new() {
		super();
		position = new Vector2(0, 0);
		rotation = 0.0;
		scale = new Vector2(1, 1);
		localTransform = Transform2D.identity();
		globalTransform = Transform2D.identity();
		globalDirty = true;
		update_local_transform();
	}

	public function set_position(value:Vector2):Void {
		position = value;
		update_local_transform();
		mark_dirty(DirtyFlag.Transform);
		mark_children_global_dirty();
	}

	public function set_rotation(value:Float):Void {
		rotation = value;
		update_local_transform();
		mark_dirty(DirtyFlag.Transform);
		mark_children_global_dirty();
	}

	public function set_scale(value:Vector2):Void {
		scale = value;
		update_local_transform();
		mark_dirty(DirtyFlag.Transform);
		mark_children_global_dirty();
	}

	public function get_position():Vector2 {
		return position.copy();
	}

	public function get_rotation():Float {
		return rotation;
	}

	public function get_scale():Vector2 {
		return scale.copy();
	}

	function update_local_transform():Void {
		localTransform = Transform2D.from_rotation_translation_scale(rotation, position, scale);
	}

	public function get_transform():Transform2D {
		return localTransform.copy();
	}

	public function get_global_transform():Transform2D {
		if (!globalDirty) {
			return globalTransform.copy();
		}

		var parent2D:Null<Node2D> = Std.instance(parent, Node2D);
		if (parent2D == null) {
			globalTransform = localTransform.copy();
		} else {
			globalTransform = parent2D.get_global_transform().multiply(localTransform);
		}

		globalDirty = false;
		return globalTransform.copy();
	}

	public function get_global_position():Vector2 {
		return get_global_transform().origin;
	}

	public function set_global_position(value:Vector2):Void {
		var parent2D:Null<Node2D> = Std.instance(parent, Node2D);
		if (parent2D == null) {
			set_position(value);
			return;
		}

		var parentGlobal:Transform2D = parent2D.get_global_transform();
		var localPos:Vector2 = parentGlobal.xform_inv(value);
		set_position(localPos);
	}

	public function get_global_rotation():Float {
		return get_global_transform().get_rotation();
	}

	public function translate(offset:Vector2):Void {
		set_position(position.add(offset));
	}

	public function global_translate(offset:Vector2):Void {
		set_global_position(get_global_position().add(offset));
	}

	function mark_children_global_dirty():Void {
		globalDirty = true;
		for (child in get_children()) {
			var child2D:Null<Node2D> = Std.instance(child, Node2D);
			if (child2D != null) {
				child2D.mark_children_global_dirty();
			}
		}
	}

	override public function set_property(name:String, value:godot.tscn.TscnValue, doc:godot.tscn.TscnDocument):Bool {
		switch (name) {
			case "position":
				if (value.vector2Value != null) {
					set_position(value.vector2Value);
					return true;
				}

			case "rotation":
				if (value.floatValue != null) {
					set_rotation(value.floatValue);
					return true;
				}

			case "rotation_degrees":
				if (value.floatValue != null) {
					set_rotation(value.floatValue * Math.PI / 180.0);
					return true;
				}

			case "scale":
				if (value.vector2Value != null) {
					set_scale(value.vector2Value);
					return true;
				}

			case "global_position":
				if (value.vector2Value != null) {
					set_global_position(value.vector2Value);
					return true;
				}
		}

		return super.set_property(name, value, doc);
	}
}

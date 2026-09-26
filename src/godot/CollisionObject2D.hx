package godot;

class CollisionObject2D extends Node2D {
	public var collisionLayer:Int;
	public var collisionMask:Int;

	public function new() {
		super();
		collisionLayer = 1;
		collisionMask = 1;
	}

	override public function _enter_tree():Void {
		super._enter_tree();
		Physics2DServer.instance.register_object(this);
	}

	override public function _exit_tree():Void {
		super._exit_tree();
		Physics2DServer.instance.unregister_object(this);
	}

	public function get_world_rect():Rect2 {
		var shapeNode:Null<CollisionShape2D> = Std.instance(get_child(0), CollisionShape2D);
		if (shapeNode == null || shapeNode.shape == null) {
			return Rect2.from_xywh(0, 0, 0, 0);
		}

		var pos:Vector2 = get_global_position();
		var localRect:Rect2 = shapeNode.shape.get_rect();

		return Rect2.from_xywh(pos.x + localRect.position.x, pos.y + localRect.position.y, localRect.size.x, localRect.size.y);
	}
}

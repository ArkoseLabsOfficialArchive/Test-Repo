package godot.physics;

import godot.Rect2;
import godot.Vector2;

class CollisionSolver2D {
	public static function rects_overlap(a:Rect2, b:Rect2):Bool {
		return a.intersects(b);
	}

	public static function resolve_rect_motion(mover:Rect2, target:Rect2, motion:Vector2):CollisionResult2D {
		var result:CollisionResult2D = new CollisionResult2D();

		var next:Rect2 = Rect2.from_xywh(mover.position.x + motion.x, mover.position.y + motion.y, mover.size.x, mover.size.y);

		if (!next.intersects(target)) {
			return result;
		}

		result.collided = true;

		var overlapX:Float = Math.min(next.get_end().x, target.get_end().x) - Math.max(next.position.x, target.position.x);

		var overlapY:Float = Math.min(next.get_end().y, target.get_end().y) - Math.max(next.position.y, target.position.y);

		if (overlapX < overlapY) {
			if (motion.x > 0.0) {
				result.normal = new Vector2(-1.0, 0.0);
				result.remainder = new Vector2(overlapX, motion.y);
			} else {
				result.normal = new Vector2(1.0, 0.0);
				result.remainder = new Vector2(-overlapX, motion.y);
			}
		} else {
			if (motion.y > 0.0) {
				result.normal = new Vector2(0.0, -1.0);
				result.remainder = new Vector2(motion.x, overlapY);
			} else {
				result.normal = new Vector2(0.0, 1.0);
				result.remainder = new Vector2(motion.x, -overlapY);
			}
		}

		return result;
	}
}

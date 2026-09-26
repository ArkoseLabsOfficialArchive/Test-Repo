package godot.physics;

import godot.KinematicBody2D;
import godot.Physics2DServer;
import godot.Vector2;

class PhysicsMotionCalculator {
	public static function move_and_slide(body:KinematicBody2D, velocity:Vector2, delta:Float, upDirection:Vector2):Vector2 {
		var motion:Vector2 = velocity.scale(delta);
		var remaining:Vector2 = motion.copy();

		var onFloor:Bool = false;
		var onWall:Bool = false;
		var onCeiling:Bool = false;

		var iterations:Int = 4;
		var i:Int = 0;

		while (i < iterations && !remaining.is_zero_approx()) {
			var collision:CollisionResult2D = Physics2DServer.instance.move_body(body, remaining);

			if (!collision.collided) {
				body.translate(remaining);
				remaining = new Vector2(0, 0);
				break;
			}

			var normal:Vector2 = collision.normal.normalized();

			if (normal.dot(upDirection) > 0.7) {
				onFloor = true;
			} else if (normal.dot(upDirection.scale(-1.0)) > 0.7) {
				onCeiling = true;
			} else {
				onWall = true;
			}

			var slide:Vector2 = remaining.subtract(normal.scale(remaining.dot(normal)));

			body.translate(remaining.subtract(collision.remainder));
			remaining = slide;

			i++;
		}

		body.collisionState.onFloor = onFloor;
		body.collisionState.onWall = onWall;
		body.collisionState.onCeiling = onCeiling;

		return velocity;
	}
}

package godot;

import godot.physics.CollisionResult2D;
import godot.physics.CollisionSolver2D;

class Physics2DServer {
	public static var instance:Physics2DServer = new Physics2DServer();

	var objects:Array<CollisionObject2D>;
	var staticRects:Map<String, StaticRectCollider>;

	function new() {
		objects = [];
		staticRects = new Map<String, StaticRectCollider>();
	}

	public function register_object(obj:CollisionObject2D):Void {
		if (objects.indexOf(obj) < 0) {
			objects.push(obj);
		}
	}

	public function unregister_object(obj:CollisionObject2D):Void {
		objects.remove(obj);
	}

	public function set_static_rect(key:String, rect:Rect2, layer:Int):Void {
		staticRects.set(key, new StaticRectCollider(key, rect, layer));
	}

	public function remove_static_rect(key:String):Void {
		staticRects.remove(key);
	}

	public function clear_static_rects():Void {
		staticRects.clear();
	}

	public function move_body(body:KinematicBody2D, motion:Vector2):CollisionResult2D {
		var moverRect:Rect2 = body.get_world_rect();

		var best:Null<CollisionResult2D> = null;
		var bestDistance:Float = Math.POSITIVE_INFINITY;

		for (other in objects) {
			if (other.instanceId == body.instanceId) {
				continue;
			}

			var staticBody:Null<StaticBody2D> = Std.instance(other, StaticBody2D);
			if (staticBody == null) {
				continue;
			}

			var result:CollisionResult2D = CollisionSolver2D.resolve_rect_motion(moverRect, other.get_world_rect(), motion);

			if (result.collided) {
				var dist:Float = result.remainder.length_squared();

				if (dist < bestDistance) {
					best = result;
					bestDistance = dist;
				}
			}
		}

		for (collider in staticRects) {
			var result:CollisionResult2D = CollisionSolver2D.resolve_rect_motion(moverRect, collider.rect, motion);

			if (result.collided) {
				var dist:Float = result.remainder.length_squared();

				if (dist < bestDistance) {
					best = result;
					bestDistance = dist;
				}
			}
		}

		if (best != null) {
			return best;
		}

		return new CollisionResult2D();
	}

	public function get_overlapping_bodies(area:Area2D):Array<PhysicsBody2D> {
		var out:Array<PhysicsBody2D> = [];
		var areaRect:Rect2 = area.get_world_rect();

		for (obj in objects) {
			var body:Null<PhysicsBody2D> = Std.instance(obj, PhysicsBody2D);
			if (body == null || body.instanceId == area.instanceId) {
				continue;
			}

			var bodyRect:Rect2 = body.get_world_rect();

			if (areaRect.intersects(bodyRect)) {
				out.push(body);
			}
		}

		return out;
	}

	public function raycast(from:Vector2, to:Vector2, collisionMask:Int):RayCastResult {
		var result:RayCastResult = new RayCastResult();

		var dir:Vector2 = to.subtract(from);
		var maxDist:Float = dir.length();

		if (maxDist == 0.0) {
			return result;
		}

		var dirNorm:Vector2 = dir.normalized();
		var closestDist:Float = maxDist;

		for (obj in objects) {
			if ((obj.collisionLayer & collisionMask) == 0) {
				continue;
			}

			var rect:Rect2 = obj.get_world_rect();
			var hit:Float = ray_vs_rect(from, dirNorm, maxDist, rect);

			if (hit > 0.0 && hit < closestDist) {
				closestDist = hit;
				result.collided = true;
				result.position = from.add(dirNorm.scale(hit));
				result.normal = get_rect_normal(rect, result.position);
				result.collider = obj;
			}
		}

		for (collider in staticRects) {
			if ((collider.layer & collisionMask) == 0) {
				continue;
			}

			var hit:Float = ray_vs_rect(from, dirNorm, maxDist, collider.rect);

			if (hit > 0.0 && hit < closestDist) {
				closestDist = hit;
				result.collided = true;
				result.position = from.add(dirNorm.scale(hit));
				result.normal = get_rect_normal(collider.rect, result.position);
				result.collider = null;
			}
		}

		return result;
	}

	function ray_vs_rect(origin:Vector2, dir:Vector2, maxDist:Float, rect:Rect2):Float {
		var tmin:Float = (rect.position.x - origin.x) / dir.x;
		var tmax:Float = (rect.get_end().x - origin.x) / dir.x;

		if (tmin > tmax) {
			var temp:Float = tmin;
			tmin = tmax;
			tmax = temp;
		}

		var tymin:Float = (rect.position.y - origin.y) / dir.y;
		var tymax:Float = (rect.get_end().y - origin.y) / dir.y;

		if (tymin > tymax) {
			var temp:Float = tymin;
			tymin = tymax;
			tymax = temp;
		}

		if ((tmin > tymax) || (tymin > tmax)) {
			return -1.0;
		}

		if (tymin > tmin) {
			tmin = tymin;
		}

		if (tymax < tmax) {
			tmax = tymax;
		}

		if (tmin < 0.0) {
			if (tmax < 0.0) {
				return -1.0;
			}

			tmin = tmax;
		}

		return tmin > maxDist ? -1.0 : tmin;
	}

	function get_rect_normal(rect:Rect2, point:Vector2):Vector2 {
		var center:Vector2 = rect.position.add(rect.size.scale(0.5));
		var diff:Vector2 = point.subtract(center);
		var halfSize:Vector2 = rect.size.scale(0.5);

		if (Math.abs(diff.x / halfSize.x) > Math.abs(diff.y / halfSize.y)) {
			return new Vector2(diff.x > 0 ? 1 : -1, 0);
		}

		return new Vector2(0, diff.y > 0 ? 1 : -1);
	}
}

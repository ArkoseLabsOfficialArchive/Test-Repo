package godot;

import godot.physics.PhysicsMotionCalculator;
import godot.physics.CollisionResult2D;

class KinematicCollisionState {
    public var onFloor:Bool;
    public var onWall:Bool;
    public var onCeiling:Bool;

    public function new() {
        onFloor = false;
        onWall = false;
        onCeiling = false;
    }
}

class KinematicBody2D extends PhysicsBody2D {
    public var collisionState:KinematicCollisionState;

    public function new() {
        super();
        collisionState = new KinematicCollisionState();
    }

    public function move_and_slide(velocity:Vector2, upDirection:Vector2 = null):Vector2 {
        var up:Vector2 = upDirection != null ? upDirection : new Vector2(0, -1);
        var delta:Float = EngineTime.physics_delta;
        return PhysicsMotionCalculator.move_and_slide(this, velocity, delta, up);
    }

    public function move_and_collide(motion:Vector2):CollisionResult2D {
        var result:CollisionResult2D = Physics2DServer.instance.move_body(this, motion);
        if (!result.collided) {
            translate(motion);
        } else {
            translate(motion.subtract(result.remainder));
        }
        return result;
    }

    public function is_on_floor():Bool {
        return collisionState.onFloor;
    }

    public function is_on_wall():Bool {
        return collisionState.onWall;
    }

    public function is_on_ceiling():Bool {
        return collisionState.onCeiling;
    }
}
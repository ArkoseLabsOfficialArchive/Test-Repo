package godot.rendering.openfl;

import godot.CPUParticles2D;
import godot.ParticleData;
import godot.DirtyFlag;
import openfl.display.Sprite;

class Particles2DRenderer {
	var renderer:Renderer;

	public function new(renderer:Renderer) {
		this.renderer = renderer;
	}

	public function create_state(particles:CPUParticles2D):RenderObjectState {
		var state:RenderObjectState = new RenderObjectState();
		var sprite:Sprite = new Sprite();
		state.displayObject = sprite;
		renderer.add_world_object(sprite);
		return state;
	}

	public function update_if_dirty(particles:CPUParticles2D, state:RenderObjectState):Void {
		if (!particles.is_dirty(DirtyFlag.Visual)) {
			return;
		}

		var sprite:Null<Sprite> = Std.instance(state.displayObject, Sprite);
		if (sprite == null) {
			return;
		}

		sprite.graphics.clear();

		var colorInt:Int = particles.color.to_argb32() & 0xFFFFFF;
		var alpha:Float = particles.color.a;

		for (particle in particles.particles) {
			if (!particle.active) {
				continue;
			}

			sprite.graphics.beginFill(colorInt, alpha);
			sprite.graphics.drawCircle(particle.position.x, particle.position.y, particles.particleSize);
			sprite.graphics.endFill();
		}

		particles.clear_dirty(DirtyFlag.Visual);
	}
}

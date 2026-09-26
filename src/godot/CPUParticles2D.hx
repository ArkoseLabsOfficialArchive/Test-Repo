package godot;

class CPUParticles2D extends Particles2D {
	public var gravity:Vector2;
	public var initialVelocityMin:Float;
	public var initialVelocityMax:Float;
	public var spreadDegrees:Float;
	public var particleSize:Float;
	public var color:Color;

	public var particles:Array<ParticleData>;

	var spawnAccumulator:Float;

	public function new() {
		super();

		gravity = new Vector2(0.0, 0.0);
		initialVelocityMin = 20.0;
		initialVelocityMax = 60.0;
		spreadDegrees = 180.0;
		particleSize = 2.0;
		color = Color.white();

		particles = [];
		spawnAccumulator = 0.0;

		set_process(true);
	}

	override public function _process(delta:Float):Void {
		sync_particle_pool();

		if (emitting) {
			spawnAccumulator += delta * (amount / lifetime);

			while (spawnAccumulator >= 1.0) {
				spawn_one();
				spawnAccumulator -= 1.0;
			}
		}

		var anyActive:Bool = false;

		for (particle in particles) {
			if (!particle.active) {
				continue;
			}

			particle.life -= delta;

			if (particle.life <= 0.0) {
				particle.reset();
				continue;
			}

			particle.velocity = particle.velocity.add(gravity.scale(delta));
			particle.position = particle.position.add(particle.velocity.scale(delta));

			anyActive = true;
		}

		if (anyActive || emitting) {
			mark_dirty(DirtyFlag.Visual);
		}
	}

	function sync_particle_pool():Void {
		while (particles.length < amount) {
			particles.push(new ParticleData());
		}

		while (particles.length > amount) {
			particles.pop();
		}
	}

	function spawn_one():Void {
		for (particle in particles) {
			if (particle.active) {
				continue;
			}

			particle.active = true;
			particle.position.set(0.0, 0.0);
			particle.life = lifetime;

			var angle:Float = Math.random() * spreadDegrees * Math.PI / 180.0;
			var speed:Float = initialVelocityMin + Math.random() * (initialVelocityMax - initialVelocityMin);

			particle.velocity = new Vector2(Math.cos(angle) * speed, Math.sin(angle) * speed);

			return;
		}
	}

	override public function set_property(name:String, value:godot.tscn.TscnValue, doc:godot.tscn.TscnDocument):Bool {
		switch (name) {
			case "gravity":
				if (value.vector2Value != null) {
					gravity = value.vector2Value;
					return true;
				}

			case "initial_velocity_min":
				if (value.floatValue != null) {
					initialVelocityMin = value.floatValue;
					return true;
				}

			case "initial_velocity_max":
				if (value.floatValue != null) {
					initialVelocityMax = value.floatValue;
					return true;
				}

			case "spread":
				if (value.floatValue != null) {
					spreadDegrees = value.floatValue;
					return true;
				}

			case "particle_size":
				if (value.floatValue != null) {
					particleSize = value.floatValue;
					return true;
				}

			case "color":
				if (value.colorValue != null) {
					color = value.colorValue;
					return true;
				}
		}

		return super.set_property(name, value, doc);
	}
}

package godot;

import godot.SpriteFrames;

class AnimatedSprite extends Node2D {
	public var frames:Null<SpriteFrames>;
	public var animation:String;
	public var frame:Int;
	public var playing:Bool;
	public var speedScale:Float;
	public var centered:Bool;
	public var flipH:Bool;
	public var flipV:Bool;

	var elapsedTime:Float;

	public function new() {
		super();
		frames = null;
		animation = "default";
		frame = 0;
		playing = false;
		speedScale = 1.0;
		centered = true;
		flipH = false;
		flipV = false;
		elapsedTime = 0.0;

		set_process(true);
	}

	public function set_sprite_frames(value:Null<SpriteFrames>):Void {
		frames = value;
		frame = 0;
		elapsedTime = 0.0;
		mark_dirty(DirtyFlag.Texture);
	}

	public function play(name:String = ""):Void {
		if (name.length > 0) {
			animation = name;
		}
		playing = true;
	}

	public function stop():Void {
		playing = false;
	}

	public function get_current_texture():Null<Texture> {
		if (frames == null) {
			return null;
		}
		return frames.get_frame_texture(animation, frame);
	}

	override public function _process(delta:Float):Void {
		if (!playing || frames == null) {
			return;
		}

		var anim:Null<SpriteFrameAnimation> = frames.get_animation(animation);
		if (anim == null || anim.frames.length == 0) {
			return;
		}

		elapsedTime += delta * speedScale;

		var frameDuration:Float = 1.0 / anim.speed;
		if (elapsedTime >= frameDuration) {
			elapsedTime -= frameDuration;
			advance_frame(anim);
		}
	}

	function advance_frame(anim:SpriteFrameAnimation):Void {
		var next:Int = frame + 1;

		if (next >= anim.frames.length) {
			if (anim.loop) {
				next = 0;
			} else {
				next = anim.frames.length - 1;
				playing = false;
			}
		}

		if (next != frame) {
			frame = next;
			mark_dirty(DirtyFlag.Frame);
			emit_signal("frame_changed", [frame]);
		}
	}

	override public function set_property(name:String, value:godot.tscn.TscnValue, doc:godot.tscn.TscnDocument):Bool {
		switch (name) {
			case "frames":
				var resource:Null<Resource> = ResourceFactory.create_resource_from_value(value, doc);
				var spriteFrames:Null<SpriteFrames> = Std.instance(resource, SpriteFrames);

				if (spriteFrames != null) {
					set_sprite_frames(spriteFrames);
					return true;
				}

			case "animation":
				if (value.stringValue != null) {
					animation = value.stringValue;
					return true;
				}

			case "playing":
				if (value.boolValue != null) {
					playing = value.boolValue;
					return true;
				}

			case "frame":
				if (value.intValue != null) {
					frame = value.intValue;
					return true;
				}
		}

		return super.set_property(name, value, doc);
	}
}

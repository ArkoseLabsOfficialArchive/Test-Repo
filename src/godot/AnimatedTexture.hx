package godot;

class AnimatedTextureFrame {
	public var texture:Null<Texture>;
	public var delay:Float;

	public function new(texture:Null<Texture> = null, delay:Float = 1.0) {
		this.texture = texture;
		this.delay = delay;
	}
}

class AnimatedTexture extends Texture {
	public var frames:Array<AnimatedTextureFrame>;
	public var fps:Float;
	public var currentFrame:Int;

	var elapsed:Float;

	public function new() {
		super();

		frames = [];
		fps = 1.0;
		currentFrame = 0;
		elapsed = 0.0;

		width = 0;
		height = 0;
	}

	public function add_frame(texture:Null<Texture>, delay:Float = 1.0):Void {
		frames.push(new AnimatedTextureFrame(texture, delay));

		if (frames.length == 1 && texture != null) {
			width = texture.width;
			height = texture.height;
		}
	}

	public function get_current_texture():Null<Texture> {
		if (frames.length == 0) {
			return null;
		}

		if (currentFrame < 0 || currentFrame >= frames.length) {
			currentFrame = 0;
		}

		return frames[currentFrame].texture;
	}

	public function update(delta:Float):Bool {
		if (frames.length <= 1) {
			return false;
		}

		elapsed += delta;

		var delay:Float = frames[currentFrame].delay;

		if (delay <= 0.0) {
			delay = fps > 0.0 ? 1.0 / fps : 1.0;
		}

		if (elapsed >= delay) {
			elapsed -= delay;
			currentFrame++;

			if (currentFrame >= frames.length) {
				currentFrame = 0;
			}

			var tex:Null<Texture> = get_current_texture();
			if (tex != null) {
				width = tex.width;
				height = tex.height;
			}

			return true;
		}

		return false;
	}
}

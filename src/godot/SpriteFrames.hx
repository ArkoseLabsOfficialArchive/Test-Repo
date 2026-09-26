package godot;

class SpriteFrameAnimation {
    public var name:String;
    public var frames:Array<Texture>;
    public var speed:Float;
    public var loop:Bool;

    public function new(name:String, speed:Float, loop:Bool) {
        this.name = name;
        this.frames = [];
        this.speed = speed;
        this.loop = loop;
    }
}

class SpriteFrames extends Resource {
    var animations:Map<String, SpriteFrameAnimation>;

    public function new() {
        super();
        animations = new Map<String, SpriteFrameAnimation>();
        add_animation("default", 5.0, true);
    }

    public function add_animation(name:String, speed:Float, loop:Bool):Void {
        animations.set(name, new SpriteFrameAnimation(name, speed, loop));
    }

    public function add_frame(animation:String, texture:Texture):Void {
        var anim:Null<SpriteFrameAnimation> = animations.get(animation);
        if (anim != null) {
            anim.frames.push(texture);
        }
    }

    public function get_animation(name:String):Null<SpriteFrameAnimation> {
        return animations.get(name);
    }

    public function has_animation(name:String):Bool {
        return animations.exists(name);
    }

    public function get_frame_count(animation:String):Int {
        var anim:Null<SpriteFrameAnimation> = animations.get(animation);
        return anim != null ? anim.frames.length : 0;
    }

    public function get_frame_texture(animation:String, index:Int):Null<Texture> {
        var anim:Null<SpriteFrameAnimation> = animations.get(animation);
        if (anim == null) {
            return null;
        }
        if (index < 0 || index >= anim.frames.length) {
            return null;
        }
        return anim.frames[index];
    }
}
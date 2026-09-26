package godot;

class AudioStreamPlayer extends Node {
    public var stream:Null<AudioStream>;
    public var volumeDb:Float;
    public var pitchScale:Float;
    public var autoplay:Bool;
    public var playing:Bool;

    var channel:Null<openfl.media.SoundChannel>;

    public function new() {
        super();
        stream = null;
        volumeDb = 0.0;
        pitchScale = 1.0;
        autoplay = false;
        playing = false;
        channel = null;
    }

    public function play():Void {
        if (stream == null || stream.sound == null) {
            return;
        }

        stop();

        var transform:openfl.media.SoundTransform = new openfl.media.SoundTransform(linear_volume());
        channel = stream.sound.play(0, 0, transform);
        playing = true;
    }

    public function stop():Void {
        if (channel != null) {
            channel.stop();
            channel = null;
        }
        playing = false;
    }

    public function is_playing():Bool {
        return playing;
    }

    function linear_volume():Float {
        return Math.pow(10.0, volumeDb / 20.0);
    }

    override public function _enter_tree():Void {
        super._enter_tree();
        if (autoplay) {
            play();
        }
    }

    override public function _exit_tree():Void {
        stop();
        super._exit_tree();
    }
}
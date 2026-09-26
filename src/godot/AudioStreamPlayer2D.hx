package godot;

class AudioStreamPlayer2D extends Node2D {
    public var stream:Null<AudioStream>;
    public var volumeDb:Float;
    public var playing:Bool;

    var channel:Null<openfl.media.SoundChannel>;

    public function new() {
        super();
        stream = null;
        volumeDb = 0.0;
        playing = false;
        channel = null;
    }

    public function play():Void {
        if (stream == null || stream.sound == null) {
            return;
        }

        stop();

        var transform:openfl.media.SoundTransform = new openfl.media.SoundTransform(Math.pow(10.0, volumeDb / 20.0));
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
}
package godot;

class AtlasTexture extends Texture {
    public var atlas:Null<Texture>;
    public var region:Rect2;

    public function new() {
        super();
        atlas = null;
        region = Rect2.from_xywh(0, 0, 0, 0);
    }

    public function setup(atlasTexture:Texture, rect:Rect2):Void {
        atlas = atlasTexture;
        region = rect;
        width = Math.floor(rect.size.x);
        height = Math.floor(rect.size.y);
    }
}
package godot;

class Rect2 {
    public var position:Vector2;
    public var size:Vector2;

    public function new(position:Vector2, size:Vector2) {
        this.position = position;
        this.size = size;
    }

    public static function from_xywh(x:Float, y:Float, w:Float, h:Float):Rect2 {
        return new Rect2(new Vector2(x, y), new Vector2(w, h));
    }

    public function get_end():Vector2 {
        return new Vector2(position.x + size.x, position.y + size.y);
    }

    public function has_point(point:Vector2):Bool {
        return point.x >= position.x &&
               point.y >= position.y &&
               point.x < position.x + size.x &&
               point.y < position.y + size.y;
    }

    public function has_no_area():Bool {
        return size.x <= 0.0 || size.y <= 0.0;
    }

    public function intersects(other:Rect2):Bool {
        return position.x < other.position.x + other.size.x &&
               other.position.x < position.x + size.x &&
               position.y < other.position.y + other.size.y &&
               other.position.y < position.y + size.y;
    }

    public function encloses(other:Rect2):Bool {
        return other.position.x >= position.x &&
               other.position.y >= position.y &&
               other.get_end().x <= get_end().x &&
               other.get_end().y <= get_end().y;
    }

    public function merge(other:Rect2):Rect2 {
        var minX:Float = Math.min(position.x, other.position.x);
        var minY:Float = Math.min(position.y, other.position.y);
        var maxX:Float = Math.max(get_end().x, other.get_end().x);
        var maxY:Float = Math.max(get_end().y, other.get_end().y);
        return Rect2.from_xywh(minX, minY, maxX - minX, maxY - minY);
    }

    public function grow(amount:Float):Rect2 {
        return Rect2.from_xywh(
            position.x - amount,
            position.y - amount,
            size.x + amount * 2.0,
            size.y + amount * 2.0
        );
    }

    public function expand(point:Vector2):Rect2 {
        var minX:Float = Math.min(position.x, point.x);
        var minY:Float = Math.min(position.y, point.y);
        var maxX:Float = Math.max(get_end().x, point.x);
        var maxY:Float = Math.max(get_end().y, point.y);
        return Rect2.from_xywh(minX, minY, maxX - minX, maxY - minY);
    }

    public function intersection(other:Rect2):Null<Rect2> {
        if (!intersects(other)) {
            return null;
        }

        var minX:Float = Math.max(position.x, other.position.x);
        var minY:Float = Math.max(position.y, other.position.y);
        var maxX:Float = Math.min(get_end().x, other.get_end().x);
        var maxY:Float = Math.min(get_end().y, other.get_end().y);

        return Rect2.from_xywh(minX, minY, maxX - minX, maxY - minY);
    }

    public function copy():Rect2 {
        return new Rect2(position.copy(), size.copy());
    }

    public function toString():String {
        return "[pos=" + position.toString() + ", size=" + size.toString() + "]";
    }
}
package godot;

class Gradient extends Resource {
    public var offsets:Array<Float>;
    public var colors:Array<Color>;

    public function new() {
        super();

        offsets = [0.0, 1.0];
        colors = [Color.black(), Color.white()];
    }

    public function set_data(newOffsets:Array<Float>, newColors:Array<Color>):Void {
        offsets = newOffsets.copy();
        colors = newColors.copy();
    }

    public function add_point(offset:Float, color:Color):Void {
        var index:Int = 0;

        while (index < offsets.length && offsets[index] < offset) {
            index++;
        }

        offsets.insert(index, offset);
        colors.insert(index, color.copy());
    }

    public function sample(t:Float):Color {
        if (colors.length == 0) {
            return Color.white();
        }

        if (colors.length == 1) {
            return colors[0].copy();
        }

        if (t <= offsets[0]) {
            return colors[0].copy();
        }

        var last:Int = offsets.length - 1;

        if (t >= offsets[last]) {
            return colors[last].copy();
        }

        var i:Int = 0;

        while (i < last) {
            var a:Float = offsets[i];
            var b:Float = offsets[i + 1];

            if (t >= a && t <= b) {
                var range:Float = b - a;

                if (range <= 0.0) {
                    return colors[i].copy();
                }

                var localT:Float = (t - a) / range;
                return colors[i].linear_interpolate(colors[i + 1], localT);
            }

            i++;
        }

        return colors[last].copy();
    }
}
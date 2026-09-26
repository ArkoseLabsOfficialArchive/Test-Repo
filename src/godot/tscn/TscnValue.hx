package godot.tscn;

enum TscnValueType {
	TNull;
	TBool;
	TInt;
	TFloat;
	TString;
	TVector2;
	TVector3;
	TRect2;
	TColor;
	TNodePath;
	TExtResource;
	TSubResource;
	TArray;
	TDictionary;
	TPoolByteArray;
	TPoolIntArray;
	TPoolRealArray;
	TPoolStringArray;
	TPoolVector2Array;
	TPoolVector3Array;
	TPoolColorArray;
}

class TscnValue {
	public var type:TscnValueType;

	public var boolValue:Null<Bool>;
	public var intValue:Null<Int>;
	public var floatValue:Null<Float>;
	public var stringValue:Null<String>;

	public var vector2Value:Null<godot.Vector2>;
	public var vector3Value:Null<godot.Vector3>;
	public var rect2Value:Null<godot.Rect2>;
	public var colorValue:Null<godot.Color>;
	public var nodePathValue:Null<godot.NodePath>;

	public var resourceRef:Null<String>;

	public var arrayValue:Null<Array<TscnValue>>;
	public var dictionaryValue:Null<Map<String, TscnValue>>;

	public var poolByteArrayValue:Null<Array<Int>>;
	public var poolIntArrayValue:Null<Array<Int>>;
	public var poolRealArrayValue:Null<Array<Float>>;
	public var poolStringArrayValue:Null<Array<String>>;
	public var poolVector2ArrayValue:Null<Array<godot.Vector2>>;
	public var poolVector3ArrayValue:Null<Array<godot.Vector3>>;
	public var poolColorArrayValue:Null<Array<godot.Color>>;

	public function new(type:TscnValueType) {
		this.type = type;
	}

	public static function make_null():TscnValue {
		return new TscnValue(TNull);
	}

	public static function make_bool(v:Bool):TscnValue {
		var out:TscnValue = new TscnValue(TBool);
		out.boolValue = v;
		return out;
	}

	public static function make_int(v:Int):TscnValue {
		var out:TscnValue = new TscnValue(TInt);
		out.intValue = v;
		return out;
	}

	public static function make_float(v:Float):TscnValue {
		var out:TscnValue = new TscnValue(TFloat);
		out.floatValue = v;
		return out;
	}

	public static function make_string(v:String):TscnValue {
		var out:TscnValue = new TscnValue(TString);
		out.stringValue = v;
		return out;
	}

	public static function make_vector2(v:godot.Vector2):TscnValue {
		var out:TscnValue = new TscnValue(TVector2);
		out.vector2Value = v;
		return out;
	}

	public static function make_vector3(v:godot.Vector3):TscnValue {
		var out:TscnValue = new TscnValue(TVector3);
		out.vector3Value = v;
		return out;
	}

	public static function make_rect2(v:godot.Rect2):TscnValue {
		var out:TscnValue = new TscnValue(TRect2);
		out.rect2Value = v;
		return out;
	}

	public static function make_color(v:godot.Color):TscnValue {
		var out:TscnValue = new TscnValue(TColor);
		out.colorValue = v;
		return out;
	}

	public static function make_node_path(v:godot.NodePath):TscnValue {
		var out:TscnValue = new TscnValue(TNodePath);
		out.nodePathValue = v;
		return out;
	}

	public static function make_ext_resource(id:String):TscnValue {
		var out:TscnValue = new TscnValue(TExtResource);
		out.resourceRef = id;
		return out;
	}

	public static function make_sub_resource(id:String):TscnValue {
		var out:TscnValue = new TscnValue(TSubResource);
		out.resourceRef = id;
		return out;
	}

	public static function make_array(values:Array<TscnValue>):TscnValue {
		var out:TscnValue = new TscnValue(TArray);
		out.arrayValue = values;
		return out;
	}

	public static function make_dictionary(values:Map<String, TscnValue>):TscnValue {
		var out:TscnValue = new TscnValue(TDictionary);
		out.dictionaryValue = values;
		return out;
	}

	public static function make_pool_byte_array(values:Array<Int>):TscnValue {
		var out:TscnValue = new TscnValue(TPoolByteArray);
		out.poolByteArrayValue = values;
		return out;
	}

	public static function make_pool_int_array(values:Array<Int>):TscnValue {
		var out:TscnValue = new TscnValue(TPoolIntArray);
		out.poolIntArrayValue = values;
		return out;
	}

	public static function make_pool_real_array(values:Array<Float>):TscnValue {
		var out:TscnValue = new TscnValue(TPoolRealArray);
		out.poolRealArrayValue = values;
		return out;
	}

	public static function make_pool_string_array(values:Array<String>):TscnValue {
		var out:TscnValue = new TscnValue(TPoolStringArray);
		out.poolStringArrayValue = values;
		return out;
	}

	public static function make_pool_vector2_array(values:Array<godot.Vector2>):TscnValue {
		var out:TscnValue = new TscnValue(TPoolVector2Array);
		out.poolVector2ArrayValue = values;
		return out;
	}

	public static function make_pool_vector3_array(values:Array<godot.Vector3>):TscnValue {
		var out:TscnValue = new TscnValue(TPoolVector3Array);
		out.poolVector3ArrayValue = values;
		return out;
	}

	public static function make_pool_color_array(values:Array<godot.Color>):TscnValue {
		var out:TscnValue = new TscnValue(TPoolColorArray);
		out.poolColorArrayValue = values;
		return out;
	}
}

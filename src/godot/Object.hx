package godot;

import godot.core.EngineError;
import godot.core.Log;

typedef SignalCallback = Array<Dynamic>->Void;

class SignalConnection {
	public var target:Object;
	public var callback:SignalCallback;

	public function new(target:Object, callback:SignalCallback) {
		this.target = target;
		this.callback = callback;
	}
}

class Object {
	static var nextInstanceId:Int = 1;

	public var instanceId:Int;
	public var className:String;
	public var name:String;

	var signals:Map<String, Array<SignalConnection>>;
	var metadata:Map<String, Dynamic>;

	public function new() {
		instanceId = nextInstanceId++;
		className = Type.getClassName(Type.getClass(this));
		name = "";
		signals = new Map<String, Array<SignalConnection>>();
		metadata = new Map<String, Dynamic>();
	}

	public function call_method(methodName:String, args:Array<Dynamic>):Bool {
		return false;
	}

	public function add_user_signal(signalName:String):Void {
		if (!signals.exists(signalName)) {
			signals.set(signalName, []);
		}
	}

	public function has_signal(signalName:String):Bool {
		return signals.exists(signalName);
	}

	public function connect(signalName:String, target:Object, callback:SignalCallback):Void {
		if (!signals.exists(signalName)) {
			signals.set(signalName, []);
		}

		var list:Array<SignalConnection> = signals.get(signalName);
		if (list == null) {
			return;
		}

		list.push(new SignalConnection(target, callback));
	}

	public function disconnect(signalName:String, target:Object, callback:SignalCallback):Void {
		var list:Null<Array<SignalConnection>> = signals.get(signalName);
		if (list == null) {
			return;
		}

		var i:Int = 0;
		while (i < list.length) {
			var conn:SignalConnection = list[i];
			if (conn.target == target && Reflect.compareMethods(conn.callback, callback)) {
				list.splice(i, 1);
			} else {
				i++;
			}
		}
	}

	public function emit_signal(signalName:String, args:Array<Dynamic> = null):Void {
		var list:Null<Array<SignalConnection>> = signals.get(signalName);
		if (list == null) {
			return;
		}

		var actualArgs:Array<Dynamic> = args != null ? args : [];

		for (conn in list) {
			conn.callback(actualArgs);
		}
	}

	public function set_meta(key:String, value:Dynamic):Void {
		metadata.set(key, value);
	}

	public function get_meta(key:String):Null<Dynamic> {
		return metadata.get(key);
	}

	public function has_meta(key:String):Bool {
		return metadata.exists(key);
	}

	public function free():Void {
		signals.clear();
		metadata.clear();
	}

	public function toString():String {
		return className + ":" + name;
	}
}

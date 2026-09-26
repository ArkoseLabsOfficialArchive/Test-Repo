package godot.core;

class EngineError {
	public var subsystem:String;
	public var className:String;
	public var operation:String;
	public var message:String;
	public var nodePath:Null<String>;
	public var resourcePath:Null<String>;
	public var propertyName:Null<String>;

	public function new(subsystem:String, className:String, operation:String, message:String, ?nodePath:String, ?resourcePath:String, ?propertyName:String) {
		this.subsystem = subsystem;
		this.className = className;
		this.operation = operation;
		this.message = message;
		this.nodePath = nodePath;
		this.resourcePath = resourcePath;
		this.propertyName = propertyName;
	}

	public function format():String {
		var out:StringBuf = new StringBuf();
		out.add("[");
		out.add(subsystem);
		out.add("] ");
		out.add(className);
		out.add(".");
		out.add(operation);
		out.add(": ");
		out.add(message);

		if (nodePath != null) {
			out.add("\n    NodePath: ");
			out.add(nodePath);
		}

		if (resourcePath != null) {
			out.add("\n    Resource: ");
			out.add(resourcePath);
		}

		if (propertyName != null) {
			out.add("\n    Property: ");
			out.add(propertyName);
		}

		return out.toString();
	}
}

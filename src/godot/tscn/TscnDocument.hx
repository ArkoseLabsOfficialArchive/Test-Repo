package godot.tscn;

class TscnDocument {
	public var sourcePath:String;

	public var header:Null<TscnHeader>;
	public var extResources:Array<TscnExternalResource>;
	public var subResources:Array<TscnSubResource>;
	public var nodes:Array<TscnNode>;
	public var connections:Array<TscnConnection>;

	public function new() {
		sourcePath = "";

		header = null;
		extResources = [];
		subResources = [];
		nodes = [];
		connections = [];
	}

	public function get_ext_resource(id:String):Null<TscnExternalResource> {
		for (res in extResources) {
			if (res.id == id) {
				return res;
			}
		}

		return null;
	}

	public function get_sub_resource(id:String):Null<TscnSubResource> {
		for (res in subResources) {
			if (res.id == id) {
				return res;
			}
		}

		return null;
	}
}

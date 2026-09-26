package godot.core;

import haxe.PosInfos;

enum abstract LogLevel(Int) from Int to Int {
	var Debug = 0;
	var Info = 1;
	var Warning = 2;
	var Error = 3;
	var Fatal = 4;
}

class Log {
	public static var minimumLevel:LogLevel = LogLevel.Debug;

	public static function debug(subsystem:String, message:String, ?pos:PosInfos):Void {
		emit(LogLevel.Debug, subsystem, message, pos);
	}

	public static function info(subsystem:String, message:String, ?pos:PosInfos):Void {
		emit(LogLevel.Info, subsystem, message, pos);
	}

	public static function warning(subsystem:String, message:String, ?pos:PosInfos):Void {
		emit(LogLevel.Warning, subsystem, message, pos);
	}

	public static function error(err:EngineError, ?pos:PosInfos):Void {
		if (shouldEmit(LogLevel.Error)) {
			trace("ERROR " + format(err, pos));
		}
	}

	public static function fatal(err:EngineError, ?pos:PosInfos):Void {
		if (shouldEmit(LogLevel.Fatal)) {
			trace("FATAL " + format(err, pos));
		}

		throw format(err, pos);
	}

	public static function debugSource(subsystem:String, message:String, source:String, line:Int):Void {
		if (shouldEmit(LogLevel.Debug)) {
			trace("DEBUG [" + subsystem + "] " + message + " (" + source + ":" + line + ")");
		}
	}

	public static function warningSource(subsystem:String, message:String, source:String, line:Int):Void {
		if (shouldEmit(LogLevel.Warning)) {
			trace("WARNING [" + subsystem + "] " + message + " (" + source + ":" + line + ")");
		}
	}

	public static function errorSource(subsystem:String, message:String, source:String, line:Int):Void {
		if (shouldEmit(LogLevel.Error)) {
			trace("ERROR [" + subsystem + "] " + message + " (" + source + ":" + line + ")");
		}
	}

	static function shouldEmit(level:LogLevel):Bool {
		return (level : Int) >= (minimumLevel : Int);
	}

	static function emit(level:LogLevel, subsystem:String, message:String, pos:Null<PosInfos>):Void {
		if (!shouldEmit(level)) {
			return;
		}

		var location:String = formatPosition(pos);
		trace(levelName(level) + " [" + subsystem + "] " + message + " (" + location + ")");
	}

	static function format(err:EngineError, pos:Null<PosInfos>):String {
		var base:String = err.format();
		var location:String = formatPosition(pos);
		return base + "\n    Raised at: " + location;
	}

	static function formatPosition(pos:Null<PosInfos>):String {
		if (pos == null) {
			return "unknown source";
		}

		return pos.fileName + ":" + pos.lineNumber;
	}

	static function levelName(level:LogLevel):String {
		return switch (level) {
			case LogLevel.Debug: "DEBUG";
			case LogLevel.Info: "INFO";
			case LogLevel.Warning: "WARNING";
			case LogLevel.Error: "ERROR";
			case LogLevel.Fatal: "FATAL";
		}
	}
}

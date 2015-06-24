package;

import haxe.io.Bytes;
import haxe.io.BytesInput;
import haxe.io.Path;
import haxe.Resource;
import haxe.Timer;
import hxPixels.Pixels;


enum DataWrapper {
	PNG(data:format.png.Data);
	BMP(data:format.bmp.Data);
	GIF(data:format.gif.Data);
	Invalid;
}

class FormatAbstractPixelsDemo {
	
	var startTime:Float = 0.0;
	
	public static function main(): Void {
		new FormatAbstractPixelsDemo();
	}

	public function new() {
		for (id in Resource.listNames()) {
			var res = Resource.getBytes(id);
			var bytesInput = new BytesInput(res);
			
			trace('[ testing $id ]');
			
			test(bytesInput, id);
		}
	}
	
	public function test(input:BytesInput, id:String):Void {
		
		var ext = id.substr(-3).toLowerCase();
		
		// read input into data using format tools
		startTime = Timer.stamp();
		var dataWrapper = switch (ext) {
			case "png":
				var pngReader = new format.png.Reader(input);
				var data = pngReader.read();
				PNG(data);
				
			case "bmp":
				var bmpReader = new format.bmp.Reader(input);
				var data = bmpReader.read();
				BMP(data);
				
			case "gif":
				var gifReader = new format.gif.Reader(input);
				var data = gifReader.read();
				GIF(data);
				
			default:
				Invalid;
		}
		trace('read        ${Timer.stamp() - startTime}');
		
		if (dataWrapper == Invalid) {
			trace("ERROR: Invalid data.\n");
			return;
		}
		
		// load bitmapData into pixels abstract
		var pixels:Pixels = null;
		startTime = Timer.stamp();
		pixels = switch (dataWrapper) {
			case PNG(data): data;
			case BMP(data): data;
			case GIF(data): Pixels.fromGIFData(data, Std.random(format.gif.Tools.framesCount(data)), Std.random(2) == 0 ? true : false);
			default: null;
		}
		trace('load        ${Timer.stamp() - startTime}');
		
		// generate random points
		var points = [];
		var NUM_POINTS = 10000;
		for (i in 0...NUM_POINTS) points.push( { x: Std.random(pixels.width), y: Std.random(pixels.height) } );
		
		// read random points
		startTime = Timer.stamp();
		for (i in 0...NUM_POINTS) {
			var color = pixels.getPixel32(points[i].x, points[i].y);
		}
		trace('get         ${Timer.stamp() - startTime}');
		
		// add random red points
		startTime = Timer.stamp();
		for (i in 0...NUM_POINTS) {
			pixels.setPixel32(points[i].x, points[i].y, 0xFFFF0000);
		}
		// if this green line doesn't go _exactly_ from top-left to bottom-right, 
		// then there's something wrong with the Pixels impl.
		Bresenham.line(pixels, 0, 0, pixels.width - 1, pixels.height - 1, 0x00FF00);
		trace('set         ${Timer.stamp() - startTime}');
		
		// trace info
		trace("pixels      " + pixels.width, pixels.height, pixels.count, StringTools.hex(pixels.getPixel32(0, 0)));
		
		writeModifiedPNG(pixels, id);
	}
	
	public function writeModifiedPNG(pixels:Pixels, fileName:String) {
	#if neko	
		var dir = Path.directory(neko.vm.Module.local().name);
	#else
		var dir = Path.directory(Sys.executablePath());
	#end
		var outputFileName = "out_" + fileName + ".png";
		var file = sys.io.File.write(Path.join([dir, outputFileName]), true);
		var pngWriter = new format.png.Writer(file);
		startTime = Timer.stamp();
		pixels.convertTo(PixelFormat.ARGB);
		trace('convert     ${Timer.stamp() - startTime}');
		var pngData = format.png.Tools.build32ARGB(pixels.width, pixels.height, pixels.bytes);
		pngWriter.write(pngData);
		trace("written to '" + outputFileName + "'\n");
	}
}
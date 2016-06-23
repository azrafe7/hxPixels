package;

import flash.display.Stage;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.events.KeyboardEvent;
import flash.Lib;
import haxe.Timer;
import hxPixels.Pixels;


#if !openfl
@:bitmap("assets/global/galapagosColor.png")
class Asset1 extends flash.display.BitmapData {}

@:bitmap("assets/global/FromBitmap.png")
class Asset2 extends flash.display.BitmapData {}

class Assets {
	
	static var assets:Map<String, BitmapData>;
	
	static function __init__():Void {
		assets = new Map();
		assets["assets/global/galapagosColor.png"] = new Asset1(0, 0);
		assets["assets/global/FromBitmap.png"] = new Asset2(0, 0);
	}
	
	static public function get(id:String):BitmapData {
		return assets[id];
	}
}
#end

class AbstractPixelsDemo extends Sprite {

	var assets:Array<String> = [
		"assets/global/galapagosColor.png",
		"assets/global/FromBitmap.png"
	];
	

	public static function main(): Void {
		Lib.current.addChild(new AbstractPixelsDemo());
	}

	public function new() {
		super();
		
		for (asset in assets) {
		#if openfl
			var bmd = openfl.Assets.getBitmapData(asset);
		#else
			var bmd = Assets.get(asset);
		#end
			test(bmd, asset);
		}
		
		// programmatically generated test BitmapData
		var bmd = new BitmapData(480, 80, true, 0xA0102030);
		test(bmd, "generated BMD");
	}
	
	public function test(bitmapData:BitmapData, id:String):Void {
		
		// show the image bmp
		var bitmap:Bitmap = new Bitmap(bitmapData);
		addChild(bitmap);
		bitmap.x = (Lib.current.stage.stageWidth - bitmap.width) / 2;
		bitmap.y = (Lib.current.stage.stageHeight - bitmap.height) / 2;
		
		trace('[ testing $id ]');
		
		// load bitmapData into pixels abstract
		var startTime = Timer.stamp();
		var pixels:Pixels = bitmapData;
		trace('load        ${Timer.stamp() - startTime}');
		
		// generate random points
		var points = [];
		var NUM_POINTS = 10000;
		for (i in 0...NUM_POINTS) points.push( { x: Std.int(Math.random() * pixels.width), y: Std.int(Math.random() * pixels.height) } );
		
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
		
		// apply the modified pixels back to bitmapData
		startTime = Timer.stamp();
		pixels.applyToBitmapData(bitmapData);
		trace('apply       ${Timer.stamp() - startTime}');
		
		// trace info
		trace("pixels      " + pixels.width, pixels.height, pixels.count, StringTools.hex(pixels.getPixel32(50, 50)));
	#if !(html5 && openfl_legacy)
		trace("bitmapData  " + bitmapData.width, bitmapData.height, bitmapData.width * bitmapData.height, StringTools.hex(bitmapData.getPixel32(50, 50)) + "\n");
	#end
	
		// key presses
		Lib.current.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
	}
	
	function onKeyDown(event:KeyboardEvent):Void
	{
		if (event.keyCode == 27) {  // ESC
			#if flash
				flash.system.System.exit(1);
			#elseif sys
				Sys.exit(1);
			#end
		}
	}
}
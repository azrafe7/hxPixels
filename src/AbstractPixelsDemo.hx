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

@:bitmap("assets/global/galapagosColor.png")
class GalapagosColor extends flash.display.BitmapData {}

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
			var bmd = openfl.Assets.getBitmapData(asset);
			test(bmd, asset);
		}
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
		
		// add random red points
		startTime = Timer.stamp();
		for (i in 0...10000) {
			pixels.setPixel32(Std.int(Math.random() * pixels.width), Std.int(Math.random() * pixels.height), 0xFFFF0000);
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
		trace("pixels      " + pixels.width, pixels.height, pixels.count, StringTools.hex(pixels.getPixel32(100, 100)));
		trace("bitmapData  " + bitmapData.width, bitmapData.height, bitmapData.width * bitmapData.height, StringTools.hex(bitmapData.getPixel32(100, 100)) + "\n");
		
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
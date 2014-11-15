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

	public static function main(): Void {
		Lib.current.addChild(new AbstractPixelsDemo());
	}

	public function new() {
		super();
		
		var bitmapData:BitmapData = null;
		
    #if html5	// load as openfl asset
        bitmapData = openfl.Assets.getBitmapData("GalapagosColor");
    #else		
        bitmapData = new GalapagosColor(0, 0);	
	#end
	
		// show the image bmp
		var bitmap:Bitmap = new Bitmap(bitmapData);
		addChild(bitmap);
		
		// load bitmapData into pixels abstract
		var startTime = Timer.stamp();
		var pixels:Pixels = bitmapData;
		trace("load", Timer.stamp() - startTime);
		
		// add random red points
		startTime = Timer.stamp();
		for (i in 0...10000) {
			pixels.setPixel32(Std.int(Math.random() * pixels.width), Std.int(Math.random() * pixels.height), 0xFFFF0000);
		}
		trace("set", Timer.stamp() - startTime);
		
		// apply the modified pixels back to bitmapData
		startTime = Timer.stamp();
		pixels.applyTo(bitmapData);
		trace("apply", Timer.stamp() - startTime);
		
		// trace info
		trace("pixels    ", pixels.width, pixels.height, pixels.length, StringTools.hex(pixels.getPixel32(300, 300)));
		trace("bitmapData", bitmapData.width, bitmapData.height, bitmapData.width * bitmapData.height, StringTools.hex(bitmapData.getPixel32(300, 300)));
		
		
		// click/drag
		Lib.current.stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
		Lib.current.stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		
		// animate
		Lib.current.stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
		
		// key presses
		Lib.current.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		
	}
	
    function onMouseUp( event: MouseEvent ): Void {
    }
    
    function onMouseDown( event: MouseEvent ): Void {
    }
    
    function onEnterFrame( event: Event ): Void {
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
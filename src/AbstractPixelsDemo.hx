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


#if (use_loader)

@:bitmap("assets/global/galapagosColor.png")
class Asset1 extends flash.display.BitmapData {}

@:bitmap("assets/global/FromBitmap.png")
class Asset2 extends flash.display.BitmapData {}

#end


class AbstractPixelsDemo extends Sprite {

  var assetFileNames:Array<String> = [
    "assets/global/galapagosColor.png",
    "assets/global/FromBitmap.png"
  ];
  var assetClassNames:Array<String> = [
    "Asset1",
    "Asset2"
  ];
  

  public static function main(): Void {
    Lib.current.addChild(new AbstractPixelsDemo());
  }

  
  function runTests(bmds:Array<BitmapData>, titles:Array<String>) {
    for (i in 0...bmds.length) {
      test(bmds[i], titles[i]);
    }
  }
  
  
  public function new() {
    super();
    
    // programmatically generated test BitmapData
    var genBmd = new BitmapData(480, 80, true, 0xA0102030);
    //genBmd.image.buffer.premultiplied = false;
    
    var bmds = [];
    var titles = [for (assetName in assetFileNames) assetName];
    titles.push("Generated BMD");
    
  #if use_loader
    
    var loader = new ImageLoader();
    trace(" -- USING ImageLoader --");
    
    loader.load(assetClassNames, function(loader) {
      for (assetName in assetClassNames) bmds.push(loader.getBitmapData(assetName));
      bmds.push(genBmd);
      
      runTests(bmds, titles);
    });
    
  #else
    
    for (assetName in assetFileNames) {
      trace(assetName + ": " + (openfl.Assets.exists(assetName) ? "ok" : "not exists"));
      var bmd = openfl.Assets.getBitmapData(assetName, false);
      bmds.push(bmd);
    }
    bmds.push(genBmd);
    
    runTests(bmds, titles);
    
  #end
    
    // key presses
    Lib.current.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
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
    trace("pixels      " + pixels.width, pixels.height, pixels.count, "0x" + StringTools.hex(pixels.getPixel32(50, 50), 8));
  #if !(html5 && openfl_legacy)
    trace("bitmapData  " + bitmapData.width, bitmapData.height, bitmapData.width * bitmapData.height, "0x" + StringTools.hex(bitmapData.getPixel32(50, 50), 8) + "\n");
  #end
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
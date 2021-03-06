package ;

import flambe.display.Texture;
import flambe.Entity;
import flambe.System;
import flambe.asset.AssetPack;
import flambe.asset.Manifest;
import flambe.display.FillSprite;
import flambe.display.ImageSprite;
import haxe.Timer;
import hxPixels.Pixels;

#if flash
@:bitmap("assets/global/galapagosColor.png")
class GalapagosColor extends flash.display.BitmapData { }
#end

class FlambeAbstractPixelsDemo
{
    private static function main ()
    {
        // Wind up all platform-specific stuff
        System.init();

        // Catch uncaught exceptions
		System.uncaughtError.connect(log);
		
		// Load up the compiled pack in the assets directory named "global"
        var manifest = Manifest.fromAssets("global");
        var loader = System.loadAssetPack(manifest);
        loader.get(onSuccess);
    }

    private static function onSuccess (pack :AssetPack)
    {
        var texture:Texture = pack.getTexture("galapagosColor");
		
		// show the sprite
        var sprite = new ImageSprite(texture).centerAnchor().setXY(System.stage.width/2, System.stage.height/2);
        var entity = new Entity().add(sprite);
		System.root.addChild(entity);
		
		// load texture into pixels abstract
		var startTime = Timer.stamp();
	#if html
		var pixels:Pixels = texture;
	#else
		var bitmapData = new GalapagosColor(0, 0);
		var pixels:Pixels = bitmapData;
	#end
		log("load " + (Timer.stamp() - startTime) + "  " + pixels.width + "x" + pixels.height);
		
		// add random red points
		startTime = Timer.stamp();
		for (i in 0...10000) {
			pixels.setPixel32(Std.int(Math.random() * pixels.width), Std.int(Math.random() * pixels.height), 0xFFFF0000);
		}
		// if this green line doesn't go _exactly_ from top-left to bottom-right, 
		// then there's something wrong with the Pixels impl.
		Bresenham.line(pixels, 0, 0, pixels.width - 1, pixels.height - 1, 0x00FF00);
		log("set " + (Timer.stamp() - startTime));
		
		// apply the modified pixels back to texture
		startTime = Timer.stamp();
	#if	html
		pixels.applyToFlambeTexture(texture);
	#else
		pixels.applyToBitmapData(bitmapData);
		texture = System.renderer.createTextureFromImage(bitmapData);
		entity.remove(sprite);
        sprite = new ImageSprite(texture).centerAnchor().setXY(System.stage.width/2, System.stage.height/2);
        entity.add(sprite);
	#end
		log("apply " + (Timer.stamp() - startTime));
    }
	
	static public function log(x:Dynamic):Void {
	#if flash
		flash.external.ExternalInterface.call("console.log", x);
	#else
		js.Browser.console.log(x);
	#end
	}
}

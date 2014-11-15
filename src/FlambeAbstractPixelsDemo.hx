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

class FlambeAbstractPixelsDemo
{
    private static function main ()
    {
        // Wind up all platform-specific stuff
        System.init();

        // Load up the compiled pack in the assets directory named "global"
        var manifest = Manifest.fromAssets("global");
        var loader = System.loadAssetPack(manifest);
        loader.get(onSuccess);
    }

    private static function onSuccess (pack :AssetPack)
    {
        // Add a solid color background
        var background = new FillSprite(0xffffff, System.stage.width, System.stage.height).setXY(0, 0);
        System.root.addChild(new Entity().add(background));

        var texture:Texture = pack.getTexture("galapagosColor");
		
		// show the sprite
        var sprite = new ImageSprite(texture).centerAnchor().setXY(System.stage.width/2, System.stage.height/2);
        System.root.addChild(new Entity().add(sprite));
		
		// load texture into pixels abstract
		var startTime = haxe.Timer.stamp();
		var pixels:Pixels = texture;
		trace("load", haxe.Timer.stamp() - startTime);
		
		// add random red points
		startTime = haxe.Timer.stamp();
		for (i in 0...10000) {
			pixels.setPixel32(Std.int(Math.random() * pixels.width), Std.int(Math.random() * pixels.height), 0xFFFF0000);
		}
		trace("set", Timer.stamp() - startTime);
		
		// apply the modified pixels back to texture
		startTime = haxe.Timer.stamp();
		pixels.applyTo(texture);
		trace("apply", Timer.stamp() - startTime);
    }
}

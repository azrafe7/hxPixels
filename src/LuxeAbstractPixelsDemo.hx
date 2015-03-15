
import haxe.Timer;
import luxe.Input;
import luxe.Vector;
import luxe.Sprite;
import luxe.Color;
import phoenix.Texture;
import snow.utils.UInt8Array;
import hxPixels.Pixels;

class LuxeAbstractPixelsDemo extends luxe.Game {

	var texture:Texture;
	
    override function ready() {
		texture = Luxe.loadTexture("assets/global/galapagosColor.png");
		
		texture.onload = onLoaded;
    } //ready

	function onLoaded(_):Void {
		
        texture.filter = FilterType.nearest;

		$type(texture.asset.image.data);
		
        var sprite = new Sprite({
            texture: texture,
			pos: Luxe.screen.mid
        });
		
		var start = Timer.stamp();
		var pixels:Pixels = texture;
		trace("load " + (Timer.stamp() - start));
		
		start = Timer.stamp();
		for (i in 0...10000) {
			var color = 0xFF0000;
			pixels.setPixel32(Std.int(Math.random() * texture.width), Std.int(Math.random() * texture.height), 
							  0xFF000000 | color);
		}
		trace("set " + (Timer.stamp() - start));
		
		start = Timer.stamp();
		pixels.applyToSnowTexture(texture);
		trace("apply " + (Timer.stamp() - start));
	}
	
	override function onkeyup( e:KeyEvent ) {

        if(e.keycode == Key.escape) {
            Luxe.shutdown();
        }

    } //onkeyup

    override function update(dt:Float) {

    } //update


} //Main

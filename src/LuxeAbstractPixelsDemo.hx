
import haxe.Timer;
import hxPixels.Pixels;
import luxe.Input.Key;
import luxe.Input.KeyEvent;
import luxe.Sprite;
import phoenix.Texture;
import snow.types.Types.AssetImage;

class LuxeAbstractPixelsDemo extends luxe.Game {

	static var assetId:String = "assets/global/galapagosColor.png";
	
	var assetImage:AssetImage;
	
    override function ready() {
		Luxe.snow.assets.image(assetId).then(function (_assetImage:AssetImage):Void {
			assetImage = _assetImage;
			Luxe.resources.load_texture(assetId).then(onLoaded);
		});
    } //ready

	function onLoaded(texture:Texture):Void {
		
		$type(texture);
		
        var sprite = new Sprite({
            texture: texture,
			pos: Luxe.screen.mid
        });
		
		var start = Timer.stamp();
		var pixels:Pixels = Pixels.fromLuxeAssetImage(assetImage);
		trace("load " + (Timer.stamp() - start));
		start = Timer.stamp();
		for (i in 0...10000) {
			var color = 0xFF0000;
			pixels.setPixel32(Std.int(Math.random() * texture.width), Std.int(Math.random() * texture.height), 
							  0xFF000000 | color);
		}
		// if this green line doesn't go _exactly_ from top-left to bottom-right, 
		// then there's something wrong with the Pixels impl.
		Bresenham.line(pixels, 0, 0, pixels.width - 1, pixels.height - 1, 0x00FF00);
		trace("set " + (Timer.stamp() - start));
		
		start = Timer.stamp();
		pixels.applyToLuxeTexture(texture);
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

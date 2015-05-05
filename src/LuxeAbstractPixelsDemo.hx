
import haxe.Timer;
import hxPixels.Pixels;
import luxe.Input.Key;
import luxe.Input.KeyEvent;
import luxe.Sprite;
import phoenix.Texture;
import snow.api.Promise;
import snow.types.Types.AssetImage;

class LuxeAbstractPixelsDemo extends luxe.Game {

	var assets:Array<String> = [
		"assets/global/galapagosColor.png",
		"assets/global/FromBitmap.png"
	];
	
    override function ready() {
		
		var z = 0;
		
		for (asset in assets) {
			
			var assetImage:AssetImage;
			var texture:Texture;
			
			var promisedAsset = Luxe.snow.assets.image(asset).then(function (_assetImage):Void {
				assetImage = _assetImage;
			});
			
			var promisedTexture = Luxe.resources.load_texture(asset).then(function (_texture):Void {
				texture = _texture;
			});
			
			Promise.all([promisedAsset, promisedTexture]).then(function (_):Void {
				test(texture, assetImage, asset, z--);
			});
		}
    } //ready

	function test(texture:Texture, assetImage:AssetImage, id:String, z:Int):Void {
		
        var sprite = new Sprite({
            texture: texture,
			pos: Luxe.screen.mid,
			depth: z
        });
		
		trace('[ testing $id ]');
		
		var startTime = Timer.stamp();
		var pixels:Pixels = Pixels.fromLuxeAssetImage(assetImage);
		trace('load        ${Timer.stamp() - startTime}');
		
		startTime = Timer.stamp();
		for (i in 0...10000) {
			var color = 0xFF0000;
			pixels.setPixel32(Std.int(Math.random() * texture.width), Std.int(Math.random() * texture.height), 
							  0xFF000000 | color);
		}
		// if this green line doesn't go _exactly_ from top-left to bottom-right, 
		// then there's something wrong with the Pixels impl.
		Bresenham.line(pixels, 0, 0, pixels.width - 1, pixels.height - 1, 0x00FF00);
		trace('set         ${Timer.stamp() - startTime}');
		
		startTime = Timer.stamp();
		pixels.applyToLuxeTexture(texture);
		trace('apply       ${Timer.stamp() - startTime}\n');
	}
	
	override function onkeyup( e:KeyEvent ) {

        if(e.keycode == Key.escape) {
            Luxe.shutdown();
        }

    } //onkeyup

    override function update(dt:Float) {

    } //update


} //Main

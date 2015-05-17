
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
			
			var promisedTexture = Luxe.resources.load_texture(asset);
			var promisedAsset = Luxe.snow.assets.image(asset);
			
			Promise.all([promisedTexture, promisedAsset]).then(function (fulfilledArray):Void {
				test(cast fulfilledArray[0], cast fulfilledArray[1], asset, z--);
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
		
		// load into pixels abstract
		var startTime = Timer.stamp();
		var pixels:Pixels = Pixels.fromLuxeAssetImage(assetImage);
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
		for (i in 0...10000) {
			var color = 0xFF0000;
			pixels.setPixel32(Std.int(Math.random() * texture.width), Std.int(Math.random() * texture.height), 
							  0xFF000000 | color);
		}
		// if this green line doesn't go _exactly_ from top-left to bottom-right, 
		// then there's something wrong with the Pixels impl.
		Bresenham.line(pixels, 0, 0, pixels.width - 1, pixels.height - 1, 0x00FF00);
		trace('set         ${Timer.stamp() - startTime}');
		
		// apply the modified pixels back
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

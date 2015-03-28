package;
import hxPixels.Pixels;

/**
 * ...
 * @author azrafe7
 */
class Bresenham {

	// see: http://en.wikipedia.org/wiki/Bresenham's_line_algorithm
	static public function lineCallback(fromX:Int, fromY:Int, toX:Int, toY:Int, precision:Int = 1, callback:Int->Int->Void = null):Void 
	{
		if (callback == null) callback = function(x, y) { };
		
		var steep:Bool = Math.abs(toY - fromY) > Math.abs(toX - fromX);
		
		if (steep) {	// swap x <-> y
			var tmp:Int;
			
			tmp = fromX;
			fromX = fromY;
			fromY = tmp;
			
			tmp = toX;
			toX = toY;
			toY = tmp;
		}
		
		var deltaX:Int = Std.int(Math.abs(toX - fromX));
		var deltaY:Int = Std.int(Math.abs(toY - fromY));
		var error:Int = Std.int(deltaX / 2);
		var x:Int = fromX;
		var y:Int = fromY;
		var count:Int = -1;
		
		var xStep:Int = fromX < toX ? 1 : -1;
		var yStep:Int = fromY < toY ? 1 : -1;
		
		while (x != toX) {
			if (count == precision || count < 0) {
				if (steep) callback(y, x)
				else callback(x, y);
				count = 0;
			}
			
			error -= deltaY;
			if (error < 0) {
				y += yStep;
				error += deltaX;
			}
			x += xStep;
			count++;
		}
		
		// last point
		if (steep) callback(y, x)
		else callback(x, y);
	}

	static public function line(pixels:Pixels, fromX:Int, fromY:Int, toX:Int, toY:Int, color:Int, precision:Int = 1):Void 
	{
		lineCallback(fromX, fromY, toX, toY, precision, function (x, y) {
			pixels.setPixel32(x, y, 0xFF000000 | color);
		});
	}
}
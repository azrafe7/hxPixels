// ported from http://paulbourke.net/fractals/buddhabrot/buddha.c

import hxPixels.Pixels;


@:structInit
class XY {
  public var x:Float;
  public var y:Float;

  public function new(x:Float, y:Float)   {
    this.x = x;
    this.y = y;
  }
}

/**
  Crude, but functional, little program to calculate the
  So called "budda mandelbrot" or "buddhabrot"
  Please note that this is not supposed to be the most efficient
  implementation, it is only intended to be a simple example with
  plenty of scope for improvement by the reader.
*/
class Buddhabrot {

  static inline function drand48():Float {
    return Math.random();
  }

  // Image dimensions
  static inline var NX:Int = 500;
  static inline var NY:Int = 300;

  // Length of sequence to test escape status
  // Also known as bailout
  static inline var NMAX:Int = 200;

  static inline var TTMAX:Int = 1000;

  // Number of iterations, in multiples of TTMAX
  static inline var TMAX:Int = 10000;


  static public function main() {
    trace('[Buddhabrot (width:$NX, height:$NY, iterations:${TMAX * TTMAX})]\n...');

    var t0 = haxe.Timer.stamp();

    var ix:Int, iy:Int;
    var x:Float, y:Float;

    // The density plot image (cleared to black)
    var image = [for (i in 0...NX * NY) 0];

    // Alloc space for the sequence
    var xyseq:Array<XY> = [for (i in 0...NMAX) {x:0, y:0}];

    // Iterate
    for (tt in 0...TTMAX) {
      for (t in 0...TMAX) {

        // Choose a random point in same range
        x = 6 * drand48() - 3;
        y = 6 * drand48() - 3;

        // Determine state of this point, draw if it escapes
        var result = iterate(x, y, xyseq);
        if (result.escaped) {
          for (i in 0...result.n) {
            ix = Math.round(0.3 * NX * (xyseq[i].x + 0.0) + NX / 2);
            iy = Math.round(0.3 * NY * (xyseq[i].y + 0.5) + NY / 2);
            if (ix >= 0 && iy >= 0 && ix < NX && iy < NY)
              image[iy * NX + ix]++;
          }
        }
      } // t
    } // tt

    trace("Elapsed: " + (haxe.Timer.stamp() - t0) + "s");

    // Save the result
    writeImage("buddha.png", image, NX, NY);
  }

  /**
    Iterate the Mandelbrot and return true if the point escapes
  */
  static inline function iterate(x0:Float, y0:Float, seq:Array<XY>):{n:Int, escaped:Bool} {
    var n = 0;
    var result = {n:n, escaped:false};
    var x = 0.0, y = 0.0, xnew = 0.0, ynew = 0.0;

    for (i in 0...NMAX) {
      ynew = y * y - x * x + y0;
      xnew = 2 * y * x + x0;
      seq[i].x = xnew;
      seq[i].y = ynew;
      if (xnew * xnew + ynew * ynew > 10) {
        result.n = i;
        result.escaped = true;
        break;
      }
      x = xnew;
      y = ynew;
    }

    return result;
  }

  /**
    Write the buddha image to a PNG file.
  */
  static function writeImage(fileName:String, image:Array<Int>, width:Int, height:Int):Void {
    var ramp:Float, biggest = Math.NEGATIVE_INFINITY, smallest = Math.POSITIVE_INFINITY;

    var dir = haxe.io.Path.directory(Sys.programPath());
    var fullPath = haxe.io.Path.join([dir, fileName]);
    var file = sys.io.File.write(fullPath, true);
    var pngWriter = new format.png.Writer(file);

    // Find the largest and smallest density values
    for (i in 0...width * height) {
      biggest = Math.max(biggest, image[i]);
      smallest = Math.min(smallest, image[i]);
    }
    trace('Density value range: $smallest to $biggest');

    // Write the image
    trace('Writing "$fileName" (in "$dir")');

    var pixels = new Pixels(width, height, true);
    var bytes = pixels.bytes;

    // Raw uncompressed bytes
    for (i in 0...width * height) {
      ramp = 2 * (image[i] - smallest) / (biggest - smallest);
      if (ramp > 1)
        ramp = 1;
      ramp = Math.pow(ramp, 0.5);
      var pos = i << 2;
      bytes.set(pos + 0, 255);
      bytes.set(pos + 1, Std.int(ramp * 255));
      bytes.set(pos + 2, Std.int(ramp * 255));
      bytes.set(pos + 3, Std.int(ramp * 255));
    }

    var pngData = format.png.Tools.build32ARGB(pixels.width, pixels.height, pixels.bytes);
    pngWriter.write(pngData);
    file.close();
  }
}
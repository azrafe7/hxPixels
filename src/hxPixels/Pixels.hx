package hxPixels;

import haxe.io.Bytes;
import haxe.io.UInt8Array;
import haxe.io.UInt32Array;


/**
 * Class abstracting pixels for various libs/targets (for easier manipulation).
 * 
 * The exposed get/set methods will transparently work in ARGB format, while
 * the underlying bytes' pixel format will be automatically inferenced when one 
 * of the `from_` methods is called.
 * 
 * You can still override the channel mapping by setting `format` afterwards.
 * 
 * NOTE: One important thing to keep in mind is that, on some targets/libs, a
 * pixel with an alpha value of zero doesn't necessarily mean that RGB will be
 * zero too (f.e. openfl with neko/cpp targets). This means that instead of 
 * relying blindly on RGB values you should - in such cases - first test the 
 * alpha one.
 * 
 * @author azrafe7
 */
@:expose
@:forward
abstract Pixels(PixelsData)
{
  static inline var CHANNEL_MASK:Int = 3;
  
  /** 
   * Constructor. If `alloc` is false no memory will be allocated for `bytes`, 
   * but the other properties (width, height, count) will still be set.
   */
  inline public function new(width:Int, height:Int, alloc:Bool = true) 
  {
    this = new PixelsData(width, height, alloc);
  }
  
  /** Returns the byte value at `i` position, as if the data were in ARGB format. */
  @:arrayAccess
  inline public function getByte(i:Int) {
    return this.bytes.get((i & ~CHANNEL_MASK) + this.format.channelMap[i & CHANNEL_MASK]);
  }
  
  /** Returns the pixel value (without alpha) at `x`,`y`, as if the data were in ARGB format. */
  inline public function getPixel(x:Int, y:Int):Pixel {
    var pos = (y * this.width + x) << 2;
    
    var r = this.bytes.get(pos + this.format.R) << 16;
    var g = this.bytes.get(pos + this.format.G) << 8;
    var b = this.bytes.get(pos + this.format.B);
    
    return cast (r | g | b);
  }
  
  /** Returns the pixel value (with alpha) at `x`,`y`, as if the data were in ARGB format. */
  inline public function getPixel32(x:Int, y:Int):Pixel {
    var pos = (y * this.width + x) << 2;
    
    var a = this.bytes.get(pos + this.format.A) << 24;
    var r = this.bytes.get(pos + this.format.R) << 16;
    var g = this.bytes.get(pos + this.format.G) << 8;
    var b = this.bytes.get(pos + this.format.B);
    
    return cast (a | r | g | b);
  }
  
  /** Sets the byte value at `i` pos, as if the data were in ARGB format. */
  @:arrayAccess
  inline public function setByte(i:Int, value:Int) {
    this.bytes.set((i & ~CHANNEL_MASK) + this.format.channelMap[i & CHANNEL_MASK], value);
  }
  
  /** Sets the pixel value (without alpha) at `x`,`y`, with `value` expressed in RGB format. */
  inline public function setPixel(x:Int, y:Int, value:Int) {
    var pos = (y * this.width + x) << 2;
    
    var r = (value >> 16) & 0xFF;
    var g = (value >> 8) & 0xFF;
    var b = (value) & 0xFF;

    this.bytes.set(pos + this.format.R, r);
    this.bytes.set(pos + this.format.G, g);
    this.bytes.set(pos + this.format.B, b);
  }
  
  /** Sets the pixel value (with alpha) at `x`,`y`, with `value` expressed in ARGB format. */
  inline public function setPixel32(x:Int, y:Int, value:Int) {
    var pos = (y * this.width + x) << 2;
    
    var a = (value >> 24) & 0xFF;
    var r = (value >> 16) & 0xFF;
    var g = (value >> 8) & 0xFF;
    var b = (value) & 0xFF;

    this.bytes.set((pos + this.format.A), a);
    this.bytes.set((pos + this.format.R), r);
    this.bytes.set((pos + this.format.G), g);
    this.bytes.set((pos + this.format.B), b);
  }
  
  /** Fills the specified rect area, with `value` expressed in ARGB format. Doesn't do any bound checking. */
  public function fillRect(x:Int, y:Int, width:Int, height:Int, value:Int):Void {
    var pos = (y * this.width + x) << 2;
    
    var stridePixels = new Pixels(width, 1, true);
    stridePixels.format = this.format;
    var stride = width << 2;
    
    for (x in 0...width) stridePixels.setPixel32(x, 0, value);
    for (y in 0...height) {
      this.bytes.blit(pos, stridePixels.bytes, 0, stride);
      pos += this.width << 2;
    }		
  }
  
  public function clone():Pixels {
    var clone:Pixels = new Pixels(this.width, this.height, true);
    clone.bytes.blit(0, this.bytes, 0, this.bytes.length);
    clone.format = this.format;
    return clone;
  }

  static public function fromBytes(bytes:Bytes, width:Int, height:Int, ?format:PixelFormat):Pixels {
    var pixels = new Pixels(width, height, false);
    if (format == null) format = PixelFormat.ARGB;
    pixels.bytes = bytes;
    return pixels;
  }

  inline public function convertTo(format:PixelFormat):Pixels {
    return convert(cast this, format, true);
  }
  
  static public function convert(pixels:Pixels, toFormat:PixelFormat, inPlace:Bool = false):Pixels {
    var res = inPlace ? pixels : pixels.clone();
    
    if (toFormat == pixels.format) return res;
    
    var i = 0;
    var pos = 0;
    
    // fast path in case only B and R have to be swapped
    if ((pixels.format == PixelFormat.BGRA && toFormat == PixelFormat.RGBA) ||
      (pixels.format == PixelFormat.RGBA && toFormat == PixelFormat.BGRA))
    {
      while (i < pixels.count) {
        
        var r = pixels.getByte(pos + 1);
        var b = pixels.getByte(pos + 3);
        
        res.bytes.set(pos + toFormat.R, r);
        res.bytes.set(pos + toFormat.B, b);
        
        i++;
        pos += 4;
      }
    } else {
      while (i < pixels.count) {
        
        var a = pixels.getByte(pos + 0);
        var r = pixels.getByte(pos + 1);
        var g = pixels.getByte(pos + 2);
        var b = pixels.getByte(pos + 3);
        
        res.bytes.set(pos + toFormat.A, a);
        res.bytes.set(pos + toFormat.R, r);
        res.bytes.set(pos + toFormat.G, g);
        res.bytes.set(pos + toFormat.B, b);
        
        i++;
        pos += 4;
      }
    }
    
    res.format = toFormat;
    return res;
  }

#if (format)	// convert from png, bmp and gif data using `HaxeFoundation/format` lib (underlying bytes in BGRA format)

  @:from static public function fromPNGData(data:format.png.Data) {
    var header = format.png.Tools.getHeader(data);
    var bytes = format.png.Tools.extract32(data);
    var pixels = new Pixels(header.width, header.height, false);
    pixels.bytes = bytes;
    pixels.format = PixelFormat.BGRA;
    
    return pixels;
  }

  @:from static public function fromBMPData(data:format.bmp.Data) {
    var header = data.header;
    var bytes = format.bmp.Tools.extractBGRA(data);
    var pixels = new Pixels(header.width, header.height, false);
    pixels.bytes = bytes;
    pixels.format = PixelFormat.BGRA;
    
    return pixels;
  }

  static public function fromGIFData(data:format.gif.Data, frameIndex:Int = 0, full:Bool = true) {
    var pixels:Pixels;
    
    if (full) {
      pixels = new Pixels(data.logicalScreenDescriptor.width, data.logicalScreenDescriptor.height, false);
      pixels.bytes = format.gif.Tools.extractFullBGRA(data, frameIndex);
    } else {
      var frame = format.gif.Tools.frame(data, frameIndex);
      pixels = new Pixels(frame.width, frame.height, false);
      pixels.bytes = format.gif.Tools.extractBGRA(data, frameIndex);
    }
    pixels.format = PixelFormat.BGRA;
    
    return pixels;
  }

#end
  
#if (flambe) // in flambe texture bytes are in RGBA format

  @:from static public function fromFlambeTexture(texture:flambe.display.Texture) {
    var pixels = new Pixels(texture.width, texture.height, true);
    pixels.format = PixelFormat.RGBA;
    
    var data = texture.readPixels(0, 0, texture.width, texture.height);
    pixels.bytes.blit(0, data, 0, data.length);
    
    return pixels;
  }
  
  #if (flambe && html) // not possible in (flambe && flash) due to Stage3D limitations
  public function applyToFlambeTexture(texture:flambe.display.Texture) {
    texture.writePixels(this.bytes, 0, 0, this.width, this.height);
  }
  #end

#end

#if (snow || luxe) // in snow/luxe texture bytes are in RGBA format (and must account for padded sizes when submitting)
  
  @:from static public function fromLuxeTexture(texture:phoenix.Texture) {
    var pixels = new Pixels(texture.width, texture.height, false);
    pixels.format = PixelFormat.RGBA;
    
    var data = new snow.api.buffers.Uint8Array(texture.width * texture.height * 4);
    texture.fetch(data);
    pixels.bytes = data.toBytes();
    
    return pixels;
  }
  
  @:from static public function fromLuxeAssetImage(assetImage:snow.types.Types.AssetImage) {
    var image:snow.types.Types.ImageData = assetImage.image;
    var pixels = new Pixels(image.width, image.height, true);
    pixels.format = PixelFormat.RGBA;
    
    var data = image.pixels.toBytes();
    var stride = image.width * 4;
    
    for (y in 0...image.height) {
      pixels.bytes.blit(y * stride, data, y * image.width_actual * 4, stride);
    }
    
    return pixels;
  }
  
  public function applyToLuxeTexture(texture:phoenix.Texture) {
    var data = Bytes.alloc(texture.width_actual * texture.height_actual * 4);
    
    var padded_width = texture.width_actual;
    var stride = this.width * 4;
    
    for (y in 0...this.height) {
      data.blit(y * padded_width * 4, this.bytes, y * stride, stride);
    }
    
    texture.submit(snow.api.buffers.Uint8Array.fromBytes(data));  // rebind texture
  }
#end

#if (flash || openfl || nme || (flambe && flash))

  @:from static public function fromBitmapData(bmd:flash.display.BitmapData) {
  #if js	
  
    var pixels = new Pixels(bmd.width, bmd.height, false);
    pixels.format = PixelFormat.RGBA;
    
    // force buffer creation
    var image = bmd.image;
    lime.graphics.utils.ImageCanvasUtil.convertToCanvas(image);
    lime.graphics.utils.ImageCanvasUtil.createImageData(image);
    
    var data = image.buffer.data;
    pixels.bytes = Bytes.ofData(data.buffer);
    
  #else
    
    var pixels = new Pixels(bmd.width, bmd.height, false);

    #if flash
    
      pixels.format = PixelFormat.ARGB;
      
      var ba = bmd.getPixels(bmd.rect);
      pixels.bytes = Bytes.ofData(ba);
      
    #elseif (openfl_next || openfl >= "4.0.0")
    
      //trace("!flash openfl");
      pixels.format = PixelFormat.BGRA;
      
      var data = @:privateAccess bmd.image.buffer.data.buffer.getData();
      pixels.bytes = Bytes.ofData(data);
      
    #else
    
      //trace("!next openfl < 4.0.0");
      pixels.format = PixelFormat.ARGB;
      
      var ba = bmd.getPixels(bmd.rect);
      pixels.bytes = (ba);
      
    #end
  
  #end
  
    return pixels;
  }
  
  public function applyToBitmapData(bmd:flash.display.BitmapData) {
  #if js
    
    var image = bmd.image;
    
    #if (openfl < "4.0.0")
    
      lime.graphics.utils.ImageCanvasUtil.convertToData(image);
      image.dirty = true;
      
    #else
    
      image.buffer.data = lime.utils.UInt8Array.fromBytes(this.bytes);
      image.type = lime.graphics.ImageType.DATA;
      image.dirty = true;
      image.version++;
      
    #end
        
  #else
  
    #if flash
      
      var ba = this.bytes.getData();
      ba.endian = flash.utils.Endian.BIG_ENDIAN;
      ba.position = 0;
      bmd.setPixels(bmd.rect, ba);
      
    #elseif (openfl_next || openfl >= "4.0.0")
      
      //trace("!flash openfl");
      bmd.image.buffer.data = openfl.utils.UInt8Array.fromBytes(this.bytes);
      
      #if (openfl >= "4.0.0")
        
        bmd.image.dirty = true;
        bmd.image.version++;
        
      #end
      
    #else
      
      //trace("!next openfl < 4.0.0");
      var ba = openfl.utils.ByteArray.fromBytes(this.bytes);
      ba.position = 0;
      bmd.setPixels(bmd.rect, ba);
      
    #end
    
  #end
  }

#end

#if java

  @:from static public function fromBufferedImage(image:java.awt.image.BufferedImage) {
    var pixels = new Pixels(image.getWidth(), image.getHeight(), true);
    pixels.format = PixelFormat.RGBA;
    
    var buffer = new java.NativeArray<Int>(pixels.bytes.length);
    buffer = image.getRaster().getPixels(0, 0, pixels.width, pixels.height, buffer);
    
    for (i in 0...buffer.length) pixels.bytes.set(i, buffer[i]);
    
    return pixels;
  }
  
  public function applyToBufferedImage(image:java.awt.image.BufferedImage) {
    var buffer = new java.NativeArray<Int>(this.bytes.length);
    for (i in 0...buffer.length) buffer[i] = this.bytes.get(i);
    
    image.getRaster().setPixels(0, 0, this.width, this.height, buffer);
  }

#end

#if js	// plain js - conversion from ImageData

  @:from static public function fromImageData(image:js.html.ImageData) {
    var pixels = new Pixels(image.width, image.height, false);
    pixels.format = PixelFormat.RGBA;
    
    var u8ClampedArray:js.html.Uint8ClampedArray = image.data;
    
    var u8Array = haxe.io.UInt8Array.fromData(cast u8ClampedArray);
    pixels.bytes = u8Array.view.buffer;

    return pixels;
  }

  public function applyToImageData(imageData:js.html.ImageData) {
    var u8clampedArray = new js.html.Uint8ClampedArray(this.bytes.getData());
    imageData.data.set(u8clampedArray);
    return imageData;
  }

#end
}


@:allow(hxPixels.Pixels)
private class PixelsData
{
  inline static public var BYTES_PER_PIXEL:Int = 4;
  
  /** Total number of pixels. */
  public var count(default, null):Int;
  
  /** Bytes representing the pixels (in the raw format used by the original source). */
  public var bytes(default, set):Bytes;
  function set_bytes(bytes:Bytes):Bytes {
    this.bytes = bytes;
    this.uint8Array = UInt8Array.fromBytes(bytes);
    this.uint32Array = UInt32Array.fromBytes(bytes);
    return this.bytes;
  }
  
  /** Width of the source image. */
  public var width(default, null):Int;
  
  /** Height of the source image. */
  public var height(default, null):Int;
  
  /** Internal pixel format. */
  public var format:PixelFormat;
  
  public var uint8Array:UInt8Array = null;
  public var uint32Array:UInt32Array = null;
  
  /** 
   * Constructor. If `alloc` is false no memory will be allocated for `bytes`, 
   * but the other properties (width, height, count) will still be set.
   * 
   * `format` defaults to ARGB.
   */
  public function new(width:Int, height:Int, alloc:Bool = true, format:PixelFormat = null)
  {
    this.count = width * height;
    
    if (alloc) bytes = Bytes.alloc(this.count << 2);
    
    this.width = width;
    this.height = height;
    this.format = format != null ? format : PixelFormat.ARGB;
  }
}

@:expose
@:allow(hxPixels.Pixels)
class PixelFormat {
  
  static public var ARGB(default, null):PixelFormat;
  static public var RGBA(default, null):PixelFormat;
  static public var BGRA(default, null):PixelFormat;
  
  /** Internal. Don't modify any of these. */
  var channelMap:Array<Channel>;
  var ch0:Channel;
  var ch1:Channel;
  var ch2:Channel;
  var ch3:Channel;
  
  var name:String;
  
  static function __init__():Void {
    ARGB = new PixelFormat(CH_0, CH_1, CH_2, CH_3, "ARGB");
    RGBA = new PixelFormat(CH_3, CH_0, CH_1, CH_2, "RGBA");
    BGRA = new PixelFormat(CH_3, CH_2, CH_1, CH_0, "BGRA");
  }
  
  inline public function new(a:Channel, r:Channel, g:Channel, b:Channel, name:String = "PixelFormat"):Void {
    this.channelMap = [a, r, g, b];
    this.ch0 = a;
    this.ch1 = r;
    this.ch2 = g;
    this.ch3 = b;
    this.name = name;
  }
  
  public var A(get, null):Channel;
  inline private function get_A():Channel {
    return ch0;
  }
  
  public var R(get, null):Channel;
  inline private function get_R():Channel {
    return ch1;
  }
  
  public var G(get, null):Channel;
  inline private function get_G():Channel {
    return ch2;
  }
  
  public var B(get, null):Channel;
  inline private function get_B():Channel {
    return ch3;
  }
  
  public function toString():String {
    return name;
  }
}

@:enum abstract Channel(Int) to Int {
  var CH_0 = 0;
  var CH_1 = 1;
  var CH_2 = 2;
  var CH_3 = 3;
  
  @:op(A + B) static function add(a:Int, b:Channel):Int;
}

/** 
 * Abstracts an ARGB pixel over Int. 
 * 
 * NOTE: it's just a convenience class to easily access ARGB channels' values (wrapping bit math).
 * Since it's built on top of a primitive (value) type, be careful with what you expect when 
 * assigning to it. In particular consider that:
 * 
 *   `pixels.getPixel32(10, 10).R = 0xFF;`
 * 
 * will NOT modify the actual pixel (but just an Int copy/representation of it!)
 * 
 * What you really want is probably:
 * 
 *   `var pixel = pixels.getPixel32(10, 10);
 *    pixel.R = 0xFF;  // or pixel.fR = 1.0;
 *    pixels.setPixel32(10, 10, pixel);`
 * 
 * Also note that, for performance reasons, no clamping is performed when setting values, i.e.:
 * 
 *   `pixel.B = 0xFFFF;`
 * 
 * is perfectly valid, but will probably result in unwanted behaviour.
 */
@:expose
@:forward
abstract Pixel(Int) from Int to Int 
{
  public var A(get, set):Int;
  inline private function get_A():Int {
    return (this >> 24) & 0xFF;
  }
  inline private function set_A(a:Int):Int {
    this = (this & 0x00FFFFFF) | (a << 24);
    return a;
  }
  
  public var R(get, set):Int;
  inline private function get_R():Int {
    return (this >> 16) & 0xFF;
  }
  inline private function set_R(r:Int):Int {
    this = (this & 0xFF00FFFF) | (r << 16);
    return r;
  }
  
  public var G(get, set):Int;
  inline private function get_G():Int {
    return (this >> 8) & 0xFF;
  }
  inline private function set_G(g:Int):Int {
    this = (this & 0xFFFF00FF) | (g << 8);
    return g;
  }
  
  public var B(get, set):Int;
  inline private function get_B():Int {
    return this & 0xFF;
  }
  inline private function set_B(b:Int):Int {
    this = (this & 0xFFFFFF00) | b;
    return b;
  }
  
  // channels as floats (expected range is [0...1])
  public var fA(get, set):Float;
  inline private function get_fA():Float {
    return (this : Pixel).A / 255.;
  }
  inline private function set_fA(a:Float):Float {
    this = (this & 0x00FFFFFF) | (Std.int(a * 255) << 24);
    return a;
  }
  
  public var fR(get, set):Float;
  inline private function get_fR():Float {
    return (this : Pixel).R / 255.;
  }
  inline private function set_fR(r:Float):Float {
    this = (this & 0xFF00FFFF) | (Std.int(r * 255) << 16);
    return r;
  }
  
  public var fG(get, set):Float;
  inline private function get_fG():Float {
    return (this : Pixel).G / 255.;
  }
  inline private function set_fG(g:Float):Float {
    this = (this & 0xFFFF00FF) | (Std.int(g * 255) << 8);
    return g;
  }
  
  public var fB(get, set):Float;
  inline private function get_fB():Float {
    return (this : Pixel).B / 255.;
  }
  inline private function set_fB(b:Float):Float {
    this = (this & 0xFFFFFF00) | (Std.int(b * 255));
    return b;
  }
  
  // forward operators from Int (same order used in std/Int32)
  @:op(-A) function negate():Pixel;
  @:op(++A) function preIncrement():Pixel;
  @:op(A++) function postIncrement():Pixel;
  @:op(--A) function preDecrement():Pixel;
  @:op(A--) function postDecrement():Pixel;
  
  @:op(A + B) static function add(a:Pixel, b:Pixel):Pixel;
  @:op(A + B) @:commutative static function addInt(a:Pixel, b:Int):Pixel;
  @:op(A + B) @:commutative static function addFloat(a:Pixel, b:Float):Float;
  @:op(A - B) static function sub(a:Pixel, b:Pixel):Pixel;
  @:op(A - B) static function subInt(a:Pixel, b:Int):Pixel;
  @:op(A - B) static function intSub(a:Int, b:Pixel):Pixel;
  @:op(A - B) static function subFloat(a:Pixel, b:Float):Float;
  @:op(A - B) static function floatSub(a:Float, b:Pixel):Float;
  @:op(A * B) static function mul(a:Pixel, b:Pixel):Pixel;
  @:op(A * B) @:commutative static function mulInt(a:Pixel, b:Int):Pixel;
  @:op(A * B) static function mul(a:Pixel, b:Pixel):Pixel;
  @:op(A * B) @:commutative static function mulInt(a:Pixel, b:Int):Pixel;
  @:op(A * B) @:commutative static function mulFloat(a:Pixel, b:Float):Float;
  @:op(A / B) static function div(a:Pixel, b:Pixel):Float;
  @:op(A / B) static function divInt(a:Pixel, b:Int):Float;
  @:op(A / B) static function intDiv(a:Int, b:Pixel):Float;
  @:op(A / B) static function divFloat(a:Pixel, b:Float):Float;
  @:op(A / B) static function floatDiv(a:Float, b:Pixel):Float;

  @:op(A % B) static function mod(a:Pixel, b:Pixel):Pixel;
  @:op(A % B) static function modInt(a:Pixel, b:Int):Int;
  @:op(A % B) static function intMod(a:Int, b:Pixel):Int;
  @:op(A % B) static function modFloat(a:Pixel, b:Float):Float;
  @:op(A % B) static function floatMod(a:Float, b:Pixel):Float;

  @:op(A == B) static function eq(a:Pixel, b:Pixel):Bool;
  @:op(A == B) @:commutative static function eqInt(a:Pixel, b:Int):Bool;
  @:op(A == B) @:commutative static function eqFloat(a:Pixel, b:Float):Bool;

  @:op(A != B) static function neq(a:Pixel, b:Pixel):Bool;
  @:op(A != B) @:commutative static function neqInt(a:Pixel, b:Int):Bool;
  @:op(A != B) @:commutative static function neqFloat(a:Pixel, b:Float):Bool;

  @:op(A < B) static function lt(a:Pixel, b:Pixel):Bool;
  @:op(A < B) static function ltInt(a:Pixel, b:Int):Bool;
  @:op(A < B) static function intLt(a:Int, b:Pixel):Bool;
  @:op(A < B) static function ltFloat(a:Pixel, b:Float):Bool;
  @:op(A < B) static function floatLt(a:Float, b:Pixel):Bool;

  @:op(A <= B) static function lte(a:Pixel, b:Pixel):Bool;
  @:op(A <= B) static function lteInt(a:Pixel, b:Int):Bool;
  @:op(A <= B) static function intLte(a:Int, b:Pixel):Bool;
  @:op(A <= B) static function lteFloat(a:Pixel, b:Float):Bool;
  @:op(A <= B) static function floatLte(a:Float, b:Pixel):Bool;

  @:op(A > B) static function gt(a:Pixel, b:Pixel):Bool;
  @:op(A > B) static function gtInt(a:Pixel, b:Int):Bool;
  @:op(A > B) static function intGt(a:Int, b:Pixel):Bool;
  @:op(A > B) static function gtFloat(a:Pixel, b:Float):Bool;
  @:op(A > B) static function floatGt(a:Float, b:Pixel):Bool;

  @:op(A >= B) static function gte(a:Pixel, b:Pixel):Bool;
  @:op(A >= B) static function gteInt(a:Pixel, b:Int):Bool;
  @:op(A >= B) static function intGte(a:Int, b:Pixel):Bool;
  @:op(A >= B) static function gteFloat(a:Pixel, b:Float):Bool;
  @:op(A >= B) static function floatGte(a:Float, b:Pixel):Bool;

  @:op(~A) function complement():Pixel;

  @:op(A & B) static function and(a:Pixel, b:Pixel):Pixel;
  @:op(A & B) @:commutative static function andInt(a:Pixel, b:Int):Pixel;

  @:op(A | B) static function or(a:Pixel, b:Pixel):Pixel;
  @:op(A | B) @:commutative static function orInt(a:Pixel, b:Int):Pixel;

  @:op(A ^ B) static function xor(a:Pixel, b:Pixel):Pixel;
  @:op(A ^ B) @:commutative static function xorInt(a:Pixel, b:Int):Pixel;


  @:op(A >> B) static function shr(a:Pixel, b:Pixel):Pixel;
  @:op(A >> B) static function shrInt(a:Pixel, b:Int):Pixel;
  @:op(A >> B) static function intShr(a:Int, b:Pixel):Pixel;

  @:op(A >>> B) static function ushr(a:Pixel, b:Pixel):Pixel;
  @:op(A >>> B) static function ushrInt(a:Pixel, b:Int):Pixel;
  @:op(A >>> B) static function intUshr(a:Int, b:Pixel):Pixel;

  @:op(A << B) static function shl(a:Pixel, b:Pixel):Pixel;
  @:op(A << B) static function shlInt(a:Pixel, b:Int):Pixel;
  @:op(A << B) static function intShl(a:Int, b:Pixel):Pixel;
}
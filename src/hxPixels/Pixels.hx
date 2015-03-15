package hxPixels;

import haxe.io.Bytes;


/**
 * Class abstracting pixels for various libs/targets (for easier manipulation).
 * The underlying bytes will be in ARGB format (and implicitly converted to that when needed).
 * 
 * @author azrafe7
 */
@:forward
abstract Pixels(PixelsData)
{
	/** 
	 * Constructor. If `alloc` is false no memory will be allocated for `bytes`, 
	 * but the other properties (width, height, count) will still be set.
	 */
	inline public function new(width:Int, height:Int, alloc:Bool = true, format:ColorFormat = null) 
	{
		this = new PixelsData(width, height, alloc);
	}
	
	inline public function setFormat(format:ColorFormat):Void {
		this.format = format;
	}
	
	inline public function getByte(i:Int) {
		return this.bytes.get(i);
	}
	
	inline public function getPixel(x:Int, y:Int) {
		var pos = (y * this.width + x) << 2;
		
		var r = this.bytes.get(pos + 1) << 16;
		var g = this.bytes.get(pos + 2) << 8;
		var b = this.bytes.get(pos + 3);
		
		return r | g | b;
	}
	
	inline public function getPixel32(x:Int, y:Int) {
		var pos = (y * this.width + x) << 2;
		
		var a = this.bytes.get(pos + 0) << 24;
		var r = this.bytes.get(pos + 1) << 16;
		var g = this.bytes.get(pos + 2) << 8;
		var b = this.bytes.get(pos + 3);
		
		return a | r | g | b;
	}
	
	inline public function setByte(i:Int, value:Int) {
		this.bytes.set(i, value);
	}
	
	inline public function setPixel(x:Int, y:Int, value:Int) {
		var pos = (y * this.width + x) << 2;
		
		var r = (value >> 16) & 0xFF;
		var g = (value >> 8) & 0xFF;
		var b = (value) & 0xFF;

		this.bytes.set((pos + 1), r);
		this.bytes.set((pos + 2), g);
		this.bytes.set((pos + 3), b);
	}
	
	inline public function setPixel32(x:Int, y:Int, value:Int) {
		var pos = (y * this.width + x) << 2;
		
		var a = (value >> 24) & 0xFF;
		var r = (value >> 16) & 0xFF;
		var g = (value >> 8) & 0xFF;
		var b = (value) & 0xFF;

		this.bytes.set((pos + 0), a);
		this.bytes.set((pos + 1), r);
		this.bytes.set((pos + 2), g);
		this.bytes.set((pos + 3), b);
	}
	
	public function clone():Pixels {
		var clone:Pixels = new Pixels(this.width, this.height, true);
		clone.bytes.blit(0, this.bytes, 0, this.bytes.length);
		return clone;
	}
	
#if (flambe) // in flambe texture bytes are in RGBA format, and we want ARGB

	@:from static public function fromTexture(texture:flambe.display.Texture) {
		var pixels = new Pixels(texture.width, texture.height, false);
		
		// read pixels bytes in RGBA and then convert them in place to ARGB
		pixels.bytes = texture.readPixels(0, 0, texture.width, texture.height);
		Converter.RGBA2ARGB(pixels.bytes);
		
		return pixels;
	}
	
	#if (flambe && html) // not possible in (flambe && flash) due to Stage3D limitations
	public function applyTo(texture:flambe.display.Texture) {
		var bytesRGBA = Bytes.alloc(this.bytes.length);
		Converter.ARGB2RGBA(this.bytes, bytesRGBA);
		texture.writePixels(bytesRGBA, 0, 0, this.width, this.height);
	}
	#end

#end

#if (snow || luxe) // in snow/luxe texture bytes are in RGBA format, and we want ARGB
	
	@:from static public function fromSnowTexture(texture:phoenix.Texture) {
		var pixels = new Pixels(texture.width, texture.height, true);
		
		var data:snow.utils.UInt8Array = texture.asset.image.data;
		
		// read pixels bytes in RGBA and then convert them in place to ARGB
		for (i in 0...pixels.count) {
			var pos = i << 2;
			pixels.bytes.set(pos + 0, data[pos + 3]);
			pixels.bytes.set(pos + 1, data[pos + 0]);
			pixels.bytes.set(pos + 2, data[pos + 1]);
			pixels.bytes.set(pos + 3, data[pos + 2]);
		}
		
		return pixels;
	}
	
	public function applyTo(texture:phoenix.Texture) {
		var data:snow.utils.UInt8Array = texture.asset.image.data;
		for (i in 0...this.count) {
			var pos = i << 2;
			data[pos + 3] = getByte(pos + 0);
			data[pos + 0] = getByte(pos + 1);
			data[pos + 1] = getByte(pos + 2);
			data[pos + 2] = getByte(pos + 3);
		}
		texture.reset();  // rebind texture
	}

#elseif (flash || openfl || nme || (flambe && flash))

	@:from static public function fromBitmapData(bmd:flash.display.BitmapData) {
	#if js	
	
		var pixels = new Pixels(bmd.width, bmd.height);
		
		/* NOTE: alternative way, but seems slower
		var bv = bmd.getPixels(bmd.rect).byteView;

		for (i in 0...bv.length) {
			var pos = (i % 4) != 3 ? i + 1 : i - 3; // `bv` is in RGBA and we want ARGB
			pixels.bytes.set(pos, bv[i]);
		}*/
		
		for (y in 0...pixels.height) {
			for (x in 0...pixels.width) {
				pixels.setPixel32(x, y, bmd.getPixel32(x, y));
			}
		}
		
	#else
		
		var pixels = new Pixels(bmd.width, bmd.height, false);
		var ba = bmd.getPixels(bmd.rect);
		
		#if flash
			pixels.bytes = Bytes.ofData(ba);
		#else
			pixels.bytes = Bytes.ofData(ba.getData());
		#end
	
	#end
	
		return pixels;
	}
	
	public function applyTo(bmd:flash.display.BitmapData) {
	#if !js
		
		var ba = bmd.getPixels(bmd.rect);
		
		#if (openfl && !flash)
			ba.blit(0, this.bytes, 0, this.bytes.length);
		#else
			ba.position = 0;
			ba.writeBytes(this.bytes.getData());
		#end
		
		ba.position = 0;
		bmd.setPixels(bmd.rect, ba);
		
	#else
	
		for (y in 0...this.height) {
			for (x in 0...this.width) {
				bmd.setPixel32(x, y, getPixel32(x, y));
			}
		}
		
	#end
	}

#elseif java

	@:from static public function fromBufferedImage(image:java.awt.image.BufferedImage) {
		var pixels = new Pixels(image.getWidth(), image.getHeight(), true);
		
		var imageARGB = image;
		
		/* NOTE: it seems the buffer has always bytes in RGBA, so there's no need to convert
		if (image.getType() != java.awt.image.BufferedImage.TYPE_INT_ARGB) {
			trace("before", image.getType());
			imageARGB = Converter.convert(image, java.awt.image.BufferedImage.TYPE_INT_ARGB);
			trace("after", imageARGB.getType());
		}*/
		
		var buffer = new java.NativeArray<Int>(pixels.bytes.length);
		imageARGB.getRaster().getPixels(0, 0, pixels.width, pixels.height, buffer);
		
		for (i in 0...buffer.length) pixels.bytes.set(i, buffer[i]);
		Converter.RGBA2ARGB(pixels.bytes);
		
		return pixels;
	}
	
	public function applyTo(image:java.awt.image.BufferedImage) {
		var imageType = image.getType();
		
		var bytesRGBA = Bytes.alloc(this.bytes.length);
		Converter.ARGB2RGBA(this.bytes, bytesRGBA);
		
		var buffer = new java.NativeArray<Int>(this.bytes.length);
		for (i in 0...buffer.length) buffer[i] = bytesRGBA.get(i);
		
		image.getRaster().setPixels(0, 0, this.width, this.height, buffer);
	}

#elseif js	// plain js - conversion from ImageData

	@:from static public function fromImageData(image:js.html.ImageData) {
		var pixels = new Pixels(image.width, image.height, true);
		
		var data = image.data;
		
		for (i in 0...data.byteLength) {
			pixels.bytes.set(i, data[i]);
		}
		
		return pixels;
	}

#end
}

@:allow(hxPixels.Pixels)
private class PixelsData implements ArrayAccess<Int>
{
	/** Total number of pixels. */
	public var count(default, null):Int;
	
	/** Bytes representing the pixels (in `format` color format). */
	public var bytes(default, null):Bytes;
	
	/** Width of the source image. */
	public var width(default, null):Int;
	
	/** Height of the source image. */
	public var height(default, null):Int;
	
	/** Internal pixel format. */
	public var format:ColorFormat;
	
	/** 
	 * Constructor. If `alloc` is false no memory will be allocated for `bytes`, 
	 * but the other properties (width, height, count) will still be set.
	 */
	public function new(width:Int, height:Int, alloc:Bool = true, format:ColorFormat = null)
	{
		if (alloc) bytes = Bytes.alloc(this.count << 2);
		
		this.count = width * height;
		
		this.width = width;
		this.height = height;
		this.format = format != null ? format : ColorFormat.ARGB;
	}
	
	public function get(i:Int):Int {
		return bytes.get(i);
	}
	
	public function set(i:Int, value:Int):Int {
		bytes.set(i, value);
		return value;
	}
}

class ColorFormat {
	
	static public var ARGB(default, null):ColorFormat;
	static public var RGBA(default, null):ColorFormat;
	
	public var channelMap(default, null):Array<Channel>;
	
	var name:String;
	
	static function __init__():Void {
		ARGB = new ColorFormat(CHANNEL_0, CHANNEL_1, CHANNEL_2, CHANNEL_3, "ARGB");
		RGBA = new ColorFormat(CHANNEL_3, CHANNEL_0, CHANNEL_1, CHANNEL_2, "RGBA");
	}
	
	public function new(a:Channel, r:Channel, g:Channel, b:Channel, name:String = "ColorFormat"):Void {
		this.channelMap = [a, r, g, b];
		this.name = name;
	}
	
	public var A(get, null):Int;
	inline private function get_A():Int {
		return channelMap[0];
	}
	
	public var R(get, null):Int;
	inline private function get_R():Int {
		return channelMap[1];
	}
	
	public var G(get, null):Int;
	inline private function get_G():Int {
		return channelMap[2];
	}
	
	public var B(get, null):Int;
	inline private function get_B():Int {
		return channelMap[3];
	}
	
	public function toString():String {
		return name;
	}
}

@:enum abstract Channel(Int) to Int {
	var CHANNEL_0 = 0;
	var CHANNEL_1 = 1;
	var CHANNEL_2 = 2;
	var CHANNEL_3 = 3;
}

class Converter
{
	/** Converts from ARGB to RGBA. If `outBytesRGBA` is null then `inBytesARGB` will be converted in place. */
	static public function ARGB2RGBA(inBytesARGB:Bytes, ?outBytesRGBA:Bytes):Void {
		var convertInPlace = outBytesRGBA == null;
		
		if (!convertInPlace) {
			for (i in 0...inBytesARGB.length) {
				var pos = (i % 4) != 0 ? i - 1 : i + 3;
				outBytesRGBA.set(pos, inBytesARGB.get(i));
			}
		} else {
			outBytesRGBA = inBytesARGB;
			
			for (i in 0...inBytesARGB.length >> 2) {
				var pos = i << 2;
				var a = inBytesARGB.get(pos + 0);
				var r = inBytesARGB.get(pos + 1);
				var g = inBytesARGB.get(pos + 2);
				var b = inBytesARGB.get(pos + 3);
				
				outBytesRGBA.set(pos + 3, a);
				outBytesRGBA.set(pos + 0, r);
				outBytesRGBA.set(pos + 1, g);
				outBytesRGBA.set(pos + 2, b);
			}
		}
	}
	
	/** Converts from ARGB to RGBA. If `outBytesARGB` is null then `inBytesRGBA` will be converted in place. */
	static public function RGBA2ARGB(inBytesRGBA:Bytes, ?outBytesARGB:Bytes):Void {
		var convertInPlace = outBytesARGB == null;
		
		if (!convertInPlace) {
			for (i in 0...inBytesRGBA.length) {
				var pos = (i % 4) <= 3 ? i + 1 : i - 3;
				outBytesARGB.set(pos, inBytesRGBA.get(i));
			}
		} else {
			outBytesARGB = inBytesRGBA;
			
			for (i in 0...inBytesRGBA.length >> 2) {
				var pos = i << 2;
				var a = inBytesRGBA.get(pos + 3);
				var r = inBytesRGBA.get(pos + 0);
				var g = inBytesRGBA.get(pos + 1);
				var b = inBytesRGBA.get(pos + 2);
				
				outBytesARGB.set(pos + 0, a);
				outBytesARGB.set(pos + 1, r);
				outBytesARGB.set(pos + 2, g);
				outBytesARGB.set(pos + 3, b);
			}
		}
	}
	
#if java

	/** Converts `inImage` into a new image of `imageType` format. */
	static public function convert(inImage:java.awt.image.BufferedImage, imageType:Int):java.awt.image.BufferedImage
	{
		var outImage = new java.awt.image.BufferedImage(inImage.getWidth(), inImage.getHeight(), imageType);
		var g2d = outImage.createGraphics();
		g2d.drawImage(inImage, 0, 0, null);
		g2d.dispose();
		
		return outImage;
	}
#end
}
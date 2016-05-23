hxPixels
========

An _hxperimental_ (cross-target/cross-lib) Pixels abstract, in Haxe 3.1+


Simple interface to access/manipulate pixel values among different targets and libs, having a way to get/set individual pixels (or bytes), and be able to apply them back to the original source (taking care of framework-specific details under the hood).

### API

For the supported libs the following methods are implemented (**note** that all color values are in ARGB format):

 - `get`/`setPixel32()`: get/set pixel value (with alpha) at `x`,`y`
 - `get`/`setPixel()`: get/set pixel value (without alpha) at `x`,`y`
 - `get`/`setByte()`: get/set byte value at `i`
 - `clone()`: make a duplicate of the `Pixels` instance
 - `fillRect()`: fill a rect area with pixel value (with alpha)
 - `convertTo()`: convert to specified `PixelFormat`
 - `bytes`: access to the _raw_ underlying bytes (in source-specific format)
 - `format`: change internal color mapping
 
### Supported classes/libs

 - `BitmapData`: flash, openfl and nme (and flambe flash)
 - `Texture`: flambe (`applyToFlambeTexture()` only for html - not flash -, due to limitations imposed by Stage3d)
 - `BufferedImage`: java
 - `ImageData`: plain js
 - `Texture` and `AssetImage`: snow/luxe
 - png, bmp and gif: format lib
 
### Implementation

`Pixels` is an abstract over `haxe.io.Bytes`. It stores the raw bytes in the underlying `bytes` var (in source-specific color format), providing an ARGB API over them.

### Usage 
See the [src folder](https://github.com/azrafe7/hxPixels/tree/master/src) for examples on how to use it, and please file an issue if you have problems or spot a bug.

### License (MIT)
See LICENSE file.
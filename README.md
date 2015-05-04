hxPixels
========

An _hxperimental_ (cross-target/cross-lib) Pixels abstract, in Haxe 3.1+

### Objective

Common interface to access pixel values among different targets and libs, having a way to get/set individual pixels (or bytes), and be able to apply them back to the original instance.

Could be helpful if you need to manipulate raw pixels with various frameworks by using the same interface.

### API

For the supported libs the following methods are implemented* (**note** that all values are in ARGB format):

 - `get`/`setPixel32()`: get/set pixel value (with alpha) at `x`,`y`
 - `get`/`setPixel()`: get/set pixel value (without alpha) at `x`,`y`
 - `get`/`setByte()`: get/set byte value at `i`
 - `clone()`: make a duplicate of the `Pixels` instance

### Supported classes/libs

 - `BitmapData`: flash, openfl and nme (and `applyToBitmapData()` for flambe+flash)
 - `Texture`: for flambe (`applyToFlambeTexture()` only for html, due to limitations imposed by Stage3d)
 - `BufferedImage`: for java
 - `ImageData`: for plain js
 - `Texture` and `AssetImage`: for snow/luxe
 
### Implementation

`Pixels` is an abstract over `haxe.io.Bytes` and retains the source channels format in the underlying `bytes`, auto-converting to ARGB when using get/set methods (see other branches for the inverse approach).

### Usage 
<sup>See the [src folder](https://github.com/azrafe7/hxPixels/tree/master/src) for examples on how to use it, and file issues if you have problems or spot a bug.</sup>
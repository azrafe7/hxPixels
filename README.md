hxPixels
========

An hxperimental (cross-target/cross-lib) Pixels abstract, in Haxe 3.1+

Supported targets/libs:

 - `BitmapData` for flash, openfl and nme (and applyTo() for flambe-flash)
 - `Texture` for flambe (applyTo_() only for html, due to limitations imposed by Stage3d)
 - `BufferedImage` for java
 - `ImageData` for plain js
 - `Texture` for snow/luxe
 
This implementation tries to retain the source color format in the underlying `bytes`, and
auto-converts to ARGB when using get/set methods (see other branches for the inverse approach).
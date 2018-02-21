/**
 * Simple class that wraps the loading of BitmapDatas embedded via @:bitmap metatag (for openfl/nme).
 * 
 * Why?:
 * 	 In the html5 target, openfl _awesomely_ embeds BitmapData by base64 encoding it as
 * 	 a haxe.Resource. The problem is that the process of istantiating it afterwards is 
 * 	 asynchronous (as Javascript/html5 mandates). This requires the user to pass a callback 
 * 	 for every new instantiated BitmapData in order to be sure the image has finished loading.
 *  
 * 	 This class attempts to simplify the bulk-load of multiple BitmapDatas by presenting a 
 * 	 centralized onComplete callback (with optional timeout parameters), across all? targets.
 *  
 * 	 The main purpose of the approach implemented here is to be able to read/write the images' 
 * 	 raw pixel data in html5, working around common cross-origin issues.
 * 
 * Usage:
 * 	 @:bitmap("assets/smallheart.png") class Heart extends BitmapData {}
 * 	 @:bitmap("assets/background.png") class BackDrop extends BitmapData {}
 *   
 * 	 ...
 * 	 var loader = new ImageLoader();
 * 	 
 *	 loader.load([Heart, BackDrop], onLoaded, 2000, onTimeOut);
 *	 
 *   // or
 *   
 *   loader.load(["Heart", "BackDrop"], onLoaded, 2000, onTimeOut);
 * 	 ...
 *   
 * 	 function onLoaded(_) {
 * 	 	myBitmap.bitmapData = loader.getBitmapData("Heart");
 * 	 	sceneBMD = loader.getBitmapData("BackDrop");
 * 	 }
 *   
 * 	 function onTimeOut(_) {
 * 	 	// handle timeout here
 * 	 }
 */
class ImageLoader 
{
  public var map:Map<String, flash.display.BitmapData>;
  
  public function new() {
    map = new Map<String, flash.display.BitmapData>();
  }
  
  public function load(bmdClassesOrClassNames:Array<Dynamic>, onComplete:ImageLoader->Void, timeOutMs:Int = 0, ?onTimeOut:ImageLoader->Void) {
    var count = bmdClassesOrClassNames.length;	
    var timedOut = false;

    var bmdClasses:Array<Class<flash.display.BitmapData>> = [];
    
    // resolve classNames to classes
    if (Std.is(bmdClassesOrClassNames[0], String)) {
      var emptyLine = "";
      for (i in 0...bmdClassesOrClassNames.length) {
        var clsName = bmdClassesOrClassNames[i];
        var resolvedClass = Type.resolveClass(clsName);
        if (i == bmdClassesOrClassNames.length - 1) emptyLine = "\n";
        trace(clsName + ": " + (resolvedClass != null ? "ok" : "null") + emptyLine);
        bmdClasses.push(cast resolvedClass);
      }
    } else {
      bmdClasses = cast bmdClassesOrClassNames;
    }
    
    // timeout handler
    if (count > 0 && timeOutMs > 0) {
      haxe.Timer.delay(function ():Void {
        if (count != 0) {
          timedOut = true;
          if (onTimeOut != null) onTimeOut(this);
          else throw 'ImageLoader timed out (${timeOutMs/1000}s elapsed)!';
        }
      }, timeOutMs);
    }
    
    for (i in 0...bmdClasses.length) {
      var bmdClass = bmdClasses[i];
      var name = Type.getClassName(bmdClass);
    
    #if html5 // for openfl html5 the loading is async
      Type.createInstance(bmdClass, [0, 0, true, 0, function(bmd) { 
        if (timedOut) return;
        map[name] = bmd;
        count--;
        if (count == 0) onComplete(this);
      }]);
    #else
      map[name] = Type.createInstance(bmdClass, [0, 0]); 
      count--;
      if (count == 0) onComplete(this);
    #end
    }
  }
  
  public function getBitmapData(className:String) {
    var res = map[className];
    return res != null ? res : throw 'No @:bitmap named "${className}" found!';
  }
  
  public function list():Array<String> {
    return [for (k in map.keys()) k];
  }
}
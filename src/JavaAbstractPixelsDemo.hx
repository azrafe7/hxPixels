package ;

import haxe.Timer;
import hxPixels.Pixels;
import java.lang.System;
import java.javax.swing.JFrame;
import java.javax.swing.JLabel;
import java.awt.Color;
import java.awt.Dimension;
import java.awt.Graphics;
import java.awt.Graphics2D;
import java.awt.RenderingHints;
import java.javax.imageio.ImageIO;
import java.awt.image.BufferedImage;
import java.javax.swing.ImageIcon;
import java.awt.event.*;
 
class JavaAbstractPixelsDemo extends JFrame implements KeyListener {
 
	public static function main() 
    { 
        new JavaAbstractPixelsDemo(); 
    } 
    
    public function new()
    {
        super("JavaAbstractPixelsDemo");
        //System.setProperty("sun.java2d.opengl","True");
        setSize(1024, 780);
        setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        setLocationRelativeTo(null);
		
		var image:BufferedImage = null;
		try {
			image = ImageIO.read(new java.io.File("../../assets/global/galapagosColor.png"));
		} catch (e:Dynamic) {
			throw e;
		}
		
		trace(image.getWidth(), image.getHeight(), image.getType()); // https://docs.oracle.com/javase/7/docs/api/constant-values.html#java.awt.image.BufferedImage.TYPE_4BYTE_ABGR
		
		add(new JLabel(new ImageIcon(image)));
		
		// load image into pixels abstract
		var startTime = Timer.stamp();
		var pixels:Pixels = image;
		trace("load", Timer.stamp() - startTime);
		
		// add random red points
		startTime = Timer.stamp();
		for (i in 0...10000) {
			pixels.setPixel32(Std.int(Math.random() * pixels.width), Std.int(Math.random() * pixels.height), 0xFFFF0000);
		}
		// if this green line doesn't go _exactly_ from top-left to bottom-right, 
		// then there's something wrong with the Pixels impl.
		Bresenham.line(pixels, 0, 0, pixels.width - 1, pixels.height - 1, 0x00FF00);
		trace("set", Timer.stamp() - startTime);
		
		// apply the modified pixels back to image
		startTime = haxe.Timer.stamp();
		pixels.applyToBufferedImage(image);
		trace("apply", Timer.stamp() - startTime);
		
		// trace info
		trace("pixels", pixels.width, pixels.height, pixels.count, StringTools.hex(pixels.getPixel32(100, 100)));
		trace("image ", image.getWidth(), image.getHeight(), image.getWidth() * image.getHeight(), StringTools.hex(image.getRGB(100, 100)));
		
        
		setVisible(true);
		
		addKeyListener(this);
    }

    public function keyPressed(e:KeyEvent) {
		if (e.getKeyCode() == KeyEvent.VK_ESCAPE) {
			Sys.exit(1);
		}
    }
	
    public function keyTyped(e:KeyEvent) { }
	
    public function keyReleased(e:KeyEvent) { }
}
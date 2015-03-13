package ;

import haxe.Timer;
import hxPixels.Pixels;
import java.lang.System;
import javax.swing.JFrame;
import javax.swing.JLabel;
import java.awt.Color;
import java.awt.Dimension;
import java.awt.Graphics;
import java.awt.Graphics2D;
import java.awt.RenderingHints;
import java.javax.imageio.ImageIO;
import java.awt.image.BufferedImage;
import javax.swing.ImageIcon;
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
		trace("set", Timer.stamp() - startTime);
		
		// apply the modified pixels back to image
		startTime = haxe.Timer.stamp();
		pixels.applyTo(image);
		trace("apply", Timer.stamp() - startTime);
		
		// trace info
		trace("pixels", pixels.width, pixels.height, pixels.count, StringTools.hex(pixels.getPixel32(300, 300)));
		trace("image ", image.getWidth(), image.getHeight(), image.getWidth() * image.getHeight(), StringTools.hex(image.getRGB(300, 300)));
		
        
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
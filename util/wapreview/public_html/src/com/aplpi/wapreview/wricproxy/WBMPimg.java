package com.aplpi.wapreview.wricproxy;

import java.awt.Graphics;
import java.awt.Image;
import java.awt.Toolkit;

import java.awt.Component;
import java.awt.Color;
import java.io.DataInputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.io.InputStream;
import java.net.URL;
import Acme.JPM.Encoders.GifEncoder;
/**
 * 
 * see http://wapreview.sourceforge.net
 *
 * Copyright (C) 2000 Robert Fuller, Applepie Solutions Ltd. 
 *                    <robert.fuller@applepiesolutions.com>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 *

 * This class reads a WBMPimage stream, renders the image
 * on a component, and passes the image to the Acme gifencoder
 * to convert the image to a gif.
 *
 * @see Acme.JPM.Encoders.GifEncoder
 */
public class WBMPimg{

  public void wbmp2gif(Component c, InputStream in, OutputStream out)
   throws IOException {
    DataInputStream wbmp = new DataInputStream(in);
    Image i = createWBMP(c,wbmp);
    if(i!=null){
      GifEncoder gif = new GifEncoder(i,out);
      gif.encode();
    }
  }
  private Image getImage(Component c){
    Image i = Toolkit.getDefaultToolkit().getImage("tiny.gif");
    i.flush();
    return(i);
  }
  public Image createWBMP(Component c, DataInputStream wbmp) {
    Image i;// = getImage(c);
    try {
      wbmp.readByte();
      wbmp.readByte();
      int width = wbmp.readByte();
      int height = wbmp.readByte();
      i = c.createImage(width,height);
      if(i == null){
        System.err.println("Could not create image"
                           +" height:"+height
                           +" width:"+width
          );
        return null;
      }
      Graphics g = i.getGraphics();
      if(g == null){
        System.err.println("Could not get graphics");
        return null;
      }
      g.setColor(new Color(106,186,123));
      g.fillRect(0,0,width,height);
      for (int y=0;y<height;y++)
        for (int x=0;x<width;x+=8) {
          byte b = (byte)~wbmp.readByte();
          for (int x1=x; b!=0 && x1<width;x1++,b<<=1)
            if ((b & 128)!=0) {
              g.setColor(Color.black);
              g.fillRect(x1,y,1,1);
            }
        }
    g.drawImage(i,0,0,c);
    } catch (Exception e) {
      System.err.println("Error converting image:" + e.toString());
      e.printStackTrace();
      return null;
    }
    try{
      wbmp.close();
    } catch (Exception e) {
      System.err.println("Error closing file:" + e.toString());
      return null;
    }
    return i;
  }
}

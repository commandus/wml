package com.aplpi.wapreview;

import java.lang.String;
import java.lang.StringBuffer;

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

 * The template is used by the WmlDeckBuilder to capture the
 * events specified in the &lt;template&gt element, and assign
 * these to the deck.  Once an object of this class has been
 * created it is treated by the WmlDeckBuilder as any other card,
 * however internally it simply passes the relevant contained items 
 * to the WmlDeck to deal with.
 *
 * @author Copyright (c) 2000, Applepie Solutions Ltd.
 * @author Written by Robert Fuller &lt;robert.fuller@applepiesolutions.com&gt;
 *
 */
public class WmlTemplate implements WmlCardInterface{
  private WmlDeckInterface deck;
  
  public WmlTemplate(WmlDeckInterface mdeck){
    deck = mdeck;
  }
  
  public WmlDeckInterface deck(){
    return deck;
  }
  
  public void cardData(String S){
  }
  
  public void navData(String S){
  }
  
  public void onenterforward(String S){
    deck.onenterforward(S);
  }

  public void onenterbackward(String S){
    deck.onenterbackward(S);
  }

  public void ontimer(String S){
    deck.ontimer(S);
  }

  public String name(){
    return("_aplpi_template_");
  }
  public void beginSelect(String s1, String s2, String s3, 
                          String s4, String s5, boolean b){
  }
  public void endSelect(){
  }
  public void addOption(String s1, String s2, String s3){
  }

}

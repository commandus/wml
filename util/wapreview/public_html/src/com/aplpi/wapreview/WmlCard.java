package com.aplpi.wapreview;

import java.lang.String;
import java.lang.StringBuffer;
import java.util.Hashtable;
import java.util.Vector;
import java.util.Enumeration;
import java.io.IOException;

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

 * A WML card belongs to a WML deck.
 * The methods used by WmlDeckBuilder when creating
 * decks, and by applet responsible for displaying
 * the cards.
 *
 * @author Copyright (c) 2000, Applepie Solutions Ltd.
 * @author Written by Robert Fuller &lt;robert.fuller@applepiesolutions.com&gt;
 *
 * @see WmlCardInterface
 * @see WmlDeck
 * @see WmlDeckBuilder
 */
public class WmlCard implements WmlCardInterface{
  private StringBuffer cardData;
  private Vector navData;
  private Vector cardparts;
  private StringBuffer onenterforward;
  private StringBuffer onenterbackward;
  private String ontimer;
  private WmlCard myOptionsCard;
  private WmlDeckInterface deck;
  private WmlSelect currentSelect;
  private Hashtable selects;
    private String name;
  //private String nextCard;

  /**
   * Construct a new card of the given name, belonging to the given deck.
   * This method is used by WmlDeckBuilder when constructing the card.
   *
   * @param mdeck The deck to which this card belongs.
   * @param mname The name of this card.
   */
  public WmlCard(WmlDeckInterface mdeck, String mname){
    name = mname;
    deck = mdeck;
    cardData = new StringBuffer();
    cardparts = new Vector();
    navData = new Vector();
    selects = new Hashtable();
    myOptionsCard = null;
  }

  /**
   * return the name of this card.
   *
   */
  public String name(){
    return this.name;
  }
  
  /**
   * print some useful information to STDERR (for debugging)
   *
   */
  public void dump(){
    System.err.println("Card:"+name);
    System.err.println("    cardData:"+cardData);
    System.err.println("     navData:"+navData);
    System.err.println("     onenterforward:" + onenterforward());
    System.err.println("    onenterbackward:"+ onenterbackward());
    System.err.println("    ontimer:"+ontimer);
    System.err.println("---------------------------------------");
  }
  
  /**
   * Return the deck to which this card belongs
   *
   */
  public WmlDeckInterface deck(){
    return deck;
  }
  
  /**
   * Append a string to the dhtml representation of the card.
   * This method is used by WmlDeckBuilder when constructing the card.
   */
  public void cardData(String S){
    if(S != null){
	    cardData.append(S);
    }
  }
  
  /**
   * Begin a &lt;select&gt; item.  This method is used by
   * WmlDeckBuilder when constructing the card.
   */
  public void beginSelect(String title_, String name_, 
                          String value_, String iname_,
                          String ivalue_, boolean multiple_){
    WmlSelect sel = new WmlSelect(deck, title_, name_, 
                                  value_, iname_, ivalue_, 
                                  multiple_, selects.size()+1);
    selects.put(sel.name(), sel);
    currentSelect = sel;
    cardparts.addElement(cardData);
    cardparts.addElement(sel);
    cardData = new StringBuffer();
  }

  /**
   * End of the current &lt;select&gt; element
   */
  public void endSelect(){
    currentSelect =  null;
  }
  
  /**
   * select the specified option in the appropriate
   * select group.  Returns a value to indicate whether
   * or not the option is currently selected.
   */
   public boolean selectitem(String group, int optionIndex){
     WmlSelect s = (WmlSelect) selects.get(group);
     if(s == null){
       return false;
     }
     return(s.select(optionIndex));
   }
  
  /**
   * Add the option onto the current select element
   */
  public void addOption(String value_, String title_, String onpick_){
    if(currentSelect != null){
      currentSelect.addOption(value_, title_, onpick_);
    }else{
      System.err.println("<option> outside of <select>?");
    }
  }
  /**
   * Return a dhtml representation of this card.  This method is
   * invoked from the wapreview applet.
   */
  public String cardData(){
    String s = "";
    Enumeration e = cardparts.elements();
    while(e.hasMoreElements()){
      Object o = e.nextElement();
      s+=o.toString();
    }
    s += cardData.toString();
    try{
	    s = deck.expandVariables(s);
    }
    catch(java.io.IOException E){
    }
    //System.err.println(s);
    return "<form>"+s+"</form>";
  }
  
  /**
   * Add a string representing a navigation belonging to this card.
   * This method is used by WmlDeckBuilder when constructing the card,
   * and is invoked for each navigational option identified on the card.
   */
  public void navData(String S){
    if(S != null){
	    navData.addElement(S);
    }
  }
  
  /**
   * Return the dhtml representation of navigational data belonging to 
   * this card.  This method is invoked by the wapreview applet.
   */
  public String navData(){
    /*
     * options will appear on a separate card.  There will
     * be a link to the options card if there are options.
     * The 'back' link will always appear.
     */
    String prev = "<td><font size=2><a href=\"javascript:prevCard();\">"
	    +"<em>back</em></a></font></td>";
    String optCardName = "aplpioptions_"+this.name;
    String options = "";
    
    if(myOptionsCard == null && !navData.isEmpty()){
	    //put the navigations on an options card
      
	    myOptionsCard = new WmlCard(deck, optCardName);
	    deck.addCard(myOptionsCard);
	    Enumeration enum = navData.elements();
	    while(enum.hasMoreElements()){
        String s = (String) enum.nextElement();
        myOptionsCard.cardData(s+"<br>");
	    }
	    navData.removeAllElements();
	    
    }
    
    if(myOptionsCard != null){
	    //put 'options' in the navigation area.
	    options = "<td><font size=2><a href=\"javascript:setCard('#"
        +optCardName+"');\"><em>options</em></a></font></td>";
    }
    String s = prev+options;
    try{
	    s = deck.expandVariables(prev+options);
    }
    catch(java.io.IOException E){
    }
    return "<table><tr>"+s+"</tr></table>";
  }
  
  /**
   * Set the named variable to the specified value.  The variable is
   * global accross all cards belonging to the deck to whiich this
   * card belongs.
   *
   */
  public String setVar(String key, String value){
    return deck.setVar(key,value);
  }
  
  /**
   * Return the value of the specified variable.  The variable is 
   * global accross all cards belonging to the deck to which this
   * card belongs.
   */
  public String getVar(String key){
    return deck.getVar(key);
  }
  
  /**
   * Return the next card in the deck.
   *
   */
  //    public String nextCard(){
  //      return nextCard;
  //    }
  
  /**
   * Set the dhtml of the action to perfom on an onenterforward event.
   * This method is used by WmlDeckBuilder when constructing the card.
   *
   */
  public void onenterforward(String S){
    if(S != null){
      if(onenterforward == null){
        onenterforward = new StringBuffer(S);
      }else{
        onenterforward.append(S);
      }
    }
  }
  
  /**
   * Return the dhtml of the action to perfom on an onenterforward event.
   * This method is accessed from the wapreview applet.
   *
   */   
  public String onenterforward(){
    String s;
    if(onenterforward != null){
	    s= onenterforward.toString();
    }else{
	    s=deck.onenterforward();
    }
    try{
	    s = deck.expandVariables(s);
    }
    catch(java.io.IOException E){
    }
    return s;
  }
  
  /**
   * Set the dhtml of the action to perfom on an onenterbackward event.
   * This method is used by WmlDeckBuilder when constructing the card.
   *
   */
  public void onenterbackward(String S){
    if(S != null){
      if(onenterbackward == null){
        onenterbackward = new StringBuffer(S);
      }else{
        onenterbackward.append(S);
      }
    }
  }
  
  /**
   * Return the dhtml of the action to perfom on an onenterbackward event.
   * This method is accessed from the wapreview applet.
   *
   */
  public String onenterbackward(){
    String s;
    if(onenterbackward != null){
	    s=onenterbackward.toString();
    }else{
	    s=deck.onenterbackward();
    }
    try{
	    s = deck.expandVariables(s);
    }
    catch(java.io.IOException E){
    }
    return s;
  }
  
  /**
   * Return the dhtml of the action to perfom on an ontimer event.
   * This method is accessed from the wapreview applet.
   *
   */
  public String ontimer(){
    String s;
    if(ontimer != null){
	    s = ontimer.toString();
    }else{
	    s = deck.ontimer();
    }
    try{
	    s = deck.expandVariables(s);
    }
    catch(java.io.IOException E){
    }
    return s;
  }
  
  /**
   * Set the dhtml of the action to perfom on an ontimer event
   * This method is used by WmlDeckBuilder when constructing the card.
   *
   */    
  public void ontimer(String S){
    if(S != null){
	    ontimer = S;
    }
  }
  
  /**
   * Return the (javascript) value of the timer value for this card
   *
   */
  public String getCardTimerValue(){
    String timeout= deck.getVar("aplpicardtimeout"+name);
    if(timeout.equals("")){
	    timeout = "-1";
    }else if(timeout.startsWith("$")){
	    timeout=deck.getVar(timeout.substring(1))+"00";
    }
    return timeout;
  }
  
}


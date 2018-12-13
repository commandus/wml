package com.aplpi.wapreview;

import java.applet.*;
import java.util.Stack;

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

 * Wapreview WML User Agent Applet
 * <p>This applet exposes a set of public methods which allow the
 * javascript component of Wapreview to access the java functionality
 * responsible for retrieving and parsing the WML deck.
 * <p>Once the WML deck has been retrieved and parsed, the javascript
 * component calls upon this applet to perform actions on behalf of
 * the user.  These actions include:
 * <ul>
 * <li> Set the value of a variable
 * <li> Get the value of a variable
 * <li> Produce the (D)HTML used to render a card
 * <li> Produce a javascript representation of intrinsic events:
 *   <ul>
 *   <li> onenterforward
 *   <li> onenterbackward
 *   <li> ontimer
 *   </ul>
 * <li> Navigate to another WML card within this deck
 * <li> Navigate to a card within an external WML deck via HTTP GET
 * <li> Navigate to a card within an external WML deck via HTTP POST
 * <li> Maintain state information
 * <li> Maintain history
 * </ul>
 * @author Copyright (c) 2000 by Applepie Solutions Ltd.
 * @author written by Robert Fuller &lt;robert.fuller@applepiesolutions.com&gt;
 */
public class Wapreview extends Applet{
  private Stack decks;
  private Stack cards;
  private WmlDeck deck;
  private WmlCard card;
  private boolean debugging = false;
  private String imgconverter;
  private String gateway;
  private String homeurl = null;
  
  /**
   * Returns the HREF at the specified index.  The HREF will 
   * consist of a line of javascript which will be eval()'d
   * by the javascript component of wapreview.  The javascript
   * returned by this method will have all variables expanded
   * appropriately.
   *
   * This method is typically invoked when a user performs an
   * action which triggers a dHTML event, eg: by clicking on a
   * HTML link or by entering text in a textbox.
   *
   * @param index The index of the HREF to retrieve.
   */
  public String getHref(int index){
    if(debugging)System.err.println("getHref:"+index);
    String href = "alert(\"href ["+index+"] not found\")";
    if(deck != null){
	    href = deck.getHref(index);
    }
    if(debugging)System.err.println("getHref:"+href);
    return href;
  }
  
  /**
   * turn on or off debugging mode
   */
  public void debug(boolean onoff){
    debugging=onoff;
  }
  /**
   * select (or unselect) an option in a select
   * list... all display management is handled in javascript.
   */
  public boolean selectitem(String group, int itemno){
    if(card == null){
      return false;
    }
    return(card.selectitem(group, itemno));
  }

  /**
   * Sets the value of a WML variable.  The variable of the
   * specified name is set to the specified value.  The value
   * can be accessed by any card within the current deck.
   *
   * @param name The name of the variable.
   * @param value The value to assign to the variable.
   *
   */ 
  public void setVar(String name, String value){
    if(debugging)System.err.println("setVar:"+name+"="+value);
    if(card != null){
	    card.setVar(name,value);
    }
  }

  /**
   * Returns the value of the named variable.
   * 
   * @param name The name of the variable.
   *
   */
  public String getVar(String name){
    if(debugging)System.err.println("getVar:"+name);
    if(card != null){
	    return card.getVar(name);
    }
    return "1";
  }

  /**
   * Returns the main content of the current WML card.  The content
   * of the card is returned in a format which can be rendered
   * within the web browser in which the javascript component of
   * wapreview is being interpreted.
   *
   */
  public String getCardData(){
    String cd = "<br><br><center><b>Sorry!</b><br>This simulator failed<br>to load the card!</center><br>This may be because the url was incorrect, or because there was a problem parsing the wml.";
    if(card != null){
	    cd = card.cardData();
    }
    if(debugging)System.err.println("getCardData:"+cd);
    return cd;
  }

  /**
   * Returns the navigational content of the current WML card.
   * The navigational content of the card is returned in a format 
   * which can be rendered within the web browser in which the 
   * javascript component of wapreview is being interpreted.  The
   * javascript component of wapreview renders this content in a different
   * HTML <em>layer</em> or <em>div</em> than the main content of the card.
   */
  public String getNavData(){
    String nd = "<table><tr><td><font size=2><a href=\"javascript:prevCard()\">back</a></font></td></tr></table>";
    if(card != null){
	    nd = card.navData();
    }
    if(debugging)System.err.println("getNavData:"+nd);
    return nd;
  }
  /**
   * Returns the timer value of the timer for the current card.
   * (-1 is returned if there is no timer)
   * The javascript component of wapreview retrieves the timer value
   * when the card displayed.  If there is a timer value, the javascript
   * component sets a timer, upon expiration of which the ontimer() event
   * is triggered.
   */
  public int getCardTimerValue(){
    String ti = "-1";
    if(debugging)System.err.println("in getCardTimerValue:"+ti);
    if(card != null){
	    ti = card.getCardTimerValue();
    }
    int i;
    try{
	    i=Integer.parseInt(ti);
    }catch(Exception E){
	    i=-1;
    }
    if(debugging)System.err.println("getCardTimerValue:["+ti+"]"+i);
    return i;
  }

  /**
   * Returns the URL of the currently loaded deck
   */
  public String currentURL(){
    String url = "http://";
    if(deck != null){
      url = deck.url;
      if(url == null || url.equals("")){
        url = "http://";
      }
    }
    return(url);
  }
  /**
   * Returns the source WML for the currently loaded deck
   */
  public String getSource(){
    String source = "Source not available";
    if(deck != null){
      source = deck.wml();
    }
    return(WmlDeckBuilder.encode(source,true));
  }

  /**
   * Causes the current deck to be reloaded.  The http method and 
   * parameters used in reloading the deck will be the same
   * as those used to retrieve the deck initially.
   */
  public void reloadDeck(){
    if(debugging)System.err.println("reloadDeck:");
    if(deck != null){
	    setCard(deck.url);
    }
  }

  /**
   * Retrieves a WML deck using an HTTP POST.
   *
   * @param index The index of the HREF to POST to.
   */
  public void post(int index){
    // use the post method to load a url
    WmlTask t = deck.getTask(index);
    if(t != null){
	    WmlDeckBuilder df = new WmlDeckBuilder(deck, t);
	    if(imgconverter != null){
        df.imgconverter=imgconverter;
	    }
	    if(gateway != null){
        df.gateway=gateway;
	    }

	    card = startparse(df);
	    if(card != null){
        cards.push(card);
	    }
    }
  }
  
  /**
   * Sets the current card to the one specified.
   * If the card specified begins with '#', the card will
   * be sought within the current deck, otherwise a
   * new deck will be created from the specified URL.
   * If the url specifies a card within a deck (ie., it
   * contains, but does not begin with '#'), the specified
   * card will be the current card, otherwise the first
   * card in the deck will used.
   *
   * @param url The url identifying the target card.
   */
  public void setCard(String url){
    if(debugging)System.err.println("setCard:"+url);
    if(url.startsWith("#")){
      card=deck.getCard(url.substring(1));
    }else{
	    // pass the deckfactory constructor a reference to
	    // the current deck, because it may need to extract
	    // variables for posting (change this later to pass
	    // it a byte array of post data, since in some cases
	    // we will not want to pass this data ... as in when
	    // a user enters a new url).
	    WmlDeckBuilder df = new WmlDeckBuilder(deck, url);
	    if(imgconverter != null){
        df.imgconverter=imgconverter;
	    }
	    if(gateway != null){
        df.gateway=gateway;
	    }
	    card = startparse(df);
    }
    if(card != null){
	    cards.push(card);
	    if(homeurl==null){
        homeurl=url;
	    }
    }
  }

  /**
   * Cause the specified WmlDeckBuilder to begin
   * the activity of retrieving the specified URL
   * and parsing the WML content.
   */
  private WmlCard startparse(WmlDeckBuilder df){
    deck = df.startParse();
    WmlCard card = null;
    if(deck != null){
	    if(debugging)deck.dump();
	    decks.push(deck);
	    card = deck.firstcard;
    }
    return card;
  }

  /**
   * Sets the current card to the previous card.  This
   * allows the user to navigate up the history stack.
   */
  public void prevCard(){
    if(debugging)System.err.println("prevCard:");
    if(!cards.isEmpty()){
	    card=(WmlCard)cards.pop(); // current card
    }
    if(!cards.isEmpty()){
	    card=(WmlCard)cards.peek(); // prev card
    }else{
	    cards.push(card);
    }
    deck = (WmlDeck)card.deck();
  }
  
  /**
   * Returns the javascript representation of the
   * actions to be performed when an onenterforward
   * event occurs on the current card.  This javascript
   * is eval()'d by the javascript component of wapreview.
   */
  public String onenterforward(){
    String oef="//";//alert(\"java:on enter forward\")";
	  if(card != null){
	    oef = card.onenterforward();
	  }
	  if(debugging)System.err.println("onenterforward:"+oef);
	  return oef;
  }

  /**
   * Returns the javascript representation of the
   * actions to be performed when an onenterbackward
   * event occurs on the current card.  This javascript
   * is eval()'d by the javascript component of wapreview.
   */
    public String onenterbackward(){
      String oeb = "//";//"alert(\"java:on enter backward\")";
      if(card != null){
        oeb = card.onenterbackward();
      }
      if(debugging)System.err.println("onenterbackward:"+oeb);
      return oeb;
    }

  /**
   * Returns the javascript representation of the
   * actions to be performed when an ontimer
   * event occurs on the current card.  This javascript
   * is eval()'d by the javascript component of wapreview.
   */
  public String ontimer(){
    String ot = "//";//"alert(\"java:on timer\")";
    if(card != null){
	    ot = card.ontimer();
    }
    if(debugging)System.err.println("ontimer:"+ot);
    return ot;
  }
  
  /**
   * Returns the a string contianing the URL used
   * to identify the first deck retrieved by the
   * applet.
   */
  public String homeurl(){
    return(homeurl);
  }

  /**
   * Initialises the applet.  Two applet parameters are
   * expected: a url for the image converter, and a
   * url for the gateway.
   */
  public void init(){
    decks = new Stack();
    cards = new Stack();
    imgconverter = this.getParameter("imgconverter");
    gateway = this.getParameter("gateway");
  }
}

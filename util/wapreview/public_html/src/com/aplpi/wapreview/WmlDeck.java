package com.aplpi.wapreview;

import java.net.URL;

import java.util.Hashtable;
import java.util.Stack;
import java.util.Enumeration;

import java.io.ByteArrayOutputStream;
import java.io.ByteArrayInputStream;
import java.io.PushbackInputStream;
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

 * This class represents a WmlDeck containing WmlCards.
 * The deck is constructed by the WmlDeckBuilder, based
 * upon the content of a WML deck retrieved from a URL.
 * The deck contains all the cards within the WML deck,
 * and provides common resources which include:
 *
 * @author Copyright (c) 2000, Applepie Solutions Ltd.
 * @author Written by Robert Fuller &lt;robert.fuller@applepiesolutions.com&gt;
 *
 * <ul>
 * <li> Variable expansion
 * <li> Template level events.
 * </ul>
 * @see WmlDeckBuilder
 */
public class WmlDeck implements WmlDeckInterface{

  public int unknownCards = 0;
  private Hashtable cards;
  private Stack deck;
  private Stack hrefs;
  private Hashtable variables;
  private String onenterforward;
  private String onenterbackward;
  private String ontimer;
  public WmlCardInterface currentcard;
  public WmlCard firstcard;
  public String url;
  private String sourcecode;
  private URL sourceUrl = null;
  private Stack tasks;
  private Stack htasks;
  private String targetCard = null;
  public String awaitingtask = null;
  
  /* variable substitiution state model */
  private final static int st_outvar = 0;
  private final static int st_beginvar = 1;
  private final static int st_invar = 2;
  private final static int st_esc = 3;

  /* variable escaping */
  public final static int V_NOESC = 0;
  public final static int V_ESCAPE = 1;
  public final static int V_UNESC = 2;
  
  /**
   * Constructs and initialises new deck, identifying the URL used
   * as a source.
   * 
   * @param U The source url for this deck.
   */
  public WmlDeck(URL U){
    sourceUrl = U;
    String u = sourceUrl.toString();
    int i;
    // a '#' in the url means there is a target card
    if((i=u.indexOf('#'))>-1){
      int j;
      if(((j=u.indexOf('?'))>i)||((j=u.length())>0)){
        if(j>i+1){
          targetCard=u.substring(i+1,j);
//System.err.println("target card is["+targetCard+"]");
        }
      }
    }
    this.init();
  }

  /**
   * Constructs and initialises a new deck.
   */
  public WmlDeck(){
    this.init();
  }

  /**
   * Initialise the new deck.
   */
  private void init(){
    cards = new Hashtable();
    //history = new Stack();
    deck = new Stack();
    tasks = new Stack();
    htasks = new Stack(); // temporary for during construction.
    variables = new Hashtable();
    hrefs = new Stack();
    onenterforward = new String();
    onenterbackward = new String();
    ontimer = new String();
    currentcard = new WmlTemplate(this);
  }

  /**
   * Sets a variable which is shared among all the cards
   * in the deck.
   *
   * @param varName The name of the variable
   * @param varValue The value to assign to the named variable
   */
  public String setVar(String varName, String varValue){
    //System.err.println("setVar(\""+varName+"\",\""+varValue+"\");");
    variables.put(varName, varValue);
    return(varName);
  }

  /**
   * Returns the value of the named variable.
   *
   * @param varName The name of the variable.
   * parses, but ignores variable escaping $(foo:escape)
   */
  public String getVar(String varName){
    //System.err.println("getVar("+varName+")");
    // remove surrounding ()'s
    if(varName.startsWith("(")){
	    varName = varName.substring(1);
    }
    if(varName.endsWith(")")){
	    varName = varName.substring(0, varName.length()-1);
    }
    if(varName.indexOf(':')>0){
      // ignore escaping for now
      varName = varName.substring(0,varName.indexOf(':')-1);
    }
    String val = (String)variables.get(varName);
    if(val == null){val = "";}
    return val;
  }
  
  /**
   * Returns the javascript representation of the ontimer
   * event for this deck.
   * This method is invoked by cards which do not have their
   * own ontimer event specified.
   */
  public String ontimer(){
	  return ontimer;
  }
  
  /**
   *  Sets the source wml for this deck
   */
  public void wml(String source){
    sourcecode = source;
  }
  
  /**
   * Returns the source wml for this deck
   */
  public String wml(){
    return(sourcecode==null?"No source is available":sourcecode);
  }
  
  /**
   * Returns the javascript representation of the onenterforward
   * event for this deck.
   * This method is invoked by cards which do not have their
   * own ontimer event specified.
   */
 
  public String onenterforward(){
    return onenterforward;
  }

  /**
   * Returns the javascript representation of the onenterbackward
   * event for this deck.
   * This method is invoked by cards which do not have their
   * own ontimer event specified.
   */
  public String onenterbackward(){
    return onenterbackward;
  }

  /** 
   * Sets the javascript representation of the onenterforward
   * event for this deck.
   * This method may be invoked by the WmlDeckBuilder during
   * construction of this deck.
   */
    public void onenterforward(String s){
      onenterforward = new String(s);
    }

  /** 
   * Sets the javascript representation of the onenterbackward
   * event for this deck.
   * This method may be invoked by the WmlDeckBuilder during
   * construction of this deck.
   */
  public void onenterbackward(String s){
    onenterbackward = new String(s);
  }
  /** 
   * Sets the javascript representation of the ontimer
   * event for this deck.
   * This method may be invoked by the WmlDeckBuilder during
   * construction of this deck.
   */
  public void ontimer(String s){
    ontimer=s;
  }

  /**
   * Returns the named card.  If the named card cannot be found,
   * a new card indicating this situation is constructed and returned.
   *
   * @param cardName The name of the wanted card.
   */
  public WmlCard getCard(String cardName){
    // return an "unknown card" or the sought one.
    WmlCard card = new WmlCard(this, "unknown");
    card.cardData("<center><b>card "+cardName+" not found!</b></center>");
    //if(cards.contains(cardName)){
    WmlCard foundcard = (WmlCard)cards.get(cardName);
    if(foundcard != null){
      card = foundcard;
    }
    return card;
  }

  /**
   * Add the specified card onto this Deck.
   * An explicit typecast is to convert the card from
   * an Object into a WmlCard in order to avoid
   * circular dependencies between WmlCardInterface 
   * and WmlDeckInterface.  This method simply invokes
   * the addCard(WmlCard card) method after performing
   * the typecast.
   * This method may be invoked by the WmlDeckBuilder during
   * construction of this deck.
   *
   * @param card The card to be added to the deck.
   */
  public void addCard(Object card){
    this.addCard((WmlCard)card);
  }

  /**
   * Add the specified card onto this Deck.
   * This method may be invoked by the WmlDeckBuilder during
   * construction of this deck.
   *
   * @param card The card to be added to the deck.
   */
  public void addCard(WmlCard card){
    deck.push(card);
    cards.put(card.name(), card);
    currentcard = card;
    if(firstcard==null){
	    firstcard=card;
    }else if(targetCard!=null && targetCard.equals(card.name())){
      // target card was known by #id in url...
      firstcard=card;
    }
  }
    
  /**
   * Create and return a new WmlTask belonging to this
   * Deck.  This method may be invoked by WmlDeckBuilder
   * during construction of this deck.  The new deck is
   * pushed onto a stack of tasks held to the deck
   * and also onto a stack of task which are currently
   * open during parsing.
   *
   * @see WmlTask
   *
   **/
  public WmlTask newTask(){
    int i = tasks.size();
    WmlTask t =  new WmlTask(this, i);
    tasks.push(t);
    if(awaitingtask != null){
	    // we were waiting for this task to arrive!!
	    if(awaitingtask.equals("onenterforward")){
        currentcard.onenterforward("reval(getHref("+i+"));");
	    }else if(awaitingtask.equals("onenterbackward")){
        currentcard.onenterbackward("reval(getHref("+i+"));");
      }else if(awaitingtask.equals("ontimer")){
        currentcard.ontimer("reval(getHref("+i+"));");
      }
    }
    htasks.push(t); // temporary holding area.
    return(t);
  }

  /**
   * Removes a task from a stack of tasks which are open
   * during parsing of the WML content.  This method is invoked
   * by WmlDeckBuilder during construction of the deck.
   **/
  public void endTask(){
    htasks.pop();
  }

  /**
   * Returns the WmlTask at the specified index.
   *
   * @param index The index identifying the wanted task.
   */
  public WmlTask getTask(int index){
    return (WmlTask)tasks.elementAt(index);
  }
 
  /**
   * Returns the current task, if one exists.
   * This method may be invoked by the WmlDeckBuilder
   * during construction of this deck.
   */ 
  public WmlTask currentTask(){
    if(htasks.isEmpty()){
	    return(null);
    }
    return (WmlTask)htasks.peek();
  }

  /**
   * Returns the javascript required to invoke the
   * task at the specified index.
   *
   * @param index The index of the wanted reference.
   */
  public String getHref(int index){
    WmlTask t = this.getTask(index);
    String href = "alert(\"unknown task "+index+"\");";
    if(t != null){
	    href = t.getInvocation();
    }
    return href;
  }

  /**
   * Returns a count of the number of tasks belonging to
   * this deck.
   */
  public int countTasks(){
    return tasks.size();
  }

  /**
   * Resolves and returns a string representing a url.
   * This method may be invoked by WmlDeckBuilder during
   * construction of this deck in order to resolve any
   * url's contained within the deck.
   *
   * @param url A string representing the url to be resolved.
   */
  public String resolveUrl(String url){
    //System.err.println("resolving url:["+url+"]");
    //return docbase+"?url="+url;
    if(url == null || url.equals("")){
      //url = "#?????";
      url = sourceUrl.toString();
    }else if(url.startsWith("#")){
	    // return url;
    }else if(url.toLowerCase().startsWith("http://")
      || url.toLowerCase().startsWith("file://")){
	    // return url;
    }else{
	    //make the url relative to the
	    //originating doc.
	    try{
        url = new URL(sourceUrl, url).toString();
	    }
	    catch(java.net.MalformedURLException E){
        url = "#unknown";
	    }
    }
    //System.err.println("resolved to:["+url+"]");
    // protect any $variables in the url..
     int i=0;
     while(i<url.length()){
       switch(url.charAt(i)){
        case '$':
          url = (i>0?url.substring(0,i):"")
            +"$$"
            +(i<url.length()-1?url.substring(i+1):"");
          i+=2;
          break;
         default:
           i++;
       }
     }
    return(url);
  }

  /**
   * Dump all the cards belonging to this deck.
   * The dump() method will be invoked on each card
   * belonging to this deck.  This method is useful
   * for debugging purposes.
   */
  public void dump(){
    Enumeration e = deck.elements();
    while(e.hasMoreElements()){
	    WmlCard c = (WmlCard) e.nextElement();
	    c.dump();
    }
  }

  /**
   * Expand any $variables in the string with
   * their corresponding values.
   * Escape modes are parsed but ignored.
   * eg $(var:unesc) == $(var) == $(var:escape) == $(var:noesc)
   *
   * @param s The string which may contain variables 
   */
  public String expandVariables(String s) 
    throws java.io.IOException{
    // expand $variables with their
    // corresponding values.
    if(s==null){
	    return null;
    }
    StringBuffer outstr = new StringBuffer();
    ByteArrayOutputStream os = new ByteArrayOutputStream();
    ByteArrayOutputStream var = new ByteArrayOutputStream();
    ByteArrayOutputStream esc = new ByteArrayOutputStream();
    PushbackInputStream p = 
	    new PushbackInputStream(new ByteArrayInputStream(s.getBytes()));
    int c;
    int state = st_outvar;
    boolean vardelim=false; // $var vs $(var)
    int escmode = V_NOESC;

    while((c=p.read())!=-1){
	    switch(state){
        case st_outvar:
          switch(c){
            case '$':
              state = st_beginvar;
              vardelim = false;
              var.reset();
              esc.reset();
              break;
            default:
              os.write(c);
              break;
          }
          break;
        case st_beginvar:
          switch(c){
            case '$':
              state = st_outvar;
              os.write(c);
              if(vardelim){ // $($) ?
                int x;
                if((x=p.read())!=-1){
                  if(x != ')'){
                    p.unread(x);
                  }
                }
              }
              break;
            case '(':
              state = st_beginvar;
              vardelim =  true;
              break;
            default:
              if((c >= 'A' && c <= 'Z')
                 || (c >= 'a' && c <= 'z')
                 || c == '_')
              {
                state = st_invar;
                var.reset();
                var.write(c);
              }else{
                //hmmn... not a variable character
                System.err.println("unexpected byte ["+c+"] in variable name... ignoring");
                state = st_outvar;
                os.write('$');
                p.unread(c);
              }
              break;
          }
          break;
          
        case st_invar:
          switch(c){
            case ':':
              if(vardelim){ // $(foo:esc) vs $foo:esc
                state = st_esc;
                break;
              }// otherwise, fallthrough to default
            default:
              if((c >= 'A' && c <= 'Z')
                 || (c >= 'a' && c <= 'z')
                 || (c >= '0' && c <= '9')
                 || c == '_')
              {
                state = st_invar;
                var.write(c);
              }else{
                state = st_outvar;
                outstr.append(os.toString());
                os.reset();
                if(var.size()>0){
                  outstr.append(this.getVar(var.toString()));
                 }
                var.reset();
                //end of variable...
                if((!vardelim) || c != ')'){
                  p.unread(c);
                }
              }
              break;
          }
          break;
        case st_esc:
          if((c >= 'A' && c <= 'Z')
             || (c >= 'a' && c <= 'z')){
            esc.write(c);
          }else if(c != ')'){
            // unexpected esc char eg: $(foo:esc bar
            System.err.println("unexpected byte ["+c+"] in variable esc mode");
             p.unread(c);
             c = ')';
          }
          if(c == ')'){
            p.unread(c);
            state = st_invar;
            String e = esc.toString().toLowerCase();
            if(e.equals("e") || e.equals("escape")){
              escmode = V_ESCAPE;
            }else if(e.equals("n") || e.equals("noesc")){
              escmode = V_NOESC;
            }else if(e.equals("u") || e.equals("unesc")){
              escmode = V_UNESC;
            }else{
              System.err.println("Unrecognised variable escape mode ["+e+"]");
              escmode = V_NOESC;
            }
          }
          break;
        default:
          break;
	    }  
    }
    if(os.size()>0){    
	    outstr.append(os.toString());
    }
    if(var.size()>0){
      outstr.append(this.getVar(var.toString()));
    }
    return(outstr.toString());
  }
}

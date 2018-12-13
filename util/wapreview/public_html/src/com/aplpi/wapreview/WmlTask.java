package com.aplpi.wapreview;

import java.lang.String;

import java.net.URLEncoder;

import java.util.Enumeration;
import java.util.Hashtable;
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

 * This class is used to represent a WML task.
 *
 * @author Copyright (c) 2000, Applepie Solutions Ltd.
 * @author Written by Robert Fuller &lt;robert.fuller@applepiesolutions.com&gt;
 *
 */
public class WmlTask{
    private Hashtable attributes;
    private WmlDeckInterface deck;
    private Hashtable postfields;
    private Stack postorder;
    private int indexCount;
    private String url;
    private boolean isPrev = false;
    private boolean isGet = false;
    private boolean isPost = false;
    private boolean isRefresh = false;
    private boolean sendreferer = false;
    private boolean encoded = false;
    private String setvar;
  
  /**
   * Construct a new WmlTask belonging to the named deck.
   *
   * @param wmldeck The WmlDeck to which the task belongs
   * @param index The index number of this WmlTask.
   *
   */
  public WmlTask(WmlDeckInterface wmldeck, int index){
    indexCount = index;
    deck = wmldeck;
    setvar = new String();
  }
  
  /**
   * Initialise this task as a task of the specified type.
   *
   * @param tsktype The task type
   */
  public void init(String tsktype){
    init(tsktype,null,null,null);
  }
  
  /**
   *
   * Initialise this task as a task of the specified type
   * and href
   *
   * @param tsktype The task type
   * @param tskhref The HREF associated with the task
   */
  public void init(String tsktype, String tskhref){
    init(tsktype,tskhref,null,null);
  }
  /**
   *
   * Initialise this task as a task of the specified type,
   * href, sendreferer and method
   *
   * @param tsktype The task type
   * @param tskhref The HREF associated with the task
   * @param tsksendrefer The sendrefer
   * @param tskmethod The method for this task eg: GET or POST
   */  
  public void init(String tsktype, 
                   String tskhref,
                   String tsksendreferer,
                   String tskmethod){
    postfields = new Hashtable();
    postorder = new Stack();
    attributes = new Hashtable();
    
    if(tsksendreferer != null 
       && tsksendreferer.equals("true")){
	    sendreferer = true;
    }else{
	    sendreferer = false;
    }
    
    if(tsktype != null){
	    if(tsktype.equals("go")){
        /*
         * resolveurl protects variables... we need to
         * expand them again so the 'get's work properly
         */
        url = deck.resolveUrl(tskhref);
        try{
          url = deck.expandVariables(url);
        }catch(java.io.IOException ioe){
          System.err.println("Error while expanding url ["+url+"]"+ioe.toString());
        }
	    }else if(tsktype.equals("prev")){
        isPrev = true; //tskhref="prevCard()";
	    }else if(tsktype.equals("refresh")){
        isRefresh = true;//reloadDeck();
	    }
    }
    
    if(tskmethod != null && tskmethod.equals("post")){
	    isPost = true;
    }else{
	    isGet = true;
    }
    
    
  }
  
  /**
   * Assign the name and value for a setvar task.
   *
   * @param name The name of the variable to set.
   * @param value The value the variable will be set to.
   */
  public void setvar(String name, String value){
    setvar = setvar + "setVar('"+name+"','"+value+"');";
  }

  /**
   * Register a postfield for this task.
   *
   * @param name The name of the post field
   * @param value The value to be assigned to the named postfield.
   */
  public void postfield(String name, String value){
    postfields.put(name,value);
    postorder.push(name);
  }
  
  /**
   * Returns the javascript required to invoke this
   * task.
   */
  public String getInvocation(){
    if(isPrev){
	    return(setvar+"prevCard();");
    }
    if(isRefresh){
	    return(setvar);
    }
    if(postfields.isEmpty()){
	    return(setvar+"setCard(\""+url+"\");");
    }
    if(isPost){
	    return(setvar+"post("+indexCount+");");
    }
    if(encoded){
	    return(setvar+"setCard(\""+url+"\");");
    }
    String params = getparams();
    
    //url=url+params.toString();
    //encoded = true; // we won't encode this again... bad idea?
    String concat = (url.indexOf("?")>=0)?"&":"?";
    
    return(setvar+"setCard(\""+url+concat+params+"\");");
  }
  
  /**
   * Return the postfield value for the specified field.
   *
   * @param fieldname The name of the postfield.
   */
  private String getPostfieldValue(String fieldname){
    String value = (String)postfields.get(fieldname);
    if(value==null){value = "";}
    translate:{
	    while(value.startsWith("$")){
        value = value.substring(1); // remove the $ sign
        if(value.startsWith("$")){
          //ok, this is the wanted value
          break translate;
        }
        if(value.length()==0){
          // empty string;
          break translate;
        }
        value = deck.getVar(value);
	    } // end while
    } // end translate block
    
    return(value);
  }
  
  /**
   * Returns a string representing the URL for this WML task.
   */
  public String getUrl(){
    return url;
  }
  
  /**
   * Returns a byte array of the post fields for this task.
   */
  public byte[] getPostData(){
    return getparams().getBytes();
  }
  
  /**
   * Returns a string representation of the post fields for this task.
   */ 
  public String getparams(){
    StringBuffer params = new StringBuffer();
    boolean firstparam = true;
    Enumeration e = postorder.elements();
    while(e.hasMoreElements()){
	    String name = (String)e.nextElement();
	    String value = getPostfieldValue(name);
	    if(firstparam){
        firstparam=false;
	    }else{
        params.append("&");
	    }
	    params.append(URLEncoder.encode(name)+ 
                    "="+ URLEncoder.encode(value));
    }
    return params.toString();
  }
}
 

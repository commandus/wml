package com.aplpi.wapreview;

import java.lang.String;
import java.util.Hashtable;
import java.util.Enumeration;
import java.util.Vector;
import java.util.StringTokenizer;

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

 * A WML Select represents a &lt;select&gt; element
 * and contains the &lt;option&gt; elements within 
 * that select element.
 * It is capable of producing the JavaScript representation
 * of the select and option elements.
 *
 * @author Copyright (c) 2000, Applepie Solutions Ltd.
 * @author Written by Robert Fuller &lt;robert.fuller@applepiesolutions.com&gt;
 */

public class WmlSelect extends Object{
  private WmlDeckInterface deck;
  private String title;
  private String name;
  private String value;
  private String iname;
  private String ivalue;
  private String group;
  private boolean multichoice;
  private Vector options;
  /**
   * Construct a new WmlSelect object.
   *
   * @param _deck The WmlDeck to which this select belongs.
   * @param _title The title for this select
   * @param _name The value of the 'name=' attribute
   * @param _value The value of the 'value=' attribute
   * @param _iname The value of the 'iname=' attribute
   * @param _ivalue The value of the 'ivalue=' attribute
   * @param _multiple Whether multiple selects are allowed
   */
  public WmlSelect(WmlDeckInterface _deck,
                   String _title,
                   String _name,
                   String _value,
                   String _iname,
                   String _ivalue,
                   boolean _multiple,
                   int groupid){
    deck=_deck;
    title=(_title==null?"":_title);
    name=(_name==null?"":_name);
    value=(_value==null?"":_value);
    iname=(_iname==null?"":_iname);
    ivalue=(_ivalue==null?"":ivalue);
    multichoice = _multiple;
    options =  new Vector();
    group =  "group"+groupid;
  }
  
  /**
   * return the (internal) name of this select
   */
  public String name(){
    return group;
  }
  /**
   * Select (or unselect) the option at index i.
   * Set any variables changed by the activity of selecting
   * or unselecting this option.
   *
   * @param i the index of the option to select/unselect
   * @return whether the option is now selected
   */
  public boolean select(int i){
    boolean selected = false;
    if(i>0&&i<=options.size()){
System.err.println("selecting ["+i+"]("+getOptionValue(i)+")");
      boolean optarray[] = getOptionArray();
      optarray[i] = !optarray[i];
      selected = optarray[i];
      String optIndex;
      if(multichoice){
        optIndex = makeOptionIndex(optarray);
      }else{
        optIndex = (selected?""+i:"0");
      }
      setOptions(optIndex);
      /**
       * set any required variables
       */
      if(iname!=""){
        deck.setVar(iname,optIndex);
      }
      if(name!=""){
        deck.setVar(name,getValueString(optIndex));
      }
    }
    System.err.println("option is now "+(selected?"selected":"unselected"));
    return(selected);
  }
  

  /**
   * Add an option to this select list.
   *
   * @param value The value of the 'value=' attribute
   * @param title The value of the 'title=' attribute
   * @param onpick The of the 'onpick=' attribute
   */
  public void addOption(String value, String title, String onpick){
    WmlOption o = new WmlOption(value,title,onpick);
    options.addElement(o);
  }

  /*
   * Returns the option index of the first
   * option holding this option value
   */
  private String validateOptionValue(String s){
    Enumeration E = options.elements();
    boolean matched = false;
    String idx = "";
    int i = 0;
    while((!matched) && E.hasMoreElements()){
      i++;
      WmlOption o = (WmlOption)E.nextElement();
      if(s.equals(o.value)){
        matched=true;
        idx=""+i;
      }
    }
    return(idx);
  }
  
  /**
   * Validates the values contained an a string
   * and converts them to an optionIndex
   */
  private String validateValue(String s){
    String optIndex = "";
    if(!multichoice){
      optIndex = validateOptionValue(s);
    }else{
      StringTokenizer t = new StringTokenizer(s,";");
      while(t.hasMoreTokens()){
        String v = t.nextToken();
        if(!v.equals("")){
          optIndex+=validateOptionValue(v);
        }
      }
      optIndex = validateIndices(optIndex);
    }
    return(optIndex);
  }

  /**
   * Return a value string corresponding with the specified 
   * index String
   */
  private String getValueString(String idxString){
    String valueString = "";
    boolean indices[] = getOptionArray(idxString);
    for(int i=1;i<indices.length;i++){
      if(indices[i]){
        String v = getOptionValue(i);
        if(!v.equals("")){
          valueString+=v+";";
        }
      }
    }
    if(valueString.endsWith(";")){
      valueString= valueString.substring(0,valueString.length()-1);
    }
    return(valueString);
  }

  /**
   * validates the indices contained in an option index,
   * removing any duplicate or illegal values
   */
  private String validateIndices(String optString){
    /*
     * 1. Remove all non-integer indices from the value.
     *
     * 2. Remove all out-of-range indices from the value, 
     * where out-of-range is defined as any index with a value greater
     * than the number of options in the select or with a value 
     * less than one.
     *
     * 3. Remove duplicate indices
     */
    /*
     * If this is not a multichoice select, consider only
     * the first option selected.
     */
    return(makeOptionIndex(getOptionArray(optString)));
  }

  /*
   * Convert the array into an option index string
   */
  private String makeOptionIndex(boolean opt[]){
    String optString = "";
    for(int i=1;i<opt.length;i++){
      if(opt[i]){
        optString += i + ";";
      }
      if(!multichoice)
        break;
    }

    if(optString.endsWith(";")){
      optString= optString.substring(0,optString.length()-1);
    }
    return(optString);
  }

  /**
   * returns the value of the specified option.
   */
  private String getOptionValue(int index){
    String v = "";
    if(index>0 && index<=options.size()){
      WmlOption o = (WmlOption)options.elementAt(index-1);
      v=o.value;
    }
    return v;
  }

  /**
   * Return a JavaScript representation of this select object
   */
  public String toString(){
System.err.println("startingtostring");
    if(options.size()==0){
      return("");
    }
    //Step 1: the default option index is determined using iname and ivalue
    String defaultOptionIdx = "";
    if(!iname.equals("")){
      defaultOptionIdx=this.validateIndices(deck.getVar(iname));
    }
    if(defaultOptionIdx.equals("") && (!ivalue.equals(""))){
       defaultOptionIdx=this.validateIndices(ivalue);
    }
    if(defaultOptionIdx.equals("") && (!name.equals(""))){
      defaultOptionIdx=this.validateValue(deck.getVar(name));
    }

    if(defaultOptionIdx.equals("") && (!value.equals(""))){
      defaultOptionIdx=this.validateValue(value);
    }

    if(defaultOptionIdx.equals("")){
      if(multichoice){
        defaultOptionIdx = "0";
      }else{
        defaultOptionIdx = "1";
      }
    }
    /*
     * Step 2: initialise variables
     *
     * By the time we get here, the defaultOptionIdx
     * is set.  Now we need to set the corresponding
     * variables
     */
    if(!name.equals("")){
        deck.setVar(name,getValueString(defaultOptionIdx));
    }

    if(!iname.equals("")){
      deck.setVar(iname,defaultOptionIdx);
    }

    //step 3: pre-select option(s) specified by the default option index
    setOptions(defaultOptionIdx);

    String s = "<center><b>"+title+"</b></center>";

    if(!multichoice){
      s+="<script>alert('sicko');";
      if(defaultOptionIdx.equals("")||defaultOptionIdx.equals("0")){
        s+="var reset"+group+"='//';";
      }else{
        Integer I = new Integer(defaultOptionIdx);
        WmlOption o = (WmlOption)options.elementAt(I.intValue()-1);
        s+="reset"+group+"=\"flip('"+group+"',"+I+",'"+
          o.title+"',false,false,false);\";";
      }
      s+="</script>\n";
    }
    // Add the DHTML for all the options in the select.
    Enumeration e = options.elements();
    int i=0;
    while(e.hasMoreElements()){
      i++;
      WmlOption o = (WmlOption)e.nextElement();
      s+=o.toString(group, i, multichoice);
    }
System.err.println("endingtostring");

    return(s);
  }

  /**
   * Set the options as specified.
   */
  private void setOptions(String optionIdx){
    boolean opt[] = getOptionArray(optionIdx);
    for(int i=1;i<opt.length;i++){
      WmlOption o = (WmlOption)options.elementAt(i-1);
      o.selected = opt[i];
    }
  }

  private boolean[] getOptionArray(){
    int maxopt = options.size();
    boolean opt[] =  new boolean[maxopt+1];
    for(int i=1;i<opt.length;i++){
      WmlOption o = (WmlOption)options.elementAt(i-1);
      opt[i]=o.selected;
    }
    return(opt);
  }

  /**
   * Returns an boolean array with a true value at
   * the index for every (valid) option contained in the
   * string, and false value at all other indices.
   * the index string
   */
  private boolean[] getOptionArray(String idx){
    int maxopt = options.size();
    boolean indices[] =  new boolean[maxopt+1];
    for(int i=0;i<indices.length;i++){
      indices[i] = false;
    }
    Hashtable h = new Hashtable();
    StringTokenizer t = new StringTokenizer(idx,";");
    while(t.hasMoreTokens()){
      try{
        Integer I = new Integer(t.nextToken());
        int i = I.intValue();
        i=(i>maxopt?maxopt:i);
        i=(i<0?0:i);
        indices[i]=true;
      }catch(Exception E){
        System.err.println("Badly formed defaultOptionIndex ["+idx+"]");
      }
    }
    return(indices);
  }

class WmlOption{
  public String value;
  public String title;
  public String onpick;
  public boolean selected;
  public WmlOption(String _value, String _title, String _onpick){
    value=(_value==null?"":_value);
    title=(_title==null?"":_title);
    onpick=(_onpick==null?"":_onpick);
    selected=false;
  }

  public String toString(String group, int seqno, boolean multichoice){
    if(!onpick.equals("")){
      return "<a href=\"javascript:setCard('"+onpick+"');\">"
        +title+"</a><br>";
    }else{
      return "<layer id=\"nav"+group+"_"+seqno+"\">"+
        "<div id=\"iex"+group+"_"+seqno+"\">"+
        "<a href=\"javascript:choose();\" "+
        "onmousedown=\"selectitem('"+group+"',"+seqno+",'"+title+"',"+
        (selected?"false":"true")+
        (multichoice?",false,":",true,")+
        (multichoice?"true":"false")+");\">"+
        (selected?"<b>":"")+title+(selected?"</b>":"")+
        "</a></div></layer><br>\n";
    }
  }

  public boolean select(){
    selected =(!selected);
    return(selected);
  }
  
}
}







package com.aplpi.wapreview;

import java.lang.String;

import java.io.InputStream;
import java.io.Reader;
import java.io.UTFDataFormatException;

import java.net.MalformedURLException;
import java.net.URL;
import java.net.URLConnection;

import java.util.Hashtable;
import java.util.Stack;
import java.util.Enumeration;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.BufferedReader;
import java.io.FileNotFoundException;
import java.io.InputStreamReader;

import java.io.PrintWriter;
import java.io.IOException;

import com.microstar.xml.XmlHandler;
import com.microstar.xml.XmlParser;

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

 *
 * This is the handler for parsing the wml content
 * into a deck containing cards which can be displayed.
 *
 * @author Copyright (c) 2000, Applepie Solutions Ltd.
 * @author Written by Robert Fuller &lt;robert.fuller@applepiesolutions.com&gt;
 *
 */
public class WmlDeckBuilder implements XmlHandler {
    public XmlParser parser;
    private Hashtable attributes;
    private Stack wmlelements;
    private WmlTask sourceTask = null;
    private String url = "http://oiler/not/set/yet";
    public static String imgconverter = "http://www.applepiesolutions.com/cgi-bin/wbmp2gif?img=";
    public static String gateway ="http://www.applepiesolutions.com/cgi-bin/lwpproxy.cgi";
    public static String errlog = null;
    private WmlDeck deck;
    private URL sourceUrl;    
  private WmlDeck sourceDeck;
  private ByteArrayOutputStream rawWML;

    private int errors = 0; //keep count of errors

    /**
     * Construct a new WmlDeckBuilder 
     * using the provided deck and task as references.
     *
     * @param d The WmlDeck to use as a reference
     * @param t The WmlTask to use as a reference 
     */
    public WmlDeckBuilder(WmlDeck d, WmlTask t){
      sourceDeck = d;
      sourceTask = t;
      url = t.getUrl();
      init();
    }

  /**
   * Construct a new WmlDeckBuilder
   * using the provided deck and url as references
   *
   * @param d The WmlDeck to use as a reference
   * @param d A String representing the URL that contains the WML deck
   * to be built.
   */
  public WmlDeckBuilder(WmlDeck d, String u){
    sourceDeck = d;
    url = u;
    init();
  }

  /**
   * Start parsing the url specified when this WmlDeckBuilder
   * was constructed.  The constructed deck will be returned.
   * If an error occurs while retrieving or parsing, 
   * a deck with a single card containing an error message 
   * will be constructed and returned.
   */
  public WmlDeck startParse(){
    if(sourceDeck != null){
      //Expand any variables contained in the url
	    try{
//System.err.println("expanding:["+url+"]");
        url = sourceDeck.expandVariables(url);
//System.err.println("now:["+url+"]");
	    }
	    catch(java.io.IOException E){
        System.err.println("caught exception:"+E.toString());
	    }
    }else{System.err.println("No expansion required");}
    try{
	    sourceUrl = new URL(url);
    }
    catch(java.net.MalformedURLException E){
	    sourceUrl = null;
    }
    wmlelements = new Stack();
    attributes = new Hashtable();
    deck = null;
    System.err.println("URL:["+sourceUrl.toString()+"]");
    /*
     * Open a connection to the URL via the gateway.
     * Send any post data to the URL, then
     * retrieve the URL
     */
    try {
	    XmlParser parser = new XmlParser();
	    parser.setHandler(this);
      try{
	      URL url = new URL(gateway+sourceUrl.toString());
	      //System.err.println("url is to:"+gateway+systemId);
	      URLConnection connection = url.openConnection();
	      if(sourceTask != null){
          connection.setDoOutput(true);
          PrintWriter out = 
            new PrintWriter(connection.getOutputStream());
          out.write(sourceTask.getparams());
          out.close();
	      }
        InputStream is =  connection.getInputStream();
        rawWML =  new ByteArrayOutputStream();
        int r;
        while((r = is.read())>-1){
          rawWML.write(r);
        }
        is.close();
        rawWML.close(); //ok to do this?
        connection=null;
        url=null;
      }
	    catch(java.io.IOException E){
        System.err.println("Error:Cannot retrieve URL");
        String ioerr=
          "<wml><card title=\"Error!\"><p>The requested URL "
          + "<!--["+url.toString()+"]-->"
          +"could not be retrieved.</p></card></wml>";
        rawWML =  new ByteArrayOutputStream();
        rawWML.write(ioerr.getBytes());
      }
      catch(Exception E){
        //Hmm.... error reading input stream
        System.err.println("Error:"+E.toString());
        throw (E);
      }	
      /* Try to autodetect the encoding scheme.  If we get a UTF-8
         Encoding error, then retry iwth ISO-8859-1
      */
      try{
        parser.parse(url, null,
                     new ByteArrayInputStream(rawWML.toByteArray()),
                     (String)null);
      }catch(UTFDataFormatException E){
        parser.parse(url, null,
                     new ByteArrayInputStream(rawWML.toByteArray()),
                     "ISO-8859-1");
        System.err.println("WARNING:Encoding MAY be ISO-8859-1");
      }
      System.err.println("[ok]");
    }
    catch (java.io.FileNotFoundException e){
	    deck = new WmlDeck(sourceUrl);
	    WmlCard ioerr = new WmlCard(deck, "file_not_found");
	    ioerr.cardData("<center><b>Error!</b></center>"+url
                     +"<br>not found.<br>");
	    deck.addCard(ioerr);
    }
    catch (Exception e) {
	    e.printStackTrace();
	    System.err.println("[not ok]"+e.getMessage());
	    logFatalError("fatal="+sourceUrl);
	    deck = new WmlDeck(sourceUrl);
	    WmlCard wmlerr = new WmlCard(deck, "wml_error");
	    wmlerr.cardData("<center><b>Error!</b></center>"+url
                      +"<br>may contain errors.<br>");
	    deck.addCard(wmlerr);
    }
    if(deck != null){
	    deck.url = url;
      deck.wml(rawWML.toString());
    }
    return deck;
  }

  /**
    * Initialise the deck builder when it is constructed.
    */
  private void init ()
  {
      wmlelements = new Stack();
      attributes = new Hashtable();
      deck = null;
  }

  /**
   * Logs a fatal error message on the server.
   * This is useful for debugging purposes.
   */
  private void logFatalError(String message){
    errors++;
    //log only one error at most...
    if(errlog != null && errors<=1){
	    try{
        URL url2 = new URL(gateway+errlog);
        URLConnection connection = url2.openConnection();
        connection.setDoOutput(true);
        PrintWriter out = 
          new PrintWriter(connection.getOutputStream());
        out.write(message);
        out.close();
	    }	  
	    catch(Exception E){
        // do nothing.  The errlog could be wrong.
	    }
    }
  }

  /**
   * Resolve an external entity.
   * <p>This method will generate a new URL which will be
   * behind the proxy server.  This is required, since an
   * applet can only contact the server from which it was
   * downloaded.
   */
  public Object resolveEntity (String publicId, String systemId){
    //System.err.println("resolveEntity:publicId="+publicId+"\n            systemId="+systemId);
    if(publicId == null){
      //System.err.println("resolved to ["+gateway+systemId+"]");
      return gateway+systemId;

      
    }else{
      return new ByteArrayInputStream(new String(
        "<!ENTITY quot \"&#34;\">     <!-- quotation mark -->"
        +"<!ENTITY amp  \"&#38;#38;\"> <!-- ampersand -->"
        +"<!ENTITY apos \"&#39;\">     <!-- apostrophe -->"
        +"<!ENTITY lt   \"&#38;#60;\"> <!-- less than -->"
        +"<!ENTITY gt   \"&#62;\">     <!-- greater than -->"
        +"<!ENTITY nbsp \"&#160;\">    <!-- non-breaking space -->"
        +"<!ENTITY shy  \"&#173;\">    <!-- soft hyphen (discretionary hyphen) -->"
        ).getBytes());;
    }
  }
  
  
  /**
   * This method is required to implement XmlHandler interface
   * but does nothing for now.
   *
   * @see com.microstar.xml.XmlHandler#startExternalEntity
   */ 
  public void startExternalEntity (String systemId)
  {
  }

  /**
   * This method is required to implement XmlHandler interface
   * but does nothing for now.
   *
   * @see com.microstar.xml.XmlHandler#endExternalEntity
   */ 
  public void endExternalEntity (String systemId)
  {
  }

  /**
   * This method is required to implement XmlHandler interface
   * but does nothing for now.
   *
   * @see com.microstar.xml.XmlHandler#startDocument
   */ 
  public void startDocument ()
  {
  }


  /**
   * This method is required to implement XmlHandler interface
   * but does nothing for now.
   *
   * @see com.microstar.xml.XmlHandler#endDocument
   */
  public void endDocument ()
  {
  }


  /**
   * This method is required to implement XmlHandler interface
   * but does nothing for now.
   *
   * @see com.microstar.xml.XmlHandler#doctypeDecl
   */
  public void doctypeDecl (String name,
                           String pubid, String sysid)
  {
  }


  /**
    * Record the value of the named attribute.
    * Since wapreview is non validating, the values of all attributes
    * will be recorded, but unknown attributes will be
    * ignored.
    *
    * @see com.microstar.xml.XmlHandler#attribute
    */
  public void attribute (String name, String value,
                         boolean isSpecified)
  {
    if(attributes != null){
      attributes.put(name.toLowerCase(), value);
    }
  }
  
  /**
   * Start the next WmlElement.
   */ 
  private void beginWmlElement(){
    if(!wmlelements.empty()){
      wmlelement lastel = (wmlelement)wmlelements.peek();
      lastel.begin(attributes);
    }
    attributes = new Hashtable();
  }
  
  /**
   * Handle the start of an element.
   * A new object of the internal class wmlelement is
   * constructed, and given the attributes of this
   * element for interperetation.
   *
   * @see com.microstar.xml.XmlHandler#startElement
    */
  public void startElement (String name)
  {
    wmlelement el = new wmlelement(name, this);
    el.begin(attributes);
    attributes = new Hashtable();
    wmlelements.push(el);
  }
  
  /**
   * sets the current deck
   */
  public void setDeck(WmlDeck d){
    deck = d;
  }

  /**
   * returns the current deck
   */
  public WmlDeck getDeck(){
    return deck;
  }
  
  /** 
   * Handle the end of an element.
   * The current wmlelement is popped off the stack
   * of wmlelements and it's end() method is invoked.
   * @see com.microstar.xml.XmlHandler#endElement
   */
  public void endElement (String name)
  {
    if(!wmlelements.empty()){
      wmlelement el = (wmlelement) wmlelements.pop();
      el.end();
    }
  }
  
  
  /**
   * Handle character data.
   * <p>Character Data will appear unchanged in its dhtml representation.
   */
  public void charData (char ch[], int start, int length)
  {
    String chdata = (new String(ch, start, length).replace('\n',' '));
    if(deck != null){
      WmlCardInterface card = deck.currentcard;
      if(card != null){
	      card.cardData(this.encode(chdata,false));
      }
    }
  }


  /**
   * This method is required to implement XmlHandler interface
   * but does nothing for now.
   *
   * @see com.microstar.xml.XmlHandler#ignorableWhitespace
   * Handle ignorable whitespace.
   * <p>Do nothing for now. Insignificant whitespace is not of concern.
   */
  public void ignorableWhitespace (char ch[], 
				   int start, int length)
  {
  }
  
  
  /**
   * This method is required to implement XmlHandler interface
   * but does nothing for now.
   *
   * @see com.microstar.xml.XmlHandler#
   * Handle a processing instruction.
   * <p>Do nothing for now.
   */
  public void processingInstruction (String target,
				     String data)
  {
  }


  /**
    * Handle a parsing error.
    * A message will be logged on the server, if possible.
    * @see com.microstar.xml.XmlHandler#error
    */
  public void error (String message,
                     String url, int line, int column)throws Exception
  {
      /**
       * Catch UTF-8 encoding errors, we will subsequently
       * retry with ISO-8859-1
       */
      if(message != null && (message.indexOf("UTF-8")>-1)){
        String emsg = "UTF-8 Encoding Error";
        System.err.println(emsg);
        throw new UTFDataFormatException(emsg);
      }
      /* Some other error... log it somewhere? */
    String longMessage = "\nFATAL+ERROR=" + (message==null?"":message) +
      "\nurl=" + (url==null?sourceUrl.toString():url.toString()) + "\nline=" + line
      + "\ncolumn=" + column + "\n";
    System.err.println(longMessage);
    //Try logging the message on the server
    String params = "";
    if(sourceTask != null){
      params = "\n===========================\n"
	      + sourceTask.getparams()
	      + "\n===========================\n";
    }
    
    logFatalError(longMessage+params);   
    throw new Exception(message);
  }
  
  /**
   * Re-encode encoded characters.
   */
  public static String encode(String source, boolean encodeCR){
    int i=0;
    while(i<source.length()){
      switch(source.charAt(i)){
        case '<':
          source = (i>0?source.substring(0,i):"")
            +"&lt;"
            +(i<source.length()-1?source.substring(i+1):"");
          i+=3;
          break;
        case '&':
          source = (i>0?source.substring(0,i):"")
            +"&amp;"
            +(i<source.length()-1?source.substring(i+1):"");
          i+=4;
          break;
        case '>': 
          source = (i>0?source.substring(0,i):"")
            +"&gt;"
            +(i<source.length()-1?source.substring(i+1):"");
          i+=3;
         break;
        case '\n':
          if(encodeCR){
            source = (i>0?source.substring(0,i):"")
              +"<br>"
              +(i<source.length()-1?source.substring(i+1):"");
            i+=4;
          }else{
            i++;
          }
          break;
        default:
          i++;
      }
    }
    return(source);
  }  
  
  /**
   * This inner class contains knowledge about the WML elements
   * which are supported by this user agent.  This is where the WML
   * content is actually interpreted and constructed into the WmlCard
   * (and related) objects.
   * <p> The following tags are recognised to some extent:
   * <ul>
   * <li>&lt;a&gt;
   * <li>&lt;br&gt;
   * <li>&lt;card&gt;
   * <li>&lt;do&gt;
   * <li>&lt;go&gt;
   * <li>&lt;i&gt;
   * <li>&lt;input&gt;
   * <li>&lt;p&gt;
   * <li>&lt;b&gt;
   * <li>&lt;u&gt;
   * <li>&lt;big&gt;
   * <li>&lt;em&gt;
   * <li>&lt;select&gt;
   * <li>&lt;option&gt;
   * <li>&lt;postfield&gt;
   * <li>&lt;onevent&gt;
   * <li>&lt;img&gt;
   * <li>&lt;prev&gt;
   * <li>&lt;refresh&gt;
   * <li>&lt;setvar&gt;
   * <li>&lt;template&gt;
   * <li>&lt;table&gt;
   * <li>&lt;tr&gt;
   * <li>&lt;td&gt;
   * <li>&lt;timer&gt;
   * </ul>
   *
   */
  public class wmlelement{
    String name;
    StringBuffer endTags;
    boolean begun;
    private Hashtable attributes;
    private WmlDeckBuilder builder;
    private WmlDeck deck;
    /**
     * Construct a wmlelement of the given name.
     * If the name is not recognised, then it will be ignored
     * (however, recognised elements contained by it will be
     * utilised).
     *
     * @param elname The name of this element
     */
    public wmlelement(String elname, WmlDeckBuilder b){
      builder = b;
	    deck = builder.getDeck();
	    name = elname.toLowerCase();
	    attributes = new Hashtable();
	    endTags = new StringBuffer();
	    begun = false;
    }

  /**
   * Begin interpreting the attributes of this element.
   */
    public void begin(Hashtable a){
	    attributes = a;
	    // only want to begin once...
	    if(begun){
        return;
	    }
	    begun = true;

	    //System.err.println("//beginning element ["+name + "]");
	    //System.err.println("//attributes are ["+attributes.toString()+"]");
	    //System.err.println("beginning "+name);
      
      /**
       * If the name is "wml", then we are within a (hopefully) valid
       * WML deck.
       */
	    if(name.equals("wml")){
        builder.setDeck(new WmlDeck(sourceUrl));
        return;
	    }else if(deck == null){
        /**
         * Any tags outside the "wml" tags will be ignored.
         */
		    System.err.println("ignoring tag .. not inside wml["+name+"]");
		    return;
	    }


	    if(name.equals("a")){
        String href = 
          (String)attributes.get("href"); 
        href = deck.resolveUrl(href);
        deck.currentcard.cardData("<a href='javascript:setCard(\""+href+"\");'>");
        endTags.append("</a>");
	    }else if(name.equals("anchor")){	
        String accesskey = 
          (String)attributes.get("accesskey");
        String title = 
          (String)attributes.get("title");        
        deck.currentcard.cardData("<a href='javascript:reval(getHref("+deck.countTasks()+"));'>");
        endTags.append("</a>");      
	    }else if(name.equals("br")){
        deck.currentcard.cardData("<br>");
	    }else if(name.equals("card")){
        String id = 
          (String)attributes.get("id");
        String onenterforward = 
          (String)attributes.get("onenterforward");
        String onenterbackward =
          (String)attributes.get("onenterbackward");
        String align =
          (String)attributes.get("align");
        String title =
          (String)attributes.get("title");	    
        String ontimer =
          (String)attributes.get("ontimer");
        if(id == null || id.equals("")){
          id = "aplpi"+ ++deck.unknownCards;
        }
        WmlCard card = new WmlCard(deck,id);
        if(onenterforward != null){
          card.onenterforward("setCard('"+deck.resolveUrl(onenterforward)+"');");    	
        }
        if(onenterbackward != null){
          card.onenterbackward("setCard('"+deck.resolveUrl(onenterbackward)+"');");    	
        }
        deck.addCard(card);
        if(ontimer != null){
          ontimer = deck.resolveUrl(ontimer);
          card.ontimer(new String("setCard('"+ontimer+"');"));
        }
        if(title != null){
          deck.currentcard.cardData("<!--title--><center>"
                                    +title+"</center>");
        }
        if(align != null){
          deck.currentcard.cardData("<"+align+">");
          endTags.append("</"+align+">");
        }
        endTags.append("\n");
	    }else if(name.equals("do")){
        String type =
          (String)attributes.get("type");
        String label =
          (String)attributes.get("label");
        String name_ =
          (String)attributes.get("name");
        String optional =
          (String)attributes.get("optional");
        if(type == null){
        }else if(type.equals("accept")){
          //Positive acknowledgement (acceptance)
          if(label == null){
            label="ok";
          }
          deck.currentcard.navData(
            "<a href='javascript:reval(getHref("+deck.countTasks()+"));'>"
            + "<em>"
            + label+"</em></a>");
        }else if(type.equals("prev")){
          //Backward history navigation
          if(label == null){
            label = "back";
          }
          deck.currentcard.navData(
            "<a href='javascript:prevCard();'>"
            + "<em>" + label+"</em></a>");
        }else if(type.equals("help")){
          //Request for help. May be context-sensitive. 
        }else if(type.equals("reset")){
          //Clearing or resetting state. 
        }else if(type.equals("options")){
          //Context-sensitive request for options 
          //or additional operations.
        }else if(type.equals("delete")){
          //Delete item or choice
        }else if(type.equals("unknown")){
          //A generic do element. Equivalent to an 
          //empty string (e. g., type="")
        }else{
          //don't know about this type.
        }
	    }else if(name.equals("go")){
        String href = // %HREF; #REQUIRED
          (String)attributes.get("href"); 
        String sendreferer = // %boolean; "false"
          (String)attributes.get("sendreferer");
        String method = // # (post| get) "get"
          (String)attributes.get("method");
        if(method == null){
          method = "get";
        }
        WmlTask t = deck.newTask();
        t.init("go",href,sendreferer, method);
	    }else if(name.equals("i")){
        deck.currentcard.cardData("<i>");
        endTags.append("</i>");    
	    }else if(name.equals("input")){
        String name_ = // NMTOKEN #REQUIRED 
          (String) attributes.get("name");
        String type_ = // (text| password) "text"
          (String) attributes.get("type");
        if(type_ == null){
          type_ = "text";
        }
        String value =//%vdata; #IMPLIED 
          (String) attributes.get("value");
        if(value == null){
          value = "";
        }
        String format =//CDATA #IMPLIED 
          (String) attributes.get("format");
        String emptyok = //%boolean; "false" 
          (String) attributes.get("emptyok");
        if(emptyok == null){
          emptyok = "false";
        }
        String size = //# %number; #IMPLIED 
          (String) attributes.get("size");
        if(size==null){
          size="10";
        }
        try{
          int v = (Integer.valueOf(size)).intValue();
          if( v>12 || v<1 ){
            size="12";
          }
        }catch(Exception E){
          size="12";
        }
        String maxlength = //%number; #IMPLIED 
          (String) attributes.get("maxlength");
        String tabindex = //%number; #IMPLIED (
          (String) attributes.get("tabindex");
        String title = //%vdata; #IMPLIED 
          (String) attributes.get("title");
        if(title==null){
          title = "";
        }
        String accesskey =//%vdata; #IMPLIED
          (String)attributes.get("accesskey");
        deck.setVar(name_,value);
        deck.currentcard.cardData(title+"<br><input size="+size
                                  + " type="+ type_
                                  + " value=\"$"+ name_+ "\""
                                  + " onchange=\"setVar('"
                                  +name_+"',this.value);\">");
        
	    }else if(name.equals("p")){
        String align = (String)attributes.get("align");
        String mode = (String)attributes.get("mode");
        if(align == null){
          align="left";
        }
        deck.currentcard.cardData("<p align=\""+align+"\">");
        endTags.append("</p>");
	    }else if(name.equals("b")){
        deck.currentcard.cardData("<b>");
        endTags.append("</b>");
	    }else if(name.equals("u")){
        deck.currentcard.cardData("<u>");
        endTags.append("</u>");
	    }else if(name.equals("big")){
        deck.currentcard.cardData("<b>");
        endTags.append("</b>");
	    }else if(name.equals("em")){
        deck.currentcard.cardData("<em>");
        endTags.append("</em>");
	    }else if(name.equals("select")){
        //  title %vdata; #IMPLIED
        String title_ = (String)attributes.get("title");
        
        //  name NMTOKEN #IMPLIED
        String name_ = (String)attributes.get("name");
        
        //  value %vdata; #IMPLIED
        String value = (String)attributes.get("value");
        
        //  iname NMTOKEN #IMPLIED
        String iname = (String)attributes.get("iname");
        
        //  ivalue %vdata; #IMPLIED
        String ivalue = (String)attributes.get("ivalue");
        
        //  multiple %boolean; "false"
        String multiple = (String)attributes.get("multiple");
        boolean multiple_ = true;
        if(multiple == null || 
           (!multiple.equals("true"))){
          multiple_ = false;
        }
        
        //  tabindex %number; #IMPLIED
        String tabindex = (String)attributes.get("tabindex");
        deck.currentcard.beginSelect(title_,name_,value,
                                    iname,ivalue,multiple_);
        //deck.currentcard.cardData("<!--select-->");
        //endTags.append("<!--/select-->");
	    }else if(name.equals("option")){
        String onpick =
          (String)attributes.get("onpick");
        String title_ = 
          (String)attributes.get("title");
        String value =
          (String)attributes.get("value");
        if(onpick!=null && !onpick.equals("")){
          onpick = deck.resolveUrl(onpick);
        }
          //deck.currentcard.cardData("<br><em>&gt;</em><a href=\"javascript:setCard('"+onpick+"');\">");
          //endTags.append("</a>");
          deck.currentcard.addOption(value,title_,onpick);
        
	    }else if(name.equals("postfield")){
        // these are the post fields for the current 'go'
        String _name = (String)attributes.get("name");
        String value = (String)attributes.get("value");
        WmlTask t = deck.currentTask();
        if(t != null){
          t.postfield(_name,value);
        }
	    }else if(name.equals("img")){
        String src = // %HREF; #REQUIRED 
          (String)attributes.get("src");
        String localsrc = //%vdata; #IMPLIED 
          (String)attributes.get("localsrc");
        String alt = //%vdata; #REQUIRED 
          (String)attributes.get("alt");
        String vspace = //%length; "0" 
          (String)attributes.get("vspace");
        String hspace = //%length; "0" 
          (String)attributes.get("hspace");
        String align = //%IAlign; "bottom" 
          (String)attributes.get("align"); 
        String height = //%length; #IMPLIED 
          (String)attributes.get("height");
        String width = //%length; #IMPLIED
          (String)attributes.get("width");
        deck.currentcard.cardData("<img ");
        if(localsrc != null && localsrc.length()>0){
          src=localsrc;
          if(alt == null || alt.length()>0){
            alt=localsrc;
          }
        }
        if(src != null && src.length()>0){
          src = deck.resolveUrl(src);
          deck.currentcard.cardData(" src=\""
                                    +WmlDeckBuilder.imgconverter 
                                    +src+"&.gif\"");
          if(alt != null){
            deck.currentcard.cardData(" alt=\""+alt+"\" ");
          }
        }
        deck.currentcard.cardData(">");
        endTags.append("</img>");	
	    }else if(name.equals("onevent")){
        String tipe = (String)attributes.get("type");
        if(tipe!=null){
          deck.awaitingtask=tipe;
        }
	    }else if(name.equals("prev")){
        deck.newTask();
        WmlTask t = deck.currentTask();
        t.init("prev");
        
	    }else if(name.equals("refresh")){
        deck.newTask();
        WmlTask t = deck.currentTask();
        t.init("refresh");    
	    }else if (name.equals("setvar")){
        WmlTask t = deck.currentTask();
        String varname = (String)attributes.get("name");
        String value = (String)attributes.get("value");
        if(t !=null){
          t.setvar(varname, value);
        }
      }else if(name.equals("template")){
        WmlTemplate t = new WmlTemplate(deck);
        deck.currentcard =  t;
	    }else if(name.equals("table")){
        deck.currentcard.cardData("<table>");
        endTags.append("</table>");
        
	    }else if(name.equals("tr")){
        deck.currentcard.cardData("<tr>");
        endTags.append("</tr>");
        
	    }else if(name.equals("td")){
        deck.currentcard.cardData("<td><font size=1>");
        endTags.append("</font></td>");
        
	    }else if(name.equals("timer")){
        String value =
          (String)attributes.get("value");
        String name_ =
          (String)attributes.get("name");
        if(value != null){
          deck.setVar("aplpicardtimeout"+deck.currentcard.name(),
                      value+"00");
        }else{
          value = "0";
        }
        if(name_ != null){
          deck.setVar(name_, value);
          deck.setVar("aplpicardtimeout"+deck.currentcard.name(),
                      "$"+name_);
        }
        
	    }else{
        deck.currentcard.cardData("<!-- failed to recognize tag ["+name+"]-->");
	    }
	    
    }
    
  /**
   * Finish interpreting the attributes of this element.
   * Any necessary cleanup activities will be performed.
   */
    public void end(){
	    //System.err.println("//ending element ["+name + "]");
	    if(deck == null){
        return;
	    }
	    if(deck.currentcard != null){
        deck.currentcard.cardData(endTags.toString());
	    }
	    if(name.equals("card")){
        deck.currentcard = (WmlCard)null;
	    }else if(name.equals("template")){
        deck.currentcard = (WmlCard)null;
      }else if(name.equals("go")){
        deck.endTask();
	    }else if(name.equals("onevent")){
        deck.awaitingtask = null;
	    }else if(name.equals("prev")){
        deck.endTask();
	    }else if(name.equals("refresh")){
        deck.endTask();
	    }
    }
  }
}

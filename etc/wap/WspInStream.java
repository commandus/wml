/*======================================================================
*
*This file is part of Jwap, the Java Wap Gateway.
*Copyright (C) TietoEnator PerCom AB 
* <http://enator.se/teknik/percom/>
*
* The Jwap Project
*	David Juran & Anders Mårtensson
*      <http://simplex.hemmet.chalmers.se/Jwap.html>
*       jwap@simplex.hemmet.chalmers.se
*
*This program is free software; you can redistribute it and/or
*modify it under the terms of the GNU General Public License
*as published by the Free Software Foundation; either version 2
*of the License, or (at your option) any later version.
*
*This program is distributed in the hope that it will be useful,
*but WITHOUT ANY WARRANTY; without even the implied warranty of
*MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
*GNU General Public License for more details.
*
*You should have received a copy of the GNU General Public License
*along with this program; if not, write to the Free Software
*Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA. 
*
*======================================================================*/
package COM.tietoenator.percom.WapGateway;

import COM.tietoenator.percom.WapGateway.*;
import java.io.*;
import java.io.FilterInputStream.*;
import java.util.*;
import java.lang.Throwable.*;
import java.text.*;
import java.net.*;

/** Decodes a vector containing bytes into one HTTPHeader and then 
 drops the bytes alreadey read from the vector*/
public class WspInStream extends BufferedInputStream implements Cloneable
{
    /*As in RFS 2616*/
    private final Vector CTL=new Vector(33);
    private final Vector CRLF=new Vector(2);
    private final Vector CHAR=new Vector(127);
    private final Vector separators = new Vector(19);

    
    /*--------------------------------------------------------*/
    /**Creates a WapInStream on the InputStream in*/
    public WspInStream(InputStream in)
    {
	super(in);

	int i;

	//initialize constants 
	for(i=0;i<32;i++)
	    CTL.addElement(new Integer(i));
	CTL.addElement(new Integer(127));

	CRLF.addElement(new Integer(13));
	CRLF.addElement(new Integer(10));

	for(i=0;i<128;i++){
	    CHAR.addElement(new Integer(i));
	}

	separators.addElement(new Integer(0x28));
	separators.addElement(new Integer(0x29));
	separators.addElement(new Integer(0x3C));
	separators.addElement(new Integer(0x3E));
	separators.addElement(new Integer(0x40));
	separators.addElement(new Integer(0x2C));
	separators.addElement(new Integer(0x3B));
	separators.addElement(new Integer(0x3A));
	separators.addElement(new Integer(0x2F));
	separators.addElement(new Integer(0x22));
	separators.addElement(new Integer(0x5C));
	separators.addElement(new Integer(0x5D));
	separators.addElement(new Integer(0x5B));
	separators.addElement(new Integer(0x3F));
	separators.addElement(new Integer(0x3D));
	separators.addElement(new Integer(0x7B));
	separators.addElement(new Integer(0x7D));
	separators.addElement(new Integer(0x20));
	separators.addElement(new Integer(0x09));
    }
    /*---------------------------------------------------------*/
    /**overrides read() but throws IOExceptionif there's nothing
       to be read*/
    public int read() throws IOException
    {
	int i=super.read();
	if(i!=-1)
	    return i;
	else
	    throw new IOException("Stream ended prematurely");
    }
    /*---------------------------------------------------------*/
    /**This method clones the stream in a certain sence. What it
       does is produce a new stream containing all the bytes
       that this clone contained at the moment*/
    public Object clone() throws CloneNotSupportedException
    {
	try{
	    int len=available();
	    byte[] buf=new byte[len];
	    
	    mark(len);
	    read(buf);
	    reset();
	    
	    return new WspInStream(new ByteArrayInputStream(buf));
	}
	catch(IOException e){
	    System.err.println(e.getClass()+" caught."+e.getMessage());
	    System.exit(-1);
	    return null;
	}
    }
    /*---------------------------------------------------------*/
    /** reads len bytes from the stream and puts them into 
	a new stream*/
    public WspInStream getSubStream(int len) throws IOException
    {
	if(available()<len)
	    throw new IOException("Stream ended prematurely");
	byte[] buf=new byte[len];

	read(buf);

	return new WspInStream(new ByteArrayInputStream(buf));
    }
    /*---------------------------------------------------------*/
    /** pops a PDU from the stream*/
    public PDU mkPDU() throws IOException,CodeNotInTableException, CloneNotSupportedException
    {
	byte tid,b;
	
	/*First comes the TID,
	  a uint8*/
	tid=(byte)read();
	
	/*Then the PDU-type comes
	  and then the PDU contents*/
	b=(byte)read();
	if((b>=0x40)&&(b<=0x5F)){ //GET
	    return new GET_PDU(tid,this);
	}
	if((b>=0x60)&&(b<=0x7F)) //POST
	    return new PostPdu(tid,this);

	throw new CodeNotInTableException(""+b+" is unknown PDU-type"); // We shouldnt get here (DUH!)
    }
    /*---------------------------------------------------------*/
    /** reads a string from the stream*/
    private String getString() throws IOException
    {
	String str=new String();
	int b;
	
	do{
	    b=read();
	    str+=b;
	}while(b!=0);
	return str;
    }
    /*---------------------------------------------------------*/
    /**Returns true if the first byte in the stream i Constrained-Media*/
    private boolean isConstrainedMedia() throws IOException
    {
	/*constrained-media==constrained-encoding
	  constrained encoding could either be
	  extension-media or
	  short-integer*/
	return (isExtensionMedia()|isShortInteger());
    }
    /*-----------------------------------------------------------*/
    /**Returns true if the first byte in the stream i short-integer*/
    private boolean isShortInteger() throws IOException
    {
	boolean result;

	/*A short integer is a octet 0-127 with MSB set*/	
	mark(1);
	result=((read()&0x80)==0x80);
	reset();
	return result;
    }
    /*--------------------------------------------------------*/
    /**Pops an untyped-parameter from the stream*/
    private String getUntypedParameter() throws IOException
    {
	/*This consists of token-text followed
	  by an untyped-value*/
	String tok=getTokenText();
	String val=getUntypedValue();
	if(val.length()!=0)
	    return tok+"=\""+val+"\"";
	else
	    return tok;
    }
    /*--------------------------------------------------------*/
    /**Pops an Untyped-value off the stream*/
    private String getUntypedValue() throws IOException
    {
	/*this could either be integer-value or
	  text-value*/
	if(isTextValue())
	    return getTextValue();
	else
	    return(new String((new Integer(getIntegerValue())).toString()));
    }
    /*--------------------------------------------------------*/
    /**returns true if the stream starts with a text-Value*/
    private boolean isTextValue() throws IOException
    {
	return isNoValue()||isTokenText()||isQuotedString();
    }
    /*--------------------------------------------------------*/
    /**Pops a text-value from the stream*/
    private String getTextValue() throws IOException
    {
	/*This could either be no-value
	  or token-text
	  or quoted-string*/
	if(isNoValue()){
	    read();
	    return "";
	}
	if(isTokenText())
	    return(getTokenText());
	if(isQuotedString())
	    return(getQuotedString());
	return new String("ERROR: getTextValue failed )-:");
    }
    /*--------------------------------------------------------*/
    /** Pops a qouted-string from the vector*/
    private String getQuotedString() throws IOException
    {
	String str;
	/* A quoted string is \34 followed by 
	   TEXT followed by
	   end-of-string*/
	read();
	str=getText();
	read();
	return str;
    }
    /*--------------------------------------------------------*/
    /** Returns true if the first byte in the stream is start 
	of a quoted string*/
    private boolean isQuotedString() throws IOException
    {
	//starts with a \34
	mark(1);
	int b=read();
	reset();

	return (b==34);
    }
    /*--------------------------------------------------------*/
    /**return true if the first byte in the stream is a 
       no-value*/
    private boolean isNoValue() throws IOException
    {
	//\0
	mark(1);
	int b=read();
	reset();
	
	return (b==0);
    }
    /*-----------------------------------------------------------*/
    /**Returns true if the first byte in the stream i extension-media*/
    private boolean isExtensionMedia() throws IOException
    {
	byte b;
	
	/*Extension media is a text followed by a End-of-string
	  i.e. \32-\126*/
	mark(1);
	b=(byte)read();
	reset();
	return ((b>31)&&(b<127));
    }
    /*-----------------------------------------------------------*/
    /**Returns true if the first byte in the stream i short-length*/
    private boolean isShortLength() throws IOException
    {
	byte b;

	//Short length i any octet \0 - \30
	mark(1);
	b=(byte)read();
	reset();

	return (b<31);
    }
    /*-----------------------------------------------------------*/
    /**pops a UIntVar from the stream*/
    private int getUIntVarInteger() throws IOException
    {
	int b,temp=0;

	/*UIntVar is a number of octets with the 7 LSB significant and
	  a MSB set if it continues ini the next byte.
	  Better described in WSP 8.1.2*/
	do{
	    temp<<=7;
	    b=(read()); 
	    temp|=(b&0x7F);
	}while(((b&0x80)==0x80));
	return temp;
    }
    /*-----------------------------------------------------------*/
    /**Pops a accept from the stream*/
    private String  getAcceptValue() throws IOException, CodeNotInTableException
    {
	if(isConstrainedMedia())
	    /*Constrained media could be
	      Extension-media as pointed out by
	      Martien Huysmans*/
	    if(isExtensionMedia())
		return getExtensionMedia();
	    else
		return ContentTypeTable.getName(getShortInteger());
	else
	    return getAcceptGeneralForm();
    }
    /*-----------------------------------------------------------*/
    private String getMediaType() throws CodeNotInTableException, IOException
    {
	String str;
	
	if(isWellKnownMedia())
	    str=getWellKnownMedia();
	else
	    str=getExtensionMedia();
	
	while(available()>0)
	    str+=getParameter();
	
	return str;
    }
    /*--------------------------------------------------------*/
    /**pops a parameter from the stream*/
    private String getParameter() throws CodeNotInTableException, IOException
    {
	/*this could be an typed or untyped parameter*/
	if(isTypedParameter())
	    return(getTypedParameter());
	else
	    return(getUntypedParameter());
    }
    /*--------------------------------------------------------*/
    /** pops a typed parameter from the stream*/
    private String getTypedParameter() throws CodeNotInTableException, IOException
    {
	int token;
	
	/*This is a Well-known-parameter-token followed 
	  by a typed value*/
	token=getIntegerValue();

	/*the value type depends on the token	
	  WSP Appendix A
	  table 38*/
	switch(token){
	case 0x00://Q
	    return new String("Q="+getQValue()); 
	case 0x01://Charset
	    return new String("Charset="+getWellKnownCharset()); 
	case 0x02://Level
	    return new String("Level="+getVersionValue()); 
	case 0x03://Type
	    return new String("Type="+getIntegerValue()); 
	case 0x05://Name
	    return new String("Name="+getTextString()); 
	case 0x06://FileName
	    return new String("Filename="+getTextString()); 
	case 0x07://differences
	    return new String("Differences="+getFieldName()); 
	case 0x08://Padding
	    return new String("Padding="+getShortInteger()); 
	default:
	    throw new CodeNotInTableException("Unknown Parameter type \n And it shouldnt be )-:");
	}
    }
    /*--------------------------------------------------------*/
    /** Pops a version-value of the stream*/
    private String getVersionValue() throws IOException
    {
	byte ver;
	//Encoded as in WSP 8.4.2.3
	if(isShortInteger()){
	    ver=getShortInteger();
	    
	    //only major number
	    if((ver&0xF)==15) {
		ver&=0x70;
		ver>>>=4;
		return new String((new Integer(ver).toString()));
	    }
	    else //both major and minor
		return new String((new Integer((ver&0x70)>>>4)).toString()+
				  "."+
				  (new Integer(ver&0xF)).toString());
	}
	else //encoded as text
	    return getTextString();
    }    
    /*--------------------------------------------------------*/
    /** Pops a well-known-charset from the vector*/
    private String getWellKnownCharset() throws CodeNotInTableException, IOException
    {
 	/*WSP Apendix A
	  table 42*/
	return  CharacterSetTable.getSet(getIntegerValue());
    }
    /*--------------------------------------------------------*/
    /**Pops a Q-value from the stream*/
    private float getQValue() throws IOException
    {
	int len,temp=0,i;
	
	mark(2);
	int f=read();
	int s=read();
	reset();

	//One or two octets?
	if((f&0x80)==0x80)
	    len=2;
	else
	    len=1;
	
	//sick encoding... see WSP 8.4.2.3	
	for(i=0;i<len;i++){
	    temp<<=7;
	    temp|=(read()&0x7F);
	}
	
	/* q=0 or 1 or 2 decimal digits?*/
	if(temp<100)
	    return (float)(temp-1)/(float)100;
	else //three decimal quality
	    return(float)(temp-100)/(float)1000;
    }
    /*--------------------------------------------------------*/
    /**Returns true if the first byte in the stream is a
       typed-parameter*/
    private boolean isTypedParameter() throws IOException
    {
	/*consists of a well-known-parameter-token and a
	  typed-value*/
	return isWellKnownParameterToken();
    }
    /*---------------------------------------------------------*/
    /**pops a Accept-parameter off the stream*/
    private String getAcceptParameters() throws CodeNotInTableException, IOException
    {
	String str;

	//Get rid of Q-token
	read();

	str="q="+getQValue();

	if(available()>0)
	    str+=getAcceptExtension();

	return str;
    }
    /*---------------------------------------------------------*/
    /**Pops a accept-extension off the stream*/
    private String getAcceptExtension() throws CodeNotInTableException, IOException
    {
	return getParameter();
    }
    /*--------------------------------------------------------*/
    /**Returns true if the first byte in the stream is a 
       well-known-parameter-token*/
    private boolean isWellKnownParameterToken() throws IOException
    {
	//this is an integer-value
	return isIntegerValue();
    }
    /*---------------------------------------------------------*/
    /**Pops a Well-known-media off the stream*/
    private String getWellKnownMedia() throws CodeNotInTableException, IOException
    {
	return ContentTypeTable.getName((byte)getIntegerValue());
    }
    /*--------------------------------------------------------*/
    /**Returns true if the first byte in the stream is 
       well-known-media*/
    private boolean isWellKnownMedia() throws IOException
    {
	/*well-known-media == integer-value*/
	return this.isIntegerValue();
    }
    /*--------------------------------------------------------*/
    /**Returns true if the first byte in the stream is
       integer-value*/
    private boolean isIntegerValue() throws IOException
    /*integer-value could be either short-integer or
      long integer*/
    {
	return this.isShortInteger()||this.isLongInteger();
    }
    /*--------------------------------------------------------*/
    /**Returns true if the first byte in the stream is a
       long-integer*/
    private boolean isLongInteger() throws IOException
    {
	mark(1);
	int f=read();
	reset();
	
	if(f<=30) //Short length	
	    return(available()>f);//Do we really have len OCTETS?
	else
	    return false;
    }
    /*-----------------------------------------------------------*/
    /** Pops a Constrained-media from the string*/
    private String getConstrainedMedia() throws IOException, CodeNotInTableException
    {
	return getConstrainedEncoding();
    }
    /*-----------------------------------------------------------*/
    /**Pops a Content-type from the stream*/
    String getContentType() throws IOException, CodeNotInTableException
    {
	if(isConstrainedMedia())
	    return getConstrainedMedia();
	else
	    return getContentGeneralForm();
    }
    /*-----------------------------------------------------------*/
    private String getContentGeneralForm() throws IOException, CodeNotInTableException
    {
	WspInStream bvec=getSubStream(getValueLength());

	return bvec.getMediaType();
    }
    /*-----------------------------------------------------------*/
    /**Pops a Accept-general-form off the stream*/
    private String getAcceptGeneralForm() throws IOException, CodeNotInTableException
    {
	String str;

	WspInStream bvec=getSubStream(getValueLength());

	str=bvec.getMediaRange();
	
	if(bvec.available()>0)
	    str+=bvec.getAcceptParameters();
	
	return str;
    }
    /*---------------------------------------------------------*/
    /**pops a Media-range off the stream*/
    private String getMediaRange() throws CodeNotInTableException, IOException
    {
	String str;

	if(isWellKnownMedia())
	    str=getWellKnownMedia();
	else
	    str=getExtensionMedia();

	if(available()>0)
	    str+=";"+getParameter();

	return str;
    }
    /*-----------------------------------------------------------*/

    /** pops a Accept-Language from the stream*/
    private String getAcceptLanguageValue() throws IOException, CodeNotInTableException
    {
	if(isConstrainedLanguage())
	    return getConstrainedLanguage();
	else
	    return getAcceptLanguageGeneralForm();
    }
    /*-----------------------------------------------------------*/
    /**Returns true if the the stream starts with a
       ConstrainedLanguage*/
    private boolean isConstrainedLanguage() throws IOException
    {
	return isAnyLanguage()||isConstrainedEncoding();
    }
    /*-----------------------------------------------------------*/
    /**Returns true if the stream starts with a Any-Language*/
    private boolean isAnyLanguage() throws IOException
    {
	byte  b;

	//\128
	mark(1);
	b=(byte)read();
	reset();
	
	return(b==128);
    }
    /*-----------------------------------------------------------*/
    /** returns true if the stream starts with a 
	Constrained-encoding*/
    private boolean isConstrainedEncoding() throws IOException
    {
	return(isExtensionMedia()||isShortInteger());
    }
    /*-----------------------------------------------------------*/
    /** Pops a Constrained-language from the Stream*/
    private String getConstrainedLanguage() throws IOException,CodeNotInTableException
    {
	if(isAnyLanguage())
	    return getAnyLanguage();
	else
	    /*I hope this is encoded using 
	      WSP, Appendix A, table 41*/
	    return (new LanguageTable()).getName((new Byte(getConstrainedEncoding()).byteValue()));
    }
    /*-----------------------------------------------------------*/
    /**pops the Any-language token from the stream*/
    private String getAnyLanguage() throws IOException
    {
	read();
	return new String("*");
    }
    /*-----------------------------------------------------------*/
    /**pops an Accept-language-general-forom from the stream*/
    private String getAcceptLanguageGeneralForm() throws IOException,CodeNotInTableException
    {
	/*I _Hope_ WSP 8.4.2.10 should bve interpreted as
	  the Value-length includes the optional Q-Value*/
	
	
	WspInStream bvec=getSubStream(getValueLength());
	String str;
	
	if(bvec.isWellKnownLanguage())
	    str=bvec.getWellKnownLanguage();
	else
	    str=bvec.getTextString();
	
	if(bvec.available()>0)
	    str+=";q="+bvec.getQValue();
	
	return str;
    }
    /*---------------------------------------------------------*/
    /**Returns true if the stream starts with a 
       Well-known-language*/
    private boolean isWellKnownLanguage() throws IOException
    {
	return isAnyLanguage()||isIntegerValue();
    }
    /*-----------------------------------------------------------*/
    /** pops a Value-length from the stream*/
    private int getValueLength() throws IOException
    {
	if(isShortLength())
	    return getShortLength();
	else{
	    //flush the length-quote
	    read();
	 
	    return getLength();
	}
    }
    /*-----------------------------------------------------------*/
    /**Pops a Length from the Stream*/
    private int getLength() throws IOException
    {
	return getUIntVarInteger();
    }
    /*-----------------------------------------------------------*/
    /**Pops a Short-length off the Stream*/ 
    private byte getShortLength() throws IOException
    {
	return (byte)read();
    }
    /*-----------------------------------------------------------*/
    /**Pops a Constrained-encoding off the Stream*/
    private String getConstrainedEncoding() throws IOException
    {
	if(isExtensionMedia())
	    return getExtensionMedia();
	else
	    return (new Byte(getShortInteger()).toString());
    }
    /*-----------------------------------------------------------*/
    /**Pops a short integer from the vector*/
    private byte getShortInteger() throws IOException
    {
	//As described in WSP 8.4.2.1
	return (byte)(read()&0x7F);
    }
    /*-----------------------------------------------------------*/
    /**Pops Extensionmedia off the stream*/
    private String getExtensionMedia() throws IOException
    {
	String str;
	/*This consists of text 
	  followed by an end-of-string*/
	str=new String(getText());
	read();
	return(str);
    }
    /*-----------------------------------------------------------*/
    /**Pops a TEXT (as in RFC 2616) from the stream*/
    private String getText() throws IOException
    {
	String str=new String();
	
	while(isText())
	    str+=(char)read();
	return str;
    }
    /*-----------------------------------------------------------*/
    /** return true if first element of the stream is TEXT
	(as in RFC 2616)*/
    private boolean isText() throws IOException
    {
	Integer b;

	mark(1);
	b=new Integer(read());
	reset();

	if(CTL.contains(b))
	    if(isLWS())
		return true;
	    else
		return false;
	return true;
    }
    /*-----------------------------------------------------------*/
    /** return true if the vector starts with an LWS
	(as in RFC 2616)*/
    private boolean isLWS() throws IOException
    {
	Integer first;
	int second;

	mark(2);
	first=new Integer(read());
	second=read();
	reset();

	if(CRLF.contains(first)){
	    //SPACE or HT
	    if((second==32)||second==9)
		return true;
	}
	else{
	    //SPACE or HT
	    if((first.intValue()==32)||first.intValue()==9)
		return true;
	}
	return false;
    }
    /*-----------------------------------------------------------*/
    /**Pops an Accept-Charset header from the stream*/
    private String getAcceptCharsetValue() throws IOException, CodeNotInTableException
    {
	if(isConstrainedCharset())
	    return getConstrainedCharset();
	else
	    return getAcceptCharsetGeneralForm();
    }
    /*-----------------------------------------------------------*/
    /** retruns true if the stream starts with a 
	Constrained-charset*/
    private boolean isConstrainedCharset() throws IOException
    {
	return isConstrainedEncoding();
    }
    /*-----------------------------------------------------------*/
    /** Pops a Constrained-charset from the stream*/
    private String getConstrainedCharset() throws IOException, CodeNotInTableException
    {
	//Encoded using WSP, Appendix A, table 42
	return CharacterSetTable.getSet((new Integer(getConstrainedEncoding()).intValue()));
    }
    /*-----------------------------------------------------------*/
    /** Pops a Accept-charset-general-form off the stream*/
    private String getAcceptCharsetGeneralForm() throws IOException, CodeNotInTableException
    {
	int len=getValueLength();
	WspInStream bvec=getSubStream(len);
	String str;
	
	if(bvec.isWellKnownCharset())
	    str=bvec.getWellKnownCharset();
	else
	    str=bvec.getTokenText();
	
	if(bvec.available()>0)
	    str+="; q="+bvec.getQValue();
	
	return str;
    }
    /*--------------------------------------------------------*/
    /**returns true if the stream starts with a
       Well-known-charset*/
    private boolean isWellKnownCharset() throws IOException
    {
	return isIntegerValue();
    }
    /*-----------------------------------------------------------*/
    /**creates a HTTPHeader with the contents of the stream*/
    HTTPHeader decodeHeader() throws IOException, CloneNotSupportedException, ShiftSequenceException, CodeNotInTableException, MalformedHeaderException, ContentRangeException
    {
	String str=new String();
	byte wsp;

	//first comes a header
	if(isMessageHeader())
	    return getMessageHeader();
	else
	    //Nokia Wap toolkit sends crap )-:
	    if(isShiftSequence())
		return  getShiftSequence();
	    else
		throw new MalformedHeaderException();
    }
    /*------------------------------------------------------------------------------*/
    private boolean isShiftSequence() throws IOException
    {
	int f,s;
	
	mark(2);
	f=read();
	s=read();
	reset();

	if(f==127) //Shift-delimiter
	    if(s>=1) //Page-identity
		return true;
	else
	    if((f>=1)&&(f<=31)) //Short-cut-shift-delimiter
		return true;
	return false;
    }
    /*------------------------------------------------------------------------------*/
    /**returns true if the stream starts with a Message-header*/
    private boolean isMessageHeader() throws IOException, CloneNotSupportedException
    {
	return isWellKnownHeader()||isApplicationHeader();
    }
    /*------------------------------------------------------------------------------*/
    /**returns true if the stream starts with a Well-known-header*/
    private boolean isWellKnownHeader() throws IOException
    {
	return isShortInteger();
    }
    /*------------------------------------------------------------------------------*/
    /** Returns true if stream starts with a Application-header*/
    private boolean isApplicationHeader() throws IOException, CloneNotSupportedException
    {
	boolean temp=false;
	WspInStream str;

	/* Token-text followed by
	   Application-specific-value*/
	if(isTokenText()){
	    str=(WspInStream)clone();
	    if(str.isApplicationSpecificValue())
		temp=true;
	    reset();
	}
	return temp;
    }
    /*------------------------------------------------------------------------------*/
    /**return true if the first byte of the vector is the 
       start of a token-text*/
    private boolean isTokenText() throws IOException
    {
	mark(1);
	Integer f=new Integer(read());
	reset();

	/*This consists of a token and
	  a end-of-string.
	  Token as in RFC2616*/
	
	// 	if(CHAR.contains(new Integer(f))&&!(CTL.contains(new Integer(f))&&!separators.contains(new Integer(f))))
// 	    return true;
// 	else
// 	    return false;

	if(CHAR.contains(f))
	    if(!CTL.contains(f))
		if(!separators.contains(f))
		    return true;
	return false;
    }
    /*------------------------------------------------------------------------------*/
    /**returns true if the streamn starts with a Application-specific-value*/
    private boolean isApplicationSpecificValue() throws IOException, CloneNotSupportedException
    {
	return isTextString();
    }
    /*------------------------------------------------------------------------------*/
    /**returns true if the stream starts with a text-stream*/
    private boolean isTextString() throws IOException, CloneNotSupportedException
    {
	int f;
	boolean temp;
	WspInStream tmpStr;
	//as in WSP 8.4.2.1
	mark(1);
	f=read();
	reset();

	if(f==127){
	    tmpStr=(WspInStream)clone();
	    tmpStr.read();
	    if(tmpStr.isText()){
		tmpStr.mark(1);
		f=tmpStr.read();
		tmpStr.reset();
		if(f>=128){
		    tmpStr.getText();
		    if(tmpStr.isEndOfString())
			return true;
		    else
			return false;
		}
		else
		    return false;
	    }
	    else
		return false;
	}
	else{
	    mark(1);
	    f=read();
	    reset();
	    if(f<=127){
		tmpStr=(WspInStream)clone();
		if(tmpStr.isText()){
		    tmpStr.getText();
		    if(tmpStr.isEndOfString())
			return true;
		    else
			return false;
		}
		else
		    return false;
	    }
	    else
		return false;
	}
    }
    /*------------------------------------------------------------------------------*/
    /**returns true if stream starts with End-of-string*/
    private boolean isEndOfString() throws IOException
    {
	int temp;
	
	mark(1);
	temp=read();
	reset();

	return(temp==0);
    }
    /*------------------------------------------------------------------------------*/
    /**Pops a Token-text from the stream*/
    private String getTokenText() throws IOException
    {
	String str=getToken();
	
	getEndOfString();
	return str;
    }
    /*------------------------------------------------------------------------------*/
    /** Pops the token (as in RFC 2616) from the start of the stream*/
    private String getToken() throws IOException
    {
	String str=new String();
	Integer b;
	
	do{
	    str+=(char)read();
	    mark(1);
	    b=new Integer(read());
	    reset();
	}while((CHAR.contains(b))&&
	       !((CTL.contains(b))||(separators.contains(b))));
	
	return str;
    }
    /*------------------------------------------------------------------------------*/
    /** Pops a End-of-String*/
    private byte getEndOfString() throws IOException
    {
	return (byte)read();
    }
    /*------------------------------------------------------------------------------*/
    /** Pops a Message-header from the stream*/
    private HTTPHeader getMessageHeader() throws IOException, CodeNotInTableException, ContentRangeException, CloneNotSupportedException
    {
	if(isWellKnownHeader())
	    return getWellKnownHeader();
	else 
	    return getApplicationHeader();
    }
    /*------------------------------------------------------------------------------*/
    /** Pops a ApplicationHeader from the stream*/
    private HTTPHeader getApplicationHeader() throws IOException
    {
	return new HTTPHeader(getTokenText(),getApplicationSpecificValue());
    }
    /*------------------------------------------------------------------------------*/
    /**Pops a Application-specific-value off the stream*/
    private String getApplicationSpecificValue() throws IOException
    {
	return getTextString();
    }
    /*------------------------------------------------------------------------------*/
    /**Pops a Well-known-header off the stream*/
    private HTTPHeader getWellKnownHeader() throws IOException, CodeNotInTableException, ContentRangeException, CloneNotSupportedException
    {
	int fn=getShortInteger();
	return new HTTPHeader(new HeaderFieldNameTable().getName((byte)fn),getWapValue(fn));
    }
    /*------------------------------------------------------------------------------*/
    /** Pops a Shift-sequence off the stream and throws the right exception*/
    private HTTPHeader getShiftSequence() throws ShiftSequenceException, IOException
    {
	if(isShortCutShiftDelimiter())
	    throw new ShiftSequenceException(getShortCutShiftDelimiter());
	else{
	    getShiftDelimiter();
	    throw new ShiftSequenceException(getPageIdentity());
	}
    }
    /*------------------------------------------------------------------------------*/
    /** Pops a page Identity off the stream*/
    private byte getPageIdentity() throws IOException
    {
	return (byte)read();
    }
    /*------------------------------------------------------------------------------*/
    /**pops a Shift-delimiter off the stream*/
    private byte getShiftDelimiter() throws IOException
    {
	return (byte)read();
    }
    /*------------------------------------------------------------------------------*/
    /**Pops a Short-cut-shift-delimiter off the stream*/
    private byte getShortCutShiftDelimiter() throws IOException
    {
	return (byte)read();
    }
    /*------------------------------------------------------------------------------*/
    /**returns true if the stream begins with a Short-cut-shift-delimiter*/
    private boolean isShortCutShiftDelimiter() throws IOException
    {
	int b;
	mark(1);
	b=read();
	reset();

	return((b>=1)&&(b<=31));
    }
//     /*------------------------------------------------------------------------------*/
//     /**Pops a Well-known-field-name off the stream*/
//     public int getWellKnownFieldName() throws IOException
//     {
// 	return getShortInteger();
//     }
//     /*------------------------------------------------------------------------------*/
    /* Pops a Wap-value off the stream.
       The type of the value depends on str*/
       
    private String getWapValue(int str) throws CodeNotInTableException, IOException, ContentRangeException, CloneNotSupportedException
    {
	//and here we just test all the cases...
	switch(str){
	case 0x00: //Accept
	    return getAcceptValue();
	case 0x01: //Accept-charset
	    return getAcceptCharsetValue();
	case 0x02: //Accept-encoding
	    return getContentEncodingValue();
	case 0x03: //Accept-Language
	    return getAcceptLanguageValue();
	case 0x04: //Accept-ranges
	    return getRangesValue();
	case 0x05: //Age
	    return ""+getIntegerValue();
	case 0x06: //Allow
	    return PDUTypeTable.getName(getShortInteger());
	case 0x07: //Authorization
	    return getAuthorizationValue();
	case 0x08://Cache-Control
	    return getCacheControlValue();
	case 0x09: //Connection
	    return getConnectionValue();
	case 0x0A: //Content-base
	    return getTextString();
	case 0x0B: //Content-encoding
	    return getContentEncodingValue();
	case 0x0C: //Content-language
	    return getContentLanguageValue();
	case 0x0D: //Content-length
	    return ""+getIntegerValue();
	case 0x0E: //Content-location
	    return getTextString();
	case 0x0F: //Content-MD5
	    return getContentMD5Value();
	case 0x10: //Content-range
	    return getContentRange();
	case 0x11: //Content-type
	    return getContentTypeValue();
	case 0x12: //Date
	    return getDateValue();
	case 0x13: //Etag
	    return "\""+getTextString()+"\"";
	case 0x14: //Expires
	    return getDateValue();
	case 0x15: //From
	    return getTextString();
	case 0x16: //Host
	    return getTextString();
	case 0x17: //If-modified-since
	    return getDateValue();
	case 0x18: //If-match
	    return "\""+getTextString()+"\"";
	case 0x19: //If-none-match
	    return "\""+getTextString()+"\"";
	case 0x1A: //If-range
	    return getIfRange();
	case 0x1B: //If-unmodified-since
	    return getDateValue();
	case 0x1C: //Location
	    return getTextString();
	case 0x1D: //Last-modified
	    return getDateValue();
	case 0x1E: //Max-forwards
	    return ""+getMaxForwards();
	case 0x1F: //Pragma
	     return getPragmaValue();
	case 0x20: //Proxy-authenticate
	    return getSubStream(getValueLength()).getChallenge();
	case 0x21: //Proxy-authorization
	    return getSubStream(getValueLength()).getCredentials();
	case 0x22:
	    return getPublicValue();
	case 0x23: //Range
	    return getSubStream(getValueLength()).getRangeValue();
	case 0x24: //Referer
	    return getTextString();
	case 0x25: //Retry-after
	    return getRetryAfterValue();
	case 0x26: //Server
	    return getTextString();
	case 0x27: //Transfer-encoding
	    return getTransferEncodingValues();
	case 0x28: //Upgrade
	    return getTextString();
	case 0x29: //User-agent
	    return getUserAgentValue();
	case 0x2A: //Vary
	    return getFieldName();
	case 0x2B: //Via
	    return getTextString();
	case 0x2C: //Warning
	    return getWarning();
	case 0x2D: //WWW-authenticate
	    return getSubStream(getValueLength()).getChallenge();
	case 0x2E: //Content-disposition
	    return getSubStream(getValueLength()).getContentDispositionValue();
	case 0x2F: //X-wap-application-id
	    return getApplicationIdValue();
	case 0x30: //X-wap-content-URI
	    return getTextString();
	case 0x31: //X-wap-initiator-uri
	    return getTextString();
	case 0x32: //Accept-application
	    return getAcceptApplicationValue();
	case 0x33: //Bearer-indication
	    return ""+getIntegerValue();
	case 0x34: //Push-flag
	    return ""+getShortInteger();
	case 0x35: //Profile
	    return getTextString();
	case 0x36: //Profile-diff
	    return getSubStream(getValueLength()).getProfileDiffValue();
	default:
	    throw new CodeNotInTableException(str+" is an unknown header )-:");
	}
    }
    /*--------------------------------------------------------*/
    /**reads a profile-diff-value off the stream*/
    private String getProfileDiffValue() throws IOException
    {
	String str="";
	while(available()>0)
	    str+=read();
	return str;
    }
    /*--------------------------------------------------------*/
    /**Pops a Content-disposition off thte stream*/
    private String getContentDispositionValue() throws CodeNotInTableException, IOException
    {
	String str;

	int b=read();

	if(b==128)//\128
	    str="Form-data";
	else
	    str="attachment";

	while(available()>0)
	    str+=";"+getParameter();
	    
	return str;
    }
    /*--------------------------------------------------------*/
    private String getRangeValue() throws IOException
    {
       	if(read()==128){//Byte-range-spec
	    String str="bytes="+getUIntVarInteger()+"-";
	    if(available()>0)
		str+=getUIntVarInteger();
	    return str;
	}
	else //Suffix-byte-range-spec
	    return "-"+getUIntVarInteger();
    }
    /*--------------------------------------------------------*/
    /**Pops Credentials off the vector*/
    private String getCredentials() throws CodeNotInTableException, IOException
    {
	mark(1);
	int b=read();
	reset();

      	//Basic
	if(b==128){
	    read();
	    return "Basic "+getBasicCookie();
	}
	else{
	    String str=getTokenText();
	    if(available()>0)
		str+=getParameter();

	    while(available()>0)
		str+=","+getParameter();
	    return str;
	}
    }
    /*--------------------------------------------------------*/
    /**Pops a Basic-cookie off the vector*/
    private String getBasicCookie() throws IOException
    {
	return (Base64Coder.encode(getTextString()+":"+getTextString()));
    }
    /*--------------------------------------------------------*/
    /**Pops a challenge off the stream*/
    private String getChallenge() throws CodeNotInTableException, IOException
    {
	mark(1);
	int b=read();
	reset();
	
	if(b==128){
	    read();
	    return "basic realm=\""+getTextString()+"\"";
	}
	else{
	    String str=getTokenText()+" realm=\""+getTextString()+"\"";
	    while(available()>0)
		str+=","+getParameter();
	    return str;
	}
    }
    /*--------------------------------------------------------*/
    /**pops a accept-application-value off the stream*/
    private String getAcceptApplicationValue() throws IOException, CloneNotSupportedException
    {
	mark(1);
	int b=read();
	reset();

	if(b==128)
	    return "*";
	else
	    return getApplicationIdValue();
    }
    /*--------------------------------------------------------*/
    /**Pops a application-id-value off the stream*/
    private String getApplicationIdValue() throws CloneNotSupportedException, IOException
    {
	if(isTextString())
	    return getTextString();
	else
	    return ""+getIntegerValue();
    }
    /*--------------------------------------------------------*/
    /**Pops a warning off the stream*/
    private String getWarning() throws IOException
    {
	if(isShortInteger())
	    /* the warning should consist of warning-code, warning-agent
	       and warning-text, so I make the rest up....*/
	    return getShortInteger()+" "+InetAddress.getLocalHost().getHostName()+" This wasn't good";
	else{
	    getValueLength();
	    return getShortInteger()+" "+getTextString()+" \""+getTextString()+"\"";
	}
    }
    /*--------------------------------------------------------*/
    /**Pops a Max-forwards field off the stream and decreses it
       If 0 is reached, it shouldn't be forwarded. However, 
       I'm not really sure what to send, so for now i just forward it...*/
    private int getMaxForwards() throws IOException
    {
	int no=getIntegerValue();
	if(no<=0)
	    return no;
	else
	    return no-1;
    }
    /*--------------------------------------------------------*/
    /**Pops a field-name off the stream*/
    private String getFieldName() throws IOException, CodeNotInTableException
    {
	if(isTokenText())
	    return getTokenText();
	else
	    return HeaderFieldNameTable.getName(getShortInteger());
    }
    /*--------------------------------------------------------*/
    /**Pops a Transfer-encoding off the stream*/
    private String getTransferEncodingValues() throws IOException
    {
	mark(1);
	int b=read();
	reset();
	
	if(b==128){
	    read();
	    return "Chunked";
	}
	else
	    return getTokenText();
    }
    /*--------------------------------------------------------*/
    /**Pops a well known method off the stream*/
    private String getWellKnownMethod() throws CodeNotInTableException, IOException
    {
	return PDUTypeTable.getName(getShortInteger());	
    }
    /*--------------------------------------------------------*/
    private boolean isWellKnownMethod() throws IOException
    {
	return isShortInteger();
    }
    /*--------------------------------------------------------*/
    /**Pops a Retry-after-value off the stream*/
    private String getRetryAfterValue() throws IOException
    {
	getValueLength();
	if(read()==128)
	    return getDateValue();
	else 
	    return ""+getIntegerValue();
    }
    /*--------------------------------------------------------*/
    /**Pops a Public-value off the stream*/
    private String getPublicValue() throws IOException, CodeNotInTableException
    {
	if(isWellKnownMethod())
	    return getWellKnownMethod();
	else
	    return getTokenText();
    }
    /*--------------------------------------------------------*/
    /**Pops a Pragma-value off the Stream*/
    private String getPragmaValue() throws IOException, CodeNotInTableException
    {
	mark(1);
	int b=read();
	reset();

	if(b==128){
	    read();
	    return "No-Cache";
	}
	else{
	    return getSubStream(getValueLength()).getParameter();
	} 
    }
    /*--------------------------------------------------------*/
    /**Pops a If-rane off the stream*/
    private String getIfRange() throws IOException, CloneNotSupportedException
    {
	if(isTextString())
	    return "\""+getTextString()+"\"";
	else
	    return getDateValue();
    }
    /*--------------------------------------------------------*/
    /**Pops a Date-value off the stream returning it as a HTTP-date*/
    private String getDateValue() throws IOException
    {
	SimpleDateFormat df=new SimpleDateFormat("E, d MMM yyyy HH:mm:ss z");
	df.setTimeZone(TimeZone.getTimeZone("GMT"));
	return df.format(new Date((long)getLongInteger()*1000));
    }
    /*--------------------------------------------------------*/
    private String getContentTypeValue() throws IOException, CodeNotInTableException
    {
	if(isConstrainedMedia())
	    return getConstrainedMedia();
	else
	    return getContentGeneralForm();
    }
    /*--------------------------------------------------------*
    /** pops a Content-range off the stream*/
    private String getContentRange() throws IOException, ContentRangeException
    {
	//get rid of the Value-length
	getValueLength();
	/*Since we don't know the PDU size yet, 
	  we have to throw an exception and fill 
	  in this header later*/

	throw new ContentRangeException(getUIntVar(),getUIntVar());
    }
    /*--------------------------------------------------------*/
    /**Pops a ContentMD5Value off the stream*/
    private String getContentMD5Value() throws IOException
    {
	String str="";
	//Why is there a Value-length here???
	getValueLength();
	for(int i=0;i<16;i++)
	    str+=(char)read();
	return Base64Coder.encode(str);
    }
    /*--------------------------------------------------------*/
    /**Pops a Conntent-language-value off the stream*/
    private String getContentLanguageValue() throws IOException, CodeNotInTableException
    {
	if(isTokenText())
	    return getTokenText();
	else
	    return getWellKnownLanguage();
    }
    /*--------------------------------------------------------*/
    /**Pops a Well-known-language from the vector*/
    private String getWellKnownLanguage() throws CodeNotInTableException, IOException
    {
	if(isAnyLanguage())
	    return getAnyLanguage();
	else
	    //I hope this is encoded by table 41, WSP Appendix A
	    return  LanguageTable.getName((byte)getIntegerValue());
    }
    /*--------------------------------------------------------*/
    /**Pops a Connection-value off the stream*/
    private String getConnectionValue() throws IOException
    {
	mark(1);
	int b=read();
	reset();

	if(b==128){
	    read();
	    return "Close";
	}
	else
	    return getTokenText();
    }
    /*--------------------------------------------------------*/
    /**Pops a Cache-control-value off the stream*/
    private String getCacheControlValue() throws IOException, CodeNotInTableException
    {
	mark(1);
	int b=read();
	reset();
	
	switch(b){
	case 128:
	    read();
	    return "No-cache";
	case 129:
	    read();
	    return "No-store";
	case 131:
	    read();
	    return "Max-stale";
	case 133:
	    read();
	    return "Only-if-cached";
	case 134:
	    read();
	    return "Public";
	case 135:
	    read();
	    return "Private";
	case 136:
	    read();
	    return "No-transform";
	case 137:
	    read();
	    return "Must revalidate";
	case 138:
	    read();
	    return "Proxy-revalidate";
	default:
	    if(isTokenText())//Cache-extension
		return getTokenText();
	    else{
		return getSubStream(getValueLength()).getCacheDirective();
	    }
	}
    }
    /*---------------------------------------------------------*/
    /**Pops a Cache-directive off the vector*/
    private String getCacheDirective() throws CodeNotInTableException, IOException
    {
	String str;

	switch(read()){
	case 128: //\128
	    str="No-cache="+getFieldName();
	    while(available()>0)
		str+=","+getFieldName();
	    return str;
	case 130: //\130
	    return "Max-age="+getIntegerValue();
	case 131: //\131
	    return "Max-stale="+getIntegerValue();
	case 132: //\132
	    return "Min-fresh="+getIntegerValue();
	case 135: //\135
	    str="Private=\""+getFieldName();
	    while(available()>0)
		str+=","+getFieldName();
	    return str+"\"";
	}

	return getTokenText()+getParameter();
    }
    /*--------------------------------------------------------*/
    /**Pops an Authorization-value off the stream*/
    private String getAuthorizationValue() throws IOException, CodeNotInTableException
    {
	return getSubStream(getValueLength()).getCredentials();
    }
    /*--------------------------------------------------------*/
    /**Pops an integer-value from the stream*/
    private int getIntegerValue() throws IOException
    {
	/*this could be a short-intger or a
	  long integer*/
	if(isShortInteger())
	    return getShortInteger();
	else
	    return getLongInteger();
    }
    /*--------------------------------------------------------*/
    /**Pops a Long integer of the stream*/
    private int getLongInteger() throws IOException
    {
	/*this consists of a short-length followed by a
	  multi-octet-integer*/
	return getMultiOctetInteger(getShortLength());
    }
    /*--------------------------------------------------------*/
    /**Pops a multi-octet-integer with length len of
       the stream*/
    private int getMultiOctetInteger(byte len) throws IOException
    {
	int temp=0;
	
	for(int i=0;i<len;i++){
	    temp*=256;
	    temp+=read();
	} 
	return temp;
    }
    /*------------------------------------------------------------------------------*/
    private String getRangesValue() throws IOException
    {
	mark(1);
	int b=read();
	reset();

	switch(b){
	case 128:
	    read();
	    return "None";
	case 129:
	    read();
	    return "Bytes";
	default:
	    return getTokenText();
	}
    }
    /*------------------------------------------------------------------------------*/
    /**Pops a Content-encoding-value off the stream*/
    private String getContentEncodingValue() throws IOException
    {
	int b;

	mark(1);
	b=read();
	reset();

	switch(b){
	case 128: //Gzip
	    read();
	    return "Gzip";
	case 129: 
	    read();
	    return "Compress";
	case 130:
	    read();
	    return "Deflate";
	default:
	    return getTokenText();
	}
    }
    /*------------------------------------------------------------------------------*/
    /**Pops a User-agent off the stream*/
    private String getUserAgentValue() throws IOException
    {
	    return getTextString();
    }
    /*------------------------------------------------------------------------------*/
    /** Pops a uintvar from the stream*/
    int getUIntVar() throws IOException
    {
	return getUIntVarInteger();
    }
    /*------------------------------------------------------------------------------*/
    /** Pops a Text-string off the stream*/
    private String getTextString() throws IOException
    {
	String str;
	byte b;
	
	mark(1);
	b=(byte)read();
	reset();

	//As described in WSP 8.4.2.1
	if(b>127)
	    read();
	str=getText();
	read();
	return str;
    }
    /*------------------------------------------------------------------------------*/
    // test only
    public static void main(String[] argv) throws IOException, CodeNotInTableException, CloneNotSupportedException
    {
	WspInStream str=new WspInStream(new FileInputStream("/home/david/temp/dump0"));
	PDU pdu=str.mkPDU();


    }
    /*------------------------------------------------------------------------------*/


}	

    
   
    

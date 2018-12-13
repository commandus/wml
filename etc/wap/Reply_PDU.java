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

import java.util.*;
import java.text.*;
import java.io.*;
import java.net.*;
import COM.tietoenator.percom.WapGateway.wmlc.*;

/** This class holds a Reply PDU*/
class Reply_PDU extends PDU
{
    /* Instans variables */
    private ByteVector status=new ByteVector();
    private ByteVector hLen=new ByteVector();
    private ByteVector contType=new ByteVector();
    private ByteVector headers=new ByteVector();
    private ByteVector data=new ByteVector();
    
    /* Server name */
    private final String sName=new String("JWap");

    /* --- Constructor --- */

    /** Creates a Reply PDU header from the specified TID and the HttpUrlConnection */
    Reply_PDU(int tid, HttpURLConnection resp) {
	super(tid);
	String str;
	String content=null;   // used to store content-type; if content is null, then there is no content
	byte tmpByte;
	boolean viaAdded=false;
	boolean maxForwardExceptOcc=false;
	ByteVector bvtmp;

	/* use Reply PPDU, WAP WSP 8.2.3.3 */
	
	try { // catch all IOExceptions
	    try {
		if((tmpByte=StatusCodeTable.encode(resp.getResponseCode()))==WapTable.ERROR_CODE) {
		    /* don't understand status code. Sending 'Bad Gateway' and the rest of the 
		       contents in the message */
		    status.addElement(new Byte(StatusCodeTable.encode(502))); 
		}
		else {
		    status.addElement(new Byte(tmpByte));
		}
	    }
	    catch(UnknownHostException uhe) { answerError(502,"Gateway can't find requested server."); return; }
	    catch(FileNotFoundException fnfe) { answerError(404,"Gateway can't find requested file."); return; }
	    
	    content=resp.getContentType();
	    if(content!=null) {
		/* Add Content-Type header */
		HTTPHeader tmpH=new HTTPHeader("Content-Type",content);
		contType=tmpH.toWSP();
	    }
	    else {
		//  no Content-Type, use Content-Type: */*
		HTTPHeader tmpH=new HTTPHeader("Content-Type","*/*");
		contType=tmpH.toWSP();		
	    }

	    /* First element of contType contains a byte according to Header Filed Name Assignment.
	       This byte MUST NOT be sent and is therefore removed */
	    contType.removeElementAt(0);

	    /* Add headers to PDU; empty string (single CRLF) at end of HTTP headers. */
	    for(int i=1;(str=resp.getHeaderFieldKey(i))!=null;i++) {
		/* check if via-header already exists */
		if(str.equalsIgnoreCase("Via")) {
		    /* append our gateway to list */
		    headers.addElement((new HTTPHeader(str, resp.getHeaderField(i)+", "+sName)).toWSP());
		    viaAdded=true;
		    continue; // read next header
		}

		/* update Max-Forwards header */
		if(str.equalsIgnoreCase("Max-Forwards")) {
		    try {
			int maxf=Integer.parseInt(resp.getHeaderField(i));
			if(maxf==0)
			    maxForwardExceptOcc=false;
			else
			    maxf--; // decrease max-forwards
			headers.addElement((new HTTPHeader("Max-Forwards",Integer.toString(maxf))).toWSP());
		    }
		    catch (NumberFormatException nfe) { nfe.printStackTrace(System.err); }
		    continue; // read next header
		}

		/* Do not encode Content-Type header or Content-Length header*/
		if(!(str.equalsIgnoreCase("Content-Type") || str.equalsIgnoreCase("Content-Length"))) {
		    bvtmp=(new HTTPHeader(str, resp.getHeaderField(i))).toWSP();
		    if(bvtmp.size()>0) // if size=0 => malformed header, skip it
			headers.addElement(bvtmp.clone());
		}
	    }

	    /* Add Gateway name to Via-header */
	    if(!viaAdded)
		headers.addElement((new HTTPHeader("Via", sName)).toWSP());

	    /* check if Max-Forwards was zero */
	    if(maxForwardExceptOcc)
		System.err.println("MaxForwardsException occured! No action taken.");
	    
	    /* read data and put in a ByteVector */
	    byte[] buffer=new byte[1024];
	    byte[] tmparray;
	    int bytesRead;
	    InputStream fromServer=resp.getInputStream();
	    
	    while((bytesRead=fromServer.read(buffer))>0) {
		if(bytesRead!=buffer.length) {
		    tmparray=new byte[bytesRead];
		    System.arraycopy(buffer,0,tmparray,0,bytesRead);
		}
		else
		    tmparray=buffer;
		/* add to data vector */
		data.addElement(tmparray.clone());
	    }
	}
	catch(IOException ioe) { answerError(502,"An error occured while accessing the http-server."); return; }
	
	if(data.size()>0) {
	    /* if data is wml encode to binary wml */

	    /* look for content-type byte */
	    byte[] wspBytes=contType.toByteArray();
	    int index=0;  // index to content-type byte in the array
	    if(wspBytes[0]<0) { 
		/* first bit is set, header has no parameters */
		index=0;
	    }
	    else if(wspBytes[0]==(byte)0x7f) { // there is a value-length: length-quote length
		index=1; // start after length-quote
		while(wspBytes[index]<0)  // loop while fist bit is set
		    index++;
		index++; // index now points to content-Type
	    }
	    else { // there is a value-length: short-length 
		index=1; // content-type is after short-length
	    }
	
	    /* Check if content-type is wml; if so change to wmlc */
	    if(wspBytes[index]<0) { // first bit is set => content-type is a short int and not a text field
		if( (byte)(wspBytes[index]&(0x7f)) == ContentTypeTable.getCode("text/vnd.wap.wml")) {
		    /* read out charset from HTTP Content-Type header */
		    String chSet=null;
		    String ctHead=resp.getContentType();
		    int parStart=ctHead.indexOf(';'); // parameters start with ';'
		    
		    if(parStart>=0) { // there is a ';'
			int charsetIndex=ctHead.toLowerCase().indexOf("charset",parStart); // look for 'charset', ignore case
			if(charsetIndex>=0) { // there is a charset parameter
			    int eqIndex=ctHead.indexOf('=',charsetIndex);       // look for '=' sign
			    chSet=ctHead.substring(eqIndex+1);     // character set is after '='
			    parStart=chSet.indexOf(';');           // look for more parameters
			    if(parStart>=0)
				chSet=chSet.substring(0,parStart); // cut of rest of parameters
			}
		    }
		    
		    /* build new Content-Type header */
		    if(chSet==null) // no character set from server, use utf-8
			contType=(new HTTPHeader("Content-Type","application/vnd.wap.wmlc; charset=utf-8")).toWSP();
		    else 
			contType=(new HTTPHeader("Content-Type","application/vnd.wap.wmlc; charset="+chSet)).toWSP();
		    
		    /* First element of contType contains a byte according to Header Filed Name Assignment.
		       This byte MUST NOT be sent and is therefore removed */
		    contType.removeElementAt(0);
		
		    try {
			ByteVector dataVec=new ByteVector();
			
			/* compile content into wmlc */
			if(chSet==null) 
			    /* no charset specified; use default character sets:
			       wml document: iso-8859-1  (HTTP)
			       binary encoding of wml document: utf-8  (WBXML) */
			    dataVec.addElement(WMLCompiler.encode(new ByteArrayInputStream(data.toByteArray()),"iso-8859-1","utf-8"));
			else
			    /* use the character set specified in the header for both 
			       the document and the binary representation */
			    dataVec.addElement(WMLCompiler.encode(new ByteArrayInputStream(data.toByteArray()),chSet,chSet));
			
			data=dataVec;
		    }
		    catch (CodeNotInTableException ce) {
			answerError(502,"The requested document contains character encoding not supported by gateway");
			return;
		    }
		    catch (NotWMLDocumentException nwe) {
			answerError(502,"The requested document is not a wml document.");
			return;
		    }
		    catch (WMLCParserException wpe) { 
			answerError(502,"The requested document is not valid and could not be parsed."); 
			return;
		    }
		}
	    }
	
	    /* Add Content-Length to headers */
	    headers.addElement((new HTTPHeader("Content-Length", Integer.toString(data.countBytes()))).toWSP());
	}

	/* Header length */
	hLen.addElement(WSPInteger.makeUintvar(contType.countBytes()+headers.countBytes()));
    }

    /** Creates a Reply PDU with the specified startuscode and a textstring.
     * @param tid Transaction ID
     * @param statusCode HTTP status code
     * @param errString String to be displayed on the phone 
     */
    Reply_PDU(int tid,int statusCode, String errString) {
	super(tid);
	answerError(statusCode, errString);	
    }

    /* --- Methods to build a PDU when gateway discovers an error --- */
    
    /** constructs an answer with the status code and a textstring */
    private void answerError(int statusCode, String errorString) {
	status.removeAllElements(); // clear status
	byte sc=StatusCodeTable.encode(statusCode);
	if(sc!=WapTable.ERROR_CODE)
	    status.addElement(new Byte(sc)); /* Bad Gateway */
	else
	    status.addElement(new Byte(StatusCodeTable.encode(502))); /* Bad Gateway */
	/* Add Content-Type header */
	contType=(new HTTPHeader("Content-Type","application/vnd.wap.wmlc")).toWSP();
	/* First element of contType contains a byte according to Header Filed Name Assignment.
	   This byte MUST NOT be sent and is therefore removed */
	contType.removeElementAt(0);

	hLen.addElement(WSPInteger.makeUintvar(contType.countBytes()+headers.countBytes()));

	String answer="<?xml version=\"1.0\"?>\n";
	answer+="<!DOCTYPE wml PUBLIC \"-//WAPFORUM//DTD WML 1.1//EN\" \"http://www.wapforum.org/DTD/wml_1.1.xml\">\n\n";
	answer+="<wml><card id=\"c0\" title=\"Gateway error\"><p>"+errorString+"</p></card></wml>";
	
	data=new ByteVector();  // clear data vector
	/* compile WML */
	try {
	    data.addElement(WMLCompiler.encode(new ByteArrayInputStream(answer.getBytes("iso-8859-1")),"iso-8859-1","utf-8"));
	}
	catch (CodeNotInTableException cte) { cte.printStackTrace(System.err); }
	catch (UnsupportedEncodingException uee) { uee.printStackTrace(System.err); }
	catch (NotWMLDocumentException nwe) { nwe.printStackTrace(System.err); }
	catch (WMLCParserException wpe) { wpe.printStackTrace(System.err); }
    }

    /* --- Methods on Reply_PDU --- */

    /** Dummy method inherited from PDU class */
    Reply_PDU getResponse() {
	System.err.println("getResponse in class Reply_PDU called. Stupid thing to do.");
	return null;
    }

    byte[] getByteArray() {
	byte[] st=status.toByteArray();
	byte[] hL=hLen.toByteArray();
	byte[] cT=contType.toByteArray();
	byte[] he=headers.toByteArray();
	ByteVector dataVec=new ByteVector();
	ByteVector bv=new ByteVector();

	/* add tid before PDU */
	bv.addElement(new Byte((byte)tid));

	/* add type field to PDU */
	bv.addElement(new Byte(PDUTypeTable.getCode("Reply")));

	/* add Reply PDU headers to ByteVector */
	bv.addElement(st);
	bv.addElement(hL);
	bv.addElement(cT);
	bv.addElement(he);

 	/* add data to PDU */
	bv.addElement(data);

	return bv.toByteArray();
    }
    
    /** Returns the size of the Reply_PDU in bytes */
    int size() {
	/* +2 because of the tid and PDU type at the beginning of the PDU. */
	return 2+status.countBytes()+hLen.countBytes()+contType.countBytes()+headers.countBytes()+data.countBytes();
    }	

}


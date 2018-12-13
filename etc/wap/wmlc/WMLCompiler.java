/*======================================================================
*
*This file is part of Jwap, the Java Wap Gateway.
*Copyright (C) TietoEnator PerCom AB 
* <http://enator.se/teknik/percom/>
*
* The Jwap Project
*       David Juran & Anders Mårtensson
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

package COM.tietoenator.percom.WapGateway.wmlc;

import javax.xml.parsers.*;
import org.xml.sax.*;
import java.io.IOException;
import java.io.ByteArrayInputStream;
import java.io.*;  // debug
import org.w3c.dom.*;

import COM.tietoenator.percom.WapGateway.ByteVector;
import COM.tietoenator.percom.WapGateway.WSPInteger;
import COM.tietoenator.percom.WapGateway.CharacterSetTable;
import COM.tietoenator.percom.WapGateway.CodeNotInTableException;

/** Reads a WML document and compiles it into WML binary form. */
public class WMLCompiler {

    /* ------------ class varables (constants) ------------ */
    private static final byte CHILD_BIT=0x40;
    private static final byte ATTR_BIT=(byte)0x80;
    
    /* --------------- internal classes --------------- */
    /** exception class */
    private static class InternalEncodingException extends Exception {
    
	public InternalEncodingException() {
	    super();
	}
    
	public InternalEncodingException(String s) {
	    super(s);
	}
    }
    
    /** EntityResolver for WMLCompiler */
    private static class LocalDTDResolver implements EntityResolver {
	public InputSource resolveEntity(String publicId, String systemId) throws SAXException, IOException {
	    /* Tell the SAXParser to allways use the wml DTD. */

	    /* The file should be read if the file is inside a jar file OR if it's in the directory structure */
	    InputStream dtdFile = ClassLoader.getSystemResourceAsStream("COM/tietoenator/percom/WapGateway/wmlc/wml_1.1.xml"); 
	    return new InputSource(dtdFile);
	}
    }

    /* --------------- instance variables --------------- */
    private static ByteVector wmlcVector;   // store binary xml
    private static String wmlCharset;       // charset used in wml document
    private static String wbxmlCharset;     // charset used in binary format

    /* ------------ private help functions ------------ */

    private static void init(String wmlChset, String wbxmlChset) throws CodeNotInTableException { 
	wmlcVector=new ByteVector();
	wmlCharset=wmlChset;
	wbxmlCharset=wbxmlChset;

	/* check if charset used in binary representation has a MIB enum */
	int mib=CharacterSetTable.getMIB(wbxmlChset);
	if(mib==0)
	    throw new CodeNotInTableException("Character set not found in character table: "+wbxmlCharset);
	
	/* Write information about WBXML version, charset and so on. */
	wmlcVector.addElement(new Byte((byte)0x01));         // WBXML version 1.1
	wmlcVector.addElement(new Byte((byte)0x04));         // WML 1.1 Public ID ("-//WAPFORUM//DTD WML 1.1//EN")
	wmlcVector.addElement(WSPInteger.makeUintvar(mib));  // add character set
	wmlcVector.addElement(new Byte((byte)0x00));         // no string table
    }

    private static ByteVector makeText(String txt) throws InternalEncodingException {
	ByteVector retVec=new ByteVector();
	/* write textstring */
	retVec.addElement(new Byte(GlobalToken.STR_I));
	/* encode text using wbxmlCharset */
	try {
	    retVec.addElement(txt.getBytes(wbxmlCharset));
	}
	catch (UnsupportedEncodingException uee) {
	    throw new InternalEncodingException("UnsupportedEncodingException occured: "+uee.getMessage());
	}
	retVec.addElement(new Byte(GlobalToken.STRING_END));
	return retVec;
    }

    /** Writes a variable to the wmlc document.
	varString is the variables string without any $ or parenthesis */
    private static ByteVector makeVariable(String varString) throws InternalEncodingException {
	ByteVector retVec=new ByteVector();
        String var;  // varable name without ':'
	int colonIndex=varString.indexOf(':');
	
	/* add correct global token */
        if(colonIndex<0) { // no transformation
	    retVec.addElement(new Byte(GlobalToken.EXT_I_2));
	    var=varString;
	}
	else {
	    if( Character.toLowerCase(varString.charAt(colonIndex+1))=='e'  ) { // escaped
		retVec.addElement(new Byte(GlobalToken.EXT_I_0));
	    } else if( Character.toLowerCase(varString.charAt(colonIndex+1))=='u'  ) { // unescaped
		retVec.addElement(new Byte(GlobalToken.EXT_I_1));
	    } else if( Character.toLowerCase(varString.charAt(colonIndex+1))=='n'  ) { // notransform
		retVec.addElement(new Byte(GlobalToken.EXT_I_2));
	    }
	    var=varString.substring(0,colonIndex);
	}

	try {
	    retVec.addElement(var.getBytes(wbxmlCharset));
	}
	catch (UnsupportedEncodingException uee) {
	    throw new InternalEncodingException("UnsupportedEncodingException occured: "+uee.getMessage());
	}

	/* terminate string */
	retVec.addElement(new Byte(GlobalToken.STRING_END));
	return retVec;
    }

    /* --------------- private methods --------------- */

    /* encodes a ATTR_VALUE */
    private static ByteVector encodeAttrValue(String text) throws InternalEncodingException {
	ByteVector valVec=new ByteVector();
	boolean writingText=false;

	/* starts with one character at startIndex and tests if there is a match in the 
	   AttrValue table. Adds one character each round and tests until a match is found, 
	   a '$'-sign is encountered or end of text string is reached.
	   NOTE: "http://www." and "https://www." will never match this way, because
	   "http://" and "https://" will match earlier. */
    outer:
	for(int startIndex=0; startIndex<text.length(); startIndex++) {

	    /* check if we might have a variable */
	    if(text.charAt(startIndex)=='$') {
		if(text.charAt(startIndex+1)=='$') { // an escaped '$'-sign: write it out
		    if(!writingText) { // new inline string
			valVec.addElement(new Byte(GlobalToken.STR_I));
			writingText=true;
		    }
		    valVec.addElement(new Byte((byte)'$'));
		    startIndex+=1;  // increase startIndex
		    continue;       // and continue behind '$$'
		}
		else { // it is a variable
		    int varStart=startIndex+1;
		    int varEnd;
		    if(text.charAt(varStart)=='(') {  // if varable is enclosed in parenthesis
			varEnd=text.indexOf(')',varStart);
			if(varEnd==-1) 
			    throw new InternalEncodingException("Not wellformed variable: "+text.substring(varStart));
			if(writingText) { // end string
			    valVec.addElement(new Byte(GlobalToken.STRING_END));
			    writingText=false;
			}
			valVec.addElement(makeVariable(text.substring(varStart+1,varEnd)));  // cut off parenthesis
			startIndex=varEnd;  // continue at character after ')' (for loop will increase startIndex)
		    }
		    else {  // look for end of variable
			varEnd=varStart;
			while(varEnd<text.length() && isVarnameChar(text.charAt(varEnd)))
			    varEnd++;
			if(writingText) { // end string
			    valVec.addElement(new Byte(GlobalToken.STRING_END));
			    writingText=false;
			}
			valVec.addElement(makeVariable(text.substring(varStart,varEnd)));
			startIndex=varEnd;  // continue at character after variable name
		    }
		    continue outer;   // continue after variable
		}
	    }  // end variables part
	    else { /* not a varable; look for string matches using the algorithm described before */		
		for(int endIndex=startIndex+1; endIndex<text.length(); endIndex++) {
		    String testString=text.substring(startIndex,endIndex+1);
		    byte tokenValue=AttrValue.getValue(testString);
		    if(tokenValue!=0) {
			/* we have a match: encode attribute value and continue looking after endIndex */
			if(writingText) { // end string
			    valVec.addElement(new Byte(GlobalToken.STRING_END));
			    writingText=false;
			}
			valVec.addElement(new Byte(tokenValue));
			startIndex=endIndex; // move to new index
			continue outer;      // and continue outer loop
		    }
		}

	        /* didn't find a token, writing plaintext */
		if(!writingText) { // new inline string
		    valVec.addElement(new Byte(GlobalToken.STR_I));
		    writingText=true;
		}
		
		/* add character (using correct encoding) */
		try {
		    valVec.addElement( (new Character(text.charAt(startIndex)).toString()).getBytes(wbxmlCharset) );
		}
		catch (UnsupportedEncodingException uee) {
		    throw new InternalEncodingException("UnsupportedEncodingException occured: "+uee.getMessage());
		}
	    }
	} // end while loop

	if(writingText)
	    valVec.addElement(new Byte(GlobalToken.STRING_END)); // end string before return
	    
	return valVec;
    }
    
    /* encodes the attributes of an element */
    private static ByteVector encodeAttrs(NamedNodeMap attributes) throws NotWMLDocumentException, InternalEncodingException {
	ByteVector attrVec=new ByteVector();
	ByteVector tmpVec;
	int nrAttrs = attributes.getLength();
	for(int i=0; i<nrAttrs; i++) {
	    Node attrNode=attributes.item(i);

	    /* build attribute (concat attr_strart and attr_value) */
	    String attrString=attrNode.getNodeName()+"=\""+attrNode.getNodeValue()+"\"";

	    /* try to find attribute value in the table */
	    int index=attrNode.getNodeName().length()+2;  // start at first character of NodeValue
	    byte attrCode = AttrStart.getValue(attrString,index);
	    index = AttrStart.lengthAttrString(attrCode)+1;

	    if(attrCode!=0) {
		/* we found a match */
		attrVec.addElement(new Byte(attrCode));
		if(index<attrString.length()) { // encode rest of value
		    /* index is of by one; skip " at end of string */
		    tmpVec=encodeAttrValue(attrString.substring(index-1,attrString.length()-1));
		    attrVec.addElement(tmpVec);
		}
	    }
	    else {
		/* we don't have a match; 
		   attr="value" may not have a direct mapping */
		attrCode=AttrStart.getValue(attrNode.getNodeName());

		/*** STILL no match: ERRROR ***/
		if(attrCode==0) { 
		    /* unknown attribute, throw exception */
		    throw new NotWMLDocumentException("Attribute not recognized: "+attrNode.getNodeName());
		}
		
		attrVec.addElement(new Byte(attrCode));
		/* encode value but skip " at beginning and end of string */
		tmpVec=encodeAttrValue(attrString.substring(attrNode.getNodeName().length()+2,attrString.length()-1));
		attrVec.addElement(tmpVec);
	    }
	}

	attrVec.addElement(new Byte(GlobalToken.END)); // add END attributes	    
	return attrVec;
    }
    
    private static boolean isVarnameChar(char ch) {
	/* allowed character for varname as specified in WAP WML 10.3.1 */
	return ( (ch>='A' && ch<='Z') || (ch>='a' && ch<='z') || (ch>='0' && ch<='9') || (ch=='_') );
    }

    /** Encodes a node in the dom-tree and recursivly encodes it's children */
    private static void encodeTree(Node node) throws NotWMLDocumentException, InternalEncodingException {
	ByteVector tmpVec;
	
        // is there anything to do?
        if (node == null) {
            return;
        }
	
        int type = node.getNodeType();

 	switch(type) {
	case Node.ELEMENT_NODE: 
	    byte tagcode=TagToken.getValue(node.getNodeName());
	    if(tagcode == 0)
		/* unknown attribute, throw exception */
		throw new NotWMLDocumentException("Tag not recognized: "+node.getNodeName());
	    
	    /* check if element has attributes and/or children */
	    NamedNodeMap attrTmp=node.getAttributes();
	    if(attrTmp.getLength()!=0)
		tagcode|=ATTR_BIT;  // set ATTR bit
	    if(node.hasChildNodes())
		tagcode|=CHILD_BIT;  // set CHILD bit


	    /* add tag to ByteVector */
	    wmlcVector.addElement(new Byte(tagcode));

	    /* check if element has attributes */
	    NamedNodeMap attrs=node.getAttributes();
	    if(attrs.getLength()>0) { // element has attributes
		tmpVec=encodeAttrs(attrs);
		wmlcVector.addElement(tmpVec);
	    }
 	    break;
	case Node.TEXT_NODE:
	    String text=node.getNodeValue();
	    if(text.trim().length()>0) {  // do not add empty strings	    
		int txtStartIndex=0;   // start of text
		int searchIndex=0;     // start of search for next $
		int varStart=0, varEnd=0;  // variable start and end index
		
		/* look for variables; '$'-sign */
		while((varStart=text.indexOf('$',searchIndex))>=0) {
		    if(text.charAt(varStart+1)=='$') { // another $, not a variable
			text=text.substring(txtStartIndex,varStart)+text.substring(varStart+1,text.length());
			searchIndex=varStart+1;  // begin search after $-sign 
			continue;
		    }

		    /* write text in front of variable */
		    if(varStart != searchIndex)
			wmlcVector.addElement(makeText(text.substring(txtStartIndex,varStart)));
		    
		    /* set varStart and varEnd to correct values */
		    varStart++; // move vatStart to character after dollarsign
		    if(text.charAt(varStart)=='(') {  // if varable is enclosed in parenthesis
			varEnd=text.indexOf(')',varStart);
			if(varEnd==-1) 
			    throw new InternalEncodingException("Not wellformed variable: "+text.substring(varStart));
			wmlcVector.addElement(makeVariable(text.substring(varStart+1,varEnd))); // cut off parenthesis
			txtStartIndex=varEnd+1;  // continue at character after ')'
		    }
		    else {  // look for end of variable
			varEnd=varStart;
			while(varEnd<text.length() && isVarnameChar(text.charAt(varEnd)))
			    varEnd++;
			wmlcVector.addElement(makeVariable(text.substring(varStart,varEnd)));
			txtStartIndex=varEnd;  // continue at character after variable name
		    }
		    searchIndex=txtStartIndex; // search after varable name 
		}

		/* write text behind variable, if any */
		if(!text.substring(txtStartIndex).equals(""))
		    wmlcVector.addElement(makeText(text.substring(txtStartIndex)));
	    }
	    break;
	case Node.DOCUMENT_TYPE_NODE:
 	    if(!node.getNodeName().equals("wml"))
 		throw new NotWMLDocumentException();
	    break;
	case Node.COMMENT_NODE:
	    /* comments are removed */
	case Node.DOCUMENT_NODE:
	    /* This is the root node of the document. Nothing to be done. */
	}

	/* encode all children */
	NodeList children = node.getChildNodes();
	int len = children.getLength();
	for (int i = 0; i < len; i++)
	    encodeTree(children.item(i));
	
	/* document node shall not add END-token */
	if(node.hasChildNodes() && type!=Node.DOCUMENT_NODE) {
	    /* This was an element with content. Add END tag */
	    wmlcVector.addElement(new Byte(GlobalToken.END));
	}

    } // end encodeTree()

    /* --------------- public methods --------------- */
    /** Encodes a wmldocument into its binary form.
	@throws NotWMLDocumentException Thrown if the wml document is not included
	inside the <code>&lt;wml&gt;</code>-tag.
	@throws WMLCParserException Thrown if the parser encounters an error.
	@return An array of bytes containing the binary encoding.
    */
    synchronized static public byte[] encode(InputStream wmldocument, String wmlChset, String wbxmlChset) throws
	NotWMLDocumentException, WMLCParserException, CodeNotInTableException {
	
	init(wmlChset, wbxmlChset);
	InputSource xmlStream=new InputSource(wmldocument);
	
	Document document=null;
       	/* parse the document */
	DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();

	/* change encoding of stream */
	    xmlStream.setEncoding(wmlCharset);

	try {
	    DocumentBuilder builder = factory.newDocumentBuilder();
	    LocalDTDResolver localResolver = new LocalDTDResolver();
	    builder.setEntityResolver(localResolver);
	    document = builder.parse(xmlStream);
	}
	catch (SAXParseException spe) {
	    throw new WMLCParserException("SAXParseException: "+spe.getMessage());
	}
	catch (SAXException sxe) {
	    throw new WMLCParserException("SAXException: "+sxe.getMessage());
	}
	catch (ParserConfigurationException pce) {
	    throw new WMLCParserException("ParserConfigurationException: "+pce.getMessage());
	}
	catch (IOException ioe) {
	    throw new WMLCParserException("IOException: "+ioe.getMessage());
	}
	
 	/* encode the tree and return a byte[] */
	try {
	    encodeTree(document);
	}
	catch (InternalEncodingException iee) {
	    throw new WMLCParserException("InternalWMLEncodingException: "+iee.getMessage());
	}

	return wmlcVector.toByteArray();
    }
}










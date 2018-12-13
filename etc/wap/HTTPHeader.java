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



/** The class describes a HTTP header with fieldname and an array of
 *  fieldvalues. */
public class HTTPHeader {

    /** An exception class used if a code is not present in the table */
    private class StrangeHTTPException extends Exception {
	
	/** Use this if a code is not present in the table. */
	StrangeHTTPException() {
	    super();
	}
	
	/** Use this if a code is not present in the table.
	 * @param str A short textstring to be written. */
	StrangeHTTPException(String s) {
	    super(s);
	}
    }

    /* --- Help class to HTTPHeader --- */

    /* The HTTP header class uses this class to store field values and parameters. */
    private class FieldValue {

	private String value;
	private Vector param;
	private int nrParams;

	/** Constructs a HTTP field value with parameters from a string. The string
	 *  may contain parameters separated by ';'.
	 * @param str HTTP field value string. */
	FieldValue(String str) {
	    int left=0, right=0; // index in str

	    str=str.trim();

	    param = new Vector();
	    while (left<str.length()) {
	    
		/* look for the ';' to find any parameters 
		   or look for end of string */
		while (right<str.length() && str.charAt(right)!=';') // don't change order
		    right++;
	    
		if (left==0)  // field value starts at index left
		    value = new String(str.substring(left,right));
		else  { // parameter starts at index left
		    param.addElement(new String(str.substring(left,right)));
		    nrParams++;
		}

		/* increase left and right, set index to char after ';' */
		left=++right;
	    }
	}

	/** Returns a string containing the Fieldvalue */
	String value() {
	    return new String(value);
	}

	/** Returns a string with parameter nr index */
	String parameter(int index) {
	    return new String((String)param.elementAt(index));
	}

	/** Returns the number of parameters */
	int nrParameters() {
	    return nrParams;
	}
    }

    /* --- end help class --- */
    
    private String fName;
    private String fValue;

    /** Constructs and fills in the name and values from a HTTP header.
     * @param str The HTTP Header to be processed. */
    HTTPHeader(String str) throws MalformedHeaderException {
	int index;   // index in str

	str=str.trim();

	/* Find the field name. Look for ':' */
	index=str.indexOf(':');
	if(index<0)
	    throw new MalformedHeaderException("Can not create header: "+str);
	// The field name starts at index left
	fName = new String(str.substring(0,index).trim());
	fValue = new String(str.substring(index+1).trim());
    }

    /** Constructs a HTTP header.
     * @param name HTTP field name
     * @param value HTTP field value */
    HTTPHeader(String name, String value) {
	fName=name.substring(0);
	fValue=value.substring(0);
    }

    /** Returns the HTTP Field Name. */
    String fieldName() {
	return new String(fName);
    }

    /** Returns the fieldvalue at specified index. */
    String fieldValue() {
	return new String(fValue.trim());
    }

    /** Returns a string from a HTTPHeader.
     * @param header HTTP header.
     * @ return a string */
    public String toString() {
	return new String(fName+": "+fValue);
    }

    /** Splits a HTTP field value into multiple strings. If there are no characters
     * to separate the string, <PRE>splitValues()</PRE> will return an array containing
     * one element; the field value.
     * @param separator character to use to separate different values
     * @return array of the substrings */
    private String[] splitValues(char separator) {
	int left=0, right=0;   // index in the string
	Vector indexVector=new Vector();
	boolean insideQuote=false;
	String[] strs;

	/* count number of separators */
	for(int i=0;i<fValue.length();i++) {
	    if(fValue.charAt(i)=='"')
		insideQuote=!insideQuote;
	    if((fValue.charAt(i)==separator) && (!insideQuote)) {
		indexVector.addElement(new Integer(i));
	    }
	}

	strs=new String[indexVector.size()+1];
	for(int j=0;j<indexVector.size();j++) {
	    right=((Integer)(indexVector.elementAt(j))).intValue();
	    strs[j]=new String(fValue.substring(left,right));
	    left=right+1;    // left points to character after the separator
	}
	strs[indexVector.size()]=new String(fValue.substring(left).trim());

	return strs;
    }

    /** Appends the extra field value str to the field values*/
    void appendToFieldValue(String str)
    {
	fValue+=","+str;
    }

    /** Sets the field value to str*/
    void setValue(String str)
    {
	fValue=str;
    }

    /*************************************/
    /* --- Methods for encoding HTTP --- */
    /*************************************/

    /* Formats str as ASCII-text and ends with a NUL-character. If
       first character is >127 a quote is inserted.
       * BNF: [Quote] *TEXT End-of-string   */
    private byte[] toTextString(String str) {
	byte[] tmp,tmp2;

	tmp=toExtensionMedia(str);
	if (str.charAt(0)>'\u00FF') {
	    /* we need a quote character first */
	    tmp2=new byte[tmp.length+1];
	    for(int i=0;i<tmp.length;i++) 
		tmp2[i+1]=tmp[i];
	    tmp2[0]=(byte)127; // Quote character (WAP WSP 8.4.2.1)
	    return tmp2;
	}
	else {
	    return tmp;
	}
    }

    /* Formats str as ASCII-text and ends with a NUL-character
     * BNF: Token End-of-string  */
    private byte[] toTokenText(String str) {
	int l=str.length();
	byte[] tmp= new byte[l+1];

	/* copy str to tmp */
	for(int i=0;i<l;i++) {
	    tmp[i]=(byte)str.charAt(i);
	}
	tmp[l]=(byte)0x00; // end-of-string
	
	return tmp;
    }

    /* Formats str as ASCII-text and ends with a NUL-character. Parameter str should include the '"'-characters,
       they will be removed.
       * BNF: <Quote> *TEXT End-of-string  */
    private byte[] toQuotedString(String str) {
	byte[] tmp=str.getBytes();

	tmp[0]=(byte)34;           // insert quote character at first "
	tmp[tmp.length-1]=(byte)0; // insert end-of-string at last "
	
	return tmp;
    }

    /* Formats str as ASCII-text and ends with a NUL-character
     * BNF: Token End-of-string  */
    private byte[] toExtensionMedia(String str) {
	int l=str.length();
	byte[] tmp= new byte[l+1];

	/* copy str to tmp */
	for(int i=0;i<l;i++) {
	    tmp[i]=(byte)str.charAt(i);
	}
	tmp[l]=(byte)0x00; // end-of-string
	
	return tmp;
    }


    /* SHALL be used when encoding q-values with 0, 1 or 2 decimal digits.
       returns an array of bytes containing the codes */
    private byte[] qValue12(double qVal) {
	return WSPInteger.makeUintvar((int) (qVal*100+1));
    }

    /* SHALL be used when encoding q-values with 3 decimal digits.
       returns an array of bytes containing the codes */
    /* OK */
    private byte[] qValue3(double qVal) {
	return WSPInteger.makeUintvar((int) (qVal*1000+100));
    }

    /* Returns byte array ready to be sent.
       Returns null if qValue is 1.0 (MUST NOT be sent) */
    private byte[] makeqValueBytes(double qVal) {
	byte[] ret;

	if(qVal==1.0) {
	    return null;
	}
	
	/* find out how many decimals in q-value */
	if ( (int)(qVal*1000)%10!=0 ) {
	    /* 3 decimals */
	    ret=qValue3(qVal);
	}
	else {
	    /* 0,1 or 2 decimals */
	    ret=qValue12(qVal);
	}
	return ret;
    }

    /* Build a ByteVector containing all partameters. 
     * First parameter should be the fieldvalue (not a parameter) and is ignored by this function.
     */
    private ByteVector toParameterSequenceVector(String[] param) {
	byte code;          // byte to be written 
	byte[] tmpseq;      // byte array to br written	
	double qValue;      // the q-value
	String[] par;       // array of parameter names
	String[] val;       // array of parameter values
	int equalI;         // index of '=' character
	ByteVector returnVector = new ByteVector(); // used to store bytes to be returned
	// contains Byte, byte[] or ByteVector
	
	/* Divide into parameter and values; par=val */
	par = new String[param.length-1];
	val = new String[param.length-1];

	/* param[0] is the field value */
	for(int i=1;i<param.length;i++) {
	    if((equalI=param[i].indexOf('='))!=-1) {
		/* of the form par=val */
		par[i-1]= new String(param[i].substring(0,equalI).trim());
		val[i-1]= new String(param[i].substring(equalI+1,param[i].length()).trim());
	    }
	    else {
		/* no '=' */
		par[i-1]= new String(param[i].trim());
		val[i-1]=null;
	    }
	}
	
	/* loop through all parameters and encode them */
	for(int i=0;i<param.length-1;i++) {
	    if((code=ParameterCodeTable.getCode(par[i]))!=WapTable.ERROR_CODE) {
		/* well-known, send well-known parameter */

		returnVector.addElement(WSPInteger.makeInteger(code));
		
		if(val[i]==null) {
		    /* there is no value, send 'no-value' (WAP WSP 8.4.2.3) */
		    returnVector.addElement(new Byte((byte)0x00));
		}
		else { /* send value */
		    switch (code) {
		    case 0x00: /* Q */
			Double qDouble=Double.valueOf(val[i]);
			qValue=qDouble.doubleValue() ;
			tmpseq=makeqValueBytes(qValue);
			if(tmpseq==null) {  /* qValue is 1.0, do not send */
			    /* remove last byte (q-value-parameter) */
			    returnVector.removeElementAt(returnVector.size()-1);
			}
			else {
			    returnVector.addElement(tmpseq);
			}
			break;
		    case 0x01: /* Charset */
			int chSet;

			chSet=CharacterSetTable.getMIB(val[i]);
			if(chSet<0x80) {
			    /* encode it as short int */
			    returnVector.addElement(new Byte(WSPInteger.makeShortInt((byte) chSet)));
			}
			else {
			    /* encode it as long int */
			    tmpseq=WSPInteger.makeLongInt(chSet);
			    returnVector.addElement(tmpseq);
			}
			break;
		    case 0x02: /* Level */
			int major=0, minor=0;
			int index=val[i].indexOf('.');
			boolean fit=false;
			try {
			    if(index==-1) { /* only major version number */
				major=Integer.parseInt(val[i]);
				minor=0x0f;
				if(major<8)  /* fit in one byte */
				    fit=true;			    
			    }
			    else { /* both major and minor version number */
				major=Integer.parseInt(val[i].substring(0,index));
				minor=Integer.parseInt(val[i].substring(index+1,val[i].length()));
				if(major<8 && minor<15)
				    fit=true;
			    }
			}
			catch (NumberFormatException nfe) {
			    /* val[i] is not in the form xx.yy */
			    fit=false;
			}

			if (fit) {
			    code=(byte)(major<<4);
			    code|=(byte) minor;
			    returnVector.addElement(new Byte(WSPInteger.makeShortInt(code)));
			}
			else {
			    tmpseq=toTextString(val[i]);
			    returnVector.addElement(tmpseq);
			}
			break;
		    case 0x03: /* Type */
		    case 0x09:
			/* try if value is an integer */
			try {
			    /* encode as Short integer | Long integer */
			    if (Integer.parseInt(val[i])<0x80)
				returnVector.addElement(new Byte(WSPInteger.makeShortInt((byte)Integer.parseInt(val[i]))));
			    else {
				tmpseq=WSPInteger.makeLongInt(Integer.parseInt(val[i]));
				returnVector.addElement(tmpseq);
			    }
			}
			catch (NumberFormatException nfe) {
			    /* it's a content-type */
			    returnVector.setElementAt(WSPInteger.makeInteger(0x09),0); // change type
			    if((code=ContentTypeTable.getCode(val[i]))!=WapTable.ERROR_CODE)
				returnVector.addElement(new Byte(WSPInteger.makeShortInt(code))); // constraint-encoding
			    else
				returnVector.addElement(toExtensionMedia(val[i]));
			}
			break;
		    case 0x07: /* Differences */
			if ((code=HeaderFieldNameTable.getCode(val[i]))!=WapTable.ERROR_CODE)
			    returnVector.addElement(new Byte(WSPInteger.makeShortInt(code)));
			else {
			    tmpseq=toTokenText(val[i]);
			    returnVector.addElement(tmpseq);
			}
			break;
		    case 0x08: /* Padding */
			returnVector.addElement(new Byte(WSPInteger.makeShortInt(Byte.parseByte(val[i]))));
			break;
			/* case 0x09 (Type): see 0x03 (Type) */
		    case 0x05: /* Name */
		    case 0x06: /* Filename */
		    case 0x0A: /* Start */
		    case 0x0B: /* Start-info */
		    default:
			tmpseq=toTokenText(val[i]);
			returnVector.addElement(tmpseq);
		    }
		}
	    }
	    else {
		/* parameter name not recognized */
		tmpseq=toTokenText(par[i]);
		returnVector.addElement(tmpseq);

		/* write untyped-value */
		if(val[i]==null) {
		    /* there is no value, send 'no-value' (WAP WSP 8.4.2.3) */
		    returnVector.addElement(new Byte((byte)0x00));
		}
		else {
		    try {
			int iValue=Integer.parseInt(val[i]);
			/* value is an integer */
			tmpseq=WSPInteger.makeInteger(iValue);
			returnVector.addElement(tmpseq);
		    }
		    catch (NumberFormatException nfe) {
			/* value is not an interger */
			int first=val[i].indexOf('"');
			int last=val[i].lastIndexOf('"');

			if(first==0 && last==(val[i].length()-1))
			    /* parameter is quoted */
			    tmpseq=toQuotedString(val[i]);
			else
			    tmpseq=toTokenText(val[i]);
			returnVector.addElement(tmpseq);
		    }
		}
	    } 
	    
	}

	return returnVector;
    }


    private ByteVector makeCacheControlValue(String cacheVal) {
	ByteVector ccv=new ByteVector();
	byte codetmp;
	byte[] btmp;

	/* byte codes may be found in WAP WSP 8.4.2.15 */
	if(cacheVal.indexOf("=")==-1) {
	    /* Cachevalue has no parameters */
	    if (cacheVal.equalsIgnoreCase("no-cache"))
		ccv.addElement(new Byte((byte)0x80));
	    else if (cacheVal.equalsIgnoreCase("no-store"))
		ccv.addElement(new Byte((byte)0x81));
	    else if (cacheVal.equalsIgnoreCase("max-stale"))
		ccv.addElement(new Byte((byte)0x83));
	    else if (cacheVal.equalsIgnoreCase("only-if-cached"))
		ccv.addElement(new Byte((byte)0x85));
	    else if (cacheVal.equalsIgnoreCase("private"))
		ccv.addElement(new Byte((byte)0x87));
	    else if (cacheVal.equalsIgnoreCase("public"))
		ccv.addElement(new Byte((byte)0x86));
	    else if (cacheVal.equalsIgnoreCase("no-transform"))
		ccv.addElement(new Byte((byte)0x88));
	    else if (cacheVal.equalsIgnoreCase("must-revalidate"))
		ccv.addElement(new Byte((byte)0x89));
	    else if (cacheVal.equalsIgnoreCase("proxy-revalidate"))
		ccv.addElement(new Byte((byte)0x8a));
	    else /* Cache-extension */
		ccv.addElement(toTokenText(cacheVal));
	}
	else {
	    /* Cachevalue has parameters (is a Cache-directive) */
	    String directive=cacheVal.substring(cacheVal.indexOf('=')+1,cacheVal.length());
	    cacheVal=cacheVal.substring(0,cacheVal.indexOf('='));  // value in front of '='

	    if (cacheVal.equalsIgnoreCase("max-age") || cacheVal.equalsIgnoreCase("max-stale") ||
		cacheVal.equalsIgnoreCase("min-fresh")) {
		try {
		    btmp=WSPInteger.makeInteger(Integer.parseInt(directive));
		    if(cacheVal.equalsIgnoreCase("max-age"))
			ccv.addElement(new Byte((byte)0x82));
		    else if(cacheVal.equalsIgnoreCase("max-stale"))
			ccv.addElement(new Byte((byte)0x83));
		    else /* min-fresh */
			ccv.addElement(new Byte((byte)0x84));			
		    ccv.addElement(btmp);
		}
		catch (NumberFormatException nfe) { /* don't send header */}		
	    }
	    else if (cacheVal.equalsIgnoreCase("no-cache") || cacheVal.equalsIgnoreCase("private")) {
		if (cacheVal.equalsIgnoreCase("no-cache"))
		    ccv.addElement(new Byte((byte)0x80));
		else /* private */
		    ccv.addElement(new Byte((byte)0x87));

		/* cut off " and split parameterstring */
		String[] param=splitString(directive.substring(1,directive.length()-1),',');

		for (int i=0;i<param.length;i++) {
 		    if((codetmp=HeaderFieldNameTable.getCode(param[i]))!=WapTable.ERROR_CODE) {
			/* add well-known fieldname */
			ccv.addElement(new Byte(WSPInteger.makeShortInt(codetmp)));
		    }
		    else {
			/* add exttension field-name */
			ccv.addElement(toTokenText(param[i]));
		    }
		}
	    }
	    else { /* Cache-extension */
		ccv.addElement(toTokenText(cacheVal.substring(0,cacheVal.indexOf('='))));

		/* First value of array to toParameterSequenceVector() will not be sent.
		   Inserting a ',' after auth-scheme will split parameters correctly. */
		String tmpStr=cacheVal+","+directive;
		ccv.addElement(toParameterSequenceVector(splitString(tmpStr.trim(),',')));
	    }
	}		
	    
	return ccv;
    }

    private ByteVector makeCredentials(String cred) throws StrangeHTTPException {
	ByteVector retVec=new ByteVector();
	
	int delindex;
	if(cred.substring(0,5).equalsIgnoreCase("basic")) {
	    /* Basic Authentication Scheme */
	    String plaintext = Base64Coder.decode(cred.substring(5).trim()); // decode basic credentials
	    delindex=plaintext.indexOf(':');
	    if(delindex==-1) // ':' not in string
		throw new StrangeHTTPException();
	    
	    /* add basic-cookie to temporary vector and insert length in front */
	    retVec.addElement(new Byte((byte)0x80));  // WAP WSP 8.4.2.5
	    retVec.addElement(toTextString(plaintext.substring(0,delindex)));
	    retVec.addElement(toTextString(plaintext.substring(delindex+1).trim()));
	}
	else {
	    delindex=cred.indexOf(' ');
	    if(delindex==-1) // no auth-scheme
		throw new StrangeHTTPException();

	    /* First value of array to toParameterSequenceVector() will not be sent.
	       Inserting a ',' after auth-scheme will split parameters correctly. */
	    String tmpStr=cred.substring(0,delindex)+","+cred.substring(delindex+1);
	    String[] authparams=splitString(tmpStr.trim(),',');

	    /* add (Authentication-scheme *Auth-param) and insert length in front */
	    retVec.addElement(toTokenText(cred.substring(0,delindex)));
	    retVec.addElement(toParameterSequenceVector(authparams));
	}

	return retVec;
    }

    /** Makes a challenge from a header field value. */
    private ByteVector makeChallenge(String chall) throws StrangeHTTPException {
	ByteVector retVec=new ByteVector();

	int delindex;
	String realmValue=null;
	if(chall.length()>=5 && chall.substring(0,5).equalsIgnoreCase("basic")) {
	    /* Basic Authentication Scheme */
	    realmValue=chall.substring(5).trim();
	    delindex=realmValue.indexOf('=');
	    if(delindex==-1) // no realm=XXX
		throw new StrangeHTTPException();
	    realmValue=realmValue.substring(delindex+1);
			
	    /* add basic-cookie to temporary vector */
	    retVec.addElement(new Byte((byte)0x80));  // WAP WSP 8.4.2.5
	    /* encode realm-value without '"'-characters */
	    retVec.addElement(toTextString(realmValue.substring(1,realmValue.length()-1)));
	}
	else {
	    delindex=chall.indexOf(' ');
	    if(delindex==-1) // no auth-scheme
		throw new StrangeHTTPException();
	    String authScheme=chall.substring(0,delindex);
			
	    /* find out realm-value and delete it from parameterstring */
	    HTTPHeader dummy=new HTTPHeader("dummy",chall.substring(delindex));
	    String[] param=dummy.splitValues(',');
	    String newParStr="";
	   
	    for(int cursor=0; cursor<param.length; cursor++) {
		delindex=param[cursor].indexOf('=');
		if(delindex==-1) // not of the form param=val
		    throw new StrangeHTTPException();
		if(param[cursor].substring(0,delindex).equals("realm"))
		    realmValue=param[cursor].substring(delindex+1);
		else
		    newParStr+=param[cursor]+"; ";  // use ';' to sepatate parameters
	    }

	    if(realmValue==null) // challenge has no realm
		throw new StrangeHTTPException();

	    newParStr=newParStr.substring(0,newParStr.length()-2); // remove ", " at end of string
	    /* add (Auth-Scheme Realm-value *Auth-param) */
	    retVec.addElement(toTokenText(authScheme));
	    /* encode realm-value without '"'-characters */
	    retVec.addElement(toTextString(realmValue.substring(1,realmValue.length()-1)));

	    /* First element in array is ignored by toParameterSequence() */
	    String tmpString=new String("dummy;"+newParStr);
 	    retVec.addElement(toParameterSequenceVector(splitString(tmpString,';')));
	}
    
	return retVec;
    }


    /** Splits a comma separated list of header fieldvalues into mutiple headers */
    private HTTPHeader[] splitListHeader() {
	HTTPHeader[] hhs;
	String[] fvals;
	
	fvals=this.splitValues(',');
	/* make as many headers as we need (one per value) */
	hhs=new HTTPHeader[fvals.length];
	for(int i=0;i<fvals.length;i++) {
	    hhs[i]=new HTTPHeader(this.fieldName(),fvals[i]);
	}
	return hhs;
    }

    /** Splits a string into substrings using separator to separate them */
    private String[] splitString(String str,char separator) {
	int left=0,right=0; // index in the string
	int nrSeps=0;
	String[] strs;

	/* count number of separators */
	for(int i=0;i<str.length();i++) {
	    if(str.charAt(i)==separator)
		nrSeps++;
	}

	strs=new String[nrSeps+1];
	for(int i=0;i<nrSeps;i++) {
	    right=str.indexOf(separator,left);
	    strs[i]=new String(str.substring(left,right).trim());
	    left=right+1;    // left points to character after the separator
	}
	strs[nrSeps]=new String(str.substring(left).trim());

	return strs;
    }


    /** Encodes a HTTP Header into Wap encoded header and returns a <code>ByteVector</code>
     * containing the bytes making up the header.
     * @param header The HTTP Header to be sent.
     * @return <code>ByteVector</code> containing header bytes. An empty <code>ByteVector</code>
     * HTTP header is malformed */
    ByteVector toWSP() {
	/* An array of headers may be needed, becase we are only allowed
	   to encode headers with one name and value pair */
	HTTPHeader[] hs; // array of headers
	byte ncode;      // used to store field name code
	byte vcode;      // used to store field value code
	byte[] btmp;     // used to store byte-arrays from helpfunctions
	ByteVector vtmp; // used to store complicated arrays from help functions
	String[] part;   // split strings to tokens
	ByteVector writeVec=new ByteVector(); // ByteVector to be returned
	boolean headerOK=true;  // if malformed header this changes to false

	try {
	    /* encode field name */
	    ncode=HeaderFieldNameTable.getCode(this.fieldName());

	    switch (ncode) {
	    case 0x00: /* Accept */
		String[] param;

		hs=this.splitListHeader();
		/* loop through all headers and encode them */
		for(int i=0;i<hs.length;i++) {
		    
		    /* code name as short int and send it */
		    writeVec.addElement(new Byte(WSPInteger.makeShortInt(ncode)));
		    
		    param=splitString(hs[i].fieldValue(),';');

		    /* param[0] is media type name,
		       the others are parameters */
		    
		    if ((vcode=ContentTypeTable.getCode(param[0]))!=WapTable.ERROR_CODE) {
			/* well-known media */
			if (param.length==1) {
				/* value has no parameters.
				   code it as short int and send it */
			    writeVec.addElement(new Byte(WSPInteger.makeShortInt(vcode))); 
			}
			else {
				/* encode parameters and send them */
			    vtmp=toParameterSequenceVector(param);
			    vtmp.insertElementAt(new Byte(WSPInteger.makeShortInt(vcode)),0);  // add content type at front of bytestream
			    
				/* if this test fails there were no parameters to send.
				   eg: the test fails if there was a q-value=1.0 */
			    if (vtmp.size()>1) 
				vtmp.insertElementAt(WSPInteger.makeValueLength(vtmp.countBytes()),0);  // add length in front
			    

			    writeVec.addElement(vtmp);
			}
		    }
		    else {	 /* content type not recognized */
			/* encode it as text */

			btmp=toExtensionMedia(param[0]); // fieldvalue without parameters
			if (param.length==1) {
				/* field value has no parameters, send it as text */
			    writeVec.addElement(btmp);
			}
			else {
				/* encode parameters and send them */
			    vtmp=toParameterSequenceVector(param);
			    vtmp.insertElementAt(btmp,0); // add content type at front of bytestream
			    vtmp.insertElementAt(WSPInteger.makeValueLength(vtmp.countBytes()),0);  // add length in front
			    writeVec.addElement(vtmp);
			}
		    }
		}
		break;
	    case 0x01: /* Accept-Charset */
		int mibcode;
		
		hs=this.splitListHeader();
		/* loop through all headers and encode them */
		for(int i=0;i<hs.length;i++) {
		    
		    /* code name as short int and send it */
		    writeVec.addElement(new Byte(WSPInteger.makeShortInt(ncode)));
		    /* split string into char-set and q-value */
		    part=splitString(hs[i].fieldValue(),';');

		    mibcode=CharacterSetTable.getMIB(part[0]);

		    if(part.length==1 && mibcode<0x80) { 
			/* no q-value, it will fit in one byte */
			if(mibcode!=0)
				/* well-known character set */
			    writeVec.addElement(new Byte(WSPInteger.makeShortInt((byte)mibcode)));  
			else {
			    btmp=toExtensionMedia(part[0]);
			    writeVec.addElement(btmp);   			    
			}
		    }
		    else {  /* accept-charset-general-form */
			vtmp=new ByteVector();
			if(mibcode!=0)
				/* well-known character set */
			    vtmp.addElement(WSPInteger.makeInteger(mibcode));
			else {
			    btmp=toTokenText(part[0]);
			    vtmp.addElement(btmp);
			}
			if(part.length==2) { /* there is a q-value */
			    Double tmpDouble=Double.valueOf(part[1].substring(2));
			    btmp=makeqValueBytes(tmpDouble.doubleValue());
			    if(btmp!=null) {  /* qValue is not 1.0, send */
				vtmp.addElement(btmp);
			    }
			}
			/* if this test fails there were no parameters to send.
			   eg: the test fails if there was a q-value=1.0 */
			if (vtmp.size()>1) {
			    vtmp.insertElementAt(WSPInteger.makeValueLength(vtmp.countBytes()),0);  // add length in front
			}
			writeVec.addElement(vtmp);
		    }
		}
		break;
	    case 0x02: /* Accept-Encoding */

		hs=this.splitListHeader();
		/* loop through all headers and encode them */
		for(int i=0;i<hs.length;i++) {
		    
		    /* code name as short int and send it */
		    writeVec.addElement(new Byte(WSPInteger.makeShortInt(ncode)));
		    /* split string into char-set and q-value */
		    part=splitString(hs[i].fieldValue(),';');
		    if(part[0].equalsIgnoreCase("gzip"))  
			writeVec.addElement(new Byte((byte)128));
		    else if(part[0].equalsIgnoreCase("compress"))
			writeVec.addElement(new Byte((byte)129));
		    else if(part[0].equalsIgnoreCase("deflate"))
			writeVec.addElement(new Byte((byte)130));
		    else
			/* send token text */
			writeVec.addElement(toTokenText(part[0]));
		}	    
		break;
	    case 0x03: /* Accept-Language */
		byte lcode;
		
		hs=this.splitListHeader();
		/* loop through all headers and encode them */
		for(int i=0;i<hs.length;i++) {
		    
		    /* code name as short int and send it */
		    writeVec.addElement(new Byte(WSPInteger.makeShortInt(ncode)));
		    /* split string into Language and q-value */
		    part=splitString(hs[i].fieldValue(),';');
		    lcode=LanguageTable.getCode(part[0]);

		    if(part.length==1 && ((lcode&0x80)==0 || lcode==WapTable.ERROR_CODE)) { 
			/* no q-value, it might fit in one byte */ 
			if(lcode!=WapTable.ERROR_CODE)
				/* well-known Language */
			    writeVec.addElement(new Byte(WSPInteger.makeShortInt((byte)lcode)));
			else {
			    btmp=toExtensionMedia(part[0]);
			    writeVec.addElement(btmp);   			    
			}
			
		    }
		    else {  /* accept-language-general-form */
			vtmp=new ByteVector();
			if(lcode!=WapTable.ERROR_CODE)
				/* well-known language set */
			    if((lcode&0x80)==0) 
				/* number is small enough to fit i short int (7 bits) */
				vtmp.addElement(new Byte(WSPInteger.makeShortInt((byte)lcode)));
			    else {
				/* MSB is set; lcode is negative */
				int newcode=0;
				newcode|=lcode;
				newcode&=0xff;
				vtmp.addElement(WSPInteger.makeInteger(newcode));
			    }
			else {
			    btmp=toTextString(part[0]);
			    vtmp.addElement(btmp);
			}
			if(part.length==2) { /* there is a q-value */
			    Double tmpDouble=Double.valueOf(part[1].substring(2));
			    btmp=makeqValueBytes(tmpDouble.doubleValue());
			    if(btmp!=null) {  /* qValue is not 1.0, send */
				vtmp.addElement(btmp);
			    }
			}
			/* if this test fails there were no parameters to send.
			   eg: the test fails if there was a q-value=1.0 */
			if (vtmp.size()>1) {
			    vtmp.insertElementAt(WSPInteger.makeValueLength(vtmp.countBytes()),0);  // add length in front
			}
			writeVec.addElement(vtmp);
		    }
		}
		break;
	    case 0x04: /* Accept-Ranges */
		/* code name as short int and send it */
		writeVec.addElement(new Byte(WSPInteger.makeShortInt(ncode)));
		
		if(this.fieldValue().equalsIgnoreCase("none"))
		    writeVec.addElement(new Byte((byte)0x80)); /* WAP WSP 8.4.2.11 */
		else if (this.fieldValue().equalsIgnoreCase("bytes"))
		    writeVec.addElement(new Byte((byte)0x81)); /* WAP WSP 8.4.2.11 */
		else {
		    btmp=toTokenText(this.fieldValue());
		    writeVec.addElement(btmp);
		}
		break;
	    case 0x05: /* Age */
		try {
		    /* code delta seconds value */
		    btmp=WSPInteger.makeInteger(Integer.parseInt(this.fieldValue()));
		    
		    /* code name as short int and send it */
		    writeVec.addElement(new Byte(WSPInteger.makeShortInt(ncode)));
		    writeVec.addElement(btmp);
		}
		catch (NumberFormatException nfe) { /* do not send contnet-length */ }
		break;
	    case 0x06: /* Allow */
		hs=this.splitListHeader();
		/* loop through all headers and encode them */
		for(int i=0;i<hs.length;i++) {
		    /* code name as short int and send it */
		    writeVec.addElement(new Byte(WSPInteger.makeShortInt(ncode)));

		    if ((vcode=PDUTypeTable.getCode(hs[i].fieldValue()))!=WapTable.ERROR_CODE) {
			writeVec.addElement(new Byte(WSPInteger.makeShortInt(PDUTypeTable.getCode(hs[i].fieldValue()))));
		    }
		    else {
			/* do not send header, remove last addition */
			writeVec.removeElementAt(writeVec.size());
		    }
		}
		break;
	    case 0x07: /* Authorization */
		vtmp=makeCredentials(this.fieldValue());
		vtmp.insertElementAt(WSPInteger.makeValueLength(vtmp.countBytes()),0); // insert value-length
		
		/* code name as short int and send it */
		writeVec.addElement(new Byte(WSPInteger.makeShortInt(ncode)));
		/* add credentials */
		writeVec.addElement(vtmp);
		break;
	    case 0x08: /* Cache-Control */
		hs=this.splitListHeader();
		/* loop through all headers and encode them */
		for(int i=0;i<hs.length;i++) {
		    vtmp=makeCacheControlValue(hs[i].fieldValue());
		    if(vtmp.countBytes()>1)
			/* complicated cache-directive, add value-length */
			vtmp.insertElementAt(WSPInteger.makeValueLength(vtmp.countBytes()),0);
		    
		    /* code name as short int and send it */
		    writeVec.addElement(new Byte(WSPInteger.makeShortInt(ncode)));
		    writeVec.addElement(vtmp);
		}
		break;
	    case 0x09: /* Connection */
		/* code name as short int and send it */
		writeVec.addElement(new Byte(WSPInteger.makeShortInt(ncode)));
		if(this.fieldValue().equalsIgnoreCase("close"))
		    writeVec.addElement(new Byte((byte)0x80)); /* WAP WSP 8.4.16 */
		else {
		    btmp=toTokenText(this.fieldValue());
		    writeVec.addElement(btmp);
		}
		break;
	    case 0x0a: /* Content-Base */
		/* code name as short int and send it */
		writeVec.addElement(new Byte(WSPInteger.makeShortInt(ncode)));
		writeVec.addElement(toTextString(this.fieldValue()));
		break;
	    case 0x0b: /* Content-Encoding */
		hs=this.splitListHeader();
		/* loop through all headers and encode them */
		for(int i=0;i<hs.length;i++) {
		    
		    /* code name as short int and send it */
		    writeVec.addElement(new Byte(WSPInteger.makeShortInt(ncode)));
		    if(hs[i].fieldValue().equalsIgnoreCase("gzip"))  
			writeVec.addElement(new Byte((byte)128));
		    else if(hs[i].fieldValue().equalsIgnoreCase("compress"))
			writeVec.addElement(new Byte((byte)129));
		    else if(hs[i].fieldValue().equalsIgnoreCase("deflate"))
			writeVec.addElement(new Byte((byte)130));
		    else
			/* send token text */
			writeVec.addElement(toTokenText(hs[i].fieldValue()));
		}	    
		break;
	    case 0x0c: /* Content-Language */
		hs=this.splitListHeader();
		/* loop through all headers and encode them */
		for(int i=0;i<hs.length;i++) {
		    
		    /* code name as short int and send it */
		    writeVec.addElement(new Byte(WSPInteger.makeShortInt(ncode)));
		    lcode=LanguageTable.getCode(hs[i].fieldValue());

		    if(lcode!=WapTable.ERROR_CODE) { 
			/* well-known Language */
			btmp=WSPInteger.makeInteger((int)lcode);
			writeVec.addElement(btmp);
		    }
		    else {
			btmp=toTokenText(hs[i].fieldValue());
			writeVec.addElement(btmp);
		    }
		}
		break;
	    case 0x0d: /* Content-Length */
		try {
		    /* code length-value */
		    btmp=WSPInteger.makeInteger(Integer.parseInt(this.fieldValue()));

		    /* code name as short int and send it */
		    writeVec.addElement(new Byte(WSPInteger.makeShortInt(ncode)));
		    writeVec.addElement(btmp);
		}
		catch (NumberFormatException nfe) { /* do not send contnet-length */ }
		break;
	    case 0x0e: /* Content-Location */
		/* code name as short int and send it */
		writeVec.addElement(new Byte(WSPInteger.makeShortInt(ncode)));
		writeVec.addElement(toTextString(this.fieldValue()));		
		break;
	    case 0x0f: /* Content-MD5 */
		String digest=Base64Coder.decode(this.fieldValue());
		if (digest.length()!=16)
		    throw new StrangeHTTPException();
		    
		vtmp=new ByteVector();
		/* code name as short int and send it */
		writeVec.addElement(new Byte(WSPInteger.makeShortInt(ncode)));
		vtmp.addElement(digest.getBytes());
		vtmp.insertElementAt(WSPInteger.makeValueLength(vtmp.countBytes()),0);  // add length in front
		writeVec.addElement(vtmp);
		break;
	    case 0x10: /* Content-Range */
		int fbp; // first-byte-pos
		int el;  // entity-length
		int sp, minus, slash; // token delimeters
		String rspace=this.fieldValue();

		try {
		    sp=rspace.indexOf(' ');
		    minus=rspace.indexOf('-');
		    slash=rspace.indexOf('/');
		    if(sp<0 || minus<0 || slash<0 || !(rspace.substring(0,sp).equals("bytes")) )
			/* HTTP must contain these delimiters and WAP only understand bytes */
			throw new StrangeHTTPException();
		
		    /* read first-byte-pos and entity-length */
		    fbp=Integer.parseInt(rspace.substring(sp+1,minus));
		    el=Integer.parseInt(rspace.substring(slash+1,rspace.length()));

		    vtmp=new ByteVector();
		    vtmp.addElement(WSPInteger.makeUintvar(fbp));
		    vtmp.addElement(WSPInteger.makeUintvar(el));
		    /* insert valuelength in front */
		    vtmp.insertElementAt(WSPInteger.makeValueLength(vtmp.countBytes()),0);

		    /* code name as short int and send it */
		    writeVec.addElement(new Byte(WSPInteger.makeShortInt(ncode)));
		    writeVec.addElement(vtmp);
		}
		catch (NumberFormatException nfe) { /* do not send header */ }
		break;
	    case 0x11: /* Content-Type */
		// String[] param; // Defined in Accept

		writeVec.addElement(new Byte(WSPInteger.makeShortInt(ncode)));

		vtmp=new ByteVector();
		param=splitString(this.fieldValue(),';');
		/* param[0] is media type name,
		   the others are parameters */
		
		if ((vcode=ContentTypeTable.getCode(param[0]))!=WapTable.ERROR_CODE) {
		    /* well-known media */
		    if (param.length==1) {
			/* value has no parameters.
			   code it as short int and send it */
			writeVec.addElement(new Byte(WSPInteger.makeShortInt(vcode)));
		    }
		    else {
			/* encode parameters and send them */
			vtmp=toParameterSequenceVector(param);
			vtmp.insertElementAt(new Byte(WSPInteger.makeShortInt(vcode)),0);  // add content type at front of bytestream
			
			/* if this test fails there were no parameters to send.
			   eg: the test fails if there was a q-value=1.0 */
			if (vtmp.size()>1) 

			    vtmp.insertElementAt(WSPInteger.makeValueLength(vtmp.countBytes()),0);  // add length in front
			writeVec.addElement(vtmp);
		    }
		}
		else {	 /* content type not recognized */
		    /* encode it as text */

		    btmp=toExtensionMedia(param[0]); // fieldvalue without parameters
		    if (param.length==1) {
			/* field value has no parameters, send it as text */
			writeVec.addElement(btmp);
		    }
		    else {
			/* encode parameters and send them */
			vtmp=toParameterSequenceVector(param);
			vtmp.insertElementAt(btmp,0); // add content type at front of bytestream
			vtmp.insertElementAt(WSPInteger.makeValueLength(vtmp.countBytes()),0);  // add length in front
			writeVec.addElement(vtmp);
		    }
		}
		break;
	    case 0x12: /* Date */
	    case 0x14: /* Expires */
	    case 0x17: /* If-Modified-Since */
	    case 0x1b: /* If-Unmodified-Since */
	    case 0x1d: /* Last-Modified */
		try {
		    Locale.setDefault(Locale.UK);
		    SimpleDateFormat df=new SimpleDateFormat("E, d MMM yyyy HH:mm:ss z");
		    df.setTimeZone(TimeZone.getTimeZone("GMT"));
		    Date d=df.parse(this.fieldValue());

		    btmp=WSPInteger.makeLongInt((int)(d.getTime()/1000)); // getTime returns milliseconds
		    /* code name as short int and send it */
		    writeVec.addElement(new Byte(WSPInteger.makeShortInt(ncode)));
		    writeVec.addElement(btmp);
		}
		catch(ParseException pe)
		    { /* Malformed date, don't send any date */ }
		break;
	    case 0x13: /* Etag */
		/* code name as short int and send it */
		writeVec.addElement(new Byte(WSPInteger.makeShortInt(ncode)));
		/* cut of " on both sides */
		btmp=toTextString(this.fieldValue().substring(1,this.fieldValue().length()-1));
		writeVec.addElement(btmp);
		break;
		/* case 0x14 (Expires): see 0x12 (Date) */
	    case 0x15: /* From */
	    case 0x16: /* Host */ 
	    case 0x1c: /* Location */
	    case 0x24: /* Referer */
		/* code name as short int and send it */
		writeVec.addElement(new Byte(WSPInteger.makeShortInt(ncode)));
		/* send uri as text string */
		btmp=toTextString(this.fieldValue());
		writeVec.addElement(btmp);
		break;
		/* case 0x17 (If-Modified-Since): see 0x12 (Date) */
	    case 0x18: /* If-Match */
	    case 0x19: /* If-None-Match */
		hs=this.splitListHeader();
		/* loop through all headers and encode them */
		for(int i=0;i<hs.length;i++) {
		    
		    /* code name as short int and send it */
		    writeVec.addElement(new Byte(WSPInteger.makeShortInt(ncode)));
		    if(hs[i].fieldValue().equals("*"))
			writeVec.addElement(toTextString("*"));
		    else
			/* send etag as text string */
			writeVec.addElement(toTextString(hs[i].fieldValue().substring(1,hs[i].fieldValue().length()-1)));
		}
		break;
		/* case 0x1d (Last-Modified): see 0x12 (Date) */
	    case 0x1a: /* If-Range */
		/* try if fieldvalue is a date */
		try {
		    Locale.setDefault(Locale.UK);
		    SimpleDateFormat df=new SimpleDateFormat("E, d MMM yyyy HH:mm:ss z");
		    df.setTimeZone(TimeZone.getTimeZone("GMT"));
		    Date d=df.parse(this.fieldValue());

		    btmp=WSPInteger.makeLongInt((int)(d.getTime()/1000)); // getTime returns milliseconds
		    /* code name as short int and send it */
		    writeVec.addElement(new Byte(WSPInteger.makeShortInt(ncode)));
		    writeVec.addElement(btmp);
		}
		catch(ParseException pe) /* fieldvalue is not a date, send etag */ 
		    {  
			/* code name as short int and send it */
			writeVec.addElement(new Byte(WSPInteger.makeShortInt(ncode)));
			/* cut of " on both sides */
			writeVec.addElement(toTextString(this.fieldValue().substring(1,this.fieldValue().length()-1)));
		    }
		break;
		/* case 0x1b (If-Unmodified-Since): see 0x12 (Date) */
		/* case 0x1c (Location): see 0x15 (From) */
	    case 0x1e: /* Max-Forwards */
		try {
		    int maxf=Integer.parseInt(this.fieldValue());
		    /* code name as short int and send it */
		    writeVec.addElement(new Byte(WSPInteger.makeShortInt(ncode)));
		    writeVec.addElement(WSPInteger.makeInteger(maxf));
		}
		catch (NumberFormatException nfe) { /* do not send header */ throw new StrangeHTTPException(); }
		break;
	    case 0x1f: /* Pragma */

		hs=this.splitListHeader();
		/* loop through all headers and encode them */
		for(int i=0;i<hs.length;i++) {
		    
		    vtmp=new ByteVector();
		    if(hs[i].fieldValue().equalsIgnoreCase("no-cache")) {
			vtmp.addElement(new Byte(WSPInteger.makeShortInt((byte)0x80))); // WAP WSP 8.4.2.38 & 8.4.2.15
		    }
		    else {
			/* First element in array is ignored by toParameterSequence() */
			String tmpString=new String("dummy;"+hs[i].fieldValue());
			vtmp.addElement(toParameterSequenceVector(splitString(tmpString,';')));
			vtmp.insertElementAt(WSPInteger.makeValueLength(vtmp.countBytes()),0); // insert value-length
		    }
		    writeVec.addElement(new Byte(WSPInteger.makeShortInt(ncode)));
		    writeVec.addElement(vtmp);
		}
		break;
	    case 0x20: /* Proxy-Authenticate */
		vtmp=makeChallenge(this.fieldValue());
		vtmp.insertElementAt(WSPInteger.makeValueLength(vtmp.countBytes()),0); // insert value-length
		
		/* code name as short int and send it */
		writeVec.addElement(new Byte(WSPInteger.makeShortInt(ncode)));
		/* add challenge */
		writeVec.addElement(vtmp);
		break;
	    case 0x21: /* Proxy-Authorization */
		vtmp=makeCredentials(this.fieldValue());
		vtmp.insertElementAt(WSPInteger.makeValueLength(vtmp.countBytes()),0); // insert value-length
		
		/* code name as short int and send it */
		writeVec.addElement(new Byte(WSPInteger.makeShortInt(ncode)));
		/* add credentials */
		writeVec.addElement(vtmp);
		break;
	    case 0x22: /* Public */
		/* This gateway removes any Public-header encounted. */
		break;
	    case 0x23: /* Range */
		String[] rspec;
		int delIndex, eqIndex;
		int first, last;

		try {
		    
		    if(!this.fieldValue().substring(0,5).equalsIgnoreCase("bytes"))
			throw new StrangeHTTPException();
		    
		    eqIndex=this.fieldValue().indexOf('=');
		    if(eqIndex<0)
			throw new StrangeHTTPException();

		    rspec=splitString(this.fieldValue().substring(eqIndex+1).trim(),',');
		    for(int i=0;i<rspec.length;i++) {
			last=-1;
			delIndex=rspec[i].indexOf('-');
			
			/* header must be of the form 'bytes=xx-[yy]' */
			if(delIndex<0)
			    throw new StrangeHTTPException();
			
			vtmp=new ByteVector();
			if(delIndex>0) {
			    /* byte-range-spec */
			    first=Integer.parseInt(rspec[i].substring(0,delIndex));
			    if(delIndex<rspec[i].length()-1) // there is a last-byte-pos
				last=Integer.parseInt(rspec[i].substring(delIndex+1,rspec[i].length()));
			    
			    vtmp.addElement(new Byte((byte)0x80)); // WAP WSP 8.4.2.42
			    vtmp.addElement(WSPInteger.makeUintvar(first));
			    if(last!=-1)
				vtmp.addElement(WSPInteger.makeUintvar(last));
			}
			else { /* delIndex==0 *
				  /* suffix-byte-range-spec */
			    last=Integer.parseInt(rspec[i].substring(delIndex+1,rspec[i].length()));
			    
			    vtmp.addElement(new Byte((byte)0x81)); // WAP WSP 8.4.2.42
			    vtmp.addElement(WSPInteger.makeUintvar(last));
			}
			/* add value-length */
			vtmp.insertElementAt(WSPInteger.makeValueLength(vtmp.countBytes()),0);
			
			/* code name as short int and send it */
			writeVec.addElement(new Byte(WSPInteger.makeShortInt(ncode)));
			writeVec.addElement(vtmp);
		    }
		    
		}
		catch (NumberFormatException nfe) { /* do not send header */ }
		break;
		/* case 0x24 (Referer): see 0x15 (From) */
	    case 0x25: /* Retry-After */
		vtmp=new ByteVector();
		/* try if value is a date */
		try {
		    Locale.setDefault(Locale.UK);
		    SimpleDateFormat df=new SimpleDateFormat("E, d MMM yyyy HH:mm:ss z");
		    df.setTimeZone(TimeZone.getTimeZone("GMT"));
		    Date d=df.parse(this.fieldValue());

		    vtmp.addElement(new Byte((byte)0x80)); // WAP WSP 8.4.2.44		    
		    vtmp.addElement(WSPInteger.makeLongInt((int)(d.getTime()/1000))); // getTime returns milliseconds
		}
		catch(ParseException pe) {
		    /* try if value if delta seconds */
		    try {
			btmp=WSPInteger.makeInteger(Integer.parseInt(this.fieldValue()));

			vtmp.addElement(new Byte((byte)0x81)); // WAP WSP 8.4.2.44		    
			vtmp.addElement(btmp);
		    }
		    catch (NumberFormatException nfe)  /* do not send header */
			{ throw new StrangeHTTPException(); }
		}
		vtmp.insertElementAt(WSPInteger.makeValueLength(vtmp.countBytes()),0);

		/* code name as short int and send it */
		writeVec.addElement(new Byte(WSPInteger.makeShortInt(ncode)));
		writeVec.addElement(vtmp);		  
		break;
	    case 0x26: /* Server */
	    case 0x29: /* User-Agent */
		/* code name as short int and send it */
		writeVec.addElement(new Byte(WSPInteger.makeShortInt(ncode)));
		/* send server/user info as text string */
		btmp=toTextString(this.fieldValue());
		writeVec.addElement(btmp);
		break;
	    case 0x27: /* Transfer-Encoding */
		hs=this.splitListHeader();
		/* loop through all headers and encode them */
		for(int i=0;i<hs.length;i++) {
		    /* code name as short int and send it */
		    writeVec.addElement(new Byte(WSPInteger.makeShortInt(ncode)));
		    if(hs[i].fieldValue().equalsIgnoreCase("chunked"))
			writeVec.addElement(new Byte((byte)0x80)); // WAP WSP 8.4.2.46
		    else
			writeVec.addElement(toTokenText(hs[i].fieldValue()));
		}
		break;
	    case 0x28: /* Upgrade */
		hs=this.splitListHeader();
		/* loop through all headers and encode them */
		for(int i=0;i<hs.length;i++) {
		    /* code name as short int and send it */
		    writeVec.addElement(new Byte(WSPInteger.makeShortInt(ncode)));
		    writeVec.addElement(toTextString(hs[i].fieldValue()));
		}
		break;
		/* case 0x29 (User-Agent): see 0x26 (Server) */
	    case 0x2a: /* Vary */
		hs=this.splitListHeader();
		/* loop through all headers and encode them */
		for(int i=0;i<hs.length;i++) {
		    /* code name as short int and send it */
		    writeVec.addElement(new Byte(WSPInteger.makeShortInt(ncode)));
		    if((vcode=HeaderFieldNameTable.getCode(hs[i].fieldValue()))!=WapTable.ERROR_CODE)
			writeVec.addElement(new Byte(WSPInteger.makeShortInt(vcode)));
		    else
			writeVec.addElement(toTokenText(hs[i].fieldValue()));		
		}
		break;
	    case 0x2b: /* Via */
		/* code name as short int and send it */
		writeVec.addElement(new Byte(WSPInteger.makeShortInt(ncode)));
		writeVec.addElement(toTextString(this.fieldValue()));
		break;
	    case 0x2c: /* Warning */
		/* try if there's only a number */
		int warning;
		try {
		    warning=Integer.parseInt(this.fieldValue());

		    writeVec.addElement(new Byte(WSPInteger.makeShortInt(ncode)));
		    writeVec.addElement(new Byte(WSPInteger.makeShortInt((byte)warning)));
		}
		catch (NumberFormatException nfe) {
		    try {
			/* split fieldvalue into (w-code, w-agent, w-text) */
			String[] wvals=splitString(this.fieldValue(),' ');
			warning=Integer.parseInt(wvals[0]);
			vtmp=new ByteVector();
			vtmp.addElement(new Byte(WSPInteger.makeShortInt((byte)warning)));
			vtmp.addElement(toTextString(wvals[1]));
			/* remove '"'-characters from quoted string */
			vtmp.addElement(toTextString(wvals[2].substring(1,wvals[2].length()-1)));
			/* any HTTP date is removed */
			vtmp.insertElementAt(WSPInteger.makeValueLength(vtmp.countBytes()),0);
			
			writeVec.addElement(new Byte(WSPInteger.makeShortInt(ncode)));
			writeVec.addElement(vtmp);
		    }
		    catch (IndexOutOfBoundsException ie) { /* do not send header */ }
		    catch (NumberFormatException nfe2) { /* do not send header */ }
		}
		break;
	    case 0x2d: /* WWW-Authenticate */
		vtmp=makeChallenge(this.fieldValue());
		vtmp.insertElementAt(WSPInteger.makeValueLength(vtmp.countBytes()),0); // insert value-length
		
		/* code name as short int and send it */
		writeVec.addElement(new Byte(WSPInteger.makeShortInt(ncode)));
		/* add challenge */
		writeVec.addElement(vtmp);
		break;
	    case 0x2e: /* Content-Disposition */
		/* This gateway does not forward the Content-Disposition-header. */
		break;
		    
		/* These headers are not supported in WAP 1.1.
		   They are sent in plain text */
	    case 0x2f: /* X-Wap-Application-Id */
	    case 0x30: /* X-Wap-Content-URI */
	    case 0x31: /* X-Wap-Initiator-URI */
	    case 0x32: /* Accept-Application */
	    case 0x33: /* Bearer-Indication */
	    case 0x34: /* Push-Flag */
	    case 0x35: /* Profile */
	    case 0x36: /* Profile-Diff */
	    case 0x37: /* Profile-Warning */

	    defaults:  /* code not recognized, encode header as text and send */
	    writeVec.addElement(toTokenText(this.fieldName()));
	    writeVec.addElement(toTextString(this.fieldValue()));
	    break;
	    } /* end of switch */
	    
	}
	catch (StrangeHTTPException she) { 
	    /* Malformed header. Don't send it */ 
	    return new ByteVector();
	}	
	
	return writeVec;	
    }

	
}


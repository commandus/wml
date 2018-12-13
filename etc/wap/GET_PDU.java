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
import java.io.*;
import java.net.*;
    
/** This class holds a GET PDU*/
class GET_PDU extends PDU
{
    // private String uri;
    private Vector headers;
    private WspInStream in;
    
    /*creates a GET PDU header from the 
      specified TID and the WSP stream in*/
    GET_PDU(int tid,
		   WspInStream in) throws IOException, CodeNotInTableException, CloneNotSupportedException
    {
	super(tid);
	int len,i;
	WspInStream wsp;
 
	//First there is the URI length
	len=in.getUIntVar();
	
	//read the URI
	super.URL=new String();
	for(i=0;i<len;i++)
	    super.URL+=(char)in.read();
	
	/* Get the headers
	   Until the end of the SDU, 
	   where I hope this stream end...*/
	headers=new Vector();
	// 	/* loop until the entire packet is processed
	// 	 There is crap at the end of the packet, which 
	// 	I don't know what to do with, so I catch it with
	// 	an exception )-:*/
 	while(in.available()>0){
	    try{
		headers.addElement(in.decodeHeader());
	    }
	    catch(ContentRangeException e){
		/*Can a Content-range-header be in a GET???
		  Oh well...*/
		headers.addElement(new HTTPHeader("Content-Range","bytes "+e.firstBytePos+"-"+e.firstBytePos+"/"+e.entityLength));
	    }
	    catch(ShiftSequenceException e){
		/*change the codepage*/
		System.err.println("Shiftsequence cought. And we are running in sessionless mode...");
		break;
	    }
	    catch(MalformedHeaderException e){
		/*a malformed header has been sent, 
		  we skip the rest of the stream*/
		break;
	    }
	    catch(IOException e){
		//we skip the rest of the stream
	    	break;
	    }
	}
    }
    /*---------------------------------------------------------------------------------------------*/
    /**Sends the PDU to the HTTP-server and returns a Response-PDU
       containging the response*/
    Reply_PDU getResponse()
    {
	URL url;
	HttpURLConnection uc;

	try{
	    url=new URL(super.URL);
	}
	catch(MalformedURLException e){
	    /* Somethings wrong with the URL, so we answer 
	       back to the phone with a 'Bad Gateway'*/
	    return new Reply_PDU(super.tid,502,"What kind of URI is "+super.URL+e.getMessage());
	}

	try{
	    uc=(HttpURLConnection)url.openConnection();
	}
	catch(IOException e){
	    return new Reply_PDU(super.tid,502,"Gateway couldn't connect to "+url);
	}

	StringTokenizer tok;
	boolean viaFound=false;

	/*only the last instance of a certain header in sent )-:
	 known bug...*/
	int i,j;

	if(headers.size()>1)
	    //loop entire vector
	    for(i=0;i<headers.size();i++){
		for(j=i+1;j<headers.size();j++){
		    //check if repeated header
		    while((j<headers.size())&&(((HTTPHeader)headers.elementAt(j)).fieldName().equals(((HTTPHeader)headers.elementAt(i)).fieldName()))){
			((HTTPHeader)headers.elementAt(i)).appendToFieldValue(((HTTPHeader)headers.elementAt(j)).fieldValue());
			headers.removeElementAt(j);
		    }
		}
	    }

	//Send all the headers	
	for(i=0;i<headers.size();i++){
	    //add ourselfs to via
	    if(((HTTPHeader)headers.elementAt(i)).fieldName().equalsIgnoreCase("via")){
		viaFound=true;
		((HTTPHeader)headers.elementAt(i)).appendToFieldValue(",Jwap");
	    }
	    uc.setRequestProperty(((HTTPHeader)headers.elementAt(i)).fieldName(),((HTTPHeader)headers.elementAt(i)).fieldValue());
	}

	if(!viaFound)
	    uc.setRequestProperty("Via","Jwap");
	
	return new Reply_PDU(super.tid,uc);
    }
}



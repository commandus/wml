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

import java.net.*;
import java.io.*;
import java.util.*;

class PostPdu extends PDU 
{
    //    private String uri;
    private Vector headers=new Vector();
    private byte[] data;
    
    PostPdu(int tid,
		   WspInStream in) throws IOException, CodeNotInTableException, CloneNotSupportedException
    {
	super(tid);

	int uriLen,headersLen,before,after,i,fbp=0,el=0;
	String contentType;
	boolean contentRangeField=false;

	//First there is the URI length
	uriLen=in.getUIntVar();

	//then comes the headers-length
	headersLen=in.getUIntVar();

	//here comes the URI
	super.URL=new String();
	for(i=0;i<uriLen;i++)
	    super.URL+=(char)in.read();

	//And the Content-type
	before=in.available();
	contentType=in.getContentType();
	headersLen-=(before-in.available());

	/*The headers are HeaderLen-(length of
	  Content-type*/
	while(headersLen>0){
	    before=in.available();
	    try{
		headers.addElement(in.decodeHeader());
	    }
	    catch(ShiftSequenceException e){
		System.err.println(""+e.getClass()+" caught. And we are in conectionless mode...");
		/*Continue*/
		continue;	
	    }
	    catch(MalformedHeaderException e){
		/*flush the rest of the headers...*/
		headersLen-=before-in.available();
		for(i=0;i<headersLen;i++)
		    in.read();
	    }
	    catch(ContentRangeException e){
		/*A Content-range-header has been cought
		  We can't set it before we know the size 
		  of the data field, so for now we just 
		  register it has been sent, and when we know 
		  the size of the data we set it*/
		fbp=e.firstBytePos;
		el=e.entityLength;
		contentRangeField=true;
		
	    }
	    headersLen-=before-in.available();
	}

	if(contentRangeField)
	    headers.addElement(new HTTPHeader("Content-Range","bytes "+fbp+"-"+(fbp+in.available())+"/"+el));
	
	/*Get the data
	  Until end of SDU*/
	data=new byte[in.available()];
	in.read(data,0,in.available());
    }
    /*-------------------------------------------------------------*/
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
	    return new Reply_PDU(super.tid,502,"Gateway couldn't connect to "+url.toString());
	}
	uc.setDoOutput(true);
	
	int i,j;
	boolean viaFound=false;

	/*only the last instance of a certain header in sent )-:
	  known bug...*/

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

	//Set headers
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

	//Send Data
	try{
	    uc.getOutputStream().write(data);
	}
	catch(IOException e){
	    return new Reply_PDU(super.tid,502,"Gateway couldn't write data to "+url.toString());
	}

	return new Reply_PDU(tid,uc);
    }
}

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

import java.io.*;
import java.net.*;
import java.util.*;

class Request extends Thread
{
    /**Boolean value to indicate
       whether this thread is
       free or occupied (i.e. busy).
       DO NOT FORGET TO SET IT!!!*/
    boolean free=true;
    private DatagramPacket p;

    /*------------------------------------------*/
    /**Sets the packet which this request will 
       handle and starts up the thread*/
    synchronized void setPacket(DatagramPacket p)
    {
	this.p=p;
	notify();
    }
    /*------------------------------------------*/
   public synchronized void run()
    {
	//continue execution forever
	while(true){

	    /*wait for a new packet to be set
	      and then handle it*/
	    try{
		wait();
	    }
	    catch(InterruptedException e){
		System.err.println(this+" was interrupted?!?!?!");
		return;
	    }

	    //get return address
	    InetAddress clientAddress=p.getAddress();
	    int clientPort=p.getPort();
 	    
	    PDU pdu=null;
	    Reply_PDU reply=null;
	
	    //create a PDU from the significant portion of the UDP-packet    	
	    try{	    
		pdu=(new WspInStream(new ByteArrayInputStream(p.getData(),0,p.getLength()))).mkPDU();
	    }
	    catch(CloneNotSupportedException e){
		System.err.println("Now this shouldn't have happened. Please report this.");
		e.printStackTrace();
		return;
	    }
	    catch(IOException e){
		System.err.println("IOException occurd:"+e.getMessage()+"Skipping this packet");
		return;
	    }
	    catch(CodeNotInTableException e){
		System.err.println("CodeNotInTable occured:"+e.getMessage());
		e.printStackTrace();
		return;
	    }

	    System.err.println((new Date()).toString()+
			       " Request made from: "+
			       clientAddress.getHostAddress()+
			       " for "+pdu.URL);	

	    //And now get the response from the remote HTTP-server    
	    try {
		reply=pdu.getResponse();
	    }
	    catch(IOException e){
		/* Gateway can't reach http-sever.
		   Send a text to the client. */
		reply=new Reply_PDU(pdu.tid, 502, "Gateway can't reach network.");
		return;
	    }

	    /* build a new packet to send back to the phone */
	    p=new DatagramPacket(new byte[reply.size()],reply.size(),clientAddress,clientPort);
	    p.setData(reply.getByteArray());

	    //And send it back to the phone
	    Jwap.send(p);
	
	    //Mark this request free
	    this.free=true;
	}
    }
    /*------------------------------------------*/
}

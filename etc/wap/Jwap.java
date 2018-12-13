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

public class java
{
    private static DatagramSocket sock;

//     /**Creates a thread that will listen to the if networkInterface*/
//     public Jwap(DatagramPacket p)
//     {
// 	this.p=p;
//     }
    /*-------------------------------------------------------------------------------------------------*/    	
    public static void main(String[] argv)
    {
	ThreadPool pool;

	int initialNumberOfThreads;
	long interval;
	
	if(argv.length<1){
	    System.err.println("usage: java Jwap <if>");
	    System.exit(-1);
	}

	System.out.println("***Jwap - the Java Wap Gateway***");
	System.out.println("Version: 0.8");
	System.out.println("(C) Tietoenator PerCom AB");
	System.out.println("The Jwap project");
	System.out.println("David Juran & Anders Mårtensson");
	System.out.println("jwap@simplex.hemmet.chalmers.se");
	System.out.println();
	
	/*Set up a socket to listen to. This socket must be static 
	  otherwise the run-method won't be able to 
	  send on it*/
	try{
	    sock=new DatagramSocket(9200,InetAddress.getByName(argv[0]));
	}
	catch(SocketException e){
	    System.err.println("Failed to create Socket."+e.getMessage());
	    System.exit(-1);
	}
	catch(UnknownHostException e){
	    System.err.println("Cant find interface )-:"+e.getMessage());
	    System.exit(-1);
	}

	System.out.println("***Jwap running on "+sock.getLocalAddress().getHostName()+":9200***");

	//Set up a pool of threads
	if(System.getProperty("InitialNumberOfThreads")!=null)
	    initialNumberOfThreads=(new Integer(System.getProperty("InitialNumberOfThreads"))).intValue();
	else
	    //defaults to 8 threads
	    initialNumberOfThreads=8;
	if(System.getProperty("Interval")!=null)
	    interval=(new Long(System.getProperty("Interval"))).longValue();
	else
	    //defaults to 5 min.
	    interval=300000;
		    
	pool=new ThreadPool(initialNumberOfThreads,interval);
	
	/*If we are busy, we don't need to check
	  the number of threads*/
	pool.setPriority(Thread.MIN_PRIORITY);
	pool.start();
					   

	//listen for packets

	
// 	byte[] buf = new byte[1700];
// 	FileInputStream sl1 = new FileInputStream("SL1.bin");
// 	DatagramPacket p=new DatagramPacket(buf,1700);	
// 	sl1.read(buf);
	
// 	p.setData(buf);
// 	pool.dispatch(p);
	
	    

	while(true){
	    byte[] buf=new byte[1700];
	    DatagramPacket p=new DatagramPacket(buf,1700);	
	    try{
		sock.receive(p);
	    }
	    catch(IOException e){
		System.err.println("IOException cought, skipping this packet");
		e.printStackTrace();
		continue;
	    }

	    //fire up a new thread to handle this request
	    pool.dispatch(p);
	}
    }
    /*-------------------------------------------------------------------------------------------------*/ 
    /**Sends the packet p on the port registered
       in the main method of the class.
       The packet has to be sent back to the phone using this 
       method, or it won't come from the same port*/
    static void send(DatagramPacket p)
    {
	try{
	    sock.send(p);
	}
	catch(IOException e)
	    {
		System.err.println(e.getMessage());
	    }
    }
 /*-------------------------------------------------------------------------------------------------*/    
 
}


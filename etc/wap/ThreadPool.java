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
import java.util.*;

/**This class is supposed to hold a pool of threads ready to 
   take care of incomming requests. It will automatically
   keep the number of unused threads at a apropriate level*/
class ThreadPool extends Thread
{
    private Vector threads;
    private long interval;
    
    /*----------------------------------------------------------*/
    /**Creates a new pool with initialNo of threads initially*/
    ThreadPool(int initialNo,
	       long interval)
    {
	//5 min Don't forget to det right...
	this.interval=interval;
	
	/*Create a bunch of threads and 
	  start them. They won't actually start running
	  before setPacket() is called*/
	threads=new Vector(initialNo);
	for(int i=0;i<initialNo;i++){
	    Request tmp=new Request();
	    tmp.start();
	    threads.addElement(tmp);
	}
    }
    /*----------------------------------------------------------*/
    /**fires up a thread to serve the 
       Packet p.
    Hmmm, I begin to doubt the efficiency of this dispatcher...
    Override it if you don't like it...*/
    void dispatch(DatagramPacket p)
    {
	int i;
	Request tmp;

	/*Search the vector fron the top to find
	  the first unoccupied thread.
	  The vector is sorted so that one
	  should be found fairly quick*/
	try{	
	    for(i=0;!((Request)threads.elementAt(i)).free;i++);
	    //Take this thread out of the vector
	    tmp=(Request)threads.elementAt(i);
	    threads.removeElementAt(i);
	}
	catch(ArrayIndexOutOfBoundsException e){
	    //A new thread is needed
	    tmp=new Request();
	    tmp.setPriority(Thread.NORM_PRIORITY);
	}
		
	//fire up this thread
	tmp.free=false;
	tmp.setPacket(p);

	//insert the thread at the bottom of the vector
	threads.addElement(tmp);
    }
    /*----------------------------------------------------------*/
public void run()
    {
	/*A infinite loop that will 
	  with a certain interval check 
	  whether the threads are used or not
	  and remove them if there are to many of them*/
	while(true){
	    try{
		sleep(interval);
	    }
	    catch(InterruptedException e){
		//Oh well...
		e.printStackTrace();
	    }

	    /*I will make sure I have as
	      most twice as many threads as the number 
	      currently used. This heuristic is based on a guess, 
	      please change it if you don't like it*/

	    //Count used threads
	    int used=0;
	    for(int i=0;i<threads.size();i++)
		if(!((Request)threads.elementAt(i)).free)
		    used++;

	    //We want at least 2 free threads
	    if(used==0)
		used=1;
	    
	    /*And now we remove the excessive amount*/
	    synchronized(threads){
		for(int i=0;(threads.size()>used*2)&&(i<threads.size());i++)
		    if(((Request)threads.elementAt(i)).free)
			threads.removeElementAt(i);
	    }
	}
    }
    /*----------------------------------------------------------*/
//     /*test only*/
//     public static void main(String[] argv)
//     {
// 	ThreadPool tp=new ThreadPool(8);
// 	tp.dispatch(null);
	
//     }
    /*----------------------------------------------------------*/
}

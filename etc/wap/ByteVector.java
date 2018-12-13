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
import java.util.*;

/** This class is meant to store <CODE>Bytes</CODE>, <CODE>byte[]</CODE> and other
 * <CODE>ByteVector</CODE>s. The {@link #writeByteVector(OutputStream ostr) writeByteVector method} can
 * be used to write all bytes in the <code>ByteVector</code> to an <code>OutputStream</code>. */
public class ByteVector extends Vector {

    /** Constructs an empty vector so that its internal data array has size 10
     *  and its standard capacity increment is zero. */
    public ByteVector() {
	super();
    }
    
    /** Constructs an empty vector with the specified initial capacity and with its
     *  capacity increment equal to zero. */
    public ByteVector(int initialCapacity) {
	super(initialCapacity);
    }
    
    /** Constructs an empty vector with the specified initial capacity and capacity increment. */
    public ByteVector(int initialCapacity, int capacityIncrement) {
	super(initialCapacity, capacityIncrement);
    }


    /** Writes a vector of bytes to the stream. The vector <I>may only</I> contain 
     * elements of the <CODE>Byte</CODE>-class or <CODE>byte[]</CODE>.
     * @param ostr <code>OutputStream</code> to write to */
    public void writeByteVector(OutputStream ostr) throws IOException {
	Object tmp;
	try {
	    while (!this.isEmpty()) {
		if(this.firstElement() instanceof ByteVector) {
		    /* a vector; write it */
		    tmp=this.firstElement();
		    this.removeElementAt(0);
		    ((ByteVector)tmp).writeByteVector(ostr);
		}
		else if(this.firstElement() instanceof Byte) {
		    /* write one byte */
		    tmp=this.firstElement();
		    this.removeElementAt(0);
		    ostr.write( ((Byte)tmp).byteValue() );
		}
		else { /*  (this.firstElement() instanceof byte[]) */
		    /* write byte array */
		    tmp=this.firstElement();
		    this.removeElementAt(0);
		    ostr.write( (byte[])tmp );
		}
	    }
	}
	catch(ClassCastException cce) {
	    System.err.println("FATAL ERROR: Not a bytetype in ByteVector.");
	    throw cce;
	}
    }

    /** Counts how many bytes that are present in the vector */
    public int countBytes() {
	int vectorlen;
	
	vectorlen=0;
	try {
	    for(int i=0;i<this.size();i++) {
		if(this.elementAt(i) instanceof ByteVector)
		    vectorlen+=((ByteVector)this.elementAt(i)).countBytes();
		else if(this.elementAt(i) instanceof Byte)
		    vectorlen++;
		else /* (this.elementAt(i) instanceof byte[]) */
		    vectorlen+=((byte[])this.elementAt(i)).length;
	    }
	}
	catch(ClassCastException cce) {
	    System.err.println("FATAL ERROR: Not a bytetype in ByteVector.");
	    throw cce;
	}
	return vectorlen;
    }
    
    /* help fuction for the method toByteArray() */
    private void tBA(byte[] a,int[] cursor) {
	try {
	    for(int i=0;i<this.size();i++) {
		if(this.elementAt(i) instanceof ByteVector) {
		    ((ByteVector)(this.elementAt(i))).tBA(a,cursor);
		}
		else if(this.elementAt(i) instanceof Byte) {
		    a[cursor[0]]=((Byte)(this.elementAt(i))).byteValue();
		    cursor[0]++;
		}
		else { /* (this.elementAt(i) instanceof byte[]) */ 		 
		    /* copy all bytes to array */
		    int j=0;
		    for(j=0;j<((byte[])(this.elementAt(i))).length;j++)
			a[cursor[0]+j]=((byte[])(this.elementAt(i)))[j];
		    cursor[0]+=j;
		}
	    }
	}
	catch(ClassCastException cce) {
	    System.err.println("FATAL ERROR: Not a bytetype in ByteVector.");
	    throw cce;
	}
    }
    
    /** Converts a <code>ByteVector</code> to an <code>byte[]</code>. */
    public byte[] toByteArray() {
	int length=this.countBytes();
	byte[] bytes=new byte[length];
	int[] cursor={0}; // used to simulate call by reference
	
	this.tBA(bytes,cursor);
	return bytes;
    }   
    
}

    

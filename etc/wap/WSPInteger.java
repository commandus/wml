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

/** This class contains a few methods to manipulate WSP integers */
public class WSPInteger {

    static private final byte SHORT_INT_MASK=(byte)0x80;  // used when encoding to short ints.

    /** Makes a short int from 7-bit integer (set MSB). */
    public static byte makeShortInt(byte b) {
	return b |= SHORT_INT_MASK;
    }

    /** Makes a long integer from an int and returns an array of bytes:
	Short-length Multi-octet-integer   (WAP WSP 8.4.2.1) */
    public static byte[] makeLongInt(int number) {
	byte[] tmp;
	byte length=0;
	int tmpnumber=number;

	/* find out byte-length needed */
	do {
	    length++;
	    tmpnumber>>>=8;  // shift one byte
	} while(tmpnumber>0);

	tmp=new byte[length+1]; // one more for the Short-length
	for(int i=0;i<length;i++) {
	    tmp[length-i]=(byte) number; // cut off MSB:s
	    number>>>=8;
	}

	tmp[0]=length; // set Short-length 
	return tmp;
    }

    /** Makes a short or a long integer and returns the byte array.
	If the number fits in a short int, an array with one element is returned.
	@param int must be a positive integer. */
    public static byte[] makeInteger(int number) {
	byte[] tmp;

	if(number<128) {
	    tmp=new byte[1];
	    tmp[0]=makeShortInt((byte)number);
	}
	else {
	    tmp=makeLongInt(number);
	}
	
	return tmp;
    }

    /** Returns an array of bytes containing the uintvar.
	The continue-bit is set in all but LS Byte. */
    public static byte[] makeUintvar(int number) {
	final int[] MASK = {0xf0000000, 0xfe00000, 0x1fc000, 0x3f80, 0x7f };
	int needed=0;  // how many bytes needed for uintvar
	byte[] intvar = new byte[5];
	byte[] ret;
	
	/* split bits into uintvar-array */
	for(int i=0;i<5;i++) {
	    intvar[i]= (byte) ( (number&MASK[i]) >>> (7*(4-i)) );
	    intvar[i]|= (byte)0x80; // set continue-bit in each byte
	}
		
	while (number>0) { 
	    number&=~MASK[4-needed];      // clear bits in number
	    needed++;
	}

	intvar[4]&=(byte)0x7f; // clear continue-bit in last byte

	/* move uintvar to return array */
	ret=new byte[needed];
	for(int i=0;i<needed;i++) {
	    ret[i]=intvar[5-needed+i];
	}	
	return ret;
    }

    /** Makes a Value-Length from a specified length.
	Returns an array of bytes */
    public static byte[] makeValueLength(int len) {
	byte[] tmp=null, ret=null;

	if(len<31) {  /* WAP WSP 8.4.2.2 */
	    /* encode as short int */
	    ret=new byte[1];
	    ret[0]=(byte)len;
	}
	else {
	    /* encode as (Length-quote Length) */
	    tmp=makeUintvar(len);
	    ret=new byte[tmp.length+1];

	    ret[0]=(byte)31;  // WAP WSP 8.4.2.2 
	    for(int i=0;i<tmp.length;i++) {
		ret[i+1]=tmp[i];
	    }
	}
	return ret;
    }
}

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
 
/** This class is a Base64 coder/decoder. It should be used like:
    <blockquote><pre>
    String plain="abcXYZ";
    Base64coder bc=new Base64coder();
    String result=bc.encode(plain);
    </pre></blockquote>
*/
public class Base64Coder {

    /* Base64 alphabet */
    static private final String alphabet="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";

    /* masks used by this class */
    static private final int[] plainTextMask = {0xff0000, 0xff00, 0xff};
    static private final int[] cipherMask = {0xfc0000, 0x3f000, 0xfc0, 0x3f};

    /** This method encodes a plaintext into Base64 code. */
    static public String encode(String plain) {
	String returnStr=""; // returnstring
	int tmpInt;          // integer to plaintext characters
	int cursor=0;        // index in plaintext
	int nrPadd=0;        // number of '='-characters needed at end
	int charIndex;       // ASCII value or 6-bit value from Base64-alphabet
	boolean reachedEnd=false; // loop variable
	int current;         // loop variable

	while(!reachedEnd) {
	    tmpInt=0;
	    for(current=0; current<3 && !reachedEnd; current++) {
		if(cursor==plain.length())
		    break; // reached end
		else {		    
		    charIndex=(int)plain.charAt(cursor);
		    charIndex<<=((2-current)*8);  // shift it to right place
		    tmpInt|=charIndex;
		    cursor++;
		}
	    }
	    /* tmpInt now contains 4 Base64 indexes */

	    if(cursor==plain.length())
		reachedEnd=true;

	    /* find out how many '=' at end */
	    if(reachedEnd)
		nrPadd=3-current;  // i is off by one

	    for(int j=0; j<(4-nrPadd); j++) {	    
		charIndex=(tmpInt&cipherMask[j])>>>((3-j)*6);
		returnStr += alphabet.charAt(charIndex);
	    }

	}

	/* add padding */
	for(int k=0; k<nrPadd; k++) 
	    returnStr+='=';

	return returnStr;
    }	

    /** This method decodes a Base64 code string back to plaintext.*/
    static public String decode(String cipher) {
	String returnStr=""; // returnstring
	int tmpInt;          // integer to hold plaintext characters
	int cursor=0;        // index in cipher
	int nrEq=0;          // number of '='-characters
	int charIndex;       // 6-bit value from Base64-alphabet or ASCII value
	boolean reachedEnd=false; // loop variable

	while(!reachedEnd) {
	    tmpInt=0;
	    for(int i=0; i<4 && !reachedEnd; i++) {
		if(cursor==cipher.length())
		    reachedEnd=true;
		else {
		    charIndex=alphabet.indexOf(cipher.charAt(cursor));
		    if(charIndex==64) {// hit the padding
			reachedEnd=true;
		    }
		    else {
			charIndex<<=((3-i)*6);  // shift it to right place
			tmpInt|=charIndex;
			cursor++;
		    }
		}
	    }
	    /* tmpInt now contains 3 characters */

	    /* find out how many '=' at end */
	    if(reachedEnd)
		nrEq=cipher.length()-cursor;

	    for(int j=0; j<(3-nrEq); j++) {
		charIndex=(tmpInt&plainTextMask[j])>>>((2-j)*8);
		returnStr += (char)charIndex;
	    }
	}	
	return returnStr;
    }
}


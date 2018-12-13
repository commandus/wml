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

/** This class contains the WSP encoding of IANA MIBEnum values.
 * The information is taken from <I>WAP WSP</I>, Appendix A, Table 42. The full set
 * may be found at <A HREF="ftp://ftp.isi.edu/in-notes/iana/assignments/character-sets">
 * ftp://ftp.isi.edu/in-notes/iana/assignments/character-sets</A>.
 * @author Anders Mårtensson
 */
public final class CharacterSetTable extends WapTable {
    /* Contains Character sets */
    private static final String[] CARACTER_SET = { "big5", "iso-10646-ucs-2", "iso-8859-1", "iso-8859-2", "iso-8859-3", 
						   "iso-8859-4", "iso-8859-5", "iso-8859-6", "iso-8859-7", "iso-8859-8",
						   "iso-8859-9", "shift_JIS", "us-ascii", "utf-8" };

    /* Contains all WAP codes (=IANA MIBEnum values) for the character sets */
    private static final int[] MIBENUM = { 2026, 1000, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B,
					    0x0C, 0x11, 0x03, 0x6A };
    
    /** Translates between character-set and IANA MIBEnum.
     * @param name character-set (case-<I>in</I>sensitive)
     * @return MIBEnum value. Method returns 0 if characterset is not in table.
     */ 
    public static int getMIB(String name) {
	for (int i=0; i<CARACTER_SET.length; i++) {
	    if (name.equalsIgnoreCase(CARACTER_SET[i]))
		return MIBENUM[i];
	}
	// Content type not recognized
	return 0;
    }

    /** Translates between WAP encoded header and HTTP header.
     * @param code Encoded WAP Content type.
     * @return HTTP Content type.
     */ 
    public static String getSet(int mib) throws CodeNotInTableException {
	for (int i=0; i<MIBENUM.length; i++) {
	    if (mib==MIBENUM[i])
		return new String(CARACTER_SET[i]);
	}
	// Content type not recognized
	throw new CodeNotInTableException("MIB "+mib+" is not included in this character set table.");
    }

}

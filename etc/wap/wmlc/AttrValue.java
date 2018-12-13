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

package COM.tietoenator.percom.WapGateway.wmlc;
/** This class contains the codes for the ATTRVALUE code space. */
final class AttrValue {

  private static String[] ATTR_VALUE={ ".com/", ".edu/", ".net/", ".org/", "accept", "bottom", "clear", "delete",
				       "help", "http://", "http://www.", "https://", "https://www.", /* NULL, */ "middle",
				       "nowrap", "onpick", "onenterbackward", "onenterforward", "ontimer", "options",
				       "password", "reset", /* NULL, */ "text", "top", "unknown", "wrap", "www."};

    private static byte[] ATTR_CODE={ (byte)0x85, (byte)0x86, (byte)0x87, (byte)0x88, (byte)0x89, (byte)0x8A, (byte)0x8B,
				      (byte)0x8C, (byte)0x8D, (byte)0x8E, (byte)0x8F, (byte)0x90, (byte)0x91,
				      /* (byte)0x92,*/ (byte)0x93, (byte)0x94, (byte)0x95, (byte)0x96, (byte)0x97,
				      (byte)0x98, (byte)0x99, (byte)0x9A, (byte)0x9B, /* (byte)0x9C, */ (byte)0x9D,
				      (byte)0x9E, (byte)0x9F, (byte)0xA0, (byte)0xA1 };

    /** Translates between ATTRVALUE name and assigned value
     * @param name text value
     * @return assigned value. <code>0</code> if not in table.
     */
    static byte getValue(String name) {
	for (int i=0; i<ATTR_VALUE.length; i++) {
	    if (name.equals(ATTR_VALUE[i]))
		return ATTR_CODE[i];
	}
	return 0;
    }

    /** Translates between ATTRSTART value and text string
     * @param val assigned value 
     * @return text value. <code>null</code> if error.
     */
    static String getText(int val) {
	for (int i=0; i<ATTR_CODE.length; i++) {
	    if (val==ATTR_CODE[i])
		return new String(ATTR_VALUE[i]);
	}
	return null;
    }
}

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
/** This class contains the ATTRSTART names and assiged numbers as defined by attribute code page 0.
 * (Info from Kannel and <code>wml-tools</code>.)
 */
final class AttrStart {

  private static String[] ATTR_START={ "accept-charset", "align=\"bottom\"", "align=\"center\"", "align=\"left\"",
				       "align=\"middle\"", "align=\"right\"", "align=\"top\"", "alt", "content",
				       /* null, */ "domain", "emptyok=\"false\"", "emptyok-\"true\"", "format",
				       "height", "hspace", "ivalue", "iname", /* null, */ "label", "localsrc", 
				       "maxlength", "method=\"get\"", "method=\"post\"", "mode=\"nowrap\"",
				       "mode=\"wrap\"", "multiple=\"false\"", "multiple=\"true\"", "name",
				       "newcontext=\"false\"", "newcontext=\"true\"", "onpick", "onenterbackward",
				       "onenterforward", "ontimer", "optional=\"false\"", "optional=\"true\"", "path",
				       /* null, null,  null, */ "scheme", "sendreferer=\"false\"",
				       "sendreferer=\"true\"", "size", "src", "ordered=\"true\"", "ordered=\"false\"",
				       "tabindex", "title", "type", "type=\"accept\"", "type=\"delete\"",
				       "type=\"help\"", "type=\"password\"", "type=\"onpick\"",
				       "type=\"onenterbackward\"", "type=\"onenterforward\"", "type=\"ontimer\"",
				       /* null,  null,  null,  null,  null, */ "type=\"options\"", "type=\"prev\"",
				       "type=\"reset\"", "type=\"text\"", "type=\"vnd\"", "href", "href=\"http://",
				       "href=\"https://", "value", "vspace", "width", "xml:lang", /* null, */
				       "align", "columns", "class", "id", "forua=\"false\"", "forua=\"true\"",
				       "src=\"http://", "src=\"https://", "http-equiv", "http-equiv=\"Content-Type\"",
				       "content=\"application/vnd.wap.wmlc;charset=", "http-equiv=\"Expires\""};

  private static byte[] ATTR_CODE={ 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, /*0x0E,*/ 0x0F, 0x10, 0x11,
				    0x12, 0x13, 0x14, 0x15, 0x16, /*0x17,*/ 0x18, 0x19, 0x1A, 0x1B, 0x1C, 0x1D, 0x1E,
				    0x1F, 0x20, 0x21, 0x22, 0x23, 0x24, 0x25, 0x26, 0x27, 0x28, 0x29, 0x2A, /*0x2B,
				    0x2C, 0x2D,*/ 0x2E, 0x2F, 0x30, 0x31, 0x32, 0x33, 0x34, 0x35, 0x36, 0x37, 0x38,
				    0x39, 0x3A, 0x3B, 0x3C, 0x3D, 0x3E, 0x3F, /*0x40, 0x41, 0x42, 0x43, 0x44,*/ 0x45,
				    0x46, 0x47, 0x48, 0x49, 0x4A, 0x4B, 0x4C, 0x4D, 0x4E, 0x4F, 0x50, /*0x51,*/ 0x52,
				    0x53, 0x54, 0x55, 0x56, 0x57, 0x58, 0x59, 0x5A, 0x5B, 0x5C, 0x5D};


    /** Translates between ATTRSTART name and assigned value
     * @param name text value
     * @return assigned value. <code>0</code> if not in table.
     */
    static byte getValue(String name) {
	for (int i=0; i<ATTR_START.length; i++) {
	    if (name.equals(ATTR_START[i]))
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
		return new String(ATTR_START[i]);
	}
	return null;
    }

    /** Translates between ATTRSTART name and assigned value. Don't
     * check in the table unless the string in the table is longer
     * than <code>minLength</code>.
     * @param name text value
     * @param minLength minimun length of the string
     * @return assigned value. <code>0</code> if not in table.
     */
    static byte getValue(String name, int minLength) {
        for (int i=0; i<ATTR_START.length; i++) {
	    if ( (ATTR_START[i].length() >= minLength) && 
		 (ATTR_START[i].regionMatches(0,name,0,ATTR_START[i].length())) )
		return ATTR_CODE[i];        
        }
        return 0;
    }

    /** Find out how long a string entry in the table is.
     * @param attrCode assigned value of the attribute start.
     * @return the length of the string entry
     */
    static int lengthAttrString(byte attrCode) {
        if (attrCode == 0) 
	    return 0;
        for (int i=0; i<ATTR_CODE.length; i++) {
	    if (ATTR_CODE[i] == attrCode)
		return ATTR_START[i].length();
        }
        return 0;
    }
}

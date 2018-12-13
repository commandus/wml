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
/** This class contains the tag names and assiged numbers as defined by tag code page 0.
 * (Info from Kannel and <code>wml-tools</code>.)
 */
final class TagToken {

    private static final String[] TAG_NAMES={ "a","td","tr","table","p","postfield","anchor","access","b","big","br",
					      "card","do","em","fieldset","go","head","i","img","input","meta","noop",
					      "prev","onevent","optgroup","option","refresh","select","small","strong",
					      /* null, */ "template","timer","u","setvar","wml"};

    private static final byte[] TAG_BYTE={ 0x1C, 0x1D, 0x1E, 0x1F, 0x20, 0x21, 0x22, 0x23, 0x24, 0x25, 0x26, 0x27,
					   0x28, 0x29, 0x2A, 0x2B, 0x2C, 0x2D, 0x2E, 0x2F, 0x30, 0x31, 0x32, 0x33,
					   0x34, 0x35, 0x36, 0x37, 0x38, 0x39, /*0x3A,*/ 0x3B, 0x3C, 0x3D, 0x3E, 0x3F};

    /** Translates between tag name and assigned value
     * @param name text value
     * @return assigned value. <code>0</code> if error.
     */
    static byte getValue(String name) {
	for (int i=0; i<TAG_NAMES.length; i++) {
	    if (name.equals(TAG_NAMES[i]))
		return TAG_BYTE[i];
	}
	return 0;
    }

    /** Translates between tag value and text string
     * @param val assigned value 
     * @return text value. <code>null</code> if error.
     */
    static String getText(int val) {
	for (int i=0; i<TAG_BYTE.length; i++) {
	    if (val==TAG_BYTE[i])
		return new String(TAG_NAMES[i]);
	}
	return null;
    }
}

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

/** This class contains the WSP encoding of HTTP Parameters..
 * The information is taken from <I>WAP WSP</I>, Appendix A, Table 38.
 * <P> The class also includes some methods to translate between Parameter
 * tokens and WAP codes. </P>
 * @author Anders Mårtensson
 */
final class ParameterCodeTable extends WapTable {

    /** Contains all HTTP Parameter names */
    private static final String[] PARAMETER_NAME = { "q", "charset", "level", "type", "name", "filename",
						    "differences", "padding", "type", "start", "start-info" };

    /** Contains all WAP codes for the HTTP Parameter names */
    private static final byte[] PARAMETER_CODE = { 0x00, 0x01, 0x02, 0x03, 0x05, 0x06, 0x07,// 0x04 not assigned
						  0x08, 0x09, 0x0A, 0x0B };
    
    /** Translates between HTTP Parameter name and WAP code.
     * @param name HTTP Parameter name (case-<I>in</I>sensitive)
     * @return Encoded WAP Content type. ERROR_CODE if error.
     */ 
    static byte getCode(String name) {
	for (int i=0; i<PARAMETER_NAME.length; i++) {
	    if (name.equalsIgnoreCase(PARAMETER_NAME[i]))
		return PARAMETER_CODE[i];
	}
	// Content type not recognized
	return ERROR_CODE;
    }

    /** Translates between WAP encoded header and HTTP header.
     * @param code Encoded WAP Parameter name.
     * @return HTTP Parameter name. null if error.
     */ 
    static String getName(byte code) throws CodeNotInTableException {
	for (int i=0; i<PARAMETER_CODE.length; i++) {
	    if (code==PARAMETER_CODE[i])
		return new String(PARAMETER_NAME[i]);
	}
	// Content type not recognized
	throw new CodeNotInTableException("Code "+code+" is not assigned to a parameter type.");
    }       

}

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

/** This class contains the WSP encoding of HTTP Content Types.
 * The information is taken from <I>WAP WSP</I>, Appendix A, Table 40.
 * @author Anders Mårtensson
 */
final class ContentTypeTable extends WapTable {
    /** Contains all HTTP Content type names */
    private static final String[] CONTENT_TYPE = { "*/*", "text/*", "text/html", "text/plain",
						   "text/x-hdml", "text/x-ttml", "text/x-vCalender",
						   "text/x-vCard", "text/vnd.wap.wml", "text/vnd.wap.wmlscript",
						   "text/vnd.wap.channel", "Multipart/*", "Multipart/mixed",
						   "Multipart/form-data", "Multipart/byteranges",
						   "multipart/alternative", "application/*", "application/java-vm",
						   "application/x-www-form-urlencoded", "application/x-hdmlc",
						   "application/vnd.wap.wmlc",
						   "application/vnd.wap.wmlscriptc", "application/vnd.wap.channelc",
						   "application/vnd.wap.uaprof",
						   "application/vnd.wap.wtls-ca-certificate",
						   "application/vnd.wap.wtls-user-certificate",
						   "application/x-x509-ca-cert", "application/x-x509-user-cert",
						   "image/*", "image/gif", "image/jpeg", "image/tiff", "image/png",
						   "image/vnd.wap.wbmp", "application/vnd.wap.multipart.*",
						   "application/vnd.wap.multipart.mixed",
						   "application/vnd.wap.multipart.form-data",
						   "application/vnd.wap.multipart.byteranges",
						   "application/vnd.wap.multipart.alternative", "application/xml",
						   "text/xml", "application/vnd.wap.wbxml",
						   "application/x-x968-cross-cert", "application/x-x968-ca-cert",
						   "application/x-user-cert", "text/vnd.wap.si",
						   "application/vnd.wap.sic", "text/vnd.wap.sl",
						   "application/vnd.wap.slc", "text/vnd.wap.co", 
						   "application/vnd.wap.coc", 
						   "application/vnd.wap.multipart.related",
						   "application/vnd.wap.sia" };

    /** Contains all WAP codes for the HTTP Content type names */
    private static final byte[] CONTENT_TYPE_CODE = { 0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07,
						      0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F,
						      0x10, 0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17,
						      0x18, 0x19, 0x1A, 0x1B, 0x1C, 0x1D, 0x1E, 0x1F,
						      0x20, 0x21, 0x22, 0x23, 0x24, 0x25, 0x26, 0x27,
						      0x28, 0x29, 0x2A, 0x2B, 0x2C, 0x2D, 0x2E, 0x2F,
						      0x30, 0x31, 0x32, 0x33, 0x34 };
    
    /** Translates between HTTP Content type and WAP code.
     * @param name HTTP Content type (case-sensitive)
     * @return Encoded WAP Content type. 0xFF if error.
     */ 
    static byte getCode(String name) {
	for (int i=0; i<CONTENT_TYPE.length; i++) {
	    if (name.equals(CONTENT_TYPE[i]))
		return CONTENT_TYPE_CODE[i];
	}
	// Content type not recognized
	return ERROR_CODE;
    }

    /** Translates between WAP encoded header and HTTP header.
     * @param code Encoded WAP Content type.
     * @return HTTP Content type. null if error.
     */ 
    static String getName(byte code) throws CodeNotInTableException {
	for (int i=0; i<CONTENT_TYPE_CODE.length; i++) {
	    if (code==CONTENT_TYPE_CODE[i])
		return new String(CONTENT_TYPE[i]);
	}
	// Content type not recognized
	throw new CodeNotInTableException("Code "+code+" is not assigned to a content type.");
    }       


}

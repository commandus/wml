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

/** This class contains the WSP encoding of HTTP header field names.
 * The information is taken from <I>WAP WSP</I>, Appendix A, Table 39.
 * <P> The class also includes some methods to translate between header
 * names and WAP codes. </P>
 * @author Anders Mårtensson
 */
final class HeaderFieldNameTable extends WapTable {

    /** Contains all HTTP Header Fieled names */
    private static final String[] FIELD_NAME = { "Accept", "Accept-Charset", "Accept-Encoding", "Accept-Language",
					 "Accept-Ranges", "Age", "Allow", "Authorization",
					 "Cache-Control", "Connection", "Content-Base", "Content-Encoding",
					 "Content-Language", "Content-Length", "Content-Location", "Content-MD5",
					 "Content-Range", "Content-Type", "Date", "Etag", "Expires", "From",
					 "Host", "If-Modified-Since", "If-Match", "If-None-Match", "If-Range",
					 "If-Unmodified-Since", "Location", "Last-Modified", "Max-Forwards",
					 "Pragma", "Proxy-Authenticate", "Proxy-Authorization", "Public",
					 "Range", "Referer", "Retry-After", "Server", "Transfer-Encoding",
					 "Upgrade", "User-Agent", "Vary", "Via", "Warning", "WWW-Authenticate",
					 "Content-Disposition", "X-Wap-Application-Id", "X-Wap-Content-URI",
					 "X-Wap-Initiator-URI", "Accept-Application", "Bearer-Indication",
					 "Push-Flag", "Profile", "Profile-Diff", "Profile-Warning"} ;
    /** Contains all Wap codes for the HTTP Header Field names */
    private static final byte[] FIELD_NAME_CODE = { 0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A,
					    0x0B, 0x0C, 0x0D, 0x0E, 0x0F, 0x10, 0x11, 0x12, 0x13, 0x14, 0x15,
					    0x16, 0x17, 0x18, 0x19, 0x1A, 0x1B, 0x1C, 0x1D, 0x1E, 0x1F, 0x20,
					    0x21, 0x22, 0x23, 0x24, 0x25, 0x26, 0x27, 0x28, 0x29, 0x2A, 0x2B,
					    0x2C, 0x2D, 0x2E, 0x2F, 0x30, 0x31, 0x32, 0x33, 0x34, 0x35, 0x36,
					    0x37};

    /** Translates between HTTP header and WAP code.
     * @param name HTTP Header Field name (case-<I>in</I>sensitive)
     * @return Encoded WAP header field. ERROR_CODE if error.
     */ 
    static byte getCode(String name) {
	for (int i=0; i<FIELD_NAME.length; i++) {
	    if (name.equalsIgnoreCase(FIELD_NAME[i]))
		return FIELD_NAME_CODE[i];
	}
	// Header name not recognized
	return ERROR_CODE;
    }

    /** Translates between WAP encoded header and HTTP header.
     * @param code Encoded WAP header field.
     * @return HTTP Header Field name. null if error.
     */ 
    static String getName(byte code) throws CodeNotInTableException {
	for (int i=0; i<FIELD_NAME_CODE.length; i++) {
	    if (code==FIELD_NAME_CODE[i])
		return new String(FIELD_NAME[i]);
	}
	// Header code not recognized
	throw new CodeNotInTableException("Code "+code+" is not assigned to a header.");
    }       

}

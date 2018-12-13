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

/** The Status Code Table contains information about all HTTP Status codes.
 * The information is taken from <I>WAP WSP</I>, Appendix A, Table 36.
 * @author Anders Mårtensson
 */
final class StatusCodeTable extends WapTable {

    /** Contains all HTTP Status codes */
    private static final int[] HTTP_STATUS_CODE = { 100, 101,
					    200, 201, 202, 203, 204, 205, 206,
					    300, 301, 302, 303, 304, 305,
					    400, 401, 402, 403, 404, 405, 406, 407, 408, 409, 410, 411, 412, 413, 414, 415,
					    500, 501, 502, 503, 504, 505 };
    /** Contains all HTTP Status code descriptions */
    private static final String[] STATUS_DESCRIPTION = { "Continue", "Switching protocols",
						 "OK, Success", "Created", "Accepted", "Non-Authorative Information",
						    "No Content", "Reset Content", "Partial Content",
						 "Multiple Choices", "Moved Permanently", "Moved Temporarly", 
						    "See Other", "Not modified", "Use Proxy",
						 "Bad Request", "Unauthorized", "Payment required", "Forbidden",
						    "Not Found", "Method not allowed", "Not Acceptible",
						    "Proxy Authentication required", "Request timeout", "Conflict",
						    "Gone", "Length Required", "Precondition failed",
						    "Request Entity too large", "Request-URI too large",
						    "Unsuported mediatype",
						 "Internal server error", "Not implemented", "Bad gateway",
						    "Service unavailible", "Gateway Timeout",
						    "HTTP version not supported" };
    /** Contains all WAP codes for the HTTP Status codes */
    private static final byte[] WAP_STATUS_CODE = { 0x01, 0x11, 0x20, 0x21, 0x22, 0x23, 0x24, 0x25, 0x26, 0x30, 0x31,
						   0x32, 0x33, 0x34, 0x35, 0x40, 0x41, 0x42, 0x43, 0x44, 0x45, 0x46,
						   0x47, 0x48, 0x49, 0x4A, 0x4B, 0x4C, 0x4D, 0x4E, 0x4F, 0x60,
						   0x61, 0x62, 0x63, 0x64, 0x65 };

    /** Translates between HTTP Status code and WAP code.
     * @param name HTTP Status code
     * @return Encoded WAP Status code. ERROR_CODE if error.
     */ 
    static byte encode(int status) {
	for (int i=0; i<HTTP_STATUS_CODE.length; i++) {
	    if (status==HTTP_STATUS_CODE[i])
		return WAP_STATUS_CODE[i];
	}
	// Status code not recognized
	return ERROR_CODE;
    }

    /** Translates between WAP encoded Status code and HTTP Status code.
     * @param code Encoded WAP Status code.
     * @return HTTP Status code. Negative if error.
     */ 
     static int decode(byte code) throws CodeNotInTableException {
	for (int i=0; i<WAP_STATUS_CODE.length; i++) {
	    if (code==WAP_STATUS_CODE[i])
		return HTTP_STATUS_CODE[i];
	}
	// Status code not recognized
	throw new CodeNotInTableException("Code "+code+" is not assigned to a statuscode.");
    }       
    
    /** Generates a String describing the Status code.
     * @param status HTTP Status code.
     * @return String with Status description. null if error.
     */ 
     static String describe(int status) throws CodeNotInTableException {
	for (int i=0; i<HTTP_STATUS_CODE.length; i++) {
	    if (status==HTTP_STATUS_CODE[i])
		return new String(STATUS_DESCRIPTION[i]);
	}
	// Status code not recognized
	throw new CodeNotInTableException("Number "+status+" is not assigned to a HTTP statuscode.");
    }       

    /** Generates a String describing the Status code.
     * @param code Encoded WAP Status code.
     * @return String with Status description. null if error.
     */ 
     static String describe(byte code) throws CodeNotInTableException {
	for (int i=0; i<WAP_STATUS_CODE.length; i++) {
	    if (code==WAP_STATUS_CODE[i])
		return new String(STATUS_DESCRIPTION[i]);
	}
	// Status code not recognized
	throw new CodeNotInTableException("Code "+code+" is not assigned to a statuscode.");
    }       
    
}


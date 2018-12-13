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

/** The PDU Type Table contains the WSP encoding of Protocol Data Units.
 * The information is taken from <I>WAP WSP</I>, Appendix A, Table 34.
 * @author Anders Mårtensson
 */
final class PDUTypeTable extends WapTable{
   /** Contains all PDU types */
    private static final String[] PDU_NAME = { "Connect", "ConnectReply", "Redirect", "Reply", "Disconnect",
				       "Push", "ConfirmedPush", "Suspend", "Resume", "Get",
				       "Options", "Head", "Delete", "Trace", "Post",
				       "Put" };
    /** Contains all WAP codes for the PDU types */
    private static final byte[] PDU_NAME_CODE = { 0x01, 0x02, 0x03, 0x04, 0x05,
					  0x06, 0x07, 0x08, 0x09, 0x40,
					  0x41, 0x42, 0x43, 0x44, 0x60,
					  0x61 };

    /** Translates PDU type and WAP code.
     * @param name PDU type (case-<I>in</I>sensitive)
     * @return Encoded WAP PDU type. ERROR_CODE if error.
     */ 
    static byte getCode(String name) {
	for (int i=0; i<PDU_NAME.length; i++) {
	    if (name.equalsIgnoreCase(PDU_NAME[i]))
		return PDU_NAME_CODE[i];
	}
	// PDU type not recognized
	return ERROR_CODE;
    }

    /** Translates between WAP codes and PDU types.
     * @param code Encoded WAP PDU.
     * @return PDU type. null if error.
     */ 
    static String getName(byte code) throws CodeNotInTableException {
	for (int i=0; i<PDU_NAME_CODE.length; i++) {
	    if (code==PDU_NAME_CODE[i])
		return new String(PDU_NAME[i]);
	}
	// PDU code not recognized
	throw new CodeNotInTableException("Code "+code+" is not assigned to a PDU.");
    }       


}


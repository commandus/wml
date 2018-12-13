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

/** This class contains the global tokens defined in WBXML
 */
 final class GlobalToken {

     static final byte SWITCH_PAGE=0x00;
     static final byte STRING_END =0x00;
     static final byte END        =0x01;
     static final byte ENTITY     =0x02;
     static final byte STR_I      =0x03;
     static final byte LITERAL    =0x04;
     static final byte EXT_I_0    =0x40;
     static final byte EXT_I_1    =0x41;
     static final byte EXT_I_2    =0x42;
     static final byte PI         =0x43;
     static final byte LITERAL_C  =0x44;
     static final byte EXT_T_0    =(byte)0x80;
     static final byte EXT_T_1    =(byte)0x81;
     static final byte EXT_T_2    =(byte)0x82;
     static final byte STR_T      =(byte)0x83;
     static final byte LITERAL_A  =(byte)0x84;
     static final byte EXT_0      =(byte)0xC0;
     static final byte EXT_1      =(byte)0xC1;
     static final byte EXT_2      =(byte)0xC2;
     static final byte OPAQUE     =(byte)0xC3;
     static final byte LITERAL_AC =(byte)0xC4;

}


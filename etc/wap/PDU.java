/*======================================================================
*
*This file is part of Jwap, the Java Wap Gateway.
*Copyright (C) TietoEnator PerCom AB 
* <http://enator.se/teknik/percom/>
*
* The Jwap Project
*	David Juran & Anders M�rtensson
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

import java.io.*;
import java.net.*;


/**This class is supposed to hold a PDU
   no matter what kind. If there isn't
   any you like, make your own (-:*/
abstract class PDU 
{
    int tid;
    /**If the PDU contains a URL, this field should be used*/
    String URL;
   
    /** Creates a PDU which is popped from in*/
    PDU(int tid)
    {
	this.tid=tid;
    }
    
    abstract Reply_PDU getResponse() throws MalformedURLException;

}	
	
	
    
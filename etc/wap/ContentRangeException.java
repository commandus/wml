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

/**To create the Content-range header, we need to know the isze of the size of the data 
   supplied in this PDU. Since we don't know that until all headers are read, we 
   throw this exception. Then we cancreate the header when we know it*/
class ContentRangeException extends Exception
{
    /**This is the first-byte-pos*/
    final int firstBytePos;
    /**This is the Entity-length*/
    final int entityLength;
   
    /**Creates an exception passing the first-byte-pos first
       and the Enitity-length len*/
    ContentRangeException(int first,
				 int len)
    {
	firstBytePos=first;
	entityLength=len;
    }
}

/* $Id: wbmp.h,v 1.1.1.1 2001/03/20 22:29:49 stephanl Exp $ */
/***************************************************************************
*   QWMLBrowser                                                            *
*   Copyright (C) 2001 by 5nine Wireless Communications (www.5nine.com)    *
*                                                                          *
*   This program is free software; you can redistribute it and/or          *
*   modify it under the terms of the GNU General Public License            *
*   as published by the Free Software Foundation; either version 2         *
*   of the License, or (at your option) any later version.                 *
*                                                                          *
*   This program is distributed in the hope that it will be useful,        *
*   but WITHOUT ANY WARRANTY; without even the implied warranty of         *
*   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the          *
*   GNU General Public License for more details.                           *
*                                                                          *
*   You should have received a copy of the GNU General Public License      *
*   along with this program; if not, write to the Free Software            *
*   Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, *
*   USA.                                                                   *
****************************************************************************/
#include <qimage.h>


int read_wbmp_int (char *buf, int *pos);

void read_wbmp_header(int h, char *buf, int *pos);

static void read_wbmp_image (QImageIO * iio);

static void write_wbmp_image (QImageIO *image);

void addWbmpSupport ();

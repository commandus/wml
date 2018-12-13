/* 
** Copyright (C) 6.6.2000 by Applepie Solutions Ltd.
** http://www.applepiesolutions.com
**
** This program is free software; you can redistribute it and/or modify
** it under the terms of the GNU General Public License as published by
** the Free Software Foundation; either version 2 of the License, or
** (at your option) any later version.
**
** This program is distributed in the hope that it will be useful,
** but WITHOUT ANY WARRANTY; without even the implied warranty of
** MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
** GNU General Public License for more details.
**
** You should have received a copy of the GNU General Public License
** along with this program; if not, write to the Free Software
** Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
**
** wbmp2gif - image converter that converts a wbmp image to a transparent gif
** without using the patented LZW encoding algorithm.
**
** It uses code from 3 other open source c files, which are included here.
**
** 1. wbmp2pix.c is derived from wbmptpbm.c by Terje Sannum 
**    <terje@looplab.com>
**    See Terje's wbmptopbm utilities in:
**    ftp://wuarchive.wustl.edu/graphics/graphics/packages/NetPBM/
**    wbmp2pix is used to convert the WBMP image into a pixmap
**
** 2. pix2gif.c creates a GIF image using a non-lzw encoding algorithm
**    derived from gifcode.c by Michael A. Mayer. See:
**    http://www.danbbs.dk/~dino/whirlgif/gifcode.html
**    pix is used to convert the pixmap into a gif
**
** 3. giftrans.c is exptracted from GIFtrans, 
**    by Andreas Ley <ley@rz.uni-karlsruhe.de>
**    See ftp.rz.uni-karlsruhe.de/pub/net/www/tools/giftrans.c
**    giftrans is used to convert the gif into a transparent gif.
**
** To compile this application:
** gcc -c *.c && gcc -o wbmp2gif *.o
**
**/

#include <stdio.h>

int giftrans(FILE *, FILE *);
unsigned char **readwbmp(FILE *f, int *cols, int *rows);

int	main( int args, char **argv )
{
	int rows, cols, i, j;
	unsigned char **two_dpixmap;
	int *pixmap;
	FILE *fp;

	/* First, we'll convert the data sent to standard input to a pixmap */
	fp = stdin;

	two_dpixmap = readwbmp( fp, &cols, &rows );

	/* Create a temporary file, tmpfile handles everything */

	fp = tmpfile();

	/* Now convert the pixmap to a gif, using pix2gif to write to the
		temporary file */

	pixmap = (int *)malloc( rows * cols * sizeof( int ) );

	for ( i = 0; i < rows; i++ ) for ( j = 0; j < cols; j++ )
		pixmap[ (i*cols)+j ] = two_dpixmap[ i ][ j ];

	for ( i = 0; i < rows; i++ ) free( two_dpixmap[ i ] );
	free( two_dpixmap );

	pix2gif( fp, pixmap, cols, rows );

	free( pixmap );

	/* rewind the temporary file, and use giftrans to convert its contents
	from GIF87 format to GIF89 format, and make it transparent. We then
	write the result to standard out */

	rewind( fp );
	giftrans( fp, stdout );

	fclose( fp );

	return 0;
}

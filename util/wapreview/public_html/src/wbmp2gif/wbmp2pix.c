/* wbmptopbm.c - convert a wbmp file to a portable bitmap
**
** Copyright (C) 1999 Terje Sannum <terje@looplab.com>.
**
** Permission to use, copy, modify, and distribute this software and its
** documentation for any purpose and without fee is hereby granted, provided
** that the above copyright notice appear in all copies and that both that
** copyright notice and this permission notice appear in supporting
** documentation.  This software is provided "as is" without express or
** implied warranty.
*/

#include <stdio.h>

int readint(FILE *f) {
  int c=0, pos=0, sum=0;
  do {
    c = fgetc(f);
    sum = (sum << 7*pos++) | (c & 0x7f);
  } while(c & 0x80);
  return sum;
}

void readheader(int h, FILE *f) {
  int c,i;
  switch(h & 0x60) {
  case 0x00:
    /* Type 00: read multi-byte bitfield */
    do c=fgetc(f); while(c & 0x80);
    break;
  case 0x60:
    /* Type 11: read name/value pair */
    for(i=0; i < (h & 0x70) >> 4 + (h & 0x0f); i++) c=fgetc(f);
    break;
  }
}

unsigned char **readwbmp(FILE *f, int *cols, int *rows) {
  int i,j,k,row,c;
  unsigned char **image;
  /* Type */
  c = readint(f);
  if(c != 0) fputs("Unsupported WBMP type", stderr);
  /* Headers */
  c = fgetc(f); /* FixHeaderField */
  while(c & 0x80) { /* ExtHeaderFields */
    c = fgetc(f);
    readheader(c, f);
  }
  /* Geometry */
  *cols = readint(f);
  *rows = readint(f);

  image = (unsigned char **)malloc( *rows * sizeof( char* ) );
  for ( i = 0; i < *rows; i++ ) image[i] = (unsigned char *)malloc( *cols * sizeof( char ) );

  /* read image */
  row = *cols/8;
  if(*cols%8) row +=1;
  for(i=0; i<*rows; i++) {
    for(j=0; j<row; j++) {
      c=fgetc(f);
      for(k=0; k<8 && j*8+k<*cols; k++) {
	image[i][j*8+k] = c & (0x80 >> k) ? 255 : 0;
      }
    }
  }
  return image;
}

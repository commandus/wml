/*
** Extracted from: GIFtrans
**
** Copyright (C) 24.2.94 by Andreas Ley <ley@rz.uni-karlsruhe.de>
** See ftp.rz.uni-karlsruhe.de/pub/net/www/tools/giftrans.c
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
*/
#define	X11		/* When using X Window System */
#undef	OPENWIN		/* When using Open Windows */
#undef	X386		/* When using XFree86 with FreeBSD/386BSD */
#undef	OS2		/* When using IBM C/C++ 2.0 */
#ifndef	MSDOS	/* required for TurboC 1.0 */
#undef	MSDOS		/* When using Borland C (maybe MSC too) */
#endif

#ifndef OS2_OR_MSDOS
#ifdef OS2
#define OS2_OR_MSDOS
#endif /* OS2 */
#ifdef MSDOS
#define OS2_OR_MSDOS
#endif /* MSDOS */
#endif /* OS2_OR_MSDOS */

char copyright[] = "@(#)Copyright (C) 1994 by Andreas Ley (ley@rz.uni-karlsruhe.de)";
char sccsid[] = "@(#)GIFtrans v1.12.2 - Transpose GIF files";

#ifndef RGBTXT
#ifdef X11
#define	RGBTXT	"/usr/lib/X11/rgb.txt"
#else /* X11 */
#ifdef OPENWIN
#define	RGBTXT	"/usr/openwin/lib/rgb.txt"
#else /* OPENWIN */
#ifdef X386
#define	RGBTXT	"/usr/X386/lib/X11/rgb.txt"
#else /* X386 */
#ifdef OS2_OR_MSDOS
#define	RGBTXT	"rgb.txt"
#else /* OS2_OR_MSDOS */
#define	RGBTXT	"";
#endif /* OS2_OR_MSDOS */
#endif /* X386 */
#endif /* OPENWIN */
#endif /* X11 */
#endif /* RGBTXT */

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <errno.h>
#ifndef OS2_OR_MSDOS
#include <unistd.h>
#include <ctype.h>
#include <sys/param.h>
#else /* OS2_OR_MSDOS */
#include <fcntl.h>
#ifdef OS2
#include <io.h>
#endif /* OS2 */
#include "getopt.c"
#endif /* OS2_OR_MSDOS */

#ifndef MAXPATHLEN
#define MAXPATHLEN 256
#endif /* MAXPATHLEN */

#ifndef FALSE
#define	FALSE	(0)		/* This is the naked Truth */
#define	TRUE	(1)		/* and this is the Light */
#endif

#define	SUCCESS	(0)
#define	FAILURE	(1)

struct entry {
	struct entry	*next;
	char		*name;
	int		red;
	int		green;
	int		blue;
	} *root;

#define	NONE	(-1)
#define	OTHER	(-2)
#define	RGB	(-3)

struct color {
	int		index;
	int		red;
	int		green;
	int		blue;
	} bc,tc,tn,go,gn;

static char	*image,*comment;
static int	skipcomment,list,verbose,output,debug;
static long int	pos;

static char	rgbtxt[] = RGBTXT, *rgb = rgbtxt;
static char	true[] = "True";
static char	false[] = "False";

#define	readword(buffer)	((buffer)[0]+256*(buffer)[1])
#define	readflag(buffer)	((buffer)?true:false)
#define	hex(c)			('a'<=(c)&&(c)<='z'?(c)-'a'+10:'A'<=(c)&&(c)<='Z'?(c)-'A'+10:(c)-'0')


void dump(adr,data,len)
long int	adr;
unsigned char	*data;
size_t		len;
{
	int	i;

	while (len>0) {
		for (i=adr%16;i<16&&len>0;i++,adr++,data++,len--);
	}
}



void writedata(dest,data,len)
FILE		*dest;
unsigned char	*data;
size_t		len;
{
	unsigned char	size;

	while (len) {
		size=len<256?len:255;
		(void)fwrite((void *)&size,1,1,dest);
		(void)fwrite((void *)data,(size_t)size,1,dest);
		data+=size;
		len-=size;
	}
	size=0;
	(void)fwrite((void *)&size,1,1,dest);
}


void skipdata(src)
FILE	*src;
{
	unsigned char	size,buffer[256];

	do {
		pos=ftell(src);
		(void)fread((void *)&size,1,1,src);
		if (debug)
			dump(pos,&size,1);
		if (debug) {
			pos=ftell(src);
			(void)fread((void *)buffer,(size_t)size,1,src);
			dump(pos,buffer,(size_t)size);
		}
		else
			(void)fseek(src,(long int)size,SEEK_CUR);
	} while (!feof(src)&&size>0);
}


void transblock(src,dest)
FILE	*src;
FILE	*dest;
{
	unsigned char	size,buffer[256];

	pos=ftell(src);
	(void)fread((void *)&size,1,1,src);
	if (debug)
		dump(pos,&size,1);
	if (output)
		(void)fwrite((void *)&size,1,1,dest);
	pos=ftell(src);
	(void)fread((void *)buffer,(size_t)size,1,src);
	if (debug)
		dump(pos,buffer,(size_t)size);
	if (output)
		(void)fwrite((void *)buffer,(size_t)size,1,dest);
}


void dumpcomment(src)
FILE	*src;
{
	unsigned char	size,buffer[256];
	size_t i;

	pos=ftell(src);
	(void)fread((void *)&size,1,1,src);
	if (debug)
		dump(pos,&size,1);
	(void)fread((void *)buffer,(size_t)size,1,src);
	if (debug)
		dump(pos+1,buffer,(size_t)size);
	(void)fseek(src,(long int)pos,SEEK_SET);
}


void transdata(src,dest)
FILE	*src;
FILE	*dest;
{
	unsigned char	size,buffer[256];

	do {
		pos=ftell(src);
		(void)fread((void *)&size,1,1,src);
		if (debug)
			dump(pos,&size,1);
		if (output)
			(void)fwrite((void *)&size,1,1,dest);
		pos=ftell(src);
		(void)fread((void *)buffer,(size_t)size,1,src);
		if (debug)
			dump(pos,buffer,(size_t)size);
		if (output)
			(void)fwrite((void *)buffer,(size_t)size,1,dest);
	} while (!feof(src)&&size>0);
}


int giftrans(src,dest)
FILE	*src;
FILE	*dest;
{
	unsigned char	buffer[3*256],lsd[7],gct[3*256],gce[5];
	unsigned int	cnt,cols,size,gct_size,gct_delay,gce_present;
	struct entry	*rgbptr;
	output = 1;

	getindex( &tc, "#ffffff" );

	/* Header */
	pos=ftell(src);
	(void)fread((void *)buffer,6,1,src);
	if (strncmp((char *)buffer,"GIF",3)) {
		return(1);
	}
	if (output) {
		if (!strncmp((char *)buffer,"GIF87a",6))
			buffer[4]='9';
		(void)fwrite((void *)buffer,6,1,dest);
	}

	/* Logical Screen Descriptor */
	pos=ftell(src);
	(void)fread((void *)lsd,7,1,src);

	/* Global Color Table */
	gct_delay=FALSE;
	if (lsd[4]&0x80) {
		gct_size=2<<(lsd[4]&0x7);
		pos=ftell(src);
		(void)fread((void *)gct,gct_size,3,src);
		if (go.index==RGB)
			for(cnt=0;cnt<gct_size&&go.index==RGB;cnt++)
				if (gct[3*cnt]==go.red&&gct[3*cnt+1]==go.green&&gct[3*cnt+2]==go.blue)
					go.index=cnt;
		if (go.index>=0) {
			if (gn.index>=0) {
				gn.red=gct[3*gn.index];
				gn.green=gct[3*gn.index+1];
				gn.blue=gct[3*gn.index+2];
			}
			gct[3*go.index]=gn.red;
			gct[3*go.index+1]=gn.green;
			gct[3*go.index+2]=gn.blue;
		}
		if (bc.index==RGB)
			for(cnt=0;cnt<gct_size&&bc.index==RGB;cnt++)
				if (gct[3*cnt]==bc.red&&gct[3*cnt+1]==bc.green&&gct[3*cnt+2]==bc.blue)
					bc.index=cnt;
		if (bc.index>=0)
			lsd[5]=bc.index;
		if (tc.index==RGB)
			for(cnt=0;cnt<gct_size&&tc.index==RGB;cnt++)
				if (gct[3*cnt]==tc.red&&gct[3*cnt+1]==tc.green&&gct[3*cnt+2]==tc.blue)
					tc.index=cnt;
		if (tc.index==OTHER)
			tc.index=lsd[5];
		if (tn.index>=0) {
			tn.red=gct[3*tn.index];
			tn.green=gct[3*tn.index+1];
			tn.blue=gct[3*tn.index+2];
		}
		if (tn.index!=NONE)
			gct_delay=TRUE;
	}
	if (output)
		(void)fwrite((void *)lsd,7,1,dest);
	if (lsd[4]&0x80) {
		if (output&&(!gct_delay))
			(void)fwrite((void *)gct,gct_size,3,dest);
	}

	gce_present=FALSE;
	do {
		pos=ftell(src);
		(void)fread((void *)buffer,1,1,src);
		switch (buffer[0]) {
		case 0x2c:	/* Image Descriptor */
			(void)fread((void *)(buffer+1),9,1,src);
			/* Write Graphic Control Extension */
			if (tc.index>=0||gce_present) {
				if (!gce_present) {
					gce[0]=0;
					gce[1]=0;
					gce[2]=0;
				}
				if (tc.index>=0) {
					gce[0]|=0x01;	/* Set Transparent Color Flag */
					gce[3]=tc.index;	/* Set Transparent Color Index */
				}
				else if (gce[0]&0x01)
					tc.index=gce[3];	/* Remember Transparent Color Index */
				gce[4]=0;
				if (tc.index>=0&&(!(buffer[8]&0x80))) { /* Transparent Color Flag set and no Local Color Table */
					gct[3*tc.index]=tn.red;
					gct[3*tc.index+1]=tn.green;
					gct[3*tc.index+2]=tn.blue;
				}
				if (output&&gct_delay) {
					(void)fwrite((void *)gct,gct_size,3,dest);
					gct_delay=FALSE;
				}
				if (output) {
					(void)fputs("\041\371\004",dest);
					(void)fwrite((void *)gce,5,1,dest);
				}
			}
			if (output&&gct_delay) {
				(void)fwrite((void *)gct,gct_size,3,dest);
				gct_delay=FALSE;
			}
			/* Write Image Descriptor */

			if (output)
				(void)fwrite((void *)buffer,10,1,dest);
			/* Local Color Table */
			if (buffer[8]&0x80) {
				size=2<<(buffer[8]&0x7);
				pos=ftell(src);
				(void)fread((void *)buffer,size,3,src);
				if (tc.index>=0) { /* Transparent Color Flag set */
					buffer[3*tc.index]=tn.red;
					buffer[3*tc.index+1]=tn.green;
					buffer[3*tc.index+2]=tn.blue;
				}
				if (output)
					(void)fwrite((void *)buffer,size,3,dest);
			}
			/* Table Based Image Data */
			pos=ftell(src);
			(void)fread((void *)buffer,1,1,src);
			if (output)
				(void)fwrite((void *)buffer,1,1,dest);
			transdata(src,dest);
			gce_present=FALSE;
			break;
		case 0x3b:	/* Trailer */
			if (comment&&*comment&&output) {
				(void)fputs("\041\376",dest);
				writedata(dest,(unsigned char *)comment,strlen(comment));
			}
			if (output)
				(void)fwrite((void *)buffer,1,1,dest);
			break;
		case 0x21:	/* Extension */
			(void)fread((void *)(buffer+1),1,1,src);
			switch (buffer[1]) {
			case 0x01:	/* Plain Text Extension */
				if (output&&gct_delay) {
					(void)fwrite((void *)gct,gct_size,3,dest);
					gct_delay=FALSE;
				}
				if (output)
					(void)fwrite((void *)buffer,2,1,dest);
				transblock(src,dest);
				transdata(src,dest);
				break;
			case 0xf9:	/* Graphic Control Extension */
				(void)fread((void *)(buffer+2),1,1,src);
				size=buffer[2];
				(void)fread((void *)gce,size,1,src);
	
				pos=ftell(src);
				(void)fread((void *)buffer,1,1,src);
				if (debug)
					dump(pos,buffer,1);
				gce_present=TRUE;
				break;
			case 0xfe:	/* Comment Extension */
				if (skipcomment)
					skipdata(src);
				else {
					if (output&&gct_delay) {
						(void)fwrite((void *)gct,gct_size,3,dest);
						gct_delay=FALSE;
					}
					if (output)
						(void)fwrite((void *)buffer,2,1,dest);
					transdata(src,dest);
				}
				break;
			case 0xff:	/* Application Extension */
				if (output&&gct_delay) {
					(void)fwrite((void *)gct,gct_size,3,dest);
					gct_delay=FALSE;
				}
				if (output)
					(void)fwrite((void *)buffer,2,1,dest);
				transblock(src,dest);
				transdata(src,dest);
				break;
			default:
				if (output&&gct_delay) {
					(void)fwrite((void *)gct,gct_size,3,dest);
					gct_delay=FALSE;
				}
				if (output)
					(void)fwrite((void *)buffer,2,1,dest);
				transblock(src,dest);
				transdata(src,dest);
				break;
			}
			break;
		default:
			return(1);
		}
	} while (buffer[0]!=0x3b&&!feof(src));
	return(buffer[0]==0x3b?SUCCESS:FAILURE);
}



int getindex(c,arg)
struct color	*c;
char	*arg;
{
	struct entry	*ptr;

	if ('0'<=*arg&&*arg<='9')
		c->index=atoi(arg);
	else if (*arg=='#') {
		if (strlen(arg)==4) {
			c->index=RGB;
			c->red=hex(arg[1])<<4;
			c->green=hex(arg[2])<<4;
			c->blue=hex(arg[3])<<4;
		}
		else if (strlen(arg)==7) {
			c->index=RGB;
			c->red=(hex(arg[1])<<4)+hex(arg[2]);
			c->green=(hex(arg[3])<<4)+hex(arg[4]);
			c->blue=(hex(arg[5])<<4)+hex(arg[6]);
		}
		else {
			return(FAILURE);
		}
	}
	else {
		for (ptr=root;ptr&&c->index!=RGB;ptr=ptr->next)
			if (!strcmp(ptr->name,arg)) {
				c->index=RGB;
				c->red=ptr->red;
				c->green=ptr->green;
				c->blue=ptr->blue;
			}
		if (c->index!=RGB) {
			return(FAILURE);
		}
	}
	return(SUCCESS);
}


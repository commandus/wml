/* $Id: wbmp.cpp,v 1.3 2001/03/21 20:58:50 stephanl Exp $ */
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


int read_wbmp_int (char *buf, int *pos)
{
        int sum=0;
        int offset=0;
        int c=0;
        do {
                c=buf[(*pos)++];
                sum=(sum <<7*offset++) | (c & 0x7f);
        } while (c & 0x80);
        return sum;
}

void read_wbmp_header(int h, char *buf, int *pos)
{
        int c,i;

        switch (h & 0x60) {
        case 0x00 : /* Type 00 : read multi-byte bitfield */
                do (*pos)++;
                while (buf[*pos] & 0x80);
                //do {} while (buf[(*pos)++] & 0x80);
                break;
        case 0x60 : /* type 11: read name/value pair */
                // could be reduce
                //(*pos)=(*pos)+(h & 0x70) >> 4 + (h & 0x0f);

                for (i=0; i< (h & 0x70) >> 4 + (h & 0x0f); i++)
                        (*pos)++;
                break;
        }
}

#include "back.xpm"

static void read_wbmp_image (QImageIO * iio)
{
        qDebug ("read wbmp");
        //QPixmap pix (back) ;
        //iio->setImage(pix.convertToImage());
        //iio->setStatus (0);
        //return ;
        // construct the QImageIO with the wmbp file

        // i should better use streams  like for the bmp file
        // maybe in the next version
        QIODevice *d=iio->ioDevice();
        QImage image;
        d->at(0);
        // rely on the fact that a wbmp should not be huge
        char buf[d->size()+1];
        buf[d->size()]='\0';
        qDebug ("size %d",d->size());

        if (d->readBlock (buf,d->size())!=d->size()) {
                qDebug ("pb de lecture");
                iio->setStatus (-1);
                return;
        }

        int pos=0;

        int tyty;

        // check wbmp type should be 0
        //if ((tyty==read_wbmp_int(buf,&pos))!=0)
        if (read_wbmp_int(buf,&pos)!=0) {
                //      qDebug (" wbmp file ? %d", tyty);
                iio->setStatus(-1); // not a valid wbmp
                qDebug ("Not a wbmp file");
                return;
        }

        qDebug ("pos %d", pos);

        // Headers
        int c;
        c=buf[pos++];

        while (c & 0x80) {
                c=buf[pos++];
                read_wbmp_header(c,buf,&pos);
        }


        qDebug ("pos %d", pos);

        int col, row;
        col=read_wbmp_int (buf,&pos);
        row=read_wbmp_int (buf,&pos);


        qDebug ("col %d",col);
        qDebug ("row %d",row);

        qDebug ("pos %d",pos);


        image.create(col,row,1,0,QImage::BigEndian);

        if (image.isNull()) {
                qDebug ("Image is null");
                iio->setStatus (-1);
                return;
        }

        char bitmap[d->size()-pos];


        memset (bitmap,0,(d->size()-pos)); // white
        //memset (bitmap,1,15);

        //memset (bitmap+15+15,0,15);

        memcpy (bitmap, buf+pos, d->size()-pos);



        QImage toto((uchar *)(bitmap),col,row,1,0,2,QImage::BigEndian);
        toto.setColor (1,qRgb(255,255,255));
        toto.setColor (0,qRgb(0,0,0));
        //toto.invertPixels();
        iio->setImage (toto);
        //iio->setImage (image);



        iio->setStatus(0); // tells that s ok
}

// i don t need to write but will be implement soon

static void write_wbmp_image (QImageIO *image)
{
        image->ioDevice();

        image->setStatus(0); // tells that s ok ne fct pas ici
}


//add the wbmp support to QT libs
//QImageIO::defineIOHandler( "WBMP", "^\0", "0",read_wbmp_image, write_wbmp_image );


void addWbmpSupport ()
{
        // not the right regular expression
        // seems to match all the files
        QImageIO::defineIOHandler( "WBMP", "^\0", "0",read_wbmp_image, write_wbmp_image);
}

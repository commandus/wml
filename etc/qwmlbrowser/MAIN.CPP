/* $Id: main.cpp,v 1.3 2001/03/21 20:58:50 stephanl Exp $ */
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


#include <iostream>
#include <qapplication.h>
//#include <qpeapplication.h>
#include <qwidget.h>
#include <qmainwindow.h>
#include <qtextbrowser.h>
#include <qmime.h>
#include <qlineedit.h>
#include <qscrollview.h>
#include <qvbox.h>
#include <qlabel.h>
#include <qhbox.h>
#include <qpainter.h>
#include <qfont.h>
#include <qfontmetrics.h>
#include "qbrowser.h"
#include "wbmp.h"
#include <qwidget.h>
int main( int argc, char **argv )
{



        QApplication a( argc, argv );
        //QPEApplication a(argc, argv); // for qpe application
        QBrowser *w =new QBrowser();
        addWbmpSupport();

#if 0
        QImage test;
        QStringList list=test.outputFormatList () ;

        for ( QStringList::Iterator it = list.begin(); it != list.end(); ++it )
                qDebug( "%s \n", (*it).latin1() );
#endif

        a.setMainWidget (w);
        //w->setGeometry (0,20,240,280); // for the iPaq

        w->setGeometry (500,0,340,400);


        w->show();
        a.connect(&a, SIGNAL(lastWindowClosed()), &a, SLOT(quit()));

        return a.exec();
}

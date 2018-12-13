/* $Id: qbrowser.h,v 1.2 2001/03/21 20:58:50 stephanl Exp $ */
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
#ifndef _QBROWSER_H
#define _QBROWSER_H
#include <qmainwindow.h>
#include <qstring.h>
#include "qwmlbrowser.h"
#include <qcombobox.h>
#include <qfile.h>

#define CONF_FILE ".wmlbrowserrc"
#define MAX_URL_LENGTH 255
#define STR_CONF_HISTORY "[LastLinks]"

class QBrowser : public QMainWindow
{
        Q_OBJECT
public:
        QBrowser (QWidget *parent=0, const char *name=0);
        ~QBrowser ();




protected:
        QList <QString> *history;
        QList <QString> *last_sites;

        QWmlBrowser * browser;
        QComboBox *comboList;

        void getLinks();
        void saveLinks();
        QString getHomeDir () const;


        void emptyQList (QList <QString> *);


        int backId, forwardId;


signals:
        void addUrl2Combolist (const QString &);
        /*
        void textChanged ();
        //  void backAvailable(bool state);
        //  void forwardAvailable (bool state);
        */

private  slots:
        void about ();
        void back();
        void forward();
        void slotBackAvailable (bool state);
        void slotForwardAvailable (bool state);
        void home();
        void comboListSelected(const QString &);
        void reload ();
        void slotAddUrl2Combolist (const QString &);

        void quit();
};

#endif

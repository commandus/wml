/* $Id: qwmlbrowser.h,v 1.3 2001/03/21 20:58:50 stephanl Exp $ */
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
#ifndef _QWMLBROWSER_H
#define _QWMLBROWSER_H
#include <iostream>
#include <qapplication.h>
#include <qwidget.h>
#include <qmainwindow.h>
#include <qmime.h>
#include <qlineedit.h>
#include <qscrollview.h>
#include <qpainter.h>
#include <qfont.h>
#include <qfontmetrics.h>
#include <qqueue.h>
#include "qsimplerichtextbis.h"
#include <qstylesheet.h>
#include <qregion.h>
#include <qvaluestack.h>
#include <qtextbrowser.h>
#include <qmime.h>



class QWmlBrowser : public QScrollView
{
        Q_OBJECT
public:
        QWmlBrowser  (QWidget *parent=0, const char *name=0);
        ~QWmlBrowser();

        void render (QPainter *P);



        // a deplacer dans une autre classe
        //  void renderText (int x, int y, const QRect& rect, const QString& text, QPainter *p);

        void viewportMouseReleaseEvent( QMouseEvent* e );

        void viewportMousePressEvent( QMouseEvent* e );


        void viewportMouseMoveEvent (QMouseEvent* e);

        // should be slots
        // because they are by qbrowser
        void back();
        void forward();
        void reload();
        void home();


        QString text() const;

        //public slots:
        virtual void setText (const QString & test, const QString & context);

        //virtual void setSource ( const QString & name );
        virtual void setSource (const QString& name, bool isClicked=FALSE);
        QString source () const;

        virtual QString context () const
        {
                return context_;
        };


        QMimeSourceFactory * test;

        QMimeSourceFactory *  mimeSourceFactory () const;


public slots:
        void slotTextChanged();
        void update();

signals:
        void addUrl2Combolist (const QString &);
        void highlighted(const QString & );   // connecter ca sur une fct
        // et non l utiliser dans le mouseMove --> plus efficace

        void textChanged();
        void backAvailable (bool state);
        void forwardAvailable (bool state);

protected:

        //  void paintEvent(QPaintEvent *);

        void drawContents ( QPainter * p, int clipx, int clipy, int clipw, int cliph )  ;
        void addChild (QObject *);

        QString homeUrl;
        QString context_;

        // i should have one function be able to handle QList <type>
        void emptyListQObject (QList <QObject> *);
        void emptyListQString (QList <QString> *);

        // these datas may be gathered in another class
        // if there are numerous
        // text to display
        QString _original_text;
        QString highlightedLink;

        QString currentSite;

        // will be replace by a list to handle cards (soon)
        QSimpleRichTextBis *tmp;

        int oldWidth, oldHeight;

        QString oldDirPath; // just needed to handle the relative links
        // could be replace by looking at filePath in the MimeSourceFactory

        QValueStack <QString> stack;
        QValueStack <QString> forwardStack;

        // taken from qtextview
        QString curmain;
        QString curmark;


        QString buttonDown; // needed ?

        // liste contenant tous les objets necessaires au rendering d une page WML
        QList <QObject> *child;


        QString anchorAt(const QPoint& pos);
        void scrollToAnchor (const QString& name, QSimpleRichTextBis* );

};

#endif

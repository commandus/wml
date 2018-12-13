/* $Id: qsimplerichtextbis.h,v 1.2 2001/03/21 20:58:50 stephanl Exp $ */
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
/****************************************************************************
** $Id: qsimplerichtextbis.h,v 1.2 2001/03/21 20:58:50 stephanl Exp $
**
** Definition of the QSimpleRichText class
**
** Created : 990101
**
** Copyright (C) 1992-2000 Trolltech AS.  All rights reserved.
**
** This file is part of the kernel module of the Qt GUI Toolkit.
**
** This file may be distributed under the terms of the Q Public License
** as defined by Trolltech AS of Norway and appearing in the file
** LICENSE.QPL included in the packaging of this file.
**
** This file may be distributed and/or modified under the terms of the
** GNU General Public License version 2 as published by the Free Software
** Foundation and appearing in the file LICENSE.GPL included in the
** packaging of this file.
**
** Licensees holding valid Qt Enterprise Edition or Qt Professional Edition
** licenses may use this file in accordance with the Qt Commercial License
** Agreement provided with the Software.
**
** This file is provided AS IS with NO WARRANTY OF ANY KIND, INCLUDING THE
** WARRANTY OF DESIGN, MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.
**
** See http://www.trolltech.com/pricing.html or email sales@trolltech.com for
**   information about Qt Commercial License Agreements.
** See http://www.trolltech.com/qpl/ for QPL licensing information.
** See http://www.trolltech.com/gpl/ for GPL licensing information.
**
** Contact info@trolltech.com if any conditions of this licensing are
** not clear to you.
**
**********************************************************************/

// the same as QSimpleRichText
// but i add a richText function needed by scrollToAnchor
// because the original class has the member QRichText private
// so i can t add my function using inheritance


#include "qrichtext_p.h"

#ifndef QSIMPLERICHTEXTBIS_H
#define QSIMPLERICHTEXTBIS_H

#ifndef QT_H
#include "qnamespace.h"
#include "qstring.h"
#include "qregion.h"
#endif // QT_H

#ifndef QT_NO_RICHTEXTBIS

class QPainter;
class QWidget;
class QStyleSheet;
class QBrush;
class QMimeSourceFactory;
class QSimpleRichTextData;


class Q_EXPORT QSimpleRichTextBis
{
public:
        QSimpleRichTextBis( const QString& text, const QFont& fnt,
                            const QString& context = QString::null, const QStyleSheet* sheet = 0);
        QSimpleRichTextBis( const QString& text, const QFont& fnt,
                            const QString& context,  const QStyleSheet* sheet,
                            const QMimeSourceFactory* factory, int verticalBreak = -1,
                            const QColor& linkColor = Qt::blue, bool linkUnderline = TRUE );
        ~QSimpleRichTextBis();

        void setWidth( int );
        void setWidth( QPainter*, int );
        int width() const;
        int widthUsed() const;
        int height() const;
        void adjustSize();

        void draw( QPainter*,  int x, int y, const QRegion& clipRegion,
                   const QPalette& pal, const QBrush* paper = 0) const;

        void draw( QPainter*,  int x, int y, const QRegion& clipRegion,
                   const QColorGroup& cg, const QBrush* paper = 0) const;

        QString context() const;
        QString anchorAt( const QPoint& pos ) const;
        QString anchor( QPainter* p, const QPoint& pos ); // remove in 3.0

        bool inText( const QPoint& pos ) const;

        // member added
        QRichText* richText() const;

private:
        QSimpleRichTextData* d;
};

#endif // QT_NO_RICHTEXTBIS

#endif // QSIMPLERICHTEXTBIS_H

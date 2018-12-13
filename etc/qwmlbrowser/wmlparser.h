/* $Id: wmlparser.h,v 1.2 2001/03/21 20:58:50 stephanl Exp $ */
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
** $Id: wmlparser.h,v 1.2 2001/03/21 20:58:50 stephanl Exp $
**
** Copyright (C) 1992-2000 Trolltech AS.  All rights reserved.
**
** This file is part of an example program for Qt.  This example
** program may be used, distributed and modified without limitation.
**
*****************************************************************************/
#include <qxml.h>
#include <qstringlist.h>
#include <qlist.h>
class WmlHandler : public QXmlDefaultHandler
{
public:
        WmlHandler();
        virtual ~WmlHandler();

        // return the list of quotes
        QList <QString> card();
        // after should be a list of Card

        // return the error protocol if parsing failed
        QString errorProtocol();

        // overloaded handler functions
        bool startDocument();
        bool startElement( const QString& namespaceURI, const QString& localName, const QString& qName, const QXmlAttributes& atts );
        bool endElement( const QString& namespaceURI, const QString& localName, const QString& qName );
        bool characters( const QString& ch );

        QString errorString();

        bool error ( const QXmlParseException & );

        bool fatalError( const QXmlParseException& exception );

        void printTmp();

        QString getWmlParsed();

private:
        QList <QString> cardList;
        // after should be a list of Card
        QString errorProt;

        QString tmp;

        QString tmpLink; // for handling the wml anchor tag

        enum State {
                StateInit,
                StateDocument,
                StateWml,
                StateNewCard,
                StateLine,
                StateHeading,
                StateP,
                StateAnchor // used
        };
        State state;
};

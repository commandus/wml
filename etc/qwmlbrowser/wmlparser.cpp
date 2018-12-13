/* $Id: wmlparser.cpp,v 1.2 2001/03/21 20:58:50 stephanl Exp $ */
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
** $Id: wmlparser.cpp,v 1.2 2001/03/21 20:58:50 stephanl Exp $
**
** Copyright (C) 1992-2000 Trolltech AS.  All rights reserved.
**
** This file is part of an example program for Qt.  This example
** program may be used, distributed and modified without limitation.
**
*****************************************************************************/
#include "wmlparser.h"

WmlHandler::WmlHandler()
{}



WmlHandler::~WmlHandler()
{}

// just for testing purpose

QString WmlHandler::getWmlParsed()
{
        return tmp;
}

QList <QString>  WmlHandler::card()
{
        return cardList;
}


QString WmlHandler::errorProtocol()
{
        return errorProt;
}


bool WmlHandler::startDocument()
{
        // at the beginning of parsing: do some initialization
        cardList.clear();
        errorProt = "";
        state = StateInit;

        return TRUE;
}


bool WmlHandler::startElement( const QString&, const QString& localName, const QString& qName, const QXmlAttributes& atts )
{
        //    qDebug ("start Element ------------> %s %s \n", qName.latin1(), localName.latin1());


        int i;
        //  for (i=0;i<atts.length();i++)
        //    qDebug ("Attributes %s %s", atts.qName(i).latin1(),atts.value(atts.qName(i)).latin1());


        if (qName=="wml")
                state=StateWml;

        if (qName=="p") {
                tmp+="<p";
                for (int i=0; i<atts.length();i++) {
                        if (atts.qName(i)=="align") {
                                if (atts.value(atts.qName(i))=="left")
                                        tmp+=" align=left ";

                                if (atts.value(atts.qName(i))=="right")
                                        tmp+=" align=right ";

                                if (atts.value(atts.qName(i))=="center")
                                        tmp+=" align=center ";
                        }


                        if (atts.qName(i)=="mode")
                                qDebug ("Mode attributes not handled");
                }
                tmp+=">";
        }


        if (qName=="small")
                tmp+="<small>";

        if (qName=="strong")
                tmp+="<strong>";

        if (qName=="i")
                tmp+="<i>";

        if (qName=="b")
                tmp+="<b>";

        if (qName=="u")
                tmp+="<u>";

        if (qName=="big")
                tmp+="<big>";

        if (qName=="em")
                tmp+="<em>";


        if (qName=="br")
                tmp+="<br>";

        // img tag

        if (qName=="img") {

                tmp+="<img ";
                for (int i=0;i<atts.length();i++) {
                        if (atts.qName(i)=="alt")
                                qDebug ("img alt not supported");

                        // attenton different si localsrc contient qqch
                        if (atts.qName(i)=="src")
                                tmp+="src="+atts.value(atts.qName(i))+ " ";

                        if (atts.qName(i)=="localsrc")
                                qDebug ("img localsrc nor supported");

                        if (atts.qName(i)=="vspace")
                                qDebug ("img alt not supported");

                        if (atts.qName(i)=="hspace")
                                qDebug ("img alt not supported");

                        if (atts.qName(i)=="align") {
                                if (atts.value(atts.qName(i))=="left")
                                        tmp+=" align=left ";

                                if (atts.value(atts.qName(i))=="right")
                                        tmp+=" align=right ";

                                if (atts.value(atts.qName(i))=="center")
                                        tmp+=" align=center ";
                        }


                        if (atts.qName(i)=="height")
                                tmp+=" height="+atts.value(atts.qName(i))+ " ";

                        if (atts.qName(i)=="width")
                                tmp+=" height="+atts.value(atts.qName(i))+ " ";

                }
                //tmp+=">";
        }


        // links and anchors <a> <anchor>

        if (qName=="a") {
                tmp+="<a ";

                for (int i=0; i<atts.length();i++) {

                        if (atts.qName(i)=="href")
                                tmp+="href=\""+atts.value(atts.qName(i)) +"\" ";

                        if (atts.qName(i)=="title")
                                qDebug ("A title Not supported");

                        if (atts.qName(i)=="accesskey")
                                qDebug ("A accesskey Not supported");
                }
                tmp+=">";

        }

        if (qName=="anchor")
                state=StateAnchor;


        if (qName=="go") {
                if (state==StateAnchor) {
                        state=StateWml;
                        tmp+="<a ";

                        for (int i=0; i<atts.length();i++) {
                                if (atts.qName(i)=="href")
                                        tmp+=" href=\""+atts.value(atts.qName(i))+"\" ";
                        }
                }
        }


if (qName=="noop") {}


        return TRUE;
        // return FALSE; provoque l appel de fatalError
}



bool WmlHandler::endElement( const QString&, const QString& localName, const QString& qName)
{

        //  qDebug ("end Element -------------------> %s", qName.latin1()) ;



        if (qName=="p")
                tmp+="</p>";

        if (qName=="small")
                tmp+="</small>";

        if (qName=="strong")
                tmp+="</strong>";

        if (qName=="i")
                tmp+="</i>";

        if (qName=="b")
                tmp+="</b>";

        if (qName=="u")
                tmp+="</u>";

        if (qName=="big")
                tmp+="</big>";

        if (qName=="em")
                tmp+="</em>";

        // si <br></br> faire <br/>
        if (qName=="br") {
                if (tmp.right(4)=="<br>")
                        tmp=tmp.left (tmp.length()-4)+"<br/>";
                else
                        tmp+="</br>";
        }

        if (qName=="img")
                tmp+="/>";


        if (qName=="a")
                tmp+="</a>";

        if (qName=="go") {
                tmp+=">"+tmpLink+"</a>";
                tmpLink="";
        }

        if (qName=="noop") {}


        return TRUE;
}

// return the caracters
bool WmlHandler::characters( const QString& ch )
{
        // we are not interested in whitespaces

        //    qDebug ("characters %s", ch.latin1());


        if (state!=StateAnchor)
                tmp+=ch;
        else
                tmpLink+=ch;

        QString ch_simplified = ch.simplifyWhiteSpace();
        if ( ch_simplified.isEmpty() )
                return TRUE;
        /*
            switch ( state ) {
        	case StateWml:
        	case StateLine:
        	case StateHeading:
        	case StateP:
        	    quoteList.last() += ch_simplified;
        	    break;
        	default:
        	    return FALSE;
            }
        */
        return TRUE;
}


QString WmlHandler::errorString()
{
        return "the document is not in the quote file format";
}


bool WmlHandler::fatalError( const QXmlParseException& exception )
{
        errorProt += QString( "fatal parsing error: %1 in line %2, column %3\n" )
                     .arg( exception.message() )
                     .arg( exception.lineNumber() )
                     .arg( exception.columnNumber() );

        //return QXmlDefaultHandler::fatalError( exception );
}



bool WmlHandler::error ( const QXmlParseException & )
{
        qDebug ("pb parser");
}


void WmlHandler::printTmp()
{
        qDebug ("%s ",tmp.latin1());
}



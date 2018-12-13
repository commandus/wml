/* $Id: qhttpdirect.h,v 1.2 2001/03/21 20:58:50 stephanl Exp $ */
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
#ifndef QHTTPDIRECT_H
#define QHTTPDIRECT_H


class QHttpDirect
{
        Q_OBJECT

private:
        QHtpp* qhttp;
        QUrlOperator* op;

public:
        QHttpDirect(QString url);
        getData ();

public slots:
        void slotData (const QByteArray &, QNetworkOperation *);
};



#endif

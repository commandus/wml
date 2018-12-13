/* $Id: qbrowser.cpp,v 1.2 2001/03/21 20:58:50 stephanl Exp $ */
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
#include "qbrowser.h"
#include <qmenubar.h>
#include <qpopmenu.h>
#include <qcombobox.h>
#include <qtoolbar.h>
#include <qtoolbutton.h>
#include <qtooltip.h>
#include <qaccel.h>
#include <qmessagebox.h>
#include <qstatusbar.h>
#include <stdlib.h>
#include <qfile.h>
#include <qtextstream.h>
#include <qdir.h>
#include "wbmp.h"


QBrowser::QBrowser (QWidget *parent=0, const char *name=0) : QMainWindow (NULL, name, WDestructiveClose)
{


        // just the wml widget
        browser = new QWmlBrowser (this,"browser");


        connect (browser, SIGNAL(addUrl2Combolist (const QString &)),this, SLOT(slotAddUrl2Combolist (const QString &)));

        setCentralWidget (browser);

        QMenuBar* menu = new QMenuBar(this,"menu");

        QPopupMenu* file = new QPopupMenu (this);
        menu->insertItem ("&File",file);

        // pb
        //subMenu->insertItem ("Quit",qApp,SLOT(closeAllWindows()),QAccel::stringToKey( tr("Ctrl+Q")));

        //subMenu->insertItem ("Quit",qApp,SLOT(quit()),QAccel::stringToKey( tr("Ctrl+Q")));
        // bizarre qd on quitte avec le menu fichier->quitter le destructeur de qbrowser n est pas appelle bug ?
        file->insertItem ("Quit",this,SLOT(quit()),QAccel::stringToKey( tr("Ctrl+Q")));

        QPopupMenu *go=new QPopupMenu (this);

        menu->insertItem ("&Go",go);

        backId=go->insertItem ("Back", this, SLOT(back()), CTRL+Key_Left);
        connect (browser, SIGNAL (backAvailable(bool)),this,SLOT(slotBackAvailable(bool)));
        forwardId=go->insertItem ("Forward", this, SLOT(forward()), CTRL+Key_Right);
        connect (browser,SIGNAL(forwardAvailable(bool)), SLOT(slotForwardAvailable(bool)));
        go->insertItem ("Home",this, SLOT(home()),CTRL+Key_Home);

        QPopupMenu *view=new QPopupMenu (this);
        menu->insertSeparator();
        menu->insertItem ("&View",view);
        view->insertItem ("Reload",this,SLOT(reload()),Key_F5);

        menu->insertSeparator();

        QPopupMenu *help=new QPopupMenu (this);

        menu->insertItem ("&Help", help);
        help->insertItem ("About WMLBrowser", this, SLOT(about()));


        QToolBar *qToolBar = new QToolBar (this,"toolbar");

        QIconSet backIcon( QPixmap("back.xpm") );
        QToolButton * button  = new QToolButton( backIcon, "Back", QString::null, this, SLOT(back()), qToolBar, "back" );

        QToolTip::add(button,"Go to previous page");
        button->setEnabled(FALSE);
        connect (browser,SIGNAL (backAvailable(bool)), button,SLOT(setEnabled(bool)));

        QIconSet forwardIcon( QPixmap("forward.xpm") );
        button  = new QToolButton( forwardIcon, "Forward", QString::null, this, SLOT(forward()), qToolBar, "forward" );
        button->setEnabled(FALSE);

        QToolTip::add(button,"Go to next page");
        connect (browser,SIGNAL (forwardAvailable(bool)), button,SLOT(setEnabled(bool)));

        QIconSet homeIcon (QPixmap("home.xpm"));
        button = new QToolButton (homeIcon,"Home",QString::null,this,SLOT(home()),qToolBar,"home");

        QIconSet reloadIcon (QPixmap("reload.xpm"));
        button = new QToolButton(reloadIcon,"Reload",QString::null, this, SLOT(reload()), qToolBar, "reload");

        QToolTip::add(button,"Reload");
        QIconSet aboutIcon( QPixmap("5nine.xpm") );

        button = new QToolButton( aboutIcon, "About", QString::null, this, SLOT(about()), qToolBar, "about" );

        QToolTip::add(button,"About WmlBrowser");


        //                                  editable,
        // change that to be read in a text file
        // fill the history
        // and update the combobox after
        comboList = new QComboBox (TRUE, qToolBar);
        qToolBar->setStretchableWidget(comboList);

        /* to be removed */
        /*
          comboList->insertItem ((QString)"file:///tmp/i.wml");
          comboList->insertItem ((QString)"http://www.wapit.com/~liw/hello.wml");
          comboList->insertItem ((QString)"http://webcab.de/i.wml");
        */
        /* end to be removed */

        // ne fontionne queqd on remplit la comboxbox a la "main"
        // mais pas avec insertItem !!!!!!!!!!!!!
        comboList->setInsertionPolicy(QComboBox::AtTop);
        comboList->setDuplicatesEnabled(FALSE);

        connect( comboList, SIGNAL( activated( const QString & ) ), this, SLOT( comboListSelected( const QString & ) ) );
        QToolTip::add(comboList,"Type a WAP address and press Enter");


        // statusbar
        connect( browser, SIGNAL( highlighted( const QString&) ),
                 statusBar(), SLOT( message( const QString&)) );

        setCaption ("WMLBrowser");

        // init the list for the history and for the sites visited (for back and forward buttons)

        history=new QList <QString>;
        history->setAutoDelete (TRUE);
        getLinks();

        last_sites=new QList <QString>;
        last_sites->setAutoDelete (TRUE);


        // affiche un message sur la status bar
        //statusBar()->message("Loading...",2000);

        //connect (this, SIGNAL (textChanged()),this,SLOT(slotTextChanged()));


        // disable forward et back capabilities
        //emit backAvailable (FALSE);
        //emit forwardAvailable (FALSE);
        menuBar()->setItemEnabled (backId, FALSE);
        menuBar()->setItemEnabled (forwardId, FALSE);
        browser->setFocus();

}



void QBrowser::getLinks ()
{
        QFile* configFile = new QFile (getHomeDir()+"/"+CONF_FILE );

        QString qstring;

        //qDebug ("%s",getHomeDir().latin1());

        QTextStream textstream( configFile);

        if (!configFile->exists()) {

                qDebug ("pas de fichier de configuration dans le HOME DIRECTORY");
                return ;
        }

        if (!configFile->open(IO_ReadOnly)) {
                qDebug ("Ne peut pas ouvrir le fichier de configuration");
                return;
        }

        while ((qstring=textstream.readLine ())!=QString::null)
        {
                //cout <<qstring<<endl;
                if (qstring.find(QString (STR_CONF_HISTORY),0,FALSE)==0) {
                        //cout <<"egal"<<endl;
                        while ((qstring=textstream.readLine ())!=QString::null) {
                                //cout <<"chaine "<<qstring<<endl;
                                if ((qstring.find ('[')!=-1) || qstring.isEmpty())  //|| qstring.isNull())
                                        return;

                                history->append (new QString(qstring));
                                //cout <<"APPEND"<<endl;
                                comboList->insertItem (qstring);
                        }
                }
        }

        configFile->close();
        delete configFile;
}


// save the history in a file
// should be called before exiting the application
void QBrowser::saveLinks()
{


        //qDebug ("nb Combolist element %d",comboList->count());

        if ((comboList->count())==0)
                return;


        QFile* configFile = new QFile (getHomeDir()+"/"+CONF_FILE);

        if (configFile->exists()) {
                QFile* configFileOld = new QFile (getHomeDir()+"/"+CONF_FILE+".old");

                if (configFileOld->exists())
                        if (!configFileOld->remove()) {
                                qDebug ("pb remove .old .");
                                return ;
                        }

                delete configFile;
                delete configFileOld;

                QDir configFilePath;
                if (!(configFilePath.rename (getHomeDir()+"/"+CONF_FILE,getHomeDir()+"/"+CONF_FILE+".old"))) {
                        qDebug ("Erreur rename.");
                        return ;
                }

                configFile = new QFile (getHomeDir()+"/"+CONF_FILE);
                configFileOld = new QFile (getHomeDir()+"/"+CONF_FILE+".old");

                configFile->open(IO_WriteOnly);
                configFileOld->open(IO_ReadOnly);

                QTextStream textstream (configFile);
                QTextStream textstreamOld (configFileOld);

                QString qstring;


                // copie de l ancien vers le nouveau config file
                bool history=FALSE;

                while ((qstring=textstreamOld.readLine())!=QString::null) {
                        if (qstring.find (STR_CONF_HISTORY,0,FALSE)!=-1) {
                                history=TRUE;
                                qstring="";
                        }


                        if ((history) && (qstring.find ('[')!=-1))
                                history=FALSE;

                        if (!history)
                                textstream <<qstring<<endl;

                } // end while

                textstream <<STR_CONF_HISTORY<<endl;
                for (int i=0;i< ( comboList->count());)
                        textstream <<(comboList->text(i++))<<endl;


                configFile->close();
                configFileOld->close();
                delete configFile;
                delete configFileOld;
        } else { // !configFile.exists
                configFile->open(IO_WriteOnly);

                QTextStream textstream (configFile);
                textstream <<STR_CONF_HISTORY<<endl;

                for (int i=0;i<(comboList->count());)
                        textstream <<(comboList->text(i++))<<endl;

                configFile->close();
                delete configFile;
        }
}


void QBrowser::emptyQList (QList <QString> *qlist)
{
        int i=qlist->count();
        for (;i>=0;)
                qlist->remove (--i);
}


// slot events
void QBrowser::about()
{
        //QMessageBox::about (this, "About ... ","WmlBrowser\n\nCopyright 2001\n5Nine Wireless Communications Inc.\n");

        QMessageBox::about (this, "About ... ","WmlBrowser\n\n5Nine Wireless Communications Inc.\n");
        saveLinks();

}


void QBrowser::back()
{
        // qDebug ("Qbrowser Back");
        browser->back();
}

void QBrowser::forward()
{
        browser->forward();
}

void QBrowser::home()
{
        //  cout <<"Home"<<endl;
        browser->home();
}


void QBrowser::comboListSelected (const QString & url)
{
        //qDebug ("Combolist selected %s",url.latin1());

        browser->setSource (url);

        // must change back et forward possibilities


}



void QBrowser::reload ()
{
        // qDebug ("Reload");
        browser->reload();
}



QBrowser::~QBrowser ()
{
        qDebug ("destructeur");
        saveLinks();


        // empty the QList history and last_sites
        emptyQList (history);
        emptyQList (last_sites);

        delete (history);
        delete (last_sites);

}




void QBrowser::slotBackAvailable (bool state)
{
        /*
        qDebug ("Available");

        if (state==TRUE)
          qDebug ("TRUE");
        else
          qDebug ("FALSE");
        */
        menuBar()->setItemEnabled (backId, state);
}


void QBrowser::slotForwardAvailable (bool state)
{

        //qDebug ("Available");
        menuBar()->setItemEnabled (forwardId, state);


}


QString  QBrowser::getHomeDir () const
{
        return QString::QString(getenv ("HOME"));

}


void QBrowser::quit ()
{

        // bizarre qd on quitte avec le menu fichier->quitter le destructeur de qbrowser n est pas appelle bug ?
        qDebug("quit...");
        saveLinks();
        qApp->quit();
}

void QBrowser::slotAddUrl2Combolist (const QString & newItem)
{
        comboList->insertItem (newItem,0);
        comboList->setCurrentItem (0);
}

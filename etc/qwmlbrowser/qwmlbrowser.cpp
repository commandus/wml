/* $Id: qwmlbrowser.cpp,v 1.2 2001/03/21 20:58:50 stephanl Exp $ */
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
#include "qwmlbrowser.h"
#include <qstatusbar.h>
#include <qmime.h>
#include <qdragobject.h>
#include <qlineedit.h>
#include <qurl.h>
#include "qrichtext_p.h"

#include "wmlparser.h"

// theses functions are just needed for debugging purpose
void urlInfo (QUrl url);
QString dirPathWthFile (QUrl url);
void printFilePaths (QStringList list);

QWmlBrowser::QWmlBrowser (QWidget *parent, const char* name): QScrollView (parent,name, WPaintClever)//WRepaintNoErase)
{

        child=new QList<QObject>;
        child->setAutoDelete (TRUE);


        // initialisation
        viewport()->setMouseTracking( TRUE );   // needed to handle mouseMoveEvent

        setVScrollBarMode( QScrollView::Auto );
        setHScrollBarMode( QScrollView::Auto );

        //viewport()->setBackgroundMode( PaletteBase );

        // a retirer
        //setGeometry (0,0,visibleWidth(),visibleHeight()); // taille de la widget et de la surface de rendering
        // appeler cette fct qd on connait la taille de la page
        //resizeContents(visibleWidth(),visibleHeight()*2);
        viewport()->setBackgroundMode( PaletteBase );


        // fin de a retirer



        //QLineEdit *test=new QLineEdit ("QLINEDIT",this);
        //test->move (0,100);

        // disable back et forward buttons
        // doesn t seem to work
        //emit backAvailable (FALSE);
        //emit forwardAvailable (FALSE);

        // hope that solve wml get pb
        //test=new QMimeSourceFactory ();
        //  test->setExtensionType("wml","text/vnd.wap.wml");
        //mimeSourceFactory()->setFilePath ("/data/work/simplerichtextbis/");
        //mimeSourceFactory()->setFilePath ("/skiff/");
        //mimeSourceFactory()->setFilePath ("/");
        mimeSourceFactory()->setExtensionType("wml","text/vnd.wap.wml");



        connect (this,SIGNAL(textChanged()), this, SLOT(slotTextChanged()));


        currentSite="";

}



QWmlBrowser::~QWmlBrowser()
{
        // vide les QList
        emptyListQObject (child);

        delete (child);


}

void QWmlBrowser::emptyListQObject(QList <QObject> *qlist)
{

        int i=qlist->count();
        for (;i>=0;)
                qlist->remove (--i);

}


// not use for the moment
void QWmlBrowser::emptyListQString(QList <QString> *qlist)
{
        int i=qlist->count();
        for (;i>=0;)
                qlist->remove(--i);

}



void QWmlBrowser::addChild (QObject *qobject)
{
        child->append (qobject);
}





void QWmlBrowser::render (QPainter *p)
{
}



/* doit etre lie a QRichSimpleText */
/* sinon ne fct qu avec tmp */

/* parcours de la queue contenant les objects */
/* pour chaque noeud du type QSimppleRichText appeler anchorAT */
QString QWmlBrowser::anchorAt(const QPoint& pos)
{

        //cout <<"AnchorAT"<<endl;
        if (tmp==NULL) return QString::null;

        return tmp->anchorAt( QPoint(contentsX(), contentsY() ) + pos );

        /*
           int i=child->count();
           for (;i>=0;)
           {
             
           }
        */

}



void QWmlBrowser::viewportMousePressEvent( QMouseEvent* e )
{
        if ( e->button() == LeftButton ) {
                buttonDown=anchorAt (e->pos());
        }
}

/*!
  \e override to activate anchors.
*/
void QWmlBrowser::viewportMouseReleaseEvent( QMouseEvent* e )
{
        if (e->button()==LeftButton) {
                if (!buttonDown.isEmpty() && anchorAt(e->pos()) ==buttonDown) {
                        qDebug ("click links %s",buttonDown.latin1());
                        setSource(buttonDown,TRUE);

                }
        }
        buttonDown=QString::null;
}

void QWmlBrowser::viewportMouseMoveEvent( QMouseEvent* e)
{
        /*
        #ifndef QT_NO_DRAGANDDROP
            if ( (e->state() & LeftButton) == LeftButton && !d->buttonDown.isEmpty()  ) {
                if ( ( e->globalPos() - d->lastClick ).manhattanLength() > QApplication::startDragDistance() ) {
                    QUrl url ( context(), d->buttonDown, TRUE );
                    QUriDrag* drag = new QUriDrag( this );
                    drag->setUnicodeUris( url.toString() );
                    drag->drag();
                }
                return;
            }
        #endif
         
            if ( e->state() == 0 ) {
                QString act = anchorAt( e->pos() );
                if (d->highlight != act) {
                    if ( !act.isEmpty() ){
                        emit highlighted( act );
                        d->highlight = act;
                    }
                    else if ( !d->highlight.isEmpty() ) {
                        emit highlighted( QString::null );
                        d->highlight = QString::null;
                    }
        #ifndef QT_NO_CURSOR
                    viewport()->setCursor( d->highlight.isEmpty()?arrowCursor:pointingHandCursor );
        #endif
                }
            }
         
            QTextView::viewportMouseMoveEvent( e );
        */
        highlightedLink=anchorAt (e->pos());

        if (highlightedLink!=QString::null)
                emit highlighted (highlightedLink);
        else
                emit highlighted (QString::null);


#ifndef QT_NO_CURSOR
        viewport()->setCursor( highlightedLink.isEmpty()?arrowCursor:pointingHandCursor );
#endif

}


void QWmlBrowser::update()
{
}



void QWmlBrowser::drawContents (QPainter *p, int clipx, int clipy, int clipw, int cliph)
{

        //qDebug ("DrawContents");

        //if (tmp==NULL) qDebug ("tmp == NULL");

        if (tmp==NULL) return;
        //qDebug ("DrawContents");


        viewport()->erase (0,0,oldWidth,oldHeight); // flicker when the window lost the focus

        tmp->setWidth (this->visibleWidth());
        //resizeContents (visibleWidth(), tmp->height());
        // ajouter un test pour verifier que l affichage a change avant de refaire le m affichage !

        //viewport()->erase (0,0,visibleWidth(),tmp->height()); // flicker when the window lost the focus
        viewport()->erase (0,0,oldWidth,oldHeight); // flicker when the window lost the focus
        tmp->draw  (p, 0, 0, QRegion::QRegion ( 0,0,visibleWidth(),tmp->height() , QRegion::Rectangle ), colorGroup());

        resizeContents (visibleWidth(), tmp->height());
        //p->setPen (Qt::red);
        //p->drawRect (0,0,visibleWidth(),visibleHeight());
        //qDebug ("tmp-<height:%d  visibleHeight():%d",tmp->height(),visibleHeight());

        //  qDebug ("oldheight:%d ",oldHeight);
        oldWidth=visibleWidth();
        oldHeight=visibleHeight();
}


//call after setText
void QWmlBrowser::slotTextChanged ()
{
        qDebug ("-------------------------------------- Slot Text Changed");

        WmlHandler handler;
        QXmlInputSource source ;

        const QString &tmpText=_original_text;

        source.setData (tmpText);

        QXmlSimpleReader reader;
        reader.setContentHandler (&handler);
        reader.setErrorHandler(&handler);
        bool ok=reader.parse(source);

        if (tmp!=NULL) {
                qDebug ("kill tmp");
                delete (tmp);
        }

        QFont font("helvetica");
        tmp =new QSimpleRichTextBis (handler.getWmlParsed(), (const QFont&) font, QString::null, (QStyleSheet*)QStyleSheet::defaultSheet());

        //tmp =new QSimpleRichTextBis ("<img src=/skiff/logo.wbmp  height=40  height=78 />", (const QFont&) font, QString::null, (QStyleSheet*)QStyleSheet::defaultSheet());

        if (tmp==NULL) qDebug ("tmp est null");
        else qDebug ("tmp npon null");


        handler.printTmp();
        //emit update();
        viewport()->update();

        // disable back
        // emit backAvailable (FALSE);
}


QString QWmlBrowser::text() const
{
        return _original_text;
}


void QWmlBrowser::setText (const QString & text, const QString & context)
{
        qDebug ("**********SetText Called ******************************");

        _original_text=text;
        emit textChanged();
}


void QWmlBrowser::back ()
{
        //qDebug ("QWmlBrowser back");
        if ( stack.count() <= 1)
                return;
        forwardStack.push(stack.pop() );
        setSource( stack.pop(),TRUE );
        emit forwardAvailable( TRUE );
}


void QWmlBrowser::forward()
{
        //qDebug ("QWmlbrowser forward");

        if ( forwardStack.isEmpty() )
                return;
        setSource( forwardStack.pop(),TRUE );
        emit forwardAvailable( !forwardStack.isEmpty() );
}

void QWmlBrowser::home()
{
        //qDebug ("QWmlbrowser home");
        //scrollToAnchor ("123",tmp);
        if (homeUrl.isNull())
                return;

        setSource (homeUrl);
}

void QWmlBrowser::reload ()
{
        qDebug ("QWmlbrowser reload");
}


QString QWmlBrowser::source() const
{
        if ( stack.isEmpty() )
                return QString::null;
        else
                return stack.top();
}


// the the qrichtext object in qsimplerichtext ! which is private
// that why there is qsimplerichtextbis
// which is the same as qsimplerichtext with an added function
// QRichText * richtext () const;

// from qtextbrowser
void QWmlBrowser::scrollToAnchor(const QString& name, QSimpleRichTextBis* tmp)

{
        if ( name.isEmpty() )
                return;

        //    d->curmark = name;

        QRichTextIterator it( *tmp->richText() );
        do {
                if ( it.format()->anchorName() == name ) {
                        QTextParagraph* b = it.outmostParagraph();
                        if ( b->dirty ) { // QTextView layouts delayed in the background, so this may happen
                                QRichTextFormatter tc( *tmp->richText() );
                                tc.gotoParagraph( 0, tmp->richText());
                                tc.updateLayout();
                                resizeContents( QMAX( tmp->richText()->flow()->widthUsed-1, visibleWidth() ),
                                                tmp->richText()->flow()->height );
                        }
                        QRect r = it.lineGeometry();
                        setContentsPos( contentsX(), r.top() );
                        return;
                }
        } while ( it.right( FALSE ) );
}

// only for debbugging purposes
void printFilePaths (QStringList list)
{

        qDebug ("print File Paths");
        for ( QStringList::Iterator it = list.begin(); it != list.end(); ++it )
                qDebug( "%s \n", (*it).latin1() );
        qDebug ("fin print file paths");

}


void urlInfo (QUrl url)
{
        qDebug ("Url Info-------------------------------------");
        qDebug ("protocol %s ",url.protocol().latin1());
        qDebug ("path sans le fichier %s ",url.path().left(url.path().length()-url.fileName().length()).latin1());
        qDebug ("fileName %s ", url.fileName().latin1());
        qDebug ("dirPath %s ",url.dirPath().latin1());
        qDebug ("host %s ",url.host().latin1());
        if (url.isLocalFile())
                qDebug ("isLocalFile TRUE");
        else
                qDebug ("isLocalFile FALSE");

        if (url.hasPath())
                qDebug ("hasPath TRUE");
        else
                qDebug ("hasPath FALSE");

        if (url.hasRef())
                qDebug ("hasRef TRUE");
        else
                qDebug ("hasRef FALSE");

        if (url.isValid())
                qDebug ("isValid TRUE");
        else
                qDebug ("isValid FALSE");

        if (url.isRelativeUrl (url.toString()))
                qDebug ("isRelativeUrl TRUE");
        else
                qDebug ("isRelativeUrl FALSE");

        qDebug ("toString %s",url.toString().latin1());

        qDebug ("--------------------------------");


}

// cf qtextbrowser.cpp
// this method need to be cleaned ...
void QWmlBrowser::setSource(const QString& name,bool isClicked)
{
        printFilePaths (mimeSourceFactory()->filePath ());
        QString toto;

        qDebug ("setSource NAME  %s",name.latin1());
#ifndef QT_NO_CURSOR
        if (isVisible())
                qApp->setOverrideCursor(waitCursor);
#endif

        QUrl tmpUrl(name);
        urlInfo (tmpUrl);


        QString source=name;

        if (source.left(1)=="/")
                source=source.mid(1);

        // peut etre a modifier pour des file://

        qDebug ("temp url %s",tmpUrl.protocol().latin1());

        qDebug ("Current Source %s",currentSite.latin1());

        qDebug ("NAME: SETSOURCE : %s",source.latin1());


        QString mark;

        // the following should be removed
        // and http request should be threat with QMineSource
        // but for the moment i don t know how

        if (name.left(5).lower() == "http:") {
                // requete http
                qDebug ("http request");
        }


        int hash = name.find('#');
        if ( hash != -1) {
                source  = name.left( hash );
                mark = name.mid( hash+1 );
        }

        // these two tests should be integrated after
        if ( source.left(7) == "file://" )
                source="file:"+source.mid(7);

        if (source.left(5)=="file:") {
                source = source.mid(5);
                if ((! (tmpUrl.dirPath().isEmpty()) )  && (! (tmpUrl.dirPath().isNull())) ) {
                        mimeSourceFactory()->setFilePath (dirPathWthFile(tmpUrl)+"/");
                        oldDirPath=dirPathWthFile(tmpUrl);
                        qDebug ("setFilePath %s",dirPathWthFile(tmpUrl).latin1());
                }


        }



        QString url = mimeSourceFactory()->makeAbsolute( source, context() );
        //QString url=mimeSourceFactory()->makeAbsolute(source,QString::null);
        qDebug (url);
        qDebug (source);
        QString txt;
        bool dosettext = FALSE;

        if ( !source.isEmpty() && url != curmain ) {
                //const QMimeSource* m=mimeSourceFactory()->data(source,QString::null);
                const QMimeSource* m = mimeSourceFactory()->data( source, context() );
                if ( !m ) {
                        qWarning("QWmlBrowser: no mimesource for %s", source.latin1() );
                        qDebug ("ici");
                }
                // drag and drop i don t care for the moment

                else {
                        if ( !QTextDrag::decode( m, txt ) ) {
                                qWarning("QWmlBrowser: cannot decode %s", source.latin1() );
                        }
                }

                if ( isVisible() ) {
                        QString firstTag = txt.left( txt.find('>' )+1 );
                        QRichText* ltmp = new QRichText( firstTag, QApplication::font() );
                        static QString s_type = QString::fromLatin1("type");
                        static QString s_detail = QString::fromLatin1("detail");
                        bool doReturn = FALSE;
                        if ( ltmp->attributes().contains(s_type)
                                        && ltmp->attributes()[s_type] == s_detail )
                                doReturn = TRUE;
                        QTextFormatCollection* formats = ltmp->formats;
                        delete ltmp;
                        delete formats; //#### fix inheritance structure in rich text
                        /*
                            if ( doReturn ) {
                        popupDetail( txt, d->lastClick );
                        #ifndef QT_NO_CURSOR
                        qApp->restoreOverrideCursor();
                        #endif
                        return;
                            }
                         */
                }

                curmain = url;
                dosettext = TRUE;
        }

        curmark = mark;

        if ( !mark.isEmpty() ) {
                url += "#";
                url += mark;
        }
        if ( !homeUrl )
                homeUrl = url;


        toto=tmpUrl.protocol()+":"+tmpUrl.path();
        qDebug ("dir wth path %s",dirPathWthFile(url).latin1());
        qDebug ("TOTO TOTO %s",toto.latin1());

        if ( stack.isEmpty() || stack.top() != url) {

                tmpUrl=QUrl (url);
                if ((dirPathWthFile (tmpUrl).isEmpty()) || (dirPathWthFile(tmpUrl)).isNull()) {
                        url=tmpUrl.protocol()+":"+oldDirPath+tmpUrl.fileName();
                        qDebug ("ICI ET LA");

                }

                if (tmpUrl.protocol()!=url.left(tmpUrl.protocol().length()))
                        url=tmpUrl.protocol()+":"+url;



                qDebug ("PUSH %s",url.latin1());
                // il faut mettre le chemin au complet ici
                // sinon comment differencier http:// de file://
                // et conserver un trace du chemin complet
                stack.push( url );
        }

        int stackCount = stack.count();
        if ( stack.top() == url )
                stackCount--;
        emit backAvailable( stackCount > 0 );
        stackCount = forwardStack.count();
        if ( forwardStack.top() == url )
                stackCount--;
        emit forwardAvailable( stackCount > 0 );


        if ( dosettext ) {
                setText( txt, url );
                //qDebug ("---------------text %s", txt.latin1());
        }

        if ( isVisible() && !mark.isEmpty() )
                // i must change that piece of code
                // scroll to anchor should check every
                // qsimplerichtextbis
                // this is just here for a demo
                // with just one qsimplerichtextbis widget
                scrollToAnchor( mark, tmp);
        else
                setContentsPos( 0, 0 );

#ifndef QT_NO_CURSOR
        if (isVisible())
                qApp->restoreOverrideCursor();
#endif


        // update the combolist
        // send a signal
        // only if the url comes from a click
        // otherwise the link come from writing or drag and drop
        if (isClicked)
                emit addUrl2Combolist (url);

}

// a changer plus tard
QMimeSourceFactory* QWmlBrowser::mimeSourceFactory () const
{
        return QMimeSourceFactory::defaultFactory();
        //return test;
}


// need to be in Qurl
// maybe later ...

QString dirPathWthFile (QUrl url)
{
        QString tmp=url.path().left(url.path().length()-url.fileName().length());

        if ((!tmp.isEmpty()) && (!tmp.isNull()) && (tmp.left(1)!="/"))
                return ("/"+tmp);
        return tmp;
}


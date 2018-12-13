// 
// Copyright (C) 6.6.2000 by Applepie Solutions Ltd.
// http://www.applepiesolutions.com
//
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program; if not, write to the Free Software
// Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
//
// This javascript code defines the wapreview user interface and 
// manages communications with the wapreview applet
//
var aplpidbg = 0;
var spd=50; //scrolling speed
var scrn_w=120; //screen width
var scrn_h=450;//window.innerHeight;
var fnt_h=8;//font height
var pos=60;// initial top position
var off_t=34;//top offset
var off_b=200;//bottom offset
var upr=-1000;//upper offset (not used)
var lwr=pos;// lower limiter
var tim;    // timer variable for scrolling
var off_l=20;   // left offset
var fnt_f="verdana"; // font name
var bgc_t="gray"; // top backgroundcolor
var bgc_b="white"; // bottom backgroundcolor
var bgc_s="#6ABA7B"; // scrn backgroundcolor 106,186,123
var fgc_s="black"; // scrn forecolor
var cardtimer;
var loadtimer;
//what browser are we using
var dyn=(document.layers||document.all)?true:alert("Sorry... support for later versions of navigator and explorer only.");
var nav=(document.layers);
var iex=(document.all);
var resetgroup1="//";
var resetgroup2="//";
var resetgroup3="//";
var resetgroup4="//";
var resetgroup5="//";
var resetgroup6="//";
var resetgroup7="//";
var resetgroup8="//";
var resetgroup9="//";


function reval(cmd){
  eval(cmd+';');
}
function choose(){
  // do nothing;
  true;
}


function flip(group,itemno,linktext,selected,resetgroup,allowmulti){
  // This function simulates a (possibly multichoice) selection
  // list, by highlighting the selected option(s).
  var elinktext=linktext;
  var resetcode="//";
  var clickstart='selectitem(\''+group+'\','+itemno+',\''+linktext+'\',';
  var resetstart='flip(\''+group+'\','+itemno+',\''+linktext+'\',';
  if(selected){
      elinktext="<b>"+linktext+"</b>";
      resetcode=resetstart+"false,false,"+allowmulti+");"
  }
  var cntnt = '<a href="javascript:choose()" onmousedown="'+clickstart+!selected+','+!allowmulti+','+allowmulti+');">'+elinktext+'</a>';
  if(document.layers){
    var doc = 'document.aplpicard.document.nav'+group+'_'+itemno+'.document';
    eval(doc+'.open();');
    eval(doc+'.write(cntnt);');
    eval(doc+'.close();');
  }
  if(document.all){
    var doc='iex'+group+'_'+itemno;
    eval(doc+'.innerHTML=cntnt');
  }
  if(resetgroup){
     eval(eval("reset"+group+";")+"//");
     eval("reset"+group+"=resetcode;");
  }

}

function selectitem(group,itemno,ltext,selected,resetgroup,allowmulti){
  // call the flip() method after contacting the applet
  // the value of selected might be wrong, so we reset it
  selected = document.wapplet.selectitem(group,itemno);
  flip(group,itemno,ltext,selected,resetgroup,allowmulti);
  return(true);
}

function beginnavigation(){
  if(iex)document.changeurl.navto.focus();
  if(nav)window.focus();
}


function cardtimeout(){
//  alert("in timeout");
  reval(document.wapplet.ontimer());
}

// could use this function if the applet retrieved
// the deck on a separate thread.
//function loadtimeout(msg){
//  loadmsg = '<br><br><center><b>'+msg+'</b></center>';
//  if(iex)aplpinav.innerHTML=loadmsg; 
//  if(nav){
//    document.aplpinav.document.open();
//    document.aplpinav.document.write(loadmsg);
//    document.aplpinav.document.close();
//  }
//  ltimeout = 'loadtimeout("'+ msg+ '.'+'\")';
//  loadtimer=setTimeout(ltimeout,1);
//}

function showSource() {
 srcWindow = window.open("","subWindow",
  "toolbar=no,location=no,directories=no," +
  "status=nomenubar=no,scrollbars=yes,resizable=yes,width=400,height=300");
  srcWindow.focus();
  srcWindow.document.open();
  var src =
    "<HTML><HEAD><TITLE>"+document.wapplet.currentURL()+"</TITLE></HEAD>" + 
    "<BODY BGCOLOR='#FFFFFF'><P>" +"<PRE>\n" +
    document.wapplet.getSource()+
    "\n</PRE>" +
    "</BODY></HTML>\n";
   srcWindow.document.write(src);
   srcWindow.document.close();
}

function showCard(){
  if(cardtimer){clearTimeout(cardtimer);}
  if(iex)document.changeurl.navto.value = document.wapplet.currentURL();
  if(nav)document.divBtm.document.changeurl.navto.value = document.wapplet.currentURL();
  if(iex)aplpinav.innerHTML=document.wapplet.getNavData(); 
  if(nav){
    document.aplpinav.document.open();
    document.aplpinav.document.write(document.wapplet.getNavData());
    document.aplpinav.document.close();
  }	
  if(iex)aplpicard.innerHTML=document.wapplet.getCardData();
  if(nav){
    document.aplpicard.document.open();
    document.aplpicard.document.write(document.wapplet.getCardData());
    document.aplpicard.document.close();
  }	

  if(aplpidbg){alert("getNavData okay");}
  var t = document.wapplet.getCardTimerValue();
  if(aplpidbg){alert("getCardTimerValue okay");}
  if(t>=0){
    //alert("setting timeout ["+t+"]");
    cardtimer=setTimeout("cardtimeout()",t);
  }else{
    //alert("NOT setting timeout ["+t+"]");
  }
//alert("setting position");
  pos=60;
  do_scroll(pos);
}

function post(i){
  document.wapplet.post(i);
  reval(document.wapplet.onenterforward());
  showCard();
}

function setCard(url){
//alert("to set:"+url);
  beginnavigation();
  //loadtimer=setTimeout('loadtimeout("loading.")',1);
  document.wapplet.setCard(url);
  //clearTimeout(loadtimer);
  reval(document.wapplet.onenterforward());
  showCard();
}

function reloadDeck(){
  beginnavigation();
  document.wapplet.reloadDeck();
  reval(document.wapplet.onenterforward());
  showCard();
}

function prevCard(){
  beginnavigation();
  document.wapplet.prevCard();
  reval(document.wapplet.onenterbackward());
  showCard();
}

function nextCard(){
  beginnavigation();
  document.wapplet.nextCard();
  reval(document.wapplet.onenterforward());
  showCard();
}

function setVar(nam,val){
  return document.wapplet.setVar(nam,val);
}

function getVar(nam){
  return document.wapplet.getVar(nam);
}

function getHref(i){
  return document.wapplet.getHref(i);
}

function gohome(){
  var home = document.wapplet.homeurl();
  if(!home){
    home='http://www.applepiesolutions.com/i.wml';
  }
  setCard(home);
 // setCard('http://www.applepiesolutions.com/i.wml');
}

// top scrn border 
  var divTop_content='<img src="scrntop.jpg"></img>';
  var divLft_content='<img src="scrn.jpg"></img>';
  var divRght_content='<img src="scrnrght.jpg"></img>';
  var divSrnBot_content='<img src="scrnbot.jpg"></img>';

// bottom scrn border
  var divBtm_content =('<table border="0" width="100%" bgcolor="#FFFFFF" cellpadding=0 cellspacing=0><tr><td><center><a target=aplpi href=http://www.applepiesolutions.com/?simclick><img border=0 src="/pics/simlogo.gif" alt="http://www.applepiesolutions.com" width=120 height=135></img></a></center><center><a href="javascript:gohome();">home</a>&nbsp;&nbsp;<a href="javascript:showSource();">source</a><br></center><form name="changeurl" action="javascript://" onsubmit="setCard(this.navto.value);"><input name="navto" type="text" size="18" value="http://" onchange="setCard(this.value);"><br><center><a target=aplpi href=http://www.applepiesolutions.com/?simclick>Applepie Solutions</a></center><br><br><br><!--hidden button--><input type=submit></form></td></tr></table>');


if(window!=top)top.location.href=location.href;  
msg="This page requires version 4 or later of \nNetscape Navigator or Internet Explorer"
// determine if this is netscape or explorer


function scroll_dn(){
  //if(pos>upr)
  pos-=fnt_h;
  do_scroll(pos);  
  tim=setTimeout("scroll_dn()",spd);
}

function scroll_up(){
  if(pos<lwr)pos+=fnt_h;
  do_scroll(pos);
  tim=setTimeout("scroll_up()",spd);
}

function do_scroll(pos){
  if(iex){
    document.all.aplpicard.style.overflow='hidden';
    document.all.aplpicard.style.top=pos;
  }
  if(nav){
    document.aplpicard.clip.right = scrn_w;
    document.aplpicard.top=pos;
  }
}

function no_scroll(){
  clearTimeout(tim);
}

if(iex){ 
   document.write('<DIV ID="divLft" STYLE="position:absolute; top:0; left:0;z-index:1">'+divLft_content+'</DIV>');
   document.write('<DIV ID="divRgt" STYLE="position:absolute; top:0; left:145;z-index:3">'+divRght_content+'</DIV>');
   document.write('<DIV ID="divTop" STYLE="position:absolute; top:0; left:0; width:'+scrn_w+'; height:54;  background-color:'+bgc_t+'; z-index:2">'+divTop_content+'</DIV>');   
   document.write('<DIV ID="divSbt" STYLE="position:absolute; top:160; left:0; width:'+scrn_w+'; height:15;  background-color:'+bgc_t+'; z-index:4">'+divSrnBot_content+'</DIV>');
   document.write('<DIV ID="divbutup" STYLE="position:absolute; top:195; left:60; width:40; height:15;  background-color:'+bgc_t+'; z-index:5"><a HREF="javascript://" onmousedown="scroll_up();" onmouseout="no_scroll();" onmouseup="no_scroll();"><img border=0 src="butup.jpg"></img></a></DIV>');
   document.write('<DIV ID="divbutdn" STYLE="position:absolute; top:210; left:60; width:40; height:15;  background-color:'+bgc_t+'; z-index:5"><a HREF="javascript://" onmousedown="scroll_dn();" onmouseout="no_scroll();" onmouseup="no_scroll();"><img border=0 src="butdown.jpg"></img></a></DIV>');
   document.write('<DIV ID="divBtm" STYLE="position:absolute; top:229; left:0; width:165; height:'+scrn_h+'; background-color:'+bgc_b+';font-size:'+fnt_h+'pt; z-index:3">'+divBtm_content+'</DIV>');
   document.write('<DIV ID="aplpinav" STYLE="position:absolute; top:144; left:'+off_l+'; width:'+scrn_w+'; height=15; font-family:'+fnt_f+'; font-size:'+fnt_h+'pt; background-color:'+bgc_s+'; color:'+fgc_s+'; z-index:2;"></DIV>');
   document.write('<DIV ID="aplpicard" STYLE="position:absolute; top:'+off_t+'; left:'+off_l+'; width:'+scrn_w+'; font-family:'+fnt_f+'; font-size:'+fnt_h+'pt; background-color:'+bgc_s+'; color:'+fgc_s+'; z-index:1;"><br><br><center><b>loading...</b></center></DIV>');
}

if(nav){
   document.write('<LAYER ID="divLft" position="absolute" top="0" left="0" z-index="1">'+divLft_content+'</LAYER>');
   document.write('<LAYER ID="divRgt" position="absolute" top="0" left="145" z-index="3">'+divRght_content+'</LAYER>');
   document.write('<LAYER ID="divTop" position="absolute" top="0" left="0" width="'+scrn_w+'" height="54"  background-color="'+bgc_t+'" z-index="2">'+divTop_content+'</LAYER>');  
   document.write('<LAYER ID="divSbt" position="absolute" top="160" left="0" width="'+scrn_w+'" height="15"  background-color="'+bgc_t+'" z-index="4">'+divSrnBot_content+'</LAYER>');
   document.write('<LAYER ID="divbutup" position="absolute" top="195" left="60" width="40" height="15"  background-color="'+bgc_t+'" z-index="5"><a HREF="javascript://" onmousedown="scroll_up();" onmouseout="no_scroll();" onmouseup="no_scroll();"><img border=0 src="butup.jpg"></img></a></LAYER>');
   document.write('<LAYER ID="divbutdn" position="absolute" top="210" left="60" width="40" height="15"  background-color="'+bgc_t+'" z-index="5"><a HREF="javascript://" onmousedown="scroll_dn();" onmouseout="no_scroll();" onmouseup="no_scroll();"><img border=0 src="butdown.jpg"></img></a></LAYER>');
   document.write('<LAYER ID="divBtm" position="absolute" top="229" left="0" width="165" height="'+scrn_h+'" background-color="'+bgc_b+'" font-size="'+fnt_h+'pt" z-index="3">'+divBtm_content+'</LAYER>');
   document.write('<LAYER ID="aplpinav" position="absolute" top="144" left="'+off_l+'" width="'+scrn_w+'" height=15" font-family="'+fnt_f+'" font-size="'+fnt_h+'pt" background-color="'+bgc_s+'" color="'+fgc_s+'" z-index="2"></LAYER>');
   document.write('<LAYER ID="aplpicard" position="absolute" top="'+off_t+'" left="'+off_l+'" width="'+scrn_w+'" font-family="'+fnt_f+'" font-size="'+fnt_h+'pt" background-color="'+bgc_s+'" color="'+fgc_s+'" z-index="1"><br><br><center><b>loading...</b></center></LAYER>');
}

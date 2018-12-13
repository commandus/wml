// COPYRIGHT
// ~~~~~~~~~
// Original idea of Orfo system belongs to Dmitry Koteroff.
// If you want to modify this script, please communicate 
// with author first: http://forum.dklab.ru/other/orphus/.
//
// You may use this script "as is" with no restrictions.
// Please do not remove these comments.
//
// УСЛОВИЯ ИСПОЛЬЗОВАНИЯ
// ~~~~~~~~~~~~~~~~~~~~~
// Оригинальная идея системы "чистки" орфографии принадлежит 
// Дмитрию Котерову. Если Вы хотите модифицировать этот скрипт, 
// пожалуйста, свяжитесь сначала с автором по адресу:
// http://forum.dklab.ru/other/orphus/.
//
// Вы можете использовать этот скрипт и идею "как есть".
// Пожалуйста, не удаляте эти комментарии.

var orfo = new Object;

	orfo.email      = "orfo@rsdn.ru";
	orfo.hq         = "http://orphus.dklab.ru"; 
	orfo.img        = "/Images/orfo.gif";
	orfo.contlen    = 10;
	orfo.contunit   = "word";
	orfo.seltag1    = "<!!!>";
	orfo.seltag2    = "<!!!>";
	orfo.version    = "2.2";
	orfo.ready      = false;
	orfo.alt        = "Выделите орфографическую ошибку мышью и нажмите Ctrl+Enter. Сделаем язык чище!";
	orfo.badbrowser = "Ваш браузер не поддерживает возможность перехвата выделенного текста. Возможно, слишком стара\я верси\я, а возможно, еще кака\я-нибудь ошибка.";
	orfo.toobig     = "Вы выбрали слишком большой объем текста!";
	orfo.thanks     = "Спасибо за сотрудничество!";
	orfo.subject    = "Орфографическая ошибка";
	orfo.docmsg     = "Документ:";
	orfo.intextmsg  = "Орфографическая ошибка в тексте:";
	orfo.ifsendmsg  = "Послать сообщение об ошибке автору ("+orfo.email+")?\nВаш браузер останется на той же странице.";
	orfo.gohome     = "Перейти на домашнюю страницу системы Orfo?";
	orfo.author     = "Система Orfo v"+orfo.version+". Автор: Дмитрий Котеров.";
	orfo.comment    = "Комментарий: ";
	orfo.comment_prompt = "Поясните, что именно здесь неправильно (нажмите cancel если не хотите пояснять)";
	orfo.comment_default = "";

	document.writeln(
	'<form name=orfo_form target=orfo_frame action="'+orfo.hq+'/" method=post>' +
		'<input type=hidden name="email" value="'+orfo.email+'">' +
		'<input type=hidden name="subject" value="'+orfo.subject+'">' +
		'<input type=hidden name="Referrer" value="">' +
		'<input type=hidden name="Address" value="">' +
		'<input type=hidden name="Context" value="">' +
	'</form>' +
	'	<iframe name=orfo_frame valign=top width=1 height=1 border=0 style="position:absolute;visibility:hidden"></iframe>' +
		'<table width=1 cellpadding=0 cellspacing=0 border=0 bgcolor=9999FF>' +
			'<tr>' +
				'<td>'+
					'<a onClick="return orfo_imgclick()" target=_blank href="'+orfo.hq+'/"><img src="'+orfo.img+'" alt="'+orfo.alt+'" title="'+orfo.alt+'" __width=121 __height=21 border=0></a>' +
				'</td>' +
			'</tr>' +
		'</table>' +
	''
	);
	orfo.ready = true;
	document.onkeypress = BODY_onkeypress;

function BODY_onkeypress(e)
{
	var pressed=0;
	if(!orfo.ready) return;
	var we=null;
	if(window.event) we=window.event;
	if(we) {
		// IE
		pressed=we.keyCode==10;
	} else if(e) {
		// NN
		pressed = 
			(e.which==10 && e.modifiers==2) || // NN4
			(e.keyCode==0 && e.charCode==106 && e.ctrlKey) ||
			(e.keyCode==13 && e.ctrlKey) // Mozilla
	}
	if(pressed) orfo_do();
}
function orfo_strip_tags(text)
{
	for(var s=0; s<text.length; s++) {
		if(text.charAt(s)=='<') {
			var e=text.indexOf('>',s); if(e<=0 || e==false) continue;	
			text=text.substring(0,s)+text.substring(e+1); s--;
		}
	}
	return text;
}
function orfo_strip_slashn(text)
{
	for(var s=0; s<text.length; s++) {
		if(text.charAt(s)=='\n' || text.charAt(s)=='\r') {
			text=text.substring(0,s)+" "+text.substring(s+1);
			s--;
		}
	}
	return text;
}
function orfo_do()
{
	var text=null, context=null;
	if(navigator.appName.indexOf("Netscape")!=-1 && eval(navigator.appVersion.substring(0,1))<5) {
		alert(orfo.badbrowser);
		return;
	}
	var w = /* parent? parent : */ window;
	var selection = null;
	if(w.getSelection) {
		context=text=w.getSelection();
	} else if(w.document.getSelection) {
		context=text=orfo_strip_tags(w.document.getSelection());
	} else {
		selection = w.document.selection;
	}
	if(selection) {
		var sel = text = selection.createRange().text;
		var s=0; while(text.charAt(s)==" " || text.charAt(s)=="\n") s++;
		var e=0; while(text.charAt(text.length-e-1)==" " || text.charAt(text.length-e-1)=="\n") e++;
		var rngA=selection.createRange();
		rngA.moveStart(orfo.contunit,-orfo.contlen);
		rngA.moveEnd("character",-text.length+s);
		var rngB=selection.createRange();
		rngB.moveEnd(orfo.contunit,orfo.contlen);
		rngB.moveStart("character",text.length-e);
		text    = text.substring(s,text.length-e);
		context = rngA.text+orfo.seltag1+text+orfo.seltag2+rngB.text;
	}
	if(text==null) { alert(orfo.badbrowser); return; }
	if(context.length>512) {
		alert(orfo.toobig);
		return;
	}
	var url = w.document.location;
	if(confirm(orfo.docmsg+"\n    "+url+"\n"+orfo.intextmsg+'\n    "'+orfo_strip_slashn(context)+'"\n\n'+orfo.ifsendmsg)) {
		var comment = orfo.comment_default;
		comment = prompt(orfo.comment_prompt, comment);
		if(comment!="")
		{
			orfo_send(text,url,context,comment);
			orfo_thanks(0);
		}
	}
}
function orfo_thanks(n)
{
	var s=orfo.thanks;
	if(n>20) return;
	if(!(n%5)) s=' ';
	window.status=s;
	setTimeout("orfo_thanks("+(n+1)+")",100);
}
function orfo_send(text,url,context,comment)
{
	var form=document.orfo_form;
	if(!form) return;
	if(!context) context=text;
	form["Address"].value=url;
	form["Context"].value=context + "\n\n" + orfo.comment + comment;
	form["Referrer"].value=top.document.location;
	form.submit();
}
function orfo_imgclick()
{
	return confirm(orfo.author+"\n\n"+orfo.alt+"\n\n"+orfo.gohome);
}
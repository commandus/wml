if (self==top)
{
	with(window.location){
		s="http://"+hostname+"/?"+pathname.substr(1);
		if(-1==pathname.indexOf("?")) s=s+search;
	}
	//s="<DIV><FONT style='color:#56789a;font-size:11pt;font-family:arial;font-weight:bold;'>&lt;&lt;</FONT><A href='"+s+"' target=_top><font face='tahoma' style='font-size:8pt'>�������� ����</font></A></DIV>";
	s="&lt;&lt;<A href='"+s+"' target=_top>��������&nbsp;����</A>&nbsp;";

	//s="<DIV><FONT style='color:#56789a;font-size:11pt;font-family:arial;font-weight:bold;'>&lt;&lt;</FONT><A href='"+s+"' target=_top><font face='tahoma' style='font-size:8pt'>��������&nbsp;����</font></A></DIV>";

	document.write(s);
}
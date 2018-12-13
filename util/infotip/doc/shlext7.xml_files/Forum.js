// RSDN.Forum.js

// NewMsg.aspx
function OpenSearch(text)
{
	window.open('/search/?q='+text);
}

function MozillaInsertText(element, text, pos) 
{
    element.value = element.value.slice(0,pos)+text+element.value.slice(pos);
}

// NewMsg.aspx
function AddTag(t1,t2)
{
	if (is_ie5up)
	{
		if (document.selection)
		{
	    document.forms.NewMsg.msg.focus();

		  var txt = document.forms.NewMsg.msg.value;
		  var str = document.selection.createRange();

		  if (str.text == "")
			{
			        str.text = t1 + t2;
		  }
			else if (txt.indexOf(str.text) >= 0)
			{
	        str.text = t1 + str.text + t2;
			}
			else
			{
			        document.forms.NewMsg.msg.value = txt + t1 + t2;
		        }
			str.select();
		}
	} 
	else if (is_nav4up)
	{
		var element = document.forms.NewMsg.msg;
		var sel_start = element.selectionStart;
		var sel_end = element.selectionEnd;
		MozillaInsertText(element, t1, sel_start);
		MozillaInsertText(element, t2, sel_end+t1.length);
		element.selectionStart = sel_start;
		element.selectionEnd = sel_end+t1.length+t2.length;
		element.focus();    
	}    
	else
	{
		document.forms.NewMsg.msg.value = document.forms.NewMsg.msg.value + t1 + t2;
	}
}

// NewMsg.aspx
function OpenBlockPView()
{
	OpenBlock("pview");

	if (is_ie5_5up)
	{
		var el = document.getElementById("pview");
		if (el._state == "hide")
		{
			el = document.getElementById("msg");
			el.style.height = "100%";
		}
		else
		{
			el = document.getElementById("msg");
			el.style.height = "";
		}
	}
}

// NewMsg.aspx
function OpenBlockTags()
{
	OpenBlock("tags");
	
	var el = document.getElementById("tags");
	SetOption(1, el.getAttribute("_state") != "hide");

	el = document.getElementById("nosmile");
	SetOption(2, el.checked);
}

// Message.aspx
function searchMSDN()
{
	if (document.selection)
	{
		var str = document.selection.createRange();
		if (str.text != "")
		{
			window.open("MSDNRef.aspx?ref=" + escape(str.text));
		}
		else
		{
			alert("Выделите нужную функцию и попробуйте ещё раз.");
		}
	}
	else
	{
		alert("Выделите нужную функцию и попробуйте ещё раз.");
	}
}

// Message.aspx
function RateMsg(mid,rate)
{
	var href = "/forum/Private/Rate.aspx?mid=" + mid + "&rate=" + rate;
	var opts = "height=170,width=350,menubar=no,status=no,toolbar=no,resizable=yes";

    if ("object" == typeof(window.screen)) {
		var top  = window.screen.height/2 - 75;
		var left = window.screen.width/2 - 120;
		opts = "left=" + left + ",top=" + top + "," + opts;
	}

	window.RateWindow = window.open(href,"RateWindow",opts);
}

function SubMsg(tid)
{
	var href = "/forum/Private/Subscr.aspx?tid=" + tid;
	var opts = "height=180,width=400,menubar=no,status=no,toolbar=no,resizable=yes";

    if ("object" == typeof(window.screen)) {
		var top  = window.screen.height/2 - 75;
		var left = window.screen.width/2 - 120;
		opts = ",left=" + left + ",top=" + top + "," + opts;
	}

	window.SubWindow = window.open(href,"SubWindow",opts);
}

function AddFav(mid)
{
	var href = "/Users/Private/AddFav.aspx?mid=" + mid;
	var opts = "height=130,width=380,menubar=no,status=no,toolbar=no,resizable=yes";

    if ("object" == typeof(window.screen)) {
		var top  = window.screen.height/2 - 75;
		var left = window.screen.width/2 - 120;
		opts = ",left=" + left + ",top=" + top + "," + opts;
	}

	window.FavWindow = window.open(href,"FavWindow",opts);
}

function FileUpload()
{
	var href = "/Tools/Private/FileList.aspx";
	var opts = "height=300,width=450,menubar=no,status=no,toolbar=no,resizable=yes,scrollbars";

    if ("object" == typeof(window.screen)) {
		var top  = window.screen.height/2 - 150;
		var left = window.screen.width/2 - 225;
		opts = ",left=" + left + ",top=" + top + "," + opts;
	}

	window.UploadWindow = window.open(href, "UploadWindow", opts);
}

window.FavWindow = null;
window.RateWindow = null;
window.SubWindow = null;
window.UploadWindow = null;
window.onunload = CloseMsgWindow;

// Message.aspx
function CloseMsgWindow()
{
	if (window.RateWindow   != null) window.RateWindow.close();
	if (window.SubWindow    != null) window.SubWindow.close();
	if (window.FavWindow    != null) window.FavWindow.close();
	if (window.UploadWindow != null) window.UploadWindow.close();
}

// MsgList.aspx
function frame_resize()
{
	if (window.parent != window && window.parent.frames["frameMsg"] != null)
	{
		var upper = document.body.clientHeight;
		var lower = window.parent.frames["frameMsg"].document.body.clientHeight;
		var percent = parseInt(upper * 100 / (upper + lower) + 0.5);
		
		SetCookie("pf",percent);
	}
}

// Message.aspx
function ShowMessageFrame(mid)
{
	if (parent.frames["frameMsg"] == null)
	{
		document.write("&nbsp;<a href='/forum/?mid="+mid+"' target=_self title='Показать положение в теме'><img src='images/showfr.gif' align='absmiddle' border=0 width='18px' height='14px'/></a>&nbsp;");
	}
}

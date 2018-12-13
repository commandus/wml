unit
  xHtml;
(*##*)
(*******************************************************************************
*                                                                             *
*   x  h  t  m  l                                                              *
*                                                                             *
*   Copyright © 2002- 2003 Andrei Ivanov. All rights reserved.                 *
*   wireless markup language classes                                          *
*   Conditional defines:                                                       *
*                                                                             *
*   Revisions    : Dec 15 2002                                                 *
*   Last fix     : Dec 15 2002                                                *
*   Lines        : 6216                                                        *
*   History      :                                                            *
*   Printed      : ---                                                         *
*                                                                             *
********************************************************************************)
(*##*)

interface
uses
  Classes, Windows, SysUtils, Controls, StrUtils,
  jclUnicode, customxml;

var
  DEF_XHtmL_TEXTWRAP: Boolean = True;

const
  ATTR_abbr: String[4] = 'abbr';
  ATTR_accept: String[6] = 'accept';
  ATTR_accept_charset: String[14] = 'accept-charset';
  ATTR_accesskey: String[9] = 'accesskey';
  ATTR_action: String[6] = 'action';
  ATTR_align: String[5] = 'align';
  ATTR_alink: String[5] = 'alink';
  ATTR_alt: String[3] = 'alt';
  ATTR_archive: String[7] = 'archive';
  ATTR_axis: String[4] = 'axis';
  ATTR_background: String[10] = 'background';
  ATTR_bgcolor: String[7] = 'bgcolor';
  ATTR_border: String[6] = 'border';
  ATTR_cellpadding: String[11] = 'cellpadding';
  ATTR_cellspacing: String[11] = 'cellspacing';
  ATTR_char: String[4] = 'char';
  ATTR_charoff: String[7] = 'charoff';
  ATTR_charset: String[7] = 'charset';
  ATTR_checked: String[7] = 'checked';
  ATTR_cite: String[4] = 'cite';
  ATTR_class: String[5] = 'class';
  ATTR_classid: String[7] = 'classid';
  ATTR_clear: String[5] = 'clear';
  ATTR_code: String[4] = 'code';
  ATTR_codebase: String[8] = 'codebase';
  ATTR_codetype: String[8] = 'codetype';
  ATTR_color: String[5] = 'color';
  ATTR_cols: String[4] = 'cols';
  ATTR_colspan: String[7] = 'colspan';
  ATTR_compact: String[7] = 'compact';
  ATTR_content: String[7] = 'content';
  ATTR_coords: String[6] = 'coords';
  ATTR_data: String[4] = 'data';
  ATTR_datetime: String[8] = 'datetime';
  ATTR_declare: String[7] = 'declare';
  ATTR_defer: String[5] = 'defer';
  ATTR_dir: String[3] = 'dir';
  ATTR_disabled: String[8] = 'disabled';
  ATTR_enctype: String[7] = 'enctype';
  ATTR_face: String[4] = 'face';
  ATTR_for: String[3] = 'for';
  ATTR_frame: String[5] = 'frame';
  ATTR_frameborder: String[11] = 'frameborder';
  ATTR_headers: String[7] = 'headers';
  ATTR_height: String[6] = 'height';
  ATTR_href: String[4] = 'href';
  ATTR_hreflang: String[8] = 'hreflang';
  ATTR_hspace: String[6] = 'hspace';
  ATTR_http_equiv: String[10] = 'http-equiv';
  ATTR_id: String[2] = 'id';
  ATTR_ismap: String[5] = 'ismap';
  ATTR_label: String[5] = 'label';
  ATTR_lang: String[4] = 'lang';
  ATTR_language: String[8] = 'language';
  ATTR_link: String[4] = 'link';
  ATTR_longdesc: String[8] = 'longdesc';
  ATTR_marginheight: String[12] = 'marginheight';
  ATTR_marginwidth: String[11] = 'marginwidth';
  ATTR_maxlength: String[9] = 'maxlength';
  ATTR_media: String[5] = 'media';
  ATTR_method: String[6] = 'method';
  ATTR_multiple: String[8] = 'multiple';
  ATTR_name: String[4] = 'name';
  ATTR_nohref: String[6] = 'nohref';
  ATTR_noshade: String[7] = 'noshade';
  ATTR_nowrap: String[6] = 'nowrap';
  ATTR_object: String[6] = 'object';
  ATTR_onblur: String[6] = 'onblur';
  ATTR_onchange: String[8] = 'onchange';
  ATTR_onclick: String[7] = 'onclick';
  ATTR_ondblclick: String[10] = 'ondblclick';
  ATTR_onfocus: String[7] = 'onfocus';
  ATTR_onkeydown: String[9] = 'onkeydown';
  ATTR_onkeypress: String[10] = 'onkeypress';
  ATTR_onkeyup: String[7] = 'onkeyup';
  ATTR_onload: String[6] = 'onload';
  ATTR_onmousedown: String[11] = 'onmousedown';
  ATTR_onmousemove: String[11] = 'onmousemove';
  ATTR_onmouseout: String[10] = 'onmouseout';
  ATTR_onmouseover: String[11] = 'onmouseover';
  ATTR_onmouseup: String[9] = 'onmouseup';
  ATTR_onreset: String[7] = 'onreset';
  ATTR_onselect: String[8] = 'onselect';
  ATTR_onsubmit: String[8] = 'onsubmit';
  ATTR_onunload: String[8] = 'onunload';
  ATTR_profile: String[7] = 'profile';
  ATTR_prompt: String[6] = 'prompt';
  ATTR_readonly: String[8] = 'readonly';
  ATTR_rel: String[3] = 'rel';
  ATTR_rev: String[3] = 'rev';
  ATTR_rows: String[4] = 'rows';
  ATTR_rowspan: String[7] = 'rowspan';
  ATTR_rules: String[5] = 'rules';
  ATTR_scheme: String[6] = 'scheme';
  ATTR_scope: String[5] = 'scope';
  ATTR_scrolling: String[9] = 'scrolling';
  ATTR_selected: String[8] = 'selected';
  ATTR_shape: String[5] = 'shape';
  ATTR_size: String[4] = 'size';
  ATTR_span: String[4] = 'span';
  ATTR_src: String[3] = 'src';
  ATTR_standby: String[7] = 'standby';
  ATTR_start: String[5] = 'start';
  ATTR_style: String[5] = 'style';
  ATTR_summary: String[7] = 'summary';
  ATTR_tabindex: String[8] = 'tabindex';
  ATTR_target: String[6] = 'target';
  ATTR_text: String[4] = 'text';
  ATTR_title: String[5] = 'title';
  ATTR_type: String[4] = 'type';
  ATTR_usemap: String[6] = 'usemap';
  ATTR_valign: String[6] = 'valign';
  ATTR_value: String[5] = 'value';
  ATTR_valuetype: String[9] = 'valuetype';
  ATTR_vlink: String[5] = 'vlink';
  ATTR_vspace: String[6] = 'vspace';
  ATTR_width: String[5] = 'width';
  ATTR_xml_lang: String[8] = 'xml:lang';
  ATTR_xml_space: String[9] = 'xml:space';
  ATTR_xmlns: String[5] = 'xmlns';

type
  THtmContainer = class(TxmlContainer)
  public
    constructor Create(ACollection: TCollection); override;
  end;

  THtmDocDesc = class(TDocDesc)
  public
    constructor Create(ACollection: TCollection); override;
    function CreateText(ALevel: Integer; AOptions: TFormatTextSet): WideString; override;
  end;

  THtmServerSide = class(TServerSide)
  public
    constructor Create(ACollection: TCollection); override;
  end;

  THtmPCData = class(TxmlPCData)
  public
    // return what aligmnment assigned in parent paragraph
    function TextAlignment: TAlignment; override;
    function TextWrap: Boolean; override;
    // return context of TWMLEm TWMLStrong TWMLB TWMLI TWMLU TWMLBig TWMLSmall elements
    function TextEmphasisis: TEmphasisis; override;
    function CreateText(ALevel: Integer; AOptions: TFormatTextSet): WideString; override;
  end;

  THtmBaseElement = class(TxmlElement)
  private
  protected
  public
    constructor Create(ACollection: TCollection); override;
  end;

  THtmBracket = class(TBracket)
  public
    constructor Create(ACollection: TCollection); override;
  end;

  THtmCommentedElement  = class(THtmBaseElement)
  private
  protected
  public
    constructor Create(ACollection: TCollection); override;
  end;

  THtmHtml = class(THtmCommentedElement)
  private
  protected
  public
    constructor Create(ACollection: TCollection); override;
  end;

  THtmHead = class(THtmCommentedElement)
  private
  protected
  public
    constructor Create(ACollection: TCollection); override;
  end;

  THtmTitle = class(THtmCommentedElement)
  private
  protected
  public
    constructor Create(ACollection: TCollection); override;
  end;

  THtmBase = class(THtmBaseElement)
  private
  protected
  public
    constructor Create(ACollection: TCollection); override;
  end;

  THtmMeta = class(THtmBaseElement)
  private
  protected
  public
    constructor Create(ACollection: TCollection); override;
  end;

  THtmLink = class(THtmBaseElement)
  private
  protected
  public
    constructor Create(ACollection: TCollection); override;
  end;

  THtmStyle = class(THtmCommentedElement)
  private
  protected
  public
    constructor Create(ACollection: TCollection); override;
  end;

  THtmScript = class(THtmCommentedElement)
  private
  protected
  public
    constructor Create(ACollection: TCollection); override;
  end;

  THtmNoscript = class(THtmCommentedElement)
  private
  protected
  public
    constructor Create(ACollection: TCollection); override;
  end;

  THtmIframe = class(THtmCommentedElement)
  private
  protected
  public
    constructor Create(ACollection: TCollection); override;
  end;

  THtmNoframes = class(THtmCommentedElement)
  private
  protected
  public
    constructor Create(ACollection: TCollection); override;
  end;

  THtmBody = class(THtmCommentedElement)
  private
  protected
  public
    constructor Create(ACollection: TCollection); override;
  end;

  THtmDiv = class(THtmCommentedElement)
  private
  protected
  public
    constructor Create(ACollection: TCollection); override;
  end;

  THtmP = class(THtmCommentedElement)
  private
  protected
  public
    constructor Create(ACollection: TCollection); override;
  end;

  THtmH1 = class(THtmCommentedElement)
  private
  protected
  public
    constructor Create(ACollection: TCollection); override;
  end;

  THtmH2 = class(THtmCommentedElement)
  private
  protected
  public
    constructor Create(ACollection: TCollection); override;
  end;

  THtmH3 = class(THtmCommentedElement)
  private
  protected
  public
    constructor Create(ACollection: TCollection); override;
  end;

  THtmH4 = class(THtmCommentedElement)
  private
  protected
  public
    constructor Create(ACollection: TCollection); override;
  end;

  THtmH5 = class(THtmCommentedElement)
  private
  protected
  public
    constructor Create(ACollection: TCollection); override;
  end;

  THtmH6 = class(THtmCommentedElement)
  private
  protected
  public
    constructor Create(ACollection: TCollection); override;
  end;

  THtmUl = class(THtmCommentedElement)
  private
  protected
  public
    constructor Create(ACollection: TCollection); override;
  end;

  THtmOl = class(THtmCommentedElement)
  private
  protected
  public
    constructor Create(ACollection: TCollection); override;
  end;

  THtmMenu = class(THtmCommentedElement)
  private
  protected
  public
    constructor Create(ACollection: TCollection); override;
  end;

  THtmDir = class(THtmCommentedElement)
  private
  protected
  public
    constructor Create(ACollection: TCollection); override;
  end;

  THtmLi = class(THtmCommentedElement)
  private
  protected
  public
    constructor Create(ACollection: TCollection); override;
  end;

  THtmDl = class(THtmCommentedElement)
  private
  protected
  public
    constructor Create(ACollection: TCollection); override;
  end;

  THtmDt = class(THtmCommentedElement)
  private
  protected
  public
    constructor Create(ACollection: TCollection); override;
  end;

  THtmDd = class(THtmCommentedElement)
  private
  protected
  public
    constructor Create(ACollection: TCollection); override;
  end;

  THtmAddress = class(THtmCommentedElement)
  private
  protected
  public
    constructor Create(ACollection: TCollection); override;
  end;

  THtmHr = class(THtmBaseElement)
  private
  protected
  public
    constructor Create(ACollection: TCollection); override;
  end;

  THtmPre = class(THtmCommentedElement)
  private
  protected
  public
    constructor Create(ACollection: TCollection); override;
  end;

  THtmBlockquote = class(THtmCommentedElement)
  private
  protected
  public
    constructor Create(ACollection: TCollection); override;
  end;

  THtmCenter = class(THtmCommentedElement)
  private
  protected
  public
    constructor Create(ACollection: TCollection); override;
  end;

  THtmIns = class(THtmCommentedElement)
  private
  protected
  public
    constructor Create(ACollection: TCollection); override;
  end;

  THtmDel = class(THtmCommentedElement)
  private
  protected
  public
    constructor Create(ACollection: TCollection); override;
  end;

  THtmA = class(THtmCommentedElement)
  private
  protected
  public
    constructor Create(ACollection: TCollection); override;
  end;

  THtmSpan = class(THtmCommentedElement)
  private
  protected
  public
    constructor Create(ACollection: TCollection); override;
  end;

  THtmBdo = class(THtmCommentedElement)
  private
  protected
  public
    constructor Create(ACollection: TCollection); override;
  end;

  THtmBr = class(THtmBaseElement)
  private
  protected
  public
    constructor Create(ACollection: TCollection); override;
  end;

  THtmEm = class(THtmCommentedElement)
  private
  protected
  public
    constructor Create(ACollection: TCollection); override;
  end;

  THtmStrong = class(THtmCommentedElement)
  private
  protected
  public
    constructor Create(ACollection: TCollection); override;
  end;

  THtmDfn = class(THtmCommentedElement)
  private
  protected
  public
    constructor Create(ACollection: TCollection); override;
  end;

  THtmCode = class(THtmCommentedElement)
  private
  protected
  public
    constructor Create(ACollection: TCollection); override;
  end;

  THtmSamp = class(THtmCommentedElement)
  private
  protected
  public
    constructor Create(ACollection: TCollection); override;
  end;

  THtmKbd = class(THtmCommentedElement)
  private
  protected
  public
    constructor Create(ACollection: TCollection); override;
  end;

  THtmVar = class(THtmCommentedElement)
  private
  protected
  public
    constructor Create(ACollection: TCollection); override;
  end;

  THtmCite = class(THtmCommentedElement)
  private
  protected
  public
    constructor Create(ACollection: TCollection); override;
  end;

  THtmAbbr = class(THtmCommentedElement)
  private
  protected
  public
    constructor Create(ACollection: TCollection); override;
  end;

  THtmAcronym = class(THtmCommentedElement)
  private
  protected
  public
    constructor Create(ACollection: TCollection); override;
  end;

  THtmQ = class(THtmCommentedElement)
  private
  protected
  public
    constructor Create(ACollection: TCollection); override;
  end;

  THtmSub = class(THtmCommentedElement)
  private
  protected
  public
    constructor Create(ACollection: TCollection); override;
  end;

  THtmSup = class(THtmCommentedElement)
  private
  protected
  public
    constructor Create(ACollection: TCollection); override;
  end;

  THtmTt = class(THtmCommentedElement)
  private
  protected
  public
    constructor Create(ACollection: TCollection); override;
  end;

  THtmI = class(THtmCommentedElement)
  private
  protected
  public
    constructor Create(ACollection: TCollection); override;
  end;

  THtmB = class(THtmCommentedElement)
  private
  protected
  public
    constructor Create(ACollection: TCollection); override;
  end;

  THtmBig = class(THtmCommentedElement)
  private
  protected
  public
    constructor Create(ACollection: TCollection); override;
  end;

  THtmSmall = class(THtmCommentedElement)
  private
  protected
  public
    constructor Create(ACollection: TCollection); override;
  end;

  THtmU = class(THtmCommentedElement)
  private
  protected
  public
    constructor Create(ACollection: TCollection); override;
  end;

  THtmS = class(THtmCommentedElement)
  private
  protected
  public
    constructor Create(ACollection: TCollection); override;
  end;

  THtmStrike = class(THtmCommentedElement)
  private
  protected
  public
    constructor Create(ACollection: TCollection); override;
  end;

  THtmBasefont = class(THtmBaseElement)
  private
  protected
  public
    constructor Create(ACollection: TCollection); override;
  end;

  THtmFont = class(THtmCommentedElement)
  private
  protected
  public
    constructor Create(ACollection: TCollection); override;
  end;

  THtmObject = class(THtmCommentedElement)
  private
  protected
  public
    constructor Create(ACollection: TCollection); override;
  end;

  THtmParam = class(THtmBaseElement)
  private
  protected
  public
    constructor Create(ACollection: TCollection); override;
  end;

  THtmApplet = class(THtmCommentedElement)
  private
  protected
  public
    constructor Create(ACollection: TCollection); override;
  end;

  THtmImg = class(THtmBaseElement)
  private
  protected
  public
    constructor Create(ACollection: TCollection); override;
  end;

  THtmMap = class(THtmCommentedElement)
  private
  protected
  public
    constructor Create(ACollection: TCollection); override;
  end;

  THtmArea = class(THtmBaseElement)
  private
  protected
  public
    constructor Create(ACollection: TCollection); override;
  end;

  THtmForm = class(THtmCommentedElement)
  private
  protected
  public
    constructor Create(ACollection: TCollection); override;
  end;

  THtmLabel = class(THtmCommentedElement)
  private
  protected
  public
    constructor Create(ACollection: TCollection); override;
  end;

  THtmInput = class(THtmBaseElement)
  private
  protected
  public
    constructor Create(ACollection: TCollection); override;
    function CreateText(ALevel: Integer; AOptions: TFormatTextSet): WideString; override;
  end;

  THtmSelect = class(THtmCommentedElement)
  private
  protected
  public
    constructor Create(ACollection: TCollection); override;
    function CreateText(ALevel: Integer; AOptions: TFormatTextSet): WideString; override;
  end;

  THtmOptgroup = class(THtmCommentedElement)
  private
  protected
  public
    constructor Create(ACollection: TCollection); override;
  end;

  THtmOption = class(THtmCommentedElement)
  private
  protected
  public
    constructor Create(ACollection: TCollection); override;
  end;

  THtmTextarea = class(THtmCommentedElement)
  private
  protected
  public
    constructor Create(ACollection: TCollection); override;
  end;

  THtmFieldset = class(THtmCommentedElement)
  private
  protected
  public
    constructor Create(ACollection: TCollection); override;
  end;

  THtmLegend = class(THtmCommentedElement)
  private
  protected
  public
    constructor Create(ACollection: TCollection); override;
  end;

  THtmButton = class(THtmCommentedElement)
  private
  protected
  public
    constructor Create(ACollection: TCollection); override;
  end;

  THtmIsindex = class(THtmBaseElement)
  private
  protected
  public
    constructor Create(ACollection: TCollection); override;
  end;

  THtmTable = class(THtmCommentedElement)
  private
  protected
  public
    constructor Create(ACollection: TCollection); override;
  end;

  THtmCaption = class(THtmCommentedElement)
  private
  protected
  public
    constructor Create(ACollection: TCollection); override;
  end;

  THtmThead = class(THtmCommentedElement)
  private
  protected
  public
    constructor Create(ACollection: TCollection); override;
  end;

  THtmTfoot = class(THtmCommentedElement)
  private
  protected
  public
    constructor Create(ACollection: TCollection); override;
  end;

  THtmTbody = class(THtmCommentedElement)
  private
  protected
  public
    constructor Create(ACollection: TCollection); override;
  end;

  THtmColgroup = class(THtmCommentedElement)
  private
  protected
  public
    constructor Create(ACollection: TCollection); override;
  end;

  THtmCol = class(THtmBaseElement)
  private
  protected
  public
    constructor Create(ACollection: TCollection); override;
  end;

  THtmTr = class(THtmCommentedElement)
  private
  protected
  public
    constructor Create(ACollection: TCollection); override;
  end;

  THtmTh = class(THtmCommentedElement)
  private
  protected
  public
    constructor Create(ACollection: TCollection); override;
  end;

  THtmTd = class(THtmCommentedElement)
  private
  protected
  public
    constructor Create(ACollection: TCollection); override;
  end;

// register xml schema used by xmlsupported

function RegisterXML(var AxmlDesc: TxmlClassDesc): Integer;

implementation

uses
  xmlParse; // for GetDocumentTitle() implementation - document is parsed

const
  // 156..252
  XHtmLElements: array [0..96] of TxmlElementClass = (
      THtmContainer, THtmBracket,
      THtmHtml, THtmhead, THtmtitle, THtmbase, THtmmeta,
      THtmlink, THtmstyle, THtmscript, THtmnoscript, THtmiframe,
      THtmnoframes, THtmbody, THtmp, THtmdiv, THtmh1,
      THtmh2, THtmh3, THtmh4, THtmh5, THtmh6,
      THtmul, THtmol, THtmmenu, THtmdir, THtmli,
      THtmdl, THtmdt, THtmdd, THtmaddress, THtmhr,
      THtmpre, THtmblockquote, THtmcenter, THtmins, THtmdel,
      THtma, THtmspan, THtmbdo, THtmbr, THtmem,
      THtmstrong, THtmdfn, THtmcode, THtmsamp, THtmkbd,
      THtmvar, THtmcite, THtmabbr, THtmacronym, THtmq,
      THtmsub, THtmsup, THtmtt, THtmi, THtmb,
      THtmbig, THtmsmall, THtmu, THtms, THtmstrike,
      THtmbasefont, THtmfont, THtmobject, THtmparam, THtmapplet,
      THtmimg, THtmmap, THtmarea, THtmform, THtmlabel,
      THtminput, THtmselect, THtmoptgroup, THtmoption, THtmtextarea,
      THtmfieldset, THtmlegend, THtmbutton, THtmisindex, THtmtable,
      THtmcaption, THtmthead, THtmtfoot, THtmtbody, THtmcolgroup,
      THtmcol, THtmtr, THtmth, THtmtd,
      THtmPCData, TxmlComment, TXMLDesc, THtmDocDesc, THtmServerSide, TxmlssScript);

// --------- THtmContainer ---------

constructor THtmContainer.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  FNestedElements.AddNew(THtmHtml, wciOne);
  FNestedElements.AddNew(THtmDocDesc, wciOneOrNone);

  if wcServerExtensions in xmlENV.xmlCapabilities
  then FNestedElements.AddNew(THtmServerSide, wciAny);
end;

// --------- THtmDocDesc ---------

constructor THtmDocDesc.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  FBinCode:= NOBINCODE;
  FAbstract:= False;
  // attribute collection
  FAttributes.AddAttribute('version', atCData, REQUIRED, '1.0', '1.0|1.1');
end;

//
function THtmDocDesc.CreateText(ALevel: Integer; AOptions: TFormatTextSet): WideString;
var
  t: String;
begin
  // left align
  t:= ValidateLevel(ALevel);

  Result:= t + Format('<!DOCTYPE xHtml PUBLIC "-//W3C//DTD XHtmL %s Transitional//EN" "http://www.w3.org/TR/xHtml1/DTD/xHtml1-transitional.dtd">',
    [FAttributes.ValueByName['version']]);
end;

// --------- THtmServerSide ---------

constructor THtmServerSide.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  FNestedElements.AddNew(THtmPCData, wciAny);
end;

// --------- THtmPCData ---------

// return what aligmnment assigned in parent paragraph
function THtmPCData.TextAlignment: TAlignment;
var
  p: THtmP;
  al: String;
begin
  Result:= DEFAULT_TEXTALIGNMENT;
  p:= THtmP(GetParentByClass(THtmP, THtmBody));
  if Assigned(p) then begin
    al:= p.Attributes.ValueByName['align'];
    if CompareText(al, 'left') = 0
    then Result:= taLeftJustify
    else if CompareText(al, 'right') = 0
      then Result:= taRightJustify
      else if CompareText(al, 'center') = 0
        then Result:= taCenter;
  end;
end;

// return what wrapping mode set in parent paragraph
function THtmPCData.TextWrap: Boolean;
var
  p: THtmP;
  wr: String;
begin
  Result:= DEF_XHtmL_TEXTWRAP;
  p:= THtmP(GetParentByClass(THtmP, THtmBody));
  if Assigned(p) then begin
    wr:= p.Attributes.ValueByName['mode'];
    Result:= CompareText(wr, 'wrap') = 0;
  end;
end;

// return context of THtmEm THtmStrong THtmB THtmI THtmU THtmBig THtmSmall elements
function THtmPCData.TextEmphasisis: TEmphasisis;
begin
  Result:= [];
  if Assigned(GetParentByClass(THtmEm, THtmP)) then begin
    Include(Result, emEm);
  end;
  if Assigned(GetParentByClass(THtmStrong, THtmP)) then begin
    Include(Result, emStrong);
  end;
  if Assigned(GetParentByClass(THtmB, THtmP)) then begin
    Include(Result, emB);
  end;
  if Assigned(GetParentByClass(THtmI, THtmP)) then begin
    Include(Result, emI);
  end;
  if Assigned(GetParentByClass(THtmU, THtmP)) then begin
    Include(Result, emU);
  end;
  if Assigned(GetParentByClass(THtmBig, THtmP)) then begin
    Include(Result, emBig);
  end;
  if Assigned(GetParentByClass(THtmSmall, THtmP)) then begin
    Include(Result, emSmall);
  end;
end;

function THtmPCData.CreateText(ALevel: Integer; AOptions: TFormatTextSet): WideString;
var
  p: TxmlElement;
begin
  p:= ParentElement;
  if Assigned(p) and (p.ClassType = THtmPre) then begin
    Result:= FAttributes.ValueByName['value'];
  end else Result:= inherited CreateText(ALevel, AOptions);
end;

// Htm declaration

constructor THtmBASEElement.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  // attributes
  // server extension
  if wcServerExtensions in xmlEnv.XMLCapabilities then begin
    FAttributes.AddAttribute('loop', atVData, IMPLIED, NODEFAULT, NOLIST);
    FAttributes.AddAttribute('id', atVData, IMPLIED, NODEFAULT, NOLIST);
    FAttributes.AddAttribute('first', atNumber, IMPLIED, NODEFAULT, NOLIST);
    FAttributes.AddAttribute('last', atNumber, IMPLIED, NODEFAULT, NOLIST);
    FAttributes.AddAttribute('move', atNumber, IMPLIED, NODEFAULT, NOLIST);

    FNestedElements.AddNew(ThtmBracket, wciAny);
  end;
  Self.FAbstract:= False;
end;

constructor THtmCommentedElement.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  FNestedElements.AddNew(TxmlComment, wciAny);
  FNestedElements.AddNew(TxmlSSScript, wciAny);
end;

constructor THtmHtml.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  // attributes
  FAttributes.AddAttribute(ATTR_lang, atNMTOKEN, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_xml_lang, atNMTOKEN, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_dir, atList, IMPLIED, NODEFAULT, 'ltr|rtl');
  FAttributes.AddAttribute(ATTR_id, atID, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_xmlns, atHREF, IMPLIED, 'http://www.w3.org/1999/xHtml', NOLIST);

  // nested elements
  FNestedElements.AddNew(THtmHead, wciOne);
  FNestedElements.AddNew(THtmBody, wciOne);

  if wcServerExtensions in xmlENV.xmlCapabilities
  then FNestedElements.AddNew(THtmServerSide, wciAny);
end;

constructor THtmhead.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  // attributes
  FAttributes.AddAttribute(ATTR_lang, atNMTOKEN, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_xml_lang, atNMTOKEN, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_dir, atList, IMPLIED, NODEFAULT, 'ltr|rtl');
  FAttributes.AddAttribute(ATTR_id, atID, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_profile, atHREF, IMPLIED, NODEFAULT, NOLIST);

  // nested elements
  FNestedElements.AddNew(THtmScript, wciAny);
  FNestedElements.AddNew(THtmStyle, wciAny);
  FNestedElements.AddNew(THtmMeta, wciAny);
  FNestedElements.AddNew(THtmLink, wciAny);
  FNestedElements.AddNew(THtmObject, wciAny);
  FNestedElements.AddNew(THtmIsindex, wciAny);
  FNestedElements.AddNew(THtmTitle, wciOneOrNone);
  FNestedElements.AddNew(THtmBase, wciOneOrNone);

  if wcServerExtensions in xmlENV.xmlCapabilities
  then FNestedElements.AddNew(THtmServerSide, wciAny);
end;

constructor THtmtitle.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  // attributes
  FAttributes.AddAttribute(ATTR_lang, atNMTOKEN, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_xml_lang, atNMTOKEN, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_dir, atList, IMPLIED, NODEFAULT, 'ltr|rtl');
  FAttributes.AddAttribute(ATTR_id, atID, IMPLIED, NODEFAULT, NOLIST);

  // nested elements
  FNestedElements.AddNew(THtmPCDATA, wciAny);

  if wcServerExtensions in xmlENV.xmlCapabilities
  then FNestedElements.AddNew(THtmServerSide, wciAny);
end;

constructor THtmbase.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  // attributes
  FAttributes.AddAttribute(ATTR_id, atID, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_href, atHREF, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_target, atNMTOKEN, IMPLIED, NODEFAULT, NOLIST);

  // EMPTY
end;

constructor THtmmeta.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  // attributes
  FAttributes.AddAttribute(ATTR_lang, atNMTOKEN, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_xml_lang, atNMTOKEN, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_dir, atList, IMPLIED, NODEFAULT, 'ltr|rtl');
  FAttributes.AddAttribute(ATTR_id, atID, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_http_equiv, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_name, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_content, atCDATA, REQUIRED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_scheme, atCDATA, IMPLIED, NODEFAULT, NOLIST);

  // EMPTY
end;

constructor THtmlink.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  // attributes
  FAttributes.AddAttribute(ATTR_id, atID, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_class, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_style, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_title, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_lang, atNMTOKEN, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_xml_lang, atNMTOKEN, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_dir, atList, IMPLIED, NODEFAULT, 'ltr|rtl');
  FAttributes.AddAttribute(ATTR_onclick, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_ondblclick, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmousedown, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseup, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseover, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmousemove, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseout, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeypress, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeydown, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeyup, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_charset, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_href, atHREF, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_hreflang, atNMTOKEN, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_type, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_rel, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_rev, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_media, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_target, atNMTOKEN, IMPLIED, NODEFAULT, NOLIST);

  // EMPTY
end;

constructor THtmstyle.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  // attributes
  FAttributes.AddAttribute(ATTR_lang, atNMTOKEN, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_xml_lang, atNMTOKEN, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_dir, atList, IMPLIED, NODEFAULT, 'ltr|rtl');
  FAttributes.AddAttribute(ATTR_id, atID, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_type, atCDATA, REQUIRED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_media, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_title, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_xml_space, atList, IMPLIED, NODEFAULT, 'preserve');

  // nested elements
  FNestedElements.AddNew(THtmPCDATA, wciOneOrNone);

  if wcServerExtensions in xmlENV.xmlCapabilities
  then FNestedElements.AddNew(THtmServerSide, wciAny);
end;

constructor THtmscript.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  // attributes
  FAttributes.AddAttribute(ATTR_id, atID, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_charset, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_type, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_language, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_src, atHREF, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_defer, atList, IMPLIED, NODEFAULT, 'defer');
  FAttributes.AddAttribute(ATTR_xml_space, atList, IMPLIED, NODEFAULT, 'preserve');

  // nested elements
  FNestedElements.AddNew(THtmPCDATA, wciOneOrNone);

  if wcServerExtensions in xmlENV.xmlCapabilities
  then FNestedElements.AddNew(THtmServerSide, wciAny);
end;

constructor THtmnoscript.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  // attributes
  FAttributes.AddAttribute(ATTR_id, atID, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_class, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_style, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_title, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_lang, atNMTOKEN, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_xml_lang, atNMTOKEN, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_dir, atList, IMPLIED, NODEFAULT, 'ltr|rtl');
  FAttributes.AddAttribute(ATTR_onclick, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_ondblclick, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmousedown, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseup, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseover, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmousemove, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseout, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeypress, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeydown, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeyup, atCDATA, IMPLIED, NODEFAULT, NOLIST);

  // nested elements
  FNestedElements.AddNew(THtmPCDATA, wciAny);
  FNestedElements.AddNew(THtmP, wciAny);
  FNestedElements.AddNew(THtmH1, wciAny);
  FNestedElements.AddNew(THtmH2, wciAny);
  FNestedElements.AddNew(THtmH3, wciAny);
  FNestedElements.AddNew(THtmH4, wciAny);
  FNestedElements.AddNew(THtmH5, wciAny);
  FNestedElements.AddNew(THtmH6, wciAny);
  FNestedElements.AddNew(THtmDiv, wciAny);
  FNestedElements.AddNew(THtmUl, wciAny);
  FNestedElements.AddNew(THtmOl, wciAny);
  FNestedElements.AddNew(THtmDl, wciAny);
  FNestedElements.AddNew(THtmMenu, wciAny);
  FNestedElements.AddNew(THtmDir, wciAny);
  FNestedElements.AddNew(THtmPre, wciAny);
  FNestedElements.AddNew(THtmHr, wciAny);
  FNestedElements.AddNew(THtmBlockquote, wciAny);
  FNestedElements.AddNew(THtmAddress, wciAny);
  FNestedElements.AddNew(THtmCenter, wciAny);
  FNestedElements.AddNew(THtmNoframes, wciAny);
  FNestedElements.AddNew(THtmIsindex, wciAny);
  FNestedElements.AddNew(THtmFieldset, wciAny);
  FNestedElements.AddNew(THtmTable, wciAny);
  FNestedElements.AddNew(THtmForm, wciAny);
  FNestedElements.AddNew(THtmA, wciAny);
  FNestedElements.AddNew(THtmBr, wciAny);
  FNestedElements.AddNew(THtmSpan, wciAny);
  FNestedElements.AddNew(THtmBdo, wciAny);
  FNestedElements.AddNew(THtmObject, wciAny);
  FNestedElements.AddNew(THtmApplet, wciAny);
  FNestedElements.AddNew(THtmImg, wciAny);
  FNestedElements.AddNew(THtmMap, wciAny);
  FNestedElements.AddNew(THtmIframe, wciAny);
  FNestedElements.AddNew(THtmTt, wciAny);
  FNestedElements.AddNew(THtmI, wciAny);
  FNestedElements.AddNew(THtmB, wciAny);
  FNestedElements.AddNew(THtmU, wciAny);
  FNestedElements.AddNew(THtmS, wciAny);
  FNestedElements.AddNew(THtmStrike, wciAny);
  FNestedElements.AddNew(THtmBig, wciAny);
  FNestedElements.AddNew(THtmSmall, wciAny);
  FNestedElements.AddNew(THtmFont, wciAny);
  FNestedElements.AddNew(THtmBasefont, wciAny);
  FNestedElements.AddNew(THtmEm, wciAny);
  FNestedElements.AddNew(THtmStrong, wciAny);
  FNestedElements.AddNew(THtmDfn, wciAny);
  FNestedElements.AddNew(THtmCode, wciAny);
  FNestedElements.AddNew(THtmQ, wciAny);
  FNestedElements.AddNew(THtmSamp, wciAny);
  FNestedElements.AddNew(THtmKbd, wciAny);
  FNestedElements.AddNew(THtmVar, wciAny);
  FNestedElements.AddNew(THtmCite, wciAny);
  FNestedElements.AddNew(THtmAbbr, wciAny);
  FNestedElements.AddNew(THtmAcronym, wciAny);
  FNestedElements.AddNew(THtmSub, wciAny);
  FNestedElements.AddNew(THtmSup, wciAny);
  FNestedElements.AddNew(THtmInput, wciAny);
  FNestedElements.AddNew(THtmSelect, wciAny);
  FNestedElements.AddNew(THtmTextarea, wciAny);
  FNestedElements.AddNew(THtmLabel, wciAny);
  FNestedElements.AddNew(THtmButton, wciAny);
  FNestedElements.AddNew(THtmNoscript, wciAny);
  FNestedElements.AddNew(THtmIns, wciAny);
  FNestedElements.AddNew(THtmDel, wciAny);
  FNestedElements.AddNew(THtmScript, wciAny);

  if wcServerExtensions in xmlENV.xmlCapabilities
  then FNestedElements.AddNew(THtmServerSide, wciAny);
end;

constructor THtmiframe.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  // attributes
  FAttributes.AddAttribute(ATTR_id, atID, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_class, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_style, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_title, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_longdesc, atHREF, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_name, atNMTOKEN, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_src, atHREF, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_frameborder, atList, IMPLIED, '1', '1|0');
  FAttributes.AddAttribute(ATTR_marginwidth, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_marginheight, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_scrolling, atList, IMPLIED, 'auto', 'yes|no|auto');
  FAttributes.AddAttribute(ATTR_align, atList, IMPLIED, NODEFAULT, 'top|middle|bottom|left|right');
  FAttributes.AddAttribute(ATTR_height, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_width, atCDATA, IMPLIED, NODEFAULT, NOLIST);

  // nested elements
  FNestedElements.AddNew(THtmPCDATA, wciAny);
  FNestedElements.AddNew(THtmP, wciAny);
  FNestedElements.AddNew(THtmH1, wciAny);
  FNestedElements.AddNew(THtmH2, wciAny);
  FNestedElements.AddNew(THtmH3, wciAny);
  FNestedElements.AddNew(THtmH4, wciAny);
  FNestedElements.AddNew(THtmH5, wciAny);
  FNestedElements.AddNew(THtmH6, wciAny);
  FNestedElements.AddNew(THtmDiv, wciAny);
  FNestedElements.AddNew(THtmUl, wciAny);
  FNestedElements.AddNew(THtmOl, wciAny);
  FNestedElements.AddNew(THtmDl, wciAny);
  FNestedElements.AddNew(THtmMenu, wciAny);
  FNestedElements.AddNew(THtmDir, wciAny);
  FNestedElements.AddNew(THtmPre, wciAny);
  FNestedElements.AddNew(THtmHr, wciAny);
  FNestedElements.AddNew(THtmBlockquote, wciAny);
  FNestedElements.AddNew(THtmAddress, wciAny);
  FNestedElements.AddNew(THtmCenter, wciAny);
  FNestedElements.AddNew(THtmNoframes, wciAny);
  FNestedElements.AddNew(THtmIsindex, wciAny);
  FNestedElements.AddNew(THtmFieldset, wciAny);
  FNestedElements.AddNew(THtmTable, wciAny);
  FNestedElements.AddNew(THtmForm, wciAny);
  FNestedElements.AddNew(THtmA, wciAny);
  FNestedElements.AddNew(THtmBr, wciAny);
  FNestedElements.AddNew(THtmSpan, wciAny);
  FNestedElements.AddNew(THtmBdo, wciAny);
  FNestedElements.AddNew(THtmObject, wciAny);
  FNestedElements.AddNew(THtmApplet, wciAny);
  FNestedElements.AddNew(THtmImg, wciAny);
  FNestedElements.AddNew(THtmMap, wciAny);
  FNestedElements.AddNew(THtmIframe, wciAny);
  FNestedElements.AddNew(THtmTt, wciAny);
  FNestedElements.AddNew(THtmI, wciAny);
  FNestedElements.AddNew(THtmB, wciAny);
  FNestedElements.AddNew(THtmU, wciAny);
  FNestedElements.AddNew(THtmS, wciAny);
  FNestedElements.AddNew(THtmStrike, wciAny);
  FNestedElements.AddNew(THtmBig, wciAny);
  FNestedElements.AddNew(THtmSmall, wciAny);
  FNestedElements.AddNew(THtmFont, wciAny);
  FNestedElements.AddNew(THtmBasefont, wciAny);
  FNestedElements.AddNew(THtmEm, wciAny);
  FNestedElements.AddNew(THtmStrong, wciAny);
  FNestedElements.AddNew(THtmDfn, wciAny);
  FNestedElements.AddNew(THtmCode, wciAny);
  FNestedElements.AddNew(THtmQ, wciAny);
  FNestedElements.AddNew(THtmSamp, wciAny);
  FNestedElements.AddNew(THtmKbd, wciAny);
  FNestedElements.AddNew(THtmVar, wciAny);
  FNestedElements.AddNew(THtmCite, wciAny);
  FNestedElements.AddNew(THtmAbbr, wciAny);
  FNestedElements.AddNew(THtmAcronym, wciAny);
  FNestedElements.AddNew(THtmSub, wciAny);
  FNestedElements.AddNew(THtmSup, wciAny);
  FNestedElements.AddNew(THtmInput, wciAny);
  FNestedElements.AddNew(THtmSelect, wciAny);
  FNestedElements.AddNew(THtmTextarea, wciAny);
  FNestedElements.AddNew(THtmLabel, wciAny);
  FNestedElements.AddNew(THtmButton, wciAny);
  FNestedElements.AddNew(THtmNoscript, wciAny);
  FNestedElements.AddNew(THtmIns, wciAny);
  FNestedElements.AddNew(THtmDel, wciAny);
  FNestedElements.AddNew(THtmScript, wciAny);

  if wcServerExtensions in xmlENV.xmlCapabilities
  then FNestedElements.AddNew(THtmServerSide, wciAny);
end;

constructor THtmnoframes.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  // attributes
  FAttributes.AddAttribute(ATTR_id, atID, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_class, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_style, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_title, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_lang, atNMTOKEN, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_xml_lang, atNMTOKEN, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_dir, atList, IMPLIED, NODEFAULT, 'ltr|rtl');
  FAttributes.AddAttribute(ATTR_onclick, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_ondblclick, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmousedown, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseup, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseover, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmousemove, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseout, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeypress, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeydown, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeyup, atCDATA, IMPLIED, NODEFAULT, NOLIST);

  // nested elements
  FNestedElements.AddNew(THtmPCDATA, wciAny);
  FNestedElements.AddNew(THtmP, wciAny);
  FNestedElements.AddNew(THtmH1, wciAny);
  FNestedElements.AddNew(THtmH2, wciAny);
  FNestedElements.AddNew(THtmH3, wciAny);
  FNestedElements.AddNew(THtmH4, wciAny);
  FNestedElements.AddNew(THtmH5, wciAny);
  FNestedElements.AddNew(THtmH6, wciAny);
  FNestedElements.AddNew(THtmDiv, wciAny);
  FNestedElements.AddNew(THtmUl, wciAny);
  FNestedElements.AddNew(THtmOl, wciAny);
  FNestedElements.AddNew(THtmDl, wciAny);
  FNestedElements.AddNew(THtmMenu, wciAny);
  FNestedElements.AddNew(THtmDir, wciAny);
  FNestedElements.AddNew(THtmPre, wciAny);
  FNestedElements.AddNew(THtmHr, wciAny);
  FNestedElements.AddNew(THtmBlockquote, wciAny);
  FNestedElements.AddNew(THtmAddress, wciAny);
  FNestedElements.AddNew(THtmCenter, wciAny);
  FNestedElements.AddNew(THtmNoframes, wciAny);
  FNestedElements.AddNew(THtmIsindex, wciAny);
  FNestedElements.AddNew(THtmFieldset, wciAny);
  FNestedElements.AddNew(THtmTable, wciAny);
  FNestedElements.AddNew(THtmForm, wciAny);
  FNestedElements.AddNew(THtmA, wciAny);
  FNestedElements.AddNew(THtmBr, wciAny);
  FNestedElements.AddNew(THtmSpan, wciAny);
  FNestedElements.AddNew(THtmBdo, wciAny);
  FNestedElements.AddNew(THtmObject, wciAny);
  FNestedElements.AddNew(THtmApplet, wciAny);
  FNestedElements.AddNew(THtmImg, wciAny);
  FNestedElements.AddNew(THtmMap, wciAny);
  FNestedElements.AddNew(THtmIframe, wciAny);
  FNestedElements.AddNew(THtmTt, wciAny);
  FNestedElements.AddNew(THtmI, wciAny);
  FNestedElements.AddNew(THtmB, wciAny);
  FNestedElements.AddNew(THtmU, wciAny);
  FNestedElements.AddNew(THtmS, wciAny);
  FNestedElements.AddNew(THtmStrike, wciAny);
  FNestedElements.AddNew(THtmBig, wciAny);
  FNestedElements.AddNew(THtmSmall, wciAny);
  FNestedElements.AddNew(THtmFont, wciAny);
  FNestedElements.AddNew(THtmBasefont, wciAny);
  FNestedElements.AddNew(THtmEm, wciAny);
  FNestedElements.AddNew(THtmStrong, wciAny);
  FNestedElements.AddNew(THtmDfn, wciAny);
  FNestedElements.AddNew(THtmCode, wciAny);
  FNestedElements.AddNew(THtmQ, wciAny);
  FNestedElements.AddNew(THtmSamp, wciAny);
  FNestedElements.AddNew(THtmKbd, wciAny);
  FNestedElements.AddNew(THtmVar, wciAny);
  FNestedElements.AddNew(THtmCite, wciAny);
  FNestedElements.AddNew(THtmAbbr, wciAny);
  FNestedElements.AddNew(THtmAcronym, wciAny);
  FNestedElements.AddNew(THtmSub, wciAny);
  FNestedElements.AddNew(THtmSup, wciAny);
  FNestedElements.AddNew(THtmInput, wciAny);
  FNestedElements.AddNew(THtmSelect, wciAny);
  FNestedElements.AddNew(THtmTextarea, wciAny);
  FNestedElements.AddNew(THtmLabel, wciAny);
  FNestedElements.AddNew(THtmButton, wciAny);
  FNestedElements.AddNew(THtmNoscript, wciAny);
  FNestedElements.AddNew(THtmIns, wciAny);
  FNestedElements.AddNew(THtmDel, wciAny);
  FNestedElements.AddNew(THtmScript, wciAny);

  if wcServerExtensions in xmlENV.xmlCapabilities
  then FNestedElements.AddNew(THtmServerSide, wciAny);
end;

constructor THtmbody.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  // attributes
  FAttributes.AddAttribute(ATTR_id, atID, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_class, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_style, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_title, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_lang, atNMTOKEN, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_xml_lang, atNMTOKEN, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_dir, atList, IMPLIED, NODEFAULT, 'ltr|rtl');
  FAttributes.AddAttribute(ATTR_onclick, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_ondblclick, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmousedown, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseup, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseover, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmousemove, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseout, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeypress, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeydown, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeyup, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onload, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onunload, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_background, atHREF, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_bgcolor, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_text, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_link, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_vlink, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_alink, atCDATA, IMPLIED, NODEFAULT, NOLIST);

  // nested elements
  FNestedElements.AddNew(THtmPCDATA, wciAny);
  FNestedElements.AddNew(THtmP, wciAny);
  FNestedElements.AddNew(THtmH1, wciAny);
  FNestedElements.AddNew(THtmH2, wciAny);
  FNestedElements.AddNew(THtmH3, wciAny);
  FNestedElements.AddNew(THtmH4, wciAny);
  FNestedElements.AddNew(THtmH5, wciAny);
  FNestedElements.AddNew(THtmH6, wciAny);
  FNestedElements.AddNew(THtmDiv, wciAny);
  FNestedElements.AddNew(THtmUl, wciAny);
  FNestedElements.AddNew(THtmOl, wciAny);
  FNestedElements.AddNew(THtmDl, wciAny);
  FNestedElements.AddNew(THtmMenu, wciAny);
  FNestedElements.AddNew(THtmDir, wciAny);
  FNestedElements.AddNew(THtmPre, wciAny);
  FNestedElements.AddNew(THtmHr, wciAny);
  FNestedElements.AddNew(THtmBlockquote, wciAny);
  FNestedElements.AddNew(THtmAddress, wciAny);
  FNestedElements.AddNew(THtmCenter, wciAny);
  FNestedElements.AddNew(THtmNoframes, wciAny);
  FNestedElements.AddNew(THtmIsindex, wciAny);
  FNestedElements.AddNew(THtmFieldset, wciAny);
  FNestedElements.AddNew(THtmTable, wciAny);
  FNestedElements.AddNew(THtmForm, wciAny);
  FNestedElements.AddNew(THtmA, wciAny);
  FNestedElements.AddNew(THtmBr, wciAny);
  FNestedElements.AddNew(THtmSpan, wciAny);
  FNestedElements.AddNew(THtmBdo, wciAny);
  FNestedElements.AddNew(THtmObject, wciAny);
  FNestedElements.AddNew(THtmApplet, wciAny);
  FNestedElements.AddNew(THtmImg, wciAny);
  FNestedElements.AddNew(THtmMap, wciAny);
  FNestedElements.AddNew(THtmIframe, wciAny);
  FNestedElements.AddNew(THtmTt, wciAny);
  FNestedElements.AddNew(THtmI, wciAny);
  FNestedElements.AddNew(THtmB, wciAny);
  FNestedElements.AddNew(THtmU, wciAny);
  FNestedElements.AddNew(THtmS, wciAny);
  FNestedElements.AddNew(THtmStrike, wciAny);
  FNestedElements.AddNew(THtmBig, wciAny);
  FNestedElements.AddNew(THtmSmall, wciAny);
  FNestedElements.AddNew(THtmFont, wciAny);
  FNestedElements.AddNew(THtmBasefont, wciAny);
  FNestedElements.AddNew(THtmEm, wciAny);
  FNestedElements.AddNew(THtmStrong, wciAny);
  FNestedElements.AddNew(THtmDfn, wciAny);
  FNestedElements.AddNew(THtmCode, wciAny);
  FNestedElements.AddNew(THtmQ, wciAny);
  FNestedElements.AddNew(THtmSamp, wciAny);
  FNestedElements.AddNew(THtmKbd, wciAny);
  FNestedElements.AddNew(THtmVar, wciAny);
  FNestedElements.AddNew(THtmCite, wciAny);
  FNestedElements.AddNew(THtmAbbr, wciAny);
  FNestedElements.AddNew(THtmAcronym, wciAny);
  FNestedElements.AddNew(THtmSub, wciAny);
  FNestedElements.AddNew(THtmSup, wciAny);
  FNestedElements.AddNew(THtmInput, wciAny);
  FNestedElements.AddNew(THtmSelect, wciAny);
  FNestedElements.AddNew(THtmTextarea, wciAny);
  FNestedElements.AddNew(THtmLabel, wciAny);
  FNestedElements.AddNew(THtmButton, wciAny);
  FNestedElements.AddNew(THtmNoscript, wciAny);
  FNestedElements.AddNew(THtmIns, wciAny);
  FNestedElements.AddNew(THtmDel, wciAny);
  FNestedElements.AddNew(THtmScript, wciAny);

  if wcServerExtensions in xmlENV.xmlCapabilities
  then FNestedElements.AddNew(THtmServerSide, wciAny);
end;

constructor THtmdiv.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  // attributes
  FAttributes.AddAttribute(ATTR_id, atID, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_class, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_style, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_title, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_lang, atNMTOKEN, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_xml_lang, atNMTOKEN, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_dir, atList, IMPLIED, NODEFAULT, 'ltr|rtl');
  FAttributes.AddAttribute(ATTR_onclick, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_ondblclick, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmousedown, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseup, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseover, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmousemove, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseout, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeypress, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeydown, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeyup, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_align, atList, IMPLIED, NODEFAULT, 'left|center|right|justify');

  // nested elements
  FNestedElements.AddNew(THtmPCDATA, wciAny);
  FNestedElements.AddNew(THtmP, wciAny);
  FNestedElements.AddNew(THtmH1, wciAny);
  FNestedElements.AddNew(THtmH2, wciAny);
  FNestedElements.AddNew(THtmH3, wciAny);
  FNestedElements.AddNew(THtmH4, wciAny);
  FNestedElements.AddNew(THtmH5, wciAny);
  FNestedElements.AddNew(THtmH6, wciAny);
  FNestedElements.AddNew(THtmDiv, wciAny);
  FNestedElements.AddNew(THtmUl, wciAny);
  FNestedElements.AddNew(THtmOl, wciAny);
  FNestedElements.AddNew(THtmDl, wciAny);
  FNestedElements.AddNew(THtmMenu, wciAny);
  FNestedElements.AddNew(THtmDir, wciAny);
  FNestedElements.AddNew(THtmPre, wciAny);
  FNestedElements.AddNew(THtmHr, wciAny);
  FNestedElements.AddNew(THtmBlockquote, wciAny);
  FNestedElements.AddNew(THtmAddress, wciAny);
  FNestedElements.AddNew(THtmCenter, wciAny);
  FNestedElements.AddNew(THtmNoframes, wciAny);
  FNestedElements.AddNew(THtmIsindex, wciAny);
  FNestedElements.AddNew(THtmFieldset, wciAny);
  FNestedElements.AddNew(THtmTable, wciAny);
  FNestedElements.AddNew(THtmForm, wciAny);
  FNestedElements.AddNew(THtmA, wciAny);
  FNestedElements.AddNew(THtmBr, wciAny);
  FNestedElements.AddNew(THtmSpan, wciAny);
  FNestedElements.AddNew(THtmBdo, wciAny);
  FNestedElements.AddNew(THtmObject, wciAny);
  FNestedElements.AddNew(THtmApplet, wciAny);
  FNestedElements.AddNew(THtmImg, wciAny);
  FNestedElements.AddNew(THtmMap, wciAny);
  FNestedElements.AddNew(THtmIframe, wciAny);
  FNestedElements.AddNew(THtmTt, wciAny);
  FNestedElements.AddNew(THtmI, wciAny);
  FNestedElements.AddNew(THtmB, wciAny);
  FNestedElements.AddNew(THtmU, wciAny);
  FNestedElements.AddNew(THtmS, wciAny);
  FNestedElements.AddNew(THtmStrike, wciAny);
  FNestedElements.AddNew(THtmBig, wciAny);
  FNestedElements.AddNew(THtmSmall, wciAny);
  FNestedElements.AddNew(THtmFont, wciAny);
  FNestedElements.AddNew(THtmBasefont, wciAny);
  FNestedElements.AddNew(THtmEm, wciAny);
  FNestedElements.AddNew(THtmStrong, wciAny);
  FNestedElements.AddNew(THtmDfn, wciAny);
  FNestedElements.AddNew(THtmCode, wciAny);
  FNestedElements.AddNew(THtmQ, wciAny);
  FNestedElements.AddNew(THtmSamp, wciAny);
  FNestedElements.AddNew(THtmKbd, wciAny);
  FNestedElements.AddNew(THtmVar, wciAny);
  FNestedElements.AddNew(THtmCite, wciAny);
  FNestedElements.AddNew(THtmAbbr, wciAny);
  FNestedElements.AddNew(THtmAcronym, wciAny);
  FNestedElements.AddNew(THtmSub, wciAny);
  FNestedElements.AddNew(THtmSup, wciAny);
  FNestedElements.AddNew(THtmInput, wciAny);
  FNestedElements.AddNew(THtmSelect, wciAny);
  FNestedElements.AddNew(THtmTextarea, wciAny);
  FNestedElements.AddNew(THtmLabel, wciAny);
  FNestedElements.AddNew(THtmButton, wciAny);
  FNestedElements.AddNew(THtmNoscript, wciAny);
  FNestedElements.AddNew(THtmIns, wciAny);
  FNestedElements.AddNew(THtmDel, wciAny);
  FNestedElements.AddNew(THtmScript, wciAny);

  if wcServerExtensions in xmlENV.xmlCapabilities
  then FNestedElements.AddNew(THtmServerSide, wciAny);
end;

constructor THtmp.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  // attributes
  FAttributes.AddAttribute(ATTR_id, atID, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_class, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_style, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_title, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_lang, atNMTOKEN, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_xml_lang, atNMTOKEN, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_dir, atList, IMPLIED, NODEFAULT, 'ltr|rtl');
  FAttributes.AddAttribute(ATTR_onclick, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_ondblclick, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmousedown, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseup, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseover, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmousemove, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseout, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeypress, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeydown, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeyup, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_align, atList, IMPLIED, NODEFAULT, 'left|center|right|justify');

  // nested elements
  FNestedElements.AddNew(THtmPCDATA, wciAny);
  FNestedElements.AddNew(THtmA, wciAny);
  FNestedElements.AddNew(THtmBr, wciAny);
  FNestedElements.AddNew(THtmSpan, wciAny);
  FNestedElements.AddNew(THtmBdo, wciAny);
  FNestedElements.AddNew(THtmObject, wciAny);
  FNestedElements.AddNew(THtmApplet, wciAny);
  FNestedElements.AddNew(THtmImg, wciAny);
  FNestedElements.AddNew(THtmMap, wciAny);
  FNestedElements.AddNew(THtmIframe, wciAny);
  FNestedElements.AddNew(THtmTt, wciAny);
  FNestedElements.AddNew(THtmI, wciAny);
  FNestedElements.AddNew(THtmB, wciAny);
  FNestedElements.AddNew(THtmU, wciAny);
  FNestedElements.AddNew(THtmS, wciAny);
  FNestedElements.AddNew(THtmStrike, wciAny);
  FNestedElements.AddNew(THtmBig, wciAny);
  FNestedElements.AddNew(THtmSmall, wciAny);
  FNestedElements.AddNew(THtmFont, wciAny);
  FNestedElements.AddNew(THtmBasefont, wciAny);
  FNestedElements.AddNew(THtmEm, wciAny);
  FNestedElements.AddNew(THtmStrong, wciAny);
  FNestedElements.AddNew(THtmDfn, wciAny);
  FNestedElements.AddNew(THtmCode, wciAny);
  FNestedElements.AddNew(THtmQ, wciAny);
  FNestedElements.AddNew(THtmSamp, wciAny);
  FNestedElements.AddNew(THtmKbd, wciAny);
  FNestedElements.AddNew(THtmVar, wciAny);
  FNestedElements.AddNew(THtmCite, wciAny);
  FNestedElements.AddNew(THtmAbbr, wciAny);
  FNestedElements.AddNew(THtmAcronym, wciAny);
  FNestedElements.AddNew(THtmSub, wciAny);
  FNestedElements.AddNew(THtmSup, wciAny);
  FNestedElements.AddNew(THtmInput, wciAny);
  FNestedElements.AddNew(THtmSelect, wciAny);
  FNestedElements.AddNew(THtmTextarea, wciAny);
  FNestedElements.AddNew(THtmLabel, wciAny);
  FNestedElements.AddNew(THtmButton, wciAny);
  FNestedElements.AddNew(THtmIns, wciAny);
  FNestedElements.AddNew(THtmDel, wciAny);
  FNestedElements.AddNew(THtmScript, wciAny);

  if wcServerExtensions in xmlENV.xmlCapabilities
  then FNestedElements.AddNew(THtmServerSide, wciAny);
end;

constructor THtmh1.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  // attributes
  FAttributes.AddAttribute(ATTR_id, atID, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_class, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_style, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_title, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_lang, atNMTOKEN, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_xml_lang, atNMTOKEN, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_dir, atList, IMPLIED, NODEFAULT, 'ltr|rtl');
  FAttributes.AddAttribute(ATTR_onclick, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_ondblclick, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmousedown, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseup, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseover, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmousemove, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseout, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeypress, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeydown, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeyup, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_align, atList, IMPLIED, NODEFAULT, 'left|center|right|justify');

  // nested elements
  FNestedElements.AddNew(THtmPCDATA, wciAny);
  FNestedElements.AddNew(THtmA, wciAny);
  FNestedElements.AddNew(THtmBr, wciAny);
  FNestedElements.AddNew(THtmSpan, wciAny);
  FNestedElements.AddNew(THtmBdo, wciAny);
  FNestedElements.AddNew(THtmObject, wciAny);
  FNestedElements.AddNew(THtmApplet, wciAny);
  FNestedElements.AddNew(THtmImg, wciAny);
  FNestedElements.AddNew(THtmMap, wciAny);
  FNestedElements.AddNew(THtmIframe, wciAny);
  FNestedElements.AddNew(THtmTt, wciAny);
  FNestedElements.AddNew(THtmI, wciAny);
  FNestedElements.AddNew(THtmB, wciAny);
  FNestedElements.AddNew(THtmU, wciAny);
  FNestedElements.AddNew(THtmS, wciAny);
  FNestedElements.AddNew(THtmStrike, wciAny);
  FNestedElements.AddNew(THtmBig, wciAny);
  FNestedElements.AddNew(THtmSmall, wciAny);
  FNestedElements.AddNew(THtmFont, wciAny);
  FNestedElements.AddNew(THtmBasefont, wciAny);
  FNestedElements.AddNew(THtmEm, wciAny);
  FNestedElements.AddNew(THtmStrong, wciAny);
  FNestedElements.AddNew(THtmDfn, wciAny);
  FNestedElements.AddNew(THtmCode, wciAny);
  FNestedElements.AddNew(THtmQ, wciAny);
  FNestedElements.AddNew(THtmSamp, wciAny);
  FNestedElements.AddNew(THtmKbd, wciAny);
  FNestedElements.AddNew(THtmVar, wciAny);
  FNestedElements.AddNew(THtmCite, wciAny);
  FNestedElements.AddNew(THtmAbbr, wciAny);
  FNestedElements.AddNew(THtmAcronym, wciAny);
  FNestedElements.AddNew(THtmSub, wciAny);
  FNestedElements.AddNew(THtmSup, wciAny);
  FNestedElements.AddNew(THtmInput, wciAny);
  FNestedElements.AddNew(THtmSelect, wciAny);
  FNestedElements.AddNew(THtmTextarea, wciAny);
  FNestedElements.AddNew(THtmLabel, wciAny);
  FNestedElements.AddNew(THtmButton, wciAny);
  FNestedElements.AddNew(THtmIns, wciAny);
  FNestedElements.AddNew(THtmDel, wciAny);
  FNestedElements.AddNew(THtmScript, wciAny);

  if wcServerExtensions in xmlENV.xmlCapabilities
  then FNestedElements.AddNew(THtmServerSide, wciAny);
end;

constructor THtmh2.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  // attributes
  FAttributes.AddAttribute(ATTR_id, atID, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_class, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_style, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_title, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_lang, atNMTOKEN, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_xml_lang, atNMTOKEN, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_dir, atList, IMPLIED, NODEFAULT, 'ltr|rtl');
  FAttributes.AddAttribute(ATTR_onclick, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_ondblclick, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmousedown, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseup, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseover, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmousemove, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseout, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeypress, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeydown, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeyup, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_align, atList, IMPLIED, NODEFAULT, 'left|center|right|justify');

  // nested elements
  FNestedElements.AddNew(THtmPCDATA, wciAny);
  FNestedElements.AddNew(THtmA, wciAny);
  FNestedElements.AddNew(THtmBr, wciAny);
  FNestedElements.AddNew(THtmSpan, wciAny);
  FNestedElements.AddNew(THtmBdo, wciAny);
  FNestedElements.AddNew(THtmObject, wciAny);
  FNestedElements.AddNew(THtmApplet, wciAny);
  FNestedElements.AddNew(THtmImg, wciAny);
  FNestedElements.AddNew(THtmMap, wciAny);
  FNestedElements.AddNew(THtmIframe, wciAny);
  FNestedElements.AddNew(THtmTt, wciAny);
  FNestedElements.AddNew(THtmI, wciAny);
  FNestedElements.AddNew(THtmB, wciAny);
  FNestedElements.AddNew(THtmU, wciAny);
  FNestedElements.AddNew(THtmS, wciAny);
  FNestedElements.AddNew(THtmStrike, wciAny);
  FNestedElements.AddNew(THtmBig, wciAny);
  FNestedElements.AddNew(THtmSmall, wciAny);
  FNestedElements.AddNew(THtmFont, wciAny);
  FNestedElements.AddNew(THtmBasefont, wciAny);
  FNestedElements.AddNew(THtmEm, wciAny);
  FNestedElements.AddNew(THtmStrong, wciAny);
  FNestedElements.AddNew(THtmDfn, wciAny);
  FNestedElements.AddNew(THtmCode, wciAny);
  FNestedElements.AddNew(THtmQ, wciAny);
  FNestedElements.AddNew(THtmSamp, wciAny);
  FNestedElements.AddNew(THtmKbd, wciAny);
  FNestedElements.AddNew(THtmVar, wciAny);
  FNestedElements.AddNew(THtmCite, wciAny);
  FNestedElements.AddNew(THtmAbbr, wciAny);
  FNestedElements.AddNew(THtmAcronym, wciAny);
  FNestedElements.AddNew(THtmSub, wciAny);
  FNestedElements.AddNew(THtmSup, wciAny);
  FNestedElements.AddNew(THtmInput, wciAny);
  FNestedElements.AddNew(THtmSelect, wciAny);
  FNestedElements.AddNew(THtmTextarea, wciAny);
  FNestedElements.AddNew(THtmLabel, wciAny);
  FNestedElements.AddNew(THtmButton, wciAny);
  FNestedElements.AddNew(THtmIns, wciAny);
  FNestedElements.AddNew(THtmDel, wciAny);
  FNestedElements.AddNew(THtmScript, wciAny);

  if wcServerExtensions in xmlENV.xmlCapabilities
  then FNestedElements.AddNew(THtmServerSide, wciAny);
end;

constructor THtmh3.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  // attributes
  FAttributes.AddAttribute(ATTR_id, atID, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_class, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_style, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_title, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_lang, atNMTOKEN, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_xml_lang, atNMTOKEN, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_dir, atList, IMPLIED, NODEFAULT, 'ltr|rtl');
  FAttributes.AddAttribute(ATTR_onclick, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_ondblclick, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmousedown, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseup, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseover, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmousemove, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseout, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeypress, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeydown, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeyup, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_align, atList, IMPLIED, NODEFAULT, 'left|center|right|justify');

  // nested elements
  FNestedElements.AddNew(THtmPCDATA, wciAny);
  FNestedElements.AddNew(THtmA, wciAny);
  FNestedElements.AddNew(THtmBr, wciAny);
  FNestedElements.AddNew(THtmSpan, wciAny);
  FNestedElements.AddNew(THtmBdo, wciAny);
  FNestedElements.AddNew(THtmObject, wciAny);
  FNestedElements.AddNew(THtmApplet, wciAny);
  FNestedElements.AddNew(THtmImg, wciAny);
  FNestedElements.AddNew(THtmMap, wciAny);
  FNestedElements.AddNew(THtmIframe, wciAny);
  FNestedElements.AddNew(THtmTt, wciAny);
  FNestedElements.AddNew(THtmI, wciAny);
  FNestedElements.AddNew(THtmB, wciAny);
  FNestedElements.AddNew(THtmU, wciAny);
  FNestedElements.AddNew(THtmS, wciAny);
  FNestedElements.AddNew(THtmStrike, wciAny);
  FNestedElements.AddNew(THtmBig, wciAny);
  FNestedElements.AddNew(THtmSmall, wciAny);
  FNestedElements.AddNew(THtmFont, wciAny);
  FNestedElements.AddNew(THtmBasefont, wciAny);
  FNestedElements.AddNew(THtmEm, wciAny);
  FNestedElements.AddNew(THtmStrong, wciAny);
  FNestedElements.AddNew(THtmDfn, wciAny);
  FNestedElements.AddNew(THtmCode, wciAny);
  FNestedElements.AddNew(THtmQ, wciAny);
  FNestedElements.AddNew(THtmSamp, wciAny);
  FNestedElements.AddNew(THtmKbd, wciAny);
  FNestedElements.AddNew(THtmVar, wciAny);
  FNestedElements.AddNew(THtmCite, wciAny);
  FNestedElements.AddNew(THtmAbbr, wciAny);
  FNestedElements.AddNew(THtmAcronym, wciAny);
  FNestedElements.AddNew(THtmSub, wciAny);
  FNestedElements.AddNew(THtmSup, wciAny);
  FNestedElements.AddNew(THtmInput, wciAny);
  FNestedElements.AddNew(THtmSelect, wciAny);
  FNestedElements.AddNew(THtmTextarea, wciAny);
  FNestedElements.AddNew(THtmLabel, wciAny);
  FNestedElements.AddNew(THtmButton, wciAny);
  FNestedElements.AddNew(THtmIns, wciAny);
  FNestedElements.AddNew(THtmDel, wciAny);
  FNestedElements.AddNew(THtmScript, wciAny);

  if wcServerExtensions in xmlENV.xmlCapabilities
  then FNestedElements.AddNew(THtmServerSide, wciAny);
end;

constructor THtmh4.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  // attributes
  FAttributes.AddAttribute(ATTR_id, atID, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_class, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_style, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_title, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_lang, atNMTOKEN, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_xml_lang, atNMTOKEN, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_dir, atList, IMPLIED, NODEFAULT, 'ltr|rtl');
  FAttributes.AddAttribute(ATTR_onclick, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_ondblclick, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmousedown, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseup, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseover, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmousemove, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseout, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeypress, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeydown, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeyup, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_align, atList, IMPLIED, NODEFAULT, 'left|center|right|justify');

  // nested elements
  FNestedElements.AddNew(THtmPCDATA, wciAny);
  FNestedElements.AddNew(THtmA, wciAny);
  FNestedElements.AddNew(THtmBr, wciAny);
  FNestedElements.AddNew(THtmSpan, wciAny);
  FNestedElements.AddNew(THtmBdo, wciAny);
  FNestedElements.AddNew(THtmObject, wciAny);
  FNestedElements.AddNew(THtmApplet, wciAny);
  FNestedElements.AddNew(THtmImg, wciAny);
  FNestedElements.AddNew(THtmMap, wciAny);
  FNestedElements.AddNew(THtmIframe, wciAny);
  FNestedElements.AddNew(THtmTt, wciAny);
  FNestedElements.AddNew(THtmI, wciAny);
  FNestedElements.AddNew(THtmB, wciAny);
  FNestedElements.AddNew(THtmU, wciAny);
  FNestedElements.AddNew(THtmS, wciAny);
  FNestedElements.AddNew(THtmStrike, wciAny);
  FNestedElements.AddNew(THtmBig, wciAny);
  FNestedElements.AddNew(THtmSmall, wciAny);
  FNestedElements.AddNew(THtmFont, wciAny);
  FNestedElements.AddNew(THtmBasefont, wciAny);
  FNestedElements.AddNew(THtmEm, wciAny);
  FNestedElements.AddNew(THtmStrong, wciAny);
  FNestedElements.AddNew(THtmDfn, wciAny);
  FNestedElements.AddNew(THtmCode, wciAny);
  FNestedElements.AddNew(THtmQ, wciAny);
  FNestedElements.AddNew(THtmSamp, wciAny);
  FNestedElements.AddNew(THtmKbd, wciAny);
  FNestedElements.AddNew(THtmVar, wciAny);
  FNestedElements.AddNew(THtmCite, wciAny);
  FNestedElements.AddNew(THtmAbbr, wciAny);
  FNestedElements.AddNew(THtmAcronym, wciAny);
  FNestedElements.AddNew(THtmSub, wciAny);
  FNestedElements.AddNew(THtmSup, wciAny);
  FNestedElements.AddNew(THtmInput, wciAny);
  FNestedElements.AddNew(THtmSelect, wciAny);
  FNestedElements.AddNew(THtmTextarea, wciAny);
  FNestedElements.AddNew(THtmLabel, wciAny);
  FNestedElements.AddNew(THtmButton, wciAny);
  FNestedElements.AddNew(THtmIns, wciAny);
  FNestedElements.AddNew(THtmDel, wciAny);
  FNestedElements.AddNew(THtmScript, wciAny);

  if wcServerExtensions in xmlENV.xmlCapabilities
  then FNestedElements.AddNew(THtmServerSide, wciAny);
end;

constructor THtmh5.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  // attributes
  FAttributes.AddAttribute(ATTR_id, atID, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_class, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_style, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_title, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_lang, atNMTOKEN, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_xml_lang, atNMTOKEN, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_dir, atList, IMPLIED, NODEFAULT, 'ltr|rtl');
  FAttributes.AddAttribute(ATTR_onclick, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_ondblclick, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmousedown, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseup, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseover, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmousemove, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseout, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeypress, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeydown, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeyup, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_align, atList, IMPLIED, NODEFAULT, 'left|center|right|justify');

  // nested elements
  FNestedElements.AddNew(THtmPCDATA, wciAny);
  FNestedElements.AddNew(THtmA, wciAny);
  FNestedElements.AddNew(THtmBr, wciAny);
  FNestedElements.AddNew(THtmSpan, wciAny);
  FNestedElements.AddNew(THtmBdo, wciAny);
  FNestedElements.AddNew(THtmObject, wciAny);
  FNestedElements.AddNew(THtmApplet, wciAny);
  FNestedElements.AddNew(THtmImg, wciAny);
  FNestedElements.AddNew(THtmMap, wciAny);
  FNestedElements.AddNew(THtmIframe, wciAny);
  FNestedElements.AddNew(THtmTt, wciAny);
  FNestedElements.AddNew(THtmI, wciAny);
  FNestedElements.AddNew(THtmB, wciAny);
  FNestedElements.AddNew(THtmU, wciAny);
  FNestedElements.AddNew(THtmS, wciAny);
  FNestedElements.AddNew(THtmStrike, wciAny);
  FNestedElements.AddNew(THtmBig, wciAny);
  FNestedElements.AddNew(THtmSmall, wciAny);
  FNestedElements.AddNew(THtmFont, wciAny);
  FNestedElements.AddNew(THtmBasefont, wciAny);
  FNestedElements.AddNew(THtmEm, wciAny);
  FNestedElements.AddNew(THtmStrong, wciAny);
  FNestedElements.AddNew(THtmDfn, wciAny);
  FNestedElements.AddNew(THtmCode, wciAny);
  FNestedElements.AddNew(THtmQ, wciAny);
  FNestedElements.AddNew(THtmSamp, wciAny);
  FNestedElements.AddNew(THtmKbd, wciAny);
  FNestedElements.AddNew(THtmVar, wciAny);
  FNestedElements.AddNew(THtmCite, wciAny);
  FNestedElements.AddNew(THtmAbbr, wciAny);
  FNestedElements.AddNew(THtmAcronym, wciAny);
  FNestedElements.AddNew(THtmSub, wciAny);
  FNestedElements.AddNew(THtmSup, wciAny);
  FNestedElements.AddNew(THtmInput, wciAny);
  FNestedElements.AddNew(THtmSelect, wciAny);
  FNestedElements.AddNew(THtmTextarea, wciAny);
  FNestedElements.AddNew(THtmLabel, wciAny);
  FNestedElements.AddNew(THtmButton, wciAny);
  FNestedElements.AddNew(THtmIns, wciAny);
  FNestedElements.AddNew(THtmDel, wciAny);
  FNestedElements.AddNew(THtmScript, wciAny);

  if wcServerExtensions in xmlENV.xmlCapabilities
  then FNestedElements.AddNew(THtmServerSide, wciAny);
end;

constructor THtmh6.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  // attributes
  FAttributes.AddAttribute(ATTR_id, atID, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_class, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_style, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_title, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_lang, atNMTOKEN, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_xml_lang, atNMTOKEN, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_dir, atList, IMPLIED, NODEFAULT, 'ltr|rtl');
  FAttributes.AddAttribute(ATTR_onclick, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_ondblclick, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmousedown, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseup, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseover, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmousemove, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseout, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeypress, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeydown, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeyup, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_align, atList, IMPLIED, NODEFAULT, 'left|center|right|justify');

  // nested elements
  FNestedElements.AddNew(THtmPCDATA, wciAny);
  FNestedElements.AddNew(THtmA, wciAny);
  FNestedElements.AddNew(THtmBr, wciAny);
  FNestedElements.AddNew(THtmSpan, wciAny);
  FNestedElements.AddNew(THtmBdo, wciAny);
  FNestedElements.AddNew(THtmObject, wciAny);
  FNestedElements.AddNew(THtmApplet, wciAny);
  FNestedElements.AddNew(THtmImg, wciAny);
  FNestedElements.AddNew(THtmMap, wciAny);
  FNestedElements.AddNew(THtmIframe, wciAny);
  FNestedElements.AddNew(THtmTt, wciAny);
  FNestedElements.AddNew(THtmI, wciAny);
  FNestedElements.AddNew(THtmB, wciAny);
  FNestedElements.AddNew(THtmU, wciAny);
  FNestedElements.AddNew(THtmS, wciAny);
  FNestedElements.AddNew(THtmStrike, wciAny);
  FNestedElements.AddNew(THtmBig, wciAny);
  FNestedElements.AddNew(THtmSmall, wciAny);
  FNestedElements.AddNew(THtmFont, wciAny);
  FNestedElements.AddNew(THtmBasefont, wciAny);
  FNestedElements.AddNew(THtmEm, wciAny);
  FNestedElements.AddNew(THtmStrong, wciAny);
  FNestedElements.AddNew(THtmDfn, wciAny);
  FNestedElements.AddNew(THtmCode, wciAny);
  FNestedElements.AddNew(THtmQ, wciAny);
  FNestedElements.AddNew(THtmSamp, wciAny);
  FNestedElements.AddNew(THtmKbd, wciAny);
  FNestedElements.AddNew(THtmVar, wciAny);
  FNestedElements.AddNew(THtmCite, wciAny);
  FNestedElements.AddNew(THtmAbbr, wciAny);
  FNestedElements.AddNew(THtmAcronym, wciAny);
  FNestedElements.AddNew(THtmSub, wciAny);
  FNestedElements.AddNew(THtmSup, wciAny);
  FNestedElements.AddNew(THtmInput, wciAny);
  FNestedElements.AddNew(THtmSelect, wciAny);
  FNestedElements.AddNew(THtmTextarea, wciAny);
  FNestedElements.AddNew(THtmLabel, wciAny);
  FNestedElements.AddNew(THtmButton, wciAny);
  FNestedElements.AddNew(THtmIns, wciAny);
  FNestedElements.AddNew(THtmDel, wciAny);
  FNestedElements.AddNew(THtmScript, wciAny);

  if wcServerExtensions in xmlENV.xmlCapabilities
  then FNestedElements.AddNew(THtmServerSide, wciAny);
end;

constructor THtmul.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  // attributes
  FAttributes.AddAttribute(ATTR_id, atID, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_class, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_style, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_title, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_lang, atNMTOKEN, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_xml_lang, atNMTOKEN, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_dir, atList, IMPLIED, NODEFAULT, 'ltr|rtl');
  FAttributes.AddAttribute(ATTR_onclick, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_ondblclick, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmousedown, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseup, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseover, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmousemove, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseout, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeypress, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeydown, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeyup, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_type, atList, IMPLIED, NODEFAULT, 'disc|square|circle');
  FAttributes.AddAttribute(ATTR_compact, atList, IMPLIED, NODEFAULT, 'compact');

  // nested elements
  FNestedElements.AddNew(THtmLi, wciOneOrMore);

  if wcServerExtensions in xmlENV.xmlCapabilities
  then FNestedElements.AddNew(THtmServerSide, wciAny);
end;

constructor THtmol.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  // attributes
  FAttributes.AddAttribute(ATTR_id, atID, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_class, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_style, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_title, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_lang, atNMTOKEN, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_xml_lang, atNMTOKEN, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_dir, atList, IMPLIED, NODEFAULT, 'ltr|rtl');
  FAttributes.AddAttribute(ATTR_onclick, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_ondblclick, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmousedown, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseup, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseover, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmousemove, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseout, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeypress, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeydown, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeyup, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_type, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_compact, atList, IMPLIED, NODEFAULT, 'compact');
  FAttributes.AddAttribute(ATTR_start, atCDATA, IMPLIED, NODEFAULT, NOLIST);

  // nested elements
  FNestedElements.AddNew(THtmLi, wciOneOrMore);

  if wcServerExtensions in xmlENV.xmlCapabilities
  then FNestedElements.AddNew(THtmServerSide, wciAny);
end;

constructor THtmmenu.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  // attributes
  FAttributes.AddAttribute(ATTR_id, atID, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_class, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_style, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_title, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_lang, atNMTOKEN, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_xml_lang, atNMTOKEN, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_dir, atList, IMPLIED, NODEFAULT, 'ltr|rtl');
  FAttributes.AddAttribute(ATTR_onclick, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_ondblclick, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmousedown, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseup, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseover, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmousemove, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseout, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeypress, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeydown, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeyup, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_compact, atList, IMPLIED, NODEFAULT, 'compact');

  // nested elements
  FNestedElements.AddNew(THtmLi, wciOneOrMore);

  if wcServerExtensions in xmlENV.xmlCapabilities
  then FNestedElements.AddNew(THtmServerSide, wciAny);
end;

constructor THtmdir.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  // attributes
  FAttributes.AddAttribute(ATTR_id, atID, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_class, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_style, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_title, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_lang, atNMTOKEN, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_xml_lang, atNMTOKEN, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_dir, atList, IMPLIED, NODEFAULT, 'ltr|rtl');
  FAttributes.AddAttribute(ATTR_onclick, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_ondblclick, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmousedown, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseup, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseover, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmousemove, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseout, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeypress, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeydown, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeyup, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_compact, atList, IMPLIED, NODEFAULT, 'compact');

  // nested elements
  FNestedElements.AddNew(THtmLi, wciOneOrMore);

  if wcServerExtensions in xmlENV.xmlCapabilities
  then FNestedElements.AddNew(THtmServerSide, wciAny);
end;

constructor THtmli.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  // attributes
  FAttributes.AddAttribute(ATTR_id, atID, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_class, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_style, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_title, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_lang, atNMTOKEN, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_xml_lang, atNMTOKEN, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_dir, atList, IMPLIED, NODEFAULT, 'ltr|rtl');
  FAttributes.AddAttribute(ATTR_onclick, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_ondblclick, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmousedown, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseup, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseover, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmousemove, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseout, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeypress, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeydown, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeyup, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_type, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_value, atCDATA, IMPLIED, NODEFAULT, NOLIST);

  // nested elements
  FNestedElements.AddNew(THtmPCDATA, wciAny);
  FNestedElements.AddNew(THtmP, wciAny);
  FNestedElements.AddNew(THtmH1, wciAny);
  FNestedElements.AddNew(THtmH2, wciAny);
  FNestedElements.AddNew(THtmH3, wciAny);
  FNestedElements.AddNew(THtmH4, wciAny);
  FNestedElements.AddNew(THtmH5, wciAny);
  FNestedElements.AddNew(THtmH6, wciAny);
  FNestedElements.AddNew(THtmDiv, wciAny);
  FNestedElements.AddNew(THtmUl, wciAny);
  FNestedElements.AddNew(THtmOl, wciAny);
  FNestedElements.AddNew(THtmDl, wciAny);
  FNestedElements.AddNew(THtmMenu, wciAny);
  FNestedElements.AddNew(THtmDir, wciAny);
  FNestedElements.AddNew(THtmPre, wciAny);
  FNestedElements.AddNew(THtmHr, wciAny);
  FNestedElements.AddNew(THtmBlockquote, wciAny);
  FNestedElements.AddNew(THtmAddress, wciAny);
  FNestedElements.AddNew(THtmCenter, wciAny);
  FNestedElements.AddNew(THtmNoframes, wciAny);
  FNestedElements.AddNew(THtmIsindex, wciAny);
  FNestedElements.AddNew(THtmFieldset, wciAny);
  FNestedElements.AddNew(THtmTable, wciAny);
  FNestedElements.AddNew(THtmForm, wciAny);
  FNestedElements.AddNew(THtmA, wciAny);
  FNestedElements.AddNew(THtmBr, wciAny);
  FNestedElements.AddNew(THtmSpan, wciAny);
  FNestedElements.AddNew(THtmBdo, wciAny);
  FNestedElements.AddNew(THtmObject, wciAny);
  FNestedElements.AddNew(THtmApplet, wciAny);
  FNestedElements.AddNew(THtmImg, wciAny);
  FNestedElements.AddNew(THtmMap, wciAny);
  FNestedElements.AddNew(THtmIframe, wciAny);
  FNestedElements.AddNew(THtmTt, wciAny);
  FNestedElements.AddNew(THtmI, wciAny);
  FNestedElements.AddNew(THtmB, wciAny);
  FNestedElements.AddNew(THtmU, wciAny);
  FNestedElements.AddNew(THtmS, wciAny);
  FNestedElements.AddNew(THtmStrike, wciAny);
  FNestedElements.AddNew(THtmBig, wciAny);
  FNestedElements.AddNew(THtmSmall, wciAny);
  FNestedElements.AddNew(THtmFont, wciAny);
  FNestedElements.AddNew(THtmBasefont, wciAny);
  FNestedElements.AddNew(THtmEm, wciAny);
  FNestedElements.AddNew(THtmStrong, wciAny);
  FNestedElements.AddNew(THtmDfn, wciAny);
  FNestedElements.AddNew(THtmCode, wciAny);
  FNestedElements.AddNew(THtmQ, wciAny);
  FNestedElements.AddNew(THtmSamp, wciAny);
  FNestedElements.AddNew(THtmKbd, wciAny);
  FNestedElements.AddNew(THtmVar, wciAny);
  FNestedElements.AddNew(THtmCite, wciAny);
  FNestedElements.AddNew(THtmAbbr, wciAny);
  FNestedElements.AddNew(THtmAcronym, wciAny);
  FNestedElements.AddNew(THtmSub, wciAny);
  FNestedElements.AddNew(THtmSup, wciAny);
  FNestedElements.AddNew(THtmInput, wciAny);
  FNestedElements.AddNew(THtmSelect, wciAny);
  FNestedElements.AddNew(THtmTextarea, wciAny);
  FNestedElements.AddNew(THtmLabel, wciAny);
  FNestedElements.AddNew(THtmButton, wciAny);
  FNestedElements.AddNew(THtmNoscript, wciAny);
  FNestedElements.AddNew(THtmIns, wciAny);
  FNestedElements.AddNew(THtmDel, wciAny);
  FNestedElements.AddNew(THtmScript, wciAny);

  if wcServerExtensions in xmlENV.xmlCapabilities
  then FNestedElements.AddNew(THtmServerSide, wciAny);
end;

constructor THtmdl.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  // attributes
  FAttributes.AddAttribute(ATTR_id, atID, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_class, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_style, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_title, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_lang, atNMTOKEN, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_xml_lang, atNMTOKEN, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_dir, atList, IMPLIED, NODEFAULT, 'ltr|rtl');
  FAttributes.AddAttribute(ATTR_onclick, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_ondblclick, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmousedown, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseup, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseover, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmousemove, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseout, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeypress, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeydown, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeyup, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_compact, atList, IMPLIED, NODEFAULT, 'compact');

  // nested elements
  FNestedElements.AddNew(THtmDt, wciOneOrMore);
  FNestedElements.AddNew(THtmDd, wciOneOrMore);

  if wcServerExtensions in xmlENV.xmlCapabilities
  then FNestedElements.AddNew(THtmServerSide, wciAny);
end;

constructor THtmdt.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  // attributes
  FAttributes.AddAttribute(ATTR_id, atID, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_class, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_style, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_title, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_lang, atNMTOKEN, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_xml_lang, atNMTOKEN, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_dir, atList, IMPLIED, NODEFAULT, 'ltr|rtl');
  FAttributes.AddAttribute(ATTR_onclick, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_ondblclick, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmousedown, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseup, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseover, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmousemove, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseout, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeypress, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeydown, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeyup, atCDATA, IMPLIED, NODEFAULT, NOLIST);

  // nested elements
  FNestedElements.AddNew(THtmPCDATA, wciAny);
  FNestedElements.AddNew(THtmA, wciAny);
  FNestedElements.AddNew(THtmBr, wciAny);
  FNestedElements.AddNew(THtmSpan, wciAny);
  FNestedElements.AddNew(THtmBdo, wciAny);
  FNestedElements.AddNew(THtmObject, wciAny);
  FNestedElements.AddNew(THtmApplet, wciAny);
  FNestedElements.AddNew(THtmImg, wciAny);
  FNestedElements.AddNew(THtmMap, wciAny);
  FNestedElements.AddNew(THtmIframe, wciAny);
  FNestedElements.AddNew(THtmTt, wciAny);
  FNestedElements.AddNew(THtmI, wciAny);
  FNestedElements.AddNew(THtmB, wciAny);
  FNestedElements.AddNew(THtmU, wciAny);
  FNestedElements.AddNew(THtmS, wciAny);
  FNestedElements.AddNew(THtmStrike, wciAny);
  FNestedElements.AddNew(THtmBig, wciAny);
  FNestedElements.AddNew(THtmSmall, wciAny);
  FNestedElements.AddNew(THtmFont, wciAny);
  FNestedElements.AddNew(THtmBasefont, wciAny);
  FNestedElements.AddNew(THtmEm, wciAny);
  FNestedElements.AddNew(THtmStrong, wciAny);
  FNestedElements.AddNew(THtmDfn, wciAny);
  FNestedElements.AddNew(THtmCode, wciAny);
  FNestedElements.AddNew(THtmQ, wciAny);
  FNestedElements.AddNew(THtmSamp, wciAny);
  FNestedElements.AddNew(THtmKbd, wciAny);
  FNestedElements.AddNew(THtmVar, wciAny);
  FNestedElements.AddNew(THtmCite, wciAny);
  FNestedElements.AddNew(THtmAbbr, wciAny);
  FNestedElements.AddNew(THtmAcronym, wciAny);
  FNestedElements.AddNew(THtmSub, wciAny);
  FNestedElements.AddNew(THtmSup, wciAny);
  FNestedElements.AddNew(THtmInput, wciAny);
  FNestedElements.AddNew(THtmSelect, wciAny);
  FNestedElements.AddNew(THtmTextarea, wciAny);
  FNestedElements.AddNew(THtmLabel, wciAny);
  FNestedElements.AddNew(THtmButton, wciAny);
  FNestedElements.AddNew(THtmIns, wciAny);
  FNestedElements.AddNew(THtmDel, wciAny);
  FNestedElements.AddNew(THtmScript, wciAny);

  if wcServerExtensions in xmlENV.xmlCapabilities
  then FNestedElements.AddNew(THtmServerSide, wciAny);
end;

constructor THtmdd.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  // attributes
  FAttributes.AddAttribute(ATTR_id, atID, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_class, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_style, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_title, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_lang, atNMTOKEN, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_xml_lang, atNMTOKEN, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_dir, atList, IMPLIED, NODEFAULT, 'ltr|rtl');
  FAttributes.AddAttribute(ATTR_onclick, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_ondblclick, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmousedown, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseup, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseover, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmousemove, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseout, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeypress, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeydown, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeyup, atCDATA, IMPLIED, NODEFAULT, NOLIST);

  // nested elements
  FNestedElements.AddNew(THtmPCDATA, wciAny);
  FNestedElements.AddNew(THtmP, wciAny);
  FNestedElements.AddNew(THtmH1, wciAny);
  FNestedElements.AddNew(THtmH2, wciAny);
  FNestedElements.AddNew(THtmH3, wciAny);
  FNestedElements.AddNew(THtmH4, wciAny);
  FNestedElements.AddNew(THtmH5, wciAny);
  FNestedElements.AddNew(THtmH6, wciAny);
  FNestedElements.AddNew(THtmDiv, wciAny);
  FNestedElements.AddNew(THtmUl, wciAny);
  FNestedElements.AddNew(THtmOl, wciAny);
  FNestedElements.AddNew(THtmDl, wciAny);
  FNestedElements.AddNew(THtmMenu, wciAny);
  FNestedElements.AddNew(THtmDir, wciAny);
  FNestedElements.AddNew(THtmPre, wciAny);
  FNestedElements.AddNew(THtmHr, wciAny);
  FNestedElements.AddNew(THtmBlockquote, wciAny);
  FNestedElements.AddNew(THtmAddress, wciAny);
  FNestedElements.AddNew(THtmCenter, wciAny);
  FNestedElements.AddNew(THtmNoframes, wciAny);
  FNestedElements.AddNew(THtmIsindex, wciAny);
  FNestedElements.AddNew(THtmFieldset, wciAny);
  FNestedElements.AddNew(THtmTable, wciAny);
  FNestedElements.AddNew(THtmForm, wciAny);
  FNestedElements.AddNew(THtmA, wciAny);
  FNestedElements.AddNew(THtmBr, wciAny);
  FNestedElements.AddNew(THtmSpan, wciAny);
  FNestedElements.AddNew(THtmBdo, wciAny);
  FNestedElements.AddNew(THtmObject, wciAny);
  FNestedElements.AddNew(THtmApplet, wciAny);
  FNestedElements.AddNew(THtmImg, wciAny);
  FNestedElements.AddNew(THtmMap, wciAny);
  FNestedElements.AddNew(THtmIframe, wciAny);
  FNestedElements.AddNew(THtmTt, wciAny);
  FNestedElements.AddNew(THtmI, wciAny);
  FNestedElements.AddNew(THtmB, wciAny);
  FNestedElements.AddNew(THtmU, wciAny);
  FNestedElements.AddNew(THtmS, wciAny);
  FNestedElements.AddNew(THtmStrike, wciAny);
  FNestedElements.AddNew(THtmBig, wciAny);
  FNestedElements.AddNew(THtmSmall, wciAny);
  FNestedElements.AddNew(THtmFont, wciAny);
  FNestedElements.AddNew(THtmBasefont, wciAny);
  FNestedElements.AddNew(THtmEm, wciAny);
  FNestedElements.AddNew(THtmStrong, wciAny);
  FNestedElements.AddNew(THtmDfn, wciAny);
  FNestedElements.AddNew(THtmCode, wciAny);
  FNestedElements.AddNew(THtmQ, wciAny);
  FNestedElements.AddNew(THtmSamp, wciAny);
  FNestedElements.AddNew(THtmKbd, wciAny);
  FNestedElements.AddNew(THtmVar, wciAny);
  FNestedElements.AddNew(THtmCite, wciAny);
  FNestedElements.AddNew(THtmAbbr, wciAny);
  FNestedElements.AddNew(THtmAcronym, wciAny);
  FNestedElements.AddNew(THtmSub, wciAny);
  FNestedElements.AddNew(THtmSup, wciAny);
  FNestedElements.AddNew(THtmInput, wciAny);
  FNestedElements.AddNew(THtmSelect, wciAny);
  FNestedElements.AddNew(THtmTextarea, wciAny);
  FNestedElements.AddNew(THtmLabel, wciAny);
  FNestedElements.AddNew(THtmButton, wciAny);
  FNestedElements.AddNew(THtmNoscript, wciAny);
  FNestedElements.AddNew(THtmIns, wciAny);
  FNestedElements.AddNew(THtmDel, wciAny);
  FNestedElements.AddNew(THtmScript, wciAny);

  if wcServerExtensions in xmlENV.xmlCapabilities
  then FNestedElements.AddNew(THtmServerSide, wciAny);
end;

constructor THtmaddress.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  // attributes
  FAttributes.AddAttribute(ATTR_id, atID, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_class, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_style, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_title, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_lang, atNMTOKEN, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_xml_lang, atNMTOKEN, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_dir, atList, IMPLIED, NODEFAULT, 'ltr|rtl');
  FAttributes.AddAttribute(ATTR_onclick, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_ondblclick, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmousedown, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseup, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseover, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmousemove, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseout, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeypress, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeydown, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeyup, atCDATA, IMPLIED, NODEFAULT, NOLIST);

  // nested elements
  FNestedElements.AddNew(THtmPCDATA, wciAny);
  FNestedElements.AddNew(THtmA, wciAny);
  FNestedElements.AddNew(THtmBr, wciAny);
  FNestedElements.AddNew(THtmSpan, wciAny);
  FNestedElements.AddNew(THtmBdo, wciAny);
  FNestedElements.AddNew(THtmObject, wciAny);
  FNestedElements.AddNew(THtmApplet, wciAny);
  FNestedElements.AddNew(THtmImg, wciAny);
  FNestedElements.AddNew(THtmMap, wciAny);
  FNestedElements.AddNew(THtmIframe, wciAny);
  FNestedElements.AddNew(THtmTt, wciAny);
  FNestedElements.AddNew(THtmI, wciAny);
  FNestedElements.AddNew(THtmB, wciAny);
  FNestedElements.AddNew(THtmU, wciAny);
  FNestedElements.AddNew(THtmS, wciAny);
  FNestedElements.AddNew(THtmStrike, wciAny);
  FNestedElements.AddNew(THtmBig, wciAny);
  FNestedElements.AddNew(THtmSmall, wciAny);
  FNestedElements.AddNew(THtmFont, wciAny);
  FNestedElements.AddNew(THtmBasefont, wciAny);
  FNestedElements.AddNew(THtmEm, wciAny);
  FNestedElements.AddNew(THtmStrong, wciAny);
  FNestedElements.AddNew(THtmDfn, wciAny);
  FNestedElements.AddNew(THtmCode, wciAny);
  FNestedElements.AddNew(THtmQ, wciAny);
  FNestedElements.AddNew(THtmSamp, wciAny);
  FNestedElements.AddNew(THtmKbd, wciAny);
  FNestedElements.AddNew(THtmVar, wciAny);
  FNestedElements.AddNew(THtmCite, wciAny);
  FNestedElements.AddNew(THtmAbbr, wciAny);
  FNestedElements.AddNew(THtmAcronym, wciAny);
  FNestedElements.AddNew(THtmSub, wciAny);
  FNestedElements.AddNew(THtmSup, wciAny);
  FNestedElements.AddNew(THtmInput, wciAny);
  FNestedElements.AddNew(THtmSelect, wciAny);
  FNestedElements.AddNew(THtmTextarea, wciAny);
  FNestedElements.AddNew(THtmLabel, wciAny);
  FNestedElements.AddNew(THtmButton, wciAny);
  FNestedElements.AddNew(THtmIns, wciAny);
  FNestedElements.AddNew(THtmDel, wciAny);
  FNestedElements.AddNew(THtmScript, wciAny);
  FNestedElements.AddNew(THtmP, wciAny);

  if wcServerExtensions in xmlENV.xmlCapabilities
  then FNestedElements.AddNew(THtmServerSide, wciAny);
end;

constructor THtmhr.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  // attributes
  FAttributes.AddAttribute(ATTR_id, atID, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_class, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_style, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_title, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_lang, atNMTOKEN, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_xml_lang, atNMTOKEN, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_dir, atList, IMPLIED, NODEFAULT, 'ltr|rtl');
  FAttributes.AddAttribute(ATTR_onclick, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_ondblclick, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmousedown, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseup, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseover, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmousemove, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseout, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeypress, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeydown, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeyup, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_align, atList, IMPLIED, NODEFAULT, 'left|center|right');
  FAttributes.AddAttribute(ATTR_noshade, atList, IMPLIED, NODEFAULT, 'noshade');
  FAttributes.AddAttribute(ATTR_size, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_width, atCDATA, IMPLIED, NODEFAULT, NOLIST);

  // EMPTY
end;

constructor THtmpre.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  // attributes
  FAttributes.AddAttribute(ATTR_id, atID, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_class, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_style, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_title, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_lang, atNMTOKEN, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_xml_lang, atNMTOKEN, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_dir, atList, IMPLIED, NODEFAULT, 'ltr|rtl');
  FAttributes.AddAttribute(ATTR_onclick, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_ondblclick, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmousedown, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseup, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseover, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmousemove, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseout, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeypress, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeydown, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeyup, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_width, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_xml_space, atList, IMPLIED, 'preserve', NOLIST);

  // nested elements
  FNestedElements.AddNew(THtmPCDATA, wciAny);
  FNestedElements.AddNew(THtmA, wciAny);
  FNestedElements.AddNew(THtmBr, wciAny);
  FNestedElements.AddNew(THtmSpan, wciAny);
  FNestedElements.AddNew(THtmBdo, wciAny);
  FNestedElements.AddNew(THtmTt, wciAny);
  FNestedElements.AddNew(THtmI, wciAny);
  FNestedElements.AddNew(THtmB, wciAny);
  FNestedElements.AddNew(THtmU, wciAny);
  FNestedElements.AddNew(THtmS, wciAny);
  FNestedElements.AddNew(THtmStrike, wciAny);
  FNestedElements.AddNew(THtmEm, wciAny);
  FNestedElements.AddNew(THtmStrong, wciAny);
  FNestedElements.AddNew(THtmDfn, wciAny);
  FNestedElements.AddNew(THtmCode, wciAny);
  FNestedElements.AddNew(THtmQ, wciAny);
  FNestedElements.AddNew(THtmSamp, wciAny);
  FNestedElements.AddNew(THtmKbd, wciAny);
  FNestedElements.AddNew(THtmVar, wciAny);
  FNestedElements.AddNew(THtmCite, wciAny);
  FNestedElements.AddNew(THtmAbbr, wciAny);
  FNestedElements.AddNew(THtmAcronym, wciAny);
  FNestedElements.AddNew(THtmInput, wciAny);
  FNestedElements.AddNew(THtmSelect, wciAny);
  FNestedElements.AddNew(THtmTextarea, wciAny);
  FNestedElements.AddNew(THtmLabel, wciAny);
  FNestedElements.AddNew(THtmButton, wciAny);
  FNestedElements.AddNew(THtmIns, wciAny);
  FNestedElements.AddNew(THtmDel, wciAny);
  FNestedElements.AddNew(THtmScript, wciAny);

  if wcServerExtensions in xmlENV.xmlCapabilities
  then FNestedElements.AddNew(THtmServerSide, wciAny);
end;

constructor THtmblockquote.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  // attributes
  FAttributes.AddAttribute(ATTR_id, atID, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_class, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_style, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_title, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_lang, atNMTOKEN, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_xml_lang, atNMTOKEN, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_dir, atList, IMPLIED, NODEFAULT, 'ltr|rtl');
  FAttributes.AddAttribute(ATTR_onclick, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_ondblclick, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmousedown, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseup, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseover, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmousemove, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseout, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeypress, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeydown, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeyup, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_cite, atHREF, IMPLIED, NODEFAULT, NOLIST);

  // nested elements
  FNestedElements.AddNew(THtmPCDATA, wciAny);
  FNestedElements.AddNew(THtmP, wciAny);
  FNestedElements.AddNew(THtmH1, wciAny);
  FNestedElements.AddNew(THtmH2, wciAny);
  FNestedElements.AddNew(THtmH3, wciAny);
  FNestedElements.AddNew(THtmH4, wciAny);
  FNestedElements.AddNew(THtmH5, wciAny);
  FNestedElements.AddNew(THtmH6, wciAny);
  FNestedElements.AddNew(THtmDiv, wciAny);
  FNestedElements.AddNew(THtmUl, wciAny);
  FNestedElements.AddNew(THtmOl, wciAny);
  FNestedElements.AddNew(THtmDl, wciAny);
  FNestedElements.AddNew(THtmMenu, wciAny);
  FNestedElements.AddNew(THtmDir, wciAny);
  FNestedElements.AddNew(THtmPre, wciAny);
  FNestedElements.AddNew(THtmHr, wciAny);
  FNestedElements.AddNew(THtmBlockquote, wciAny);
  FNestedElements.AddNew(THtmAddress, wciAny);
  FNestedElements.AddNew(THtmCenter, wciAny);
  FNestedElements.AddNew(THtmNoframes, wciAny);
  FNestedElements.AddNew(THtmIsindex, wciAny);
  FNestedElements.AddNew(THtmFieldset, wciAny);
  FNestedElements.AddNew(THtmTable, wciAny);
  FNestedElements.AddNew(THtmForm, wciAny);
  FNestedElements.AddNew(THtmA, wciAny);
  FNestedElements.AddNew(THtmBr, wciAny);
  FNestedElements.AddNew(THtmSpan, wciAny);
  FNestedElements.AddNew(THtmBdo, wciAny);
  FNestedElements.AddNew(THtmObject, wciAny);
  FNestedElements.AddNew(THtmApplet, wciAny);
  FNestedElements.AddNew(THtmImg, wciAny);
  FNestedElements.AddNew(THtmMap, wciAny);
  FNestedElements.AddNew(THtmIframe, wciAny);
  FNestedElements.AddNew(THtmTt, wciAny);
  FNestedElements.AddNew(THtmI, wciAny);
  FNestedElements.AddNew(THtmB, wciAny);
  FNestedElements.AddNew(THtmU, wciAny);
  FNestedElements.AddNew(THtmS, wciAny);
  FNestedElements.AddNew(THtmStrike, wciAny);
  FNestedElements.AddNew(THtmBig, wciAny);
  FNestedElements.AddNew(THtmSmall, wciAny);
  FNestedElements.AddNew(THtmFont, wciAny);
  FNestedElements.AddNew(THtmBasefont, wciAny);
  FNestedElements.AddNew(THtmEm, wciAny);
  FNestedElements.AddNew(THtmStrong, wciAny);
  FNestedElements.AddNew(THtmDfn, wciAny);
  FNestedElements.AddNew(THtmCode, wciAny);
  FNestedElements.AddNew(THtmQ, wciAny);
  FNestedElements.AddNew(THtmSamp, wciAny);
  FNestedElements.AddNew(THtmKbd, wciAny);
  FNestedElements.AddNew(THtmVar, wciAny);
  FNestedElements.AddNew(THtmCite, wciAny);
  FNestedElements.AddNew(THtmAbbr, wciAny);
  FNestedElements.AddNew(THtmAcronym, wciAny);
  FNestedElements.AddNew(THtmSub, wciAny);
  FNestedElements.AddNew(THtmSup, wciAny);
  FNestedElements.AddNew(THtmInput, wciAny);
  FNestedElements.AddNew(THtmSelect, wciAny);
  FNestedElements.AddNew(THtmTextarea, wciAny);
  FNestedElements.AddNew(THtmLabel, wciAny);
  FNestedElements.AddNew(THtmButton, wciAny);
  FNestedElements.AddNew(THtmNoscript, wciAny);
  FNestedElements.AddNew(THtmIns, wciAny);
  FNestedElements.AddNew(THtmDel, wciAny);
  FNestedElements.AddNew(THtmScript, wciAny);

  if wcServerExtensions in xmlENV.xmlCapabilities
  then FNestedElements.AddNew(THtmServerSide, wciAny);
end;

constructor THtmcenter.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  // attributes
  FAttributes.AddAttribute(ATTR_id, atID, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_class, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_style, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_title, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_lang, atNMTOKEN, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_xml_lang, atNMTOKEN, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_dir, atList, IMPLIED, NODEFAULT, 'ltr|rtl');
  FAttributes.AddAttribute(ATTR_onclick, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_ondblclick, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmousedown, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseup, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseover, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmousemove, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseout, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeypress, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeydown, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeyup, atCDATA, IMPLIED, NODEFAULT, NOLIST);

  // nested elements
  FNestedElements.AddNew(THtmPCDATA, wciAny);
  FNestedElements.AddNew(THtmP, wciAny);
  FNestedElements.AddNew(THtmH1, wciAny);
  FNestedElements.AddNew(THtmH2, wciAny);
  FNestedElements.AddNew(THtmH3, wciAny);
  FNestedElements.AddNew(THtmH4, wciAny);
  FNestedElements.AddNew(THtmH5, wciAny);
  FNestedElements.AddNew(THtmH6, wciAny);
  FNestedElements.AddNew(THtmDiv, wciAny);
  FNestedElements.AddNew(THtmUl, wciAny);
  FNestedElements.AddNew(THtmOl, wciAny);
  FNestedElements.AddNew(THtmDl, wciAny);
  FNestedElements.AddNew(THtmMenu, wciAny);
  FNestedElements.AddNew(THtmDir, wciAny);
  FNestedElements.AddNew(THtmPre, wciAny);
  FNestedElements.AddNew(THtmHr, wciAny);
  FNestedElements.AddNew(THtmBlockquote, wciAny);
  FNestedElements.AddNew(THtmAddress, wciAny);
  FNestedElements.AddNew(THtmCenter, wciAny);
  FNestedElements.AddNew(THtmNoframes, wciAny);
  FNestedElements.AddNew(THtmIsindex, wciAny);
  FNestedElements.AddNew(THtmFieldset, wciAny);
  FNestedElements.AddNew(THtmTable, wciAny);
  FNestedElements.AddNew(THtmForm, wciAny);
  FNestedElements.AddNew(THtmA, wciAny);
  FNestedElements.AddNew(THtmBr, wciAny);
  FNestedElements.AddNew(THtmSpan, wciAny);
  FNestedElements.AddNew(THtmBdo, wciAny);
  FNestedElements.AddNew(THtmObject, wciAny);
  FNestedElements.AddNew(THtmApplet, wciAny);
  FNestedElements.AddNew(THtmImg, wciAny);
  FNestedElements.AddNew(THtmMap, wciAny);
  FNestedElements.AddNew(THtmIframe, wciAny);
  FNestedElements.AddNew(THtmTt, wciAny);
  FNestedElements.AddNew(THtmI, wciAny);
  FNestedElements.AddNew(THtmB, wciAny);
  FNestedElements.AddNew(THtmU, wciAny);
  FNestedElements.AddNew(THtmS, wciAny);
  FNestedElements.AddNew(THtmStrike, wciAny);
  FNestedElements.AddNew(THtmBig, wciAny);
  FNestedElements.AddNew(THtmSmall, wciAny);
  FNestedElements.AddNew(THtmFont, wciAny);
  FNestedElements.AddNew(THtmBasefont, wciAny);
  FNestedElements.AddNew(THtmEm, wciAny);
  FNestedElements.AddNew(THtmStrong, wciAny);
  FNestedElements.AddNew(THtmDfn, wciAny);
  FNestedElements.AddNew(THtmCode, wciAny);
  FNestedElements.AddNew(THtmQ, wciAny);
  FNestedElements.AddNew(THtmSamp, wciAny);
  FNestedElements.AddNew(THtmKbd, wciAny);
  FNestedElements.AddNew(THtmVar, wciAny);
  FNestedElements.AddNew(THtmCite, wciAny);
  FNestedElements.AddNew(THtmAbbr, wciAny);
  FNestedElements.AddNew(THtmAcronym, wciAny);
  FNestedElements.AddNew(THtmSub, wciAny);
  FNestedElements.AddNew(THtmSup, wciAny);
  FNestedElements.AddNew(THtmInput, wciAny);
  FNestedElements.AddNew(THtmSelect, wciAny);
  FNestedElements.AddNew(THtmTextarea, wciAny);
  FNestedElements.AddNew(THtmLabel, wciAny);
  FNestedElements.AddNew(THtmButton, wciAny);
  FNestedElements.AddNew(THtmNoscript, wciAny);
  FNestedElements.AddNew(THtmIns, wciAny);
  FNestedElements.AddNew(THtmDel, wciAny);
  FNestedElements.AddNew(THtmScript, wciAny);

  if wcServerExtensions in xmlENV.xmlCapabilities
  then FNestedElements.AddNew(THtmServerSide, wciAny);
end;

constructor THtmins.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  // attributes
  FAttributes.AddAttribute(ATTR_id, atID, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_class, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_style, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_title, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_lang, atNMTOKEN, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_xml_lang, atNMTOKEN, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_dir, atList, IMPLIED, NODEFAULT, 'ltr|rtl');
  FAttributes.AddAttribute(ATTR_onclick, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_ondblclick, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmousedown, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseup, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseover, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmousemove, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseout, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeypress, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeydown, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeyup, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_cite, atHREF, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_datetime, atCDATA, IMPLIED, NODEFAULT, NOLIST);

  // nested elements
  FNestedElements.AddNew(THtmPCDATA, wciAny);
  FNestedElements.AddNew(THtmP, wciAny);
  FNestedElements.AddNew(THtmH1, wciAny);
  FNestedElements.AddNew(THtmH2, wciAny);
  FNestedElements.AddNew(THtmH3, wciAny);
  FNestedElements.AddNew(THtmH4, wciAny);
  FNestedElements.AddNew(THtmH5, wciAny);
  FNestedElements.AddNew(THtmH6, wciAny);
  FNestedElements.AddNew(THtmDiv, wciAny);
  FNestedElements.AddNew(THtmUl, wciAny);
  FNestedElements.AddNew(THtmOl, wciAny);
  FNestedElements.AddNew(THtmDl, wciAny);
  FNestedElements.AddNew(THtmMenu, wciAny);
  FNestedElements.AddNew(THtmDir, wciAny);
  FNestedElements.AddNew(THtmPre, wciAny);
  FNestedElements.AddNew(THtmHr, wciAny);
  FNestedElements.AddNew(THtmBlockquote, wciAny);
  FNestedElements.AddNew(THtmAddress, wciAny);
  FNestedElements.AddNew(THtmCenter, wciAny);
  FNestedElements.AddNew(THtmNoframes, wciAny);
  FNestedElements.AddNew(THtmIsindex, wciAny);
  FNestedElements.AddNew(THtmFieldset, wciAny);
  FNestedElements.AddNew(THtmTable, wciAny);
  FNestedElements.AddNew(THtmForm, wciAny);
  FNestedElements.AddNew(THtmA, wciAny);
  FNestedElements.AddNew(THtmBr, wciAny);
  FNestedElements.AddNew(THtmSpan, wciAny);
  FNestedElements.AddNew(THtmBdo, wciAny);
  FNestedElements.AddNew(THtmObject, wciAny);
  FNestedElements.AddNew(THtmApplet, wciAny);
  FNestedElements.AddNew(THtmImg, wciAny);
  FNestedElements.AddNew(THtmMap, wciAny);
  FNestedElements.AddNew(THtmIframe, wciAny);
  FNestedElements.AddNew(THtmTt, wciAny);
  FNestedElements.AddNew(THtmI, wciAny);
  FNestedElements.AddNew(THtmB, wciAny);
  FNestedElements.AddNew(THtmU, wciAny);
  FNestedElements.AddNew(THtmS, wciAny);
  FNestedElements.AddNew(THtmStrike, wciAny);
  FNestedElements.AddNew(THtmBig, wciAny);
  FNestedElements.AddNew(THtmSmall, wciAny);
  FNestedElements.AddNew(THtmFont, wciAny);
  FNestedElements.AddNew(THtmBasefont, wciAny);
  FNestedElements.AddNew(THtmEm, wciAny);
  FNestedElements.AddNew(THtmStrong, wciAny);
  FNestedElements.AddNew(THtmDfn, wciAny);
  FNestedElements.AddNew(THtmCode, wciAny);
  FNestedElements.AddNew(THtmQ, wciAny);
  FNestedElements.AddNew(THtmSamp, wciAny);
  FNestedElements.AddNew(THtmKbd, wciAny);
  FNestedElements.AddNew(THtmVar, wciAny);
  FNestedElements.AddNew(THtmCite, wciAny);
  FNestedElements.AddNew(THtmAbbr, wciAny);
  FNestedElements.AddNew(THtmAcronym, wciAny);
  FNestedElements.AddNew(THtmSub, wciAny);
  FNestedElements.AddNew(THtmSup, wciAny);
  FNestedElements.AddNew(THtmInput, wciAny);
  FNestedElements.AddNew(THtmSelect, wciAny);
  FNestedElements.AddNew(THtmTextarea, wciAny);
  FNestedElements.AddNew(THtmLabel, wciAny);
  FNestedElements.AddNew(THtmButton, wciAny);
  FNestedElements.AddNew(THtmNoscript, wciAny);
  FNestedElements.AddNew(THtmIns, wciAny);
  FNestedElements.AddNew(THtmDel, wciAny);
  FNestedElements.AddNew(THtmScript, wciAny);

  if wcServerExtensions in xmlENV.xmlCapabilities
  then FNestedElements.AddNew(THtmServerSide, wciAny);
end;

constructor THtmdel.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  // attributes
  FAttributes.AddAttribute(ATTR_id, atID, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_class, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_style, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_title, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_lang, atNMTOKEN, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_xml_lang, atNMTOKEN, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_dir, atList, IMPLIED, NODEFAULT, 'ltr|rtl');
  FAttributes.AddAttribute(ATTR_onclick, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_ondblclick, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmousedown, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseup, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseover, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmousemove, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseout, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeypress, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeydown, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeyup, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_cite, atHREF, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_datetime, atCDATA, IMPLIED, NODEFAULT, NOLIST);

  // nested elements
  FNestedElements.AddNew(THtmPCDATA, wciAny);
  FNestedElements.AddNew(THtmP, wciAny);
  FNestedElements.AddNew(THtmH1, wciAny);
  FNestedElements.AddNew(THtmH2, wciAny);
  FNestedElements.AddNew(THtmH3, wciAny);
  FNestedElements.AddNew(THtmH4, wciAny);
  FNestedElements.AddNew(THtmH5, wciAny);
  FNestedElements.AddNew(THtmH6, wciAny);
  FNestedElements.AddNew(THtmDiv, wciAny);
  FNestedElements.AddNew(THtmUl, wciAny);
  FNestedElements.AddNew(THtmOl, wciAny);
  FNestedElements.AddNew(THtmDl, wciAny);
  FNestedElements.AddNew(THtmMenu, wciAny);
  FNestedElements.AddNew(THtmDir, wciAny);
  FNestedElements.AddNew(THtmPre, wciAny);
  FNestedElements.AddNew(THtmHr, wciAny);
  FNestedElements.AddNew(THtmBlockquote, wciAny);
  FNestedElements.AddNew(THtmAddress, wciAny);
  FNestedElements.AddNew(THtmCenter, wciAny);
  FNestedElements.AddNew(THtmNoframes, wciAny);
  FNestedElements.AddNew(THtmIsindex, wciAny);
  FNestedElements.AddNew(THtmFieldset, wciAny);
  FNestedElements.AddNew(THtmTable, wciAny);
  FNestedElements.AddNew(THtmForm, wciAny);
  FNestedElements.AddNew(THtmA, wciAny);
  FNestedElements.AddNew(THtmBr, wciAny);
  FNestedElements.AddNew(THtmSpan, wciAny);
  FNestedElements.AddNew(THtmBdo, wciAny);
  FNestedElements.AddNew(THtmObject, wciAny);
  FNestedElements.AddNew(THtmApplet, wciAny);
  FNestedElements.AddNew(THtmImg, wciAny);
  FNestedElements.AddNew(THtmMap, wciAny);
  FNestedElements.AddNew(THtmIframe, wciAny);
  FNestedElements.AddNew(THtmTt, wciAny);
  FNestedElements.AddNew(THtmI, wciAny);
  FNestedElements.AddNew(THtmB, wciAny);
  FNestedElements.AddNew(THtmU, wciAny);
  FNestedElements.AddNew(THtmS, wciAny);
  FNestedElements.AddNew(THtmStrike, wciAny);
  FNestedElements.AddNew(THtmBig, wciAny);
  FNestedElements.AddNew(THtmSmall, wciAny);
  FNestedElements.AddNew(THtmFont, wciAny);
  FNestedElements.AddNew(THtmBasefont, wciAny);
  FNestedElements.AddNew(THtmEm, wciAny);
  FNestedElements.AddNew(THtmStrong, wciAny);
  FNestedElements.AddNew(THtmDfn, wciAny);
  FNestedElements.AddNew(THtmCode, wciAny);
  FNestedElements.AddNew(THtmQ, wciAny);
  FNestedElements.AddNew(THtmSamp, wciAny);
  FNestedElements.AddNew(THtmKbd, wciAny);
  FNestedElements.AddNew(THtmVar, wciAny);
  FNestedElements.AddNew(THtmCite, wciAny);
  FNestedElements.AddNew(THtmAbbr, wciAny);
  FNestedElements.AddNew(THtmAcronym, wciAny);
  FNestedElements.AddNew(THtmSub, wciAny);
  FNestedElements.AddNew(THtmSup, wciAny);
  FNestedElements.AddNew(THtmInput, wciAny);
  FNestedElements.AddNew(THtmSelect, wciAny);
  FNestedElements.AddNew(THtmTextarea, wciAny);
  FNestedElements.AddNew(THtmLabel, wciAny);
  FNestedElements.AddNew(THtmButton, wciAny);
  FNestedElements.AddNew(THtmNoscript, wciAny);
  FNestedElements.AddNew(THtmIns, wciAny);
  FNestedElements.AddNew(THtmDel, wciAny);
  FNestedElements.AddNew(THtmScript, wciAny);

  if wcServerExtensions in xmlENV.xmlCapabilities
  then FNestedElements.AddNew(THtmServerSide, wciAny);
end;

constructor THtma.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  // attributes
  FAttributes.AddAttribute(ATTR_id, atID, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_class, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_style, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_title, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_lang, atNMTOKEN, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_xml_lang, atNMTOKEN, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_dir, atList, IMPLIED, NODEFAULT, 'ltr|rtl');
  FAttributes.AddAttribute(ATTR_onclick, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_ondblclick, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmousedown, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseup, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseover, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmousemove, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseout, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeypress, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeydown, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeyup, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_accesskey, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_tabindex, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onfocus, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onblur, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_charset, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_type, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_name, atNMTOKEN, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_href, atHREF, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_hreflang, atNMTOKEN, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_rel, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_rev, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_shape, atList, IMPLIED, 'rect', 'rect|circle|poly|default');
  FAttributes.AddAttribute(ATTR_coords, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_target, atNMTOKEN, IMPLIED, NODEFAULT, NOLIST);

  // nested elements
  FNestedElements.AddNew(THtmPCDATA, wciAny);
  FNestedElements.AddNew(THtmBr, wciAny);
  FNestedElements.AddNew(THtmSpan, wciAny);
  FNestedElements.AddNew(THtmBdo, wciAny);
  FNestedElements.AddNew(THtmObject, wciAny);
  FNestedElements.AddNew(THtmApplet, wciAny);
  FNestedElements.AddNew(THtmImg, wciAny);
  FNestedElements.AddNew(THtmMap, wciAny);
  FNestedElements.AddNew(THtmIframe, wciAny);
  FNestedElements.AddNew(THtmTt, wciAny);
  FNestedElements.AddNew(THtmI, wciAny);
  FNestedElements.AddNew(THtmB, wciAny);
  FNestedElements.AddNew(THtmU, wciAny);
  FNestedElements.AddNew(THtmS, wciAny);
  FNestedElements.AddNew(THtmStrike, wciAny);
  FNestedElements.AddNew(THtmBig, wciAny);
  FNestedElements.AddNew(THtmSmall, wciAny);
  FNestedElements.AddNew(THtmFont, wciAny);
  FNestedElements.AddNew(THtmBasefont, wciAny);
  FNestedElements.AddNew(THtmEm, wciAny);
  FNestedElements.AddNew(THtmStrong, wciAny);
  FNestedElements.AddNew(THtmDfn, wciAny);
  FNestedElements.AddNew(THtmCode, wciAny);
  FNestedElements.AddNew(THtmQ, wciAny);
  FNestedElements.AddNew(THtmSamp, wciAny);
  FNestedElements.AddNew(THtmKbd, wciAny);
  FNestedElements.AddNew(THtmVar, wciAny);
  FNestedElements.AddNew(THtmCite, wciAny);
  FNestedElements.AddNew(THtmAbbr, wciAny);
  FNestedElements.AddNew(THtmAcronym, wciAny);
  FNestedElements.AddNew(THtmSub, wciAny);
  FNestedElements.AddNew(THtmSup, wciAny);
  FNestedElements.AddNew(THtmInput, wciAny);
  FNestedElements.AddNew(THtmSelect, wciAny);
  FNestedElements.AddNew(THtmTextarea, wciAny);
  FNestedElements.AddNew(THtmLabel, wciAny);
  FNestedElements.AddNew(THtmButton, wciAny);
  FNestedElements.AddNew(THtmIns, wciAny);
  FNestedElements.AddNew(THtmDel, wciAny);
  FNestedElements.AddNew(THtmScript, wciAny);

  if wcServerExtensions in xmlENV.xmlCapabilities
  then FNestedElements.AddNew(THtmServerSide, wciAny);
end;

constructor THtmspan.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  // attributes
  FAttributes.AddAttribute(ATTR_id, atID, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_class, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_style, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_title, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_lang, atNMTOKEN, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_xml_lang, atNMTOKEN, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_dir, atList, IMPLIED, NODEFAULT, 'ltr|rtl');
  FAttributes.AddAttribute(ATTR_onclick, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_ondblclick, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmousedown, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseup, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseover, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmousemove, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseout, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeypress, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeydown, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeyup, atCDATA, IMPLIED, NODEFAULT, NOLIST);

  // nested elements
  FNestedElements.AddNew(THtmPCDATA, wciAny);
  FNestedElements.AddNew(THtmA, wciAny);
  FNestedElements.AddNew(THtmBr, wciAny);
  FNestedElements.AddNew(THtmSpan, wciAny);
  FNestedElements.AddNew(THtmBdo, wciAny);
  FNestedElements.AddNew(THtmObject, wciAny);
  FNestedElements.AddNew(THtmApplet, wciAny);
  FNestedElements.AddNew(THtmImg, wciAny);
  FNestedElements.AddNew(THtmMap, wciAny);
  FNestedElements.AddNew(THtmIframe, wciAny);
  FNestedElements.AddNew(THtmTt, wciAny);
  FNestedElements.AddNew(THtmI, wciAny);
  FNestedElements.AddNew(THtmB, wciAny);
  FNestedElements.AddNew(THtmU, wciAny);
  FNestedElements.AddNew(THtmS, wciAny);
  FNestedElements.AddNew(THtmStrike, wciAny);
  FNestedElements.AddNew(THtmBig, wciAny);
  FNestedElements.AddNew(THtmSmall, wciAny);
  FNestedElements.AddNew(THtmFont, wciAny);
  FNestedElements.AddNew(THtmBasefont, wciAny);
  FNestedElements.AddNew(THtmEm, wciAny);
  FNestedElements.AddNew(THtmStrong, wciAny);
  FNestedElements.AddNew(THtmDfn, wciAny);
  FNestedElements.AddNew(THtmCode, wciAny);
  FNestedElements.AddNew(THtmQ, wciAny);
  FNestedElements.AddNew(THtmSamp, wciAny);
  FNestedElements.AddNew(THtmKbd, wciAny);
  FNestedElements.AddNew(THtmVar, wciAny);
  FNestedElements.AddNew(THtmCite, wciAny);
  FNestedElements.AddNew(THtmAbbr, wciAny);
  FNestedElements.AddNew(THtmAcronym, wciAny);
  FNestedElements.AddNew(THtmSub, wciAny);
  FNestedElements.AddNew(THtmSup, wciAny);
  FNestedElements.AddNew(THtmInput, wciAny);
  FNestedElements.AddNew(THtmSelect, wciAny);
  FNestedElements.AddNew(THtmTextarea, wciAny);
  FNestedElements.AddNew(THtmLabel, wciAny);
  FNestedElements.AddNew(THtmButton, wciAny);
  FNestedElements.AddNew(THtmIns, wciAny);
  FNestedElements.AddNew(THtmDel, wciAny);
  FNestedElements.AddNew(THtmScript, wciAny);

  if wcServerExtensions in xmlENV.xmlCapabilities
  then FNestedElements.AddNew(THtmServerSide, wciAny);
end;

constructor THtmbdo.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  // attributes
  FAttributes.AddAttribute(ATTR_id, atID, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_class, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_style, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_title, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onclick, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_ondblclick, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmousedown, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseup, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseover, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmousemove, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseout, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeypress, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeydown, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeyup, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_lang, atNMTOKEN, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_xml_lang, atNMTOKEN, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_dir, atList, REQUIRED, NODEFAULT, 'ltr|rtl');

  // nested elements
  FNestedElements.AddNew(THtmPCDATA, wciAny);
  FNestedElements.AddNew(THtmA, wciAny);
  FNestedElements.AddNew(THtmBr, wciAny);
  FNestedElements.AddNew(THtmSpan, wciAny);
  FNestedElements.AddNew(THtmBdo, wciAny);
  FNestedElements.AddNew(THtmObject, wciAny);
  FNestedElements.AddNew(THtmApplet, wciAny);
  FNestedElements.AddNew(THtmImg, wciAny);
  FNestedElements.AddNew(THtmMap, wciAny);
  FNestedElements.AddNew(THtmIframe, wciAny);
  FNestedElements.AddNew(THtmTt, wciAny);
  FNestedElements.AddNew(THtmI, wciAny);
  FNestedElements.AddNew(THtmB, wciAny);
  FNestedElements.AddNew(THtmU, wciAny);
  FNestedElements.AddNew(THtmS, wciAny);
  FNestedElements.AddNew(THtmStrike, wciAny);
  FNestedElements.AddNew(THtmBig, wciAny);
  FNestedElements.AddNew(THtmSmall, wciAny);
  FNestedElements.AddNew(THtmFont, wciAny);
  FNestedElements.AddNew(THtmBasefont, wciAny);
  FNestedElements.AddNew(THtmEm, wciAny);
  FNestedElements.AddNew(THtmStrong, wciAny);
  FNestedElements.AddNew(THtmDfn, wciAny);
  FNestedElements.AddNew(THtmCode, wciAny);
  FNestedElements.AddNew(THtmQ, wciAny);
  FNestedElements.AddNew(THtmSamp, wciAny);
  FNestedElements.AddNew(THtmKbd, wciAny);
  FNestedElements.AddNew(THtmVar, wciAny);
  FNestedElements.AddNew(THtmCite, wciAny);
  FNestedElements.AddNew(THtmAbbr, wciAny);
  FNestedElements.AddNew(THtmAcronym, wciAny);
  FNestedElements.AddNew(THtmSub, wciAny);
  FNestedElements.AddNew(THtmSup, wciAny);
  FNestedElements.AddNew(THtmInput, wciAny);
  FNestedElements.AddNew(THtmSelect, wciAny);
  FNestedElements.AddNew(THtmTextarea, wciAny);
  FNestedElements.AddNew(THtmLabel, wciAny);
  FNestedElements.AddNew(THtmButton, wciAny);
  FNestedElements.AddNew(THtmIns, wciAny);
  FNestedElements.AddNew(THtmDel, wciAny);
  FNestedElements.AddNew(THtmScript, wciAny);

  if wcServerExtensions in xmlENV.xmlCapabilities
  then FNestedElements.AddNew(THtmServerSide, wciAny);
end;

constructor THtmbr.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  // attributes
  FAttributes.AddAttribute(ATTR_id, atID, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_class, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_style, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_title, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_clear, atList, IMPLIED, 'none', 'left|all|right|none');

  // EMPTY 
end;

constructor THtmem.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  // attributes
  FAttributes.AddAttribute(ATTR_id, atID, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_class, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_style, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_title, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_lang, atNMTOKEN, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_xml_lang, atNMTOKEN, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_dir, atList, IMPLIED, NODEFAULT, 'ltr|rtl');
  FAttributes.AddAttribute(ATTR_onclick, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_ondblclick, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmousedown, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseup, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseover, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmousemove, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseout, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeypress, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeydown, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeyup, atCDATA, IMPLIED, NODEFAULT, NOLIST);

  // nested elements
  FNestedElements.AddNew(THtmPCDATA, wciAny);
  FNestedElements.AddNew(THtmA, wciAny);
  FNestedElements.AddNew(THtmBr, wciAny);
  FNestedElements.AddNew(THtmSpan, wciAny);
  FNestedElements.AddNew(THtmBdo, wciAny);
  FNestedElements.AddNew(THtmObject, wciAny);
  FNestedElements.AddNew(THtmApplet, wciAny);
  FNestedElements.AddNew(THtmImg, wciAny);
  FNestedElements.AddNew(THtmMap, wciAny);
  FNestedElements.AddNew(THtmIframe, wciAny);
  FNestedElements.AddNew(THtmTt, wciAny);
  FNestedElements.AddNew(THtmI, wciAny);
  FNestedElements.AddNew(THtmB, wciAny);
  FNestedElements.AddNew(THtmU, wciAny);
  FNestedElements.AddNew(THtmS, wciAny);
  FNestedElements.AddNew(THtmStrike, wciAny);
  FNestedElements.AddNew(THtmBig, wciAny);
  FNestedElements.AddNew(THtmSmall, wciAny);
  FNestedElements.AddNew(THtmFont, wciAny);
  FNestedElements.AddNew(THtmBasefont, wciAny);
  FNestedElements.AddNew(THtmEm, wciAny);
  FNestedElements.AddNew(THtmStrong, wciAny);
  FNestedElements.AddNew(THtmDfn, wciAny);
  FNestedElements.AddNew(THtmCode, wciAny);
  FNestedElements.AddNew(THtmQ, wciAny);
  FNestedElements.AddNew(THtmSamp, wciAny);
  FNestedElements.AddNew(THtmKbd, wciAny);
  FNestedElements.AddNew(THtmVar, wciAny);
  FNestedElements.AddNew(THtmCite, wciAny);
  FNestedElements.AddNew(THtmAbbr, wciAny);
  FNestedElements.AddNew(THtmAcronym, wciAny);
  FNestedElements.AddNew(THtmSub, wciAny);
  FNestedElements.AddNew(THtmSup, wciAny);
  FNestedElements.AddNew(THtmInput, wciAny);
  FNestedElements.AddNew(THtmSelect, wciAny);
  FNestedElements.AddNew(THtmTextarea, wciAny);
  FNestedElements.AddNew(THtmLabel, wciAny);
  FNestedElements.AddNew(THtmButton, wciAny);
  FNestedElements.AddNew(THtmIns, wciAny);
  FNestedElements.AddNew(THtmDel, wciAny);
  FNestedElements.AddNew(THtmScript, wciAny);

  if wcServerExtensions in xmlENV.xmlCapabilities
  then FNestedElements.AddNew(THtmServerSide, wciAny);
end;

constructor THtmstrong.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  // attributes
  FAttributes.AddAttribute(ATTR_id, atID, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_class, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_style, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_title, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_lang, atNMTOKEN, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_xml_lang, atNMTOKEN, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_dir, atList, IMPLIED, NODEFAULT, 'ltr|rtl');
  FAttributes.AddAttribute(ATTR_onclick, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_ondblclick, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmousedown, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseup, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseover, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmousemove, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseout, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeypress, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeydown, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeyup, atCDATA, IMPLIED, NODEFAULT, NOLIST);

  // nested elements
  FNestedElements.AddNew(THtmPCDATA, wciAny);
  FNestedElements.AddNew(THtmA, wciAny);
  FNestedElements.AddNew(THtmBr, wciAny);
  FNestedElements.AddNew(THtmSpan, wciAny);
  FNestedElements.AddNew(THtmBdo, wciAny);
  FNestedElements.AddNew(THtmObject, wciAny);
  FNestedElements.AddNew(THtmApplet, wciAny);
  FNestedElements.AddNew(THtmImg, wciAny);
  FNestedElements.AddNew(THtmMap, wciAny);
  FNestedElements.AddNew(THtmIframe, wciAny);
  FNestedElements.AddNew(THtmTt, wciAny);
  FNestedElements.AddNew(THtmI, wciAny);
  FNestedElements.AddNew(THtmB, wciAny);
  FNestedElements.AddNew(THtmU, wciAny);
  FNestedElements.AddNew(THtmS, wciAny);
  FNestedElements.AddNew(THtmStrike, wciAny);
  FNestedElements.AddNew(THtmBig, wciAny);
  FNestedElements.AddNew(THtmSmall, wciAny);
  FNestedElements.AddNew(THtmFont, wciAny);
  FNestedElements.AddNew(THtmBasefont, wciAny);
  FNestedElements.AddNew(THtmEm, wciAny);
  FNestedElements.AddNew(THtmStrong, wciAny);
  FNestedElements.AddNew(THtmDfn, wciAny);
  FNestedElements.AddNew(THtmCode, wciAny);
  FNestedElements.AddNew(THtmQ, wciAny);
  FNestedElements.AddNew(THtmSamp, wciAny);
  FNestedElements.AddNew(THtmKbd, wciAny);
  FNestedElements.AddNew(THtmVar, wciAny);
  FNestedElements.AddNew(THtmCite, wciAny);
  FNestedElements.AddNew(THtmAbbr, wciAny);
  FNestedElements.AddNew(THtmAcronym, wciAny);
  FNestedElements.AddNew(THtmSub, wciAny);
  FNestedElements.AddNew(THtmSup, wciAny);
  FNestedElements.AddNew(THtmInput, wciAny);
  FNestedElements.AddNew(THtmSelect, wciAny);
  FNestedElements.AddNew(THtmTextarea, wciAny);
  FNestedElements.AddNew(THtmLabel, wciAny);
  FNestedElements.AddNew(THtmButton, wciAny);
  FNestedElements.AddNew(THtmIns, wciAny);
  FNestedElements.AddNew(THtmDel, wciAny);
  FNestedElements.AddNew(THtmScript, wciAny);

  if wcServerExtensions in xmlENV.xmlCapabilities
  then FNestedElements.AddNew(THtmServerSide, wciAny);
end;

constructor THtmdfn.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  // attributes
  FAttributes.AddAttribute(ATTR_id, atID, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_class, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_style, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_title, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_lang, atNMTOKEN, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_xml_lang, atNMTOKEN, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_dir, atList, IMPLIED, NODEFAULT, 'ltr|rtl');
  FAttributes.AddAttribute(ATTR_onclick, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_ondblclick, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmousedown, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseup, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseover, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmousemove, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseout, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeypress, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeydown, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeyup, atCDATA, IMPLIED, NODEFAULT, NOLIST);

  // nested elements
  FNestedElements.AddNew(THtmPCDATA, wciAny);
  FNestedElements.AddNew(THtmA, wciAny);
  FNestedElements.AddNew(THtmBr, wciAny);
  FNestedElements.AddNew(THtmSpan, wciAny);
  FNestedElements.AddNew(THtmBdo, wciAny);
  FNestedElements.AddNew(THtmObject, wciAny);
  FNestedElements.AddNew(THtmApplet, wciAny);
  FNestedElements.AddNew(THtmImg, wciAny);
  FNestedElements.AddNew(THtmMap, wciAny);
  FNestedElements.AddNew(THtmIframe, wciAny);
  FNestedElements.AddNew(THtmTt, wciAny);
  FNestedElements.AddNew(THtmI, wciAny);
  FNestedElements.AddNew(THtmB, wciAny);
  FNestedElements.AddNew(THtmU, wciAny);
  FNestedElements.AddNew(THtmS, wciAny);
  FNestedElements.AddNew(THtmStrike, wciAny);
  FNestedElements.AddNew(THtmBig, wciAny);
  FNestedElements.AddNew(THtmSmall, wciAny);
  FNestedElements.AddNew(THtmFont, wciAny);
  FNestedElements.AddNew(THtmBasefont, wciAny);
  FNestedElements.AddNew(THtmEm, wciAny);
  FNestedElements.AddNew(THtmStrong, wciAny);
  FNestedElements.AddNew(THtmDfn, wciAny);
  FNestedElements.AddNew(THtmCode, wciAny);
  FNestedElements.AddNew(THtmQ, wciAny);
  FNestedElements.AddNew(THtmSamp, wciAny);
  FNestedElements.AddNew(THtmKbd, wciAny);
  FNestedElements.AddNew(THtmVar, wciAny);
  FNestedElements.AddNew(THtmCite, wciAny);
  FNestedElements.AddNew(THtmAbbr, wciAny);
  FNestedElements.AddNew(THtmAcronym, wciAny);
  FNestedElements.AddNew(THtmSub, wciAny);
  FNestedElements.AddNew(THtmSup, wciAny);
  FNestedElements.AddNew(THtmInput, wciAny);
  FNestedElements.AddNew(THtmSelect, wciAny);
  FNestedElements.AddNew(THtmTextarea, wciAny);
  FNestedElements.AddNew(THtmLabel, wciAny);
  FNestedElements.AddNew(THtmButton, wciAny);
  FNestedElements.AddNew(THtmIns, wciAny);
  FNestedElements.AddNew(THtmDel, wciAny);
  FNestedElements.AddNew(THtmScript, wciAny);

  if wcServerExtensions in xmlENV.xmlCapabilities
  then FNestedElements.AddNew(THtmServerSide, wciAny);
end;

constructor THtmcode.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  // attributes
  FAttributes.AddAttribute(ATTR_id, atID, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_class, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_style, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_title, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_lang, atNMTOKEN, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_xml_lang, atNMTOKEN, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_dir, atList, IMPLIED, NODEFAULT, 'ltr|rtl');
  FAttributes.AddAttribute(ATTR_onclick, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_ondblclick, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmousedown, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseup, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseover, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmousemove, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseout, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeypress, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeydown, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeyup, atCDATA, IMPLIED, NODEFAULT, NOLIST);

  // nested elements
  FNestedElements.AddNew(THtmPCDATA, wciAny);
  FNestedElements.AddNew(THtmA, wciAny);
  FNestedElements.AddNew(THtmBr, wciAny);
  FNestedElements.AddNew(THtmSpan, wciAny);
  FNestedElements.AddNew(THtmBdo, wciAny);
  FNestedElements.AddNew(THtmObject, wciAny);
  FNestedElements.AddNew(THtmApplet, wciAny);
  FNestedElements.AddNew(THtmImg, wciAny);
  FNestedElements.AddNew(THtmMap, wciAny);
  FNestedElements.AddNew(THtmIframe, wciAny);
  FNestedElements.AddNew(THtmTt, wciAny);
  FNestedElements.AddNew(THtmI, wciAny);
  FNestedElements.AddNew(THtmB, wciAny);
  FNestedElements.AddNew(THtmU, wciAny);
  FNestedElements.AddNew(THtmS, wciAny);
  FNestedElements.AddNew(THtmStrike, wciAny);
  FNestedElements.AddNew(THtmBig, wciAny);
  FNestedElements.AddNew(THtmSmall, wciAny);
  FNestedElements.AddNew(THtmFont, wciAny);
  FNestedElements.AddNew(THtmBasefont, wciAny);
  FNestedElements.AddNew(THtmEm, wciAny);
  FNestedElements.AddNew(THtmStrong, wciAny);
  FNestedElements.AddNew(THtmDfn, wciAny);
  FNestedElements.AddNew(THtmCode, wciAny);
  FNestedElements.AddNew(THtmQ, wciAny);
  FNestedElements.AddNew(THtmSamp, wciAny);
  FNestedElements.AddNew(THtmKbd, wciAny);
  FNestedElements.AddNew(THtmVar, wciAny);
  FNestedElements.AddNew(THtmCite, wciAny);
  FNestedElements.AddNew(THtmAbbr, wciAny);
  FNestedElements.AddNew(THtmAcronym, wciAny);
  FNestedElements.AddNew(THtmSub, wciAny);
  FNestedElements.AddNew(THtmSup, wciAny);
  FNestedElements.AddNew(THtmInput, wciAny);
  FNestedElements.AddNew(THtmSelect, wciAny);
  FNestedElements.AddNew(THtmTextarea, wciAny);
  FNestedElements.AddNew(THtmLabel, wciAny);
  FNestedElements.AddNew(THtmButton, wciAny);
  FNestedElements.AddNew(THtmIns, wciAny);
  FNestedElements.AddNew(THtmDel, wciAny);
  FNestedElements.AddNew(THtmScript, wciAny);

  if wcServerExtensions in xmlENV.xmlCapabilities
  then FNestedElements.AddNew(THtmServerSide, wciAny);
end;

constructor THtmsamp.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  // attributes
  FAttributes.AddAttribute(ATTR_id, atID, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_class, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_style, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_title, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_lang, atNMTOKEN, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_xml_lang, atNMTOKEN, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_dir, atList, IMPLIED, NODEFAULT, 'ltr|rtl');
  FAttributes.AddAttribute(ATTR_onclick, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_ondblclick, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmousedown, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseup, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseover, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmousemove, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseout, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeypress, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeydown, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeyup, atCDATA, IMPLIED, NODEFAULT, NOLIST);

  // nested elements
  FNestedElements.AddNew(THtmPCDATA, wciAny);
  FNestedElements.AddNew(THtmA, wciAny);
  FNestedElements.AddNew(THtmBr, wciAny);
  FNestedElements.AddNew(THtmSpan, wciAny);
  FNestedElements.AddNew(THtmBdo, wciAny);
  FNestedElements.AddNew(THtmObject, wciAny);
  FNestedElements.AddNew(THtmApplet, wciAny);
  FNestedElements.AddNew(THtmImg, wciAny);
  FNestedElements.AddNew(THtmMap, wciAny);
  FNestedElements.AddNew(THtmIframe, wciAny);
  FNestedElements.AddNew(THtmTt, wciAny);
  FNestedElements.AddNew(THtmI, wciAny);
  FNestedElements.AddNew(THtmB, wciAny);
  FNestedElements.AddNew(THtmU, wciAny);
  FNestedElements.AddNew(THtmS, wciAny);
  FNestedElements.AddNew(THtmStrike, wciAny);
  FNestedElements.AddNew(THtmBig, wciAny);
  FNestedElements.AddNew(THtmSmall, wciAny);
  FNestedElements.AddNew(THtmFont, wciAny);
  FNestedElements.AddNew(THtmBasefont, wciAny);
  FNestedElements.AddNew(THtmEm, wciAny);
  FNestedElements.AddNew(THtmStrong, wciAny);
  FNestedElements.AddNew(THtmDfn, wciAny);
  FNestedElements.AddNew(THtmCode, wciAny);
  FNestedElements.AddNew(THtmQ, wciAny);
  FNestedElements.AddNew(THtmSamp, wciAny);
  FNestedElements.AddNew(THtmKbd, wciAny);
  FNestedElements.AddNew(THtmVar, wciAny);
  FNestedElements.AddNew(THtmCite, wciAny);
  FNestedElements.AddNew(THtmAbbr, wciAny);
  FNestedElements.AddNew(THtmAcronym, wciAny);
  FNestedElements.AddNew(THtmSub, wciAny);
  FNestedElements.AddNew(THtmSup, wciAny);
  FNestedElements.AddNew(THtmInput, wciAny);
  FNestedElements.AddNew(THtmSelect, wciAny);
  FNestedElements.AddNew(THtmTextarea, wciAny);
  FNestedElements.AddNew(THtmLabel, wciAny);
  FNestedElements.AddNew(THtmButton, wciAny);
  FNestedElements.AddNew(THtmIns, wciAny);
  FNestedElements.AddNew(THtmDel, wciAny);
  FNestedElements.AddNew(THtmScript, wciAny);

  if wcServerExtensions in xmlENV.xmlCapabilities
  then FNestedElements.AddNew(THtmServerSide, wciAny);
end;

constructor THtmkbd.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  // attributes
  FAttributes.AddAttribute(ATTR_id, atID, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_class, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_style, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_title, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_lang, atNMTOKEN, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_xml_lang, atNMTOKEN, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_dir, atList, IMPLIED, NODEFAULT, 'ltr|rtl');
  FAttributes.AddAttribute(ATTR_onclick, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_ondblclick, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmousedown, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseup, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseover, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmousemove, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseout, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeypress, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeydown, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeyup, atCDATA, IMPLIED, NODEFAULT, NOLIST);

  // nested elements
  FNestedElements.AddNew(THtmPCDATA, wciAny);
  FNestedElements.AddNew(THtmA, wciAny);
  FNestedElements.AddNew(THtmBr, wciAny);
  FNestedElements.AddNew(THtmSpan, wciAny);
  FNestedElements.AddNew(THtmBdo, wciAny);
  FNestedElements.AddNew(THtmObject, wciAny);
  FNestedElements.AddNew(THtmApplet, wciAny);
  FNestedElements.AddNew(THtmImg, wciAny);
  FNestedElements.AddNew(THtmMap, wciAny);
  FNestedElements.AddNew(THtmIframe, wciAny);
  FNestedElements.AddNew(THtmTt, wciAny);
  FNestedElements.AddNew(THtmI, wciAny);
  FNestedElements.AddNew(THtmB, wciAny);
  FNestedElements.AddNew(THtmU, wciAny);
  FNestedElements.AddNew(THtmS, wciAny);
  FNestedElements.AddNew(THtmStrike, wciAny);
  FNestedElements.AddNew(THtmBig, wciAny);
  FNestedElements.AddNew(THtmSmall, wciAny);
  FNestedElements.AddNew(THtmFont, wciAny);
  FNestedElements.AddNew(THtmBasefont, wciAny);
  FNestedElements.AddNew(THtmEm, wciAny);
  FNestedElements.AddNew(THtmStrong, wciAny);
  FNestedElements.AddNew(THtmDfn, wciAny);
  FNestedElements.AddNew(THtmCode, wciAny);
  FNestedElements.AddNew(THtmQ, wciAny);
  FNestedElements.AddNew(THtmSamp, wciAny);
  FNestedElements.AddNew(THtmKbd, wciAny);
  FNestedElements.AddNew(THtmVar, wciAny);
  FNestedElements.AddNew(THtmCite, wciAny);
  FNestedElements.AddNew(THtmAbbr, wciAny);
  FNestedElements.AddNew(THtmAcronym, wciAny);
  FNestedElements.AddNew(THtmSub, wciAny);
  FNestedElements.AddNew(THtmSup, wciAny);
  FNestedElements.AddNew(THtmInput, wciAny);
  FNestedElements.AddNew(THtmSelect, wciAny);
  FNestedElements.AddNew(THtmTextarea, wciAny);
  FNestedElements.AddNew(THtmLabel, wciAny);
  FNestedElements.AddNew(THtmButton, wciAny);
  FNestedElements.AddNew(THtmIns, wciAny);
  FNestedElements.AddNew(THtmDel, wciAny);
  FNestedElements.AddNew(THtmScript, wciAny);

  if wcServerExtensions in xmlENV.xmlCapabilities
  then FNestedElements.AddNew(THtmServerSide, wciAny);
end;

constructor THtmvar.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  // attributes
  FAttributes.AddAttribute(ATTR_id, atID, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_class, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_style, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_title, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_lang, atNMTOKEN, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_xml_lang, atNMTOKEN, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_dir, atList, IMPLIED, NODEFAULT, 'ltr|rtl');
  FAttributes.AddAttribute(ATTR_onclick, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_ondblclick, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmousedown, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseup, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseover, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmousemove, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseout, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeypress, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeydown, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeyup, atCDATA, IMPLIED, NODEFAULT, NOLIST);

  // nested elements
  FNestedElements.AddNew(THtmPCDATA, wciAny);
  FNestedElements.AddNew(THtmA, wciAny);
  FNestedElements.AddNew(THtmBr, wciAny);
  FNestedElements.AddNew(THtmSpan, wciAny);
  FNestedElements.AddNew(THtmBdo, wciAny);
  FNestedElements.AddNew(THtmObject, wciAny);
  FNestedElements.AddNew(THtmApplet, wciAny);
  FNestedElements.AddNew(THtmImg, wciAny);
  FNestedElements.AddNew(THtmMap, wciAny);
  FNestedElements.AddNew(THtmIframe, wciAny);
  FNestedElements.AddNew(THtmTt, wciAny);
  FNestedElements.AddNew(THtmI, wciAny);
  FNestedElements.AddNew(THtmB, wciAny);
  FNestedElements.AddNew(THtmU, wciAny);
  FNestedElements.AddNew(THtmS, wciAny);
  FNestedElements.AddNew(THtmStrike, wciAny);
  FNestedElements.AddNew(THtmBig, wciAny);
  FNestedElements.AddNew(THtmSmall, wciAny);
  FNestedElements.AddNew(THtmFont, wciAny);
  FNestedElements.AddNew(THtmBasefont, wciAny);
  FNestedElements.AddNew(THtmEm, wciAny);
  FNestedElements.AddNew(THtmStrong, wciAny);
  FNestedElements.AddNew(THtmDfn, wciAny);
  FNestedElements.AddNew(THtmCode, wciAny);
  FNestedElements.AddNew(THtmQ, wciAny);
  FNestedElements.AddNew(THtmSamp, wciAny);
  FNestedElements.AddNew(THtmKbd, wciAny);
  FNestedElements.AddNew(THtmVar, wciAny);
  FNestedElements.AddNew(THtmCite, wciAny);
  FNestedElements.AddNew(THtmAbbr, wciAny);
  FNestedElements.AddNew(THtmAcronym, wciAny);
  FNestedElements.AddNew(THtmSub, wciAny);
  FNestedElements.AddNew(THtmSup, wciAny);
  FNestedElements.AddNew(THtmInput, wciAny);
  FNestedElements.AddNew(THtmSelect, wciAny);
  FNestedElements.AddNew(THtmTextarea, wciAny);
  FNestedElements.AddNew(THtmLabel, wciAny);
  FNestedElements.AddNew(THtmButton, wciAny);
  FNestedElements.AddNew(THtmIns, wciAny);
  FNestedElements.AddNew(THtmDel, wciAny);
  FNestedElements.AddNew(THtmScript, wciAny);

  if wcServerExtensions in xmlENV.xmlCapabilities
  then FNestedElements.AddNew(THtmServerSide, wciAny);
end;

constructor THtmcite.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  // attributes
  FAttributes.AddAttribute(ATTR_id, atID, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_class, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_style, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_title, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_lang, atNMTOKEN, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_xml_lang, atNMTOKEN, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_dir, atList, IMPLIED, NODEFAULT, 'ltr|rtl');
  FAttributes.AddAttribute(ATTR_onclick, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_ondblclick, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmousedown, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseup, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseover, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmousemove, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseout, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeypress, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeydown, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeyup, atCDATA, IMPLIED, NODEFAULT, NOLIST);

  // nested elements
  FNestedElements.AddNew(THtmPCDATA, wciAny);
  FNestedElements.AddNew(THtmA, wciAny);
  FNestedElements.AddNew(THtmBr, wciAny);
  FNestedElements.AddNew(THtmSpan, wciAny);
  FNestedElements.AddNew(THtmBdo, wciAny);
  FNestedElements.AddNew(THtmObject, wciAny);
  FNestedElements.AddNew(THtmApplet, wciAny);
  FNestedElements.AddNew(THtmImg, wciAny);
  FNestedElements.AddNew(THtmMap, wciAny);
  FNestedElements.AddNew(THtmIframe, wciAny);
  FNestedElements.AddNew(THtmTt, wciAny);
  FNestedElements.AddNew(THtmI, wciAny);
  FNestedElements.AddNew(THtmB, wciAny);
  FNestedElements.AddNew(THtmU, wciAny);
  FNestedElements.AddNew(THtmS, wciAny);
  FNestedElements.AddNew(THtmStrike, wciAny);
  FNestedElements.AddNew(THtmBig, wciAny);
  FNestedElements.AddNew(THtmSmall, wciAny);
  FNestedElements.AddNew(THtmFont, wciAny);
  FNestedElements.AddNew(THtmBasefont, wciAny);
  FNestedElements.AddNew(THtmEm, wciAny);
  FNestedElements.AddNew(THtmStrong, wciAny);
  FNestedElements.AddNew(THtmDfn, wciAny);
  FNestedElements.AddNew(THtmCode, wciAny);
  FNestedElements.AddNew(THtmQ, wciAny);
  FNestedElements.AddNew(THtmSamp, wciAny);
  FNestedElements.AddNew(THtmKbd, wciAny);
  FNestedElements.AddNew(THtmVar, wciAny);
  FNestedElements.AddNew(THtmCite, wciAny);
  FNestedElements.AddNew(THtmAbbr, wciAny);
  FNestedElements.AddNew(THtmAcronym, wciAny);
  FNestedElements.AddNew(THtmSub, wciAny);
  FNestedElements.AddNew(THtmSup, wciAny);
  FNestedElements.AddNew(THtmInput, wciAny);
  FNestedElements.AddNew(THtmSelect, wciAny);
  FNestedElements.AddNew(THtmTextarea, wciAny);
  FNestedElements.AddNew(THtmLabel, wciAny);
  FNestedElements.AddNew(THtmButton, wciAny);
  FNestedElements.AddNew(THtmIns, wciAny);
  FNestedElements.AddNew(THtmDel, wciAny);
  FNestedElements.AddNew(THtmScript, wciAny);

  if wcServerExtensions in xmlENV.xmlCapabilities
  then FNestedElements.AddNew(THtmServerSide, wciAny);
end;

constructor THtmabbr.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  // attributes
  FAttributes.AddAttribute(ATTR_id, atID, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_class, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_style, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_title, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_lang, atNMTOKEN, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_xml_lang, atNMTOKEN, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_dir, atList, IMPLIED, NODEFAULT, 'ltr|rtl');
  FAttributes.AddAttribute(ATTR_onclick, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_ondblclick, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmousedown, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseup, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseover, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmousemove, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseout, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeypress, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeydown, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeyup, atCDATA, IMPLIED, NODEFAULT, NOLIST);

  // nested elements
  FNestedElements.AddNew(THtmPCDATA, wciAny);
  FNestedElements.AddNew(THtmA, wciAny);
  FNestedElements.AddNew(THtmBr, wciAny);
  FNestedElements.AddNew(THtmSpan, wciAny);
  FNestedElements.AddNew(THtmBdo, wciAny);
  FNestedElements.AddNew(THtmObject, wciAny);
  FNestedElements.AddNew(THtmApplet, wciAny);
  FNestedElements.AddNew(THtmImg, wciAny);
  FNestedElements.AddNew(THtmMap, wciAny);
  FNestedElements.AddNew(THtmIframe, wciAny);
  FNestedElements.AddNew(THtmTt, wciAny);
  FNestedElements.AddNew(THtmI, wciAny);
  FNestedElements.AddNew(THtmB, wciAny);
  FNestedElements.AddNew(THtmU, wciAny);
  FNestedElements.AddNew(THtmS, wciAny);
  FNestedElements.AddNew(THtmStrike, wciAny);
  FNestedElements.AddNew(THtmBig, wciAny);
  FNestedElements.AddNew(THtmSmall, wciAny);
  FNestedElements.AddNew(THtmFont, wciAny);
  FNestedElements.AddNew(THtmBasefont, wciAny);
  FNestedElements.AddNew(THtmEm, wciAny);
  FNestedElements.AddNew(THtmStrong, wciAny);
  FNestedElements.AddNew(THtmDfn, wciAny);
  FNestedElements.AddNew(THtmCode, wciAny);
  FNestedElements.AddNew(THtmQ, wciAny);
  FNestedElements.AddNew(THtmSamp, wciAny);
  FNestedElements.AddNew(THtmKbd, wciAny);
  FNestedElements.AddNew(THtmVar, wciAny);
  FNestedElements.AddNew(THtmCite, wciAny);
  FNestedElements.AddNew(THtmAbbr, wciAny);
  FNestedElements.AddNew(THtmAcronym, wciAny);
  FNestedElements.AddNew(THtmSub, wciAny);
  FNestedElements.AddNew(THtmSup, wciAny);
  FNestedElements.AddNew(THtmInput, wciAny);
  FNestedElements.AddNew(THtmSelect, wciAny);
  FNestedElements.AddNew(THtmTextarea, wciAny);
  FNestedElements.AddNew(THtmLabel, wciAny);
  FNestedElements.AddNew(THtmButton, wciAny);
  FNestedElements.AddNew(THtmIns, wciAny);
  FNestedElements.AddNew(THtmDel, wciAny);
  FNestedElements.AddNew(THtmScript, wciAny);

  if wcServerExtensions in xmlENV.xmlCapabilities
  then FNestedElements.AddNew(THtmServerSide, wciAny);
end;

constructor THtmacronym.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  // attributes
  FAttributes.AddAttribute(ATTR_id, atID, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_class, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_style, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_title, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_lang, atNMTOKEN, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_xml_lang, atNMTOKEN, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_dir, atList, IMPLIED, NODEFAULT, 'ltr|rtl');
  FAttributes.AddAttribute(ATTR_onclick, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_ondblclick, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmousedown, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseup, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseover, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmousemove, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseout, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeypress, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeydown, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeyup, atCDATA, IMPLIED, NODEFAULT, NOLIST);

  // nested elements
  FNestedElements.AddNew(THtmPCDATA, wciAny);
  FNestedElements.AddNew(THtmA, wciAny);
  FNestedElements.AddNew(THtmBr, wciAny);
  FNestedElements.AddNew(THtmSpan, wciAny);
  FNestedElements.AddNew(THtmBdo, wciAny);
  FNestedElements.AddNew(THtmObject, wciAny);
  FNestedElements.AddNew(THtmApplet, wciAny);
  FNestedElements.AddNew(THtmImg, wciAny);
  FNestedElements.AddNew(THtmMap, wciAny);
  FNestedElements.AddNew(THtmIframe, wciAny);
  FNestedElements.AddNew(THtmTt, wciAny);
  FNestedElements.AddNew(THtmI, wciAny);
  FNestedElements.AddNew(THtmB, wciAny);
  FNestedElements.AddNew(THtmU, wciAny);
  FNestedElements.AddNew(THtmS, wciAny);
  FNestedElements.AddNew(THtmStrike, wciAny);
  FNestedElements.AddNew(THtmBig, wciAny);
  FNestedElements.AddNew(THtmSmall, wciAny);
  FNestedElements.AddNew(THtmFont, wciAny);
  FNestedElements.AddNew(THtmBasefont, wciAny);
  FNestedElements.AddNew(THtmEm, wciAny);
  FNestedElements.AddNew(THtmStrong, wciAny);
  FNestedElements.AddNew(THtmDfn, wciAny);
  FNestedElements.AddNew(THtmCode, wciAny);
  FNestedElements.AddNew(THtmQ, wciAny);
  FNestedElements.AddNew(THtmSamp, wciAny);
  FNestedElements.AddNew(THtmKbd, wciAny);
  FNestedElements.AddNew(THtmVar, wciAny);
  FNestedElements.AddNew(THtmCite, wciAny);
  FNestedElements.AddNew(THtmAbbr, wciAny);
  FNestedElements.AddNew(THtmAcronym, wciAny);
  FNestedElements.AddNew(THtmSub, wciAny);
  FNestedElements.AddNew(THtmSup, wciAny);
  FNestedElements.AddNew(THtmInput, wciAny);
  FNestedElements.AddNew(THtmSelect, wciAny);
  FNestedElements.AddNew(THtmTextarea, wciAny);
  FNestedElements.AddNew(THtmLabel, wciAny);
  FNestedElements.AddNew(THtmButton, wciAny);
  FNestedElements.AddNew(THtmIns, wciAny);
  FNestedElements.AddNew(THtmDel, wciAny);
  FNestedElements.AddNew(THtmScript, wciAny);

  if wcServerExtensions in xmlENV.xmlCapabilities
  then FNestedElements.AddNew(THtmServerSide, wciAny);
end;

constructor THtmq.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  // attributes
  FAttributes.AddAttribute(ATTR_id, atID, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_class, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_style, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_title, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_lang, atNMTOKEN, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_xml_lang, atNMTOKEN, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_dir, atList, IMPLIED, NODEFAULT, 'ltr|rtl');
  FAttributes.AddAttribute(ATTR_onclick, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_ondblclick, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmousedown, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseup, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseover, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmousemove, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseout, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeypress, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeydown, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeyup, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_cite, atHREF, IMPLIED, NODEFAULT, NOLIST);

  // nested elements
  FNestedElements.AddNew(THtmPCDATA, wciAny);
  FNestedElements.AddNew(THtmA, wciAny);
  FNestedElements.AddNew(THtmBr, wciAny);
  FNestedElements.AddNew(THtmSpan, wciAny);
  FNestedElements.AddNew(THtmBdo, wciAny);
  FNestedElements.AddNew(THtmObject, wciAny);
  FNestedElements.AddNew(THtmApplet, wciAny);
  FNestedElements.AddNew(THtmImg, wciAny);
  FNestedElements.AddNew(THtmMap, wciAny);
  FNestedElements.AddNew(THtmIframe, wciAny);
  FNestedElements.AddNew(THtmTt, wciAny);
  FNestedElements.AddNew(THtmI, wciAny);
  FNestedElements.AddNew(THtmB, wciAny);
  FNestedElements.AddNew(THtmU, wciAny);
  FNestedElements.AddNew(THtmS, wciAny);
  FNestedElements.AddNew(THtmStrike, wciAny);
  FNestedElements.AddNew(THtmBig, wciAny);
  FNestedElements.AddNew(THtmSmall, wciAny);
  FNestedElements.AddNew(THtmFont, wciAny);
  FNestedElements.AddNew(THtmBasefont, wciAny);
  FNestedElements.AddNew(THtmEm, wciAny);
  FNestedElements.AddNew(THtmStrong, wciAny);
  FNestedElements.AddNew(THtmDfn, wciAny);
  FNestedElements.AddNew(THtmCode, wciAny);
  FNestedElements.AddNew(THtmQ, wciAny);
  FNestedElements.AddNew(THtmSamp, wciAny);
  FNestedElements.AddNew(THtmKbd, wciAny);
  FNestedElements.AddNew(THtmVar, wciAny);
  FNestedElements.AddNew(THtmCite, wciAny);
  FNestedElements.AddNew(THtmAbbr, wciAny);
  FNestedElements.AddNew(THtmAcronym, wciAny);
  FNestedElements.AddNew(THtmSub, wciAny);
  FNestedElements.AddNew(THtmSup, wciAny);
  FNestedElements.AddNew(THtmInput, wciAny);
  FNestedElements.AddNew(THtmSelect, wciAny);
  FNestedElements.AddNew(THtmTextarea, wciAny);
  FNestedElements.AddNew(THtmLabel, wciAny);
  FNestedElements.AddNew(THtmButton, wciAny);
  FNestedElements.AddNew(THtmIns, wciAny);
  FNestedElements.AddNew(THtmDel, wciAny);
  FNestedElements.AddNew(THtmScript, wciAny);

  if wcServerExtensions in xmlENV.xmlCapabilities
  then FNestedElements.AddNew(THtmServerSide, wciAny);
end;

constructor THtmsub.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  // attributes
  FAttributes.AddAttribute(ATTR_id, atID, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_class, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_style, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_title, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_lang, atNMTOKEN, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_xml_lang, atNMTOKEN, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_dir, atList, IMPLIED, NODEFAULT, 'ltr|rtl');
  FAttributes.AddAttribute(ATTR_onclick, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_ondblclick, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmousedown, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseup, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseover, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmousemove, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseout, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeypress, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeydown, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeyup, atCDATA, IMPLIED, NODEFAULT, NOLIST);

  // nested elements
  FNestedElements.AddNew(THtmPCDATA, wciAny);
  FNestedElements.AddNew(THtmA, wciAny);
  FNestedElements.AddNew(THtmBr, wciAny);
  FNestedElements.AddNew(THtmSpan, wciAny);
  FNestedElements.AddNew(THtmBdo, wciAny);
  FNestedElements.AddNew(THtmObject, wciAny);
  FNestedElements.AddNew(THtmApplet, wciAny);
  FNestedElements.AddNew(THtmImg, wciAny);
  FNestedElements.AddNew(THtmMap, wciAny);
  FNestedElements.AddNew(THtmIframe, wciAny);
  FNestedElements.AddNew(THtmTt, wciAny);
  FNestedElements.AddNew(THtmI, wciAny);
  FNestedElements.AddNew(THtmB, wciAny);
  FNestedElements.AddNew(THtmU, wciAny);
  FNestedElements.AddNew(THtmS, wciAny);
  FNestedElements.AddNew(THtmStrike, wciAny);
  FNestedElements.AddNew(THtmBig, wciAny);
  FNestedElements.AddNew(THtmSmall, wciAny);
  FNestedElements.AddNew(THtmFont, wciAny);
  FNestedElements.AddNew(THtmBasefont, wciAny);
  FNestedElements.AddNew(THtmEm, wciAny);
  FNestedElements.AddNew(THtmStrong, wciAny);
  FNestedElements.AddNew(THtmDfn, wciAny);
  FNestedElements.AddNew(THtmCode, wciAny);
  FNestedElements.AddNew(THtmQ, wciAny);
  FNestedElements.AddNew(THtmSamp, wciAny);
  FNestedElements.AddNew(THtmKbd, wciAny);
  FNestedElements.AddNew(THtmVar, wciAny);
  FNestedElements.AddNew(THtmCite, wciAny);
  FNestedElements.AddNew(THtmAbbr, wciAny);
  FNestedElements.AddNew(THtmAcronym, wciAny);
  FNestedElements.AddNew(THtmSub, wciAny);
  FNestedElements.AddNew(THtmSup, wciAny);
  FNestedElements.AddNew(THtmInput, wciAny);
  FNestedElements.AddNew(THtmSelect, wciAny);
  FNestedElements.AddNew(THtmTextarea, wciAny);
  FNestedElements.AddNew(THtmLabel, wciAny);
  FNestedElements.AddNew(THtmButton, wciAny);
  FNestedElements.AddNew(THtmIns, wciAny);
  FNestedElements.AddNew(THtmDel, wciAny);
  FNestedElements.AddNew(THtmScript, wciAny);

  if wcServerExtensions in xmlENV.xmlCapabilities
  then FNestedElements.AddNew(THtmServerSide, wciAny);
end;

constructor THtmsup.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  // attributes
  FAttributes.AddAttribute(ATTR_id, atID, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_class, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_style, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_title, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_lang, atNMTOKEN, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_xml_lang, atNMTOKEN, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_dir, atList, IMPLIED, NODEFAULT, 'ltr|rtl');
  FAttributes.AddAttribute(ATTR_onclick, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_ondblclick, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmousedown, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseup, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseover, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmousemove, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseout, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeypress, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeydown, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeyup, atCDATA, IMPLIED, NODEFAULT, NOLIST);

  // nested elements
  FNestedElements.AddNew(THtmPCDATA, wciAny);
  FNestedElements.AddNew(THtmA, wciAny);
  FNestedElements.AddNew(THtmBr, wciAny);
  FNestedElements.AddNew(THtmSpan, wciAny);
  FNestedElements.AddNew(THtmBdo, wciAny);
  FNestedElements.AddNew(THtmObject, wciAny);
  FNestedElements.AddNew(THtmApplet, wciAny);
  FNestedElements.AddNew(THtmImg, wciAny);
  FNestedElements.AddNew(THtmMap, wciAny);
  FNestedElements.AddNew(THtmIframe, wciAny);
  FNestedElements.AddNew(THtmTt, wciAny);
  FNestedElements.AddNew(THtmI, wciAny);
  FNestedElements.AddNew(THtmB, wciAny);
  FNestedElements.AddNew(THtmU, wciAny);
  FNestedElements.AddNew(THtmS, wciAny);
  FNestedElements.AddNew(THtmStrike, wciAny);
  FNestedElements.AddNew(THtmBig, wciAny);
  FNestedElements.AddNew(THtmSmall, wciAny);
  FNestedElements.AddNew(THtmFont, wciAny);
  FNestedElements.AddNew(THtmBasefont, wciAny);
  FNestedElements.AddNew(THtmEm, wciAny);
  FNestedElements.AddNew(THtmStrong, wciAny);
  FNestedElements.AddNew(THtmDfn, wciAny);
  FNestedElements.AddNew(THtmCode, wciAny);
  FNestedElements.AddNew(THtmQ, wciAny);
  FNestedElements.AddNew(THtmSamp, wciAny);
  FNestedElements.AddNew(THtmKbd, wciAny);
  FNestedElements.AddNew(THtmVar, wciAny);
  FNestedElements.AddNew(THtmCite, wciAny);
  FNestedElements.AddNew(THtmAbbr, wciAny);
  FNestedElements.AddNew(THtmAcronym, wciAny);
  FNestedElements.AddNew(THtmSub, wciAny);
  FNestedElements.AddNew(THtmSup, wciAny);
  FNestedElements.AddNew(THtmInput, wciAny);
  FNestedElements.AddNew(THtmSelect, wciAny);
  FNestedElements.AddNew(THtmTextarea, wciAny);
  FNestedElements.AddNew(THtmLabel, wciAny);
  FNestedElements.AddNew(THtmButton, wciAny);
  FNestedElements.AddNew(THtmIns, wciAny);
  FNestedElements.AddNew(THtmDel, wciAny);
  FNestedElements.AddNew(THtmScript, wciAny);

  if wcServerExtensions in xmlENV.xmlCapabilities
  then FNestedElements.AddNew(THtmServerSide, wciAny);
end;

constructor THtmtt.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  // attributes
  FAttributes.AddAttribute(ATTR_id, atID, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_class, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_style, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_title, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_lang, atNMTOKEN, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_xml_lang, atNMTOKEN, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_dir, atList, IMPLIED, NODEFAULT, 'ltr|rtl');
  FAttributes.AddAttribute(ATTR_onclick, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_ondblclick, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmousedown, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseup, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseover, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmousemove, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseout, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeypress, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeydown, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeyup, atCDATA, IMPLIED, NODEFAULT, NOLIST);

  // nested elements
  FNestedElements.AddNew(THtmPCDATA, wciAny);
  FNestedElements.AddNew(THtmA, wciAny);
  FNestedElements.AddNew(THtmBr, wciAny);
  FNestedElements.AddNew(THtmSpan, wciAny);
  FNestedElements.AddNew(THtmBdo, wciAny);
  FNestedElements.AddNew(THtmObject, wciAny);
  FNestedElements.AddNew(THtmApplet, wciAny);
  FNestedElements.AddNew(THtmImg, wciAny);
  FNestedElements.AddNew(THtmMap, wciAny);
  FNestedElements.AddNew(THtmIframe, wciAny);
  FNestedElements.AddNew(THtmTt, wciAny);
  FNestedElements.AddNew(THtmI, wciAny);
  FNestedElements.AddNew(THtmB, wciAny);
  FNestedElements.AddNew(THtmU, wciAny);
  FNestedElements.AddNew(THtmS, wciAny);
  FNestedElements.AddNew(THtmStrike, wciAny);
  FNestedElements.AddNew(THtmBig, wciAny);
  FNestedElements.AddNew(THtmSmall, wciAny);
  FNestedElements.AddNew(THtmFont, wciAny);
  FNestedElements.AddNew(THtmBasefont, wciAny);
  FNestedElements.AddNew(THtmEm, wciAny);
  FNestedElements.AddNew(THtmStrong, wciAny);
  FNestedElements.AddNew(THtmDfn, wciAny);
  FNestedElements.AddNew(THtmCode, wciAny);
  FNestedElements.AddNew(THtmQ, wciAny);
  FNestedElements.AddNew(THtmSamp, wciAny);
  FNestedElements.AddNew(THtmKbd, wciAny);
  FNestedElements.AddNew(THtmVar, wciAny);
  FNestedElements.AddNew(THtmCite, wciAny);
  FNestedElements.AddNew(THtmAbbr, wciAny);
  FNestedElements.AddNew(THtmAcronym, wciAny);
  FNestedElements.AddNew(THtmSub, wciAny);
  FNestedElements.AddNew(THtmSup, wciAny);
  FNestedElements.AddNew(THtmInput, wciAny);
  FNestedElements.AddNew(THtmSelect, wciAny);
  FNestedElements.AddNew(THtmTextarea, wciAny);
  FNestedElements.AddNew(THtmLabel, wciAny);
  FNestedElements.AddNew(THtmButton, wciAny);
  FNestedElements.AddNew(THtmIns, wciAny);
  FNestedElements.AddNew(THtmDel, wciAny);
  FNestedElements.AddNew(THtmScript, wciAny);

  if wcServerExtensions in xmlENV.xmlCapabilities
  then FNestedElements.AddNew(THtmServerSide, wciAny);
end;

constructor THtmi.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  // attributes
  FAttributes.AddAttribute(ATTR_id, atID, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_class, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_style, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_title, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_lang, atNMTOKEN, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_xml_lang, atNMTOKEN, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_dir, atList, IMPLIED, NODEFAULT, 'ltr|rtl');
  FAttributes.AddAttribute(ATTR_onclick, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_ondblclick, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmousedown, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseup, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseover, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmousemove, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseout, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeypress, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeydown, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeyup, atCDATA, IMPLIED, NODEFAULT, NOLIST);

  // nested elements
  FNestedElements.AddNew(THtmPCDATA, wciAny);
  FNestedElements.AddNew(THtmA, wciAny);
  FNestedElements.AddNew(THtmBr, wciAny);
  FNestedElements.AddNew(THtmSpan, wciAny);
  FNestedElements.AddNew(THtmBdo, wciAny);
  FNestedElements.AddNew(THtmObject, wciAny);
  FNestedElements.AddNew(THtmApplet, wciAny);
  FNestedElements.AddNew(THtmImg, wciAny);
  FNestedElements.AddNew(THtmMap, wciAny);
  FNestedElements.AddNew(THtmIframe, wciAny);
  FNestedElements.AddNew(THtmTt, wciAny);
  FNestedElements.AddNew(THtmI, wciAny);
  FNestedElements.AddNew(THtmB, wciAny);
  FNestedElements.AddNew(THtmU, wciAny);
  FNestedElements.AddNew(THtmS, wciAny);
  FNestedElements.AddNew(THtmStrike, wciAny);
  FNestedElements.AddNew(THtmBig, wciAny);
  FNestedElements.AddNew(THtmSmall, wciAny);
  FNestedElements.AddNew(THtmFont, wciAny);
  FNestedElements.AddNew(THtmBasefont, wciAny);
  FNestedElements.AddNew(THtmEm, wciAny);
  FNestedElements.AddNew(THtmStrong, wciAny);
  FNestedElements.AddNew(THtmDfn, wciAny);
  FNestedElements.AddNew(THtmCode, wciAny);
  FNestedElements.AddNew(THtmQ, wciAny);
  FNestedElements.AddNew(THtmSamp, wciAny);
  FNestedElements.AddNew(THtmKbd, wciAny);
  FNestedElements.AddNew(THtmVar, wciAny);
  FNestedElements.AddNew(THtmCite, wciAny);
  FNestedElements.AddNew(THtmAbbr, wciAny);
  FNestedElements.AddNew(THtmAcronym, wciAny);
  FNestedElements.AddNew(THtmSub, wciAny);
  FNestedElements.AddNew(THtmSup, wciAny);
  FNestedElements.AddNew(THtmInput, wciAny);
  FNestedElements.AddNew(THtmSelect, wciAny);
  FNestedElements.AddNew(THtmTextarea, wciAny);
  FNestedElements.AddNew(THtmLabel, wciAny);
  FNestedElements.AddNew(THtmButton, wciAny);
  FNestedElements.AddNew(THtmIns, wciAny);
  FNestedElements.AddNew(THtmDel, wciAny);
  FNestedElements.AddNew(THtmScript, wciAny);

  if wcServerExtensions in xmlENV.xmlCapabilities
  then FNestedElements.AddNew(THtmServerSide, wciAny);
end;

constructor THtmb.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  // attributes
  FAttributes.AddAttribute(ATTR_id, atID, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_class, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_style, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_title, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_lang, atNMTOKEN, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_xml_lang, atNMTOKEN, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_dir, atList, IMPLIED, NODEFAULT, 'ltr|rtl');
  FAttributes.AddAttribute(ATTR_onclick, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_ondblclick, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmousedown, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseup, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseover, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmousemove, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseout, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeypress, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeydown, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeyup, atCDATA, IMPLIED, NODEFAULT, NOLIST);

  // nested elements
  FNestedElements.AddNew(THtmPCDATA, wciAny);
  FNestedElements.AddNew(THtmA, wciAny);
  FNestedElements.AddNew(THtmBr, wciAny);
  FNestedElements.AddNew(THtmSpan, wciAny);
  FNestedElements.AddNew(THtmBdo, wciAny);
  FNestedElements.AddNew(THtmObject, wciAny);
  FNestedElements.AddNew(THtmApplet, wciAny);
  FNestedElements.AddNew(THtmImg, wciAny);
  FNestedElements.AddNew(THtmMap, wciAny);
  FNestedElements.AddNew(THtmIframe, wciAny);
  FNestedElements.AddNew(THtmTt, wciAny);
  FNestedElements.AddNew(THtmI, wciAny);
  FNestedElements.AddNew(THtmB, wciAny);
  FNestedElements.AddNew(THtmU, wciAny);
  FNestedElements.AddNew(THtmS, wciAny);
  FNestedElements.AddNew(THtmStrike, wciAny);
  FNestedElements.AddNew(THtmBig, wciAny);
  FNestedElements.AddNew(THtmSmall, wciAny);
  FNestedElements.AddNew(THtmFont, wciAny);
  FNestedElements.AddNew(THtmBasefont, wciAny);
  FNestedElements.AddNew(THtmEm, wciAny);
  FNestedElements.AddNew(THtmStrong, wciAny);
  FNestedElements.AddNew(THtmDfn, wciAny);
  FNestedElements.AddNew(THtmCode, wciAny);
  FNestedElements.AddNew(THtmQ, wciAny);
  FNestedElements.AddNew(THtmSamp, wciAny);
  FNestedElements.AddNew(THtmKbd, wciAny);
  FNestedElements.AddNew(THtmVar, wciAny);
  FNestedElements.AddNew(THtmCite, wciAny);
  FNestedElements.AddNew(THtmAbbr, wciAny);
  FNestedElements.AddNew(THtmAcronym, wciAny);
  FNestedElements.AddNew(THtmSub, wciAny);
  FNestedElements.AddNew(THtmSup, wciAny);
  FNestedElements.AddNew(THtmInput, wciAny);
  FNestedElements.AddNew(THtmSelect, wciAny);
  FNestedElements.AddNew(THtmTextarea, wciAny);
  FNestedElements.AddNew(THtmLabel, wciAny);
  FNestedElements.AddNew(THtmButton, wciAny);
  FNestedElements.AddNew(THtmIns, wciAny);
  FNestedElements.AddNew(THtmDel, wciAny);
  FNestedElements.AddNew(THtmScript, wciAny);

  if wcServerExtensions in xmlENV.xmlCapabilities
  then FNestedElements.AddNew(THtmServerSide, wciAny);
end;

constructor THtmbig.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  // attributes
  FAttributes.AddAttribute(ATTR_id, atID, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_class, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_style, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_title, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_lang, atNMTOKEN, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_xml_lang, atNMTOKEN, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_dir, atList, IMPLIED, NODEFAULT, 'ltr|rtl');
  FAttributes.AddAttribute(ATTR_onclick, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_ondblclick, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmousedown, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseup, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseover, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmousemove, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseout, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeypress, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeydown, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeyup, atCDATA, IMPLIED, NODEFAULT, NOLIST);

  // nested elements
  FNestedElements.AddNew(THtmPCDATA, wciAny);
  FNestedElements.AddNew(THtmA, wciAny);
  FNestedElements.AddNew(THtmBr, wciAny);
  FNestedElements.AddNew(THtmSpan, wciAny);
  FNestedElements.AddNew(THtmBdo, wciAny);
  FNestedElements.AddNew(THtmObject, wciAny);
  FNestedElements.AddNew(THtmApplet, wciAny);
  FNestedElements.AddNew(THtmImg, wciAny);
  FNestedElements.AddNew(THtmMap, wciAny);
  FNestedElements.AddNew(THtmIframe, wciAny);
  FNestedElements.AddNew(THtmTt, wciAny);
  FNestedElements.AddNew(THtmI, wciAny);
  FNestedElements.AddNew(THtmB, wciAny);
  FNestedElements.AddNew(THtmU, wciAny);
  FNestedElements.AddNew(THtmS, wciAny);
  FNestedElements.AddNew(THtmStrike, wciAny);
  FNestedElements.AddNew(THtmBig, wciAny);
  FNestedElements.AddNew(THtmSmall, wciAny);
  FNestedElements.AddNew(THtmFont, wciAny);
  FNestedElements.AddNew(THtmBasefont, wciAny);
  FNestedElements.AddNew(THtmEm, wciAny);
  FNestedElements.AddNew(THtmStrong, wciAny);
  FNestedElements.AddNew(THtmDfn, wciAny);
  FNestedElements.AddNew(THtmCode, wciAny);
  FNestedElements.AddNew(THtmQ, wciAny);
  FNestedElements.AddNew(THtmSamp, wciAny);
  FNestedElements.AddNew(THtmKbd, wciAny);
  FNestedElements.AddNew(THtmVar, wciAny);
  FNestedElements.AddNew(THtmCite, wciAny);
  FNestedElements.AddNew(THtmAbbr, wciAny);
  FNestedElements.AddNew(THtmAcronym, wciAny);
  FNestedElements.AddNew(THtmSub, wciAny);
  FNestedElements.AddNew(THtmSup, wciAny);
  FNestedElements.AddNew(THtmInput, wciAny);
  FNestedElements.AddNew(THtmSelect, wciAny);
  FNestedElements.AddNew(THtmTextarea, wciAny);
  FNestedElements.AddNew(THtmLabel, wciAny);
  FNestedElements.AddNew(THtmButton, wciAny);
  FNestedElements.AddNew(THtmIns, wciAny);
  FNestedElements.AddNew(THtmDel, wciAny);
  FNestedElements.AddNew(THtmScript, wciAny);

  if wcServerExtensions in xmlENV.xmlCapabilities
  then FNestedElements.AddNew(THtmServerSide, wciAny);
end;

constructor THtmsmall.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  // attributes
  FAttributes.AddAttribute(ATTR_id, atID, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_class, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_style, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_title, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_lang, atNMTOKEN, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_xml_lang, atNMTOKEN, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_dir, atList, IMPLIED, NODEFAULT, 'ltr|rtl');
  FAttributes.AddAttribute(ATTR_onclick, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_ondblclick, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmousedown, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseup, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseover, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmousemove, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseout, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeypress, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeydown, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeyup, atCDATA, IMPLIED, NODEFAULT, NOLIST);

  // nested elements
  FNestedElements.AddNew(THtmPCDATA, wciAny);
  FNestedElements.AddNew(THtmA, wciAny);
  FNestedElements.AddNew(THtmBr, wciAny);
  FNestedElements.AddNew(THtmSpan, wciAny);
  FNestedElements.AddNew(THtmBdo, wciAny);
  FNestedElements.AddNew(THtmObject, wciAny);
  FNestedElements.AddNew(THtmApplet, wciAny);
  FNestedElements.AddNew(THtmImg, wciAny);
  FNestedElements.AddNew(THtmMap, wciAny);
  FNestedElements.AddNew(THtmIframe, wciAny);
  FNestedElements.AddNew(THtmTt, wciAny);
  FNestedElements.AddNew(THtmI, wciAny);
  FNestedElements.AddNew(THtmB, wciAny);
  FNestedElements.AddNew(THtmU, wciAny);
  FNestedElements.AddNew(THtmS, wciAny);
  FNestedElements.AddNew(THtmStrike, wciAny);
  FNestedElements.AddNew(THtmBig, wciAny);
  FNestedElements.AddNew(THtmSmall, wciAny);
  FNestedElements.AddNew(THtmFont, wciAny);
  FNestedElements.AddNew(THtmBasefont, wciAny);
  FNestedElements.AddNew(THtmEm, wciAny);
  FNestedElements.AddNew(THtmStrong, wciAny);
  FNestedElements.AddNew(THtmDfn, wciAny);
  FNestedElements.AddNew(THtmCode, wciAny);
  FNestedElements.AddNew(THtmQ, wciAny);
  FNestedElements.AddNew(THtmSamp, wciAny);
  FNestedElements.AddNew(THtmKbd, wciAny);
  FNestedElements.AddNew(THtmVar, wciAny);
  FNestedElements.AddNew(THtmCite, wciAny);
  FNestedElements.AddNew(THtmAbbr, wciAny);
  FNestedElements.AddNew(THtmAcronym, wciAny);
  FNestedElements.AddNew(THtmSub, wciAny);
  FNestedElements.AddNew(THtmSup, wciAny);
  FNestedElements.AddNew(THtmInput, wciAny);
  FNestedElements.AddNew(THtmSelect, wciAny);
  FNestedElements.AddNew(THtmTextarea, wciAny);
  FNestedElements.AddNew(THtmLabel, wciAny);
  FNestedElements.AddNew(THtmButton, wciAny);
  FNestedElements.AddNew(THtmIns, wciAny);
  FNestedElements.AddNew(THtmDel, wciAny);
  FNestedElements.AddNew(THtmScript, wciAny);

  if wcServerExtensions in xmlENV.xmlCapabilities
  then FNestedElements.AddNew(THtmServerSide, wciAny);
end;

constructor THtmu.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  // attributes
  FAttributes.AddAttribute(ATTR_id, atID, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_class, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_style, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_title, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_lang, atNMTOKEN, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_xml_lang, atNMTOKEN, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_dir, atList, IMPLIED, NODEFAULT, 'ltr|rtl');
  FAttributes.AddAttribute(ATTR_onclick, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_ondblclick, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmousedown, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseup, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseover, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmousemove, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseout, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeypress, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeydown, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeyup, atCDATA, IMPLIED, NODEFAULT, NOLIST);

  // nested elements
  FNestedElements.AddNew(THtmPCDATA, wciAny);
  FNestedElements.AddNew(THtmA, wciAny);
  FNestedElements.AddNew(THtmBr, wciAny);
  FNestedElements.AddNew(THtmSpan, wciAny);
  FNestedElements.AddNew(THtmBdo, wciAny);
  FNestedElements.AddNew(THtmObject, wciAny);
  FNestedElements.AddNew(THtmApplet, wciAny);
  FNestedElements.AddNew(THtmImg, wciAny);
  FNestedElements.AddNew(THtmMap, wciAny);
  FNestedElements.AddNew(THtmIframe, wciAny);
  FNestedElements.AddNew(THtmTt, wciAny);
  FNestedElements.AddNew(THtmI, wciAny);
  FNestedElements.AddNew(THtmB, wciAny);
  FNestedElements.AddNew(THtmU, wciAny);
  FNestedElements.AddNew(THtmS, wciAny);
  FNestedElements.AddNew(THtmStrike, wciAny);
  FNestedElements.AddNew(THtmBig, wciAny);
  FNestedElements.AddNew(THtmSmall, wciAny);
  FNestedElements.AddNew(THtmFont, wciAny);
  FNestedElements.AddNew(THtmBasefont, wciAny);
  FNestedElements.AddNew(THtmEm, wciAny);
  FNestedElements.AddNew(THtmStrong, wciAny);
  FNestedElements.AddNew(THtmDfn, wciAny);
  FNestedElements.AddNew(THtmCode, wciAny);
  FNestedElements.AddNew(THtmQ, wciAny);
  FNestedElements.AddNew(THtmSamp, wciAny);
  FNestedElements.AddNew(THtmKbd, wciAny);
  FNestedElements.AddNew(THtmVar, wciAny);
  FNestedElements.AddNew(THtmCite, wciAny);
  FNestedElements.AddNew(THtmAbbr, wciAny);
  FNestedElements.AddNew(THtmAcronym, wciAny);
  FNestedElements.AddNew(THtmSub, wciAny);
  FNestedElements.AddNew(THtmSup, wciAny);
  FNestedElements.AddNew(THtmInput, wciAny);
  FNestedElements.AddNew(THtmSelect, wciAny);
  FNestedElements.AddNew(THtmTextarea, wciAny);
  FNestedElements.AddNew(THtmLabel, wciAny);
  FNestedElements.AddNew(THtmButton, wciAny);
  FNestedElements.AddNew(THtmIns, wciAny);
  FNestedElements.AddNew(THtmDel, wciAny);
  FNestedElements.AddNew(THtmScript, wciAny);

  if wcServerExtensions in xmlENV.xmlCapabilities
  then FNestedElements.AddNew(THtmServerSide, wciAny);
end;

constructor THtms.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  // attributes
  FAttributes.AddAttribute(ATTR_id, atID, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_class, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_style, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_title, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_lang, atNMTOKEN, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_xml_lang, atNMTOKEN, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_dir, atList, IMPLIED, NODEFAULT, 'ltr|rtl');
  FAttributes.AddAttribute(ATTR_onclick, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_ondblclick, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmousedown, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseup, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseover, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmousemove, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseout, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeypress, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeydown, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeyup, atCDATA, IMPLIED, NODEFAULT, NOLIST);

  // nested elements
  FNestedElements.AddNew(THtmPCDATA, wciAny);
  FNestedElements.AddNew(THtmA, wciAny);
  FNestedElements.AddNew(THtmBr, wciAny);
  FNestedElements.AddNew(THtmSpan, wciAny);
  FNestedElements.AddNew(THtmBdo, wciAny);
  FNestedElements.AddNew(THtmObject, wciAny);
  FNestedElements.AddNew(THtmApplet, wciAny);
  FNestedElements.AddNew(THtmImg, wciAny);
  FNestedElements.AddNew(THtmMap, wciAny);
  FNestedElements.AddNew(THtmIframe, wciAny);
  FNestedElements.AddNew(THtmTt, wciAny);
  FNestedElements.AddNew(THtmI, wciAny);
  FNestedElements.AddNew(THtmB, wciAny);
  FNestedElements.AddNew(THtmU, wciAny);
  FNestedElements.AddNew(THtmS, wciAny);
  FNestedElements.AddNew(THtmStrike, wciAny);
  FNestedElements.AddNew(THtmBig, wciAny);
  FNestedElements.AddNew(THtmSmall, wciAny);
  FNestedElements.AddNew(THtmFont, wciAny);
  FNestedElements.AddNew(THtmBasefont, wciAny);
  FNestedElements.AddNew(THtmEm, wciAny);
  FNestedElements.AddNew(THtmStrong, wciAny);
  FNestedElements.AddNew(THtmDfn, wciAny);
  FNestedElements.AddNew(THtmCode, wciAny);
  FNestedElements.AddNew(THtmQ, wciAny);
  FNestedElements.AddNew(THtmSamp, wciAny);
  FNestedElements.AddNew(THtmKbd, wciAny);
  FNestedElements.AddNew(THtmVar, wciAny);
  FNestedElements.AddNew(THtmCite, wciAny);
  FNestedElements.AddNew(THtmAbbr, wciAny);
  FNestedElements.AddNew(THtmAcronym, wciAny);
  FNestedElements.AddNew(THtmSub, wciAny);
  FNestedElements.AddNew(THtmSup, wciAny);
  FNestedElements.AddNew(THtmInput, wciAny);
  FNestedElements.AddNew(THtmSelect, wciAny);
  FNestedElements.AddNew(THtmTextarea, wciAny);
  FNestedElements.AddNew(THtmLabel, wciAny);
  FNestedElements.AddNew(THtmButton, wciAny);
  FNestedElements.AddNew(THtmIns, wciAny);
  FNestedElements.AddNew(THtmDel, wciAny);
  FNestedElements.AddNew(THtmScript, wciAny);

  if wcServerExtensions in xmlENV.xmlCapabilities
  then FNestedElements.AddNew(THtmServerSide, wciAny);
end;

constructor THtmstrike.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  // attributes
  FAttributes.AddAttribute(ATTR_id, atID, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_class, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_style, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_title, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_lang, atNMTOKEN, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_xml_lang, atNMTOKEN, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_dir, atList, IMPLIED, NODEFAULT, 'ltr|rtl');
  FAttributes.AddAttribute(ATTR_onclick, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_ondblclick, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmousedown, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseup, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseover, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmousemove, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseout, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeypress, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeydown, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeyup, atCDATA, IMPLIED, NODEFAULT, NOLIST);

  // nested elements
  FNestedElements.AddNew(THtmPCDATA, wciAny);
  FNestedElements.AddNew(THtmA, wciAny);
  FNestedElements.AddNew(THtmBr, wciAny);
  FNestedElements.AddNew(THtmSpan, wciAny);
  FNestedElements.AddNew(THtmBdo, wciAny);
  FNestedElements.AddNew(THtmObject, wciAny);
  FNestedElements.AddNew(THtmApplet, wciAny);
  FNestedElements.AddNew(THtmImg, wciAny);
  FNestedElements.AddNew(THtmMap, wciAny);
  FNestedElements.AddNew(THtmIframe, wciAny);
  FNestedElements.AddNew(THtmTt, wciAny);
  FNestedElements.AddNew(THtmI, wciAny);
  FNestedElements.AddNew(THtmB, wciAny);
  FNestedElements.AddNew(THtmU, wciAny);
  FNestedElements.AddNew(THtmS, wciAny);
  FNestedElements.AddNew(THtmStrike, wciAny);
  FNestedElements.AddNew(THtmBig, wciAny);
  FNestedElements.AddNew(THtmSmall, wciAny);
  FNestedElements.AddNew(THtmFont, wciAny);
  FNestedElements.AddNew(THtmBasefont, wciAny);
  FNestedElements.AddNew(THtmEm, wciAny);
  FNestedElements.AddNew(THtmStrong, wciAny);
  FNestedElements.AddNew(THtmDfn, wciAny);
  FNestedElements.AddNew(THtmCode, wciAny);
  FNestedElements.AddNew(THtmQ, wciAny);
  FNestedElements.AddNew(THtmSamp, wciAny);
  FNestedElements.AddNew(THtmKbd, wciAny);
  FNestedElements.AddNew(THtmVar, wciAny);
  FNestedElements.AddNew(THtmCite, wciAny);
  FNestedElements.AddNew(THtmAbbr, wciAny);
  FNestedElements.AddNew(THtmAcronym, wciAny);
  FNestedElements.AddNew(THtmSub, wciAny);
  FNestedElements.AddNew(THtmSup, wciAny);
  FNestedElements.AddNew(THtmInput, wciAny);
  FNestedElements.AddNew(THtmSelect, wciAny);
  FNestedElements.AddNew(THtmTextarea, wciAny);
  FNestedElements.AddNew(THtmLabel, wciAny);
  FNestedElements.AddNew(THtmButton, wciAny);
  FNestedElements.AddNew(THtmIns, wciAny);
  FNestedElements.AddNew(THtmDel, wciAny);
  FNestedElements.AddNew(THtmScript, wciAny);

  if wcServerExtensions in xmlENV.xmlCapabilities
  then FNestedElements.AddNew(THtmServerSide, wciAny);
end;

constructor THtmbasefont.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  // attributes
  FAttributes.AddAttribute(ATTR_id, atID, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_size, atCDATA, REQUIRED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_color, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_face, atCDATA, IMPLIED, NODEFAULT, NOLIST);

  // EMPTY 
end;

constructor THtmfont.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  // attributes
  FAttributes.AddAttribute(ATTR_id, atID, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_class, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_style, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_title, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_lang, atNMTOKEN, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_xml_lang, atNMTOKEN, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_dir, atList, IMPLIED, NODEFAULT, 'ltr|rtl');
  FAttributes.AddAttribute(ATTR_size, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_color, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_face, atCDATA, IMPLIED, NODEFAULT, NOLIST);

  // nested elements
  FNestedElements.AddNew(THtmPCDATA, wciAny);
  FNestedElements.AddNew(THtmA, wciAny);
  FNestedElements.AddNew(THtmBr, wciAny);
  FNestedElements.AddNew(THtmSpan, wciAny);
  FNestedElements.AddNew(THtmBdo, wciAny);
  FNestedElements.AddNew(THtmObject, wciAny);
  FNestedElements.AddNew(THtmApplet, wciAny);
  FNestedElements.AddNew(THtmImg, wciAny);
  FNestedElements.AddNew(THtmMap, wciAny);
  FNestedElements.AddNew(THtmIframe, wciAny);
  FNestedElements.AddNew(THtmTt, wciAny);
  FNestedElements.AddNew(THtmI, wciAny);
  FNestedElements.AddNew(THtmB, wciAny);
  FNestedElements.AddNew(THtmU, wciAny);
  FNestedElements.AddNew(THtmS, wciAny);
  FNestedElements.AddNew(THtmStrike, wciAny);
  FNestedElements.AddNew(THtmBig, wciAny);
  FNestedElements.AddNew(THtmSmall, wciAny);
  FNestedElements.AddNew(THtmFont, wciAny);
  FNestedElements.AddNew(THtmBasefont, wciAny);
  FNestedElements.AddNew(THtmEm, wciAny);
  FNestedElements.AddNew(THtmStrong, wciAny);
  FNestedElements.AddNew(THtmDfn, wciAny);
  FNestedElements.AddNew(THtmCode, wciAny);
  FNestedElements.AddNew(THtmQ, wciAny);
  FNestedElements.AddNew(THtmSamp, wciAny);
  FNestedElements.AddNew(THtmKbd, wciAny);
  FNestedElements.AddNew(THtmVar, wciAny);
  FNestedElements.AddNew(THtmCite, wciAny);
  FNestedElements.AddNew(THtmAbbr, wciAny);
  FNestedElements.AddNew(THtmAcronym, wciAny);
  FNestedElements.AddNew(THtmSub, wciAny);
  FNestedElements.AddNew(THtmSup, wciAny);
  FNestedElements.AddNew(THtmInput, wciAny);
  FNestedElements.AddNew(THtmSelect, wciAny);
  FNestedElements.AddNew(THtmTextarea, wciAny);
  FNestedElements.AddNew(THtmLabel, wciAny);
  FNestedElements.AddNew(THtmButton, wciAny);
  FNestedElements.AddNew(THtmIns, wciAny);
  FNestedElements.AddNew(THtmDel, wciAny);
  FNestedElements.AddNew(THtmScript, wciAny);

  if wcServerExtensions in xmlENV.xmlCapabilities
  then FNestedElements.AddNew(THtmServerSide, wciAny);
end;

constructor THtmobject.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  // attributes
  FAttributes.AddAttribute(ATTR_id, atID, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_class, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_style, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_title, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_lang, atNMTOKEN, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_xml_lang, atNMTOKEN, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_dir, atList, IMPLIED, NODEFAULT, 'ltr|rtl');
  FAttributes.AddAttribute(ATTR_onclick, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_ondblclick, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmousedown, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseup, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseover, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmousemove, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseout, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeypress, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeydown, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeyup, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_declare, atList, IMPLIED, NODEFAULT, 'declare');
  FAttributes.AddAttribute(ATTR_classid, atHREF, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_codebase, atHREF, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_data, atHREF, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_type, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_codetype, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_archive, atCDATA, IMPLIED, NODEFAULT, NOLIST);  // URIList
  FAttributes.AddAttribute(ATTR_standby, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_height, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_width, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_usemap, atHREF, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_name, atNMTOKEN, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_tabindex, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_align, atList, IMPLIED, NODEFAULT, 'top|middle|bottom|left|right');
  FAttributes.AddAttribute(ATTR_border, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_hspace, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_vspace, atCDATA, IMPLIED, NODEFAULT, NOLIST);

  // nested elements
  FNestedElements.AddNew(THtmPCDATA, wciAny);
  FNestedElements.AddNew(THtmParam, wciAny);
  FNestedElements.AddNew(THtmP, wciAny);
  FNestedElements.AddNew(THtmH1, wciAny);
  FNestedElements.AddNew(THtmH2, wciAny);
  FNestedElements.AddNew(THtmH3, wciAny);
  FNestedElements.AddNew(THtmH4, wciAny);
  FNestedElements.AddNew(THtmH5, wciAny);
  FNestedElements.AddNew(THtmH6, wciAny);
  FNestedElements.AddNew(THtmDiv, wciAny);
  FNestedElements.AddNew(THtmUl, wciAny);
  FNestedElements.AddNew(THtmOl, wciAny);
  FNestedElements.AddNew(THtmDl, wciAny);
  FNestedElements.AddNew(THtmMenu, wciAny);
  FNestedElements.AddNew(THtmDir, wciAny);
  FNestedElements.AddNew(THtmPre, wciAny);
  FNestedElements.AddNew(THtmHr, wciAny);
  FNestedElements.AddNew(THtmBlockquote, wciAny);
  FNestedElements.AddNew(THtmAddress, wciAny);
  FNestedElements.AddNew(THtmCenter, wciAny);
  FNestedElements.AddNew(THtmNoframes, wciAny);
  FNestedElements.AddNew(THtmIsindex, wciAny);
  FNestedElements.AddNew(THtmFieldset, wciAny);
  FNestedElements.AddNew(THtmTable, wciAny);
  FNestedElements.AddNew(THtmForm, wciAny);
  FNestedElements.AddNew(THtmA, wciAny);
  FNestedElements.AddNew(THtmBr, wciAny);
  FNestedElements.AddNew(THtmSpan, wciAny);
  FNestedElements.AddNew(THtmBdo, wciAny);
  FNestedElements.AddNew(THtmObject, wciAny);
  FNestedElements.AddNew(THtmApplet, wciAny);
  FNestedElements.AddNew(THtmImg, wciAny);
  FNestedElements.AddNew(THtmMap, wciAny);
  FNestedElements.AddNew(THtmIframe, wciAny);
  FNestedElements.AddNew(THtmTt, wciAny);
  FNestedElements.AddNew(THtmI, wciAny);
  FNestedElements.AddNew(THtmB, wciAny);
  FNestedElements.AddNew(THtmU, wciAny);
  FNestedElements.AddNew(THtmS, wciAny);
  FNestedElements.AddNew(THtmStrike, wciAny);
  FNestedElements.AddNew(THtmBig, wciAny);
  FNestedElements.AddNew(THtmSmall, wciAny);
  FNestedElements.AddNew(THtmFont, wciAny);
  FNestedElements.AddNew(THtmBasefont, wciAny);
  FNestedElements.AddNew(THtmEm, wciAny);
  FNestedElements.AddNew(THtmStrong, wciAny);
  FNestedElements.AddNew(THtmDfn, wciAny);
  FNestedElements.AddNew(THtmCode, wciAny);
  FNestedElements.AddNew(THtmQ, wciAny);
  FNestedElements.AddNew(THtmSamp, wciAny);
  FNestedElements.AddNew(THtmKbd, wciAny);
  FNestedElements.AddNew(THtmVar, wciAny);
  FNestedElements.AddNew(THtmCite, wciAny);
  FNestedElements.AddNew(THtmAbbr, wciAny);
  FNestedElements.AddNew(THtmAcronym, wciAny);
  FNestedElements.AddNew(THtmSub, wciAny);
  FNestedElements.AddNew(THtmSup, wciAny);
  FNestedElements.AddNew(THtmInput, wciAny);
  FNestedElements.AddNew(THtmSelect, wciAny);
  FNestedElements.AddNew(THtmTextarea, wciAny);
  FNestedElements.AddNew(THtmLabel, wciAny);
  FNestedElements.AddNew(THtmButton, wciAny);
  FNestedElements.AddNew(THtmNoscript, wciAny);
  FNestedElements.AddNew(THtmIns, wciAny);
  FNestedElements.AddNew(THtmDel, wciAny);
  FNestedElements.AddNew(THtmScript, wciAny);

  if wcServerExtensions in xmlENV.xmlCapabilities
  then FNestedElements.AddNew(THtmServerSide, wciAny);
end;

constructor THtmparam.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  // attributes
  FAttributes.AddAttribute(ATTR_id, atID, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_name, atCDATA, REQUIRED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_value, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_valuetype, atList, IMPLIED, 'data', 'data|ref|object');
  FAttributes.AddAttribute(ATTR_type, atCDATA, IMPLIED, NODEFAULT, NOLIST);

  // EMPTY 
end;

constructor THtmapplet.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  // attributes
  FAttributes.AddAttribute(ATTR_id, atID, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_class, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_style, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_title, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_codebase, atHREF, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_archive, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_code, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_object, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_alt, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_name, atNMTOKEN, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_width, atCDATA, REQUIRED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_height, atCDATA, REQUIRED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_align, atList, IMPLIED, NODEFAULT, 'top|middle|bottom|left|right');
  FAttributes.AddAttribute(ATTR_hspace, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_vspace, atCDATA, IMPLIED, NODEFAULT, NOLIST);

  // nested elements
  FNestedElements.AddNew(THtmPCDATA, wciAny);
  FNestedElements.AddNew(THtmParam, wciAny);
  FNestedElements.AddNew(THtmP, wciAny);
  FNestedElements.AddNew(THtmH1, wciAny);
  FNestedElements.AddNew(THtmH2, wciAny);
  FNestedElements.AddNew(THtmH3, wciAny);
  FNestedElements.AddNew(THtmH4, wciAny);
  FNestedElements.AddNew(THtmH5, wciAny);
  FNestedElements.AddNew(THtmH6, wciAny);
  FNestedElements.AddNew(THtmDiv, wciAny);
  FNestedElements.AddNew(THtmUl, wciAny);
  FNestedElements.AddNew(THtmOl, wciAny);
  FNestedElements.AddNew(THtmDl, wciAny);
  FNestedElements.AddNew(THtmMenu, wciAny);
  FNestedElements.AddNew(THtmDir, wciAny);
  FNestedElements.AddNew(THtmPre, wciAny);
  FNestedElements.AddNew(THtmHr, wciAny);
  FNestedElements.AddNew(THtmBlockquote, wciAny);
  FNestedElements.AddNew(THtmAddress, wciAny);
  FNestedElements.AddNew(THtmCenter, wciAny);
  FNestedElements.AddNew(THtmNoframes, wciAny);
  FNestedElements.AddNew(THtmIsindex, wciAny);
  FNestedElements.AddNew(THtmFieldset, wciAny);
  FNestedElements.AddNew(THtmTable, wciAny);
  FNestedElements.AddNew(THtmForm, wciAny);
  FNestedElements.AddNew(THtmA, wciAny);
  FNestedElements.AddNew(THtmBr, wciAny);
  FNestedElements.AddNew(THtmSpan, wciAny);
  FNestedElements.AddNew(THtmBdo, wciAny);
  FNestedElements.AddNew(THtmObject, wciAny);
  FNestedElements.AddNew(THtmApplet, wciAny);
  FNestedElements.AddNew(THtmImg, wciAny);
  FNestedElements.AddNew(THtmMap, wciAny);
  FNestedElements.AddNew(THtmIframe, wciAny);
  FNestedElements.AddNew(THtmTt, wciAny);
  FNestedElements.AddNew(THtmI, wciAny);
  FNestedElements.AddNew(THtmB, wciAny);
  FNestedElements.AddNew(THtmU, wciAny);
  FNestedElements.AddNew(THtmS, wciAny);
  FNestedElements.AddNew(THtmStrike, wciAny);
  FNestedElements.AddNew(THtmBig, wciAny);
  FNestedElements.AddNew(THtmSmall, wciAny);
  FNestedElements.AddNew(THtmFont, wciAny);
  FNestedElements.AddNew(THtmBasefont, wciAny);
  FNestedElements.AddNew(THtmEm, wciAny);
  FNestedElements.AddNew(THtmStrong, wciAny);
  FNestedElements.AddNew(THtmDfn, wciAny);
  FNestedElements.AddNew(THtmCode, wciAny);
  FNestedElements.AddNew(THtmQ, wciAny);
  FNestedElements.AddNew(THtmSamp, wciAny);
  FNestedElements.AddNew(THtmKbd, wciAny);
  FNestedElements.AddNew(THtmVar, wciAny);
  FNestedElements.AddNew(THtmCite, wciAny);
  FNestedElements.AddNew(THtmAbbr, wciAny);
  FNestedElements.AddNew(THtmAcronym, wciAny);
  FNestedElements.AddNew(THtmSub, wciAny);
  FNestedElements.AddNew(THtmSup, wciAny);
  FNestedElements.AddNew(THtmInput, wciAny);
  FNestedElements.AddNew(THtmSelect, wciAny);
  FNestedElements.AddNew(THtmTextarea, wciAny);
  FNestedElements.AddNew(THtmLabel, wciAny);
  FNestedElements.AddNew(THtmButton, wciAny);
  FNestedElements.AddNew(THtmNoscript, wciAny);
  FNestedElements.AddNew(THtmIns, wciAny);
  FNestedElements.AddNew(THtmDel, wciAny);
  FNestedElements.AddNew(THtmScript, wciAny);

  if wcServerExtensions in xmlENV.xmlCapabilities
  then FNestedElements.AddNew(THtmServerSide, wciAny);
end;

constructor THtmimg.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  // attributes
  FAttributes.AddAttribute(ATTR_id, atID, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_class, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_style, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_title, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_lang, atNMTOKEN, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_xml_lang, atNMTOKEN, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_dir, atList, IMPLIED, NODEFAULT, 'ltr|rtl');
  FAttributes.AddAttribute(ATTR_onclick, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_ondblclick, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmousedown, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseup, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseover, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmousemove, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseout, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeypress, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeydown, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeyup, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_src, atHREF, REQUIRED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_alt, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_name, atNMTOKEN, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_longdesc, atHREF, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_height, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_width, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_usemap, atHREF, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_ismap, atList, IMPLIED, NODEFAULT, 'ismap');
  FAttributes.AddAttribute(ATTR_align, atList, IMPLIED, NODEFAULT, 'top|middle|bottom|left|right|absmiddle|absbottom|baseline|texttop');
  FAttributes.AddAttribute(ATTR_border, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_hspace, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_vspace, atCDATA, IMPLIED, NODEFAULT, NOLIST);

  // EMPTY
end;

constructor THtmmap.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  // attributes
  FAttributes.AddAttribute(ATTR_lang, atNMTOKEN, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_xml_lang, atNMTOKEN, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_dir, atList, IMPLIED, NODEFAULT, 'ltr|rtl');
  FAttributes.AddAttribute(ATTR_onclick, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_ondblclick, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmousedown, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseup, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseover, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmousemove, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseout, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeypress, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeydown, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeyup, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_id, atID, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_class, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_style, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_title, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_name, atCDATA, IMPLIED, NODEFAULT, NOLIST);

  // nested elements
  FNestedElements.AddNew(THtmP, wciOne);
  FNestedElements.AddNew(THtmH1, wciOne);
  FNestedElements.AddNew(THtmH2, wciOne);
  FNestedElements.AddNew(THtmH3, wciOne);
  FNestedElements.AddNew(THtmH4, wciOne);
  FNestedElements.AddNew(THtmH5, wciOne);
  FNestedElements.AddNew(THtmH6, wciOne);
  FNestedElements.AddNew(THtmDiv, wciOne);
  FNestedElements.AddNew(THtmUl, wciOne);
  FNestedElements.AddNew(THtmOl, wciOne);
  FNestedElements.AddNew(THtmDl, wciOne);
  FNestedElements.AddNew(THtmMenu, wciOne);
  FNestedElements.AddNew(THtmDir, wciOne);
  FNestedElements.AddNew(THtmPre, wciOne);
  FNestedElements.AddNew(THtmHr, wciOne);
  FNestedElements.AddNew(THtmBlockquote, wciOne);
  FNestedElements.AddNew(THtmAddress, wciOne);
  FNestedElements.AddNew(THtmCenter, wciOne);
  FNestedElements.AddNew(THtmNoframes, wciOne);
  FNestedElements.AddNew(THtmIsindex, wciOne);
  FNestedElements.AddNew(THtmFieldset, wciOne);
  FNestedElements.AddNew(THtmTable, wciOneOrMore);
  FNestedElements.AddNew(THtmForm, wciOneOrMore);
  FNestedElements.AddNew(THtmNoscript, wciOneOrMore);
  FNestedElements.AddNew(THtmIns, wciOne);
  FNestedElements.AddNew(THtmDel, wciOne);
  FNestedElements.AddNew(THtmScript, wciOneOrMore);
  FNestedElements.AddNew(THtmArea, wciOneOrMore);

  if wcServerExtensions in xmlENV.xmlCapabilities
  then FNestedElements.AddNew(THtmServerSide, wciAny);
end;

constructor THtmarea.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  // attributes
  FAttributes.AddAttribute(ATTR_id, atID, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_class, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_style, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_title, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_lang, atNMTOKEN, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_xml_lang, atNMTOKEN, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_dir, atList, IMPLIED, NODEFAULT, 'ltr|rtl');
  FAttributes.AddAttribute(ATTR_onclick, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_ondblclick, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmousedown, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseup, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseover, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmousemove, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseout, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeypress, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeydown, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeyup, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_accesskey, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_tabindex, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onfocus, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onblur, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_shape, atList, IMPLIED, 'rect', 'rect|circle|poly|default');
  FAttributes.AddAttribute(ATTR_coords, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_href, atHREF, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_nohref, atList, IMPLIED, NODEFAULT, 'nohref');
  FAttributes.AddAttribute(ATTR_alt, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_target, atNMTOKEN, IMPLIED, NODEFAULT, NOLIST);

  // EMPTY
end;

constructor THtmform.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  // attributes
  FAttributes.AddAttribute(ATTR_id, atID, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_class, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_style, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_title, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_lang, atNMTOKEN, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_xml_lang, atNMTOKEN, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_dir, atList, IMPLIED, NODEFAULT, 'ltr|rtl');
  FAttributes.AddAttribute(ATTR_onclick, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_ondblclick, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmousedown, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseup, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseover, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmousemove, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseout, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeypress, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeydown, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeyup, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_action, atHREF, REQUIRED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_method, atList, IMPLIED, 'get', 'get|post');
  FAttributes.AddAttribute(ATTR_name, atNMTOKEN, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_enctype, atCDATA, IMPLIED, 'application/x-www-form-urlencoded', NOLIST);
  FAttributes.AddAttribute(ATTR_onsubmit, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onreset, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_accept, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_accept_charset, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_target, atNMTOKEN, IMPLIED, NODEFAULT, NOLIST);

  // nested elements
  FNestedElements.AddNew(THtmPCDATA, wciAny);
  FNestedElements.AddNew(THtmP, wciAny);
  FNestedElements.AddNew(THtmH1, wciAny);
  FNestedElements.AddNew(THtmH2, wciAny);
  FNestedElements.AddNew(THtmH3, wciAny);
  FNestedElements.AddNew(THtmH4, wciAny);
  FNestedElements.AddNew(THtmH5, wciAny);
  FNestedElements.AddNew(THtmH6, wciAny);
  FNestedElements.AddNew(THtmDiv, wciAny);
  FNestedElements.AddNew(THtmUl, wciAny);
  FNestedElements.AddNew(THtmOl, wciAny);
  FNestedElements.AddNew(THtmDl, wciAny);
  FNestedElements.AddNew(THtmMenu, wciAny);
  FNestedElements.AddNew(THtmDir, wciAny);
  FNestedElements.AddNew(THtmPre, wciAny);
  FNestedElements.AddNew(THtmHr, wciAny);
  FNestedElements.AddNew(THtmBlockquote, wciAny);
  FNestedElements.AddNew(THtmAddress, wciAny);
  FNestedElements.AddNew(THtmCenter, wciAny);
  FNestedElements.AddNew(THtmNoframes, wciAny);
  FNestedElements.AddNew(THtmIsindex, wciAny);
  FNestedElements.AddNew(THtmFieldset, wciAny);
  FNestedElements.AddNew(THtmTable, wciAny);
  FNestedElements.AddNew(THtmA, wciAny);
  FNestedElements.AddNew(THtmBr, wciAny);
  FNestedElements.AddNew(THtmSpan, wciAny);
  FNestedElements.AddNew(THtmBdo, wciAny);
  FNestedElements.AddNew(THtmObject, wciAny);
  FNestedElements.AddNew(THtmApplet, wciAny);
  FNestedElements.AddNew(THtmImg, wciAny);
  FNestedElements.AddNew(THtmMap, wciAny);
  FNestedElements.AddNew(THtmIframe, wciAny);
  FNestedElements.AddNew(THtmTt, wciAny);
  FNestedElements.AddNew(THtmI, wciAny);
  FNestedElements.AddNew(THtmB, wciAny);
  FNestedElements.AddNew(THtmU, wciAny);
  FNestedElements.AddNew(THtmS, wciAny);
  FNestedElements.AddNew(THtmStrike, wciAny);
  FNestedElements.AddNew(THtmBig, wciAny);
  FNestedElements.AddNew(THtmSmall, wciAny);
  FNestedElements.AddNew(THtmFont, wciAny);
  FNestedElements.AddNew(THtmBasefont, wciAny);
  FNestedElements.AddNew(THtmEm, wciAny);
  FNestedElements.AddNew(THtmStrong, wciAny);
  FNestedElements.AddNew(THtmDfn, wciAny);
  FNestedElements.AddNew(THtmCode, wciAny);
  FNestedElements.AddNew(THtmQ, wciAny);
  FNestedElements.AddNew(THtmSamp, wciAny);
  FNestedElements.AddNew(THtmKbd, wciAny);
  FNestedElements.AddNew(THtmVar, wciAny);
  FNestedElements.AddNew(THtmCite, wciAny);
  FNestedElements.AddNew(THtmAbbr, wciAny);
  FNestedElements.AddNew(THtmAcronym, wciAny);
  FNestedElements.AddNew(THtmSub, wciAny);
  FNestedElements.AddNew(THtmSup, wciAny);
  FNestedElements.AddNew(THtmInput, wciAny);
  FNestedElements.AddNew(THtmSelect, wciAny);
  FNestedElements.AddNew(THtmTextarea, wciAny);
  FNestedElements.AddNew(THtmLabel, wciAny);
  FNestedElements.AddNew(THtmButton, wciAny);
  FNestedElements.AddNew(THtmNoscript, wciAny);
  FNestedElements.AddNew(THtmIns, wciAny);
  FNestedElements.AddNew(THtmDel, wciAny);
  FNestedElements.AddNew(THtmScript, wciAny);

  if wcServerExtensions in xmlENV.xmlCapabilities
  then FNestedElements.AddNew(THtmServerSide, wciAny);
end;

constructor THtmlabel.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  // attributes
  FAttributes.AddAttribute(ATTR_id, atID, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_class, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_style, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_title, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_lang, atNMTOKEN, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_xml_lang, atNMTOKEN, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_dir, atList, IMPLIED, NODEFAULT, 'ltr|rtl');
  FAttributes.AddAttribute(ATTR_onclick, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_ondblclick, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmousedown, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseup, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseover, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmousemove, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseout, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeypress, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeydown, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeyup, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_for, atIDREF, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_accesskey, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onfocus, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onblur, atCDATA, IMPLIED, NODEFAULT, NOLIST);

  // nested elements
  FNestedElements.AddNew(THtmPCDATA, wciAny);
  FNestedElements.AddNew(THtmA, wciAny);
  FNestedElements.AddNew(THtmBr, wciAny);
  FNestedElements.AddNew(THtmSpan, wciAny);
  FNestedElements.AddNew(THtmBdo, wciAny);
  FNestedElements.AddNew(THtmObject, wciAny);
  FNestedElements.AddNew(THtmApplet, wciAny);
  FNestedElements.AddNew(THtmImg, wciAny);
  FNestedElements.AddNew(THtmMap, wciAny);
  FNestedElements.AddNew(THtmIframe, wciAny);
  FNestedElements.AddNew(THtmTt, wciAny);
  FNestedElements.AddNew(THtmI, wciAny);
  FNestedElements.AddNew(THtmB, wciAny);
  FNestedElements.AddNew(THtmU, wciAny);
  FNestedElements.AddNew(THtmS, wciAny);
  FNestedElements.AddNew(THtmStrike, wciAny);
  FNestedElements.AddNew(THtmBig, wciAny);
  FNestedElements.AddNew(THtmSmall, wciAny);
  FNestedElements.AddNew(THtmFont, wciAny);
  FNestedElements.AddNew(THtmBasefont, wciAny);
  FNestedElements.AddNew(THtmEm, wciAny);
  FNestedElements.AddNew(THtmStrong, wciAny);
  FNestedElements.AddNew(THtmDfn, wciAny);
  FNestedElements.AddNew(THtmCode, wciAny);
  FNestedElements.AddNew(THtmQ, wciAny);
  FNestedElements.AddNew(THtmSamp, wciAny);
  FNestedElements.AddNew(THtmKbd, wciAny);
  FNestedElements.AddNew(THtmVar, wciAny);
  FNestedElements.AddNew(THtmCite, wciAny);
  FNestedElements.AddNew(THtmAbbr, wciAny);
  FNestedElements.AddNew(THtmAcronym, wciAny);
  FNestedElements.AddNew(THtmSub, wciAny);
  FNestedElements.AddNew(THtmSup, wciAny);
  FNestedElements.AddNew(THtmInput, wciAny);
  FNestedElements.AddNew(THtmSelect, wciAny);
  FNestedElements.AddNew(THtmTextarea, wciAny);
  FNestedElements.AddNew(THtmLabel, wciAny);
  FNestedElements.AddNew(THtmButton, wciAny);
  FNestedElements.AddNew(THtmIns, wciAny);
  FNestedElements.AddNew(THtmDel, wciAny);
  FNestedElements.AddNew(THtmScript, wciAny);

  if wcServerExtensions in xmlENV.xmlCapabilities
  then FNestedElements.AddNew(THtmServerSide, wciAny);
end;

constructor THtminput.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  // attributes
  FAttributes.AddAttribute(ATTR_id, atID, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_class, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_style, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_title, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_lang, atNMTOKEN, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_xml_lang, atNMTOKEN, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_dir, atList, IMPLIED, NODEFAULT, 'ltr|rtl');
  FAttributes.AddAttribute(ATTR_onclick, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_ondblclick, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmousedown, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseup, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseover, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmousemove, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseout, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeypress, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeydown, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeyup, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_accesskey, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_tabindex, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onfocus, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onblur, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_type, atList, IMPLIED, 'text', 'text|password|checkbox|radio|submit|reset|file|hidden|image|button');
  FAttributes.AddAttribute(ATTR_name, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_value, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_checked, atList, IMPLIED, NODEFAULT, 'checked');
  FAttributes.AddAttribute(ATTR_disabled, atList, IMPLIED, NODEFAULT, 'disabled');
  FAttributes.AddAttribute(ATTR_readonly, atList, IMPLIED, NODEFAULT, 'readonly');
  FAttributes.AddAttribute(ATTR_size, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_maxlength, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_src, atHREF, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_alt, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_usemap, atHREF, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onselect, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onchange, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_accept, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_align, atList, IMPLIED, NODEFAULT, 'top|middle|bottom|left|right');

  FAttributes.AddAttribute(ATTR_height, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_width, atCDATA, IMPLIED, NODEFAULT, NOLIST);

  // EMPTY
end;

function THtmInput.CreateText(ALevel: Integer; AOptions: TFormatTextSet): WideString;
var
  i, n: Integer;
  NestedElementClass: TPersistentClass;
  NestedElement: TxmlElement;
  aname: String;
  t: String;
begin
  // left align
  t:= ValidateLevel(ALevel);

  // element and attributes
  Result:= t + '<' + GetElementName + #32;
  for i:= 0 to FAttributes.Count - 1 do begin
    if FAttributes.Items[i].IsValuable then begin
      aname:= FAttributes.Items[i].Name;
      if CompareText(aname, ATTR_checked) = 0 then begin
        // remove invalid checked="NON-checked"
        if CompareText(FAttributes.Items[i].Value, ATTR_checked) = 0
        then Result:= Result + ATTR_checked + '="' + ATTR_checked + '"'#32;
      end else begin
        Result:= Result + aname + '=' +
          QuotesValue(FAttributes.Items[i].Value) + #32;
      end;
    end;
  end;
  // check is nested elements exists
  if IsEmpty then begin
    // single element, replace last space to "/>".
    Result[Length(Result)]:= '/';
    Result:= Result + '>';
  end else begin
    // have nested elements, replace last space to ">".
    Result[Length(Result)]:= '>';
    Result:= Result + LINESEPARATOR;
    // insert embedded elements
    for n:= 0 to NestedElements1Count - 1 do begin
      NestedElement:= GetNested1ElementByOrder(n, NestedElementClass);
      if Assigned(NestedElement) then begin
        Result:= Result + NestedElement.CreateText(ALevel + 1, AOptions) + LINESEPARATOR;
      end;
    end;
    // close element
    Result:= Result + t + '</' + GetElementName + '>';
  end;
end;

constructor THtmselect.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  // attributes
  FAttributes.AddAttribute(ATTR_id, atID, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_class, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_style, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_title, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_lang, atNMTOKEN, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_xml_lang, atNMTOKEN, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_dir, atList, IMPLIED, NODEFAULT, 'ltr|rtl');
  FAttributes.AddAttribute(ATTR_onclick, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_ondblclick, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmousedown, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseup, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseover, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmousemove, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseout, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeypress, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeydown, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeyup, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_name, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_size, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_multiple, atList, IMPLIED, NODEFAULT, 'multiple');
  FAttributes.AddAttribute(ATTR_disabled, atList, IMPLIED, NODEFAULT, 'disabled');
  FAttributes.AddAttribute(ATTR_tabindex, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onfocus, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onblur, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onchange, atCDATA, IMPLIED, NODEFAULT, NOLIST);

  // nested elements
  FNestedElements.AddNew(THtmOptgroup, wciOneOrMore);
  FNestedElements.AddNew(THtmOption, wciOneOrMore);

  if wcServerExtensions in xmlENV.xmlCapabilities
  then FNestedElements.AddNew(THtmServerSide, wciAny);
end;

function THtmselect.CreateText(ALevel: Integer; AOptions: TFormatTextSet): WideString;
var
  i, n: Integer;
  NestedElementClass: TPersistentClass;
  NestedElement: TxmlElement;
  aname: String;
  t: String;
begin
  // left align
  t:= ValidateLevel(ALevel);

  // element and attributes
  Result:= t + '<' + GetElementName + #32;
  for i:= 0 to FAttributes.Count - 1 do begin
    if FAttributes.Items[i].IsValuable then begin
      aname:= FAttributes.Items[i].Name;
      if CompareText(aname, ATTR_selected) = 0 then begin
        // remove invalid checked="NON-selected"
        if CompareText(FAttributes.Items[i].Value, ATTR_selected) = 0
        then Result:= Result + ATTR_selected + '="' + ATTR_selected + '"'#32;
      end else begin
        Result:= Result + aname + '=' +
          QuotesValue(FAttributes.Items[i].Value) + #32;
      end;
    end;
  end;
  // check is nested elements exists
  if IsEmpty then begin
    // single element, replace last space to "/>".
    Result[Length(Result)]:= '/';
    Result:= Result + '>';
  end else begin
    // have nested elements, replace last space to ">".
    Result[Length(Result)]:= '>';
    Result:= Result + LINESEPARATOR;
    // insert embedded elements
    for n:= 0 to NestedElements1Count - 1 do begin
      NestedElement:= GetNested1ElementByOrder(n, NestedElementClass);
      if Assigned(NestedElement) then begin
        Result:= Result + NestedElement.CreateText(ALevel + 1, AOptions) + LINESEPARATOR;
      end;
    end;
    // close element
    Result:= Result + t + '</' + GetElementName + '>';
  end;
end;

constructor THtmoptgroup.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  // attributes
  FAttributes.AddAttribute(ATTR_id, atID, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_class, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_style, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_title, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_lang, atNMTOKEN, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_xml_lang, atNMTOKEN, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_dir, atList, IMPLIED, NODEFAULT, 'ltr|rtl');
  FAttributes.AddAttribute(ATTR_onclick, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_ondblclick, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmousedown, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseup, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseover, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmousemove, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseout, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeypress, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeydown, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeyup, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_disabled, atList, IMPLIED, NODEFAULT, 'disabled');
  FAttributes.AddAttribute(ATTR_label, atCDATA, REQUIRED, NODEFAULT, NOLIST);

  // nested elements
  FNestedElements.AddNew(THtmOption, wciOneOrMore);

  if wcServerExtensions in xmlENV.xmlCapabilities
  then FNestedElements.AddNew(THtmServerSide, wciAny);
end;

constructor THtmoption.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  // attributes
  FAttributes.AddAttribute(ATTR_id, atID, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_class, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_style, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_title, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_lang, atNMTOKEN, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_xml_lang, atNMTOKEN, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_dir, atList, IMPLIED, NODEFAULT, 'ltr|rtl');
  FAttributes.AddAttribute(ATTR_onclick, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_ondblclick, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmousedown, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseup, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseover, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmousemove, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseout, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeypress, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeydown, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeyup, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_selected, atList, IMPLIED, NODEFAULT, 'selected');
  FAttributes.AddAttribute(ATTR_disabled, atList, IMPLIED, NODEFAULT, 'disabled');
  FAttributes.AddAttribute(ATTR_label, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_value, atCDATA, IMPLIED, NODEFAULT, NOLIST);

  // nested elements
  FNestedElements.AddNew(THtmPCDATA, wciOneOrNone);

  if wcServerExtensions in xmlENV.xmlCapabilities
  then FNestedElements.AddNew(THtmServerSide, wciAny);
end;

constructor THtmtextarea.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  // attributes
  FAttributes.AddAttribute(ATTR_id, atID, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_class, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_style, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_title, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_lang, atNMTOKEN, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_xml_lang, atNMTOKEN, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_dir, atList, IMPLIED, NODEFAULT, 'ltr|rtl');
  FAttributes.AddAttribute(ATTR_onclick, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_ondblclick, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmousedown, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseup, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseover, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmousemove, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseout, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeypress, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeydown, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeyup, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_accesskey, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_tabindex, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onfocus, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onblur, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_name, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_rows, atCDATA, REQUIRED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_cols, atCDATA, REQUIRED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_disabled, atList, IMPLIED, NODEFAULT, 'disabled');
  FAttributes.AddAttribute(ATTR_readonly, atList, IMPLIED, NODEFAULT, 'readonly');
  FAttributes.AddAttribute(ATTR_onselect, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onchange, atCDATA, IMPLIED, NODEFAULT, NOLIST);

  // nested elements
  FNestedElements.AddNew(THtmPCDATA, wciOneOrNone);

  if wcServerExtensions in xmlENV.xmlCapabilities
  then FNestedElements.AddNew(THtmServerSide, wciAny);
end;

constructor THtmfieldset.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  // attributes
  FAttributes.AddAttribute(ATTR_id, atID, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_class, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_style, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_title, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_lang, atNMTOKEN, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_xml_lang, atNMTOKEN, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_dir, atList, IMPLIED, NODEFAULT, 'ltr|rtl');
  FAttributes.AddAttribute(ATTR_onclick, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_ondblclick, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmousedown, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseup, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseover, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmousemove, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseout, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeypress, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeydown, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeyup, atCDATA, IMPLIED, NODEFAULT, NOLIST);

  // nested elements
  FNestedElements.AddNew(THtmPCDATA, wciAny);
  FNestedElements.AddNew(THtmLegend, wciAny);
  FNestedElements.AddNew(THtmP, wciAny);
  FNestedElements.AddNew(THtmH1, wciAny);
  FNestedElements.AddNew(THtmH2, wciAny);
  FNestedElements.AddNew(THtmH3, wciAny);
  FNestedElements.AddNew(THtmH4, wciAny);
  FNestedElements.AddNew(THtmH5, wciAny);
  FNestedElements.AddNew(THtmH6, wciAny);
  FNestedElements.AddNew(THtmDiv, wciAny);
  FNestedElements.AddNew(THtmUl, wciAny);
  FNestedElements.AddNew(THtmOl, wciAny);
  FNestedElements.AddNew(THtmDl, wciAny);
  FNestedElements.AddNew(THtmMenu, wciAny);
  FNestedElements.AddNew(THtmDir, wciAny);
  FNestedElements.AddNew(THtmPre, wciAny);
  FNestedElements.AddNew(THtmHr, wciAny);
  FNestedElements.AddNew(THtmBlockquote, wciAny);
  FNestedElements.AddNew(THtmAddress, wciAny);
  FNestedElements.AddNew(THtmCenter, wciAny);
  FNestedElements.AddNew(THtmNoframes, wciAny);
  FNestedElements.AddNew(THtmIsindex, wciAny);
  FNestedElements.AddNew(THtmFieldset, wciAny);
  FNestedElements.AddNew(THtmTable, wciAny);
  FNestedElements.AddNew(THtmForm, wciAny);
  FNestedElements.AddNew(THtmA, wciAny);
  FNestedElements.AddNew(THtmBr, wciAny);
  FNestedElements.AddNew(THtmSpan, wciAny);
  FNestedElements.AddNew(THtmBdo, wciAny);
  FNestedElements.AddNew(THtmObject, wciAny);
  FNestedElements.AddNew(THtmApplet, wciAny);
  FNestedElements.AddNew(THtmImg, wciAny);
  FNestedElements.AddNew(THtmMap, wciAny);
  FNestedElements.AddNew(THtmIframe, wciAny);
  FNestedElements.AddNew(THtmTt, wciAny);
  FNestedElements.AddNew(THtmI, wciAny);
  FNestedElements.AddNew(THtmB, wciAny);
  FNestedElements.AddNew(THtmU, wciAny);
  FNestedElements.AddNew(THtmS, wciAny);
  FNestedElements.AddNew(THtmStrike, wciAny);
  FNestedElements.AddNew(THtmBig, wciAny);
  FNestedElements.AddNew(THtmSmall, wciAny);
  FNestedElements.AddNew(THtmFont, wciAny);
  FNestedElements.AddNew(THtmBasefont, wciAny);
  FNestedElements.AddNew(THtmEm, wciAny);
  FNestedElements.AddNew(THtmStrong, wciAny);
  FNestedElements.AddNew(THtmDfn, wciAny);
  FNestedElements.AddNew(THtmCode, wciAny);
  FNestedElements.AddNew(THtmQ, wciAny);
  FNestedElements.AddNew(THtmSamp, wciAny);
  FNestedElements.AddNew(THtmKbd, wciAny);
  FNestedElements.AddNew(THtmVar, wciAny);
  FNestedElements.AddNew(THtmCite, wciAny);
  FNestedElements.AddNew(THtmAbbr, wciAny);
  FNestedElements.AddNew(THtmAcronym, wciAny);
  FNestedElements.AddNew(THtmSub, wciAny);
  FNestedElements.AddNew(THtmSup, wciAny);
  FNestedElements.AddNew(THtmInput, wciAny);
  FNestedElements.AddNew(THtmSelect, wciAny);
  FNestedElements.AddNew(THtmTextarea, wciAny);
  FNestedElements.AddNew(THtmLabel, wciAny);
  FNestedElements.AddNew(THtmButton, wciAny);
  FNestedElements.AddNew(THtmNoscript, wciAny);
  FNestedElements.AddNew(THtmIns, wciAny);
  FNestedElements.AddNew(THtmDel, wciAny);
  FNestedElements.AddNew(THtmScript, wciAny);

  if wcServerExtensions in xmlENV.xmlCapabilities
  then FNestedElements.AddNew(THtmServerSide, wciAny);
end;

constructor THtmlegend.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  // attributes
  FAttributes.AddAttribute(ATTR_id, atID, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_class, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_style, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_title, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_lang, atNMTOKEN, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_xml_lang, atNMTOKEN, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_dir, atList, IMPLIED, NODEFAULT, 'ltr|rtl');
  FAttributes.AddAttribute(ATTR_onclick, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_ondblclick, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmousedown, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseup, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseover, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmousemove, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseout, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeypress, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeydown, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeyup, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_accesskey, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_align, atList, IMPLIED, NODEFAULT, 'top|bottom|left|right');

  // nested elements
  FNestedElements.AddNew(THtmPCDATA, wciAny);
  FNestedElements.AddNew(THtmA, wciAny);
  FNestedElements.AddNew(THtmBr, wciAny);
  FNestedElements.AddNew(THtmSpan, wciAny);
  FNestedElements.AddNew(THtmBdo, wciAny);
  FNestedElements.AddNew(THtmObject, wciAny);
  FNestedElements.AddNew(THtmApplet, wciAny);
  FNestedElements.AddNew(THtmImg, wciAny);
  FNestedElements.AddNew(THtmMap, wciAny);
  FNestedElements.AddNew(THtmIframe, wciAny);
  FNestedElements.AddNew(THtmTt, wciAny);
  FNestedElements.AddNew(THtmI, wciAny);
  FNestedElements.AddNew(THtmB, wciAny);
  FNestedElements.AddNew(THtmU, wciAny);
  FNestedElements.AddNew(THtmS, wciAny);
  FNestedElements.AddNew(THtmStrike, wciAny);
  FNestedElements.AddNew(THtmBig, wciAny);
  FNestedElements.AddNew(THtmSmall, wciAny);
  FNestedElements.AddNew(THtmFont, wciAny);
  FNestedElements.AddNew(THtmBasefont, wciAny);
  FNestedElements.AddNew(THtmEm, wciAny);
  FNestedElements.AddNew(THtmStrong, wciAny);
  FNestedElements.AddNew(THtmDfn, wciAny);
  FNestedElements.AddNew(THtmCode, wciAny);
  FNestedElements.AddNew(THtmQ, wciAny);
  FNestedElements.AddNew(THtmSamp, wciAny);
  FNestedElements.AddNew(THtmKbd, wciAny);
  FNestedElements.AddNew(THtmVar, wciAny);
  FNestedElements.AddNew(THtmCite, wciAny);
  FNestedElements.AddNew(THtmAbbr, wciAny);
  FNestedElements.AddNew(THtmAcronym, wciAny);
  FNestedElements.AddNew(THtmSub, wciAny);
  FNestedElements.AddNew(THtmSup, wciAny);
  FNestedElements.AddNew(THtmInput, wciAny);
  FNestedElements.AddNew(THtmSelect, wciAny);
  FNestedElements.AddNew(THtmTextarea, wciAny);
  FNestedElements.AddNew(THtmLabel, wciAny);
  FNestedElements.AddNew(THtmButton, wciAny);
  FNestedElements.AddNew(THtmIns, wciAny);
  FNestedElements.AddNew(THtmDel, wciAny);
  FNestedElements.AddNew(THtmScript, wciAny);

  if wcServerExtensions in xmlENV.xmlCapabilities
  then FNestedElements.AddNew(THtmServerSide, wciAny);
end;

constructor THtmbutton.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  // attributes
  FAttributes.AddAttribute(ATTR_id, atID, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_class, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_style, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_title, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_lang, atNMTOKEN, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_xml_lang, atNMTOKEN, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_dir, atList, IMPLIED, NODEFAULT, 'ltr|rtl');
  FAttributes.AddAttribute(ATTR_onclick, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_ondblclick, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmousedown, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseup, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseover, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmousemove, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseout, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeypress, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeydown, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeyup, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_accesskey, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_tabindex, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onfocus, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onblur, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_name, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_value, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_type, atList, IMPLIED, 'submit', 'button|submit|reset');
  FAttributes.AddAttribute(ATTR_disabled, atList, IMPLIED, NODEFAULT, 'disabled');

  // nested elements
  FNestedElements.AddNew(THtmPCDATA, wciAny);
  FNestedElements.AddNew(THtmP, wciAny);
  FNestedElements.AddNew(THtmH1, wciAny);
  FNestedElements.AddNew(THtmH2, wciAny);
  FNestedElements.AddNew(THtmH3, wciAny);
  FNestedElements.AddNew(THtmH4, wciAny);
  FNestedElements.AddNew(THtmH5, wciAny);
  FNestedElements.AddNew(THtmH6, wciAny);
  FNestedElements.AddNew(THtmDiv, wciAny);
  FNestedElements.AddNew(THtmUl, wciAny);
  FNestedElements.AddNew(THtmOl, wciAny);
  FNestedElements.AddNew(THtmDl, wciAny);
  FNestedElements.AddNew(THtmMenu, wciAny);
  FNestedElements.AddNew(THtmDir, wciAny);
  FNestedElements.AddNew(THtmPre, wciAny);
  FNestedElements.AddNew(THtmHr, wciAny);
  FNestedElements.AddNew(THtmBlockquote, wciAny);
  FNestedElements.AddNew(THtmAddress, wciAny);
  FNestedElements.AddNew(THtmCenter, wciAny);
  FNestedElements.AddNew(THtmNoframes, wciAny);
  FNestedElements.AddNew(THtmTable, wciAny);
  FNestedElements.AddNew(THtmBr, wciAny);
  FNestedElements.AddNew(THtmSpan, wciAny);
  FNestedElements.AddNew(THtmBdo, wciAny);
  FNestedElements.AddNew(THtmObject, wciAny);
  FNestedElements.AddNew(THtmApplet, wciAny);
  FNestedElements.AddNew(THtmImg, wciAny);
  FNestedElements.AddNew(THtmMap, wciAny);
  FNestedElements.AddNew(THtmTt, wciAny);
  FNestedElements.AddNew(THtmI, wciAny);
  FNestedElements.AddNew(THtmB, wciAny);
  FNestedElements.AddNew(THtmU, wciAny);
  FNestedElements.AddNew(THtmS, wciAny);
  FNestedElements.AddNew(THtmStrike, wciAny);
  FNestedElements.AddNew(THtmBig, wciAny);
  FNestedElements.AddNew(THtmSmall, wciAny);
  FNestedElements.AddNew(THtmFont, wciAny);
  FNestedElements.AddNew(THtmBasefont, wciAny);
  FNestedElements.AddNew(THtmEm, wciAny);
  FNestedElements.AddNew(THtmStrong, wciAny);
  FNestedElements.AddNew(THtmDfn, wciAny);
  FNestedElements.AddNew(THtmCode, wciAny);
  FNestedElements.AddNew(THtmQ, wciAny);
  FNestedElements.AddNew(THtmSamp, wciAny);
  FNestedElements.AddNew(THtmKbd, wciAny);
  FNestedElements.AddNew(THtmVar, wciAny);
  FNestedElements.AddNew(THtmCite, wciAny);
  FNestedElements.AddNew(THtmAbbr, wciAny);
  FNestedElements.AddNew(THtmAcronym, wciAny);
  FNestedElements.AddNew(THtmSub, wciAny);
  FNestedElements.AddNew(THtmSup, wciAny);
  FNestedElements.AddNew(THtmNoscript, wciAny);
  FNestedElements.AddNew(THtmIns, wciAny);
  FNestedElements.AddNew(THtmDel, wciAny);
  FNestedElements.AddNew(THtmScript, wciAny);

  if wcServerExtensions in xmlENV.xmlCapabilities
  then FNestedElements.AddNew(THtmServerSide, wciAny);
end;

constructor THtmisindex.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  // attributes
  FAttributes.AddAttribute(ATTR_id, atID, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_class, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_style, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_title, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_lang, atNMTOKEN, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_xml_lang, atNMTOKEN, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_dir, atList, IMPLIED, NODEFAULT, 'ltr|rtl');
  FAttributes.AddAttribute(ATTR_prompt, atCDATA, IMPLIED, NODEFAULT, NOLIST);

  // EMPTY 
end;

constructor THtmtable.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  // attributes
  FAttributes.AddAttribute(ATTR_id, atID, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_class, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_style, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_title, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_lang, atNMTOKEN, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_xml_lang, atNMTOKEN, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_dir, atList, IMPLIED, NODEFAULT, 'ltr|rtl');
  FAttributes.AddAttribute(ATTR_onclick, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_ondblclick, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmousedown, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseup, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseover, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmousemove, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseout, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeypress, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeydown, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeyup, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_summary, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_width, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_border, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_frame, atList, IMPLIED, NODEFAULT, 'void|above|below|hsides|lhs|rhs|vsides|box|border');
  FAttributes.AddAttribute(ATTR_rules, atList, IMPLIED, NODEFAULT, 'none|groups|rows|cols|all');
  FAttributes.AddAttribute(ATTR_cellspacing, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_cellpadding, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_align, atList, IMPLIED, NODEFAULT, 'left|center|right');
  FAttributes.AddAttribute(ATTR_bgcolor, atCDATA, IMPLIED, NODEFAULT, NOLIST);

  // nested elements
  FNestedElements.AddNew(THtmCaption, wciOneOrNone);
  FNestedElements.AddNew(THtmThead, wciOneOrNone);
  FNestedElements.AddNew(THtmTfoot, wciOneOrNone);
  FNestedElements.AddNew(THtmCol, wciAny);
  FNestedElements.AddNew(THtmColgroup, wciAny);
  FNestedElements.AddNew(THtmTbody, wciOneOrMore);
  FNestedElements.AddNew(THtmTr, wciOneOrMore);

  if wcServerExtensions in xmlENV.xmlCapabilities
  then FNestedElements.AddNew(THtmServerSide, wciAny);
end;

constructor THtmcaption.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  // attributes
  FAttributes.AddAttribute(ATTR_id, atID, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_class, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_style, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_title, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_lang, atNMTOKEN, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_xml_lang, atNMTOKEN, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_dir, atList, IMPLIED, NODEFAULT, 'ltr|rtl');
  FAttributes.AddAttribute(ATTR_onclick, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_ondblclick, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmousedown, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseup, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseover, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmousemove, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseout, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeypress, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeydown, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeyup, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_align, atList, IMPLIED, NODEFAULT, 'top|bottom|left|right');

  // nested elements
  FNestedElements.AddNew(THtmPCDATA, wciAny);
  FNestedElements.AddNew(THtmA, wciAny);
  FNestedElements.AddNew(THtmBr, wciAny);
  FNestedElements.AddNew(THtmSpan, wciAny);
  FNestedElements.AddNew(THtmBdo, wciAny);
  FNestedElements.AddNew(THtmObject, wciAny);
  FNestedElements.AddNew(THtmApplet, wciAny);
  FNestedElements.AddNew(THtmImg, wciAny);
  FNestedElements.AddNew(THtmMap, wciAny);
  FNestedElements.AddNew(THtmIframe, wciAny);
  FNestedElements.AddNew(THtmTt, wciAny);
  FNestedElements.AddNew(THtmI, wciAny);
  FNestedElements.AddNew(THtmB, wciAny);
  FNestedElements.AddNew(THtmU, wciAny);
  FNestedElements.AddNew(THtmS, wciAny);
  FNestedElements.AddNew(THtmStrike, wciAny);
  FNestedElements.AddNew(THtmBig, wciAny);
  FNestedElements.AddNew(THtmSmall, wciAny);
  FNestedElements.AddNew(THtmFont, wciAny);
  FNestedElements.AddNew(THtmBasefont, wciAny);
  FNestedElements.AddNew(THtmEm, wciAny);
  FNestedElements.AddNew(THtmStrong, wciAny);
  FNestedElements.AddNew(THtmDfn, wciAny);
  FNestedElements.AddNew(THtmCode, wciAny);
  FNestedElements.AddNew(THtmQ, wciAny);
  FNestedElements.AddNew(THtmSamp, wciAny);
  FNestedElements.AddNew(THtmKbd, wciAny);
  FNestedElements.AddNew(THtmVar, wciAny);
  FNestedElements.AddNew(THtmCite, wciAny);
  FNestedElements.AddNew(THtmAbbr, wciAny);
  FNestedElements.AddNew(THtmAcronym, wciAny);
  FNestedElements.AddNew(THtmSub, wciAny);
  FNestedElements.AddNew(THtmSup, wciAny);
  FNestedElements.AddNew(THtmInput, wciAny);
  FNestedElements.AddNew(THtmSelect, wciAny);
  FNestedElements.AddNew(THtmTextarea, wciAny);
  FNestedElements.AddNew(THtmLabel, wciAny);
  FNestedElements.AddNew(THtmButton, wciAny);
  FNestedElements.AddNew(THtmIns, wciAny);
  FNestedElements.AddNew(THtmDel, wciAny);
  FNestedElements.AddNew(THtmScript, wciAny);

  if wcServerExtensions in xmlENV.xmlCapabilities
  then FNestedElements.AddNew(THtmServerSide, wciAny);
end;

constructor THtmthead.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  // attributes
  FAttributes.AddAttribute(ATTR_id, atID, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_class, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_style, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_title, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_lang, atNMTOKEN, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_xml_lang, atNMTOKEN, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_dir, atList, IMPLIED, NODEFAULT, 'ltr|rtl');
  FAttributes.AddAttribute(ATTR_onclick, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_ondblclick, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmousedown, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseup, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseover, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmousemove, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseout, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeypress, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeydown, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeyup, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_align, atList, IMPLIED, NODEFAULT, 'left|center|right|justify|char');
  FAttributes.AddAttribute(ATTR_char, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_charoff, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_valign, atList, IMPLIED, NODEFAULT, 'top|middle|bottom|baseline');

  // nested elements
  FNestedElements.AddNew(THtmTr, wciOneOrMore);

  if wcServerExtensions in xmlENV.xmlCapabilities
  then FNestedElements.AddNew(THtmServerSide, wciAny);
end;

constructor THtmtfoot.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  // attributes
  FAttributes.AddAttribute(ATTR_id, atID, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_class, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_style, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_title, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_lang, atNMTOKEN, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_xml_lang, atNMTOKEN, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_dir, atList, IMPLIED, NODEFAULT, 'ltr|rtl');
  FAttributes.AddAttribute(ATTR_onclick, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_ondblclick, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmousedown, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseup, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseover, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmousemove, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseout, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeypress, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeydown, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeyup, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_align, atList, IMPLIED, NODEFAULT, 'left|center|right|justify|char');
  FAttributes.AddAttribute(ATTR_char, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_charoff, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_valign, atList, IMPLIED, NODEFAULT, 'top|middle|bottom|baseline');

  // nested elements
  FNestedElements.AddNew(THtmTr, wciOneOrMore);

  if wcServerExtensions in xmlENV.xmlCapabilities
  then FNestedElements.AddNew(THtmServerSide, wciAny);
end;

constructor THtmtbody.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  // attributes
  FAttributes.AddAttribute(ATTR_id, atID, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_class, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_style, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_title, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_lang, atNMTOKEN, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_xml_lang, atNMTOKEN, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_dir, atList, IMPLIED, NODEFAULT, 'ltr|rtl');
  FAttributes.AddAttribute(ATTR_onclick, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_ondblclick, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmousedown, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseup, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseover, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmousemove, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseout, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeypress, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeydown, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeyup, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_align, atList, IMPLIED, NODEFAULT, 'left|center|right|justify|char');
  FAttributes.AddAttribute(ATTR_char, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_charoff, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_valign, atList, IMPLIED, NODEFAULT, 'top|middle|bottom|baseline');

  // nested elements
  FNestedElements.AddNew(THtmTr, wciOneOrMore);

  if wcServerExtensions in xmlENV.xmlCapabilities
  then FNestedElements.AddNew(THtmServerSide, wciAny);
end;

constructor THtmcolgroup.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  // attributes
  FAttributes.AddAttribute(ATTR_id, atID, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_class, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_style, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_title, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_lang, atNMTOKEN, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_xml_lang, atNMTOKEN, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_dir, atList, IMPLIED, NODEFAULT, 'ltr|rtl');
  FAttributes.AddAttribute(ATTR_onclick, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_ondblclick, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmousedown, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseup, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseover, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmousemove, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseout, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeypress, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeydown, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeyup, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_span, atCDATA, IMPLIED, '1', NOLIST);
  FAttributes.AddAttribute(ATTR_width, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_align, atList, IMPLIED, NODEFAULT, 'left|center|right|justify|char');
  FAttributes.AddAttribute(ATTR_char, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_charoff, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_valign, atList, IMPLIED, NODEFAULT, 'top|middle|bottom|baseline');

  // nested elements
  FNestedElements.AddNew(THtmCol, wciAny);

  if wcServerExtensions in xmlENV.xmlCapabilities
  then FNestedElements.AddNew(THtmServerSide, wciAny);
end;

constructor THtmcol.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  // attributes
  FAttributes.AddAttribute(ATTR_id, atID, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_class, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_style, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_title, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_lang, atNMTOKEN, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_xml_lang, atNMTOKEN, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_dir, atList, IMPLIED, NODEFAULT, 'ltr|rtl');
  FAttributes.AddAttribute(ATTR_onclick, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_ondblclick, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmousedown, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseup, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseover, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmousemove, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseout, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeypress, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeydown, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeyup, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_span, atCDATA, IMPLIED, '1', NOLIST);
  FAttributes.AddAttribute(ATTR_width, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_align, atList, IMPLIED, NODEFAULT, 'left|center|right|justify|char');
  FAttributes.AddAttribute(ATTR_char, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_charoff, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_valign, atList, IMPLIED, NODEFAULT, 'top|middle|bottom|baseline');

  // EMPTY
end;

constructor THtmtr.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  // attributes
  FAttributes.AddAttribute(ATTR_id, atID, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_class, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_style, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_title, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_lang, atNMTOKEN, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_xml_lang, atNMTOKEN, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_dir, atList, IMPLIED, NODEFAULT, 'ltr|rtl');
  FAttributes.AddAttribute(ATTR_onclick, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_ondblclick, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmousedown, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseup, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseover, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmousemove, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseout, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeypress, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeydown, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeyup, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_align, atList, IMPLIED, NODEFAULT, 'left|center|right|justify|char');
  FAttributes.AddAttribute(ATTR_char, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_charoff, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_valign, atList, IMPLIED, NODEFAULT, 'top|middle|bottom|baseline');
  FAttributes.AddAttribute(ATTR_bgcolor, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_height, atCDATA, IMPLIED, NODEFAULT, NOLIST);

  // nested elements
  FNestedElements.AddNew(THtmTh, wciOneOrMore);
  FNestedElements.AddNew(THtmTd, wciOneOrMore);

  if wcServerExtensions in xmlENV.xmlCapabilities
  then FNestedElements.AddNew(THtmServerSide, wciAny);
end;

constructor THtmth.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  // attributes
  FAttributes.AddAttribute(ATTR_id, atID, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_class, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_style, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_title, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_lang, atNMTOKEN, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_xml_lang, atNMTOKEN, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_dir, atList, IMPLIED, NODEFAULT, 'ltr|rtl');
  FAttributes.AddAttribute(ATTR_onclick, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_ondblclick, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmousedown, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseup, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseover, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmousemove, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseout, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeypress, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeydown, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeyup, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_abbr, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_axis, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_headers, atIDREFS, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_scope, atList, IMPLIED, NODEFAULT, 'row|col|rowgroup|colgroup');
  FAttributes.AddAttribute(ATTR_rowspan, atCDATA, IMPLIED, '1', NOLIST);
  FAttributes.AddAttribute(ATTR_colspan, atCDATA, IMPLIED, '1', NOLIST);
  FAttributes.AddAttribute(ATTR_align, atList, IMPLIED, NODEFAULT, 'left|center|right|justify|char');
  FAttributes.AddAttribute(ATTR_char, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_charoff, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_valign, atList, IMPLIED, NODEFAULT, 'top|middle|bottom|baseline');
  FAttributes.AddAttribute(ATTR_nowrap, atList, IMPLIED, NODEFAULT, 'nowrap');
  FAttributes.AddAttribute(ATTR_bgcolor, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_width, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_height, atCDATA, IMPLIED, NODEFAULT, NOLIST);

  // nested elements
  FNestedElements.AddNew(THtmPCDATA, wciAny);
  FNestedElements.AddNew(THtmP, wciAny);
  FNestedElements.AddNew(THtmH1, wciAny);
  FNestedElements.AddNew(THtmH2, wciAny);
  FNestedElements.AddNew(THtmH3, wciAny);
  FNestedElements.AddNew(THtmH4, wciAny);
  FNestedElements.AddNew(THtmH5, wciAny);
  FNestedElements.AddNew(THtmH6, wciAny);
  FNestedElements.AddNew(THtmDiv, wciAny);
  FNestedElements.AddNew(THtmUl, wciAny);
  FNestedElements.AddNew(THtmOl, wciAny);
  FNestedElements.AddNew(THtmDl, wciAny);
  FNestedElements.AddNew(THtmMenu, wciAny);
  FNestedElements.AddNew(THtmDir, wciAny);
  FNestedElements.AddNew(THtmPre, wciAny);
  FNestedElements.AddNew(THtmHr, wciAny);
  FNestedElements.AddNew(THtmBlockquote, wciAny);
  FNestedElements.AddNew(THtmAddress, wciAny);
  FNestedElements.AddNew(THtmCenter, wciAny);
  FNestedElements.AddNew(THtmNoframes, wciAny);
  FNestedElements.AddNew(THtmIsindex, wciAny);
  FNestedElements.AddNew(THtmFieldset, wciAny);
  FNestedElements.AddNew(THtmTable, wciAny);
  FNestedElements.AddNew(THtmForm, wciAny);
  FNestedElements.AddNew(THtmA, wciAny);
  FNestedElements.AddNew(THtmBr, wciAny);
  FNestedElements.AddNew(THtmSpan, wciAny);
  FNestedElements.AddNew(THtmBdo, wciAny);
  FNestedElements.AddNew(THtmObject, wciAny);
  FNestedElements.AddNew(THtmApplet, wciAny);
  FNestedElements.AddNew(THtmImg, wciAny);
  FNestedElements.AddNew(THtmMap, wciAny);
  FNestedElements.AddNew(THtmIframe, wciAny);
  FNestedElements.AddNew(THtmTt, wciAny);
  FNestedElements.AddNew(THtmI, wciAny);
  FNestedElements.AddNew(THtmB, wciAny);
  FNestedElements.AddNew(THtmU, wciAny);
  FNestedElements.AddNew(THtmS, wciAny);
  FNestedElements.AddNew(THtmStrike, wciAny);
  FNestedElements.AddNew(THtmBig, wciAny);
  FNestedElements.AddNew(THtmSmall, wciAny);
  FNestedElements.AddNew(THtmFont, wciAny);
  FNestedElements.AddNew(THtmBasefont, wciAny);
  FNestedElements.AddNew(THtmEm, wciAny);
  FNestedElements.AddNew(THtmStrong, wciAny);
  FNestedElements.AddNew(THtmDfn, wciAny);
  FNestedElements.AddNew(THtmCode, wciAny);
  FNestedElements.AddNew(THtmQ, wciAny);
  FNestedElements.AddNew(THtmSamp, wciAny);
  FNestedElements.AddNew(THtmKbd, wciAny);
  FNestedElements.AddNew(THtmVar, wciAny);
  FNestedElements.AddNew(THtmCite, wciAny);
  FNestedElements.AddNew(THtmAbbr, wciAny);
  FNestedElements.AddNew(THtmAcronym, wciAny);
  FNestedElements.AddNew(THtmSub, wciAny);
  FNestedElements.AddNew(THtmSup, wciAny);
  FNestedElements.AddNew(THtmInput, wciAny);
  FNestedElements.AddNew(THtmSelect, wciAny);
  FNestedElements.AddNew(THtmTextarea, wciAny);
  FNestedElements.AddNew(THtmLabel, wciAny);
  FNestedElements.AddNew(THtmButton, wciAny);
  FNestedElements.AddNew(THtmNoscript, wciAny);
  FNestedElements.AddNew(THtmIns, wciAny);
  FNestedElements.AddNew(THtmDel, wciAny);
  FNestedElements.AddNew(THtmScript, wciAny);

  if wcServerExtensions in xmlENV.xmlCapabilities
  then FNestedElements.AddNew(THtmServerSide, wciAny);
end;

constructor THtmtd.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  // attributes
  FAttributes.AddAttribute(ATTR_id, atID, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_class, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_style, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_title, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_lang, atNMTOKEN, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_xml_lang, atNMTOKEN, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_dir, atList, IMPLIED, NODEFAULT, 'ltr|rtl');
  FAttributes.AddAttribute(ATTR_onclick, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_ondblclick, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmousedown, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseup, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseover, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmousemove, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onmouseout, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeypress, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeydown, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_onkeyup, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_abbr, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_axis, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_headers, atIDREFS, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_scope, atList, IMPLIED, NODEFAULT, 'row|col|rowgroup|colgroup');
  FAttributes.AddAttribute(ATTR_rowspan, atCDATA, IMPLIED, '1', NOLIST);
  FAttributes.AddAttribute(ATTR_colspan, atCDATA, IMPLIED, '1', NOLIST);
  FAttributes.AddAttribute(ATTR_align, atList, IMPLIED, NODEFAULT, 'left|center|right|justify|char');
  FAttributes.AddAttribute(ATTR_char, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_charoff, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_valign, atList, IMPLIED, NODEFAULT, 'top|middle|bottom|baseline');
  FAttributes.AddAttribute(ATTR_nowrap, atList, IMPLIED, NODEFAULT, 'nowrap');
  FAttributes.AddAttribute(ATTR_bgcolor, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_width, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_height, atCDATA, IMPLIED, NODEFAULT, NOLIST);

  // nested elements
  FNestedElements.AddNew(THtmPCDATA, wciAny);
  FNestedElements.AddNew(THtmP, wciAny);
  FNestedElements.AddNew(THtmH1, wciAny);
  FNestedElements.AddNew(THtmH2, wciAny);
  FNestedElements.AddNew(THtmH3, wciAny);
  FNestedElements.AddNew(THtmH4, wciAny);
  FNestedElements.AddNew(THtmH5, wciAny);
  FNestedElements.AddNew(THtmH6, wciAny);
  FNestedElements.AddNew(THtmDiv, wciAny);
  FNestedElements.AddNew(THtmUl, wciAny);
  FNestedElements.AddNew(THtmOl, wciAny);
  FNestedElements.AddNew(THtmDl, wciAny);
  FNestedElements.AddNew(THtmMenu, wciAny);
  FNestedElements.AddNew(THtmDir, wciAny);
  FNestedElements.AddNew(THtmPre, wciAny);
  FNestedElements.AddNew(THtmHr, wciAny);
  FNestedElements.AddNew(THtmBlockquote, wciAny);
  FNestedElements.AddNew(THtmAddress, wciAny);
  FNestedElements.AddNew(THtmCenter, wciAny);
  FNestedElements.AddNew(THtmNoframes, wciAny);
  FNestedElements.AddNew(THtmIsindex, wciAny);
  FNestedElements.AddNew(THtmFieldset, wciAny);
  FNestedElements.AddNew(THtmTable, wciAny);
  FNestedElements.AddNew(THtmForm, wciAny);
  FNestedElements.AddNew(THtmA, wciAny);
  FNestedElements.AddNew(THtmBr, wciAny);
  FNestedElements.AddNew(THtmSpan, wciAny);
  FNestedElements.AddNew(THtmBdo, wciAny);
  FNestedElements.AddNew(THtmObject, wciAny);
  FNestedElements.AddNew(THtmApplet, wciAny);
  FNestedElements.AddNew(THtmImg, wciAny);
  FNestedElements.AddNew(THtmMap, wciAny);
  FNestedElements.AddNew(THtmIframe, wciAny);
  FNestedElements.AddNew(THtmTt, wciAny);
  FNestedElements.AddNew(THtmI, wciAny);
  FNestedElements.AddNew(THtmB, wciAny);
  FNestedElements.AddNew(THtmU, wciAny);
  FNestedElements.AddNew(THtmS, wciAny);
  FNestedElements.AddNew(THtmStrike, wciAny);
  FNestedElements.AddNew(THtmBig, wciAny);
  FNestedElements.AddNew(THtmSmall, wciAny);
  FNestedElements.AddNew(THtmFont, wciAny);
  FNestedElements.AddNew(THtmBasefont, wciAny);
  FNestedElements.AddNew(THtmEm, wciAny);
  FNestedElements.AddNew(THtmStrong, wciAny);
  FNestedElements.AddNew(THtmDfn, wciAny);
  FNestedElements.AddNew(THtmCode, wciAny);
  FNestedElements.AddNew(THtmQ, wciAny);
  FNestedElements.AddNew(THtmSamp, wciAny);
  FNestedElements.AddNew(THtmKbd, wciAny);
  FNestedElements.AddNew(THtmVar, wciAny);
  FNestedElements.AddNew(THtmCite, wciAny);
  FNestedElements.AddNew(THtmAbbr, wciAny);
  FNestedElements.AddNew(THtmAcronym, wciAny);
  FNestedElements.AddNew(THtmSub, wciAny);
  FNestedElements.AddNew(THtmSup, wciAny);
  FNestedElements.AddNew(THtmInput, wciAny);
  FNestedElements.AddNew(THtmSelect, wciAny);
  FNestedElements.AddNew(THtmTextarea, wciAny);
  FNestedElements.AddNew(THtmLabel, wciAny);
  FNestedElements.AddNew(THtmButton, wciAny);
  FNestedElements.AddNew(THtmNoscript, wciAny);
  FNestedElements.AddNew(THtmIns, wciAny);
  FNestedElements.AddNew(THtmDel, wciAny);
  FNestedElements.AddNew(THtmScript, wciAny);

  if wcServerExtensions in xmlENV.xmlCapabilities
  then FNestedElements.AddNew(THtmServerSide, wciAny);
end;

// --------- THtmBracket ---------

constructor THtmBracket.Create(ACollection: TCollection);
var
  e: Integer;
begin
  inherited Create(ACollection);
  if wcServerExtensions in xmlENV.xmlCapabilities then begin
    for e:= Low(XHtmLElements) + 2 to High(XHtmLElements) do begin
      FNestedElements.AddNew(XHtmLElements[e], wciAny);
    end;
  end;  
end;

// --------- GetDocumentTitle ---------

{
  GetDocumentTitle() calls xml parser
}

function GetDocumentTitle(const ASrc: WideString): String;
label
  fin;
var
  XHtmLCollection: TxmlElementCollection;
  e: TxmlElement;
begin
  Result:= '';
  XHtmLCollection:= TxmlElementCollection.Create(THtmContainer, Nil, wciOne);
  with XHtmLCollection do begin
    Clear1;
    xmlParse.xmlCompileText(ASrc, Nil, Nil, Nil, Items[0], THtmContainer, THtmTitle);
    Result:= Items[0].NestedElementText[THtmTitle, 0];
  end;
fin:
  XHtmLCollection.Free;
end;

// --------- RegisterXML ---------

function RegisterXML(var AxmlDesc: TxmlClassDesc): Integer;
begin
  Result:= 0;
  with AxmlDesc do begin
    ofs:= 157;
    len:= 97; // last is 253
    classes:= @XHtmLElements;
    DocType:= edXHtmL;

    xmlElementClass:= THtmContainer;
    xmlPCDataClass:= THtmPCData;
    DocDescClass:= THtmDocDesc;

    deficon:= ofs;
    defaultextension:= 'xHtml';
    desc:= 'Extensible Html file';
    extensionlist:= 'xHtml|Html|Htm';
    OnDocumentTitle:= GetDocumentTitle;
  end;
end;

end.

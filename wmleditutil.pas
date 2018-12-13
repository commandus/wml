unit
  wmleditutil;
(*##*)
(*******************************************************************************
*                                                                             *
*   w  m  l  e  d  i  t  u  t  i  l                                            *
*                                                                             *
*   Copyright © 2001-2003 Andrei Ivanov. All rights reserved.                  *
*   wireless markup language editor utility functions                         *
*   Conditional defines:                                                       *
*                                                                             *
*   Revisions    : Jul 06 2001                                                 *
*   Last fix     : Jul 29 2001                                                *
*   Lines        : 289                                                         *
*   History      :                                                            *
*   Printed      : ---                                                         *
*                                                                             *
********************************************************************************)
(*##*)

interface

uses
  Classes, Windows, SysUtils, Controls, Graphics, Menus,
  ComCtrls, Forms, JclUnicode,
  customxml, xmlsupported, xmlParse, wbmpImage, EMemo, EMemos, util1,
  wml, oebdoc, oebpkg, xHTML, BioTaxon, smit, xHHC, xHHK, rtc, 
  HtmlHlp, GifImage; // do not include GifImage and wmledutil to ocx projects

const
  RESDLLNAME = 'apooedr.dll';
  INFOTIPDLLNAME = 'apooinfotip.dll';
  IEEXTDLLNAME   = 'apooedieext.dll';  

type
  TSearchOperation = (srchNone, srchSearch, srchReplace);
  TSearchContext = class(TPersistent)
  private
  public
    Count: Integer;
    LastOperation: TSearchOperation;
    LastSearches: TStrings;
    LastReplaces: TStrings;
    LastSearchText: WideString;
    LastReplaceText: WideString;
    LastFindOptions: TGsFindOptions; //  = [foCaseSensitive, foWholeWords, foStartOrigin, foEntireScope, foBackward]
    LastInitDir: String;
    Where: Integer; // 0 - current file 1 - opened files 2- directory
    DirRecurse: Boolean;
    constructor Create;
    destructor Destroy; override;
    procedure AddOperation(ALastOperation: TSearchOperation; const ASrch, AReplace: WideString;
      AWhere: Integer; ADirRecurse: Boolean; AOptions: TGsFindOptions);
  end;

{
function WMLCompileStrings(ASrc: TStrings; AReportEvent: TReportEvent;
  ATreeViewElements: TTreeView;
  AResultElement: TWMLElement): Integer;
}

// return True - wbmp image exists and valid
// return False else
function IsValidWBMPFile(const AFileName: String): Boolean;

function ConvertImage2WBMP(const AFileIn: String; AStreamWBMP: TStream;
  ADitherMode: TDitherMode; ATransformOptions: TTransformOptions; var AImageSize: TPoint): Boolean;
function ConvertImage2WBMPFile(const AFileNameIn: String; const AFileNameWBMP: String;
  ADitherMode: TDitherMode; ATransformOptions: TTransformOptions; var AImageSize: TPoint): Boolean;

// return is this version is beta
function IsBetaVersion(const AConfigPath: String): Boolean;

// create filter strings for CBFilter combobox
procedure CreateFilterStrings(AItems: TStrings);

// create file description and associate with icon

procedure CreateFilterFileDesc(AItems: TStrings);

// --------- return document type such edWML ---------

function GetDocTypeByFilter(AIndex: Integer): TEditableDoc;

// --------- return FilterIndex value by document type such edWML ---------

function GetFilterIdxByDocType(AIndex: TEditableDoc): Integer;

function GetXSLTFileName(ADocTypeSrc, ADocTypeDest: TEditableDoc): String;

function ShowHTMLHelpNag(AControl: TWinControl; const AHlpFileName, AKeywords: String): HWND;

procedure UpdateRecentFilesMenu(ARecentFilesMenu: TMenu; ARecentFilesMenuClick: TNotifyEvent; const AFileName: String);

implementation

// TSearchContext implementation -----------------------------------------------

constructor TSearchContext.Create;
begin
  inherited;
  LastSearches:= TStringList.Create;
  with TStringList(LastSearches) do begin
    Duplicates:= dupIgnore;
    Sorted:= False;
  end;
  LastReplaces:= TStringList.Create;
  with TStringList(LastReplaces) do begin
    Duplicates:= dupIgnore;
    Sorted:= False;
  end;
  Count:= 0;
  LastSearchText:= '';
  LastReplaceText:= '';
  LastInitDir:= '';
  DirRecurse:= False;
  Where:= 0;
  LastOperation:= srchNone;
  LastFindOptions:= [foOriginFromCursor];
end;

destructor TSearchContext.Destroy;
begin
  LastSearches.Free;
  inherited;
end;

procedure TSearchContext.AddOperation(ALastOperation: TSearchOperation; const ASrch, AReplace: WideString; AWhere: Integer; ADirRecurse: Boolean; AOptions: TGsFindOptions);
begin
  LastOperation:= ALastOperation;
  LastSearchText:= ASrch;
  LastReplaceText:= AReplace;
  LastFindOptions:= AOptions;
  // LastInitDir:= ALastInitDir;
  Where:= AWhere;
  DirRecurse:= ADirRecurse;
  Include(LastFindOptions, foOriginFromCursor); // do not search entire again
  if LastSearches.IndexOf(ASrch) < 0
  then LastSearches.Insert(0, ASrch);
  if LastReplaces.IndexOf(AReplace) < 0
  then LastSearches.Insert(0, AReplace);
end;

// utility functions implementation --------------------------------------------

// return True - wbmp image exists and valid
// return False else
function IsValidWBMPFile(const AFileName: String): Boolean;
begin
  Result:= CompareText(ExtractFileExt(AFileName), '.wbmp') = 0;
end;

function ConvertImage2WBMP(const AFileIn: String; AStreamWBMP: TStream;
  ADitherMode: TDitherMode; ATransformOptions: TTransformOptions; var AImageSize: TPoint): Boolean;
var
  wbmpImg: TWBMPImage;
  Picture: TPicture;
begin
  Result:= True;
  Picture:= TPicture.Create;
  wbmpImg:= TWBMPImage.Create;
  try
    Picture.LoadFromFile(AFileIn);
    with wbmpImg do begin
      TransformOptions:= ATransformOptions;
      DitherMode:= ADitherMode;
      Assign(Picture.Graphic);
      SaveToStream(AStreamWBMP);
      AImageSize.X:= Width;
      AImageSize.Y:= Height;
    end;
  except
    Result:= False;
    // Exit;
  end;
  wbmpImg.Free;
  Picture.Free;
end;

function ConvertImage2WBMPFile(const AFileNameIn: String; const AFileNameWBMP: String;
  ADitherMode: TDitherMode; ATransformOptions: TTransformOptions; var AImageSize: TPoint): Boolean;
var
  StrmOut: TStream;
begin
  try
    StrmOut:= TFileStream.Create(AFileNameWBMP, fmCreate);
    Result:= ConvertImage2WBMP(AFileNameIn, StrmOut,
      ADitherMode, ATransformOptions, AImageSize);
  except
    Result:= False;
  end;
  StrmOut.Free;
end;

// return is this version is beta
function IsBetaVersion(const AConfigPath: String): Boolean;
const
  CHKFILENAME = 'readme.txt';
var
  fn: String;
begin
  fn:= ConcatPath(AConfigPath, CHKFILENAME);
  Result:= FileExists(fn) and (Pos('BETA', UpperCase(util1.File2String(fn))) > 0);
end;

// create filter strings for CBFilter combobox

procedure CreateFilterStrings(AItems: TStrings);
begin
  with AItems do begin
    Clear;
    AddObject('WML files (*.wml)',                            // 1
      TObject(xmlsupported.GetBitmapIndexByClass(TWMLWML)));
    AddObject('Text files (*.txt)',                           // 2
      TObject(0));
    AddObject('HTML files (*.htm;*.html)',                    // 3
      TObject(0));
    AddObject('WML compiled files (*.wmlc)',                  // 4
      TObject(xmlsupported.GetBitmapIndexByClass(TWMLWML)));
    AddObject('WML templates (*.wmlt)',                       // 5
      TObject(xmlsupported.GetBitmapIndexByClass(TWMLWML)));
    AddObject('Open eBook publications (*.oeb;*.htm;*.html)', // 6
      TObject(xmlsupported.GetBitmapIndexByClass(TOEBHTML)));
    AddObject('Open eBook packaging file(*.opf)',             // 7
      TObject(xmlsupported.GetBitmapIndexByClass(TOEBPackage)));
    AddObject('CSS files (*.css)',                            // 8
      TObject(0));
    AddObject('XHTML files (*.xhtml;*.html;*.htm;*.xml)',     // 9
      TObject(xmlsupported.GetBitmapIndexByClass(THTMHtml)));
    AddObject('Taxon files (*.txn;*.xml)',                    // 10
      TObject(xmlsupported.GetBitmapIndexByClass(TTxnTaxon)));
    AddObject('SMIT files (*.smt;*.xml)',                     // 11
      TObject(xmlsupported.GetBitmapIndexByClass(TSmtMenu)));
    AddObject('HHC Help Content(*.hhc)',                      // 12
      TObject(xmlsupported.GetBitmapIndexByClass(THHCContainer)));
    AddObject('HHK Help Keywords(*.hhk)',                     // 13
      TObject(xmlsupported.GetBitmapIndexByClass(THHKContainer)));
    AddObject('RTC user profile(*.rtc)',                      // 14
      TObject(xmlsupported.GetBitmapIndexByClass(TRTCContainer)));
    AddObject('All files (*.*)',
      TObject(0));
  end;
end;

// create file description and associate with icon

procedure CreateFilterFileDesc(AItems: TStrings);
begin
  // Note: objects stores bitmap index used in TCheckListBox DOESNT ALLOW -1 (used as error indicator)
  // Therefore use -2 or smth except -1 !!
  with AItems do begin
    Clear;
    AddObject('wml source (*.wml)',                            // 1
      TObject(xmlsupported.GetBitmapIndexByClass(TWMLWML)));
    AddObject('text (*.txt)',                                  // 2
      TObject(0));
    AddObject('html (*.htm;*.html)',                           // 3
      TObject(0));
    AddObject('wml compiled (*.wmlc)',                         // 4
      TObject(xmlsupported.GetBitmapIndexByClass(TWMLWML)));
    AddObject('wml template (*.wmlt)',                         // 5
      TObject(xmlsupported.GetBitmapIndexByClass(TWMLWML)));
    AddObject('Open eBook publication (*.oeb;*.htm;*.html)',   // 6
      TObject(xmlsupported.GetBitmapIndexByClass(TOEBHTML)));
    AddObject('Open eBook package (*.opf)',                    // 7
      TObject(xmlsupported.GetBitmapIndexByClass(ToebPackage)));
    AddObject('cascade style sheet (*.css)',                   // 8
      TObject(0));
    AddObject('Extensible HTML (*.xhtml;*.html;*.htm;*.xml)',  // 9
      TObject(xmlsupported.GetBitmapIndexByClass(THTMHtml)));
    AddObject('Taxon file (*.txn;*.xml)',                      // 10
      TObject(xmlsupported.GetBitmapIndexByClass(TTxnTaxon)));
    AddObject('SMIT file (*.smt;*.xml)',                       // 11
      TObject(xmlsupported.GetBitmapIndexByClass(TSmtMenu)));

  end;
end;

// return document type such edDefault

function GetDocTypeByFilter(AIndex: Integer): TEditableDoc;
begin
  case AIndex of
    1: Result:= edWML;          // WML files (*.wml)
    2: Result:= edText;         // Text files (*.txt)
    3: Result:= edHTML;         // HTML files (*.htm;*.html)
    4: Result:= edWMLCompiled;  // WML compiled files (*.wmlc)
    5: Result:= edWMLTemplate;  // WML templates (*.wmlt)
    6: Result:= edOEB;          // Open eBook publications (*.oeb;*.htm;*.html)
    7: Result:= edPKG;          // Open eBook packaging file(*.opf)
    8: Result:= edCSS;          // CSS files (*.css)
    9: Result:= edXHTML;        // Extensible HTML files (*.xhtml;*.html;*.htm;*.xml)
    10:Result:= edTaxon;        // Taxon file (*.txn;*.xml)
    11:Result:= edSMIT;         // SMIT file (*.smt;*.xml)
    12:Result:= edHHC;         // Help Content file (*.hhc)
    13:Result:= edHHK;         // Help Keyword file (*.hhk)
  else Result:= edDefault;
  end;
end;

function GetFilterIdxByDocType(AIndex: TEditableDoc): Integer;
begin
  case AIndex of
    edWML: Result:= 1;          // WML files (*.wml)
    edText: Result:= 2;         // Text files (*.txt)
    edHTML: Result:= 3;         // HTML files (*.htm;*.html)
    edWMLCompiled: Result:= 4;  // WML compiled files (*.wmlc)
    edWMLTemplate: Result:= 5;  // WML templates (*.wmlt)
    edOEB: Result:= 6;          // Open eBook publications (*.oeb;*.htm;*.html)
    edPKG: Result:= 7;          // Open eBook packaging file(*.opf)
    edCSS: Result:= 8;          // CSS files (*.css)
    edXHTML: Result:= 9;        // Extensible HTML files (*.xhtml;*.html;*.htm;*.xml)
    edTaxon: Result:= 10;       // Taxon file (*.txn;*.xml)
    edSMIT: Result:= 11;        // SMIT file (*.smt;*.xml)
  else Result:= -1;
  end;
end;

// appropriate methods does not works properly
{
function WMLCompileStrings(ASrc: TStrings; AReportEvent: TReportEvent;
  ATreeViewElements: TTreeView;
  AResultElement: TWMLElement): Integer;
var
  WMLParser: TWMLParser;
begin
  AResultElement.Clear;
  WMLParser:= TWMLParser.Create;
  with WMLParser do begin
    WMLParser.Lines:= ASrc;
    OnReport:= AReportEvent;
    Parse2WML(AResultElement);
  end;
  WMLParser.Free;
  if Assigned(ATreeViewElements) then with ATreeViewElements do begin
    Items.BeginUpdate;
    Items.Clear;
    Items.AddObject(Nil, AResultElement.Name, AResultElement);
    TopItem.ImageIndex:= 0;
    TopItem.SelectedIndex:= 0;
    AddWMLElement2TreeNode(AResultElement, TopItem);
    Items.EndUpdate;
  end;
  Result:= 0;
end;
}

function GetXSLTFileName(ADocTypeSrc, ADocTypeDest: TEditableDoc): String;
begin
  Result:= IntToStr(Integer(ADocTypeSrc)) + '-' + IntToStr(Integer(ADocTypeDest)) + '.xsl'
end;

const
  MSG_NOHELPFILE    = 'Help file: %s not found.';

function ShowHTMLHelpNag(AControl: TWinControl; const AHlpFileName, AKeywords: String): HWND;
var
  Link: THHAKLink;
  helpfn: String;
  SysMenu: HMENU;
  cw: Integer;
begin
  helpfn:= AHlpFileName;
  if not FileExists(helpfn) then begin
    raise Exception.CreateFmt(MSG_NOHELPFILE, [helpfn]);
  end;
  FillChar(Link, SizeOf(Link), 0);
  with Link do begin
    cbStruct:= SizeOf(Link);
    fReserved:= False;
    pszKeywords:= PChar(AKeywords);  // 'z-nag'
    //pszUrl:= 'z-about.htm';
    pszWindow:= 'nag'; // PChar('nag') + '>nag'
    // on fault display index
    fIndexOnFail:= True;
  end;
  Result:= HtmlHelp(AControl.Handle, PChar(helpFn), HH_KEYWORD_LOOKUP, DWORD(@Link));
  // helpFn:= helpFn + '::/' + 'z-about.htm';
  // Result:= HtmlHelp(AControl.Handle, PChar(helpFn), HH_DISPLAY_TOPIC, 0);

  { Modify the system menu to look more like it's s'pose to }
  SysMenu:= GetSystemMenu(Result, False);

  { Make the system menu look like a dialog which has no sys commands }

  DeleteMenu(SysMenu, SC_TASKLIST, MF_BYCOMMAND);
  DeleteMenu(SysMenu, 7, MF_BYPOSITION);
  DeleteMenu(SysMenu, 5, MF_BYPOSITION);
  DeleteMenu(SysMenu, SC_MAXIMIZE, MF_BYCOMMAND);
  DeleteMenu(SysMenu, SC_MINIMIZE, MF_BYCOMMAND);
  DeleteMenu(SysMenu, SC_SIZE, MF_BYCOMMAND);
  DeleteMenu(SysMenu, SC_RESTORE, MF_BYCOMMAND);
  DeleteMenu(SysMenu, SC_CLOSE, MF_BYCOMMAND);
  DeleteMenu(SysMenu, SC_MOVE, MF_BYCOMMAND);
                                                      
  { disable buttons }

  EnableMenuItem(SysMenu, SC_CLOSE, MF_BYCOMMAND or MF_DISABLED);
  EnableMenuItem(SysMenu, SC_MINIMIZE, MF_BYCOMMAND or MF_DISABLED);
  EnableMenuItem(SysMenu, SC_MAXIMIZE, MF_BYCOMMAND or MF_DISABLED);
  EnableMenuItem(SysMenu, SC_RESTORE, MF_BYCOMMAND or MF_DISABLED);
  EnableMenuItem(SysMenu, SC_MOVE, MF_BYCOMMAND or MF_DISABLED);

  { move window so no caption is visible }
  cw:= GetSystemMetrics(SM_CYSMCAPTION);  // SM_CYSMCAPTION was SM_CYCAPTION

  SetWindowPos(Result, HWND_TOP, 0, -cw, AControl.Width, AControl.Height + cw, SWP_SHOWWINDOW);
end;

procedure UpdateRecentFilesMenu(ARecentFilesMenu: TMenu; ARecentFilesMenuClick: TNotifyEvent; const AFileName: String);
var
  i, p: Integer;
  S: String;
  m: TMenuItem;
  Fx: Integer;
begin
  Fx:= -1;
  with ARecentFilesMenu do begin
    for i:= 0 to Items.Count - 1 do begin
      m:= Items[i];
      S:= m.Caption;
      p:= Pos(#32, s);
      if p > 0
      then Delete(S, 1, p);
      if S = AFileName then begin
        Fx:= i;
        Break;
      end;
      // renum
      m.Caption:= '&' + IntToHex(i + 1, 1) + #32 + S;
    end;
    if (Fx = -1) and (Items.Count > $F)
    then Fx:= Items.Count - 1;
    if Fx >= 0
    then Items.Delete(Fx);

    m:= TMenuItem.Create(ARecentFilesMenu);
    m.Caption:= '&0' + #32 + AFileName;
    m.OnClick:= ARecentFilesMenuClick;
    m.ImageIndex:= GetBitmapIndexByFileName(AFileName) + 1;
    Items.Insert(0, m);
  end;
end;

end.

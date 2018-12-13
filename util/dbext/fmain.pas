unit fmain;
(*##*)
(*******************************************************************
*                                                                 *
*   f  m  a  i  n                                                  *
*                                                                 *
*   Copyright © 2002 Andrei Ivanov. All rights reserved.           *
*   server extension test program                                 *
*   Conditional defines:                                           *
*                                                                 *
*   Revisions    : May 20 2002                                     *
*   Last fix     : May 27 2002                                    *
*   Lines        : 286                                             *
*   History      :                                                *
*   Printed      : ---                                             *
*                                                                 *
********************************************************************)
(*##*)

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Forms,
  Dialogs, Menus, StdCtrls, ExtCtrls, ActnList, StdActns, ComCtrls, ImgList, ToolWin,

  jclUnicode, util1, customxml, wml, wmlc, xmlSupported, xmlparse, util_xml, EMemo, EMemoWMLCode,
  dbParser, Registry,
  dbxmlInt, Controls;

type
  TFormMain = class(TForm)
    MainMenu1: TMainMenu;
    MFile: TMenuItem;
    MFileOpen: TMenuItem;
    MFileD1: TMenuItem;
    MFileExit: TMenuItem;
    ActionList1: TActionList;
    FileOpen1: TFileOpen;
    actCompile: TAction;
    PanelTop: TPanel;
    PanelDest: TPanel;
    PanelSrc: TPanel;
    FileSaveAs1: TFileSaveAs;
    MFileD2: TMenuItem;
    MFileSaveAs: TMenuItem;
    Splitter1: TSplitter;
    Splitter2: TSplitter;
    LBInfo: TListBox;
    CoolBar1: TCoolBar;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    ImageList1: TImageList;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;
    actSettings: TAction;
    MOptions: TMenuItem;
    Settings1: TMenuItem;
    PanelVars: TPanel;
    Splitter3: TSplitter;
    MVars: TMemo;
    PanelCookies: TPanel;
    MCookies: TMemo;
    procedure MFileExitClick(Sender: TObject);
    procedure FileOpen1Accept(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure actCompileExecute(Sender: TObject);
    procedure FileSaveAs1Accept(Sender: TObject);
    procedure LBInfoClick(Sender: TObject);
    procedure actSettingsExecute(Sender: TObject);
  private
    { Private declarations }
    FdocType: TEditableDoc;

    EMemoSrc: TEMemo;
    EMemoDest: TEMemo;
    EMemoWMLCode: TEMemoWMLCode;
    EMemoWMLCode2: TEMemoWMLCode;
    FDbParser: TxmlDbParser;

    FCompileAfterFileIsOpened: Boolean;

    FDBXMLDLLCalls: TDBXMLDLLCalls;
    FDllHandle: THandle; // TFuncFmtDll
    FDLLName: String;
    procedure OnReportEvent(ALevel: TReportLevel; AxmlElement: TxmlElement;
      const ASrc: PWideChar; ALen: Cardinal; AWhere: TPoint; const ADesc: PWideChar; var AContinueParse: Boolean);
  public

    { Public declarations }
    function LoadIni: Boolean;
    function StoreIni: Boolean;
    function LoadDLL: Boolean;
  end;

const
  RG_DLL      = 'DbXMLDll';
  RG_AUTOOPEN = 'DbXMLParseAfterFileIsOpened';
  RG_DRVBDE   = 'dbXMLbde.dll';
  RG_DRVIB    = 'dbXMLib.dll';
  RG_DRVADO   = 'dbXMLado.dll';
  RG_DRVDBE   = 'dbXMLdbe.dll';
  RG_DRVLDAP  = 'dbXMLldap.dll';

var
  FormMain: TFormMain;

implementation

uses fsettings;

{$R *.dfm}

function TFormMain.LoadDLL: Boolean;
var
  ws: WideString;
begin
  if FDllHandle <> 0 then begin
    FDBXMLDLLCalls.FClearThreadCache;
    FreeLibrary(FDllHandle);
  end;
  FDllHandle:= dbXMLInt.LoadDBXMLDLLCalls(FDLLName, '/', FDBXMLDLLCalls);
  Result:= FDllHandle <> 0;

  ws:= 'Connect';
  if Result
  then FDBXMLDLLCalls.FInit(PWideChar(ws), []); // PWideChar(@(ws[1])));
end;

{ load settings from registry }
function TFormMain.LoadIni: Boolean;
var
  Rg: TRegistry;
begin
  Result:= False;
  FDLLName:= RG_DRVBDE;
  FCompileAfterFileIsOpened:= False;
  Rg:= TRegistry.Create;
  Rg.RootKey:= HKEY_CURRENT_USER;// HKEY_LOCAL_MACHINE;
  if not Rg.OpenKey(RGPath, False) then begin
    Exit;
  end;
  try
    FCompileAfterFileIsOpened:= Rg.ReadBool(RG_AUTOOPEN);
  except;
  end;
  try
    FDLLName:= Rg.ReadString(RG_DLL);
  except;
  end;
  if Length(FDLLName) = 0
  then FDLLName:= RG_DRVBDE;
  Rg.Free;
  Result:= True;
end; { LoadIni }

function TFormMain.StoreIni: Boolean;
var
  Rg: TRegistry;
begin
  Result:= True;
  Rg:= TRegistry.Create;
  Rg.RootKey:= HKEY_CURRENT_USER; //HKEY_LOCAL_MACHINE;
  Rg.OpenKey(RGPATH, True);
  try
    Rg.WriteBool(RG_AUTOOPEN, FCompileAfterFileIsOpened);
  except;
  end;
  try
    Rg.WriteString(RG_DLL, FDLLName);
  except;
  end;
  Rg.Free;
end; { StoreIni }

procedure TFormMain.MFileExitClick(Sender: TObject);
begin
  Close;
end;

procedure TFormMain.FileOpen1Accept(Sender: TObject);
var
  s: String;
begin
  //
  FdocType:= GetDocTypeByFileName(FileOpen1.Dialog.FileName);
  if FdocType = edHTML then FdocType:= edxHTML; 
  s:= util1.File2String(FileOpen1.Dialog.FileName);
  if Length(s) = 0
  then s:= #13#10;
  with EMemoSrc do begin
    Encoding:= util_xml.GetEncoding(s, csUTF8);
    // load
    TextInCharacterset[convPCDATA]:= s;
    EMemoDest.ScrollTo(0, 0);
    Refresh;
  end;

  if FCompileAfterFileIsOpened then begin
    actCompileExecute(Self);
  end else begin
  end;
end;

procedure TFormMain.FileSaveAs1Accept(Sender: TObject);
var
  s: String;
  fn, ext: String;
begin
  //
  s:= EMemoDest.TextInCharacterset[convPCDATA];
  fn:= FileOpen1.Dialog.FileName;
  ext:= ExtractFileExt(fn);
  if CompareText(ext, '.wml') = 0
  then util1.String2File(fn, s);
  if CompareText(ext, '.bin') = 0 then begin
    raise Exception.Create('Not implemented yet');
  end;
end;

procedure TFormMain.FormCreate(Sender: TObject);
begin
  LoadIni;
  FDllHandle:= 0;
  LoadDLL;

  FDbParser:= TXMLDbParser.Create(Nil);
  EMemoSrc:= TEMemo.Create(Self);

  // FDBXMLDLLCalls.FSetDbXMLParseReport(OnReportEvent);
  with EMemoSrc do begin
    Align:= alClient;
    Parent:= PanelSrc;
    GutterOptions.Visible:= False;
  end;
  EMemoDest:= TEMemo.Create(Self);
  with EMemoDest do begin
    Align:= alClient;
    Parent:= PanelDest;
    GutterOptions.Visible:= False;
  end;
  EMemoWMLCode:= TEMemoWMLCode.Create(Self);
  EMemoWMLCode2:= TEMemoWMLCode.Create(Self);
  EMemoWMLCode.CxMemo:= EMemoSrc;
  EMemoWMLCode2.CxMemo:= EMemoDest;

  // allow server extensions
  xmlEnv.XMLCapabilities:= [wcServerExtensions];
end;

procedure TFormMain.FormDestroy(Sender: TObject);
begin
  if FDllHandle <> 0 then begin
    FDBXMLDLLCalls.FClearThreadCache;
    FDBXMLDLLCalls.FDone;
    FreeLibrary(FDllHandle);
  end;
  EMemoWMLCode2.Free;
  EMemoWMLCode.Free;
//?!!  FDbParser.Free; cause AVE in ADO. After delay about 1 sec - ok
end;

procedure TFormMain.OnReportEvent(ALevel: TReportLevel; AxmlElement: TxmlElement;
  const ASrc: PWideChar; ALen: Cardinal; AWhere: TPoint; const ADesc: PWideChar; var AContinueParse: Boolean);
begin
  if ALevel = rlFinishThread then with EMemoDest do begin
    Clear;  // set Modified:= True;
    Lines.Text:= ASrc;
    Modified:= False;
    ModifiedSinceLastDelay:= True;
    Invalidate;

    // at thhe rlFinishThread AxmlElement contaons cookie PWideChar
    LBInfo.Items.Add('Cookies: ' + PWideChar(AxmlElement));
  end else begin
    LBInfo.Items.AddObject(Format('%s: %s(%d,%d): %s', [ReportLevelStr[ALevel],
      ASrc, AWhere.x + 1, AWhere.y + 1, ADesc]), AxmlElement);
  end;
end;

procedure TFormMain.actCompileExecute(Sender: TObject);
var
  vars, cookies: WideString;
  pVars, pcookie: PWideChar;
begin
  LBInfo.Items.Clear;
  try
    vars:= MVars.Lines.CommaText;
    cookies:= MCookies.Lines.CommaText;
    pVars:= PWideChar(vars);
    pcookie:= PWideChar(cookies);
    FDBXMLDLLCalls.FStartDbXMLParse(FdocType, PWideChar(EMemoSrc.Lines.Text),
      pVars, pCookie, OnReportEvent, [pcParse]);
  finally
  end;
  LBInfo.Items.Add('Threads: ' + IntToStr(FDBXMLDLLCalls.FGetThreadCount) + ' ' + FDBXMLDLLCalls.FGetInfo);
end;

procedure TFormMain.LBInfoClick(Sender: TObject);
var
  el: TxmlElement;
begin
  if LBInfo.ItemIndex >= 0 then begin
    el:= TxmlElement(LBInfo.Items.Objects[LBInfo.ItemIndex]);
    if Assigned(el) then with el.DrawProperties.TagXYStart do begin
      EMemoSrc.CaretPos_V:= x;
      EMemoSrc.CaretPos_H:= y - 1;
      EMemoSrc.Refresh;
      EMemoSrc.SetFocus;
    end;
  end;
end;

procedure TFormMain.actSettingsExecute(Sender: TObject);
var
  fn: String;
begin
  //
  FormSettings:= TFormSettings.Create(Self);
  with FormSettings do begin
    CBCompileAfterOpen.Checked:= FCompileAfterFileIsOpened;
    fn:= ExtractFileName(FDLLName);
    if CompareText(fn, RG_DRVBDE) = 0 then RGDriver.ItemIndex:= 0;
    if CompareText(fn, RG_DRVIB) = 0 then RGDriver.ItemIndex:= 1;
    if CompareText(fn, RG_DRVADO) = 0 then RGDriver.ItemIndex:= 2;
    if CompareText(fn, RG_DRVDBE) = 0 then RGDriver.ItemIndex:= 3;
    if CompareText(fn, RG_DRVLDAP) = 0 then RGDriver.ItemIndex:= 4;

    if FormSettings.ShowModal = mrOk then begin
      FCompileAfterFileIsOpened:= CBCompileAfterOpen.Checked;
      case RGDriver.ItemIndex of
        0: FDLLName:= RG_DRVBDE;
        1: FDLLName:= RG_DRVIB;
        2: FDLLName:= RG_DRVADO;
        3: FDLLName:= RG_DRVDBE;
        4: FDLLName:= RG_DRVLDAP;
      end;
      StoreIni;
      LoadDLL;
    end;
    Free;
  end;
end;

end.

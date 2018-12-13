unit fPreferences;
(*##*)
(*******************************************************************************
*                                                                              *
*   f  P  r  e  f  e  r  e  n  c  e  s                                        *
*   settings preferences dialog window, part of apooed                         *
*                                                                             *
*   Copyright © 2001, 2002 Andrei Ivanov. All rights reserved.                 *
*                                                                             *
*   Conditional defines:                                                       *
*                                                                             *
*   Revisions    : Mar 29 2002                                                 *
*   Last revision:                                                            *
*   Lines        : 120                                                         *
*   History      :                                                            *
*   Printed      : ---                                                         *
*                                                                             *
********************************************************************************)
(*##*)

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, StdCtrls, ExtCtrls, CheckLst,
  dm, jclLocales;

type
  TFormPreferences = class(TForm)
    PCPref: TPageControl;
    Panel1: TPanel;
    BOk: TButton;
    BCancel: TButton;
    TSGeneral: TTabSheet;
    GBImage: TGroupBox;
    CBDefaultDitherMode: TComboBox;
    LDitherMode: TLabel;
    CBStretchPreview: TCheckBox;
    GBCharset: TGroupBox;
    LCharSet: TLabel;
    CBCharSet: TComboBox;
    LCharSetDesc: TLabel;
    TSLanguages: TTabSheet;
    CLBLanguages: TCheckListBox;
    LLanguage: TLabel;
    MLanguage: TMemo;
    GBExtensions: TGroupBox;
    CBServerSide: TCheckBox;
    CBWBXMLVersion: TComboBox;
    LWBXMLVersion: TLabel;
    Label2: TLabel;
    TSLIT: TTabSheet;
    GBGenerator: TGroupBox;
    CBLitgenGenAutoStart: TCheckBox;
    EUDLFolder: TEdit;
    LUDLFolder: TLabel;
    BUDLFolder: TButton;
    BShowUDLFolder: TButton;
    GBTempFolder: TGroupBox;
    Memo1: TMemo;
    ETempFolder: TEdit;
    BTempFolder: TButton;
    EDbDrvFileName: TEdit;
    BDbDrvFileName: TButton;
    LDbDrvFileName: TLabel;
    CBDbDrvEnable: TCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure BUDLFolderClick(Sender: TObject);
    procedure BTempFolderClick(Sender: TObject);
    procedure BDbDrvFileNameClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
//    property LangEnabledList: TStrings;
  end;

var
  FormPreferences: TFormPreferences;

implementation

{$R *.dfm}

uses
  FileCtrl, util1, fDockBase;

procedure TFormPreferences.FormCreate(Sender: TObject);
var
  LL: TjclLocalesList;
  S, sub: String;
  i: Integer;
begin
  LL:= TjclLocalesList.Create(lkInstalled);
  with CLBLanguages do begin
    Items.BeginUpdate;
    Clear;
    Sorted:= True;
    for i:= 0 to LL.Count - 1 do with LL[i] do begin
      // LangName2Code(EnglishLangName)
      s:= ISOAbbreviatedLangName;
      sub:= Lowercase(ISOAbbreviatedCountryName);
      if CompareText(s, sub) = 0
      then
      else s:= s + '-' + sub;
      // LangName2Code(EnglishLangName)
      Items.AddObject(Format('%s %s', [EnglishLangName, s]), TObject(LangId));
    end;
    Items.EndUpdate;
  end;
  LL.Free;
  { get languages
  for i:= LANGDEF_FIRST to LANGDEF_LAST do begin
    CLBLanguages.Items.AddObject(LangDef[i].n, TObject(LangDef[i].c));
  end;
  }
end;

procedure TFormPreferences.FormActivate(Sender: TObject);
begin
  BOk.SetFocus;
end;

procedure TFormPreferences.BUDLFolderClick(Sender: TObject);
var
  s: String;
  root: WideString;
begin
  //
  s:= ExpandFileName(EUDLFolder.Text);
  root:= '';//FormDockBase.FParameters.Values[ParameterNames[ID_ConfigDir]];
  if SelectDirectory('Select data access object files folder', root, s) then begin
    s:= util1.DiffPath(FormDockBase.FParameters.Values[ParameterNames[ID_ConfigDir]], s);
    if (Length(s) > 0) and (s[1] = '\')
    then Delete(s, 1, 1);
    EUDLFolder.Text:= s;
  end;
end;

procedure TFormPreferences.BTempFolderClick(Sender: TObject);
var
  s: String;
  root: WideString;
begin
  //
  s:= ExpandFileName(ETempFolder.Text);
  root:= '';
  if SelectDirectory('Select temporary files folder', root, s) then begin
    s:= util1.DiffPath(FormDockBase.FParameters.Values[ParameterNames[ID_WORKDIR]], s);
    if (Length(s) > 0) and (s[1] = '\')
    then Delete(s, 1, 1);
    ETempFolder.Text:= s;
  end;
end;

procedure TFormPreferences.BDbDrvFileNameClick(Sender: TObject);
var
  d: TOpenDialog;
  p: String;
begin
  //
  d:= TOpenDialog.Create(Nil);
  with d do begin
    p:= ExtractFilePath(EDbDrvFileName.Text);
    if DirectoryExists(p)
    then InitialDir:= p;
    {
    // in case of spc protocol redirector
    FileName:= 'spc.dll';
    Title:= 'Select IE "ap" protocol COM server';
    Filter:= 'ap protocol (spc.dll)|spc.dll|Other COM server libraries(*.dll)|*.dll|All files (*.*)|*.*';
    HistoryList.Text:= 'spc.dll';
    }
    {
    // in case of ISAPI module db access
    FileName:= 'wdbxml.dll';
    Title:= 'Select ISAPI module';
    Filter:= 'wdbxml.dll ISAPI module(wdbxml.dll)|wdbxml.dll|ISAPI modules (*.dll)|*.dll|All files (*.*)|*.*';
    HistoryList.Text:= 'wdbxml.dll';
    }

    // in case of direct db access
    FileName:= 'dbxmlib.dll';
    Title:= 'Select db access DLL';
    Filter:= 'ADO driver(dbxmlado.dll)|dbxmlado.dll|Interbase driver (dbxmlib.dll)|dbxmlib.dll|BDE driver(dbxmlbde.dll)|dbxmlbde.dll|Database express driver(dbxmldbe.dll)|dbxmldbe.dll|Other drivers (*.dll)|*.dll|All files (*.*)|*.*';
    HistoryList.Text:= 'dbxmlib.dll'#13#10'dbxmlado.dll'#13#10'dbxmlbde.dll'#13#10'dbxmldbe.dll';
    
    FilterIndex:= 1;
    if Execute then begin
      EDbDrvFileName.Text:= FileName;
    end;
    Free;
  end;
end;

end.

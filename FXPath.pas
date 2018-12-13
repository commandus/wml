unit
  FXPath;
(*##*)
(*******************************************************************************
*                                                                              *
*   F  F  I  N  D                                                             *
*   wml editor find and replace text window, part of apooed                    *
*                                                                             *
*   Copyright © 2001, 2002 Andrei Ivanov. All rights reserved.                 *
*                                                                             *
*   Conditional defines:                                                       *
*                                                                             *
*   Revisions    : Mar 29 2002                                                 *
*   Last revision:                                                            *
*   Lines        : 76                                                          *
*   History      :                                                            *
*   Printed      : ---                                                         *
*                                                                             *
********************************************************************************)
(*##*)


interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  FileCtrl, Dialogs, StdCtrls, ExtCtrls,
  util1, util_xml;

type
  TFormXPath = class(TForm)
    PanelSearch: TPanel;
    LText: TLabel;
    CBText: TComboBox;
    BOk: TButton;
    BCancel: TButton;
    RGWhere: TRadioGroup;
    GBDir: TGroupBox;
    LFileMask: TLabel;
    CBDir: TComboBox;
    BDirBrowse: TButton;
    CBDirRecurse: TCheckBox;
    CBFilter: TComboBox;
    LWichFiles: TLabel;
    BHelp: TButton;
    LAction: TLabel;
    CBDirPerform: TComboBox;
    CBProgram: TComboBox;
    LProgram: TLabel;
    BProgram: TButton;
    BShowLines: TButton;
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormActivate(Sender: TObject);
    procedure RGWhereClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure BDirBrowseClick(Sender: TObject);
    procedure BHelpClick(Sender: TObject);
    procedure BProgramClick(Sender: TObject);
    procedure CBDirPerformChange(Sender: TObject);
    procedure BShowLinesClick(Sender: TObject);
    procedure CBTextChange(Sender: TObject);
  private
    { Private declarations }
    FText2Search: WideString;
    procedure SetText2Search(AValue: WideString);
  public
    { Public declarations }
    property Text2Search: WideString read FText2Search write SetText2Search;
  end;

var
  FormXPath: TFormXPath;

implementation

{$R *.dfm}

uses
  wmleditutil, fDockBase, fedittext;

procedure TFormXPath.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
const
  pt: TPoint = (x: 0; y: 0);
begin
  if ssAlt in Shift then begin
    case Key of
      Ord('X'): CBText.SetFocus;
      Ord('U'): RGWhere.ItemIndex:= 0;
      Ord('O'): RGWhere.ItemIndex:= 1;
      Ord('I'): RGWhere.ItemIndex:= 2;
    end;
  end else begin
    case Key of
      VK_F1, VK_HELP: begin
        BHelpClick(Self);
      end;
    end;
  end;
end;

procedure TFormXPath.FormActivate(Sender: TObject);
begin
  //  BOk.SetFocus;
  // CBText.SetFocus;
end;

procedure TFormXPath.RGWhereClick(Sender: TObject);
begin
  GBDir.Visible:= RGWhere.ItemIndex = 2;
end;

procedure TFormXPath.FormCreate(Sender: TObject);
begin
  with CBFilter do begin
    Items.Clear;
    CreateFilterStrings(Items);
    ItemIndex:= 0;
    OnDrawItem:= FormDockBase.CBFilterDrawItem;
  end;
end;

procedure TFormXPath.BDirBrowseClick(Sender: TObject);
var
  s: String;
  root: WideString;
begin
  //
  s:= ExpandFileName(CBDir.Text);
  root:= '';//FormDockBase.FParameters.Values[ParameterNames[ID_ConfigDir]];
  if SelectDirectory('Select data access object files folder', root, s) then begin
    // s:= util1.DiffPath(FormDockBase.FParameters.Values[ParameterNames[ID_ConfigDir]], s);
    if (Length(s) > 0) and (s[1] = '\')
    then Delete(s, 1, 1);
    CBDir.Text:= s;
  end;
end;

procedure TFormXPath.BProgramClick(Sender: TObject);
var
  s: String;
  root: WideString;
  DlgOpen: TOpenDialog;
begin
  //
  s:= ExpandFileName(CBProgram.Text);
  // root:= '';
  root:= FormDockBase.FParameters.Values[ParameterNames[ID_ConfigDir]];
  
  DlgOpen:= TOpenDialog.Create(Nil);
  with DlgOpen do begin
    Title:= 'Select program to execute on found text';
    InitialDir:= ExtractFilePath(s);
    FileName:= s;
    HistoryList.Add(s);
    DefaultExt:= 'exe';
    Filter := 'Executable files (*.exe)|*.exe|Library files (*.dll#functionName)|*.dll|All files (*.*)|*.*';
    FilterIndex:= 1;
    if Execute then begin
    s:= FileName;
      CBProgram.Text:= util1.DiffPath(root, s);
    end;
    Free;
  end;
end;

procedure TFormXPath.BHelpClick(Sender: TObject);
var
  p: TPoint;
begin
  // help screen
  p.X:= 0;
  p.Y:= 0;
  formDockBase.ShowHelpByIndex(p, Nil, 'cmdeditxpath');
end;

procedure TFormXPath.CBDirPerformChange(Sender: TObject);
var
  b: Boolean;
begin
  b:= CBDirPerform.ItemIndex = 3;
  CBProgram.Visible:= b;
  LProgram.Visible:= b;
  BProgram.Visible:= b;
end;

procedure TFormXPath.SetText2Search(AValue: WideString);
begin
  FText2Search:= AValue;
  CBText.Text:= AValue;
end;

procedure TFormXPath.BShowLinesClick(Sender: TObject);
var
  ws: WideString;
begin
  FormEditText:= TFormEditText.Create(Self);
  with FormEditText do begin
    EMemo.Lines.Text:= Text2Search;
    if ShowModal = mrOK then begin
      ws:= EMemo.TextInCharacterset[convPCData];
      // while util1.ReplaceStr(ws, True, #13#10, '$') do;
      Text2Search:= ws;
    end;
    Free;
  end;
end;

procedure TFormXPath.CBTextChange(Sender: TObject);
begin
  FText2Search:= CBText.Text;
end;

end.

unit
  FFindReplace;
(*##*)
(*******************************************************************************
*                                                                              *
*   F  F  I  N  D                                                             *
*   wml ediotor find and replace text window, part of apooed                   *
*                                                                             *
*   Copyright © 2001, 2002 Andrei Ivanov. All rights reserved.                 *
*                                                                             *
*   Conditional defines:                                                       *
*                                                                             *
*   Revisions    : Mar 29 2002                                                 *
*   Last revision: Oct 30 2002                                                *
*   Lines        : 87                                                          *
*   History      :                                                            *
*   Printed      : ---                                                         *
*                                                                             *
********************************************************************************)
(*##*)


interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  FileCtrl, Dialogs, StdCtrls, ExtCtrls, util1, util_xml;

type
  TFormFindReplace = class(TForm)
    PanelSearch: TPanel;
    LText: TLabel;
    GBOptions: TGroupBox;
    RGDirection: TRadioGroup;
    RGScope: TRadioGroup;
    RGOrigin: TRadioGroup;
    CBCaseSensitive: TCheckBox;
    CBWholeWordsOnly: TCheckBox;
    CBRegularExpressions: TCheckBox;
    CBText: TComboBox;
    BOk: TButton;
    BCancel: TButton;
    LReplaceWith: TLabel;
    CBReplaceWith: TComboBox;
    BReplaceAll: TButton;
    RGWhere: TRadioGroup;
    GBDir: TGroupBox;
    LFileMask: TLabel;
    Label1: TLabel;
    CBDir: TComboBox;
    BDirBrowse: TButton;
    CBDirRecurse: TCheckBox;
    CBFilter: TComboBox;
    CBSpaceCompress: TCheckBox;
    CBIgnoreNonSpacing: TCheckBox;
    BHelp: TButton;
    BShowLines: TButton;
    BShowLinesReplace: TButton;
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormActivate(Sender: TObject);
    procedure RGWhereClick(Sender: TObject);
    procedure BDirBrowseClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure CBRegularExpressionsClick(Sender: TObject);
    procedure BHelpClick(Sender: TObject);
    procedure BShowLinesClick(Sender: TObject);
    procedure BShowLinesReplaceClick(Sender: TObject);
    procedure CBTextChange(Sender: TObject);
    procedure CBReplaceWithChange(Sender: TObject);
  private
    { Private declarations }
    FText2Search: WideString;
    FText2Replace: WideString;
    procedure SetText2Search(AValue: WideString);
    procedure SetText2Replace(AValue: WideString);
  public
    { Public declarations }
    property Text2Search: WideString read FText2Search write SetText2Search;
    property Text2Replace: WideString read FText2Replace write SetText2Replace;
  end;

var
  FormFindReplace: TFormFindReplace;

implementation

{$R *.dfm}

uses
  fDockBase, fedittext, wmleditutil;

procedure TFormFindReplace.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if ssAlt in Shift then begin
    case Key of
      Ord('A'): BReplaceAll.Click;    
      Ord('T'): CBText.SetFocus;
      Ord('C'): CBCaseSensitive.Checked:= not CBCaseSensitive.Checked;
      Ord('W'): CBWholeWordsOnly.Checked:= not CBWholeWordsOnly.Checked;
      Ord('R'): CBRegularExpressions.Checked:= not CBRegularExpressions.Checked;
      Ord('F'): RGOrigin.ItemIndex:= 0;
      Ord('E'): RGOrigin.ItemIndex:= 1;
      Ord('G'): RGScope.ItemIndex:= 0;
      Ord('S'): RGScope.ItemIndex:= 1;
      Ord('D'): RGDirection.ItemIndex:= 0;
      Ord('B'): RGDirection.ItemIndex:= 1;
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

procedure TFormFindReplace.FormActivate(Sender: TObject);
begin
  //  BOk.SetFocus;
  // CBText.SetFocus;
end;

procedure TFormFindReplace.RGWhereClick(Sender: TObject);
begin
  GBDir.Visible:= RGWhere.ItemIndex = 2;
  if GBDir.Visible then begin
    RGOrigin.Enabled:= False;
    RGScope.Enabled:= False;
    RGDirection.Enabled:= False;
  end else begin
    RGOrigin.Enabled:= True;
    RGScope.Enabled:= True;
    RGDirection.Enabled:= not CBRegularExpressions.Checked;
  end;
  BOk.Visible:= RGWhere.ItemIndex = 0;
end;

procedure TFormFindReplace.BDirBrowseClick(Sender: TObject);
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

procedure TFormFindReplace.FormCreate(Sender: TObject);
begin
  with CBFilter do begin
    Items.Clear;
    wmleditutil.CreateFilterStrings(Items);
    ItemIndex:= 0;
    OnDrawItem:= FormDockBase.CBFilterDrawItem;
  end;
end;

procedure TFormFindReplace.CBRegularExpressionsClick(Sender: TObject);
var
  e: Boolean;
begin
  //
  e:= CBRegularExpressions.Checked;
  CBSpaceCompress.Visible:= e;
  CBIgnoreNonSpacing.Visible:= e;
  RGDirection.Enabled:= (not e) and (RGWhere.ItemIndex <> 2);
end;

procedure TFormFindReplace.BHelpClick(Sender: TObject);
var
  p: TPoint;
begin
  // help screen
  p.X:= 0;
  p.Y:= 0;
  formDockBase.ShowHelpByIndex(p, Nil, 'cmdeditreplace');
end;

procedure TFormFindReplace.SetText2Search(AValue: WideString);
begin
  FText2Search:= AValue;
  CBText.Text:= AValue;
end;

procedure TFormFindReplace.SetText2Replace(AValue: WideString);
begin
  FText2Replace:= AValue;
  CBReplaceWith.Text:= AValue;
end;

procedure TFormFindReplace.BShowLinesClick(Sender: TObject);
var
  ws: WideString;
begin
  FormEditText:= TFormEditText.Create(Self);
  with FormEditText do begin
    EMemo.Lines.Text:= Text2Search;
    if ShowModal = mrOK then begin
      ws:= EMemo.TextInCharacterset[convPCData];
      while util1.ReplaceStr(ws, True, #13#10, '$') do CBRegularExpressions.Checked:= True;
      Text2Search:= ws;
    end;
    Free;
  end;
end;

procedure TFormFindReplace.BShowLinesReplaceClick(Sender: TObject);
begin
  FormEditText:= TFormEditText.Create(Self);
  with FormEditText do begin
    EMemo.Lines.Text:= Text2Replace;
    if ShowModal = mrOK
    then Text2Replace:= EMemo.Lines.Text;
    Free;
  end;
end;

procedure TFormFindReplace.CBTextChange(Sender: TObject);
begin
  FText2Search:= CBText.Text;
end;

procedure TFormFindReplace.CBReplaceWithChange(Sender: TObject);
begin
  FText2Replace:= CBReplaceWith.Text;
end;

end.

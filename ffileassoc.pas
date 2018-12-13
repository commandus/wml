unit
  ffileassoc;
(*##*)
(*******************************************************************************
*                                                                              *
*   F  F  I  L  E  A  S  S  O  C                                              *
*   file associations form, part of CVRT2WBMP, apooed                          *
*                                                                             *
*   Copyright © 2001, 2002 Andrei Ivanov. All rights reserved.                 *
*                                                                             *
*   Conditional defines:                                                       *
*                                                                             *
*   Revisions: Jun 26 2001                                                     *
*   Last revision:                                                            *
*   Lines        : 199                                                         *
*   History      :                                                            *
*   Printed      : ---                                                         *
*                                                                             *
********************************************************************************)
(*##*)

interface

uses Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls,
  Buttons, ExtCtrls, CheckLst,
  ActiveX, ComObj, Dialogs,
  ComCtrls, utilwin, util_xml;

type
  TFormFileAssociations = class(TForm)
    PageControl1: TPageControl;
    TSFileTypes: TTabSheet;
    TSExplorer: TTabSheet;
    Panel1: TPanel;
    BOk: TButton;
    BCancel: TButton;
    TSIE: TTabSheet;
    Panel2: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    CheckListBoxFileTypes: TCheckListBox;
    BSelectAll: TButton;
    BDeselectAll: TButton;
    Memo1: TMemo;
    LFileTypes: TLabel;
    GBExplorerContextMenu: TGroupBox;
    CBEdit: TCheckBox;
    GBInfoTip: TGroupBox;
    Memo2: TMemo;
    GBIEButton: TGroupBox;
    CBShowIETBtn: TCheckBox;
    CBInfoTip: TCheckBox;
    Memo3: TMemo;
    procedure FormActivate(Sender: TObject);
    procedure BSelectAllClick(Sender: TObject);
    procedure BDeselectAllClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure CheckListBoxFileTypesDrawItem(Control: TWinControl;
      Index: Integer; Rect: TRect; State: TOwnerDrawState);
  private
    { Private declarations }
    FConfigDir: String;
    FInfotipDLLName: String;
  public
    { Public declarations }
    procedure DoAssociate;
  end;

var
  FormFileAssociations: TFormFileAssociations;

implementation

{$R *.DFM}

uses
  util1, wmleditutil, fdockBase, dm;

procedure TFormFileAssociations.BSelectAllClick(Sender: TObject);
var
  i: Integer;
begin
  for i:= 0 to CheckListBoxFileTypes.Count - 1 do begin
    CheckListBoxFileTypes.Checked[i]:= True;
  end;
end;

procedure TFormFileAssociations.BDeselectAllClick(Sender: TObject);
var
  i: Integer;
begin
  for i:= 0 to CheckListBoxFileTypes.Count - 1 do begin
    CheckListBoxFileTypes.Checked[i]:= False;
  end;
end;

{---}

procedure TFormFileAssociations.FormCreate(Sender: TObject);
var
  R: TStrings;
  i, e: Integer;
  b: Boolean;
  FileDesc, FileIcon, CmdDesc, CmdProg, CmdParam, DdeApp, DDETopic, DDEItem: String;
begin

  FConfigDir:= fdockBase.FormDockBase.FParameters.Values[ParameterNames[ID_ConfigDir]];
  FInfotipDLLName:= util1.ConcatPath(FConfigDir, wmleditutil.INFOTIPDLLNAME);

  R:= TStringList.Create;
  with CheckListBoxFileTypes do begin
    CreateFilterFileDesc(Items);
    // mark selected
    for i:= 0 to Items.Count - 1 do begin
      R.Clear;
      util_xml.GetStringsFromFileFilter(Items[i], 2, R);
      b:= False;
      for e:= 0 to r.Count - 1 do begin
        b:= b or utilwin.IsFileExtAssociatesWithCmd(r[e], 'apoo' + r[e], 'Edit',
          FileDesc, FileIcon, CmdDesc, CmdProg, CmdParam, DdeApp, DDETopic, DDEItem);
      end;
      Checked[i]:= b;
    end;
  end;
  R.Free;
end;

procedure TFormFileAssociations.FormActivate(Sender: TObject);
begin
  BOk.SetFocus;
end;

function GetIconNumber(ANo: Integer): Integer;
begin
  Result:= 0;
  case ANo of
    0: Result:= 3;  // wml source (*.wml) icon
    1:;             // text (*.txt)
    2:;             // html (*.htm;*.html)
    3: Result:= 3;  // wml compiled (*.wmlc)
    4: Result:= 3;  // wml template (*.wmlt)',
    5: Result:= 1;  // Open eBook publication (*.oeb;*.htm;*.html)
    6: Result:= 2;  // Open eBook package (*.opf)
    7:;             // cascade style sheet (*.css)
  end; // case
end;

procedure TFormFileAssociations.DoAssociate;
var
  i, extc, p: Integer;
  extensionList: TStrings;
  s: String;
begin
  extensionList:= TStringList.Create;
  with CheckListBoxFileTypes do begin
    for i:= 0 to Items.Count - 1 do begin
      extensionList.Clear;
      s:= CheckListBoxFileTypes.Items[i];
      util_xml.GetStringsFromFileFilter(s, 2, extensionList);
      if Checked[i] then begin
        p:= Pos('(', s);
        if p > 0
        then s:= Copy(s, 1, p - 1);
        for extc:= 0 to extensionList.Count - 1 do begin
          utilwin.InstallFileExt(extensionList[extc], 'apoo' + extensionList[extc], s + 'file',
            GetIconNumber(i),
            'Edit', 'Edit '+ s  + 'file', Application.ExeName, '%1',
            'apooed', 'sys', 'fileopen("%1")', True, False);
        end;
      end else begin
        for extc:= 0 to extensionList.Count - 1 do begin
          utilwin.DeInstallFileExt(extensionList[extc], 'apoo' + extensionList[extc]);
        end;
      end;
    end;
  end;  
  extensionList.Free;
end;

procedure TFormFileAssociations.CheckListBoxFileTypesDrawItem(
  Control: TWinControl; Index: Integer; Rect: TRect;
  State: TOwnerDrawState);
var
  idx: Integer;      { text offset width }
begin
  // draw file types CheckListBox
  with TCheckListBox(Control).Canvas do begin { draw on control canvas, not on the form }
    FillRect(Rect);       { clear the rectangle }
    // get the bitmap
    idx:= Integer(TCheckListBox(Control).Items.Objects[Index]);
    if idx >= 0 then begin
      dm.dm1.ImageList16.Draw(TCheckListBox(Control).Canvas, Rect.Left + 2, Rect.Top,  idx);
    end;
    { add 4 pixels between bitmap and text}
    TextOut(Rect.Left + dm.dm1.ImageList16.Width + 6, Rect.Top, TCheckListBox(Control).Items[Index])  { display the text }
  end;
end;

end.

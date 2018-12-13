unit fmain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ImgList, ComCtrls, ToolWin, ExtCtrls, Grids, ActnList,
  util1, util_xml, wmlc, Menus;

type
  TFormMain = class(TForm)
    PanelMerge: TPanel;
    CoolBarMerger: TCoolBar;
    ToolBarMerger: TToolBar;
    TBLeftFile: TToolButton;
    ImageList24: TImageList;
    TBD1: TToolButton;
    SG: TStringGrid;
    OpenDialog1: TOpenDialog;
    SaveDialog1: TSaveDialog;
    ActionList1: TActionList;
    actFileOpenFrom: TAction;
    actFileOpenTo: TAction;
    actFileResultSaveAs: TAction;
    TBInsert: TToolButton;
    TBDelete: TToolButton;
    TBSaveSrc: TToolButton;
    actSaveSrc: TAction;
    actInsertRow: TAction;
    actDeleteSelection: TAction;
    TBSplit: TToolButton;
    actSplitCellDown: TAction;
    pmFileOpen: TPopupMenu;
    pmFileSave: TPopupMenu;
    pmOpenFileFrom: TMenuItem;
    pmOpenFileTo: TMenuItem;
    pmFileD1: TMenuItem;
    actFileOpenTranslated: TAction;
    Opentranslatedfile1: TMenuItem;
    Savesources1: TMenuItem;
    SaveResultAs1: TMenuItem;
    pmSaveD1: TMenuItem;
    TBSort: TToolButton;
    actSort: TAction;
    actToolTest1: TAction;
    actFileAddToTranslated: TAction;
    N1: TMenuItem;
    AddFromtoTranslated1: TMenuItem;
    procedure PanelMergeResize(Sender: TObject);
    procedure actFileOpenFromExecute(Sender: TObject);
    procedure actFileOpenToExecute(Sender: TObject);
    procedure actFileResultSaveAsExecute(Sender: TObject);
    procedure SGKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure actSaveSrcExecute(Sender: TObject);
    procedure actInsertRowExecute(Sender: TObject);
    procedure actDeleteSelectionExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure actSplitCellDownExecute(Sender: TObject);
    procedure actFileOpenTranslatedExecute(Sender: TObject);
    procedure actSortExecute(Sender: TObject);
    procedure actFileAddToTranslatedExecute(Sender: TObject);
  private
    { Private declarations }
    procedure RemoveEmptyLines;
  public
    { Public declarations }
    ResultFN: String;
    FileNames: array[0..2] of String;
    procedure OpenColumn(ACol: Integer; const ATitle: String);
    procedure SaveColumn(ACol: Integer; const ATitle: String);
  end;

var
  FormMain: TFormMain;

implementation

{$R *.dfm}

procedure TFormMain.OpenColumn(ACol: Integer; const ATitle: String);
var
  s: String;
  sl: TStrings;
begin
  //
  sl:= TStringList.Create;
  with OpenDialog1 do begin
    Title:= ATitle;
    DefaultExt:= 'phr';
    InitialDir:= '';
    // HistoryList.Text:= 'phrases.phr';
    Options:= Options - [ofAllowMultiSelect];
    FilterIndex:= 1;
    Filter:= 'ANSI text files (*.*)|*.*|UTF-8 text files (*.*)|*.*';
    if Execute then begin
      FileNames[ACol]:= FileName;
      s:= util1.File2String(FileName);
      case FilterIndex of
      2:begin
          s:= util_xml.CharSet2WideStringLine(csUTF8, s, []);
        end;
      else begin
        end;
      end; { case }
    end;
  end;

  sl.Text:= s;
  if SG.RowCount < sl.Count
  then SG.RowCount:= sl.Count;
  SG.Cols[ACol]:= sl;

  sl.Free;
end;

procedure TFormMain.SaveColumn(ACol: Integer; const ATitle: String);
var
  s: String;
  ex: Boolean;
begin
  //
  ex:= FileExists(FileNames[ACol]);
  s:= SG.Cols[ACol].Text;

  if not ex then  with SaveDialog1 do begin
    Title:= ATitle;
    DefaultExt:= 'phr';
    InitialDir:= '';
    // HistoryList.Text:= 'phrases.phr';
    Options:= Options - [ofAllowMultiSelect];
    FilterIndex:= 1;
    Filter:= 'ANSI text files (*.*)|*.*|UTF-8 text files (*.*)|*.*';
    if Execute then begin
      case FilterIndex of
      2:begin
          s:= WideString2EncodedString(convPCDATA, csUTF8, s, []);
        end;
      else begin
        end;
      end; { case }
    end;
    FileNames[ACol]:= FileName;
  end;

  util1.String2File(FileNames[ACol], s, True);
end;

procedure TFormMain.PanelMergeResize(Sender: TObject);
begin
  SG.DefaultColWidth:= (PanelMerge.Width - 32) div 2;
end;


procedure TFormMain.actFileAddToTranslatedExecute(Sender: TObject);
var
  s: String;
  sl: TStrings;
  i, r, rcount: Integer;
  fnd: Boolean;
begin
  //
  sl:= TStringList.Create;
  with OpenDialog1 do begin
    Title:= 'Add a new created FROM to the translated';
    DefaultExt:= 'txt';
    InitialDir:= '';
    Options:= Options - [ofAllowMultiSelect];
    FilterIndex:= 1;
    Filter:= 'All files (*.*)|*.*|Text files (*.txt)|*.txt';
    if Execute then begin
      s:= util1.File2String(FileName);
      case FilterIndex of
      2:begin
          s:= util_xml.CharSet2WideStringLine(csUTF8, s, []);
        end;
      else begin
        end;
      end; { case }
    end;
  end;

  sl.Text:= s;
  for i:= 0 to sl.Count - 1 do begin
    fnd:= False;
    rcount:= SG.Cols[0].Count;
    for r:= 0 to rCount - 1 do begin
      if ANSICompareText(SG.Cols[0][r], sl[i]) = 0 then begin
        fnd:= True;
        Break;
      end;
    end;
    if not fnd then begin
      SG.RowCount:= SG.RowCount + 1;
      SG.Cols[0][SG.RowCount - 1]:= sl[i];
    end;
  end;
  sl.Free;
end;

procedure TFormMain.actFileOpenFromExecute(Sender: TObject);
begin
  OpenColumn(0, 'Open Phrases File to be translated');
end;

procedure TFormMain.actFileOpenToExecute(Sender: TObject);
begin
  OpenColumn(1, 'Open translated Phrases File');
end;

procedure TFormMain.actFileOpenTranslatedExecute(Sender: TObject);
var
  s: String;
  sl, sl0: TStrings;
  i, p: Integer;
begin
  //
  sl:= TStringList.Create;
  sl0:= TStringList.Create;
  with OpenDialog1 do begin
    Title:= 'Open dictionary';
    DefaultExt:= 'txt';
    InitialDir:= '';
    // HistoryList.Text:= 'phrases.phr';
    Options:= Options - [ofAllowMultiSelect];
    FilterIndex:= 1;
    Filter:= 'ANSI text files (*.*)|*.*|UTF-8 text files (*.*)|*.*';
    if Execute then begin
      ResultFN:= FileName;
      s:= util1.File2String(ResultFN);
      case FilterIndex of
      2:begin
          s:= util_xml.CharSet2WideStringLine(csUTF8, s, []);
        end;
      else begin
        end;
      end; { case }
    end;
  end;

  sl.Text:= s;
  if SG.RowCount < sl.Count
  then SG.RowCount:= sl.Count;

  for i:= 0 to sl.Count - 1 do begin
    sl0.CommaText:= sl[i];
    if sl0.Count > SG.ColCount
    then SG.ColCount:= sl0.Count;
    for p:= 0 to sl0.Count - 1 do begin
      SG.Cells[p, i]:= sl0[p];
    end;
    for p:= sl0.Count to SG.ColCount - 1 do begin
      SG.Cells[p, i]:= '';
    end;
  end;

  sl0.Free;
  sl.Free;

  RemoveEmptyLines;
end;

procedure TFormMain.actFileResultSaveAsExecute(Sender: TObject);
var
  r: Integer;
  s: String;
  sl: TStrings;
begin
  RemoveEmptyLines;
  sl:= TStringList.Create;
  with SaveDialog1 do begin
    Title:= 'Save Result As';
    DefaultExt:= 'txt';
    InitialDir:= '';
    // HistoryList.Text:= 'phrases.txt';
    Options:= Options - [ofAllowMultiSelect];
    FilterIndex:= 1;
    Filter:= 'ANSI text files (*.*)|*.*|UTF-8 text files (*.*)|*.*';
    if Execute then begin
      ResultFN:= FileName;
      for r:= 0 to SG.RowCount - 1 do begin
        sl.Add(SG.Rows[r].CommaText);
      end;
      s:= sl.Text;

      case FilterIndex of
      2:begin
          s:= WideString2EncodedString(convPCDATA, csUTF8, s, []);
        end;
      else begin
        end;
      end; { case }
    end;
  end;

  util1.String2File(ResultFN, s, True);
  sl.Free;
end;

procedure TFormMain.SGKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  i: Integer;
  s: String[1];
begin
  case Key of
  VK_DELETE: if (ssShift in Shift) and (ssCtrl in Shift) then actDeleteSelection.Execute;
  VK_INSERT: if (ssShift in Shift) and (ssCtrl in Shift) then actInsertRow.Execute;
  VK_DOWN: if (ssShift in Shift) and (ssCtrl in Shift) then actSplitCellDown.Execute;
  Ord('A')..Ord('Z'): if (ssAlt in Shift) then begin
    for i:= 0 to SG.RowCount - 1 do begin
      s:= Copy(SG.Cells[0, i], 1, 1);
      if (Length(s) > 0) and (Upcase(s[1]) = Char(Key)) then begin
        SG.Row:= i;
        Break;
      end;
    end;
  end;
  end;
end;

procedure TFormMain.actSaveSrcExecute(Sender: TObject);
begin
  //
  SaveColumn(0, 'Save Phrases File to be translated As');
  SaveColumn(1, 'Save translated Phrases File As');
end;

procedure TFormMain.actInsertRowExecute(Sender: TObject);
var
  i, c, r: Integer;
begin
  // insert row
  c:= SG.Selection.Left;
  r:= SG.Selection.Top;
  SG.RowCount:= SG.RowCount + 1;
  for i:= SG.RowCount - 1 downto r do begin
    SG.Cells[c, i + 1]:= SG.Cells[c, i];
  end;
  SG.Cells[c, r]:= '';
end;

procedure TFormMain.actDeleteSelectionExecute(Sender: TObject);
var
  c, r: Integer;
  rcount: Integer;
begin
  // delete cell, row
  for c:= SG.Selection.Left to SG.Selection.Right do begin
    rcount:= SG.Selection.Bottom - SG.Selection.Top + 1;
    for r:= SG.Selection.Bottom + 1 to SG.RowCount - 1 do begin
      SG.Cells[c, r - rcount]:= SG.Cells[c, r];
    end;
    for r:= SG.RowCount - 1 downto SG.RowCount - rcount do begin
      SG.Cells[c, r]:= '';
    end;
  end;
end;

procedure TFormMain.FormCreate(Sender: TObject);
var
  i: Integer;
begin
  for i:= Low(FileNames) to High(FileNames) do begin
    FileNames[i]:= '';
  end;
  ResultFN:= '';
end;

procedure TFormMain.actSplitCellDownExecute(Sender: TObject);
begin
  //
  actInsertRow.Execute;
end;

procedure TFormMain.RemoveEmptyLines;
begin
  // delete cell, row
  while SG.RowCount > 0 do begin
    if (Trim(SG.Cells[0, SG.RowCount - 1]) = '') and (Trim(SG.Cells[1, SG.RowCount - 1]) = '') then begin
      if SG.RowCount = 1
      then Break;
      SG.RowCount:= SG.RowCount - 1;
    end else begin
      Break;
    end;
  end;  
end;

procedure TFormMain.actSortExecute(Sender: TObject);
var
  sl, sl1: TStringList;
  i: Integer;
begin
  //
  RemoveEmptyLines;

  sl:= TStringList.Create;
  sl1:= TStringList.Create;
  for i:= 0 to SG.RowCount - 1 do begin
    sl1.AddObject(SG.Cells[1, i], TObject(i));
    sl.AddObject(SG.Cells[0, i], TObject(i));
  end;
  sl.Sort;

  for i:= 0 to sl.Count - 1 do begin
    SG.Cells[0, i]:= sl[i];
    SG.Cells[1, i]:= sl1[Integer(sl.Objects[i])];
  end;

  sl1.Free;
  sl.Free;
end;

end.

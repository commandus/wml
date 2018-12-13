unit
  fGenLIT;
(*##*)
(*******************************************************************************
*                                                                             *
*   f  g  e  n  l  i  t                                                        *
*                                                                             *
*   Copyright © 2002 Andrei Ivanov. All rights reserved.                       *
*   Microsoft reader lit generator form                                       *
*                                                                              *
*                                                                             *
*   Conditional defines:                                                       *
*                                                                             *
*   Revisions    : Oct 29 2002,                                                *
*   Last revision: Oct 29 2002                                                *
*   Lines        : 203                                                         *
*   History      : see todo file                                              *
*                                                                              *
*                                                                             *
*   Printed      :                                                             *
*                                                                             *
********************************************************************************)
(*##*)

interface

uses
  Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls,
  Buttons, ExtCtrls, ShellAPI, Dialogs, ClipBrd, Menus,
  jclShell,
  util1, customxml, xmlsupported, xmlparse, litgen, litgen_MsgCodes, litConv;

type
  TFormGenerateLIT = class(TForm)
    PanelLeft: TPanel;
    PanelBottom: TPanel;
    PanelRight: TPanel;
    PanelTop: TPanel;
    BOk: TButton;
    BStart: TButton;
    LEPackage: TLabeledEdit;
    LEOutput: TLabeledEdit;
    LMessages: TLabel;
    MLines: TListBox;
    CBAutoStart: TCheckBox;
    BView: TSpeedButton;
    pmInfo: TPopupMenu;
    pmMsgCopy: TMenuItem;
    BMore: TBitBtn;
    procedure BStartClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormActivate(Sender: TObject);
    procedure BViewClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure pmMsgCopyClick(Sender: TObject);
    procedure BMoreClick(Sender: TObject);
  private
    { Private declarations }
    FInProgress,
    FFirstTime,
    FAutoStart: Boolean;
    FTmpXMLElementCollection: TxmlElementCollection;
    FOnGetXMLByFileNameProc: TGetxmlElementByFileNameCallback;
    procedure ListBoxInfoDrawItem(Control: TWinControl;
      Index: Integer; Rect: TRect; State: TOwnerDrawState);
    procedure OnLitMessage(ALevel: TReportLevel; AxmlElement: TxmlElement;
      const ASrc: PWideChar; ASrcLen: Cardinal; AWhere: TPoint; const ADesc: PWideChar;
      var AContinueParse: Boolean; AEnv: Pointer);
    procedure SetAutoStart(AValue: Boolean);
    function DoGetXMLByFileNameProc(const AFileName: String; ADocType: TEditableDoc): TxmlElement;
  protected
    procedure ThreadFinish;
    procedure ThreadStart;
  public
    { Public declarations }
    property OnGetXMLByFileNameProc: TGetxmlElementByFileNameCallback read FOnGetXMLByFileNameProc write FOnGetXMLByFileNameProc;
    property AutoStart: Boolean read FAutoStart write SetAutoStart;
  end;

var
  FormGenerateLIT: TFormGenerateLIT;

implementation

{$R *.dfm}

uses
  EMemos;

procedure TFormGenerateLIT.ThreadFinish;
begin
  FInProgress:= False;
  BStart.Enabled:= True;
  BView.Enabled:= FileExists(LEOutput.Text);
  BMore.Enabled:= BView.Enabled;
  BOK.Enabled:= True;
  // fDockBase.FormDockBase.Finish;
end;

procedure TFormGenerateLIT.ThreadStart;
begin
  FInProgress:= True;
  BStart.Enabled:= False;
  BOK.Enabled:= False;
  BView.Enabled:= False;
  BMore.Enabled:= False; 
  MLines.Clear;
  // fDockBase.FormDockBase.Start;
end;

procedure TFormGenerateLIT.OnLitMessage(ALevel: TReportLevel; AxmlElement: TxmlElement;
  const ASrc: PWideChar; ASrcLen: Cardinal; AWhere: TPoint; const ADesc: PWideChar;
  var AContinueParse: Boolean; AEnv: Pointer);
begin
  case TReportLevel(ALevel) of
  rlFinishThread: begin
       ThreadFinish;
     end;
  end;
  MLines.Items.AddObject(Format('%s: %s', [xmlParse.ReportLevelStr[ALevel], ADesc]), AxmlElement);
  MLines.ItemIndex:= MLines.Items.Count - 1;
  // do not unccoment this to avoid AVE in case no file is opened in editor
  // BUGBUG -- if no file is opened in editor, it cause AVE. I don't have checking why.
//  fDockBase.FormDockBase.AddParseMessage(ALevel, AxmlElement, ASrc, AWhere, ADesc, AContinueParse);
end;

procedure TFormGenerateLIT.SetAutoStart(AValue: Boolean);
begin
  FAutoStart:= AValue;
  CBAutoStart.Checked:= AValue;
end;

procedure TFormGenerateLIT.BStartClick(Sender: TObject);
begin
  ThreadStart;
// use Microsoft xml dom document implementation
  if not Assigned(StartProcessLitThread(LEPackage.Text, LEOutput.Text, DoGetXMLByFileNameProc, OnLitMessage)) then begin  //
    ThreadFinish;
  end;
end;

function TFormGenerateLIT.DoGetXMLByFileNameProc(const AFileName: String; ADocType: TEditableDoc): TxmlElement;
var
  fn: String;
begin
  if Pos('file://', LowerCase(AFileName)) = 1
  then fn:= Copy(AFileName, Length('file://') + 1, MaxInt)
  else fn:= AFileName;

  if Assigned(FOnGetXMLByFileNameProc) then begin
    Result:= FOnGetXMLByFileNameProc(fn, ADocType);
  end else Result:= Nil;
  if Result = Nil then begin
    if Assigned(FTmpXMLElementCollection)
    then FTmpXMLElementCollection.Free;
    FTmpXMLElementCollection:= EMemos.LoadXMLElement(srFile, ADocType, fn, []);
    if Assigned(FTmpXMLElementCollection) and Assigned(FTmpXMLElementCollection.Items[0])
    then Result:= FTmpXMLElementCollection.Items[0]; // else Result:= Nil;
  end;
end;

procedure TFormGenerateLIT.ListBoxInfoDrawItem(Control: TWinControl;
  Index: Integer; Rect: TRect; State: TOwnerDrawState);
var
  Bitmap: TBitmap;      { temporary variable for the item’s bitmap }
  Offset: Integer;      { text offset width }
  e: TxmlElement;
  imgidx: Integer;
  txt: String;
begin
  { draw on control canvas, not on the form }
  txt:=TListBox(Control).Items[Index];
  with TListBox(Control).Canvas do begin
    if odSelected in State then begin
      // use passed values
      TListBox(Control).Hint:= Txt;
    end else begin
      Brush.Color:= clWindow;
      // 'Hint'
      if Pos(ReportLevelStr[rlHint], txt) = 1 then begin
        Font.Color:= clGrayText;
        // Brush.Color:= clWindow; // clInfoBk;
      end;
      if Pos(ReportLevelStr[rlWarning], txt) = 1 // 'Warning'
      then Font.Color:= clWindowText;
      // 'Error:...
      if Pos(ReportLevelStr[rlError], txt) = 1 then begin
        Font.Color:= clBtnText;
        Brush.Color:= clBtnFace;
      end;
      // 'Search'
      if Pos(ReportLevelStr[rlSearch], txt) = 1
      then Font.Color:= clWindowText;
    end;
    FillRect(Rect);       { clear the rectangle }
    Offset:= 2;          { provide default offset }
    e:= TxmlElement((Control as TListBox).Items.Objects[Index]);
    if Assigned(e) then begin
      imgidx:= GetBitmapIndexByClass(TPersistentClass(e.ClassType));
      { get the bitmap }
      {
      if (imgidx > 0) and (imgidx < dm1.ImageList16.Count) then begin
        Bitmap:= TBitmap.Create;
        dm1.ImageList16.GetBitmap(imgIdx, Bitmap);
        if Bitmap <> nil then begin
          BrushCopy(Bounds(Rect.Left + Offset, Rect.Top, Bitmap.Width, Bitmap.Height),
            Bitmap, Bounds(0, 0, Bitmap.Width, Bitmap.Height), clRed);  // render bitmap
          Offset:= Bitmap.Width + 6;    // add four pixels between bitmap and text
        end;
        Bitmap.Free;
      end;
      }
    end;
    TextOut(Rect.Left + Offset, Rect.Top, txt)  { display the text }
  end;
end;

procedure TFormGenerateLIT.FormCreate(Sender: TObject);
begin
  FAutoStart:= False;
  FFirstTime:= True;
  ThreadFinish;
  MLines.OnDrawItem:= ListBoxInfoDrawItem;
  FTmpXMLElementCollection:= Nil;
  FOnGetXMLByFileNameProc:= Nil;
end;

procedure TFormGenerateLIT.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  FAutoStart:= CBAutoStart.Checked;
  CanClose:= not FInProgress;
end;

procedure TFormGenerateLIT.FormActivate(Sender: TObject);
begin
  BStart.SetFocus;  // instead LEOutput
  if FFirstTime then begin
    FFirstTime:= False;
    if FAutoStart
    then BStartClick(Self);
  end;
end;

procedure TFormGenerateLIT.BViewClick(Sender: TObject);
begin
  BView.Enabled:= FileExists(LEOutput.Text);
  if BView.Enabled then begin
    if ShellAPI.ShellExecute(0, 'open', PChar(LEOutput.Text), Nil, Nil, SW_SHOWNORMAL) <= 32 then begin
      ShowMessage('Error: Microsoft reader is not installed.'#13#10);
    end;
  end;
end;

procedure TFormGenerateLIT.FormDestroy(Sender: TObject);
begin
  if Assigned(FTmpXMLElementCollection)
  then FTmpXMLElementCollection.Free;
end;

procedure TFormGenerateLIT.pmMsgCopyClick(Sender: TObject);
begin
  // copy messages
  Clipboard.AsText:= MLines.Items.Text;
end;

procedure TFormGenerateLIT.BMoreClick(Sender: TObject);
begin
  if FileExists(LEOutput.Text) then begin
    DisplayContextMenu(Handle, LEOutput.Text, Point(BMore.Left, BMore.Top + BMore.Height))
  end;
end;

end.


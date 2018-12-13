unit
  fSymbol;
(*##*)
(*******************************************************************************
*                                                                             *
*   f  s  y  m  b  o  l                                                        *
*                                                                             *
*   Copyright © 2001, 2002 Andrei Ivanov. All rights reserved.                 *
*   wireless markup language classes                                          *
*   Conditional defines:                                                       *
*                                                                             *
*   Revisions    : Mar 30 2002                                                 *
*   Last revision: Mar 30 2002                                                *
*   Lines        : 46                                                          *
*   History      :                                                            *
*                                                                              *
*                                                                             *
*   Printed      :                                                             *
*                                                                             *
********************************************************************************)
(*##*)

interface

uses Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls,
  Buttons, ExtCtrls, ComCtrls,
  jclUnicode,
  wmlEditUtil, utilttf;

type
  TFormSpecialSymbol = class(TForm)
    PanelLeft: TPanel;
    PanelBottom: TPanel;
    BOK: TButton;
    BCancel: TButton;
    PanelTop: TPanel;
    LBUnicodeBlock: TListBox;
    Label1: TLabel;
    LVChar: TListView;
    procedure LVCharDblClick(Sender: TObject);
    procedure LBUnicodeBlockClick(Sender: TObject);
    procedure LVCharCustomDrawItem(Sender: TCustomListView;
      Item: TListItem; State: TCustomDrawState; var DefaultDraw: Boolean);
    procedure FormActivate(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    { Private declarations }
    FUsedFontName: String;
    procedure SetUsedFontName(const AFontName: String);
    procedure BuildBlockList;
  public
    { Public declarations }
    function SelectBlock(AIdx: Integer): Boolean;
    property UsedFontName: String read FUsedFontName write SetUsedFontName;
  end;

var
  FormSpecialSymbol: TFormSpecialSymbol;

implementation

{$R *.dfm}

uses
  dm, fDockBase;
{ return unicode range number (0..) in which AChar corresponds to
  in unicode blocks (ranges) - 138 ranges are defined in the Windows

  How to use:
  // get glyph set ranges -
  1. get structure size PGlyphSet (pass null buffer pointer);
  2. alloc memory to buffer
  3. call GetFontUnicodeRanges again and get buffer with all unicode ranges
  GetMem(GlyphSet, GetFontUnicodeRanges(LVChar.Canvas.Handle, Nil));
  GetFontUnicodeRanges(LVChar.Canvas.Handle, GlyphSet);
}

{
function GetCharInRange(AChar: Cardinal; AGlyphSet: PGlyphSet): Integer;
var
  r: Integer;
begin
  Result:= -1;
  for r:= 0 to AGlyphSet^.cRanges - 1 do with AGlyphSet^.ranges[r] do begin
    if (Word(wcLow) >= AChar) and (AChar < Word(wcLow) + cGlyphs) then begin
      Result:= r;
      Exit;
    end;
  end;
end;
}
function IsInUnicodeBlock(ABlock: Byte; const AFontSignature: TFontSignature): Boolean;
type
  TSet128 = set of 0..127;
begin
  Result:= ABlock in TSet128(AFontSignature.fsUsb);
end;

function TFormSpecialSymbol.SelectBlock(AIdx: Integer): Boolean;
begin
  if (AIdx >= 0) and (AIdx < LBUnicodeBlock.Items.Count) then begin
    LBUnicodeBlock.Selected[AIdx]:= True;
    LBUnicodeBlockClick(Self);
    Result:= True;
  end else Result:= False;
end;

procedure TFormSpecialSymbol.BuildBlockList;
var
  i: Integer;
  FontSig: TFontSignature;
begin
  with LVChar.Canvas do begin
    Font.Name:= FUsedFontName;
    Font.Charset:= ANSI_CHARSET;
    GetTextCharsetInfo(Handle, @FontSig, 0);
  end;

  with LBUnicodeBlock.Items do begin
    Clear;
    for i:= Low(utilttf.UnicodeBlockRange) to High(UnicodeBlockRange) do begin
      if IsInUnicodeBlock(UnicodeBlockRange[i].b, FontSig)
      then AddObject(' ' + UnicodeBlockRange[i].Desc, Nil)
      else AddObject(UnicodeBlockRange[i].Desc, Pointer(1));
    end;
    LBUnicodeBlock.Sorted:= True;
  end;
end;

{------------------------- event handlers -------------------------------------}

procedure TFormSpecialSymbol.LVCharDblClick(Sender: TObject);
begin
  BOk.Click;
end;

procedure TFormSpecialSymbol.LBUnicodeBlockClick(Sender: TObject);
var
  i: Integer;
  c0, c1: Cardinal;
  li: TListItem;
begin
  if LBUnicodeBlock.ItemIndex < 0
  then Exit;

  // get unicode block range in c0, c1
  if GetUnicodeRangeByDesc(Trim(LBUnicodeBlock.Items[LBUnicodeBlock.ItemIndex]), c0, c1) then begin
    LVChar.Items.Clear;
    with LVChar.Canvas do begin
      Font.Name:= FUsedFontName;
      Font.Charset:= ANSI_CHARSET;
    end;
    LVChar.Enabled:= False;
    // if (c1 - c0) > 512 then c1:= c0 + 511;
    for i:= c0 to c1 do begin
      if utilTTF.GetTTUnicodeGlyphIndex(LVChar.Canvas.Handle, i) > 0 then begin
        li:= LVChar.Items.Add;
        with li do begin
          Caption:= IntToHex(i, 4);
          ImageIndex:= -1;
        end;
      end;
    end;
    LVChar.Enabled:= True;
  end;
end;

procedure TFormSpecialSymbol.LVCharCustomDrawItem(Sender: TCustomListView;
  Item: TListItem; State: TCustomDrawState; var DefaultDraw: Boolean);
var
  dc: HDC;
  r: TRect;
  w: WideChar;
  l, h: Integer;
begin
  r:= Item.DisplayRect(drIcon);
  Word(w):= StrToIntDef('$' + Item.Caption, 32);

  with Sender.Canvas do begin
    Font.Name:= FUsedFontName;
    Font.Charset:= ANSI_CHARSET;
    Font.Size:= 12;
    Font.Style:= [fsBold];
    l:= TextWidth(w);
    h:= TextHeight(w);
    dc:= Handle;
  end;
  Windows.TextOutW(dc, R.Left + (R.Right - R.Left - l) div 2, R.Top + (R.Bottom - R.Top - h) div 2 - 6, @w, 1);
  with Sender.Canvas do begin
    Font.Size:= 8;
    Font.Style:= [];
  end;
end;

procedure TFormSpecialSymbol.SetUsedFontName(const AFontName: String);
begin
  FUsedFontName:= AFontName;
  BuildBlockList;
end;

procedure TFormSpecialSymbol.FormActivate(Sender: TObject);
begin
  LBUnicodeBlock.SetFocus;
end;

procedure TFormSpecialSymbol.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
const
  pt: TPoint = (x: 0; y: 0);
begin
  case Key of
    VK_F1, VK_HELP: begin
      FormDockBase.ShowHelpByIndex(pt, Nil, 'howtosymbol');
    end;
  end;
end;

end.

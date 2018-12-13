unit browserutil;
(*##*)
(*******************************************************************
*                                                                 *
*   b  r  o  w  s  e  r  u  t  i  l                                *
*                                                                 *
*   Copyright © 2001, 2002 Andrei Ivanov. All rights reserved.     *
*   wireless markup language browser component                    *
*   Conditional defines:                                           *
*                                                                 *
*   Revisions    : Aug 15 2001, Oct 11 2001                        *
*   Last revision: Mar 29 2002                                    *
*   Lines        : 74                                              *
*   History      : see todo file                                  *
*                                                                  *
*                                                                 *
********************************************************************)
(*##*)

interface
uses
  SysUtils, Windows, Graphics, wmlstyle;

function RotateFont(ACanvas: TCanvas; AAngle: Integer): HFont;

function RectInc(ALeftTop: TPoint; ARect: TRect): TRect;

function ValidateStyles(AWMLElementStyles: TWMLElementStyles): Boolean;

implementation

function RotateFont(ACanvas: TCanvas; AAngle: Integer): HFont;
var
  LogFont: TLogFont;
begin
  with LogFont do begin
    lfHeight := ACanvas.Font.Height;
    lfWidth:= 0; { have font mapper choose }
    lfEscapement := AAngle; { only straight fonts }
    lfOrientation := AAngle; { no rotation }
    if fsBold in ACanvas.Font.Style
    then lfWeight := FW_BOLD
    else lfWeight := FW_NORMAL;
    lfItalic := Byte(fsItalic in ACanvas.Font.Style);
    lfUnderline := Byte(fsUnderline in ACanvas.Font.Style);
    lfStrikeOut := Byte(fsStrikeOut in ACanvas.Font.Style);
    lfCharSet := Byte(ACanvas.Font.Charset);
    if CompareText(ACanvas.Font.Name, 'Default') = 0
    then StrPCopy(lfFaceName, DefFontData.Name) // do not localize
    else StrPCopy(lfFaceName, ACanvas.Font.Name);
    lfQuality := DEFAULT_QUALITY;
    { Everything else as default }
    lfOutPrecision:= OUT_DEFAULT_PRECIS;
    lfClipPrecision:= CLIP_DEFAULT_PRECIS;
    case ACanvas.Font.Pitch of
      fpVariable: lfPitchAndFamily := VARIABLE_PITCH;
      fpFixed: lfPitchAndFamily := FIXED_PITCH;
    else lfPitchAndFamily := DEFAULT_PITCH;
    end;
    Result:= CreateFontIndirect(LogFont);
    // hFntPrev:=
    SelectObject(ACanvas.Handle, Result);
  end;
end;

function RectInc(ALeftTop: TPoint; ARect: TRect): TRect;
begin
  with Result do begin
    Left:= ARect.Left + ALeftTop.X;
    Right:= ARect.Right +  ALeftTop.X;
    Top:= ARect.Top +  + ALeftTop.Y;
    Bottom:= ARect.Bottom +  + ALeftTop.Y;
  end;
end;

function ValidateStyles(AWMLElementStyles: TWMLElementStyles): Boolean;
var
  c: Integer;
  sz: TPointNSize;
begin
  Result:= True;
  with AWMLElementStyles do begin
    for c:= 0 to Count - 1 do with Items[c] do begin
      if Size.Height < 5 * Abs(Items[c].Font.Height) div 3
      then begin
        sz:= Size;
        sz.Height:= 5 * Abs(Items[c].Font.Height) div 3;
        Size:= sz;
      end;
    end;
  end;
end;

end.

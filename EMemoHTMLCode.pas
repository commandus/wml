unit
  EMemoHTMLCode;
(*##*)
(*******************************************************************************
*                                                                             *
*   E  M  e  m  o  H  T  M  L  C  o  d  e                                      *
*                                                                             *
*   Copyright © 2001, 2002 Andrei Ivanov. All rights reserved.                 *
*   Part of apooed                                                            *
*   Conditional defines:                                                       *
*                                                                             *
*   Revisions    : Jun 25 2001                                                 *
*   Last revision: Dec  3 2001                                                *
*   Lines        : 327                                                         *
*   History      :                                                            *
*   Based on code of radu@rospotline.com                                       *
*                                                                             *
*   Printed      : ---                                                         *
*                                                                             *
********************************************************************************)
(*##*)

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  EMemo, EMemoCode, customxml;

type
  TEMemoHTMLCode = class(TEMemoCode)
  private
  protected
    procedure ParseLine(ALineNo: Integer; Canvas: TCanvas; ARect: TRect); override;
  public
  published
  end;

implementation

(* TEMemoHTMLCode ************************************************************************)


procedure TEMemoHTMLCode.ParseLine(ALineNo: Integer; Canvas: TCanvas; ARect: TRect);
var
  I, SaveI, x0, len, st, fin: Integer;
  S, SpecTags_S: TGsString;
//  R: TRect;
  Line: WideString;
  hasTags: Boolean;

  procedure RecalcX;
  begin
    ARect.Left:= x0 + FCxMemo.FontWidth * FLastPos;
  end;

begin
  FCharCount := 0;
  FLastPos := 1;
  FStartPos := 0;
  FInTag := True;
  hasTags := False;
  SaveI := 1;
  x0:= ARect.Left;
  Line:= CxMemo.Lines[ALineNo];
  
  // get line width
  len:= Length(Line);
  // set boundary to prevent scan too much
  st:= FCxMemo.ScrollPos_H - FCxMemo.WidthsLen; // set to 1 ?!!
  fin:= FCxMemo.ScrollPos_H + FCxMemo.WidthsLen;  // Length(Line)
  // check left boundary
  if st <= 0
  then st:= 1;
  if fin > len
  then fin:= len;

  for I:= st to fin do begin
    SaveI := I;
    case Line[I] of
      '<': begin
         FInTag := True;
         FInValue := False;
         FFirstTag := True;
         FStartPos := I + 1;
         FCharCount := 0;
         FLastPos := I;
         hasTags := True;
         FTagNotClosed := True;
         Continue;
      end;
      '!': begin
        if FFirstTag and FInTag then FFirstTag := False;
        FCharCount := FCharCount + 1;
      end;
      ' ': if FFirstTag then
      begin
        FFirstTag := False;
        S := Copy(Line, FStartPos, FCharCount);
        if FUseTagHighlight then begin
          if ANSIUpperCase(S) = 'BR' then
          begin
            Canvas.Font.Color := FBRTagForeColor;
            Canvas.Brush.Color := FBRTagBackColor;
          end else
          begin
            Canvas.Font.Color := FTagForeColor;
            Canvas.Brush.Color := FTagBackColor;
          end;
        end else
        begin
          Canvas.Font.Color := FTagForeColor;
          Canvas.Brush.Color := FTagBackColor;
        end;
        RecalcX;
        printcanvasVisible(Canvas.Handle, PWideChar(S), ARect);
        FCharCount := 0;
        FStartPos := I + 1;
        FLastPos := I;
        Canvas.Font.Color := FCxMemo.EnvironmentOptions.TextColor;
        Canvas.Brush.Color := FCxMemo.EnvironmentOptions.TextBackground;
        Continue;
      end else
        if FInTag then FCharCount := FCharCount + 1;
      '"': if FInTag and not FInValue then
      begin
        if FStartPos = 0 then
        begin
          FCharCount := I - 1;
          FLastPos := 0;
        end;
        FInValue := True;
        S := Copy(Line, FStartPos, FCharCount);
        Canvas.Font.Color := FTagPropForeColor;
        Canvas.Brush.Color := FTagPropBackColor;
        RecalcX;
        printcanvasVisible(Canvas.Handle, PWideChar(S), ARect);
        FCharCount := 0;
        FStartPos := I + 1;
        FLastPos := I;
        Canvas.Font.Color := FCxMemo.EnvironmentOptions.TextColor;
        Canvas.Brush.Color := FCxMemo.EnvironmentOptions.TextBackground;
        Continue;
      end else
        if FInTag and FInValue then
        begin
          if FStartPos = 0 then
          begin
            FCharCount := I - 1;
            FLastPos := 0;
          end;
          FInValue := False;
          S := Copy(Line, FStartPos, FCharCount);
          Canvas.Font.Color := FValueForeColor;
          Canvas.Brush.Color := FValueBackColor;
          RecalcX;
          printcanvasVisible(Canvas.Handle, PWideChar(S), ARect);
          FCharCount := 0;
          FStartPos := I + 1;
          FLastPos := I;
          Canvas.Font.Color := FCxMemo.EnvironmentOptions.TextColor;
          Canvas.Brush.Color := FCxMemo.EnvironmentOptions.TextBackground;
          Continue;
        end;
      '>': begin
         FInTag := False;
         FTagNotClosed := False;
         if FStartPos = 0 then begin
           FCharCount := I - 1;
           FLastPos := 0;
         end;
         S := Copy(Line, FStartPos, FCharCount);
         if FFirstTag then begin
           FFirstTag := False;
           if FUseTagHighlight then begin
             if ANSIUpperCase(S) = 'BR' then begin
               Canvas.Font.Color := FBRTagForeColor;
               Canvas.Brush.Color := FBRTagBackColor;
             end else begin
               Canvas.Font.Color := FTagForeColor;
               Canvas.Brush.Color := FTagBackColor;
             end;
           end else begin
             Canvas.Font.Color := FTagForeColor;
             Canvas.Brush.Color := FTagBackColor;
           end;
         end else begin
           Canvas.Font.Color := FTagPropForeColor;
           Canvas.Brush.Color := FTagPropBackColor;
         end;
         RecalcX;
         printcanvasVisible(Canvas.Handle, PWideChar(S), ARect);
         FCharCount := 0;
         FStartPos := I + 1;
         FLastPos := I;
         Canvas.Font.Color := FCxMemo.EnvironmentOptions.TextColor;
         Canvas.Brush.Color := FCxMemo.EnvironmentOptions.TextBackground;
         Continue;
      end else
        if FInTag then FCharCount := FCharCount + 1;
    end;
  end;

  if hasTags or FTagNotClosed then begin
    if FStartPos = 0 then begin
      FCharCount := SaveI - 1;
      FLastPos := 0;
    end;
    S := Copy(Line, FStartPos, FCharCount);
    if FFirstTag then begin
      Canvas.Font.Color := FTagForeColor;
      Canvas.Brush.Color := FTagBackColor;
    end else begin
      Canvas.Font.Color := FTagPropForeColor;
      Canvas.Brush.Color := FTagPropBackColor;
    end;
    RecalcX;
    printcanvasVisible(Canvas.Handle, PWideChar(S), ARect);
    Canvas.Font.Color := FCxMemo.EnvironmentOptions.TextColor;
    Canvas.Brush.Color := FCxMemo.EnvironmentOptions.TextBackground;
  end;
  if FUseEntityHighlight then begin
    Canvas.Font.Color:= FEntityForeColor;
    Canvas.Brush.Color:= FEntityBackColor;
    if emUseBoldTags in FCxMemo.Options
    then Canvas.Font.Style:= [fsBold]
    else Canvas.Font.Style:= [];
    DrawEntities(Line, Canvas);
  end;

  if FUseSpecTagsHighlight then begin
    Canvas.Font.Color := FSpecTagsForeColor;
    Canvas.Brush.Color := FSpecTagsbackColor;
    if emUseBoldTags in FCxMemo.Options
    then Canvas.Font.Style:= [fsBold]
    else Canvas.Font.Style:= [];
{
    DrawSpecialTag('&NBSP;', Line, Canvas);
    DrawSpecialTag('&QUOT;', Line, Canvas);
    DrawSpecialTag('&AMP;', Line, Canvas);
    DrawSpecialTag('&APOS;', Line, Canvas);
    DrawSpecialTag('&LT;', Line, Canvas);
    DrawSpecialTag('&GT;', Line, Canvas);
    DrawSpecialTag('&SHY;', Line, Canvas);
}
  end;

end;

function FindTagBegin(SLine: String; StartPos: Integer): Integer;
var
  I: Integer;
begin
  Result := -1;
  if (StartPos < 1) or (StartPos > Length(SLine)) then Exit;
  for I := StartPos downto 1 do
    if SLine[I] = '<' then
    begin
      Result := I;
      Break;
    end;
end;

function FindTagEnd(SLine: String; StartPos: Integer): Integer;
var
  I: Integer;
begin
  Result := -1;
  if (StartPos < 1) or (StartPos > Length(SLine)) then Exit;
  for I := StartPos to Length(SLine) do
    if SLine[I] = '>' then begin
      Result := I;
      Break;
    end;
end;

end.

unit
  EMemoWMLCode;
(*##*)
(*******************************************************************************
*                                                                             *
*   E  M  e  m  o  W  M  L  C  o  d  e                                         *
*                                                                             *
*   Copyright © 2001, 2002 Andrei Ivanov. All rights reserved.                 *
*   wireless markup language code highlight and code insight                  *
*   Conditional defines:                                                       *
*                                                                             *
*   Revisions    : Jul 06 2001                                                 *
*   Last revision: Dec 08 2001                                                *
*   Lines        : 463                                                         *
*   History      :                                                            *
*   Printed      : ---                                                         *
*                                                                             *
********************************************************************************)
(*##*)

interface
uses
  Classes, Windows, SysUtils, Graphics,
  EMemo, EMemoCode, wml, customxml, xmlsupported;

type
  TEMemoWMLCode = class(TEMemoCode)
  private
    FTagCardDeckForeColor: TColor;
    FTagCardDeckBackColor: TColor;
    FTagEventForeColor: TColor;
    FTagEventBackColor: TColor;
    FTagTaskForeColor: TColor;
    FTagTaskBackColor: TColor;
    FTagVarForeColor: TColor;
    FTagVarBackColor: TColor;
    FTagInputForeColor: TColor;
    FTagInputBackColor: TColor;
    FTagAnchorForeColor: TColor;
    FTagAnchorBackColor: TColor;
    FTagServerSideForeColor: TColor;
    FTagServerSideBackColor: TColor;
    procedure SetTagCardDeckForeColor(AValue: TColor);
    procedure SetTagCardDeckBackColor(AValue: TColor);
    procedure SetTagEventForeColor(AValue: TColor);
    procedure SetTagEventBackColor(AValue: TColor);
    procedure SetTagTaskForeColor(AValue: TColor);
    procedure SetTagTaskBackColor(AValue: TColor);
    procedure SetTagVarForeColor(AValue: TColor);
    procedure SetTagVarBackColor(AValue: TColor);
    procedure SetTagInputForeColor(AValue: TColor);
    procedure SetTagInputBackColor(AValue: TColor);
    procedure SetTagAnchorForeColor(AValue: TColor);
    procedure SetTagAnchorBackColor(AValue: TColor);
    procedure SetServerSideForeColor(Value: TColor);
    procedure SetServerSideBackColor(Value: TColor);

    procedure DrawSpecialTag(const ASpecTag, Line: TGsString; ACanvas: TCanvas);
    procedure SelectTagColor(const ATag: TGsString; ACanvas: TCanvas);
  protected
    procedure ParseLine(ALineNo: Integer; Canvas: TCanvas; ARect: TRect); override;
    function GetClassDescription(var R: TxmlClassDesc): Boolean; override;
  public
    constructor Create(AOwner: TComponent); override;
    procedure SetBackgroundColors(AColor: TColor); override;
    property TagCardDeckForeColor: TColor read FTagCardDeckForeColor write SetTagCardDeckForeColor;
    property TagCardDeckBackColor: TColor read FTagCardDeckBackColor write SetTagCardDeckBackColor;
    property TagEventForeColor: TColor read FTagEventForeColor write SetTagEventForeColor;
    property TagEventBackColor: TColor read FTagEventBackColor write SetTagEventBackColor;
    property TagTaskForeColor: TColor read FTagTaskForeColor write SetTagTaskForeColor;
    property TagTaskBackColor: TColor read FTagTaskBackColor write SetTagTaskBackColor;
    property TagVarForeColor: TColor read FTagVarForeColor write SetTagVarForeColor;
    property TagVarBackColor: TColor read FTagVarBackColor write SetTagVarBackColor;
    property TagInputForeColor: TColor read FTagInputForeColor write SetTagInputForeColor;
    property TagInputBackColor: TColor read FTagInputBackColor write SetTagInputBackColor;
    property TagAnchorForeColor: TColor read FTagAnchorForeColor write SetTagAnchorForeColor;
    property TagAnchorBackColor: TColor read FTagAnchorBackColor write SetTagAnchorBackColor;
    property TagServerSideForeColor: TColor read FTagServerSideForeColor write SetServerSideForeColor;
    property TagServerSideBackColor: TColor read FTagServerSideBackColor write SetServerSideBackColor;
  end;

implementation

constructor TEMemoWMLCode.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FTagCardDeckForeColor:= clRed;
  FTagCardDeckBackColor:= clWhite;
  FTagEventForeColor:= clAqua;
  FTagEventBackColor:= clWhite;

  FTagTaskForeColor:= clTeal;
  FTagTaskBackColor:= clWhite;
  FTagVarForeColor:= clGreen;
  FTagVarBackColor:= clWhite;
  FTagInputForeColor:= clOlive;
  FTagInputBackColor:= clWhite;
  FTagAnchorForeColor:= clBlue;
  FTagAnchorBackColor:= clWhite;
  FTagServerSideForeColor:= clOlive;
  FTagServerSideBackColor:= clWhite;
end;

procedure TEMemoWMLCode.SetTagCardDeckForeColor(AValue: TColor);
begin
  FTagCardDeckForeColor:= AValue;
  if FCodeHighlight and (FCxMemo <> nil) then FCxMemo.Invalidate;
end;

procedure TEMemoWMLCode.SetTagEventForeColor(AValue: TColor);
begin
  FTagEventForeColor:= AValue;
  if FCodeHighlight and (FCxMemo <> nil) then FCxMemo.Invalidate;
end;

procedure TEMemoWMLCode.SetTagEventBackColor(AValue: TColor);
begin
  FTagEventBackColor:= AValue;
  if FCodeHighlight and (FCxMemo <> nil) then FCxMemo.Invalidate;
end;

procedure TEMemoWMLCode.SetTagTaskForeColor(AValue: TColor);
begin
  FTagTaskForeColor:= AValue;
  if FCodeHighlight and (FCxMemo <> nil) then FCxMemo.Invalidate;
end;

procedure TEMemoWMLCode.SetTagTaskBackColor(AValue: TColor);
begin
  FTagTaskBackColor:= AValue;
  if FCodeHighlight and (FCxMemo <> nil) then FCxMemo.Invalidate;
end;

procedure TEMemoWMLCode.SetTagVarForeColor(AValue: TColor);
begin
  FTagVarForeColor:= AValue;
  if FCodeHighlight and (FCxMemo <> nil) then FCxMemo.Invalidate;
end;

procedure TEMemoWMLCode.SetTagVarBackColor(AValue: TColor);
begin
  FTagVarBackColor:= AValue;
  if FCodeHighlight and (FCxMemo <> nil) then FCxMemo.Invalidate;
end;

procedure TEMemoWMLCode.SetTagInputForeColor(AValue: TColor);
begin
  FTagInputForeColor:= AValue;
  if FCodeHighlight and (FCxMemo <> nil) then FCxMemo.Invalidate;
end;

procedure TEMemoWMLCode.SetTagInputBackColor(AValue: TColor);
begin
  FTagInputBackColor:= AValue;
  if FCodeHighlight and (FCxMemo <> nil) then FCxMemo.Invalidate;
end;

procedure TEMemoWMLCode.SetTagAnchorForeColor(AValue: TColor);
begin
  FTagAnchorForeColor:= AValue;
  if FCodeHighlight and (FCxMemo <> nil) then FCxMemo.Invalidate;
end;

procedure TEMemoWMLCode.SetTagAnchorBackColor(AValue: TColor);
begin
  FTagAnchorBackColor:= AValue;
  if FCodeHighlight and (FCxMemo <> nil) then FCxMemo.Invalidate;
end;

procedure TEMemoWMLCode.SetTagCardDeckBackColor(AValue: TColor);
begin
  FTagCardDeckBackColor:= AValue;
  if FCodeHighlight and (FCxMemo <> nil) then FCxMemo.Invalidate;
end;

procedure TEMemoWMLCode.SetServerSideForeColor(Value: TColor);
begin
  FTagServerSideForeColor:= Value;
  if FCodeHighlight and (FCxMemo <> nil) then FCxMemo.Invalidate;
end;

procedure TEMemoWMLCode.SetServerSideBackColor(Value: TColor);
begin
  FTagServerSideBackColor:= Value;
  if FCodeHighlight and (FCxMemo <> nil) then FCxMemo.Invalidate;
end;

procedure TEMemoWMLCode.SelectTagColor(const ATag: TGsString; ACanvas: TCanvas);
var
  Tag: TGsString;
begin
  ACanvas.Font.Color := FTagForeColor;
  ACanvas.Brush.Color := FTagBackColor;

  Tag:= ANSIUppercase(ATag);
  if (Length(Tag) > 0) and (Tag[1] = '/')
  then Delete(Tag, 1, 1);
  // wml card template head access meta
  if (Tag = 'WML') or (Tag = 'CARD') or (Tag = 'TEMPLATE') or (Tag = 'HEAD') or (Tag = 'ACCESS') or (Tag = 'META') then begin
    ACanvas.Font.Color:= FTagCardDeckForeColor;
    ACanvas.Brush.Color:= FTagCardDeckBackColor;
  end;
  // do ontimer onenterforward onenterbackward onpick onevent postfield
  if (Tag = 'DO') or (Tag = 'ONTIMER') or (Tag = 'ONEENTERFORWARD') or (Tag = 'ONEENTERBACKWARD') or (Tag = 'ONPICK') or (Tag = 'ONEVENT') or (Tag = 'POSTFIELD') then begin
    ACanvas.Font.Color:= FTagEventForeColor;
    ACanvas.Brush.Color:= FTagEventBackColor;
  end;
  // go prev refresh noop
  if (Tag = 'GO') or (Tag = 'PREV') or (Tag = 'REFRESH') or (Tag = 'NOOP') then begin
    ACanvas.Font.Color:= FTagTaskForeColor;
    ACanvas.Brush.Color:= FTagTaskBackColor;
  end;
  // setvar
  if (Tag = 'SETVAR') then begin
    ACanvas.Font.Color:= FTagVarForeColor;
    ACanvas.Brush.Color:= FTagVarBackColor;
  end;
  // input select option optgroup fieldset
  if (Tag = 'INPUT') or (Tag = 'SELECT') or (Tag = 'OPTION') or (Tag = 'OPTGROUP') or (Tag = 'FIELDSET') then begin
    ACanvas.Font.Color:= FTagInputForeColor;
    ACanvas.Brush.Color:= FTagInputBackColor;
  end;
  // a anchor img timer
  if (Tag = 'A') or (Tag = 'ANCHOR') or (Tag = 'IMG') or (Tag = 'TIMER') then begin
    ACanvas.Font.Color:= FTagAnchorForeColor;
    ACanvas.Brush.Color:= FTagAnchorBackColor;
  end;
  // br p table tr td
  if (Tag = 'BR') or (Tag = 'P') or (Tag = 'TABLE') or (Tag = 'TR') or (Tag = 'TD') then begin
    ACanvas.Font.Color:= FBRTagForeColor;
    ACanvas.Brush.Color:= FBRTagBackColor;
  end;
  // serverSide
  if (Tag = 'SERVERSIDE') then begin
    ACanvas.Font.Color:= FTagServerSideForeColor;
    ACanvas.Brush.Color:= FTagServerSideBackColor;
  end;
  if emUseBoldTags in FCxMemo.Options
  then ACanvas.Font.Style:= [fsBold]
  else ACanvas.Font.Style:= [];
end;

procedure TEMemoWMLCode.DrawSpecialTag(const ASpecTag, Line: TGsString; ACanvas: TCanvas);
var
  p, SavePos: Integer;
  S, SpecTags_S, spTag: TGsString;
  R: TRect;
begin
  spTag:= ANSIUpperCase(ASpecTag);
  SpecTags_S:= ANSIUpperCase(Line);
  p:= Pos(spTag, SpecTags_S);
  SavePos:= 1;
  while P > 0 do begin
    SavePos:= SavePos + P - 1;
    S:= Copy(Line, SavePos, Length(ASpecTag));
    Delete(SpecTags_S, 1, P + Length(ASpecTag) - 1);
    R := Rect(FCxMemo.FontWidth * (SavePos - 1), 0,
      FCxMemo.FontWidth * (SavePos + 5), FCxMemo.FontHeight);
    printcanvasVisible(ACanvas.Handle, PWideChar(S), R);
    P:= Pos(spTag, SpecTags_S);
    SavePos:= SavePos + Length(spTag);
  end;
end;

function TEMemoWMLCode.GetClassDescription(var R: TxmlClassDesc): Boolean;
begin
  Result:= GetxmlClassDescByClass(TWmlContainer, R);
end;

procedure TEMemoWMLCode.ParseLine(ALineNo: Integer; Canvas: TCanvas; ARect: TRect);
var
  I, SaveI, x0, len, st, fin: Integer;
  S: TGsString;
  hasTags, FInValue, FFirstTag: Boolean;
  Line: WideString;

  procedure RecalcX;
  begin
    ARect.Left:= x0 + FLastPos * FCxMemo.FontWidth;
    printcanvasVisible(Canvas.Handle, PWideChar(S), ARect);
  end;

begin
  FFirstTag:= False;
  FInValue:= False;
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
         FFirstTag:= True;
         FStartPos := I + 1;
         FCharCount := 0;
         FLastPos := I;
         hasTags := True;
         FTagNotClosed := True;
         Continue;
      end;
      '!': begin
        if FFirstTag and FInTag
        then FFirstTag := False;
        FCharCount := FCharCount + 1;
      end;
      ' ', '/':if FFirstTag then begin
            S:= Trim(Copy(Line, FStartPos, FCharCount));
            FFirstTag:= Length(S) = 0;
            if FUseTagHighlight then begin
              SelectTagColor(S, Canvas);
            end else begin
              Canvas.Font.Color := FTagForeColor;
              Canvas.Brush.Color := FTagBackColor;
            end;
            RecalcX;
            if emUseBoldTags in FCxMemo.Options
            then Canvas.Font.Style:= [];
            FCharCount := 0;
            FStartPos := I + 1;
            FLastPos := I;
            Canvas.Font.Color := FCxMemo.EnvironmentOptions.TextColor;
            Canvas.Brush.Color := FCxMemo.EnvironmentOptions.TextBackground;
            Continue;
          end else begin
            if FInTag then FCharCount := FCharCount + 1;
          end;
      '"': if FInTag and not FInValue then
      begin
        if FStartPos = 0 then begin
          FCharCount := I - 1;
          FLastPos := 0;
        end;
        FInValue := True;
        S := Copy(Line, FStartPos, FCharCount);
        Canvas.Font.Color := FTagPropForeColor;
        Canvas.Brush.Color := FTagPropBackColor;
        RecalcX;
        FCharCount := 0;
        FStartPos := I + 1;
        FLastPos := I;
        Canvas.Font.Color := FCxMemo.EnvironmentOptions.TextColor;
        Canvas.Brush.Color := FCxMemo.EnvironmentOptions.TextBackground;
        Continue;
      end else
        if FInTag and FInValue then
        begin
          if FStartPos = 0 then begin
            FCharCount := I - 1;
            FLastPos := 0;
          end;
          FInValue := False;
          S := Copy(Line, FStartPos, FCharCount);
          Canvas.Font.Color := FValueForeColor;
          Canvas.Brush.Color := FValueBackColor;
          RecalcX;
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
         // first tag
         if FFirstTag then begin
           FFirstTag:= False;
           if FUseTagHighlight then begin // wml card template head access meta
             SelectTagColor(S, Canvas);
           end else begin
             Canvas.Font.Color := FTagForeColor;
             Canvas.Brush.Color := FTagBackColor;
           end;
         end else begin
           Canvas.Font.Color := FTagPropForeColor;
           Canvas.Brush.Color := FTagPropBackColor;
         end;
         RecalcX;
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
    Canvas.Font.Color := FCxMemo.EnvironmentOptions.TextColor;
    Canvas.Brush.Color := FCxMemo.EnvironmentOptions.TextBackground;
  end;
  if FUseEntityHighlight then begin
    Canvas.Font.Color := FSpecTagsForeColor;
    Canvas.Brush.Color := FSpecTagsbackColor;
    if emUseBoldTags in FCxMemo.Options
    then Canvas.Font.Style:= [fsBold]
    else Canvas.Font.Style:= [];
    // use entity subset
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

procedure TEMemoWMLCode.SetBackgroundColors(AColor: TColor);
begin
  inherited SetBackgroundColors(AColor);
  FTagCardDeckBackColor:= AColor;
  FTagEventBackColor:= AColor;
  FTagTaskBackColor:= AColor;
  FTagVarBackColor:= AColor;
  FTagInputBackColor:= AColor;
  FTagAnchorBackColor:= AColor;
  FTagServerSideBackColor:= AColor;
  if FCodeHighlight and (FCxMemo <> nil)
  then FCxMemo.Invalidate;
end;

end.

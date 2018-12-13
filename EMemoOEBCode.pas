unit
  EMemoOEBCode;
(*##*)
(*******************************************************************************
*                                                                             *
*   E  M  e  m  o  O  E  B  C  o  d  e                                         *
*                                                                             *
*   Copyright © 2002 Andrei Ivanov. All rights reserved.                       *
*   open eBook source xml code highlight and code insight                     *
*   Conditional defines:                                                       *
*                                                                             *
*   Revisions    : Oct 21 2002                                                 *
*   Last revision: Oct 21 2002                                                *
*   Lines        : 570                                                         *
*   History      :                                                            *
*   Printed      : ---                                                         *
*                                                                             *
********************************************************************************)
(*##*)

interface
uses
  Classes, Windows, SysUtils, Graphics,
  EMemo, EMemoCode, xmlsupported, customxml, oebdoc;

type
  TEMemoOEBCode = class(TEMemoCode)
  private
    FTagHTMLForeColor: TColor;
    FTagHTMLBackColor: TColor;
    FTagCommentForeColor: TColor;
    FTagCommentBackColor: TColor;
    FTagPCDataForeColor: TColor;
    FTagPCDataBackColor: TColor;
    FTagParaForeColor: TColor;
    FTagParaBackColor: TColor;
    FTagBlockForeColor: TColor;
    FTagBlockBackColor: TColor;
    FTagFormattingForeColor: TColor;
    FTagFormattingBackColor: TColor;
    FTagAnchorForeColor: TColor;
    FTagAnchorBackColor: TColor;
    FTagObjectForeColor: TColor;
    FTagObjectBackColor: TColor;
    FTagListForeColor: TColor;
    FTagListBackColor: TColor;
    FTagTableForeColor: TColor;
    FTagTableBackColor: TColor;
    FTagServerSideForeColor: TColor;
    FTagServerSideBackColor: TColor;
    procedure SetTagHTMLForeColor(AValue: TColor);
    procedure SetTagHTMLBackColor(AValue: TColor);
    procedure SetTagCommentForeColor(AValue: TColor);
    procedure SetTagCommentBackColor(AValue: TColor);
    procedure SetTagPCDataForeColor(AValue: TColor);
    procedure SetTagPCDataBackColor(AValue: TColor);
    procedure SetTagParaForeColor(AValue: TColor);
    procedure SetTagParaBackColor(AValue: TColor);
    procedure SetTagBlockForeColor(AValue: TColor);
    procedure SetTagBlockBackColor(AValue: TColor);
    procedure SetTagFormattingForeColor(AValue: TColor);
    procedure SetTagFormattingBackColor(AValue: TColor);
    procedure SetTagAnchorForeColor(AValue: TColor);
    procedure SetTagAnchorBackColor(AValue: TColor);
    procedure SetTagObjectForeColor(AValue: TColor);
    procedure SetTagObjectBackColor(AValue: TColor);
    procedure SetTagListForeColor(AValue: TColor);
    procedure SetTagListBackColor(AValue: TColor);
    procedure SetTagTableForeColor(AValue: TColor);
    procedure SetTagTableBackColor(AValue: TColor);
    procedure SetTagServerSideForeColor(AValue: TColor);
    procedure SetTagServerSideBackColor(AValue: TColor);

    procedure DrawSpecialTag(const ASpecTag, Line: TGsString; ACanvas: TCanvas);
    procedure SelectTagColor(const ATag: TGsString; ACanvas: TCanvas);
  protected
    procedure ParseLine(ALineNo: Integer; Canvas: TCanvas; ARect: TRect); override;
    function GetClassDescription(var R: TxmlClassDesc): Boolean; override;
  public
    constructor Create(AOwner: TComponent); override;
    procedure SetBackgroundColors(AColor: TColor); override;
    property TagHTMLForeColor: TColor read FTagHTMLForeColor write SetTagHTMLForeColor;
    property TagHTMLBackColor: TColor read FTagHTMLBackColor write SetTagHTMLBackColor;
    property TagCommentForeColor: TColor read FTagCommentForeColor write SetTagCommentForeColor;
    property TagCommentBackColor: TColor read FTagCommentBackColor write SetTagCommentBackColor;
    property TagPCDataForeColor: TColor read FTagPCDataForeColor write SetTagPCDataForeColor;
    property TagPCDataBackColor: TColor read FTagPCDataBackColor write SetTagPCDataBackColor;
    property TagParaForeColor: TColor read FTagParaForeColor write SetTagParaForeColor;
    property TagParaBackColor: TColor read FTagParaBackColor write SetTagParaBackColor;
    property TagBlockForeColor: TColor read FTagBlockForeColor write SetTagBlockForeColor;
    property TagBlockBackColor: TColor read FTagBlockBackColor write SetTagBlockBackColor;
    property TagFormattingForeColor: TColor read FTagFormattingForeColor write SetTagFormattingForeColor;
    property TagFormattingBackColor: TColor read FTagFormattingBackColor write SetTagFormattingBackColor;
    property TagAnchorForeColor: TColor read FTagAnchorForeColor write SetTagAnchorForeColor;
    property TagAnchorBackColor: TColor read FTagAnchorBackColor write SetTagAnchorBackColor;
    property TagObjectForeColor: TColor read FTagObjectForeColor write SetTagObjectForeColor;
    property TagObjectBackColor: TColor read FTagObjectBackColor write SetTagObjectBackColor;
    property TagListForeColor: TColor read FTagListForeColor write SetTagListForeColor;
    property TagListBackColor: TColor read FTagListBackColor write SetTagListBackColor;
    property TagTableForeColor: TColor read FTagTableForeColor write SetTagTableForeColor;
    property TagTableBackColor: TColor read FTagTableBackColor write SetTagTableBackColor;
    property TagServerSideForeColor: TColor read FTagServerSideForeColor write SetTagServerSideForeColor;
    property TagServerSideBackColor: TColor read FTagServerSideBackColor write SetTagServerSideBackColor;
  end;

implementation

constructor TEMemoOEBCode.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FTagHTMLForeColor:= clRed;
  FTagHTMLBackColor:= clWhite;
  FTagCommentForeColor:= clAqua;
  FTagCommentBackColor:= clWhite;
  FTagPCDataForeColor:= clTeal;
  FTagPCDataBackColor:= clWhite;
  FTagParaForeColor:= clGreen;
  FTagParaBackColor:= clWhite;
  FTagBlockForeColor:= clOlive;
  FTagBlockBackColor:= clWhite;
  FTagFormattingForeColor:= clBlue;
  FTagFormattingBackColor:= clWhite;
  FTagAnchorForeColor:= clOlive;
  FTagAnchorBackColor:= clWhite;
  FTagObjectForeColor:= clNavy;
  FTagObjectBackColor:= clWhite;
  FTagListForeColor:= clMaroon;
  FTagListBackColor:= clWhite;
  FTagTableForeColor:= clBlack;
  FTagTableBackColor:= clWhite;
  FTagServerSideForeColor:= clDkGray;
  FTagServerSideBackColor:= clWhite;
end;

procedure TEMemoOEBCode.SetTagHTMLForeColor(AValue: TColor);
begin
  FTagHTMLForeColor:= AValue;
  if FCodeHighlight and (FCxMemo <> nil) then FCxMemo.Invalidate;
end;

procedure TEMemoOEBCode.SetTagHTMLBackColor(AValue: TColor);
begin
  FTagHTMLBackColor:= AValue;
  if FCodeHighlight and (FCxMemo <> nil) then FCxMemo.Invalidate;
end;

procedure TEMemoOEBCode.SetTagCommentForeColor(AValue: TColor);
begin
  FTagCommentForeColor:= AValue;
  if FCodeHighlight and (FCxMemo <> nil) then FCxMemo.Invalidate;
end;

procedure TEMemoOEBCode.SetTagCommentBackColor(AValue: TColor);
begin
  FTagCommentBackColor:= AValue;
  if FCodeHighlight and (FCxMemo <> nil) then FCxMemo.Invalidate;
end;

procedure TEMemoOEBCode.SetTagPCDataForeColor(AValue: TColor);
begin
  FTagPCDataForeColor:= AValue;
  if FCodeHighlight and (FCxMemo <> nil) then FCxMemo.Invalidate;
end;

procedure TEMemoOEBCode.SetTagPCDataBackColor(AValue: TColor);
begin
  FTagPCDataBackColor:= AValue;
  if FCodeHighlight and (FCxMemo <> nil) then FCxMemo.Invalidate;
end;

procedure TEMemoOEBCode.SetTagParaForeColor(AValue: TColor);
begin
  FTagParaForeColor:= AValue;
  if FCodeHighlight and (FCxMemo <> nil) then FCxMemo.Invalidate;
end;

procedure TEMemoOEBCode.SetTagParaBackColor(AValue: TColor);
begin
  FTagParaBackColor:= AValue;
  if FCodeHighlight and (FCxMemo <> nil) then FCxMemo.Invalidate;
end;

procedure TEMemoOEBCode.SetTagBlockForeColor(AValue: TColor);
begin
  FTagBlockForeColor:= AValue;
  if FCodeHighlight and (FCxMemo <> nil) then FCxMemo.Invalidate;
end;

procedure TEMemoOEBCode.SetTagBlockBackColor(AValue: TColor);
begin
  FTagBlockBackColor:= AValue;
  if FCodeHighlight and (FCxMemo <> nil) then FCxMemo.Invalidate;
end;

procedure TEMemoOEBCode.SetTagFormattingForeColor(AValue: TColor);
begin
  FTagFormattingForeColor:= AValue;
  if FCodeHighlight and (FCxMemo <> nil) then FCxMemo.Invalidate;
end;

procedure TEMemoOEBCode.SetTagFormattingBackColor(AValue: TColor);
begin
  FTagFormattingBackColor:= AValue;
  if FCodeHighlight and (FCxMemo <> nil) then FCxMemo.Invalidate;
end;

procedure TEMemoOEBCode.SetTagAnchorForeColor(AValue: TColor);
begin
  FTagAnchorForeColor:= AValue;
  if FCodeHighlight and (FCxMemo <> nil) then FCxMemo.Invalidate;
end;

procedure TEMemoOEBCode.SetTagAnchorBackColor(AValue: TColor);
begin
  FTagAnchorBackColor:= AValue;
  if FCodeHighlight and (FCxMemo <> nil) then FCxMemo.Invalidate;
end;

procedure TEMemoOEBCode.SetTagObjectForeColor(AValue: TColor);
begin
  FTagObjectForeColor:= AValue;
  if FCodeHighlight and (FCxMemo <> nil) then FCxMemo.Invalidate;
end;

procedure TEMemoOEBCode.SetTagObjectBackColor(AValue: TColor);
begin
  FTagObjectBackColor:= AValue;
  if FCodeHighlight and (FCxMemo <> nil) then FCxMemo.Invalidate;
end;

procedure TEMemoOEBCode.SetTagListForeColor(AValue: TColor);
begin
  FTagListForeColor:= AValue;
  if FCodeHighlight and (FCxMemo <> nil) then FCxMemo.Invalidate;
end;

procedure TEMemoOEBCode.SetTagListBackColor(AValue: TColor);
begin
  FTagListBackColor:= AValue;
  if FCodeHighlight and (FCxMemo <> nil) then FCxMemo.Invalidate;
end;

procedure TEMemoOEBCode.SetTagTableForeColor(AValue: TColor);
begin
  FTagTableForeColor:= AValue;
  if FCodeHighlight and (FCxMemo <> nil) then FCxMemo.Invalidate;
end;

procedure TEMemoOEBCode.SetTagTableBackColor(AValue: TColor);
begin
  FTagTableBackColor:= AValue;
  if FCodeHighlight and (FCxMemo <> nil) then FCxMemo.Invalidate;
end;

procedure TEMemoOEBCode.SetTagServerSideForeColor(AValue: TColor);
begin
  FTagServerSideForeColor:= AValue;
  if FCodeHighlight and (FCxMemo <> nil) then FCxMemo.Invalidate;
end;

procedure TEMemoOEBCode.SetTagServerSideBackColor(AValue: TColor);
begin
  FTagServerSideBackColor:= AValue;
  if FCodeHighlight and (FCxMemo <> nil) then FCxMemo.Invalidate;
end;

procedure TEMemoOEBCode.SelectTagColor(const ATag: TGsString; ACanvas: TCanvas);
var
  Tag: TGsString;
begin
  ACanvas.Font.Color := FTagForeColor;
  ACanvas.Brush.Color := FTagBackColor;

  Tag:= ANSIUppercase(ATag);
  if (Length(Tag) > 0) and (Tag[1] = '/')
  then Delete(Tag, 1, 1);
  // Container Title Meta Head Body HTML TXMLDesc Base Link Script Style
  if (Tag = 'TITLE') or (Tag = 'META') or (Tag = 'HEAD') or (Tag = 'BODY') or
      (Tag = 'HTML') or (Tag = 'XML') or (Tag = 'BASE') or (Tag = 'LINK') or
      (Tag = 'SCRIPT') or (Tag = 'STYLE') then begin
    ACanvas.Font.Color:= FTagHTMLForeColor;
    ACanvas.Brush.Color:= FTagHTMLBackColor;
  end;
  // comment
  if (Tag = '!--') then begin
    ACanvas.Font.Color:= FTagCommentForeColor;
    ACanvas.Brush.Color:= FTagCommentBackColor;
  end;
  // Br Div P BlockQuote Center
  if (Tag = 'BR') or (Tag = 'DIV') or (Tag = 'P') or (Tag = 'BLOCKQUOTE') or (Tag = 'CENTER') then begin
    ACanvas.Font.Color:= FTagParaForeColor;
    ACanvas.Brush.Color:= FTagParaBackColor;
  end;
  // TT Cite Kbd Samp Dfn Code Pre
  if (Tag = 'TT') or (Tag = 'CITE') or (Tag = 'KBD') or (Tag = 'SAMP') or (Tag = 'DFN') or
      (Tag = 'CODE') or (Tag = 'PRE') then begin
    ACanvas.Font.Color:= FTagBlockForeColor;
    ACanvas.Brush.Color:= FTagBlockBackColor;
  end;
  // Span B Big, Small Sub Sup Font S Strike U Em Q Strong H1 H2 H3 H4 H5 H6
  if (Tag = 'SPAN') or (Tag = 'B') or (Tag = 'BIG') or (Tag = 'SMALL') or (Tag = 'SUB') or
      (Tag = 'SUP') or (Tag = 'FONT') or (Tag = 'S') or (Tag = 'STRIKE') or (Tag = 'U') or
      (Tag = 'EM') or (Tag = 'Q') or (Tag = 'STRONG') or (Tag = 'H1') or (Tag = 'H2') or
      (Tag = 'H3') or (Tag = 'H4') or (Tag = 'H5') or (Tag = 'H6') then begin
    ACanvas.Font.Color:= FTagFormattingForeColor;
    ACanvas.Brush.Color:= FTagFormattingBackColor;
  end;
  // A
  if (Tag = 'A') then begin
    ACanvas.Font.Color:= FTagAnchorForeColor;
    ACanvas.Brush.Color:= FTagAnchorBackColor;
  end;
  // Img HR Var Object Param Map Area
  if (Tag = 'IMG') or (Tag = 'HR') or (Tag = 'VAR') or (Tag = 'OBJECT') or (Tag = 'PARAM') or
      (Tag = 'MAP') or (Tag = 'AREA') then begin
    ACanvas.Font.Color:= FTagObjectForeColor;
    ACanvas.Brush.Color:= FTagObjectBackColor;
  end;
  // Dl Dt Dd Ol Ul Li
  if (Tag = 'DL') or (Tag = 'DT') or (Tag = 'DD') or (Tag = 'OL') or (Tag = 'UL') or (Tag = 'LI') then begin
    ACanvas.Font.Color:= FTagListForeColor;
    ACanvas.Brush.Color:= FTagListBackColor;
  end;
  // Table Caption Tr Th Td
  if (Tag = 'TABLE') or (Tag = 'CAPTION') or (Tag = 'TR') or (Tag = 'TH') or (Tag = 'TD') then begin
    ACanvas.Font.Color:= FTagTableForeColor;
    ACanvas.Brush.Color:= FTagTableBackColor;
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

procedure TEMemoOEBCode.DrawSpecialTag(const ASpecTag, Line: TGsString; ACanvas: TCanvas);
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

function TEMemoOEBCode.GetClassDescription(var R: TxmlClassDesc): Boolean;
begin
  Result:= GetxmlClassDescByClass(TOebContainer, R);
end;

procedure TEMemoOEBCode.ParseLine(ALineNo: Integer; Canvas: TCanvas; ARect: TRect);
var
  I, SaveI, x0, len, st, fin: Integer;
  S, Line: TGsString;
  hasTags, FInValue, FFirstTag: Boolean;


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

{
<!ENTITY quot "&#34;">       <!-- quotation mark -->
<!ENTITY amp  "&#38;#38;">   <!-- ampersand -->
<!ENTITY apos "&#39;">       <!-- apostrophe -->
<!ENTITY lt   "&#38;#60;">   <!-- less than -->
<!ENTITY gt   "&#62;">       <!-- greater than -->
<!ENTITY nbsp "&#160;">      <!-- non-breaking space -->
<!ENTITY shy  "&#173;">      <!-- soft hyphen (discretionary hyphen) -->
}
  end;
end;

procedure TEMemoOEBCode.SetBackgroundColors(AColor: TColor);
begin
  inherited SetBackgroundColors(AColor);
  FTagHTMLBackColor:= AColor;
  FTagCommentBackColor:= AColor;
  FTagPCDataBackColor:= AColor;
  FTagParaBackColor:= AColor;
  FTagBlockBackColor:= AColor;
  FTagFormattingBackColor:= AColor;
  FTagAnchorBackColor:= AColor;
  FTagObjectBackColor:= AColor;
  FTagListBackColor:= AColor;
  FTagTableBackColor:= AColor;
  FTagServerSideBackColor:= AColor;
  if FCodeHighlight and (FCxMemo <> nil)
  then FCxMemo.Invalidate;
end;

end.

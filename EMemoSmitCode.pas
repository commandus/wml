unit
  EMemoSmitCode;
(*##*)
(*******************************************************************************
*                                                                             *
*   E  M  e  m  o  S  M  I  T  C  O  D  E                                      *
*                                                                             *
*   Copyright © 2003 Andrei Ivanov. All rights reserved.                       *
*   SMIT elements xml code highlight and code insight                         *
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
  EMemo, EMemoCode, xmlsupported, customxml, smit;
{
    1 TTxnContainer, ToebPackage, TXMLDesc, TPkgDesc,
    2 TPkgMetaData
    3 TPkgManifest, TPkgItem,
    4 TPkgSpine, TPkgItemRef,
    5 TPkgTours, TPkgTour, TPkgSite, TPkgGuide, TPkgReference,
    6 TPkgXMetadata, TPkgMeta,
    7 TPkgDCMetadata,
       TPkgdcTitle, TPkgdcIdentifier, TPkgdcContributor, TPkgdcCreator, TPkgdcSubject,
       TPkgdcDescription, TPkgdcPublisher, TPkgdcDate, TPkgdcType, TPkgdcFormat,
       TPkgdcSource, TPkgdcLanguage, TPkgdcRelation, TPkgdcCoverage, TPkgdcRights,

    8 TPkgPCData,
    9 TxmlComment
   10 TPkgServerSide
}

type
  TEMemoSMITCode = class(TEMemoCode)
  private
    FTagContainerForeColor: TColor;
    FTagContainerBackColor: TColor;
    FTagCMD2ForeColor: TColor;
    FTagCMD2BackColor: TColor;
    FTagMenuForeColor: TColor;
    FTagMenuBackColor: TColor;
    FTagSelectorForeColor: TColor;
    FTagSelectorBackColor: TColor;
    FTagDialogForeColor: TColor;
    FTagDialogBackColor: TColor;
    FTagCMDForeColor: TColor;
    FTagCMDBackColor: TColor;
    FTagHELPForeColor: TColor;
    FTagHELPBackColor: TColor;

    FTagPCDataForeColor: TColor;
    FTagPCDataBackColor: TColor;
    FTagCommentForeColor: TColor;
    FTagCommentBackColor: TColor;
    FTagServerSideForeColor: TColor;
    FTagServerSideBackColor: TColor;
    procedure SetTagContainerForeColor(AValue: TColor);
    procedure SetTagContainerBackColor(AValue: TColor);
    procedure SetTagCommentForeColor(AValue: TColor);
    procedure SetTagCommentBackColor(AValue: TColor);
    procedure SetTagPCDataForeColor(AValue: TColor);
    procedure SetTagPCDataBackColor(AValue: TColor);
    procedure SetTagMenuForeColor(AValue: TColor);
    procedure SetTagMenuBackColor(AValue: TColor);
    procedure SetTagSelectorForeColor(AValue: TColor);
    procedure SetTagSelectorBackColor(AValue: TColor);
    procedure SetTagDialogForeColor(AValue: TColor);
    procedure SetTagDialogBackColor(AValue: TColor);
    procedure SetTagCMDForeColor(AValue: TColor);
    procedure SetTagCMDBackColor(AValue: TColor);
    procedure SetTagHelpForeColor(AValue: TColor);
    procedure SetTagHelpBackColor(AValue: TColor);
    procedure SetTagCmd2ForeColor(AValue: TColor);
    procedure SetTagCmd2BackColor(AValue: TColor);
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
    property TagContainerForeColor: TColor read FTagContainerForeColor write SetTagContainerForeColor;
    property TagContainerBackColor: TColor read FTagContainerBackColor write SetTagContainerBackColor;
    property TagCommentForeColor: TColor read FTagCommentForeColor write SetTagCommentForeColor;
    property TagCommentBackColor: TColor read FTagCommentBackColor write SetTagCommentBackColor;
    property TagPCDataForeColor: TColor read FTagPCDataForeColor write SetTagPCDataForeColor;
    property TagPCDataBackColor: TColor read FTagPCDataBackColor write SetTagPCDataBackColor;
    property TagMenuForeColor: TColor read FTagMenuForeColor write SetTagMenuForeColor;
    property TagMenuBackColor: TColor read FTagMenuBackColor write SetTagMenuBackColor;
    property TagSelectorForeColor: TColor read FTagSelectorForeColor write SetTagSelectorForeColor;
    property TagSelectorBackColor: TColor read FTagSelectorBackColor write SetTagSelectorBackColor;
    property TagDialogForeColor: TColor read FTagDialogForeColor write SetTagDialogForeColor;
    property TagDialogBackColor: TColor read FTagDialogBackColor write SetTagDialogBackColor;
    property TagCMDForeColor: TColor read FTagCMDForeColor write SetTagCMDForeColor;
    property TagCMDBackColor: TColor read FTagCMDBackColor write SetTagCMDBackColor;
    property TagHelpForeColor: TColor read FTagHELPForeColor write SetTagHelpForeColor;
    property TagHelpBackColor: TColor read FTagHELPBackColor write SetTagHelpBackColor;
    property TagCmd2ForeColor: TColor read FTagCMD2ForeColor write SetTagCmd2ForeColor;
    property TagCmd2BackColor: TColor read FTagCMD2BackColor write SetTagCmd2BackColor;
    property TagServerSideForeColor: TColor read FTagServerSideForeColor write SetTagServerSideForeColor;
    property TagServerSideBackColor: TColor read FTagServerSideBackColor write SetTagServerSideBackColor;
  end;

implementation

constructor TEMemoSMITCode.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FTagContainerForeColor:= clRed;
  FTagContainerBackColor:= clWhite;
  FTagCommentForeColor:= clAqua;
  FTagCommentBackColor:= clWhite;
  FTagPCDataForeColor:= clTeal;
  FTagPCDataBackColor:= clWhite;
  FTagMenuForeColor:= clGreen;
  FTagMenuBackColor:= clWhite;
  FTagSelectorForeColor:= clOlive;
  FTagSelectorBackColor:= clWhite;
  FTagDialogForeColor:= clBlue;
  FTagDialogBackColor:= clWhite;
  FTagCMDForeColor:= clOlive;
  FTagCMDBackColor:= clWhite;
  FTagHELPForeColor:= clNavy;
  FTagHELPBackColor:= clWhite;
  FTagCMD2ForeColor:= clBlack;
  FTagCMD2BackColor:= clWhite;
  FTagServerSideForeColor:= clDkGray;
  FTagServerSideBackColor:= clWhite;
end;

procedure TEMemoSMITCode.SetTagContainerForeColor(AValue: TColor);
begin
  FTagContainerForeColor:= AValue;
  if FCodeHighlight and (FCxMemo <> nil) then FCxMemo.Invalidate;
end;

procedure TEMemoSMITCode.SetTagContainerBackColor(AValue: TColor);
begin
  FTagContainerBackColor:= AValue;
  if FCodeHighlight and (FCxMemo <> nil) then FCxMemo.Invalidate;
end;

procedure TEMemoSMITCode.SetTagCommentForeColor(AValue: TColor);
begin
  FTagCommentForeColor:= AValue;
  if FCodeHighlight and (FCxMemo <> nil) then FCxMemo.Invalidate;
end;

procedure TEMemoSMITCode.SetTagCommentBackColor(AValue: TColor);
begin
  FTagCommentBackColor:= AValue;
  if FCodeHighlight and (FCxMemo <> nil) then FCxMemo.Invalidate;
end;

procedure TEMemoSMITCode.SetTagPCDataForeColor(AValue: TColor);
begin
  FTagPCDataForeColor:= AValue;
  if FCodeHighlight and (FCxMemo <> nil) then FCxMemo.Invalidate;
end;

procedure TEMemoSMITCode.SetTagPCDataBackColor(AValue: TColor);
begin
  FTagPCDataBackColor:= AValue;
  if FCodeHighlight and (FCxMemo <> nil) then FCxMemo.Invalidate;
end;

procedure TEMemoSMITCode.SetTagMenuForeColor(AValue: TColor);
begin
  FTagMenuForeColor:= AValue;
  if FCodeHighlight and (FCxMemo <> nil) then FCxMemo.Invalidate;
end;

procedure TEMemoSMITCode.SetTagMenuBackColor(AValue: TColor);
begin
  FTagMenuBackColor:= AValue;
  if FCodeHighlight and (FCxMemo <> nil) then FCxMemo.Invalidate;
end;

procedure TEMemoSMITCode.SetTagSelectorForeColor(AValue: TColor);
begin
  FTagSelectorForeColor:= AValue;
  if FCodeHighlight and (FCxMemo <> nil) then FCxMemo.Invalidate;
end;

procedure TEMemoSMITCode.SetTagSelectorBackColor(AValue: TColor);
begin
  FTagSelectorBackColor:= AValue;
  if FCodeHighlight and (FCxMemo <> nil) then FCxMemo.Invalidate;
end;

procedure TEMemoSMITCode.SetTagDialogForeColor(AValue: TColor);
begin
  FTagDialogForeColor:= AValue;
  if FCodeHighlight and (FCxMemo <> nil) then FCxMemo.Invalidate;
end;

procedure TEMemoSMITCode.SetTagDialogBackColor(AValue: TColor);
begin
  FTagDialogBackColor:= AValue;
  if FCodeHighlight and (FCxMemo <> nil) then FCxMemo.Invalidate;
end;

procedure TEMemoSMITCode.SetTagCMDForeColor(AValue: TColor);
begin
  FTagCMDForeColor:= AValue;
  if FCodeHighlight and (FCxMemo <> nil) then FCxMemo.Invalidate;
end;

procedure TEMemoSMITCode.SetTagCMDBackColor(AValue: TColor);
begin
  FTagCMDBackColor:= AValue;
  if FCodeHighlight and (FCxMemo <> nil) then FCxMemo.Invalidate;
end;

procedure TEMemoSMITCode.SetTagHelpForeColor(AValue: TColor);
begin
  FTagHELPForeColor:= AValue;
  if FCodeHighlight and (FCxMemo <> nil) then FCxMemo.Invalidate;
end;

procedure TEMemoSMITCode.SetTagHelpBackColor(AValue: TColor);
begin
  FTagHELPBackColor:= AValue;
  if FCodeHighlight and (FCxMemo <> nil) then FCxMemo.Invalidate;
end;

procedure TEMemoSMITCode.SetTagCmd2ForeColor(AValue: TColor);
begin
  FTagCMD2ForeColor:= AValue;
  if FCodeHighlight and (FCxMemo <> nil) then FCxMemo.Invalidate;
end;

procedure TEMemoSMITCode.SetTagCmd2BackColor(AValue: TColor);
begin
  FTagCMD2BackColor:= AValue;
  if FCodeHighlight and (FCxMemo <> nil) then FCxMemo.Invalidate;
end;

procedure TEMemoSMITCode.SetTagServerSideForeColor(AValue: TColor);
begin
  FTagServerSideForeColor:= AValue;
  if FCodeHighlight and (FCxMemo <> nil) then FCxMemo.Invalidate;
end;

procedure TEMemoSMITCode.SetTagServerSideBackColor(AValue: TColor);
begin
  FTagServerSideBackColor:= AValue;
  if FCodeHighlight and (FCxMemo <> nil) then FCxMemo.Invalidate;
end;

procedure TEMemoSMITCode.SelectTagColor(const ATag: TGsString; ACanvas: TCanvas);
var
  Tag: TGsString;
begin
  ACanvas.Font.Color:= FTagForeColor;
  ACanvas.Brush.Color:= FTagBackColor;

  Tag:= ANSIUppercase(ATag);
  if (Length(Tag) > 0) and (Tag[1] = '/')
  then Delete(Tag, 1, 1);
  // TTxnContainer, ToebPackage, TXMLDesc, TPkgDesc }
  if (Tag = '!DOCTYPE') or (Tag = '?XML') then begin
    ACanvas.Font.Color:= FTagContainerForeColor;
    ACanvas.Brush.Color:= FTagContainerBackColor;
  end;
  // TxmlComment
  if (Tag = '!--') then begin
    ACanvas.Font.Color:= FTagCommentForeColor;
    ACanvas.Brush.Color:= FTagCommentBackColor;
  end;
  //
  if (Tag = 'MENU') then begin
    ACanvas.Font.Color:= FTagMenuForeColor;
    ACanvas.Brush.Color:= FTagMenuBackColor;
  end;
  //
  if (Tag = 'SELECTOR') then begin
    ACanvas.Font.Color:= FTagSelectorForeColor;
    ACanvas.Brush.Color:= FTagSelectorBackColor;
  end;
  //
  if (Tag = 'DIALOG') then begin
    ACanvas.Font.Color:= FTagDialogForeColor;
    ACanvas.Brush.Color:= FTagDialogBackColor;
  end;
  //
  if (Tag = 'CMD') then begin
    ACanvas.Font.Color:= FTagCMDForeColor;
    ACanvas.Brush.Color:= FTagCMDBackColor;
  end;
  //
  if (Tag = 'HELP')
  then begin
    ACanvas.Font.Color:= FTagHELPForeColor;
    ACanvas.Brush.Color:= FTagHELPBackColor;
  end;
  //
  if (Pos('CMD_TO_', Tag) = 1) then begin
    ACanvas.Font.Color:= FTagCMD2ForeColor;
    ACanvas.Brush.Color:= FTagCMD2BackColor;
  end;
  // TPkgServerSide
  if (Tag = 'SERVERSIDE') then begin
    ACanvas.Font.Color:= FTagServerSideForeColor;
    ACanvas.Brush.Color:= FTagServerSideBackColor;
  end;
  if emUseBoldTags in FCxMemo.Options
  then ACanvas.Font.Style:= [fsBold]
  else ACanvas.Font.Style:= [];end;

procedure TEMemoSMITCode.DrawSpecialTag(const ASpecTag, Line: TGsString; ACanvas: TCanvas);
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

function TEMemoSMITCode.GetClassDescription(var R: TxmlClassDesc): Boolean;
begin
  Result:= GetxmlClassDescByClass(TSmtContainer, R);
end;

procedure TEMemoSMITCode.ParseLine(ALineNo: Integer; Canvas: TCanvas; ARect: TRect);
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

procedure TEMemoSMITCode.SetBackgroundColors(AColor: TColor);
begin
  inherited SetBackgroundColors(AColor);
  FTagContainerBackColor:= AColor;
  FTagCommentBackColor:= AColor;
  FTagPCDataBackColor:= AColor;
  FTagMenuBackColor:= AColor;
  FTagSelectorBackColor:= AColor;
  FTagDialogBackColor:= AColor;
  FTagCMDBackColor:= AColor;
  FTagHELPBackColor:= AColor;
  FTagCMD2BackColor:= AColor;
  FTagServerSideBackColor:= AColor;
  if FCodeHighlight and (FCxMemo <> nil)
  then FCxMemo.Invalidate;
end;

end.

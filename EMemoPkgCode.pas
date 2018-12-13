unit
  EMemoPkgCode;
(*##*)
(*******************************************************************************
*                                                                             *
*   E  M  e  m  o  P  K  G  C  o  d  e                                         *
*                                                                             *
*   Copyright © 2002 Andrei Ivanov. All rights reserved.                       *
*   open eBook package xml code highlight and code insight                    *
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
  EMemo, EMemoCode, xmlsupported, customxml, oebpkg;
{
    1 TPkgContainer, ToebPackage, TXMLDesc, TPkgDesc,
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
  TEMemoPkgCode = class(TEMemoCode)
  private
    FTagPackageForeColor: TColor;
    FTagPackageBackColor: TColor;
    FTagMetadataForeColor: TColor;
    FTagMetadataBackColor: TColor;
    FTagManifestForeColor: TColor;
    FTagManifestBackColor: TColor;
    FTagSpineForeColor: TColor;
    FTagSpineBackColor: TColor;
    FTagToursForeColor: TColor;
    FTagToursBackColor: TColor;
    FTagXMetadataForeColor: TColor;
    FTagXMetadataBackColor: TColor;
    FTagDCMetadataForeColor: TColor;
    FTagDCMetadataBackColor: TColor;

    FTagPCDataForeColor: TColor;
    FTagPCDataBackColor: TColor;
    FTagCommentForeColor: TColor;
    FTagCommentBackColor: TColor;
    FTagServerSideForeColor: TColor;
    FTagServerSideBackColor: TColor;
    procedure SetTagPackageForeColor(AValue: TColor);
    procedure SetTagPackageBackColor(AValue: TColor);
    procedure SetTagCommentForeColor(AValue: TColor);
    procedure SetTagCommentBackColor(AValue: TColor);
    procedure SetTagPCDataForeColor(AValue: TColor);
    procedure SetTagPCDataBackColor(AValue: TColor);
    procedure SetTagManifestForeColor(AValue: TColor);
    procedure SetTagManifestBackColor(AValue: TColor);
    procedure SetTagSpineForeColor(AValue: TColor);
    procedure SetTagSpineBackColor(AValue: TColor);
    procedure SetTagToursForeColor(AValue: TColor);
    procedure SetTagToursBackColor(AValue: TColor);
    procedure SetTagXMetadataForeColor(AValue: TColor);
    procedure SetTagXMetadataBackColor(AValue: TColor);
    procedure SetTagDCMetadataForeColor(AValue: TColor);
    procedure SetTagDCMetadataBackColor(AValue: TColor);
    procedure SetTagMetadataForeColor(AValue: TColor);
    procedure SetTagMetadataBackColor(AValue: TColor);
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
    property TagPackageForeColor: TColor read FTagPackageForeColor write SetTagPackageForeColor;
    property TagPackageBackColor: TColor read FTagPackageBackColor write SetTagPackageBackColor;
    property TagCommentForeColor: TColor read FTagCommentForeColor write SetTagCommentForeColor;
    property TagCommentBackColor: TColor read FTagCommentBackColor write SetTagCommentBackColor;
    property TagPCDataForeColor: TColor read FTagPCDataForeColor write SetTagPCDataForeColor;
    property TagPCDataBackColor: TColor read FTagPCDataBackColor write SetTagPCDataBackColor;
    property TagManifestForeColor: TColor read FTagManifestForeColor write SetTagManifestForeColor;
    property TagManifestBackColor: TColor read FTagManifestBackColor write SetTagManifestBackColor;
    property TagSpineForeColor: TColor read FTagSpineForeColor write SetTagSpineForeColor;
    property TagSpineBackColor: TColor read FTagSpineBackColor write SetTagSpineBackColor;
    property TagToursForeColor: TColor read FTagToursForeColor write SetTagToursForeColor;
    property TagToursBackColor: TColor read FTagToursBackColor write SetTagToursBackColor;
    property TagXMetadataForeColor: TColor read FTagXMetadataForeColor write SetTagXMetadataForeColor;
    property TagXMetadataBackColor: TColor read FTagXMetadataBackColor write SetTagXMetadataBackColor;
    property TagDCMetadataForeColor: TColor read FTagDCMetadataForeColor write SetTagDCMetadataForeColor;
    property TagDCMetadataBackColor: TColor read FTagDCMetadataBackColor write SetTagDCMetadataBackColor;
    property TagMetadataForeColor: TColor read FTagMetadataForeColor write SetTagMetadataForeColor;
    property TagMetadataBackColor: TColor read FTagMetadataBackColor write SetTagMetadataBackColor;
    property TagServerSideForeColor: TColor read FTagServerSideForeColor write SetTagServerSideForeColor;
    property TagServerSideBackColor: TColor read FTagServerSideBackColor write SetTagServerSideBackColor;
  end;

implementation

constructor TEMemoPkgCode.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FTagPackageForeColor:= clRed;
  FTagPackageBackColor:= clWhite;
  FTagCommentForeColor:= clAqua;
  FTagCommentBackColor:= clWhite;
  FTagPCDataForeColor:= clTeal;
  FTagPCDataBackColor:= clWhite;
  FTagManifestForeColor:= clGreen;
  FTagManifestBackColor:= clWhite;
  FTagSpineForeColor:= clOlive;
  FTagSpineBackColor:= clWhite;
  FTagToursForeColor:= clBlue;
  FTagToursBackColor:= clWhite;
  FTagXMetadataForeColor:= clOlive;
  FTagXMetadataBackColor:= clWhite;
  FTagDCMetadataForeColor:= clNavy;
  FTagDCMetadataBackColor:= clWhite;
  FTagMetadataForeColor:= clBlack;
  FTagMetadataBackColor:= clWhite;
  FTagServerSideForeColor:= clDkGray;
  FTagServerSideBackColor:= clWhite;
end;

procedure TEMemoPkgCode.SetTagPackageForeColor(AValue: TColor);
begin
  FTagPackageForeColor:= AValue;
  if FCodeHighlight and (FCxMemo <> nil) then FCxMemo.Invalidate;
end;

procedure TEMemoPkgCode.SetTagPackageBackColor(AValue: TColor);
begin
  FTagPackageBackColor:= AValue;
  if FCodeHighlight and (FCxMemo <> nil) then FCxMemo.Invalidate;
end;

procedure TEMemoPkgCode.SetTagCommentForeColor(AValue: TColor);
begin
  FTagCommentForeColor:= AValue;
  if FCodeHighlight and (FCxMemo <> nil) then FCxMemo.Invalidate;
end;

procedure TEMemoPkgCode.SetTagCommentBackColor(AValue: TColor);
begin
  FTagCommentBackColor:= AValue;
  if FCodeHighlight and (FCxMemo <> nil) then FCxMemo.Invalidate;
end;

procedure TEMemoPkgCode.SetTagPCDataForeColor(AValue: TColor);
begin
  FTagPCDataForeColor:= AValue;
  if FCodeHighlight and (FCxMemo <> nil) then FCxMemo.Invalidate;
end;

procedure TEMemoPkgCode.SetTagPCDataBackColor(AValue: TColor);
begin
  FTagPCDataBackColor:= AValue;
  if FCodeHighlight and (FCxMemo <> nil) then FCxMemo.Invalidate;
end;

procedure TEMemoPkgCode.SetTagManifestForeColor(AValue: TColor);
begin
  FTagManifestForeColor:= AValue;
  if FCodeHighlight and (FCxMemo <> nil) then FCxMemo.Invalidate;
end;

procedure TEMemoPkgCode.SetTagManifestBackColor(AValue: TColor);
begin
  FTagManifestBackColor:= AValue;
  if FCodeHighlight and (FCxMemo <> nil) then FCxMemo.Invalidate;
end;

procedure TEMemoPkgCode.SetTagSpineForeColor(AValue: TColor);
begin
  FTagSpineForeColor:= AValue;
  if FCodeHighlight and (FCxMemo <> nil) then FCxMemo.Invalidate;
end;

procedure TEMemoPkgCode.SetTagSpineBackColor(AValue: TColor);
begin
  FTagSpineBackColor:= AValue;
  if FCodeHighlight and (FCxMemo <> nil) then FCxMemo.Invalidate;
end;

procedure TEMemoPkgCode.SetTagToursForeColor(AValue: TColor);
begin
  FTagToursForeColor:= AValue;
  if FCodeHighlight and (FCxMemo <> nil) then FCxMemo.Invalidate;
end;

procedure TEMemoPkgCode.SetTagToursBackColor(AValue: TColor);
begin
  FTagToursBackColor:= AValue;
  if FCodeHighlight and (FCxMemo <> nil) then FCxMemo.Invalidate;
end;

procedure TEMemoPkgCode.SetTagXMetadataForeColor(AValue: TColor);
begin
  FTagXMetadataForeColor:= AValue;
  if FCodeHighlight and (FCxMemo <> nil) then FCxMemo.Invalidate;
end;

procedure TEMemoPkgCode.SetTagXMetadataBackColor(AValue: TColor);
begin
  FTagXMetadataBackColor:= AValue;
  if FCodeHighlight and (FCxMemo <> nil) then FCxMemo.Invalidate;
end;

procedure TEMemoPkgCode.SetTagDCMetadataForeColor(AValue: TColor);
begin
  FTagDCMetadataForeColor:= AValue;
  if FCodeHighlight and (FCxMemo <> nil) then FCxMemo.Invalidate;
end;

procedure TEMemoPkgCode.SetTagDCMetadataBackColor(AValue: TColor);
begin
  FTagDCMetadataBackColor:= AValue;
  if FCodeHighlight and (FCxMemo <> nil) then FCxMemo.Invalidate;
end;

procedure TEMemoPkgCode.SetTagMetadataForeColor(AValue: TColor);
begin
  FTagMetadataForeColor:= AValue;
  if FCodeHighlight and (FCxMemo <> nil) then FCxMemo.Invalidate;
end;

procedure TEMemoPkgCode.SetTagMetadataBackColor(AValue: TColor);
begin
  FTagMetadataBackColor:= AValue;
  if FCodeHighlight and (FCxMemo <> nil) then FCxMemo.Invalidate;
end;

procedure TEMemoPkgCode.SetTagServerSideForeColor(AValue: TColor);
begin
  FTagServerSideForeColor:= AValue;
  if FCodeHighlight and (FCxMemo <> nil) then FCxMemo.Invalidate;
end;

procedure TEMemoPkgCode.SetTagServerSideBackColor(AValue: TColor);
begin
  FTagServerSideBackColor:= AValue;
  if FCodeHighlight and (FCxMemo <> nil) then FCxMemo.Invalidate;
end;

procedure TEMemoPkgCode.SelectTagColor(const ATag: TGsString; ACanvas: TCanvas);
var
  Tag: TGsString;
begin
  ACanvas.Font.Color:= FTagForeColor;
  ACanvas.Brush.Color:= FTagBackColor;

  Tag:= ANSIUppercase(ATag);
  if (Length(Tag) > 0) and (Tag[1] = '/')
  then Delete(Tag, 1, 1);
  // TPkgContainer, ToebPackage, TXMLDesc, TPkgDesc }
  if (Tag = 'PACKAGE') or (Tag = '!DOCTYPE') or (Tag = '?XML') then begin
    ACanvas.Font.Color:= FTagPackageForeColor;
    ACanvas.Brush.Color:= FTagPackageBackColor;
  end;
  // TxmlComment
  if (Tag = '!--') then begin
    ACanvas.Font.Color:= FTagCommentForeColor;
    ACanvas.Brush.Color:= FTagCommentBackColor;
  end;
  // TPkgManifest, TPkgItem,
  if (Tag = 'MANIFEST') or (Tag = 'ITEM') then begin
    ACanvas.Font.Color:= FTagManifestForeColor;
    ACanvas.Brush.Color:= FTagManifestBackColor;
  end;
  // TPkgSpine, TPkgItemRef,
  if (Tag = 'SPINE') or (Tag = 'ITEMREF') then begin
    ACanvas.Font.Color:= FTagSpineForeColor;
    ACanvas.Brush.Color:= FTagSpineBackColor;
  end;
  // TPkgTours, TPkgTour, TPkgSite, TPkgGuide, TPkgReference,
  if (Tag = 'TOURS') or (Tag = 'TOUR') or (Tag = 'SITE') or (Tag = 'GUIDE') or (Tag = 'REFERENCE') then begin
    ACanvas.Font.Color:= FTagToursForeColor;
    ACanvas.Brush.Color:= FTagToursBackColor;
  end;
  // TPkgXMetadata, TPkgMeta,
  if (Tag = 'X-METADATA') or (Tag = 'META') then begin
    ACanvas.Font.Color:= FTagXMetadataForeColor;
    ACanvas.Brush.Color:= FTagXMetadataBackColor;
  end;
  // TPkgDCMetadata,
  //   TPkgdcTitle, TPkgdcIdentifier, TPkgdcContributor, TPkgdcCreator, TPkgdcSubject,
  //   TPkgdcDescription, TPkgdcPublisher, TPkgdcDate, TPkgdcType, TPkgdcFormat,
  //   TPkgdcSource, TPkgdcLanguage, TPkgdcRelation, TPkgdcCoverage, TPkgdcRights,
  if (Tag = 'DC-METADATA') or (Tag = 'DC:TITLE') or (Tag = 'DC:IDENTIFIER') or (Tag = 'DC:CONTRIBUTOR') or
     (Tag = 'DC:CREATOR') or (Tag = 'DC:SUBJECT') or (Tag = 'DC:DESCRIPTION') or (Tag = 'DC:PUBLISHER') or
      (Tag = 'DC:DATE') or (Tag = 'DC:TYPE') or (Tag = 'DC:FORMAT') or (Tag = 'DC:SOURCE') or
      (Tag = 'DC:LANGUAGE') or (Tag = 'DC:RELATION') or (Tag = 'DC:COVERAGE') or (Tag = 'DC:RIGHTS')
    then begin
    ACanvas.Font.Color:= FTagDCMetadataForeColor;
    ACanvas.Brush.Color:= FTagDCMetadataBackColor;
  end;
  // TPkgMetaData
  if (Tag = 'METADATA') then begin
    ACanvas.Font.Color:= FTagMetadataForeColor;
    ACanvas.Brush.Color:= FTagMetadataBackColor;
  end;
  // TPkgServerSide
  if (Tag = 'SERVERSIDE') then begin
    ACanvas.Font.Color:= FTagServerSideForeColor;
    ACanvas.Brush.Color:= FTagServerSideBackColor;
  end;
  if emUseBoldTags in FCxMemo.Options
  then ACanvas.Font.Style:= [fsBold]
  else ACanvas.Font.Style:= [];end;

procedure TEMemoPkgCode.DrawSpecialTag(const ASpecTag, Line: TGsString; ACanvas: TCanvas);
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

function TEMemoPkgCode.GetClassDescription(var R: TxmlClassDesc): Boolean;
begin
  Result:= GetxmlClassDescByClass(TPkgContainer, R);
end;

procedure TEMemoPkgCode.ParseLine(ALineNo: Integer; Canvas: TCanvas; ARect: TRect);
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

procedure TEMemoPkgCode.SetBackgroundColors(AColor: TColor);
begin
  inherited SetBackgroundColors(AColor);
  FTagPackageBackColor:= AColor;
  FTagCommentBackColor:= AColor;
  FTagPCDataBackColor:= AColor;
  FTagManifestBackColor:= AColor;
  FTagSpineBackColor:= AColor;
  FTagToursBackColor:= AColor;
  FTagXMetadataBackColor:= AColor;
  FTagDCMetadataBackColor:= AColor;
  FTagMetadataBackColor:= AColor;
  FTagServerSideBackColor:= AColor;
  if FCodeHighlight and (FCxMemo <> nil)
  then FCxMemo.Invalidate;
end;

end.

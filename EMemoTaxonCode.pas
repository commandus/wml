unit
  EMemoTaxonCode;
(*##*)
(*******************************************************************************
*                                                                             *
*   E  M  e  m  o  T  A  X  O  N  C  o  d  e                                   *
*                                                                             *
*   Copyright © 2003 Andrei Ivanov. All rights reserved.                       *
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
  EMemo, EMemoCode, xmlsupported, customxml, biotaxon;
{
    1 TTxnContainer, ToebPackage, TXMLDesc, TPkgDesc,
    2 TPkgPublication
    3 TPkgTaxon, TPkgItem,
    4 TPkgSynonym, TPkgItemRef,
    5 TPkgPerson, TPkgTour, TPkgSite, TPkgGuide, TPkgReference,
    6 TPkgDistribution, TPkgMeta,
    7 TPkgDCPublication,
       TPkgdcTitle, TPkgdcIdentifier, TPkgdcContributor, TPkgdcCreator, TPkgdcSubject,
       TPkgdcDescription, TPkgdcPublisher, TPkgdcDate, TPkgdcType, TPkgdcFormat,
       TPkgdcSource, TPkgdcLanguage, TPkgdcRelation, TPkgdcCoverage, TPkgdcRights,

    8 TPkgPCData,
    9 TxmlComment
   10 TPkgServerSide
}

type
  TEMemoTaxonCode = class(TEMemoCode)
  private
    FTagPackageForeColor: TColor;
    FTagPackageBackColor: TColor;
    FTagPublicationForeColor: TColor;
    FTagPublicationBackColor: TColor;
    FTagTaxonForeColor: TColor;
    FTagTaxonBackColor: TColor;
    FTagSynonymForeColor: TColor;
    FTagSynonymBackColor: TColor;
    FTagPersonForeColor: TColor;
    FTagPersonBackColor: TColor;
    FTagDistributionForeColor: TColor;
    FTagDistributionBackColor: TColor;
    FTagDCPublicationForeColor: TColor;
    FTagDCPublicationBackColor: TColor;

    FTagSymbiosForeColor: TColor;
    FTagSymbiosBackColor: TColor;
    FTagCollectionForeColor: TColor;
    FTagCollectionBackColor: TColor;

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
    procedure SetTagTaxonForeColor(AValue: TColor);
    procedure SetTagTaxonBackColor(AValue: TColor);
    procedure SetTagSynonymForeColor(AValue: TColor);
    procedure SetTagSynonymBackColor(AValue: TColor);
    procedure SetTagPersonForeColor(AValue: TColor);
    procedure SetTagPersonBackColor(AValue: TColor);
    procedure SetTagDistributionForeColor(AValue: TColor);
    procedure SetTagDistributionBackColor(AValue: TColor);
    procedure SetTagDCPublicationForeColor(AValue: TColor);
    procedure SetTagDCPublicationBackColor(AValue: TColor);
    procedure SetTagPublicationForeColor(AValue: TColor);
    procedure SetTagPublicationBackColor(AValue: TColor);
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
    property TagTaxonForeColor: TColor read FTagTaxonForeColor write SetTagTaxonForeColor;
    property TagTaxonBackColor: TColor read FTagTaxonBackColor write SetTagTaxonBackColor;
    property TagSynonymForeColor: TColor read FTagSynonymForeColor write SetTagSynonymForeColor;
    property TagSynonymBackColor: TColor read FTagSynonymBackColor write SetTagSynonymBackColor;
    property TagPersonForeColor: TColor read FTagPersonForeColor write SetTagPersonForeColor;
    property TagPersonBackColor: TColor read FTagPersonBackColor write SetTagPersonBackColor;
    property TagDistributionForeColor: TColor read FTagDistributionForeColor write SetTagDistributionForeColor;
    property TagDistributionBackColor: TColor read FTagDistributionBackColor write SetTagDistributionBackColor;
    property TagDCPublicationForeColor: TColor read FTagDCPublicationForeColor write SetTagDCPublicationForeColor;
    property TagDCPublicationBackColor: TColor read FTagDCPublicationBackColor write SetTagDCPublicationBackColor;
    property TagPublicationForeColor: TColor read FTagPublicationForeColor write SetTagPublicationForeColor;
    property TagPublicationBackColor: TColor read FTagPublicationBackColor write SetTagPublicationBackColor;
    property TagSymbiosForeColor: TColor read FTagSymbiosForeColor write FTagSymbiosForeColor;
    property TagSymbiosBackColor: TColor read FTagSymbiosBackColor write FTagSymbiosBackColor;
    property TagCollectionForeColor: TColor read FTagCollectionForeColor write FTagCollectionForeColor;
    property TagCollectionBackColor: TColor read FTagCollectionBackColor write FTagCollectionBackColor;

    property TagServerSideForeColor: TColor read FTagServerSideForeColor write SetTagServerSideForeColor;
    property TagServerSideBackColor: TColor read FTagServerSideBackColor write SetTagServerSideBackColor;
  end;

implementation

constructor TEMemoTaxonCode.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FTagPackageForeColor:= clRed;
  FTagPackageBackColor:= clWhite;
  FTagCommentForeColor:= clAqua;
  FTagCommentBackColor:= clWhite;
  FTagPCDataForeColor:= clTeal;
  FTagPCDataBackColor:= clWhite;
  FTagTaxonForeColor:= clGreen;
  FTagTaxonBackColor:= clWhite;
  FTagSynonymForeColor:= clOlive;
  FTagSynonymBackColor:= clWhite;
  FTagPersonForeColor:= clBlue;
  FTagPersonBackColor:= clWhite;
  FTagDistributionForeColor:= clOlive;
  FTagDistributionBackColor:= clWhite;
  FTagDCPublicationForeColor:= clNavy;
  FTagDCPublicationBackColor:= clWhite;
  FTagPublicationForeColor:= clBlack;
  FTagPublicationBackColor:= clWhite;


  TagSymbiosForeColor:= clTeal;
  TagSymbiosBackColor:= clWhite;
  TagCollectionForeColor:= clPurple;
  TagCollectionBackColor:= clWhite;

  FTagServerSideForeColor:= clDkGray;
  FTagServerSideBackColor:= clWhite;
end;

procedure TEMemoTaxonCode.SetTagPackageForeColor(AValue: TColor);
begin
  FTagPackageForeColor:= AValue;
  if FCodeHighlight and (FCxMemo <> nil) then FCxMemo.Invalidate;
end;

procedure TEMemoTaxonCode.SetTagPackageBackColor(AValue: TColor);
begin
  FTagPackageBackColor:= AValue;
  if FCodeHighlight and (FCxMemo <> nil) then FCxMemo.Invalidate;
end;

procedure TEMemoTaxonCode.SetTagCommentForeColor(AValue: TColor);
begin
  FTagCommentForeColor:= AValue;
  if FCodeHighlight and (FCxMemo <> nil) then FCxMemo.Invalidate;
end;

procedure TEMemoTaxonCode.SetTagCommentBackColor(AValue: TColor);
begin
  FTagCommentBackColor:= AValue;
  if FCodeHighlight and (FCxMemo <> nil) then FCxMemo.Invalidate;
end;

procedure TEMemoTaxonCode.SetTagPCDataForeColor(AValue: TColor);
begin
  FTagPCDataForeColor:= AValue;
  if FCodeHighlight and (FCxMemo <> nil) then FCxMemo.Invalidate;
end;

procedure TEMemoTaxonCode.SetTagPCDataBackColor(AValue: TColor);
begin
  FTagPCDataBackColor:= AValue;
  if FCodeHighlight and (FCxMemo <> nil) then FCxMemo.Invalidate;
end;

procedure TEMemoTaxonCode.SetTagTaxonForeColor(AValue: TColor);
begin
  FTagTaxonForeColor:= AValue;
  if FCodeHighlight and (FCxMemo <> nil) then FCxMemo.Invalidate;
end;

procedure TEMemoTaxonCode.SetTagTaxonBackColor(AValue: TColor);
begin
  FTagTaxonBackColor:= AValue;
  if FCodeHighlight and (FCxMemo <> nil) then FCxMemo.Invalidate;
end;

procedure TEMemoTaxonCode.SetTagSynonymForeColor(AValue: TColor);
begin
  FTagSynonymForeColor:= AValue;
  if FCodeHighlight and (FCxMemo <> nil) then FCxMemo.Invalidate;
end;

procedure TEMemoTaxonCode.SetTagSynonymBackColor(AValue: TColor);
begin
  FTagSynonymBackColor:= AValue;
  if FCodeHighlight and (FCxMemo <> nil) then FCxMemo.Invalidate;
end;

procedure TEMemoTaxonCode.SetTagPersonForeColor(AValue: TColor);
begin
  FTagPersonForeColor:= AValue;
  if FCodeHighlight and (FCxMemo <> nil) then FCxMemo.Invalidate;
end;

procedure TEMemoTaxonCode.SetTagPersonBackColor(AValue: TColor);
begin
  FTagPersonBackColor:= AValue;
  if FCodeHighlight and (FCxMemo <> nil) then FCxMemo.Invalidate;
end;

procedure TEMemoTaxonCode.SetTagDistributionForeColor(AValue: TColor);
begin
  FTagDistributionForeColor:= AValue;
  if FCodeHighlight and (FCxMemo <> nil) then FCxMemo.Invalidate;
end;

procedure TEMemoTaxonCode.SetTagDistributionBackColor(AValue: TColor);
begin
  FTagDistributionBackColor:= AValue;
  if FCodeHighlight and (FCxMemo <> nil) then FCxMemo.Invalidate;
end;

procedure TEMemoTaxonCode.SetTagDCPublicationForeColor(AValue: TColor);
begin
  FTagDCPublicationForeColor:= AValue;
  if FCodeHighlight and (FCxMemo <> nil) then FCxMemo.Invalidate;
end;

procedure TEMemoTaxonCode.SetTagDCPublicationBackColor(AValue: TColor);
begin
  FTagDCPublicationBackColor:= AValue;
  if FCodeHighlight and (FCxMemo <> nil) then FCxMemo.Invalidate;
end;

procedure TEMemoTaxonCode.SetTagPublicationForeColor(AValue: TColor);
begin
  FTagPublicationForeColor:= AValue;
  if FCodeHighlight and (FCxMemo <> nil) then FCxMemo.Invalidate;
end;

procedure TEMemoTaxonCode.SetTagPublicationBackColor(AValue: TColor);
begin
  FTagPublicationBackColor:= AValue;
  if FCodeHighlight and (FCxMemo <> nil) then FCxMemo.Invalidate;
end;

procedure TEMemoTaxonCode.SetTagServerSideForeColor(AValue: TColor);
begin
  FTagServerSideForeColor:= AValue;
  if FCodeHighlight and (FCxMemo <> nil) then FCxMemo.Invalidate;
end;

procedure TEMemoTaxonCode.SetTagServerSideBackColor(AValue: TColor);
begin
  FTagServerSideBackColor:= AValue;
  if FCodeHighlight and (FCxMemo <> nil) then FCxMemo.Invalidate;
end;

procedure TEMemoTaxonCode.SelectTagColor(const ATag: TGsString; ACanvas: TCanvas);
var
  Tag: TGsString;
begin
  ACanvas.Font.Color:= FTagForeColor;
  ACanvas.Brush.Color:= FTagBackColor;

  Tag:= ANSIUppercase(ATag);
  if (Length(Tag) > 0) and (Tag[1] = '/')
  then Delete(Tag, 1, 1);
  //
  if (Tag = '!DOCTYPE') or (Tag = '?XML') then begin
    ACanvas.Font.Color:= FTagPackageForeColor;
    ACanvas.Brush.Color:= FTagPackageBackColor;
  end;
  // TxmlComment
  if (Tag = '!--') then begin
    ACanvas.Font.Color:= FTagCommentForeColor;
    ACanvas.Brush.Color:= FTagCommentBackColor;
  end;

  //  TTxnSys, TTxnTitle,
  if (Tag = 'TAXON') or (Tag = 'SYS') or (Tag = 'TITLE') then begin
    ACanvas.Font.Color:= FTagTaxonForeColor;
    ACanvas.Brush.Color:= FTagTaxonBackColor;
  end;
  //  TTxnSynonyms, TTxnSynonym
  if (Pos('SYNONYM', Tag) = 1) then begin
    ACanvas.Font.Color:= FTagSynonymForeColor;
    ACanvas.Brush.Color:= FTagSynonymBackColor;
  end;
  //  TTxnAuthors, TTxnPerson,
  if (Tag = 'AUTHORS') or (Tag = 'PERSON') then begin
    ACanvas.Font.Color:= FTagPersonForeColor;
    ACanvas.Brush.Color:= FTagPersonBackColor;
  end;
  //  TTxnDistributions, TTxnDistribution, TTxnArea
  if (Pos('DISTRIBUTION', Tag) = 1) or (Pos('AREA', Tag) = 1) then begin
    ACanvas.Font.Color:= FTagDistributionForeColor;
    ACanvas.Brush.Color:= FTagDistributionBackColor;
  end;
  //  TTxnPublications, TTxnPublication,
  if (Pos('PUBLICATION', Tag) = 1) then begin
    ACanvas.Font.Color:= FTagPublicationForeColor;
    ACanvas.Brush.Color:= FTagPublicationBackColor;
  end;

  if (Pos('DC', Tag) = 1) then begin
    ACanvas.Font.Color:= FTagDCPublicationForeColor;
    ACanvas.Brush.Color:= FTagDCPublicationBackColor;
  end;

  //  TTxnSymbiosises, TTxnSymbiosis, TTxnHosts, TTxnParasites, TTxnPlants,
  if (Pos('SYMBIOS', Tag) = 1) or (Pos('HOST', Tag) = 1) or (Pos('PARASITE', Tag) = 1) or (Pos('PLANT', Tag) = 1)
  then begin
    ACanvas.Font.Color:= FTagSymbiosForeColor;
    ACanvas.Brush.Color:= FTagSymbiosBackColor;
  end;

  //  TTxnCollections, TTxnCollection, TTxnItem,
  if (Pos('COLLECTION', Tag) = 1) or (Tag = 'ITEM') then begin
    ACanvas.Font.Color:= FTagCollectionForeColor;
    ACanvas.Brush.Color:= FTagCollectionBackColor;
  end;

  // TPkgServerSide
  if (Tag = 'SERVERSIDE') then begin
    ACanvas.Font.Color:= FTagServerSideForeColor;
    ACanvas.Brush.Color:= FTagServerSideBackColor;
  end;
  if emUseBoldTags in FCxMemo.Options
  then ACanvas.Font.Style:= [fsBold]
  else ACanvas.Font.Style:= [];end;

procedure TEMemoTaxonCode.DrawSpecialTag(const ASpecTag, Line: TGsString; ACanvas: TCanvas);
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

function TEMemoTaxonCode.GetClassDescription(var R: TxmlClassDesc): Boolean;
begin
  Result:= GetxmlClassDescByClass(TTxnContainer, R);
end;

procedure TEMemoTaxonCode.ParseLine(ALineNo: Integer; Canvas: TCanvas; ARect: TRect);
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

procedure TEMemoTaxonCode.SetBackgroundColors(AColor: TColor);
begin
  inherited SetBackgroundColors(AColor);
  FTagPackageBackColor:= AColor;
  FTagCommentBackColor:= AColor;
  FTagPCDataBackColor:= AColor;
  FTagTaxonBackColor:= AColor;
  FTagSynonymBackColor:= AColor;
  FTagPersonBackColor:= AColor;
  FTagDistributionBackColor:= AColor;
  FTagDCPublicationBackColor:= AColor;
  FTagPublicationBackColor:= AColor;
  FTagServerSideBackColor:= AColor;
  if FCodeHighlight and (FCxMemo <> nil)
  then FCxMemo.Invalidate;
end;

end.

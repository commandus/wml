unit
  EMemoCode;
(*##*)
(*******************************************************************************
*                                                                             *
*   E  M  e  m  o  C  o  d  e                                                  *
*                                                                             *
*   Copyright © 2001, 2002 Andrei Ivanov. All rights reserved.                 *
*   Part of apooed                                                            *
*   Conditional defines:                                                       *
*                                                                             *
*   Revisions    : Jun 25 2001                                                 *
*   Last revision: Mar 29 2002                                                *
*   Lines        : 842                                                         *
*   History      :                                                            *
*   Base on code of radu@rospotline.com                                        *
*                                                                             *
*   Printed      : ---                                                         *
*                                                                             *
********************************************************************************)
(*##*)

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  util1, customxml, EMemo;

type
  TDropItem = class(TObject)
  protected
    FImageIndex: Integer;
    FList: TStringList;
    FText: String;
    procedure SetList(Value: TStringList);
  public
    constructor Create;
    destructor Destroy; override;
    property SubItems: TStringList read FList write SetList;
    property Text: String read FText write FText;
    property ImageIndex: Integer read FImageIndex write FImageIndex;
  end;

  TEMemoCode = class(TComponent)
  private
    FTagsList: TStrings;
    procedure SetGsMemo(Value: TECustomMemo);
    procedure SetCodeHighlight(Value: Boolean);

    procedure SetTagForeColor(Value: TColor);
    procedure SetTagBackColor(Value: TColor);
    procedure SetTagPropForeColor(Value: TColor);
    procedure SetTagPropBackColor(Value: TColor);
    procedure SetValueForeColor(Value: TColor);
    procedure SetValueBackColor(Value: TColor);
    procedure SetSpecTagsForeColor(Value: TColor);
    procedure SetSpecTagsBackColor(Value: TColor);
    procedure SetEntityForeColor(Value: TColor);
    procedure SetEntityBackColor(Value: TColor);

    procedure SetBRTagForeColor(Value: TColor);
    procedure SetBRTagBackColor(Value: TColor);

    procedure SetUseTagHighlight(Value: Boolean);
    procedure SetUseSpecTagsHighlight(Value: Boolean);
    procedure SetUseEntityHighlight(Value: Boolean);

  protected
    FCodeHighlight,
    FUseTagHighlight,
    FUseEntityHighlight, 
    FUseSpecTagsHighlight: Boolean;

    FInTag,
    FInValue,
    FFirstTag,
    FTagNotClosed: Boolean;

    FCxMemo: TECustomMemo;
    FCharCount,
    FLastPos,
    FStartPos: Integer;

    FBRTagForeColor,
    FBRTagBackColor,
    FTagForeColor,
    FTagBackColor,
    FTagPropForeColor,
    FTagPropBackColor,
    FValueForeColor,
    FValueBackColor,

    FEntityForeColor,
    FEntityBackColor: TColor;

    FSpecTagsForeColor,
    FSpecTagsBackColor: TColor;

    procedure ShowColorHint(X, Y: Integer; HintColor: TColor);
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure MemoEvents(Sender: TObject; Shift: TShiftState; KeyEvent: TGsKeyEvent;
      Key: Word; CaretPos, MousePos: TPoint; Modified, OverwriteMode: Boolean);
    procedure MemoDrawLine(Sender: TObject; LineIndex: Integer;
      ACanvas: TCanvas; TextRect: TRect; var AllowSelfDraw: Boolean);
    procedure ParseLine(ALineNo: Integer; Canvas: TCanvas; ARect: TRect); dynamic; abstract;
    procedure DropListDown(Sender: TObject); virtual;
    procedure UpdateDropListForTag(const TagStr: String);
    procedure UpdateDropList_AllTags;
    // get class description
    function GetClassDescription(var R: TxmlClassDesc): Boolean; virtual;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure ClearDropItems;
    function AddDropItem(DropItem: TDropItem): Integer;
    procedure DeleteDropItem(DropItemIndex: Integer);
    procedure CreateDropItems; virtual;
    procedure GetDropItemsFromDTDFile(const FileName: String);

    procedure SetBackgroundColors(AColor: TColor); virtual;
    function SetBackgroundColors2Memo: TColor; virtual;
//  function printcanvas(AHDC: HDC; lpString: PWideChar; nCount: Integer; var lpRect: TRect): Integer;
    // get only visible part of string and print to canvas
    function printcanvasVisible(AHDC: HDC; const AStr: TGsString; var lpRect: TRect): Integer;
    procedure DrawEntities(const ALineText: TGsString; ACanvas: TCanvas);
  published
    property CodeHighlight: Boolean read FCodeHighlight write SetCodeHighlight;
    property CxMemo: TECustomMemo read FCxMemo write SetGsMemo;
    property TagForeColor: TColor read FTagForeColor write SetTagForeColor;
    property TagBackColor: TColor read FTagBackColor write SetTagBackColor;
    property TagPropForeColor: TColor read FTagPropForeColor write SetTagPropForeColor;
    property TagPropBackColor: TColor read FTagPropBackColor write SetTagPropBackColor;
    property ValueForeColor: TColor read FValueForeColor write SetValueForeColor;
    property ValueBackColor: TColor read FValueBackColor write SetValueBackColor;
    property SpecTagsForeColor: TColor read FSpecTagsForeColor write SetSpecTagsForeColor;
    property SpecTagsBackColor: TColor read FSpecTagsBackColor write SetSpecTagsBackColor;
    property EntityForeColor: TColor read FSpecTagsForeColor write SetEntityForeColor;
    property EntityBackColor: TColor read FSpecTagsBackColor write SetEntityBackColor;
    property TagBRForeColor: TColor read FBRTagForeColor write SetBRTagForeColor;
    property TagBRBackColor: TColor read FBRTagBackColor write SetBRTagBackColor;

    property UseTagHighlight: Boolean read FUseTagHighlight write SetUseTagHighlight;
    property UseSpecTagsHighlight: Boolean read FUseSpecTagsHighlight write SetUseSpecTagsHighlight;
    property UseEntityHighlight: Boolean read FUseEntityHighlight write SetUseEntityHighlight;
  end;

function HTMLColorToColor(HTMLColor: string; var IsColor: Boolean): TColor;

function FindTagBegin(SLine: String; StartPos: Integer): Integer;

function FindTagEnd(SLine: String; StartPos: Integer): Integer;

implementation

uses
  xmlsupported;
  
function HTMLColorToColor(HTMLColor: string; var IsColor: Boolean): TColor;
var
  R, G, B, clStr: string;
begin
  IsColor := False;
  Result := clNone;
  R := '';
  G := '';
  B := '';
  if Length(HTMLColor) = 4 then begin
    if not (HTMLColor[1] = '#') then Exit;
    R := Copy(HTMLColor, 2, 1) + Copy(HTMLColor, 2, 1);
    G := Copy(HTMLColor, 3, 1) + Copy(HTMLColor, 3, 1);
    B := Copy(HTMLColor, 4, 1) + Copy(HTMLColor, 4, 1);
  end;
  if Length(HTMLColor) = 7 then begin
    if not (HTMLColor[1] = '#') then Exit;
    R := Copy(HTMLColor, 2, 2);
    G := Copy(HTMLColor, 4, 2);
    B := Copy(HTMLColor, 6, 2);
  end;
  clStr := '$00' + B + G + R;
  if Length(clStr) = 9 then
  try
    Result := StringToColor(clStr);
    IsColor := True;
  except
    IsColor := False;
    Result := clNone;
  end;
end;

(* TDropItem ********************************************************************************)

constructor TDropItem.Create;
begin
  inherited Create;
  FImageIndex:= -1;
  FList:= TStringList.Create;
end;

destructor TDropItem.Destroy;
begin
  FList.Free;
  inherited Destroy;
end;

procedure TDropItem.SetList(Value: TStringList);
begin
  FList.Assign(Value);
end;

(* TEMemoCode ************************************************************************)
{
function TEMemoCode.printcanvas(AHDC: HDC; lpString: PWideChar; nCount: Integer; var lpRect: TRect): Integer;
begin
  Result:= Integer(ExtTextOutW(AHDC, lpRect.Left, lpRect.Top, ETO_CLIPPED, @lpRect,
    lpString, ncount, FCxMemo.CharWidthsPtr));
end;
}
// get only visible part of string and print to canvas
function TEMemoCode.printcanvasVisible(AHDC: HDC; const AStr: TGsString; var lpRect: TRect): Integer;
var
  HPos: Integer;
begin
  HPos:= FCxMemo.ScrollPos_H * FCxMemo.FontWidth;
  Dec(lpRect.Left, HPos);
//  Dec(lpRect.Right, HPos);
  Result:= Integer(ExtTextOutW(AHDC, lpRect.Left, lpRect.Top, ETO_CLIPPED, @lpRect,
    PWideChar(AStr), Length(AStr), FCxMemo.CharWidthsPtr));  //
end;

procedure TEMemoCode.DrawEntities(const ALineText: TGsString; ACanvas: TCanvas);
var
  st, fin, p, p1: Integer;
  S: TGsString;
  R: TRect;
begin
  // set boundary to prevent scan too much
  st:= FCxMemo.ScrollPos_H - FCxMemo.WidthsLen;
  fin:= FCxMemo.ScrollPos_H + FCxMemo.WidthsLen;
  // check left boundary
  if st <= 0
  then st:= 1;

  p:= PosFrom(st, '&', ALineText);

  while (p > 0) and (p < fin)  do begin
    p1:= util1.PosFrom(p, ';', ALineText);
    if p1 = 0
    then Exit;

    S:= Copy(ALineText, p, p1 - p + 1);
    R:= Rect(FCxMemo.FontWidth * (p - 1), 0,
      FCxMemo.FontWidth * (p1), FCxMemo.FontHeight);
    printcanvasVisible(ACanvas.Handle, PWideChar(S), R);
    p:= PosFrom(p + 1, '&', ALineText);
  end;
end;

constructor TEMemoCode.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FCxMemo:= nil;
  FCodeHighlight:= True;
  FUseTagHighlight:= True;
  FUseSpecTagsHighlight:= True;
  FUseEntityHighlight:= True; 
  FTagForeColor:= clBlack;
  FTagBackColor:= clWhite;
  FTagPropForeColor:= clPurple;
  FTagPropBackColor:= clWhite;
  FValueForeColor:= clGray;
  FValueBackColor:= clWhite;
  FSpecTagsForeColor:= clGreen;
  FSpecTagsBackColor:= clWhite;
  FEntityForeColor:= clGreen;
  FEntityBackColor:= clWhite;  
  FBRTagForeColor:= clNavy;
  FBRTagBackColor:= clWhite;
  FTagsList:= TStringList.Create;
  CreateDropItems;
end;

destructor TEMemoCode.Destroy;
begin
  ClearDropItems;
  FTagsList.Free;
  inherited Destroy;
end;

procedure TEMemoCode.SetGsMemo(Value: TECustomMemo);
begin
  FCxMemo := Value;
  if FCxMemo <> nil then
  begin
    FCxMemo.OnMemoEvents:= MemoEvents;
    FCxMemo.OnDrawLine:= MemoDrawLine;
    FCxMemo.OnDropListDown:= DropListDown;
  end;
end;

procedure TEMemoCode.SetCodeHighlight(Value: Boolean);
begin
  FCodeHighlight := Value;
  if FCxMemo <> nil then FCxMemo.Invalidate;
end;

procedure TEMemoCode.SetTagForeColor(Value: TColor);
begin
  FTagForeColor := Value;
  if FCodeHighlight and (FCxMemo <> nil) then FCxMemo.Invalidate;
end;

procedure TEMemoCode.SetTagBackColor(Value: TColor);
begin
  FTagBackColor := Value;
  if FCodeHighlight and (FCxMemo <> nil) then FCxMemo.Invalidate;
end;

procedure TEMemoCode.SetTagPropForeColor(Value: TColor);
begin
  FTagPropForeColor := Value;
  if FCodeHighlight and (FCxMemo <> nil) then FCxMemo.Invalidate;
end;

procedure TEMemoCode.SetTagPropBackColor(Value: TColor);
begin
  FTagPropBackColor := Value;
  if FCodeHighlight and (FCxMemo <> nil) then FCxMemo.Invalidate;
end;

procedure TEMemoCode.SetValueForeColor(Value: TColor);
begin
  FValueForeColor := Value;
  if FCodeHighlight and (FCxMemo <> nil) then FCxMemo.Invalidate;
end;

procedure TEMemoCode.SetValueBackColor(Value: TColor);
begin
  FValueBackColor := Value;
  if FCodeHighlight and (FCxMemo <> nil) then FCxMemo.Invalidate;
end;

procedure TEMemoCode.SetSpecTagsForeColor(Value: TColor);
begin
  FSpecTagsForeColor := Value;
  if FCodeHighlight and (FCxMemo <> nil) then FCxMemo.Invalidate;
end;

procedure TEMemoCode.SetSpecTagsBackColor(Value: TColor);
begin
  FSpecTagsBackColor := Value;
  if FCodeHighlight and (FCxMemo <> nil) then FCxMemo.Invalidate;
end;

procedure TEMemoCode.SetEntityForeColor(Value: TColor);
begin
  FEntityForeColor:= Value;
  if FCodeHighlight and (FCxMemo <> nil) then FCxMemo.Invalidate;
end;

procedure TEMemoCode.SetEntityBackColor(Value: TColor);
begin
  FEntityBackColor:= Value;
  if FCodeHighlight and (FCxMemo <> nil) then FCxMemo.Invalidate;
end;

procedure TEMemoCode.SetBRTagForeColor(Value: TColor);
begin
  FBRTagForeColor := Value;
  if FCodeHighlight and (FCxMemo <> nil) then FCxMemo.Invalidate;
end;

procedure TEMemoCode.SetBRTagBackColor(Value: TColor);
begin
  FBRTagBackColor := Value;
  if FCodeHighlight and (FCxMemo <> nil) then FCxMemo.Invalidate;
end;

procedure TEMemoCode.SetUseTagHighlight(Value: Boolean);
begin
  FUseTagHighlight := Value;
  if FCodeHighlight and (FCxMemo <> nil) then FCxMemo.Invalidate;
end;

procedure TEMemoCode.SetUseSpecTagsHighlight(Value: Boolean);
begin
  FUseSpecTagsHighlight := Value;
  if FCodeHighlight and (FCxMemo <> nil) then FCxMemo.Invalidate;
end;

procedure TEMemoCode.SetUseEntityHighlight(Value: Boolean);
begin
  FUseEntityHighlight := Value;
  if FCodeHighlight and (FCxMemo <> nil) then FCxMemo.Invalidate;
end;

procedure TEMemoCode.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) and (AComponent = FCxMemo) then FCxMemo := nil;
end;

procedure TEMemoCode.ShowColorHint(X, Y: Integer; HintColor: TColor);
var
  HintPos: TPoint;
  R: TRect;
begin
  if FCxMemo = nil then Exit;
  if FCxMemo.HintWindow <> nil then
  begin
    Exit;
    FCxMemo.HintWindow.Free;
    FCxMemo.HintWindow := nil;
  end;
  FCxMemo.HintWindow := THintWindow.Create(Self);
  HintPos := FCxMemo.ClientToScreen(Point(X, Y));
  FCxMemo.HintWindow.Color := HintColor;
  R := Rect(HintPos.x, HintPos.y, HintPos.x + 18, HintPos.y + 14);
  FCxMemo.HintWindow.ActivateHint(R, '');
end;

procedure TEMemoCode.MemoEvents(Sender: TObject; Shift: TShiftState;
  KeyEvent: TGsKeyEvent; Key: Word; CaretPos, MousePos: TPoint; Modified, OverwriteMode: Boolean);
var
  SLink: string;
  IsColor: Boolean;
  Cl: TColor;
  FChrW, FChrH, RNo, CNo, Y: Integer;
begin
  FChrH := FCxMemo.FontHeight;
  FChrW := FCxMemo.FontWidth;
  if (KeyEvent = k_Down) and (ssCtrl in Shift) then
  begin
    FCxMemo.GetRowColAtPos(MousePos.x + FCxMemo.ScrollPos_H * FChrW, MousePos.y +
      FCxMemo.ScrollPos_V * FChrH, RNo, CNo);
    SLink := ANSIUpperCase(FCxMemo.GetWordAtPos(CNo, RNo, Y));
    if (SLink <> '') and (Y <> -1) then
    begin
      IsColor := False;
      if SLink[1] = '#' then
        Cl := HTMLColorToColor(SLink, IsColor)
      else
        Cl := clNone;
      if Cl <> clNone then IsColor := True;
      if IsColor then
      begin
        ShowColorHint(MousePos.x + 4, MousePos.y + 4, Cl);
        FCxMemo.HideHintWindow := True;
      end else
        FCxMemo.HideHintWindow := False;
    end;
  end;
end;

procedure TEMemoCode.MemoDrawLine(Sender: TObject; LineIndex: Integer;
  ACanvas: TCanvas; TextRect: TRect; var AllowSelfDraw: Boolean);
var
  ss: WideString;
begin
  if (FCxMemo = nil) or (not FCxMemo.Visible) then Exit;
  AllowSelfDraw:= not FCodeHighlight;
  if AllowSelfDraw then Exit;
  if LineIndex = FCxMemo.TopLine
  then FTagNotClosed:= False;
  ACanvas.Brush.Color := FCxMemo.EnvironmentOptions.TextBackground;
  ACanvas.Font.Color := FCxMemo.EnvironmentOptions.TextColor;
  // uncomment this for debug purposes only
  // if (LineIndex < 0) or (LineIndex >= FCxMemo.Lines.Count)
  // then ShowMessage('Out of range: '+IntToStr(LineIndex))
  // else
  ss:= Copy(FCxMemo.Lines[LineIndex], FCxMemo.ScrollPos_H + 1, FCxMemo.WidthsLen);
//  len:= Length(ss);

  ExtTextOutW(ACanvas.Handle, TextRect.Left, TextRect.Top, ETO_CLIPPED, @TextRect,
    PWideChar(ss), Length(ss), FCxMemo.CharWidthsPtr);
  ParseLine(LineIndex, ACanvas, TextRect);
end;

function FindTagBegin(SLine: String; StartPos: Integer): Integer;
var
  I: Integer;
begin
  Result := -1;
  if (StartPos < 1) or (StartPos > Length(SLine)) then Exit;
  for I := StartPos downto 1 do
    if SLine[I] = '<' then begin
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

procedure TEMemoCode.DropListDown(Sender: TObject);
var
  X, Y, z, tgB, tgE, I, I2, XBg: Integer;
  S, SLine, Tag: String;
  InTag: Boolean;
begin
  if not Assigned(FCxMemo)
  then Exit;
  FCxMemo.DropListItems.Clear;
  X:= FCxMemo.CaretPos_V;
  Y:= FCxMemo.CaretPos_H;
  if X < 0
  then Exit;
  Tag := '';
  if X <= FCxMemo.Lines.Count - 1 then begin
    S:= FCxMemo.Lines[X];
    tgB:= FindTagBegin(S, Y + 1);
    tgE:= FindTagEnd(S, Y + 1);
    if tgE > -1 then begin
      if (tgE < Y) and (tgE > tgB)
      then Exit;
    end;
    if (tgB > -1) and (tgB < Y + 1) then begin
      // check is tag closed allready?
      z:= FindTagEnd(S, tgB + 1);
      if (z > -1) and (z <= Y) then begin
        // tag terminated
        UpdateDropList_AllTags;
        Exit;
      end;
      if S[tgB + 1] = '/' then Exit;
      Tag:= FCxMemo.GetWordAtPos(tgB + 1, X, I);
      if (Y + 1) <= Length(S) then begin
        if (S[Y] in ['a'..'z', 'A'..'Z', ' ']) and (S[Y + 1] in [' ', '>'])
        then UpdateDropListForTag(Tag);
      end else
        if not (S[Y] in ['a'..'z', 'A'..'Z', ' '])
        then UpdateDropListForTag(Tag);
      if S[Y] = '<'
      then UpdateDropList_AllTags;
      Exit;
    end;
    InTag := False;
    SLine := FCxMemo.Lines[X];
    if tgB = -1 then begin
      if X = 0
      then Exit;
      for I := X - 1 downto 0 do begin
        if InTag then Break;
        S := FCxMemo.Lines[I];
        for I2 := Length(S) downto 1 do begin
          if S[I2] = '>' then Exit;
          if S[I2] = '<' then begin
            InTag := True;
            if S[I2 + 1] = '/' then Exit;
            Tag := FCxMemo.GetWordAtPos(I2 + 1, I, XBg);
            if (Y + 1) <= Length(SLine) then begin
              if (SLine[Y] in ['a'..'z', 'A'..'Z', ' ']) and (SLine[Y + 1] in [' ', '>']) then
                UpdateDropListForTag(Tag);
            end else
              if (Y <= Length(SLine)) and (Y > 0) then
                if (SLine[Y] in ['a'..'z', 'A'..'Z', ' ']) then
                  UpdateDropListForTag(Tag);
            Break;
          end;
        end;
      end;
    end;
  end;
end;

procedure TEMemoCode.UpdateDropListForTag(const TagStr: String);
var
  i, p, Idx: Integer;
  s: String;
  DropItem: TDropItem;
begin
  // Idx:= FTagsList.IndexOf(ANSIUpperCase(TagStr));
  Idx:= -1;
  for i:= 0 to FTagsList.Count - 1 do begin
    s:= FTagsList[i];
    p:= Pos('|', s);
    if p > 0
    then Delete(s, p, MaxInt);
    if ANSICompareText(TagStr, s) = 0 then begin
      Idx:= i;
      Break;
    end;
  end;

  if (Idx < 0) or (not Assigned(FTagsList.Objects[Idx]))
  then Exit;

  DropItem:= TDropItem(FTagsList.Objects[Idx]);
  FCxMemo.DropListItems.Assign(DropItem.SubItems);
end;

procedure TEMemoCode.UpdateDropList_AllTags;
var
  I: Integer;
begin
  for I:= 0 to FTagsList.Count - 1 do begin
    FCxMemo.DropListItems.AddObject(FTagsList[I], FTagsList.Objects[I]);
  end;
end;

function TEMemoCode.GetClassDescription(var R: TxmlClassDesc): Boolean;
begin
  Result:= False;
end;

procedure TEMemoCode.ClearDropItems;
begin
  with FTagsList do begin
    repeat
      if Count <= 0
      then Break;
      if Assigned(Objects[0])
      then Objects[0].Free;
      Delete(0);
    until False;
  end;
end;

function TEMemoCode.AddDropItem(DropItem: TDropItem): Integer;
begin
  if not Assigned(DropItem)
  then Result:= -1
  else Result:= FTagsList.AddObject(DropItem.Text, DropItem);
end;

procedure TEMemoCode.DeleteDropItem(DropItemIndex: Integer);
begin
  if DropItemIndex > Pred(FTagsList.Count)
  then Exit;
  FTagsList.Objects[DropItemIndex].Free;
  FTagsList.Delete(DropItemIndex);
end;

procedure TEMemoCode.CreateDropItems;
var
  i, a: Integer;
  ElementName,
  attributeName: String;
  DI: TDropItem;
  e: TxmlElement;
  dsc: TxmlClassDesc;
begin
  ClearDropItems;
  if not GetClassDescription(dsc)
  then Exit;

  for i:= 0 to dsc.len - 1 do begin
    ElementName:= dsc.classes[i].GetElementName;
    DI:= TDropItem.Create;
    DI.Text:= ElementName + '|element|' + ElementName;
    AddDropItem(DI);
    e:= dsc.classes[i].Create(Nil);
    DI.ImageIndex:= GetBitmapIndexByClass(TPersistentClass(e.ClassType));
    for a:= 0 to e.Attributes.Count - 1 do begin
      attributeName:= e.Attributes[a].Name;
      DI.SubItems.Add(attributeName + '|attribute|' + attributeName);
    end;
    e.Free;
  end
end;

procedure TEMemoCode.GetDropItemsFromDTDFile(const FileName: String);
var
  I: Integer;
  Tag, S: String;
  SList: TStringList;
  DI: TDropItem;
begin
  if not FileExists(FileName) then Exit;
  ClearDropItems;
  SList:= TStringList.Create;
  SList.LoadFromFile(FileName);
  Tag := '';
  DI:= Nil;
  for I := 0 to SList.Count - 1 do begin
    S:= SList[I];
    if Length(S) < 2
    then Continue;
    case S[1] of
    #9:begin
      Delete(S, 1, 1);
      S:= Trim(S)+'|'+S+'|'+S+'=';
      if DI = nil
      then Continue;
      if DI.Text = Tag
      then DI.SubItems.Add(S);
    end;
    else begin
      if Assigned(DI)
      then AddDropItem(DI);
      S:= Trim(S);
      Tag := S;
      DI:= TDropItem.Create;
      DI.Text := S;
      Continue;
    end;
    end; { case }
  end
end;

procedure TEMemoCode.SetBackgroundColors(AColor: TColor);
begin
  TagBackColor:= AColor;
  TagPropBackColor:= AColor;
  ValueBackColor:= AColor;
  SpecTagsBackColor:= AColor;
  TagBRBackColor:= AColor;
  EntityBackColor:= AColor;
end;

function TEMemoCode.SetBackgroundColors2Memo: TColor;
begin
  if not Assigned(FCxMemo) then begin
    Result:= 0;
    Exit;
  end;
  Result:= FCxMemo.EnvironmentOptions.TextBackground;
  SetBackgroundColors(Result);
end;

end.

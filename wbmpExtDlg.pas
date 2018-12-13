unit
  wbmpExtDlg;
(*##*)
(*******************************************************************
*                                                                  *
*   w  b  m  p  E  x  t  D  l  g                                  *
*   wbmp bitmap image dialog window, part of apooed                *
*                                                                 *
*   Copyright © 2001, 2002 Andrei Ivanov. All rights reserved.     *
*                                                                 *
*   Conditional defines:                                           *
*                                                                 *
*   Revisions    : Mar 29 2002                                     *
*   Last revision:                                                *
*   Lines        : 511                                             *
*   History      :                                                *
*   Printed      : ---                                             *
*                                                                 *
********************************************************************)
(*##*)

interface

{$R-,H+,X+}

uses
  Messages, Windows, SysUtils, Classes, Controls, StdCtrls, Graphics,
  ExtCtrls, Buttons, Dialogs, Forms,
  wbmpImage, GifImage;

type
{ TWOpenPictureDialog }
{    property Dither:     (dmNearest,			// Nearest color matching w/o error correction
     dmFloydSteinberg,		// Floyd Steinberg Error Diffusion dithering
     dmStucki,			// Stucki Error Diffusion dithering
     dmSierra,			// Sierra Error Diffusion dithering
     dmJaJuNI,			// Jarvis, Judice & Ninke Error Diffusion dithering
     dmSteveArche,		// Stevenson & Arche Error Diffusion dithering
     dmBurkes			// Burkes Error Diffusion dithering
}
  TWOpenPictureDialog = class(TOpenDialog)
  private
    FStretch: Boolean;
    FShowing: Boolean;
    // wbmp
    FDitherMode: TDitherMode;
    FImageTransformOptions: TTransformOptions;
    FPicturePanel: TPanel;
    FButtonsPanel: TPanel;
    FTransformOptionsButton: TButton;
    FPreviewButton: TSpeedButton;
    FDitherModeSelect: TComboBox;
    FPaintPanelSrc: TPanel;
    FPaintPanelConverted: TPanel;
    FImageCtrl: TImage;
    FWBMPImageCtrl: TImage;
    FSavedFilename: string;
    function  IsFilterStored: Boolean;
    procedure PreviewKeyPress(Sender: TObject; var Key: Char);
    procedure DoDither;
    procedure SetDitherMode(AValue: TDitherMode);
    procedure SetImageTransformOptions(AValue: TTransformOptions);
    procedure OnDitherModeChange(Sender: TObject);
    procedure OnPreviewClick(Sender: TObject);
    procedure SetStretch(AValue: Boolean);
  protected
    FPreviewForm: TForm;
    procedure ShowPreview(AImage: TImage);
    procedure ShowTransformOptions;
    procedure PreviewClick(Sender: TObject); virtual;
    procedure PreviewConvertedClick(Sender: TObject); virtual;
    procedure TransformOptionsClick(Sender: TObject); virtual;
    procedure DoClose; override;
    procedure DoSelectionChange; override;
    procedure DoShow; override;
    property ImageCtrl: TImage read FImageCtrl;
    property WBMPImageCtrl: TImage read FWBMPImageCtrl;
  published
    property Filter stored IsFilterStored;
    property DitherMode: TDitherMode read FDitherMode write SetDitherMode;
    property ImageTransformOptions: TTransformOptions read FImageTransformOptions write SetImageTransformOptions;
    property Stretch: Boolean read FStretch write SetStretch;
  public
    constructor Create(AOwner: TComponent); override;
    function Execute: Boolean; override;
  end;

{ TWSavePictureDialog }

  TWSavePictureDialog = class(TWOpenPictureDialog)
  public
    function Execute: Boolean; override;
  end;

implementation

uses
  Consts, Math, CommDlg, Dlgs;

type
  TSilentPaintPanel = class(TPanel)
  protected
    procedure WMPaint(var Msg: TWMPaint); message WM_PAINT;
  end;

procedure TSilentPaintPanel.WMPaint(var Msg: TWMPaint);
begin
  try
    inherited;
  except
    Caption := SInvalidImage;
  end;
end;

{ TWOpenPictureDialog }

constructor TWOpenPictureDialog.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FShowing:= False;
  FStretch:= False;
  Filter := GraphicFilter(TGraphic);
  FDitherMode:= dmNearest;
  FImageTransformOptions:= [toAlign8];
  FPicturePanel := TPanel.Create(Self);
  with FPicturePanel do begin
    Name := 'PicturePanel';
    Caption := '';
    SetBounds(204, 5, 2 * 169, 200);
    BevelOuter := bvNone;
    BorderWidth := 6;
    TabOrder := 1;
    FButtonsPanel:= TPanel.Create(Self);
    with FButtonsPanel do begin
      Name := 'FButtonsPanel';
      Caption := '';
      SetBounds(1, 1, 157, 22);
      Align := alTop;
      BorderStyle:= bsNone;
      BevelOuter:= bvNone;
      AutoSize := False;
      Parent := FPicturePanel;
    end;
    FTransformOptionsButton:= TButton.Create(Self);
    with FTransformOptionsButton do begin
      Name := 'TransformOptionsButton';
      Caption := 'Options';
      Hint:= 'Select options';
      ShowHint:= True;
      SetBounds(1, 1, 60, 20);
      Align := alNone;
      AutoSize := False;
      OnClick:= TransformOptionsClick;
      Parent:= FButtonsPanel;
    end;
    FPreviewButton := TSpeedButton.Create(Self);
    with FPreviewButton do  begin
      Name := 'PreviewButton';
      SetBounds(64, 1, 22, 22);
      Enabled:= False;
      Glyph.LoadFromResourceName(HInstance, 'PREVIEWGLYPH');
      Hint:= SPreviewLabel;
      ParentShowHint:= False;
      ShowHint := True;
      // OnClick := PreviewClick;
      OnClick:= PreviewConvertedClick;
      Align := alNone;
      Parent:= FButtonsPanel;
    end;
    FDitherModeSelect:= TCombobox.Create(Self);
    with FDitherModeSelect do begin
      Style:= csDropDownList;
      Name := 'DitherModeSelect';
      Hint:= 'Select dithering mode'#13#10'You can click mouse in preview area to change mode too';
      ShowHint:= True;
      SetBounds(7, 1, 70, 22);
      Enabled := False;
      FDitherModeSelect.OnChange:= OnDitherModeChange;
      Parent := FButtonsPanel;
    end;

    FPaintPanelSrc := TSilentPaintPanel.Create(Self);
    with FPaintPanelSrc do begin
      Name := 'PaintPanelSrc';
      Caption := '';
      Hint:= 'Click to preview';
      ParentShowHint:= False;
      ShowHint:= True;
      SetBounds(6, 29, 157, 145 div 2);
      Align := alTop;
      BevelInner := bvRaised;
      BevelOuter := bvLowered;
      TabOrder := 0;
      FImageCtrl := TImage.Create(Self);
      Parent := FPicturePanel;
      with FImageCtrl do begin
        Name := 'PaintBox';
        Align := alClient;
        OnDblClick := PreviewClick;
        Parent := FPaintPanelSrc;
        Proportional := True;
        Stretch := FStretch;
        Center := True;
        IncrementalDisplay := True;
      end;
    end;

    FPaintPanelConverted := TSilentPaintPanel.Create(Self);
    with FPaintPanelConverted do begin
      Name := 'PaintPanelConverted';
      Caption := '';
      Hint:= 'Click to preview';
      ParentShowHint:= False;
      ShowHint:= True;
//      SetBounds(6, 29, 157, 145);
      Align := alClient;
      BevelInner := bvRaised;
      BevelOuter := bvLowered;
      TabOrder := 1;
      FWBMPImageCtrl:= TImage.Create(Self);
      Parent := FPicturePanel;
      with FWBMPImageCtrl do begin
        Name := 'ConvertedBox';
        Align := alClient;
        OnDblClick := PreviewConvertedClick;
        Parent := FPaintPanelConverted;
        Proportional := True;
        Stretch := FStretch;
        Center := True;
        IncrementalDisplay := True;
      end;
    end;
  end;
end;

procedure TWOpenPictureDialog.SetStretch(AValue: Boolean);
begin
//if FStretch = AValue then Exit;
  FStretch:= AValue;
  if not Assigned(FImageCtrl)
  then Exit;
  FImageCtrl.Stretch:= AValue;
  FWBMPImageCtrl.Stretch:= AValue;
  FWBMPImageCtrl.Proportional:= FStretch;
  FImageCtrl.Proportional:= FStretch;
end;


procedure TWOpenPictureDialog.DoSelectionChange;
var
  FullName: string;
  ValidPicture: Boolean;

  function ValidFile(const FileName: string): Boolean;
  begin
    Result := GetFileAttributes(PChar(FileName)) <> $FFFFFFFF;
  end;

begin
  FullName := FileName;
  if FullName <> FSavedFilename then
  begin
    FSavedFilename := FullName;
    ValidPicture := FileExists(FullName) and ValidFile(FullName);
    if ValidPicture then
    try
      FImageCtrl.Picture.LoadFromFile(FullName);
      DoDither;
      FTransformOptionsButton.Caption := Format(SPictureDesc,
        [FImageCtrl.Picture.Width, FImageCtrl.Picture.Height]);
      FPreviewButton.Enabled := True;
      FImageCtrl.Enabled := True;
      FWBMPImageCtrl.Enabled := True;

      FDitherModeSelect.Enabled := True;
      FPaintPanelSrc.Caption := '';
      FPaintPanelConverted.Caption := '';
    except
      ValidPicture := False;
    end;
    if not ValidPicture then begin
      FTransformOptionsButton.Caption := SPictureLabel;
      FPreviewButton.Enabled := False;
      FImageCtrl.Enabled := False;
      FWBMPImageCtrl.Enabled := False;
      FDitherModeSelect.Enabled := False;
      FImageCtrl.Picture := Nil;
      FWBMPImageCtrl.Picture:= Nil;
      FPaintPanelSrc.Caption := srNone;
      FPaintPanelConverted.Caption := srNone;
    end;
  end;
  inherited DoSelectionChange;
end;

procedure TWOpenPictureDialog.DoClose;
begin
  FShowing:= False;
  inherited DoClose;
  { Hide any hint windows left behind }
  Application.HideHint;
end;

procedure TWOpenPictureDialog.DoShow;
var
  PreviewRect, StaticRect: TRect;
begin
  FShowing:= True;
  { Set preview area to entire dialog }
  GetClientRect(Handle, PreviewRect);
  StaticRect := GetStaticRect;
  { Move preview area to right of static area }
  PreviewRect.Left := StaticRect.Left + (StaticRect.Right - StaticRect.Left);
  Inc(PreviewRect.Top, 4);
  FPicturePanel.BoundsRect := PreviewRect;

  FPaintPanelSrc.SetBounds(6, 29, 157, (FPicturePanel.BoundsRect.Bottom -
    FPicturePanel.BoundsRect.Top - 29) div 2);

  FPreviewButton.Left := FButtonsPanel.BoundsRect.Right - FPreviewButton.Width - 2;
  FDitherModeSelect.Left:= FButtonsPanel.BoundsRect.Left + 60;
  FImageCtrl.Picture := Nil;
  FWBMPImageCtrl.Picture:= Nil;
  FSavedFilename := '';
  FPaintPanelSrc.Caption := srNone;
  FPicturePanel.ParentWindow := Handle;

  with Self.FDitherModeSelect do begin
    with Items do begin
      Clear;
      Add('Nearest');
      Add('Floyd');
      Add('Stucki');
      Add('Sierra');
      Add('Jarvis');
      Add('Arche');
      Add('Burkes');
    end;
    ItemIndex:= Integer(FDitherMode);
  end;

  inherited DoShow;
end;

function TWOpenPictureDialog.Execute: Boolean;
begin
  if NewStyleControls and not (ofOldStyleDialog in Options) then
    Template := 'DLGTEMPLATE' else
    Template := nil;
  Result := inherited Execute;
end;

procedure TWOpenPictureDialog.ShowTransformOptions;
var
  CImageTransformOptions: TTransformOptions;
  GBWBMPImage: TGroupBox;
  BOk, BCancel: TButton;
  CBNegative, CBFlipH, CBFlipV, CBAlign8: TCheckBox;
  FFormTrasformOptions: TForm;
begin
  FFormTrasformOptions:= TForm.Create(Self);
  with FFormTrasformOptions do begin
    BorderStyle:= bsDialog;
    Caption:= 'Image transform options';
    ClientHeight:= 210;
    ClientWidth:= 300;
    Position:= poScreenCenter;

    BOk:= TButton.Create(Self);
    with BOk do begin
      SetBounds(31, 172, 75, 25);
      Caption:= 'O&k';
      Default:= True;
      ModalResult:= 1;
      Parent:= FFormTrasformOptions;
    end;

    BCancel:= TButton.Create(Self);
    with BCancel do begin
      SetBounds(189, 172, 75, 25);
      Cancel:= True;
      Caption:= 'Cancel';
      ModalResult:= 2;
      Parent:= FFormTrasformOptions;
    end;

    GBWBMPImage:= TGroupBox.Create(Self);
    with GBWBMPImage do begin
      SetBounds(32, 16, 233, 145);
      Caption:= 'wbmp image';
      Parent:= FFormTrasformOptions;
    end;
    CBNegative:= TCheckBox.Create(Self);
    with CBNegative do begin
      SetBounds(8, 24, 130, 17);
      Caption:= '&Negative';
      Parent:= GBWBMPImage;
    end;
    CBFlipH:= TCheckBox.Create(Self);
    with CBFlipH do begin
      SetBounds(8, 48, 130, 17);
      Caption:= 'Flip &horisontal';
      Enabled:= False;
      Parent:= GBWBMPImage;
    end;
    CBFlipV:= TCheckBox.Create(Self);
    with CBFlipV do begin
      SetBounds(8, 72, 130, 17);
      Caption:= 'Flip &vertical';
      Enabled:= False;
      Parent:= GBWBMPImage;
    end;
    CBAlign8:= TCheckBox.Create(Self);
    with CBAlign8 do begin
      SetBounds(8, 96, 130, 17);
      Caption:= 'Align at &8 pixels width';
      Checked:= True;
      Parent:= GBWBMPImage;
    end;
    // set options
      CBNegative.Checked:= toNegative in FImageTransformOptions;
      CBFlipH.Checked:= toFlipH in FImageTransformOptions;
      CBFlipV.Checked:= toFlipV in FImageTransformOptions;
      CBAlign8.Checked:= toAlign8 in FImageTransformOptions;

    if ShowModal = mrOk then begin
      //
      CImageTransformOptions:= [];
      if CBNegative.Checked
      then Include(CImageTransformOptions, toNegative);
      if CBFlipH.Checked
      then Include(CImageTransformOptions, toFlipH);
      if CBFlipV.Checked
      then Include(CImageTransformOptions, toFlipV);
      if CBAlign8.Checked
      then Include(CImageTransformOptions, toAlign8);
      ImageTransformOptions:= CImageTransformOptions;
    end;
    Free;
  end;
end;

procedure TWOpenPictureDialog.ShowPreview(AImage: TImage);
var
  Panel: TPanel;
begin
  FPreviewForm := TForm.Create(Self);
  with FPreviewForm do
  try
    Name := 'PreviewForm';
    Visible := False;
    Caption := SPreviewLabel;
    BorderStyle := bsSizeToolWin;
    KeyPreview := True;
    Position := poScreenCenter;
    OnKeyPress := PreviewKeyPress;
    Panel := TPanel.Create(FPreviewForm);
    with Panel do
    begin
      Name := 'Panel';
      Caption := '';
      Hint:= 'Click to change dither mode';
      ParentShowHint:= False;
      ShowHint:= True;

      Align := alClient;
      BevelOuter := bvNone;
      BorderStyle := bsSingle;
      BorderWidth := 5;
      Color := clWindow;
      Parent := FPreviewForm;
      DoubleBuffered := True;
      with TImage.Create(FPreviewForm) do
      begin
        Name := 'Image';
        Align := alClient;
        Stretch := True;
        Proportional := True;
        Center := True;
        Picture.Assign(AImage.Picture);
        Parent := Panel;
        OnClick:= OnPreviewClick;
      end;
    end;
    if FImageCtrl.Picture.Width > 0 then
    begin
      ClientWidth := Min(Monitor.Width * 3 div 4,
        FImageCtrl.Picture.Width + (ClientWidth - Panel.ClientWidth)+ 10);
      ClientHeight := Min(Monitor.Height * 3 div 4,
        FImageCtrl.Picture.Height + (ClientHeight - Panel.ClientHeight) + 10);
    end;
    ShowModal;
  finally
    Free;
  end;
end;

procedure TWOpenPictureDialog.PreviewClick(Sender: TObject);
begin
  ShowPreview(FImageCtrl);
end;

procedure TWOpenPictureDialog.TransformOptionsClick(Sender: TObject);
begin
  ShowTransformOptions;
end;

procedure TWOpenPictureDialog.PreviewConvertedClick(Sender: TObject);
begin
  ShowPreview(FWBMPImageCtrl);
end;

procedure TWOpenPictureDialog.PreviewKeyPress(Sender: TObject; var Key: Char);
begin
  case Key of
  #27: TForm(Sender).Close;
  {
  'N': DitherMode:= dmNearest;
  'F': DitherMode:= dmFloydSteinberg;
  'S': DitherMode:= dmStucki;
  'R': DitherMode:= dmSierra;
  'J': DitherMode:= dmJaJuNI;
  'A': DitherMode:= dmSteveArche;
  'B': DitherMode:= dmBurkes;
  }
  end;
end;

{ TSavePictureDialog }

function TWSavePictureDialog.Execute: Boolean;
begin
  if NewStyleControls and not (ofOldStyleDialog in Options) then
    Template := 'DLGTEMPLATE' else
    Template := nil;
  Result := DoExecute(@GetSaveFileName);
end;

function TWOpenPictureDialog.IsFilterStored: Boolean;
begin
  Result := not (Filter = GraphicFilter(TGraphic));
end;

procedure TWOpenPictureDialog.SetDitherMode(AValue: TDitherMode);
begin
  if FDitherMode = AValue
  then Exit;
  FDitherMode:= AValue;
  if Assigned(FImageCtrl.Picture) and (FImageCtrl.Picture.Width > 0)
  then DoDither;
  if FShowing and (FDitherModeSelect.Enabled) then begin
    FDitherModeSelect.OnChange:= Nil;
    FDitherModeSelect.ItemIndex:= Integer(FDitherMode);
    FDitherModeSelect.OnChange:= OnDitherModeChange;
  end;
end;

procedure TWOpenPictureDialog.SetImageTransformOptions(AValue: TTransformOptions);
begin
  if FImageTransformOptions = AValue
  then Exit;
  FImageTransformOptions:= AValue;
  if Assigned(FImageCtrl.Picture) and (FImageCtrl.Picture.Width > 0)
  then DoDither;
end;

procedure TWOpenPictureDialog.OnDitherModeChange(Sender: TObject);
begin
  DitherMode:= TDitherMode(FDitherModeSelect.ItemIndex);
end;

procedure TWOpenPictureDialog.OnPreviewClick(Sender: TObject);
var
  c: Integer;
begin
  if DitherMode < High(TDitherMode)
  then DitherMode:= Succ(DitherMode)
  else DitherMode:= Low(TDitherMode);
  for c:= 0 to FPreviewForm.ComponentCount - 1 do begin
    if FPreviewForm.Components[c].ClassType = TImage then begin
      TImage(FPreviewForm.Components[c]).Picture.Assign(FWBMPImageCtrl.Picture);
    end;
  end;
end;

procedure TWOpenPictureDialog.DoDither;
var
  TmpBitmap: TWBMPImage;
begin
  TmpBitmap:= TWBMPImage.Create;
  with TmpBitmap do begin
    DitherMode:= FDitherMode;
    TransformOptions:= FImageTransformOptions;
    Assign(FImageCtrl.Picture.Graphic);
    FWBMPImageCtrl.Picture.Assign(TmpBitmap);
    Free;
  end;  
end;

end.

unit fmain;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Menus, StdCtrls, ExtCtrls, ComCtrls, Dialogs, ImgList,
  Buttons, Registry,
  util1, customxml, xmlsupported, wml, wmlstyle, wmlbemulate, wmlurl,
  wmlbrowser, wmlbrowsersimple, wmlbrowserwin,
  browserutil;

const
//  DEFAULTEXAMPLEFILENAME = 'hint.wml#timer';
  DEFAULT_WSS_FILEEXTENSION = '.wss';
  DEFAULT_LST_FILEEXTENSION = '.lst';
  DEFAULT_WML_FILEEXTENSION = '.wml';

  DEFAULT_WSS_FILTER = 'wml device style sheet(*.wss)|*.wss|All files(*.*)|*.*';
  DEFAULT_LST_FILTER = 'wml device style properties list(*.lst)|*.lst|All files(*.*)|*.*';
  DEFAULT_WML_FILTER = 'wml file(*.wml)|*.wml|All files(*.*)|*.*';

  DEFAULT_OPENDIALOG_TITLE = 'Open wml device style sheet file';
  DEFAULT_SAVEDIALOG_TITLE = 'Save wml device style sheet file';
  DEFAULT_OPENLSTDIALOG_TITLE = 'Open wml device style properties list';
  DEFAULT_SAVELSTDIALOG_TITLE = 'Save wml device style properties list';
  DEFAULT_OPENSAMPLEDIALOG_TITLE = 'Open wml sample file';
//DEFAULT_SAVESAMPLEDIALOG_TITLE = 'Save wml sample file';

  DEFAULTEXAMPLEFILENAME = 'sample.wml#card1';
  DEFAULTSTYLEFILENAME   = 'default.wss';
  DEFAULTLSTFILENAME     = 'style.lst';

  { registry constants }
  APPNAME      = 'apoo editor';
  STYLEDITPART = 'Tools\StyleEdit';
  { version }
  LNVERSION = '1.0';
  { resource language }
  LNG = ''; { DLL language usa, 409 }
  { registry path }
  RGPATHMAIN      = '\Software\ensen\'+APPNAME+'\'+ LNVERSION;
  RGPATHSTYLEEDIT = '\Software\ensen\'+APPNAME+'\'+ LNVERSION + '\' + STYLEDITPART;

type
  TEditAttributeArray = array[0..CNT_STYLEATTRIBUTES - 1] of record
    StylePropertyName: String;
    E: TWinControl;
    B: TBitBtn;
    CB: TCheckBox;
  end;

  TFormMain = class(TForm)
    Splitter1: TSplitter;
    PanelLeft: TPanel;
    PanelRight: TPanel;
    PanelRightTop: TPanel;
    PanelRightBottom: TPanel;
    Splitter2: TSplitter;
    ListBox1: TListBox;
    MainMenu1: TMainMenu;
    ImageList1: TImageList;
    PanelProperty: TPanel;
    PageControl1: TPageControl;
    TabSheetAttributes: TTabSheet;
    TabSheetAttributesAsText: TTabSheet;
    MemoStyle: TMemo;
    LabelElement: TLabel;
    ScrollBoxAttributes: TScrollBox;
    MFileOpenstylesheetfile: TMenuItem;
    MFileSaveStyleSheet: TMenuItem;
    MFileSaveelementlist: TMenuItem;
    MFileLoadelementstylelist: TMenuItem;
    MViewSaveScreen: TMenuItem;
    MOptions: TMenuItem;
    MOptionsShowdisableenable: TMenuItem;
    MView: TMenuItem;
    MViewRefresh: TMenuItem;
    MFileD2: TMenuItem;
    MFileExit: TMenuItem;
    OpenDialog1: TOpenDialog;
    SaveDialog1: TSaveDialog;
    LStyleFileName: TLabel;
    MFileD1: TMenuItem;
    MFileD3: TMenuItem;
    LDevice: TLabel;
    LDeviceDesc: TLabel;
    MViewD1: TMenuItem;
    MViewWMLSource: TMenuItem;
    MFileD4: TMenuItem;
    MFileOpenSampleWmlFile: TMenuItem;
    MViewD2: TMenuItem;
    MViewControlSymbols: TMenuItem;
    TabSheet1: TTabSheet;
    ScrollBox1: TScrollBox;
    GBCharset: TGroupBox;
    LCharSetDesc: TLabel;
    CBCharSet: TComboBox;
    ScrollBoxBrowser: TPanel;
    LCoord: TLabel;
    LCoordDesc: TLabel;
    MFileValidateStyles: TMenuItem;
    Label1: TLabel;
    LMouseElement: TLabel;
    TSCoordinates: TTabSheet;
    MCoordinates: TMemo;
    Label2: TLabel;
    LLink: TLabel;
    procedure ListBox1DrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure FormCreate(Sender: TObject);
    procedure ListBox1Click(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Edit1Exit(Sender: TObject);
    procedure Edit1KeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure MFileOpenstylesheetfileClick(Sender: TObject);
    procedure MFileSaveStyleSheetClick(Sender: TObject);
    procedure PageControl1Change(Sender: TObject);
    procedure ButtonColorClick(Sender: TObject);
    procedure ButtonFontClick(Sender: TObject);
    procedure MFileSaveelementlistClick(Sender: TObject);
    procedure MFileLoadelementstylelistClick(Sender: TObject);
    procedure MViewSaveScreenClick(Sender: TObject);
    procedure MOptionsShowdisableenableClick(Sender: TObject);
    procedure MViewRefreshClick(Sender: TObject);
    procedure MFileExitClick(Sender: TObject);
    procedure MFileOpenSampleWmlFileClick(Sender: TObject);
    procedure MViewWMLSourceClick(Sender: TObject);
    procedure MViewControlSymbolsClick(Sender: TObject);
    procedure OnWmlBrowserMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure MFileValidateStylesClick(Sender: TObject);
  private
    { Private declarations }
    FWMLBrowser: TCustomWMLBrowser;
    FSrc: WideString;
    FBookmark: String;
    FEncoding: Integer;
    // FWMLElementStyles: TWMLElementStyles;
    FEditAttributeArray: TEditAttributeArray;
    FUsedColors: TStrings;
    FShowDisabled: Boolean;
    FStyleFileName: String;
    FSampleWMLURL: String;
    FxmlElementClass: TxmlElementClass;
    procedure FillNSortUsedColors;
    procedure ChangeButtonsView(AWMLElementStyle: TWMLElementStyle);
    procedure FillEditors(AWMLElementStyle: TWMLElementStyle);
    procedure CommitEdited;
    procedure RollbackEdited;
    procedure CreateEditors;
    procedure DestroyEditors;
    procedure SetStyleFileName(const AValue: String);
    procedure SetStyleListName(const AValue: String);
    procedure RefreshCoordinates;
    // show coordinates
    procedure CoordinatesCallback(var AxmlElement: TxmlElement);
  public
    { Public declarations }
    FWorkingFolder: String;
    FStyleListName: String;
    function GetCurrentElementClass: TxmlElementClass;
    function GetCurrentStyle: TWMLElementStyle;
    function LoadIni: Boolean;
    function StoreIni: Boolean;
    property StyleFileName: String read FStyleFileName write SetStyleFileName;
    property StyleListName: String read FStyleListName write SetStyleListName;
  end;

var
  FormMain: TFormMain;

implementation

uses fSource;

{$R *.DFM}

function TFormMain.GetCurrentElementClass: TxmlElementClass;
begin
  if Listbox1.ItemIndex < 0
  then Result:= Nil
  else Result:= TxmlElementClass(Listbox1.Items.Objects[Listbox1.ItemIndex]);
end;

function TFormMain.GetCurrentStyle: TWMLElementStyle;
begin
  Result:= Nil;
  if Listbox1.ItemIndex >= 0 then begin
    if FWMLBrowser is TWMLBrowserWin
    then Result:= TWMLBrowserWin(FWMLBrowser).WMLElementStyles.ItemsByClass[TxmlElementClass(Listbox1.Items.Objects[Listbox1.ItemIndex])]
  end;
end;

procedure TFormMain.ListBox1DrawItem(Control: TWinControl; Index: Integer;
  Rect: TRect; State: TOwnerDrawState);
var
  chw, chh, w: Integer;
  R: TRect;
begin

  with ListBox1, Canvas do begin
    w:= Rect.Right - Rect.Left + 1;
    Font.Style:= [];
    if odFocused in State
    then Brush.Color:= clCaptionText;
    if odChecked in State
    then Brush.Color:= clActiveCaption;
    if odDisabled in State
    then Brush.Color:= clInactiveBorder;
    if odGrayed in State
    then Brush.Color:= clGrayText;
    if odSelected in State then begin
      Brush.Color:= clActiveCaption;
      Font.Style:= [fsBold];
    end;
    R:= Rect;
    R.Right:= ItemHeight;
    FillRect(R);
    Pen.Color:= clWindowText;
    chh:= TextHeight('Wp');
    chw:= TextWidth(Items[Index]);
    R:= Rect;
    Inc(R.Left, ItemHeight);
    TextRect(R, R.Left + (W - ItemHeight - chw) div 2,
      R.Top + (ItemHeight - chh) div 2, Items[Index]);
    ImageList1.Draw(Canvas, Rect.Left + (ItemHeight - ImageList1.Width) div 2,
      Rect.Top + (ItemHeight - ImageList1.Height) div 2,
      GetBitmapIndexByClass(TPersistentClass(Listbox1.Items.Objects[Index])));
  end;
end;

procedure TFormMain.CreateEditors;
var
  w: TWincontrol;
  e, y: Integer;
  elable: TLabel;
  echeckbox: TCheckBox;
  eedit: TEdit;
  colorbutton,
  fontbutton: TBitBtn;
  ecombobox: TCombobox;
  chooselist: String;
  stylepropertiesenabled: TEnabledStylePropertySet;
  curWMLElementStyle: TWMLElementStyle;
begin
  w:= ScrollBoxAttributes;
  curWMLElementStyle:= GetCurrentStyle;
  if not Assigned(curWMLElementStyle)
  then Exit;
  stylepropertiesenabled:= curWMLElementStyle.EnabledStyleProperties;

  for e:= Low(wmlstyle.StyleIndexes) to High(wmlstyle.StyleIndexes) do begin
    // create enable/disable check
    if (not FShowDisabled) and (not (e in stylepropertiesenabled)) then begin
      FEditAttributeArray[e].E:= Nil;
      Continue;
    end;

    if FWMLBrowser is TWMLBrowserWin
    then chooselist:= TWMLBrowserWin(FWMLBrowser).WMLElementStyles[0].GetChooseListByIndex(e);
    FEditAttributeArray[e].StylePropertyName:= wmlstyle.StyleIndexes[e].Name;
    if Length(chooselist) = 0 then begin
      // no choose list
      eedit:= TEdit.Create(w);
      with eedit do begin
        HelpContext:= THelpContext(e);
        Parent:= w;
        Left:= 110;
        y:= e * Height + 2;
        Top:= y;
        Width:= 100;
        Text:= '';
        OnKeyDown:= Edit1KeyDown;
        OnExit:= Edit1Exit;
      end;
      FEditAttributeArray[e].E:= eedit;
    end else begin
      // have choose list, use combobox
      ecombobox:= TComboBox.Create(w);
      with ecombobox do begin
        HelpContext:= THelpContext(e);
        Parent:= w;
        Items.CommaText:= chooselist;
        Left:= 110;
        y:= e * Height + 2;
        Top:= y;
        Width:= 100;
        Text:= '';
        OnKeyDown:= Edit1KeyDown;
        OnExit:= Edit1Exit;
      end;
      FEditAttributeArray[e].E:= ecombobox;
    end;
    // create label
    elable:= TLabel.Create(Self);
    with elable do begin
      Caption:= wmlstyle.StyleIndexes[e].Name;
      Left:= 16;
      Top:= y;
      Parent:= w;
    end;
    // create enable/disable check
    if FShowDisabled then begin
      echeckbox:= TCheckBox.Create(Self);
      with echeckbox do begin
        Caption:= ''; // wmlstyle.StyleIndexes[e].Name;
        HelpContext:= e;
        Left:= 0;
        Width:= 14;
        Top:= y;
        Parent:= w;
      end;
      FEditAttributeArray[e].CB:= echeckbox;
    end;
    // create font or color select button
    case wmlstyle.StyleIndexes[e].Style of
      stFontFamily:begin
        fontbutton:= TBitBtn.Create(w);
        FEditAttributeArray[e].B:= fontbutton;
        with fontbutton do begin
          OnClick:= ButtonFontClick;
          HelpContext:= THelpContext(e);
          Caption:= '&f';
          Hint:= 'Font Dialog';
          ShowHint:= True;
          Left:= 210;
          Top:= y;
          Width:= 22;
          Height:= 22;
          Parent:= w;
        end;
      end;
      stColor:begin
        colorbutton:= TBitBtn.Create(w);
        FEditAttributeArray[e].B:= colorbutton;
        with colorbutton do begin
          Font.Style:= [fsBold];
          OnClick:= ButtonColorClick;
          HelpContext:= THelpContext(e);
          Caption:= '&c';
          Hint:= 'Color Dialog';
          ShowHint:= True;
          Left:= 210;
          Top:= y;
          Width:= 22;
          Height:= 22;
          Parent:= w;
        end;
      end;
    end;
  end;
end;

procedure TFormMain.DestroyEditors;
var
  w: TWincontrol;
  e: Integer;
begin
  w:= ScrollBoxAttributes;
  for e:= 0 to w.ControlCount - 1 do begin
    w.RemoveControl(w.Controls[0]);
  end;
end;

procedure TFormMain.SetStyleFileName(const AValue: String);
var
  s: String;
begin
  if FileExists(AValue)
  then FStyleFileName:= AValue
  else FStyleFileName:= DEFAULTSTYLEFILENAME;
  LStyleFileName.Caption:= FStyleFileName;
  if FWMLBrowser is TWMLBrowserWin then begin
    TWMLBrowserWin(FWMLBrowser).WMLElementStyles.StylesString:= util1.File2String(FStyleFileName);
    s:= TWMLBrowserWin(FWMLBrowser).WMLElementStyles.Comments;
  end;
  util1.DeleteControlsStr(s);
  LDeviceDesc.Caption:= s;
end;

procedure TFormMain.SetStyleListName(const AValue: String);
begin
  if FileExists(AValue)
  then FStyleListName:= AValue
  else FStyleListName:= DEFAULTLSTFILENAME;
end;

procedure TFormMain.CoordinatesCallback(var AxmlElement: TxmlElement);
var
  s: String;
begin
  with AxmlElement.DrawProperties, elR do begin
    s:= Format('%s'#9#9'(%d, %d) (%d, %d)', [AxmlElement.GetElementName, Left, Top, Right, Bottom]);
    s:= s + ' ' + Format(#9'(%d, %d) (%d, %d)', [
      AxmlElement.DrawProperties.elRM.Left, AxmlElement.DrawProperties.elRM.Top,
      AxmlElement.DrawProperties.elRM.Right, AxmlElement.DrawProperties.elRM.Bottom]);
    MCoordinates.Lines.Add(s);
    if AxmlElement is FxmlElementClass then begin  // or (AxmlElement is TxmlPCDATA)
      with FWMLBrowser.Canvas do begin
        Brush.Color:= clBlue;
        if AxmlElement is TWMLA
        then Brush.Color:= clNavy;
        if AxmlElement is TWMLPCData
        then Brush.Color:= clRed;
        if AxmlElement is TWMLCard
        then Brush.Color:= clPurple;

        Font.Size:= 8;
        Font.Name:= 'Arial';
        Font.Color:= clBlack;
        Font.Style:= [];

        Pen.Color:= Trunc(Random($FFFFFF)) ;
        Brush.Color:= Trunc(Random($FFFFFF)) ;

        TextOut(elRM.Left, elR.Top, AxmlElement.GetElementName);
        MoveTo(elR.Left, elR.Top);
        {
        Brush.Style:= bsFDiagonal;
        Rectangle(elR.Left, elR.Top, elR.Right, elR.Bottom);
        Brush.Style:= bsHorizontal;
        Rectangle(elRM.Left, elRM.Top, elRM.Right, elRM.Bottom);
        Brush.Style:= bsSolid;
        }
        PolyLine([Point(elR.Left, elR.Top), Point(elRM.Right, elR.Top),
          Point(elRM.Right, elRM.Bottom), Point(elR.Right, elRM.Bottom),
          Point(elR.Right, elR.Bottom), Point(elRM.Left, elR.Bottom),
          Point(elRM.Left, elRM.Top), Point(elR.Left, elRM.Top),
          Point(elR.Left, elR.Top)]);
      end;
    end;
  end;
end;

procedure TFormMain.RefreshCoordinates;
var
  card: TWMLCard;
begin
  MCoordinates.Lines.Clear;
  card:= FWMLBrowser.CurrentCardEl as TWMLCard;
  if Assigned (card) then begin
    card.ForEach(CoordinatesCallback);
  end;
end;

procedure TFormMain.FormCreate(Sender: TObject);
var
  e: Integer;
begin
  FUsedColors:= TStringList.Create;
  FShowDisabled:= False;

  FWMLBrowser:= TSimpleWMLBrowser.Create(ScrollBoxBrowser);
  with TSimpleWMLBrowser(FWMLBrowser) do begin
    // Font.Name:= 'Georgia';
    Font.Size:= 16;
  end;
  // FWMLBrowser:= TWMLBrowserWin.Create(ScrollBoxBrowser);
  with FWMLBrowser do begin
    Align:= alClient;
    Parent:= ScrollBoxBrowser;
    LoadIni;

    if FWMLBrowser is TWMLBrowserWin then with TWMLBrowserWin(FWMLBrowser) do begin
      WMLElementStyles.StylesString:= util1.File2String(FStyleFileName);
      WMLElementStyles.EnabledStylesPropertyString:= util1.File2String(StyleListName);
    end;
    ViewOptions:= [];

    wmlurl.GetSrcFromURI(FSampleWMLURL, FSrc, FBookmark, FEncoding);
    SetSrcPtr(PWideString(@FSrc));
    CurrentCard:= FBookmark;  // #card is deleted in there
    // refresh list of coordinates
    // RefreshCoordinates;

    FWMLBrowser.OnMouseMove:= OnWmlBrowserMouseMove;
  end;
  // fill elements list
  with Listbox1 do begin
    Items.Clear;
    Items.AddStrings(GetListOfElements(TwmlContainer));
    ItemIndex:= 0;   // GetCurrentStyle checks ItemIndex
  end;
  CreateEditors;
  // fill editors
  ListBox1Click(Self);
end;

{ load settings from registry }
function TFormMain.LoadIni: Boolean;
var
  Rg: TRegistry;

function RgPar(ParamName, DefaultValue: String): String;
var
  S: String;
begin
  try
    S:= Rg.ReadString(ParamName);
  except
  end;
  if S = ''
  then RgPar:= DefaultValue
  else RgPar:= S;
end;

begin
  Rg:= TRegistry.Create;
  Rg.RootKey:= HKEY_CURRENT_USER;// HKEY_LOCAL_MACHINE;
  if not Rg.OpenKey(RGPATHMAIN, False) then begin
    // create default values
    // first try open local machine registry
    Rg.RootKey:= HKEY_LOCAL_MACHINE;
    if Rg.OpenKey(RGPATHMAIN, False) then begin
    end else begin
    end;
  end;
  // configuration folder
  FWorkingFolder:= Rg.ReadString('ConfigDir');
  if Length(FWorkingFolder) = 0
  then FWorkingFolder:= GetCurrentDir;

  // other settings
  if Rg.OpenKey(RGPATHSTYLEEDIT, False) then begin
    // default style properties file name
    StyleFileName:= Rg.ReadString('StyleFileName');
    // style enabled properties list file name
    StyleListName:= Rg.ReadString('StyleListFileName');
    // sample filename and card
    FSampleWMLURL:= Rg.ReadString('WMLSampleURL');
  end else begin
  end;
  // set default values is values is not set
  // default style properties file name
  if StyleFileName = ''
  then StyleFileName:= ConcatPath(FWorkingFolder, DEFAULTSTYLEFILENAME);
  // style enabled properties list file name
  if StyleListName = ''
  then StyleListName:= ConcatPath(FWorkingFolder, DEFAULTLSTFILENAME);
  // sample filename and card
  if FSampleWMLURL = ''
  then FSampleWMLURL:= ConcatPath(FWorkingFolder, DEFAULTEXAMPLEFILENAME);

  Rg.Free;
  Result:= True;
end; { LoadIni }

function TFormMain.StoreIni: Boolean;
var
  Rg: TRegistry;
begin
  Result:= True;
  Rg:= TRegistry.Create;
  Rg.RootKey:= HKEY_CURRENT_USER; //HKEY_LOCAL_MACHINE;
  Rg.OpenKey(RGPATHMAIN, True);

//Rg.WriteString('ConfigDir', FWorkingFolder);
  // other settings
  if Rg.OpenKey(RGPATHSTYLEEDIT, True) then begin
    // default style properties file name
    Rg.WriteString('StyleFileName', StyleFileName);
    // style enabled properties list file name
    Rg.WriteString('StyleListFileName', StyleListName);
    // sample filename and card
    Rg.WriteString('WMLSampleURL', FSampleWMLURL);
  end else begin
  end;
  Rg.Free;
end; { StoreIni }

procedure TFormMain.ChangeButtonsView(AWMLElementStyle: TWMLElementStyle);
var
  e: Integer;
begin
  if not Assigned(AWMLElementStyle)
  then Exit;
  for e:= Low(FEditAttributeArray) to High(FEditAttributeArray) do begin
    case wmlstyle.StyleIndexes[e].Style of
      stColor:begin
        FEditAttributeArray[e].B.Font.Color:=
          GetColorByName(AWMLElementStyle.StyleStrByIndex[e], 0);
      end; { stColor }
      stFontFamily:begin
        FEditAttributeArray[e].B.Font.Assign(AWMLElementStyle.Font);
      end; { stFontFamily }
    end; { case }
  end; { for }
end;

procedure TFormMain.FillEditors(AWMLElementStyle: TWMLElementStyle);
var
  e: Integer;
  stylepropertiesenabled: TEnabledStylePropertySet;
begin
  if not Assigned (AWMLElementStyle)
  then Exit;
  stylepropertiesenabled:= AWMLElementStyle.EnabledStyleProperties;

  for e:= Low(FEditAttributeArray) to High(FEditAttributeArray) do begin
    if not Assigned(FEditAttributeArray[e].E)
    then Continue;
    if FEditAttributeArray[e].E is TEdit then begin
      with TEdit(FEditAttributeArray[e].E) do begin
        Text:= AWMLElementStyle.StyleStrByIndex[e];
      end;
    end;
    if FEditAttributeArray[e].E is TComboBox then begin
      with TComboBox(FEditAttributeArray[e].E) do begin
        Text:= AWMLElementStyle.StyleStrByIndex[e];
      end;
    end;

    // enable/disable check
    if FShowDisabled then begin
      if Assigned(FEditAttributeArray[e].CB) then begin
        with TCheckBox(FEditAttributeArray[e].CB) do begin
          Checked:= e in stylepropertiesenabled;
        end;
      end;
    end;
  end;
end;

procedure TFormMain.ListBox1Click(Sender: TObject);
var
  curWMLElementStyle: TWMLElementStyle;
begin
  FxmlElementClass:= TxmlElementClass(Listbox1.Items.Objects[Listbox1.ItemIndex]);
  RefreshCoordinates;
  curWMLElementStyle:= GetCurrentStyle;
  if not Assigned(curWMLElementStyle)
  then Exit;
  FillEditors(curWMLElementStyle);
  ChangeButtonsView(curWMLElementStyle);
  MemoStyle.Lines.Text:= curWMLElementStyle.GetStyleString;;
end;

procedure TFormMain.FormDestroy(Sender: TObject);
begin
  StoreIni;
  FWMLBrowser.Free;
  FUsedColors.Free;
end;

procedure TFormMain.CommitEdited;
var
  e: Integer;
  newval: String;
  elstyle: TWMLElementStyle;
begin
  elstyle:= GetCurrentStyle;
  if elStyle = Nil
  then Exit;
  for e:= Low(FEditAttributeArray) to High(FEditAttributeArray) do begin
    if FEditAttributeArray[e].E is TEdit
    then newval:= TEdit(FEditAttributeArray[e].E).Text;
    if FEditAttributeArray[e].E is TComboBox
    then newval:= TComboBox(FEditAttributeArray[e].E).Text;
    elstyle.StyleStrByIndex[e]:= newval;

    // enable/disable check
    if FShowDisabled then begin
      if Assigned(FEditAttributeArray[e].CB) then begin
        with TCheckBox(FEditAttributeArray[e].CB) do begin
          if Checked
          then elStyle.EnabledStyleProperties:= elStyle.EnabledStyleProperties + [e]
          else elStyle.EnabledStyleProperties:= elStyle.EnabledStyleProperties - [e];
        end;
      end;
    end;

  end;
  ChangeButtonsView(elStyle);
  FillEditors(elStyle);
  MemoStyle.Lines.Text:= GetCurrentStyle.GetStyleString;;
  FWMLBrowser.Repaint;
  // RollbackEdited;
end;

procedure TFormMain.RollbackEdited;
var
  e: Integer;
  newval: String;
  elstyle: TWMLElementStyle;
begin
  elstyle:= GetCurrentStyle;
  if elStyle = Nil
  then Exit;
  for e:= Low(FEditAttributeArray) to High(FEditAttributeArray) do begin
    newval:= elstyle.StyleStrByIndex[e];
    if FEditAttributeArray[e].E is TEdit
    then TEdit(FEditAttributeArray[e].E).Text:= newval;
    if FEditAttributeArray[e].E is TComboBox
    then TComboBox(FEditAttributeArray[e].E).Text:= newval;
  end;
end;

procedure TFormMain.FillNSortUsedColors;
var
  i: Integer;
  s: TWMLElementStyle;
  ch: Char;
begin
  FUsedColors.Clear;
  TStringList(FUsedColors).Sorted:= True;
  TStringList(FUsedColors).Duplicates:= dupIgnore;
  for i:= 0 to Listbox1.Items.Count - 1 do begin
    if FWMLBrowser is TWMLBrowserWin
    then s:= TWMLBrowserWin(FWMLBrowser).WMLElementStyles.ItemsByClass[TxmlElementClass(Listbox1.Items.Objects[i])];
    FUsedColors.Add(IntToHex(s.Brush.Color, 6));
    FUsedColors.Add(IntToHex(s.Font.Color, 6));
  end;
  TStringList(FUsedColors).Sorted:= False;
  Ch:= 'A';
  for i:= 0 to FUsedColors.Count - 1 do begin
    FUsedColors[i]:= Format('Color%s=%s', [ch, FUsedColors[i]]);
    Inc(ch);
  end;
end;

procedure TFormMain.Edit1Exit(Sender: TObject);
begin
  //
  CommitEdited;
end;

procedure TFormMain.Edit1KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  //
  case Key of
  VK_RETURN: CommitEdited;
  VK_ESCAPE: RollbackEdited;
  end;
end;

procedure TFormMain.MFileOpenstylesheetfileClick(Sender: TObject);
begin
  with OpenDialog1 do begin
    Title:= DEFAULT_OPENDIALOG_TITLE;
    DefaultExt:= DEFAULT_WSS_FILEEXTENSION;
    Filter:= DEFAULT_WSS_FILTER;
    Options:= Options - [ofAllowMultiSelect];
    InitialDir:= ExtractFilePath(StyleFileName);
    FileName:= ExtractFileName(StyleFileName);
    if OpenDialog1.Execute then begin
      StyleFileName:= FileName;
      ListBox1Click(Self);
    end;
  end;
end;

procedure TFormMain.MFileSaveStyleSheetClick(Sender: TObject);
begin
  with SaveDialog1 do begin
    Title:= DEFAULT_OPENDIALOG_TITLE;
    DefaultExt:= DEFAULT_WSS_FILEEXTENSION;
    Filter:= DEFAULT_WSS_FILTER;
    InitialDir:= ExtractFilePath(StyleFileName);
    FileName:= ExtractFileName(StyleFileName);
    Options:= Options - [ofAllowMultiSelect];
    if Execute then begin
      if FileExists(StyleFileName)
      then DeleteFile(StyleFileName);
      if FWMLBrowser is TWMLBrowserWin
      then util1.String2File(StyleFileName, TWMLBrowserWin(FWMLBrowser).WMLElementStyles.StylesString);
      // in that order, first store data to file then open it
      StyleFileName:= FileName;
    end;
  end;
end;

procedure TFormMain.MFileLoadelementstylelistClick(Sender: TObject);
begin
  with OpenDialog1 do begin
    Title:= DEFAULT_OPENLSTDIALOG_TITLE;
    DefaultExt:= DEFAULT_LST_FILEEXTENSION;
    Filter:= DEFAULT_LST_FILTER;
    Options:= Options - [ofAllowMultiSelect];
    InitialDir:= ExtractFilePath(StyleListName);
    FileName:= ExtractFileName(StyleListName);
    if OpenDialog1.Execute then begin
      StyleListName:= FileName;
      if FWMLBrowser is TWMLBrowserWin
      then TWMLBrowserWin(FWMLBrowser).WMLElementStyles.EnabledStylesPropertyString:=
        util1.File2String(StyleListName);
      ListBox1Click(Self);
    end;
  end;
end;

procedure TFormMain.MFileSaveelementlistClick(Sender: TObject);
begin
  with SaveDialog1 do begin
    Title:= DEFAULT_SAVELSTDIALOG_TITLE;
    DefaultExt:= DEFAULT_LST_FILEEXTENSION;
    Filter:= DEFAULT_LST_FILTER;
    InitialDir:= ExtractFilePath(StyleListName);
    FileName:= ExtractFileName(StyleListName);
    Options:= Options - [ofAllowMultiSelect];
    if Execute then begin
      StyleListName:= FileName;
      if FileExists(StyleListName)
      then DeleteFile(StyleListName);
      if FWMLBrowser is TWMLBrowserWin
      then util1.String2File(StyleListName, TWMLBrowserWin(FWMLBrowser).WMLElementStyles.EnabledStylesPropertyString);
    end;
  end;
end;

procedure TFormMain.PageControl1Change(Sender: TObject);
begin
  // refresh properties
  ListBox1Click(Self);
end;

procedure TFormMain.ButtonColorClick(Sender: TObject);
var
  ColorDialog: TColorDialog;
  SColor: TColor;
  no: Integer;
  elStyle: TWMLElementStyle;
begin
  // color dialog
  if not (Sender is TBitBtn)
  then Exit;
  elstyle:= GetCurrentStyle;
  no:= Integer(TBitBtn(Sender).HelpContext);
  SColor:= GetColorByName(elStyle.StyleStrByIndex[No], 0);
  ColorDialog:= TColorDialog.Create(Self);
  with ColorDialog do begin
    FillNSortUsedColors;
    ColorDialog.CustomColors:= FUsedColors;
    Color:= SColor;
    if Execute then begin
      SColor:= Color;
      elStyle.StyleStrByIndex[no]:= Format('#%x', [SColor]);
      TComboBox(FEditAttributeArray[no].E).Text:= elStyle.StyleStrByIndex[no];
      // TBitBtn(Sender).Font.Color:= SColor;
      FillEditors(GetCurrentStyle);
      ChangeButtonsView(GetCurrentStyle);
      MemoStyle.Lines.Text:= GetCurrentStyle.GetStyleString;;
      FWMLBrowser.Repaint;
    end;
  end;
  ColorDialog.Free;
end;

procedure TFormMain.ButtonFontClick(Sender: TObject);
var
  FontDialog: TFontDialog;
//  no: Integer;
  elStyle: TWMLElementStyle;
begin
  // font dialog
  if not (Sender is TBitBtn)
  then Exit;
  elstyle:= GetCurrentStyle;
//  no:= Integer(TBitBtn(Sender).HelpContext);
  FontDialog:= TFontDialog.Create(Self);
  with FontDialog do begin
    Font.Assign(elStyle.Font);
    if Execute then begin
      elStyle.Font.Assign(Font);
      // TBitBtn(Sender).Font.Assign(Font);
      FillEditors(GetCurrentStyle);
      MemoStyle.Lines.Text:= GetCurrentStyle.GetStyleString;;
      FWMLBrowser.Repaint;
      ChangeButtonsView(GetCurrentStyle);
     end;
  end;
  FontDialog.Free;
end;

procedure TFormMain.MViewSaveScreenClick(Sender: TObject);
begin
  if bvScreenSave in FWMLBrowser.ViewOptions
  then FWMLBrowser.ViewOptions:= FWMLBrowser.ViewOptions - [bvScreenSave]
  else FWMLBrowser.ViewOptions:= FWMLBrowser.ViewOptions + [bvScreenSave];
  MViewSaveScreen.Checked:= bvScreenSave in FWMLBrowser.ViewOptions;
end;

procedure TFormMain.MViewControlSymbolsClick(Sender: TObject);
begin
  if bvViewControlSymbols in FWMLBrowser.ViewOptions
  then FWMLBrowser.ViewOptions:= FWMLBrowser.ViewOptions - [bvViewControlSymbols]
  else FWMLBrowser.ViewOptions:= FWMLBrowser.ViewOptions + [bvViewControlSymbols];
  MViewControlSymbols.Checked:= bvViewControlSymbols in FWMLBrowser.ViewOptions;
end;

procedure TFormMain.MOptionsShowdisableenableClick(Sender: TObject);
begin
  FShowDisabled:= not FShowDisabled;
  MOptionsShowdisableenable.Checked:= FShowDisabled;
  ScrollBoxAttributes.Visible:= False;
  DestroyEditors;
  CreateEditors;
  // fill editors
  ListBox1Click(Self);
  ScrollBoxAttributes.Visible:= True;
end;

procedure TFormMain.MViewRefreshClick(Sender: TObject);
begin
  // refresh browser
  FWMLBrowser.Reload;
  // RefreshCoordinates;
end;

procedure TFormMain.MFileExitClick(Sender: TObject);
begin
  Close;
end;

procedure TFormMain.MFileOpenSampleWmlFileClick(Sender: TObject);
begin
  //
  with OpenDialog1 do begin
    Title:= DEFAULT_OPENSAMPLEDIALOG_TITLE;
    DefaultExt:= DEFAULT_WML_FILEEXTENSION;
    Filter:= DEFAULT_WML_FILTER;
    Options:= Options - [ofAllowMultiSelect];
    InitialDir:= ExtractFilePath(FSampleWMLURL);
    FileName:= ExtractFileName(FSampleWMLURL);
    if OpenDialog1.Execute then begin
      FSampleWMLURL:= FileName;
      wmlurl.GetSrcFromURI(FSampleWMLURL, FSrc, FBookmark, FEncoding);
      FWMLBrowser.SetSrcPtr(PWideString(@FSrc));
      FWMLBrowser.CurrentCard:= FBookmark;  // #card is deleted in there
      // ListBox1Click(Self);
      // refresh list of coordinates
      // RefreshCoordinates;
    end;
  end;
end;

procedure TFormMain.MViewWMLSourceClick(Sender: TObject);
var
  src: WideString;
  bookmark: String;
  encoding: Integer;
begin
  //
  wmlurl.GetSrcFromURI(FSampleWMLURL, src, bookmark, encoding);
  FormSource.MemoSource.Lines.Text:= src;
  FormSource.Visible:= True;
end;

procedure TFormMain.OnWmlBrowserMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var
  s: String;
  el: TxmlElement;
begin
  LCoordDesc.Caption:= Format('(%d, %d)', [x, y]);
  el:= FwmlBrowser.CurMouseElement;
  if Assigned(el) then begin
    s:= Format('%s', [el.GetElementName]);
  end else begin
    s:= 'none';
  end;
  LMouseElement.Caption:= s;

  el:= FwmlBrowser.CurMouseLinkElement;
  if Assigned(el) then begin
    s:= Format('%s', [el.Attributes.ValueByName['href']]);
  end else begin
    s:= 'none';
  end;

  LLink.Caption:= s;
end;

procedure TFormMain.MFileValidateStylesClick(Sender: TObject);
begin
  //
  if FWMLBrowser is TWMLBrowserWin
  then ValidateStyles(TWMLBrowserWin(FWMLBrowser).WMLElementStyles);
  FWMLBrowser.Reload;
end;

end.

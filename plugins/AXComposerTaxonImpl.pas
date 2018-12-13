unit AXComposerTaxonImpl;

{$WARN SYMBOL_PLATFORM OFF}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ActiveX, AxCtrls, AXComposerTaxonP_TLB, StdVcl, StdCtrls;

type
  TAXComposerTaxon = class(TActiveForm, IAXComposerTaxon)
    Memo1: TMemo;
  private
    { Private declarations }
    FEvents: IAXComposerTaxonEvents;
    procedure ActivateEvent(Sender: TObject);
    procedure ClickEvent(Sender: TObject);
    procedure CreateEvent(Sender: TObject);
    procedure DblClickEvent(Sender: TObject);
    procedure DeactivateEvent(Sender: TObject);
    procedure DestroyEvent(Sender: TObject);
    procedure KeyPressEvent(Sender: TObject; var Key: Char);
    procedure PaintEvent(Sender: TObject);
  protected
    { Protected declarations }
    procedure DefinePropertyPages(DefinePropertyPage: TDefinePropertyPage); override;
    procedure EventSinkChanged(const EventSink: IUnknown); override;
    function Get_Active: WordBool; safecall;
    function Get_AlignDisabled: WordBool; safecall;
    function Get_AutoScroll: WordBool; safecall;
    function Get_AutoSize: WordBool; safecall;
    function Get_AxBorderStyle: TxActiveFormBorderStyle; safecall;
    function Get_Caption: WideString; safecall;
    function Get_Color: OLE_COLOR; safecall;
    function Get_DoubleBuffered: WordBool; safecall;
    function Get_DropTarget: WordBool; safecall;
    function Get_Enabled: WordBool; safecall;
    function Get_Font: IFontDisp; safecall;
    function Get_HelpFile: WideString; safecall;
    function Get_KeyPreview: WordBool; safecall;
    function Get_PixelsPerInch: Integer; safecall;
    function Get_PrintScale: TxPrintScale; safecall;
    function Get_Scaled: WordBool; safecall;
    function Get_ScreenSnap: WordBool; safecall;
    function Get_SnapBuffer: Integer; safecall;
    function Get_Visible: WordBool; safecall;
    function Get_VisibleDockClientCount: Integer; safecall;
    procedure _Set_Font(var Value: IFontDisp); safecall;
    procedure AboutBox; safecall;
    procedure Set_AutoScroll(Value: WordBool); safecall;
    procedure Set_AutoSize(Value: WordBool); safecall;
    procedure Set_AxBorderStyle(Value: TxActiveFormBorderStyle); safecall;
    procedure Set_Caption(const Value: WideString); safecall;
    procedure Set_Color(Value: OLE_COLOR); safecall;
    procedure Set_DoubleBuffered(Value: WordBool); safecall;
    procedure Set_DropTarget(Value: WordBool); safecall;
    procedure Set_Enabled(Value: WordBool); safecall;
    procedure Set_Font(const Value: IFontDisp); safecall;
    procedure Set_HelpFile(const Value: WideString); safecall;
    procedure Set_KeyPreview(Value: WordBool); safecall;
    procedure Set_PixelsPerInch(Value: Integer); safecall;
    procedure Set_PrintScale(Value: TxPrintScale); safecall;
    procedure Set_Scaled(Value: WordBool); safecall;
    procedure Set_ScreenSnap(Value: WordBool); safecall;
    procedure Set_SnapBuffer(Value: Integer); safecall;
    procedure Set_Visible(Value: WordBool); safecall;
  public
    { Public declarations }
    procedure Initialize; override;
  end;

implementation

uses ComObj, ComServ, FComposerTaxonAbout;

{$R *.DFM}

{ TAXComposerTaxon }

procedure TAXComposerTaxon.DefinePropertyPages(DefinePropertyPage: TDefinePropertyPage);
begin
  { Define property pages here.  Property pages are defined by calling
    DefinePropertyPage with the class id of the page.  For example,
      DefinePropertyPage(Class_AXComposerTaxonPage); }
end;

procedure TAXComposerTaxon.EventSinkChanged(const EventSink: IUnknown);
begin
  FEvents := EventSink as IAXComposerTaxonEvents;
  inherited EventSinkChanged(EventSink);
end;

procedure TAXComposerTaxon.Initialize;
begin
  inherited Initialize;
  OnActivate := ActivateEvent;
  OnClick := ClickEvent;
  OnCreate := CreateEvent;
  OnDblClick := DblClickEvent;
  OnDeactivate := DeactivateEvent;
  OnDestroy := DestroyEvent;
  OnKeyPress := KeyPressEvent;
  OnPaint := PaintEvent;
end;

function TAXComposerTaxon.Get_Active: WordBool;
begin
  Result := Active;
end;

function TAXComposerTaxon.Get_AlignDisabled: WordBool;
begin
  Result := AlignDisabled;
end;

function TAXComposerTaxon.Get_AutoScroll: WordBool;
begin
  Result := AutoScroll;
end;

function TAXComposerTaxon.Get_AutoSize: WordBool;
begin
  Result := AutoSize;
end;

function TAXComposerTaxon.Get_AxBorderStyle: TxActiveFormBorderStyle;
begin
  Result := Ord(AxBorderStyle);
end;

function TAXComposerTaxon.Get_Caption: WideString;
begin
  Result := WideString(Caption);
end;

function TAXComposerTaxon.Get_Color: OLE_COLOR;
begin
  Result := OLE_COLOR(Color);
end;

function TAXComposerTaxon.Get_DoubleBuffered: WordBool;
begin
  Result := DoubleBuffered;
end;

function TAXComposerTaxon.Get_DropTarget: WordBool;
begin
  Result := DropTarget;
end;

function TAXComposerTaxon.Get_Enabled: WordBool;
begin
  Result := Enabled;
end;

function TAXComposerTaxon.Get_Font: IFontDisp;
begin
  GetOleFont(Font, Result);
end;

function TAXComposerTaxon.Get_HelpFile: WideString;
begin
  Result := WideString(HelpFile);
end;

function TAXComposerTaxon.Get_KeyPreview: WordBool;
begin
  Result := KeyPreview;
end;

function TAXComposerTaxon.Get_PixelsPerInch: Integer;
begin
  Result := PixelsPerInch;
end;

function TAXComposerTaxon.Get_PrintScale: TxPrintScale;
begin
  Result := Ord(PrintScale);
end;

function TAXComposerTaxon.Get_Scaled: WordBool;
begin
  Result := Scaled;
end;

function TAXComposerTaxon.Get_ScreenSnap: WordBool;
begin
  Result := ScreenSnap;
end;

function TAXComposerTaxon.Get_SnapBuffer: Integer;
begin
  Result := SnapBuffer;
end;

function TAXComposerTaxon.Get_Visible: WordBool;
begin
  Result := Visible;
end;

function TAXComposerTaxon.Get_VisibleDockClientCount: Integer;
begin
  Result := VisibleDockClientCount;
end;

procedure TAXComposerTaxon._Set_Font(var Value: IFontDisp);
begin
  SetOleFont(Font, Value);
end;

procedure TAXComposerTaxon.AboutBox;
begin
  ShowAXComposerTaxonAbout;
end;

procedure TAXComposerTaxon.ActivateEvent(Sender: TObject);
begin
  if FEvents <> nil then FEvents.OnActivate;
end;

procedure TAXComposerTaxon.ClickEvent(Sender: TObject);
begin
  if FEvents <> nil then FEvents.OnClick;
end;

procedure TAXComposerTaxon.CreateEvent(Sender: TObject);
begin
  if FEvents <> nil then FEvents.OnCreate;
end;

procedure TAXComposerTaxon.DblClickEvent(Sender: TObject);
begin
  if FEvents <> nil then FEvents.OnDblClick;
end;

procedure TAXComposerTaxon.DeactivateEvent(Sender: TObject);
begin
  if FEvents <> nil then FEvents.OnDeactivate;
end;

procedure TAXComposerTaxon.DestroyEvent(Sender: TObject);
begin
  if FEvents <> nil then FEvents.OnDestroy;
end;

procedure TAXComposerTaxon.KeyPressEvent(Sender: TObject; var Key: Char);
var
  TempKey: Smallint;
begin
  TempKey := Smallint(Key);
  if FEvents <> nil then FEvents.OnKeyPress(TempKey);
  Key := Char(TempKey);
end;

procedure TAXComposerTaxon.PaintEvent(Sender: TObject);
begin
  if FEvents <> nil then FEvents.OnPaint;
end;

procedure TAXComposerTaxon.Set_AutoScroll(Value: WordBool);
begin
  AutoScroll := Value;
end;

procedure TAXComposerTaxon.Set_AutoSize(Value: WordBool);
begin
  AutoSize := Value;
end;

procedure TAXComposerTaxon.Set_AxBorderStyle(
  Value: TxActiveFormBorderStyle);
begin
  AxBorderStyle := TActiveFormBorderStyle(Value);
end;

procedure TAXComposerTaxon.Set_Caption(const Value: WideString);
begin
  Caption := TCaption(Value);
end;

procedure TAXComposerTaxon.Set_Color(Value: OLE_COLOR);
begin
  Color := TColor(Value);
end;

procedure TAXComposerTaxon.Set_DoubleBuffered(Value: WordBool);
begin
  DoubleBuffered := Value;
end;

procedure TAXComposerTaxon.Set_DropTarget(Value: WordBool);
begin
  DropTarget := Value;
end;

procedure TAXComposerTaxon.Set_Enabled(Value: WordBool);
begin
  Enabled := Value;
end;

procedure TAXComposerTaxon.Set_Font(const Value: IFontDisp);
begin
  SetOleFont(Font, Value);
end;

procedure TAXComposerTaxon.Set_HelpFile(const Value: WideString);
begin
  HelpFile := String(Value);
end;

procedure TAXComposerTaxon.Set_KeyPreview(Value: WordBool);
begin
  KeyPreview := Value;
end;

procedure TAXComposerTaxon.Set_PixelsPerInch(Value: Integer);
begin
  PixelsPerInch := Value;
end;

procedure TAXComposerTaxon.Set_PrintScale(Value: TxPrintScale);
begin
  PrintScale := TPrintScale(Value);
end;

procedure TAXComposerTaxon.Set_Scaled(Value: WordBool);
begin
  Scaled := Value;
end;

procedure TAXComposerTaxon.Set_ScreenSnap(Value: WordBool);
begin
  ScreenSnap := Value;
end;

procedure TAXComposerTaxon.Set_SnapBuffer(Value: Integer);
begin
  SnapBuffer := Value;
end;

procedure TAXComposerTaxon.Set_Visible(Value: WordBool);
begin
  Visible := Value;
end;

initialization
  TActiveFormFactory.Create(
    ComServer,
    TActiveFormControl,
    TAXComposerTaxon,
    Class_AXComposerTaxon,
    1,
    '',
    OLEMISC_SIMPLEFRAME or OLEMISC_ACTSLIKELABEL,
    tmApartment);
end.

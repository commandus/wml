unit wmlAEdit;
(*##*)
(*******************************************************************
*                                                                  *
*   w  m  l  A  E  d  i  t                                         *
*   wireless markup language attribute editors                    *
*                                                                 *
*   Copyright © 2001, 2002 Andrei Ivanov. All rights reserved.     *
*                                                                 *
*   Conditional defines:                                           *
*                                                                 *
*   Revisions    : Jul 13 2001                                     *
*   Last revision:                                                *
*   Lines        : 691                                             *
*   History      :                                                *
*   Printed      : ---                                             *
*                                                                 *
********************************************************************)
(*##*)
{$IFDEF VER140}{$DEFINE DEF_PROP_EDITOR}{$ENDIF}
{$IFDEF VER150}{$DEFINE DEF_PROP_EDITOR}{$ENDIF}
{$IFDEF VER160}{$DEFINE DEF_PROP_EDITOR}{$ENDIF}
{$IFDEF VER170}{$DEFINE DEF_PROP_EDITOR}{Borland Delphi 2005}{$ENDIF}
{$IFDEF VER180}{$DEFINE DEF_PROP_EDITOR}{Turbo Delphi 2006}{$ENDIF}

interface
uses
  Classes, Windows, SysUtils, Controls, Graphics,
  Messages, stdctrls,
{$IFDEF DEF_PROP_EDITOR}
  Valedit,
{$ENDIF}
  comctrls, grids, customxml, wml;

// --------- TEditorHandler class definition  ---------

type
  TPropertyGrid = class;
  TEditorHandler = class;
  TxmlAttributeInplaceEdit = class;

  TEditorHandler = class (TObject)
  private
    FPropertyGrid: TPropertyGrid;
    FInplaceEdit: TxmlAttributeInplaceEdit;
    FFont: TFont;
    FUnitHeight: Integer;
    FUnitWidth: Integer;
    FControlHeight: Integer;
    FControlWidth: Integer;
    FxmlAttribute: TxmlAttribute;
    FEdit: TEdit;
    FCombobox: TCombobox;
    FMeasureUnitsCombobox: TComboBox;
    FUpDown: TUpDown;
    function GetPropertyGrid: TPropertyGrid;
  protected
    FOwner: TWinControl;
    procedure OnEditKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure OnEditExit(Sender: TObject);
    procedure OnComboBoxDrawItem(Control: TWinControl; Index: Integer; Rect: TRect; State: TOwnerDrawState);
    procedure OnComboBoxKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure OnComboBoxExit(Sender: TObject);
    procedure OnUDChange(Sender: TObject);
    procedure OnMeasureUnitChange(Sender: TObject);
  public
    constructor Create;
    destructor Destroy; override;
    property xmlAttribute: TxmlAttribute read FxmlAttribute write FxmlAttribute;
    property MeasureUnitsCombobox: TComboBox read FMeasureUnitsCombobox write FMeasureUnitsCombobox;
    property UpDown: TUpDown read FUpDown write FUpDown;
    property UnitHeight: Integer read FUnitHeight write FUnitHeight;
    property UnitWidth: Integer read FUnitWidth write FUnitWidth;
    property ControlHeight: Integer read FControlHeight write FUnitHeight;
    property ControlWidth: Integer read FControlWidth write FControlWidth;
    property Font: TFont read FFont write FFont;
    property PropertyGrid: TPropertyGrid read GetPropertyGrid write FPropertyGrid;
    property InplaceEdit: TxmlAttributeInplaceEdit read FInplaceEdit write FInplaceEdit;
    // actually created one or more controls
    function CreateAttributeEditorControl(AOwner: TWinControl; AR: TRect;
      AxmlAttribute: TxmlAttribute): Boolean;
    function DestroyAttributeEditorControl: Boolean;
  end;

// --------- TxmlAttributeInplaceEdit class definition  ---------

  TxmlAttributeInplaceEdit = class(TInplaceEdit)
  private
    FOwner: TWinControl;
    FBounds: TRect;
    FEditorHandler: TEditorHandler;
  protected
    // function EditCanModify: Boolean; override;
    // procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    // procedure KeyPress(var Key: Char); override;
    // procedure KeyUp(var Key: Word; Shift: TShiftState); override;
    procedure WndProc(var Message: TMessage); override;
    procedure BoundsChanged; override;
    procedure UpdateContents; override;
    // procedure WndProc(var Message: TMessage); override;
  public
    property Grid;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

// --------- TPropertyGrid class definition  ---------

  TPropertyGrid = class (TStringGrid)
  private
    FxmlElement: TxmlElement;
    FxmlAttributeInplaceEdit: TxmlAttributeInplaceEdit;
  protected
    procedure SetXMLElement(AxmlElement: TxmlElement);
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    function CreateEditor: TInplaceEdit; override;
    function SelectCell(ACol, ARow: Longint): Boolean; override;
    procedure DrawCell(ACol, ARow: Longint; ARect: TRect; AState: TGridDrawState); override;
  public
    constructor Create(AOwner: TComponent); override;
    property XMLElement: TxmlElement read FxmlElement write SetXMLElement;
    property Col;
    property Row;
  end;

{$IFDEF DEF_PROP_EDITOR}
// --------- TPropertyEditor class definition  ---------
  TPropertyEditor = class (TValueListEditor)
  private
    FxmlElement: TxmlElement;
    FHRefs: TStrings;
    FImageList: TImageList; // never used
  protected
    procedure SetXMLElement(AxmlElement: TxmlElement);
  public
    ExtLanguages: TStrings;
    procedure DoOnValidate; override;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property XMLElement: TxmlElement read FxmlElement write SetXMLElement;
    property ImageList: TImageList read FImageList write FImageList;
  end;
{$ENDIF}

implementation

uses
  util_xml, xmlsupported;

// extract 'lot' form 'list of tables<lot>'
// if no '<' '>' found, returns entire string
function ExtractAbbr(AValue: String): String;
var
  p, pe: Integer;
begin
  Result:= AValue;
  p:= Pos('<', AValue);
  if p > 0 then begin
    pe:= Pos('>', AValue);
    if pe <= 0 then pe:= Length(AValue) + 1;
    Result:= Copy(AValue, p + 1, pe - p - 1);
  end;
end;

procedure StripAbbrList(AList: TStrings);
var
  i: Integer;
begin
  for i:= 0 to AList.Count - 1 do begin
    AList[i]:= ExtractAbbr(AList[i]);
  end;
end;
// --------- TPropertyGrid class implementation  ---------

constructor TPropertyGrid.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FixedCols:= 1;
  FixedRows:= 0;
  ColCount:= 2;
  RowCount:= 1;
  Ctl3D:= False;
  Self.ColWidths[0]:= 100;
  Self.ColWidths[1]:= 500;
  DefaultRowHeight:= 18;
  Options:= [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine];
  ScrollBars:= ssVertical;
  FxmlElement:= Nil;
end;

procedure TPropertyGrid.SetXMLElement(AxmlElement: TxmlElement);
var
  e: Integer;
  v: String;
begin
  // HideEditor;
  EditorMode:= False;
  ColCount:= 2;
  FixedCols:= 1;
  FixedRows:= 0;
  FxmlElement:= AxmlElement;
  if not Assigned(FxmlElement) then begin
    RowCount:= 1;
    Exit;
  end;
  RowCount:= AxmlElement.Attributes.Count;
  for e:= 0 to AxmlElement.Attributes.Count - 1 do begin
    Cells[0, e]:= AxmlElement.Attributes[e].Name;
    v:= WMLExtractEntityStr(AxmlElement.Attributes[e].Value);
    if Length(v) = 0 then begin
      v:= AxmlElement.Attributes[e].DefaultValue;
    end else begin
    end;
    Cells[1, e]:= v;
  end;
  if Assigned(FxmlAttributeInplaceEdit)
  then FxmlAttributeInplaceEdit.UpdateContents;
  // ShowEditor;
  EditorMode:= True;
end;

function TPropertyGrid.SelectCell(ACol, ARow: Longint): Boolean;
var
  Attribute: TxmlAttribute;
  R: TRect;
begin
  Result:= inherited SelectCell(ACol, ARow);
  R:= CellRect(ACol, ARow);
  Attribute:= FxmlElement.Attributes[ARow];
  TxmlAttributeInplaceEdit(InplaceEditor).FEditorHandler.DestroyAttributeEditorControl;
  TxmlAttributeInplaceEdit(InplaceEditor).FEditorHandler.CreateAttributeEditorControl(Self, R, Attribute);
end;

procedure TPropertyGrid.DrawCell(ACol, ARow: Longint; ARect: TRect; AState: TGridDrawState);
var
  S: string;
begin
  S:= Cells[ACol, ARow];
  if DefaultDrawing then begin
    if Self.FxmlElement.Attributes[ARow].Required then begin
      Canvas.Font.Style:= [fsBold];
    end else begin
      Canvas.Font.Style:= [];
    end;
    ExtTextOut(Canvas.Handle, ARect.Left + 2, ARect.Top + 2, ETO_CLIPPED or
      ETO_OPAQUE, @ARect, PChar(S), Length(S), nil);
  end;
  // inherited DrawCell(ACol, ARow, ARect, AState);
end;

procedure TPropertyGrid.KeyDown(var Key: Word; Shift: TShiftState);
begin
  inherited KeyDown(Key, Shift);
end;

function TPropertyGrid.CreateEditor: TInplaceEdit;
begin
  FxmlAttributeInplaceEdit:= TxmlAttributeInplaceEdit.Create(Self);
  Result:= FxmlAttributeInplaceEdit;
end;

// --------- TEditorHandler class implementation  ---------

constructor TEditorHandler.Create;
begin
  inherited Create;
  FUnitHeight:= 10;
  FUnitWidth:= 10;
  FControlHeight:= 16;
  FControlWidth:= 100;
  FOwner:= Nil;
  FEdit:= Nil;
  FMeasureUnitsCombobox:= Nil;
  FUpDown:= Nil;
  FxmlAttribute:= Nil;
  FFont:= TFont.Create;
end;

destructor TEditorHandler.Destroy;
begin
  DestroyAttributeEditorControl;
  inherited Destroy;
end;

function TEditorHandler.GetPropertyGrid: TPropertyGrid;
begin
  if FPropertyGrid <> Nil then begin
    Result:= FPropertyGrid;
  end else begin
    if Assigned(FInplaceEdit) then begin
      Result:= FInplaceEdit.Grid as TPropertyGrid;
    end else begin
      Result:= Nil;
    end;
  end;
end;

procedure TEditorHandler.OnEditKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);

  procedure SendToParent;
  begin
    if GetPropertyGrid <> Nil
    then GetPropertyGrid.KeyDown(Key, Shift);
    Key := 0;
  end;

begin
  case Key of
  VK_UP, VK_DOWN, VK_PRIOR, VK_NEXT, VK_ESCAPE: SendToParent;
  VK_RETURN:begin
      FxmlAttribute.Value:= TEdit(Sender).Text;
    end;
  end; { case }
end;

procedure TEditorHandler.OnEditExit(Sender: TObject);
begin
  FxmlAttribute.Value:= TEdit(Sender).Text;
end;

procedure TEditorHandler.OnComboBoxDrawItem(Control: TWinControl; Index: Integer; Rect: TRect; State: TOwnerDrawState);
var
  idx, p, pe: Integer;      { text offset width }
  s: String;
begin
  // draw file types CheckListBox
  with TComboBox(Control).Canvas do begin
    // clear the rectangle
    FillRect(Rect);
    // get the bitmap
    idx:= Integer(TComboBox(Control).Items.Objects[Index]);

    // get full name (skip abbreviation such 'full item name<abbr>')
    s:= TComboBox(Control).Items[Index];
    p:= Pos('<', s);
    if p > 0 then begin
      pe:= Pos('>', s);
      if pe <= 0
      then pe:= Length(S);
      Delete(s, p, pe - p + 1);
    end;
    // add 4 pixels between bitmap and text
    TextOut(Rect.Left + 0 + 6, Rect.Top, s)  { display the text }
  end;
end;

procedure TEditorHandler.OnComboBoxKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  case Key of
  VK_RETURN:begin
      FxmlAttribute.Value:= ExtractAbbr(TComboBox(Sender).Text);
    end;
  end; { case }
end;

procedure TEditorHandler.OnComboBoxExit(Sender: TObject);
begin
  FxmlAttribute.Value:= ExtractAbbr(TComboBox(Sender).Text);
end;

procedure TEditorHandler.OnUDChange(Sender: TObject);
begin
  if FUpDown.Position >= 0 then begin
    FxmlAttribute.Value:= IntToStr(FUpDown.Position) + MeasureUnitsCombobox.Text;
  end else begin
    FxmlAttribute.Value:= ''; // or default?
  end;
end;

procedure TEditorHandler.OnMeasureUnitChange(Sender: TObject);
var
  s: String;
begin
  S:= MeasureUnitsCombobox.Text;
  if Pos('%', S) > 0 then begin
    FUpDown.Max:= 100;
    if FUpDown.Position > 0
    then FUpDown.Position:= 100;
  end else begin
    FUpDown.Max:= 32767;
  end;
  FxmlAttribute.Value:= S;
end;

function TEditorHandler.CreateAttributeEditorControl(AOwner: TWinControl; AR: TRect;
  AxmlAttribute: TxmlAttribute): Boolean;
begin
  FControlHeight:= AR.Bottom - AR.Top + 1;
  FControlWidth:=  AR.Right - AR.Left + 1;
  Result:= True;
  FEdit:= Nil;
  FCombobox:= Nil;
  FMeasureUnitsCombobox:= Nil;
  FUpDown:= Nil;

  if not Assigned(AxmlAttribute)
  then Exit;
  FOwner:= AOwner;
  FxmlAttribute:= AxmlAttribute;
  FMeasureUnitsCombobox:= Nil;
  case AxmlAttribute.AttrType of
  atVData: begin
      FCombobox:= TComboBox.Create(AOwner);
      with FCombobox do begin
        Width:= FControlWidth;
        // Height:= FControlHeight;
        Left:= AR.Left; Top:= AR.Top;
        Style:= csDropDown;
        if Length(AxmlAttribute.Value) = 0
        then Text:= AxmlAttribute.DefaultValue
        else Text:= AxmlAttribute.Value;
        // list of variables
        // FEdit.Items
        Style:= csOwnerDrawFixed;
        OnDrawItem:= OnComboBoxDrawItem;
        OnKeyDown:= OnComboBoxKeyDown;
        OnExit:= OnComboBoxExit;
        Parent:= AOwner;
      end;
    end;
  atCData: begin
      FEdit:= TEdit.Create(AOwner);
      with FEdit do begin
        Width:= ControlWidth;
        Height:= ControlHeight;
        Left:= AR.Left; Top:= AR.Top;
        if Length(AxmlAttribute.Value) = 0
        then Text:= AxmlAttribute.DefaultValue
        else Text:= AxmlAttribute.Value;
        OnKeyDown:= OnEditKeyDown;
        OnExit:= OnEditExit;
        Parent:= AOwner;
      end;
    end;
  atNumber: begin
      FEdit:= TEdit.Create(AOwner);
      with FEdit do begin
        Width:= ControlWidth - 2 * UnitWidth;
        Height:= ControlHeight;
        Left:= AR.Left; Top:= AR.Top;
        Parent:= AOwner;
      end;
      FUpDown:= TUpDown.Create(AOwner);
      FUpDown.Parent:= AOwner;
      with FUpDown do begin
        Width:= UnitWidth;
        Height:= ControlHeight;
        Left:= AR.Left + FEdit.Width + 0; Top:= AR.Top;
        Min:= -1;
        Max:= 32767;
        Associate:= FEdit;
        Parent:= AOwner;
      end;
      with FEdit do begin
        if Length(AxmlAttribute.Value) = 0
        then Text:= AxmlAttribute.DefaultValue
        else Text:= AxmlAttribute.Value;
        OnChange:= OnUDChange;
      end;
    end;
  atHref: begin
      FEdit:= TEdit.Create(AOwner);
      with FEdit do begin
        Width:= ControlWidth;
        Height:= ControlHeight;
        Left:= AR.Left; Top:= AR.Top;
        if Length(AxmlAttribute.Value) = 0
        then Text:= AxmlAttribute.DefaultValue
        else Text:= AxmlAttribute.Value;
        OnKeyDown:= OnEditKeyDown;
        OnExit:= OnEditExit;
        Parent:= AOwner;
      end;
    end;
  atLength: begin
      FEdit:= TEdit.Create(AOwner);
      with FEdit do begin
        Width:= ControlWidth  - 5 * UnitWidth;
        Height:= ControlHeight;
        Left:= AR.Left;
        Top:= AR.Top;
        Parent:= AOwner;
      end;
      FUpDown:= TUpDown.Create(AOwner);
      FUpDown.Parent:= AOwner;
      with FUpDown do begin
        Width:= UnitWidth;
        Height:= ControlHeight;
        Left:= AR.Left + FEdit.Width + 0;
        Top:= AR.Top;
        Min:= -1;
        Associate:= FEdit;
        Parent:= AOwner;
      end;
      // list of measure units
      MeasureUnitsCombobox:= TComboBox.Create(AOwner);
      MeasureUnitsCombobox.Parent:= AOwner;
      with MeasureUnitsCombobox do begin
        Width:= 3 * UnitWidth;
        // Height:= ControlHeight;
        Left:= AR.Left + FEdit.Width + FUpDown.Width + 0;
        Top:= AR.Top;
        Style:= csDropDownList;
        Items.Add('');
        Items.Add('%');
        if Pos('%', AxmlAttribute.Value) > 0 then begin
          ItemIndex:= 1;
          FComboBox.Text:= Copy(AxmlAttribute.Value, 1, Length(AxmlAttribute.Value) - 1);
          FUpDown.Max:= 100;
        end else begin
          ItemIndex:= 0;
          FComboBox.Text:= AxmlAttribute.Value;
          FUpDown.Max:= 32767;
        end;
        OnChange:= OnMeasureUnitChange;
        Parent:= AOwner;
      end;
      with FEdit do begin
        if Length(AxmlAttribute.Value) = 0
        then Text:= AxmlAttribute.DefaultValue
        else Text:= AxmlAttribute.Value;
        if Pos('%', Text) > 0
        then Text:= Copy(Text, 1, Length(Text) - 1);
        OnChange:= OnUDChange;
      end;
    end;
  atNMToken: begin
      FEdit:= TEdit.Create(AOwner);
      with FEdit do begin
        Width:= ControlWidth;
        Height:= ControlHeight;
        Left:= AR.Left;
        Top:= AR.Top;
        Text:= AxmlAttribute.Value;
        if Length(AxmlAttribute.Value) = 0
        then Text:= AxmlAttribute.DefaultValue
        else Text:= AxmlAttribute.Value;
        OnKeyDown:= OnEditKeyDown;
        OnExit:= OnEditExit;
        Parent:= AOwner;
      end;
    end;
  atID: begin
     FEdit:= TEdit.Create(AOwner);
      with FEdit do begin
        Width:= ControlWidth;
        Height:= ControlHeight;
        Left:= AR.Left;
        Top:= AR.Top;
        Text:= AxmlAttribute.Value;
        if Length(AxmlAttribute.Value) = 0
        then Text:= AxmlAttribute.DefaultValue
        else Text:= AxmlAttribute.Value;
        OnKeyDown:= OnEditKeyDown;
        OnExit:= OnEditExit;
        Parent:= AOwner;
      end;
    end;
  atList, atNoStrictList: begin
      FComboBox:= TComboBox.Create(AOwner);
      with FComboBox do begin
        Width:= ControlWidth;
        // Height:= ControlHeight;
        Left:= AR.Left;
        Top:= AR.Top;
        if Length(AxmlAttribute.Value) = 0
        then Text:= AxmlAttribute.DefaultValue
        else Text:= AxmlAttribute.Value;
        // list of
        Parent:= AOwner; // importtant to Assign
        Items.Assign(AxmlAttribute.List);
        OnKeyDown:= OnComboBoxKeyDown;
        OnExit:= OnComboBoxExit;
        Parent:= AOwner;
      end;
    end;
  atColor: begin
      FComboBox:= TComboBox.Create(AOwner);
      with FComboBox do begin
        Width:= ControlWidth;
        // Height:= ControlHeight;
        Left:= AR.Left;
        Top:= AR.Top;
        if Length(AxmlAttribute.Value) = 0
        then Text:= AxmlAttribute.DefaultValue
        else Text:= AxmlAttribute.Value;
        // list of
        Parent:= AOwner; // importtant to Assign
        Items.Assign(xmlsupported.HTMLColorNames);
        FComboBox.
        OnKeyDown:= OnComboBoxKeyDown;
        OnExit:= OnComboBoxExit;
        Parent:= AOwner;
      end;
    end;
  end; { case }
  if Assigned(FMeasureUnitsCombobox) then with FMeasureUnitsCombobox do begin
    Font:= FFont;
  end;
  if Assigned(FUpDown) then with FUpDown do begin
  end;
  if Assigned(FCombobox) then with FCombobox do begin
    Font:= FFont;
    DropDownCount:= Items.Count;
    SetFocus;
  end;
  if Assigned(FEdit) then with FEdit do begin
    Font:= FFont;
    SetFocus;
  end;
end;

function TEditorHandler.DestroyAttributeEditorControl: Boolean;
begin
  if Assigned(FEdit)
  then FEdit.Free;
  if Assigned(FCombobox)
  then FCombobox.Free;
  if Assigned(FMeasureUnitsCombobox)
  then FMeasureUnitsCombobox.Free;
  if Assigned(FUpDown)
  then FUpDown.Free;
  FEdit:= Nil;
  FCombobox:= Nil;
  FMeasureUnitsCombobox:= Nil;
  FUpDown:= Nil;
  Result:= True;
end;

// --------- TxmlAttributeInplaceEdit class implementation  ---------

constructor TxmlAttributeInplaceEdit.Create(AOwner: TComponent);
begin
  with FBounds do begin
    Left:= 0;
    Right:= 0;
    Top:= 0;
    Bottom:= 0;
  end;
  inherited Create(AOwner);
  FOwner:= TWinControl(AOwner);
  FEditorHandler:= TEditorHandler.Create;
  FEditorHandler.FInplaceEdit:= Self;
  Self.Enabled:= False;
end;

destructor TxmlAttributeInplaceEdit.Destroy;
begin
  FEditorHandler.Free;
  inherited Destroy;
end;

procedure TxmlAttributeInplaceEdit.WndProc(var Message: TMessage);
begin
  inherited WndProc(Message);
end;

procedure TxmlAttributeInplaceEdit.BoundsChanged;
begin
  inherited BoundsChanged;
  {
  FBounds := Rect(2, 2, Width - 2, Height);
  SendMessage(Handle, EM_SETRECTNP, 0, LongInt(@FBounds));
  SendMessage(Handle, EM_SCROLLCARET, 0, 0);
  }
end;

procedure TxmlAttributeInplaceEdit.UpdateContents;
var
  Attribute: TxmlAttribute;
  R: TRect;
  PropertyGrid: TPropertyGrid;
begin
//  inherited UpdateContents;
  PropertyGrid:= FEditorHandler.GetPropertyGrid;
  if PropertyGrid <> Nil then with PropertyGrid do begin
    R:= CellRect(1, Row);
    Attribute:= FxmlElement.Attributes[Row];
    FEditorHandler.DestroyAttributeEditorControl;
//    FEditorHandler.CreateAttributeEditorControl(Self, R, Attribute);
  end;
end;

{$IFDEF DEF_PROP_EDITOR}

// --------- TPropertyEditor class implementation  ---------

constructor TPropertyEditor.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FxmlElement:= Nil;
  ExtLanguages:= Nil;
  FHRefs:= TStringList.Create;
  FImageList:= Nil;
  with TStringList(FHRefs) do begin
    Duplicates:= dupIgnore;
    Sorted:= True;
  end;
end;

destructor TPropertyEditor.Destroy;
begin
  // if Assigned(FxmlElement) then;
  FHRefs.Free;
  inherited Destroy;
end;

// just increase visibility
procedure TPropertyEditor.DoOnValidate;
begin
  inherited;
end;

procedure TPropertyEditor.SetXMLElement(AxmlElement: TxmlElement);
var
  e: Integer;
  sl: TValueListStrings;
begin
  HideEdit;
  FxmlElement:= AxmlElement;
  // assign list of attributes
  sl:= TValueListStrings.Create(Nil);
  if not Assigned(FxmlElement) then begin
    Strings:= sl;
    sl.Free;
    Exit;
  end;
  // refresh href list
  FHRefs.Clear;
  AxmlElement.Root.GetListHrefs(FHRefs);
  for e:= 0 to AxmlElement.Attributes.Count - 1 do begin
    sl.Add(AxmlElement.Attributes[e].Name + '=' + WMLExtractEntityStr(AxmlElement.Attributes[e].Value));
    with AxmlElement.Attributes[e] do begin
      case AttrType of
        atCData, atVData: begin
          // if CompareText('format', AxmlElement.Attributes[e].Name) = 0 then
          sl.ItemProps[e].EditStyle:= esEllipsis;
        end;
        atList, atNoStrictList: begin
          StripAbbrList(List);
          sl.ItemProps[e].PickList.Assign(List);
        end;
        atLang: sl.ItemProps[e].PickList.Assign(ExtLanguages);
        atHRef: begin
            if AxmlElement.ClassType = TWMLImg then begin
              sl.ItemProps[e].EditStyle:= esEllipsis;
            end else begin
              sl.ItemProps[e].PickList.Assign(FHRefs);
            end;
          end;
        atColor: sl.ItemProps[e].PickList.Assign(xmlsupported.HTMLColorNames);
      end;
    end;
  end;
  // DoOnValidate redeclared to increase visibility to immediate calls
  // validates before assign new values.
  //  DoOnValidate;   - do not uncomment this, else chahes made in old element and new selected twice
  // set that editor is not changed
  InplaceEditor.Modified:= False;
  // assign new element attributes
  Strings:= sl;  // can call DoOnValidate, but inplace editor is not modified.
  sl.Free;

  // validate default values
  {
  for e:= 0 to AxmlElement.Attributes.Count - 1 do begin
    if Length(AxmlElement.Attributes[e].Value) = 0 then begin
      Cells[0 or 1 ?, e]:= AxmlElement.Attributes[e].DefaultValue;
    end;
  end;
  }
end;
{$ENDIF}

end.

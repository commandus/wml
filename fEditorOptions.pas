unit
  fEditorOptions;
(*##*)
(*******************************************************************************
*                                                                              *
*   f  E  d  i  t  o  r  O  p  t  i  o  n  s                                  *
*   Editor options dialog window, part of apooed                               *
*                                                                             *
*   Copyright©2001-2004 Andrei Ivanov. All rights reserved.                    *
*                                                                             *
*   Conditional defines:                                                       *
*                                                                             *
*   Revisions    : Apr 13 2002                                                 *
*   Last revision:                                                            *
*   Lines        : 213                                                         *
*   History      :                                                            *
*   Printed      : ---                                                         *
*                                                                             *
********************************************************************************)
(*##*)

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ComCtrls,
  util_xml, EMemo, EMemoWMLCode;

type
  TFormEditorOptions = class(TForm)
    PC1: TPageControl;
    TSDisplay: TTabSheet;
    TSColor: TTabSheet;
    PanelBottom: TPanel;
    BOk: TButton;
    BCancel: TButton;
    GBMarginAndGutter: TGroupBox;
    CBVisibleRightMargin: TCheckBox;
    CBVisibleGutter: TCheckBox;
    ERightMargin: TEdit;
    EGutterWidth: TEdit;
    UDRightMargin: TUpDown;
    UDGutterWidth: TUpDown;
    GBFont: TGroupBox;
    LFont: TLabel;
    BFont: TButton;
    EFontSample: TEdit;
    CBUseBoldTags: TCheckBox;
    GBBlockIndent: TGroupBox;
    EBlockIndent: TEdit;
    UDBlockIndent: TUpDown;
    LBlockIndent: TLabel;
    LSample: TLabel;
    CBFontName: TComboBox;
    EFontSize: TEdit;
    UDFontSize: TUpDown;
    LSize: TLabel;
    GroupBox1: TGroupBox;
    PanelColorBottom: TPanel;
    PanelColorTop: TPanel;
    LBElements: TListBox;
    Label1: TLabel;
    ColorBox1: TColorBox;
    Label2: TLabel;
    GBAutoComplete: TGroupBox;
    CBAutoComplete: TCheckBox;
    CBCompileModifiedAtDelay: TCheckBox;
    LCompileModifiedAtDelay: TLabel;
    CBCompileBeforeSave: TCheckBox;
    CBNumerateLines: TCheckBox;
    TSHighlight: TTabSheet;
    GBhighlighting: TGroupBox;
    CBHighlightTag: TCheckBox;
    CBHighlightSTag: TCheckBox;
    CBHighlightEntity: TCheckBox;
    UDAutoComplete: TUpDown;
    EAutoComplete: TEdit;
    LAutoCompleteSec: TLabel;
    TSHighlightAutoConversion: TTabSheet;
    GBLoading: TGroupBox;
    CBEntities2Char: TCheckBox;
    GroupBox2: TGroupBox;
    CBChar2Entities: TCheckBox;
    CBLoadRefCharset: TCheckBox;
    CBSaveRefCharset: TCheckBox;
    procedure BFontClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure CBFontChange(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure LBElementsClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure ColorBox1Change(Sender: TObject);
  private
    { Private declarations }
    FFontControlDontReact: Boolean;
    FMemoWMLCode: TEMemoWMLCode;
  public
    { Public declarations }
    MemoSample: TEMemo;
  end;

var
  FormEditorOptions: TFormEditorOptions;

implementation

{$R *.dfm}

uses
  dm;

resourcestring
  RES_WMLCOLORSAMPLE = '<wml>'#13#10'  <card>'#13#10'    <p>'#13#10 +
    '      Sample text'#13#10'    </p>'#13#10'  </card>'#13#0'</wml>';

procedure TFormEditorOptions.BFontClick(Sender: TObject);
begin
  with dm1.FontDialog1 do begin
    Font:= EFontSample.Font;
    if Execute then begin
      FFontControlDontReact:= True;
      EFontSample.Font:= Font;
      CBFontName.ItemIndex:= CBFontName.Items.IndexOf(Font.Name);
      UDFontSize.Position:= Font.Size;
      FFontControlDontReact:= False;
    end;
  end;
end;

procedure TFormEditorOptions.FormCreate(Sender: TObject);
var
  p: TPoint;
begin
  //
  CBFontName.Items:= Screen.Fonts;
  FFontControlDontReact:= True;
  UDFontSize.Position:= EFontSample.Font.Size;
  CBFontName.ItemIndex:= CBFontName.Items.IndexOf(EFontSample.Font.Name);
  FFontControlDontReact:= False;

  FMemoWMLCode:= TEMemoWMLCode.Create(Nil);
  MemoSample:= TEMemo.Create(Nil);
  with MemoSample do begin
    TextInCharacterset[convNone]:= RES_WMLCOLORSAMPLE;
    p.x:= 1;
    p.y:= 2;
    SelBegin:= p;
    p.x:= 2;
    p.y:= 3;
    SelEnd:= p;
    Selected:= True;
    Name:= 'EMemoColorSample';
    Align:= alClient;
    Parent:= PanelColorBottom;
    Enabled:= False;
    RightEdgeCol:= 10;
    RightEdge:= True;
    FMemoWMLCode.CxMemo:= MemoSample;
    // Visible:= True;
  end;
end;

procedure TFormEditorOptions.CBFontChange(Sender: TObject);
begin
  if FFontControlDontReact
  then Exit;
  EFontSample.Font.Name:= CBFontName.Text;
  EFontSample.Font.Size:= UDFontSize.Position;
end;

procedure TFormEditorOptions.FormDestroy(Sender: TObject);
begin
  MemoSample.Free;
  // FMemoSample:= Nil;
  FMemoWMLCode.Free;
end;

procedure TFormEditorOptions.LBElementsClick(Sender: TObject);
begin
  with MemoSample.EnvironmentOptions do begin
    case LBElements.ItemIndex of
      0: ColorBox1.Selected:= TextColor;
      1: ColorBox1.Selected:= TextBackground;
      2: ColorBox1.Selected:= SelectionColor;
      3: ColorBox1.Selected:= SelectionBackground;
      4: ColorBox1.Selected:= Hyperlink;
      5: ColorBox1.Selected:= HyperlinkBackground;
      6: ColorBox1.Selected:= RightEdgeColor;
    end; { case }
  end;
end;

procedure TFormEditorOptions.FormActivate(Sender: TObject);
begin
  LBElements.ItemIndex:= 0;
  LBElements.OnClick(Self);
  BOk.SetFocus;
end;

procedure TFormEditorOptions.ColorBox1Change(Sender: TObject);
begin
  with MemoSample.EnvironmentOptions do begin
    case LBElements.ItemIndex of
      0: TextColor:= ColorBox1.Selected;
      1: TextBackground:= ColorBox1.Selected;
      2: SelectionColor:= ColorBox1.Selected;
      3: SelectionBackground:= ColorBox1.Selected;
      4: Hyperlink:= ColorBox1.Selected;
      5: HyperlinkBackground:= ColorBox1.Selected;
      6: RightEdgeColor:= ColorBox1.Selected;
    end; { case }
  end;
end;

end.

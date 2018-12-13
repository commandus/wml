unit fAskFormat;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, StdCtrls, ExtCtrls;

type
  TFormFormatSource = class(TForm)
    BOk: TButton;
    BCancel: TButton;
    GroupBox1: TGroupBox;
    CBRightMargin: TCheckBox;
    ERightMargin: TEdit;
    UDRightMargin: TUpDown;
    PanelTop: TPanel;
    L1: TLabel;
    L2: TLabel;
    CBCompressSpaces: TCheckBox;
    EBlockIndent: TEdit;
    UDBlockIndent: TUpDown;
    LBlockIndent: TLabel;
    procedure CBRightMarginClick(Sender: TObject);
    procedure CBRightMarginKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormActivate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormFormatSource: TFormFormatSource;

implementation

{$R *.dfm}

procedure TFormFormatSource.CBRightMarginClick(Sender: TObject);
begin
  UDRightMargin.Visible:= CBRightMargin.Checked;
  ERightMargin.Visible:= UDRightMargin.Visible;
end;

procedure TFormFormatSource.CBRightMarginKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  CBRightMarginClick(Self);
end;

procedure TFormFormatSource.FormActivate(Sender: TObject);
begin
  CBRightMargin.SetFocus;
end;

end.

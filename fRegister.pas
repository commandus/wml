unit FRegister;
(*##*)
(*******************************************************************
*                                                                  *
*   F  R  E  G  I  S  T  E  R                                     *
*   register form of CVRT2WBMP, part of CVRT2WBMP                  *
*                                                                 *
*   Copyright © 2001, 2002 Andrei Ivanov. All rights reserved.     *
*                                                                 *
*   Conditional defines:                                           *
*                                                                 *
*   Revisions    : Jun 07 2001                                     *
*   Last revision: Mar 29 2002                                    *
*   Lines        : 78                                              *
*   History      :                                                *
*   Printed      : ---                                             *
*                                                                 *
********************************************************************)
(*##*)

interface

uses
  Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls,
  Buttons, Registry, ExtCtrls, ClipBrd;

type
  TFormRegister = class(TForm)
    BCancel: TButton;
    GBStep1: TGroupBox;
    BDetails: TButton;
    BRegister: TButton;
    GBStep2: TGroupBox;
    Label3: TLabel;
    LName: TLabel;
    Label1: TLabel;
    ERegCode0: TEdit;
    EUserName: TEdit;
    EProduct: TEdit;
    ERegCode1: TEdit;
    ERegCode2: TEdit;
    ERegCode3: TEdit;
    ERegCode4: TEdit;
    BEnterCode: TButton;
    MDesc: TMemo;
    Label2: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    ERegcode5: TEdit;
    Label7: TLabel;
    Label8: TLabel;
    procedure BRegisterClick(Sender: TObject);
    procedure BDetailsClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Label8Click(Sender: TObject);
  private
    { Private declarations }
    function GetRegCode: String;
    procedure SetRegCode(const AValue: String);
  public
    { Public declarations }
    property RegCode: String read GetRegCode write SetRegCode;
  end;

var
  FormRegister: TFormRegister;

implementation

{$R *.DFM}

uses
  appconst, util1;

procedure TFormRegister.BRegisterClick(Sender: TObject);
begin
  util1.EExecuteFile(REGISTER_URL);
end;

procedure TFormRegister.BDetailsClick(Sender: TObject);
begin
  util1.EExecuteFile(REGISTER_HOWTO_URL);
end;

procedure TFormRegister.FormCreate(Sender: TObject);
begin
  // EManufacturer.Text:= FParameters.Values[ParameterNames[ID_MANUFACTURER]];
  EProduct.Text:= REGISTER_PRODUCTCODE;
  // ERegCode.Text:= Values[ParameterNames[ID_CODE]];
end;

function TFormRegister.GetRegCode: String;
begin
  Result:= ERegCode0.Text + ERegCode1.Text + ERegCode2.Text + ERegCode3.Text + ERegCode4.Text + ERegCode5.Text;
end;

procedure TFormRegister.SetRegCode(const AValue: String);
var
  v: String;
begin
  // remove spaces and '-' if exists
  v:= AValue;
  util1.DeleteLeadTerminateDoubledSpaceStr(v);
  while util1.ReplaceStr(v, False, '-', '') do;

  ERegCode0.Text:= Copy(v, 1, 5);
  ERegCode1.Text:= Copy(v, 6, 5);
  ERegCode2.Text:= Copy(v, 11, 5);
  ERegCode3.Text:= Copy(v, 16, 5);
  ERegCode4.Text:= Copy(v, 21, 5);
  ERegCode5.Text:= Copy(v, 26, 5);
end;

procedure TFormRegister.Label8Click(Sender: TObject);
begin
  RegCode:= Clipboard.AsText;
end;

end.

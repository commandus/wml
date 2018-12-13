unit
  fsettings;
(*##*)
(*******************************************************************
*                                                                 *
*   f  s  e  t  t  i  n  g  s                                      *
*                                                                 *
*   Copyright © 2002 Andrei Ivanov. All rights reserved.           *
*   server extension test program                                 *
*   Conditional defines: see fmain.pas                             *
*                                                                 *
*   Revisions    : May 27 2002                                     *
*   Last fix     : May 27 2002                                    *
*   Lines        : 47                                              *
*   History      :                                                *
*   Printed      : ---                                             *
*                                                                 *
********************************************************************)
(*##*)

interface

uses
  Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls,
  Buttons, ExtCtrls;

type
  TFormSettings = class(TForm)
    OKBtn: TButton;
    CancelBtn: TButton;
    RGDriver: TRadioGroup;
    GBCommon: TGroupBox;
    CBCompileAfterOpen: TCheckBox;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormSettings: TFormSettings;

implementation

{$R *.dfm}

end.

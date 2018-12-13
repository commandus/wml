unit fInformation;
(*##*)
(*******************************************************************************
*                                                                             *
*   f  i  n  f  o  r  m  a  t  o  n                                            *
*                                                                             *
*   Copyright © 2001-2003 Andrei Ivanov. All rights reserved.                  *
*   wml infowmation dialog window, part of apooed                             *
*   Conditional defines:                                                       *
*                                                                             *
*   Revisions    : Sep 19 2001                                                 *
*   Last revision: Mar 29 2002                                                *
*   Lines        : 54                                                          *
*   History      :                                                            *
*   Printed      : ---                                                         *
*                                                                             *
********************************************************************************)
(*##*)

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls;

type
  TFormInfo = class(TForm)
    PanelMemo: TPanel;
    Panel2: TPanel;
    BOk: TButton;
    MemoInfo: TMemo;
    PanelTop: TPanel;
    LInfo: TLabel;
    BCancel: TButton;
    procedure FormActivate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormInfo: TFormInfo;

implementation

{$R *.dfm}

procedure TFormInfo.FormActivate(Sender: TObject);
begin
  BOk.SetFocus;
end;

end.

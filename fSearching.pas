unit
  fSearching;
(*##*)
(*******************************************************************************
*                                                                             *
*   f  s  e  a  r  c  h  i  n  g                                               *
*                                                                             *
*   Copyright © 2001-2003 Andrei Ivanov. All rights reserved.                  *
*   wireless markup language classes                                          *
*   Conditional defines:                                                       *
*                                                                             *
*   Revisions    : Jul 06 2001, Oct 11 2001                                    *
*   Last revision: Mar 29 2002                                                *
*   Lines        : 47                                                          *
*   History      : see todo file                                              *
*                                                                              *
*                                                                             *
*   Printed      :                                                             *
*                                                                             *
********************************************************************************)
(*##*)

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls;

type
  TFormSearching = class(TForm)
    PanelIndicator: TPanel;
    PanelBottom: TPanel;
    BCancel: TButton;
    LabelIndicator: TLabel;
    procedure BCancelClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormSearching: TFormSearching;

implementation

{$R *.dfm}

procedure TFormSearching.BCancelClick(Sender: TObject);
begin
  Visible:= False;
end;

end.

unit fFloating;
(*##*)
(*******************************************************************
*                                                                 *
*   f  f  l  o  a  t  i  n  g                                      *
*                                                                 *
*   Copyright © 2001, 2002 Andrei Ivanov. All rights reserved.     *
*   Floating window class implementation                          *
*   Conditional defines:                                           *
*                                                                 *
*   Revisions    : Sep 19 2001                                     *
*   Last revision: Mar 29 2002                                    *
*   Lines        : 57                                              *
*   History      :                                                *
*   Printed      : ---                                             *
*                                                                 *
********************************************************************)
(*##*)

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs;

type
  TFormFloating = class(TCustomDockForm)
    procedure FormDockDrop(Sender: TObject; Source: TDragDockObject; X,
      Y: Integer);
  private
    { Private declarations }
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
  end;

var
  FormFloating: TFormFloating;

implementation

{$R *.dfm}

constructor TFormFloating.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
end;

procedure TFormFloating.FormDockDrop(Sender: TObject;
  Source: TDragDockObject; X, Y: Integer);
begin
  if Sender is TControl
  then Caption:= TControl(Sender).Name;
  Show;
end;

end.

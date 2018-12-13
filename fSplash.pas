unit fsplash;
(*##*)
(*******************************************************************************
*                                                                             *
*   f  s  p  l  a  s  h                                                        *
*                                                                             *
*   Copyright © 2001, 2004 Andrei Ivanov. All rights reserved.                 *
*   splash window, part of apooed                                             *
*   Conditional defines:                                                       *
*                                                                             *
*   Revisions    : Jun 07 1999                                                 *
*   Last revision: Mar 29 2002                                                *
*   Lines        : 57                                                          *
*   History      : Based on Fund, mtsbill1 code                               *
*   Printed      : ---                                                         *
*                                                                             *
********************************************************************************)
(*##*)

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, Registry,
  wmleditutil, utilhttp, jpeg;

type
  TFormSplash = class(TForm)
    Image1: TImage;
    LabelUserName: TLabel;
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
  end;

var
  FormSplash: TFormSplash;

implementation

{$R *.DFM}

uses
  fDockBase;

procedure TFormSplash.FormActivate(Sender: TObject);
begin
  { привести размер окна к размеру картинки }
  // Width:= Image1.Picture.Width;
  // Height:= Image1.Picture.Height;
end;

procedure TFormSplash.FormCreate(Sender: TObject);
var
  S, ver: String;
  code: String;
  Rg: TRegistry;
begin
  utilhttp.LoadGIF(RESDLLNAME, 'logo', Image1.Picture);
  //
{$IFDEF NOSPLASH}
{$ELSE}
  Rg:= TRegistry.Create;
  Rg.RootKey:= HKEY_CURRENT_USER;// HKEY_LOCAL_MACHINE;
  if not Rg.OpenKey(RGPath, False) then begin
    // create default values
    // first try open local machine registry
    Rg.RootKey:= HKEY_LOCAL_MACHINE;
    if Rg.OpenKey(RGPATH, False) then begin
      Rg.Free;
      Exit;
    end;
  end;
  S:= Rg.ReadString(ParameterNames[ID_USER]);
  if Length(S) > 0
  then LabelUserName.Caption:= S  // display registered user name
  else LabelUserName.Caption:= '[Unregistered]';
  Rg.Free;

{$ENDIF}
end;

end.

unit
  fFtpSettings;
(*##*)
(*******************************************************************************
*                                                                             *
*   f  f  t  p  s  e  t  i  n  g  s                                            *
*                                                                             *
*   Copyright © 2001-2003 Andrei Ivanov. All rights reserved.                  *
*   ftp settings dialog window, part of apooed                                *
*   Conditional defines:                                                       *
*                                                                             *
*   Revisions    : Sep 19 2001                                                 *
*   Last revision: Mar 29 2002                                                *
*   Lines        : 108                                                          *
*   History      :                                                            *
*   Printed      : ---                                                         *
*                                                                             *
********************************************************************************)
(*##*)

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, ExtCtrls,
  util1;

type
  TFormFTPSettings = class(TForm)
    GBFtpSettings: TGroupBox;
    LEHost: TLabeledEdit;
    LEUser: TLabeledEdit;
    LEPassword: TLabeledEdit;
    LEPort: TLabeledEdit;
    UDPort: TUpDown;
    CBPASV: TCheckBox;
    LEDesc: TLabeledEdit;
    BOk: TButton;
    BCancel: TButton;
    LERootDir: TLabeledEdit;
    procedure FormActivate(Sender: TObject);
  private
    { Private declarations }
    procedure SetSiteString(ASite: String);
    function GetSiteString: String;
  public
    { Public declarations }
    property SiteString: String read GetSiteString write SetSiteString;
  end;

var
  FormFTPSettings: TFormFTPSettings;

implementation

{$R *.dfm}
uses
  urlFuncs;

procedure TFormFTPSettings.SetSiteString(ASite: String);
var
  p, port: Integer;
  // ftp address
  desc, protocol, host, user, password, IPaddress, fn, bookmark: String;
  ftpport: Integer;
begin
  // delete description if exists
  p:= Pos('=', ASite);
  if p > 0 then begin
    desc:= Copy(ASite, 1, p - 1);
    System.Delete(ASite, 1, p);
  end else desc:= '';
  if urlFuncs.ParseFtpUrl(ASite, protocol, user, password, host, IPaddress, fn, bookmark, port, 'ftp', 21) then begin
  // if (Length(IPaddress) > 0) and (Length(host) = 0) then host:= IPaddress;
    LEDesc.Text:= desc;
    LEUser.Text:= user;
    LEPassword.Text:= password;
    LEHost.Text:= host;
    UDPort.Position:= port;
    LERootDir.Text:= fn;
  end else begin
    LEDesc.Text:= '';
    LEUser.Text:= '';
    LEPassword.Text:= '';
    LEHost.Text:= '';
    UDPort.Position:= 21;
    LERootDir.Text:= '';
  end;
end;

// andy/password@ftp.net:21;pasv
function TFormFTPSettings.GetSiteString: String;
var
  u, p, rootdir: String;
begin
  u:= Trim(LEUser.Text);
  p:= Trim(LEPassword.Text);
  if Length(u) = 0 then begin
    u:= 'anonymous';
    if Length(p) = 0
    then p:= u + '@' + LEHost.Text;
  end;
  rootdir:= Trim(LERootDir.Text);
  // Result:= Trim(LEDesc.Text) + '=' + 'ftp://' + u + ':' + p + '@' + LEHost.Text + ':' + IntToStr(UDPort.Position) + rootdir;
  Result:= Trim(LEDesc.Text) + '=' +
    urlFuncs.ComposeUrl('ftp', u, p, LEHost.Text, rootdir, '', UDPort.Position);
end;

procedure TFormFTPSettings.FormActivate(Sender: TObject);
begin
  LEHost.SetFocus;
end;

end.

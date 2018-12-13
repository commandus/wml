unit
  fExtStorageSettings;
(*##*)
(*******************************************************************************
*                                                                             *
*   f  e  x  t  s  t  o  r  a  g  e  s  e  t  i  n  g  s                       *
*                                                                             *
*   Copyright © 2001-2003 Andrei Ivanov. All rights reserved.                  *
*   ftp settings dialog window, part of apooed                                *
*   Conditional defines:                                                       *
*                                                                             *
*   Revisions    : Sep 19 2001                                                 *
*   Last revision: Mar 29 2002                                                *
*   Lines        : 108                                                         *
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
    procedure SetSiteDelimitedString(const ASite: String);
    function GetSiteDelimitedString: String;
    procedure SetSiteString(ASite: String);
    function GetSiteString: String;
  public
    { Public declarations }
    property SiteDelimitedString: String read GetSiteDelimitedString write SetSiteDelimitedString;
    property SiteString: String read GetSiteString write SetSiteString;
    // andy/password@ftp.net:21;passw
    // desc,user,passwd,host,port,[pasv]
  end;

var
  FormFTPSettings: TFormFTPSettings;

implementation

{$R *.dfm}

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
  if ParseFtpUrl(ASite, protocol, user, password, host, IPaddress, fn, bookmark, port, 'ftp', 21) then begin
  // if (Length(IPaddress) > 0) and (Length(host) = 0) then host:= IPaddress;
    LEDesc.Text:= desc;
    LEUser.Text:= user;
    LEPassword.Text:= password;
    LEHost.Text:= host;
    UDPort.Position:= port;
    LERootDir.Text:= Trim(fn);
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
    util1.ComposeUrl('ftp', u, p, LEHost.Text, rootdir, '', UDPort.Position);  
end;

procedure TFormFTPSettings.SetSiteDelimitedString(const ASite: String);
var
  sl: TStrings;
begin
  sl:= TStringList.Create;
  sl.CommaText:= ASite;
  if (sl.Count >= 6) then begin
    LEDesc.Text:= sl[0];
    LEUser.Text:= sl[1];
    LEPassword.Text:= sl[2];
    LEHost.Text:= sl[3];
    UDPort.Position:= StrToIntDef(sl[4], 21);
    CBPASV.Checked:= CompareText('PASV', sl[5]) = 0;
  end else begin
    LEDesc.Text:= '';
    LEUser.Text:= '';
    LEPassword.Text:= '';
    LEHost.Text:= '';
    UDPort.Position:= 21;
    CBPASV.Checked:= False;
  end;
  sl.Free;
end;

// andy/password@ftp.net:21;pasv
function TFormFTPSettings.GetSiteDelimitedString: String;
var
  pasv: String[4];
  sl: TStrings;
begin
  if CBPASV.Checked
  then pasv:= 'PASV'
  else pasv:= '';
  sl:= TStringList.Create;
  sl.Add(LEDesc.Text);
  sl.Add(LEUser.Text);
  sl.Add(LEPassword.Text);
  sl.Add(LEHost.Text);
  sl.Add(IntToStr(UDPort.Position));
  sl.Add(pasv);
  Result:= sl.CommaText;
  sl.Free;
end;

procedure TFormFTPSettings.FormActivate(Sender: TObject);
begin
  LEHost.SetFocus;
end;

end.

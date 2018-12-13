unit
  fFtpProxySettings;
(*##*)
(*******************************************************************************
*                                                                             *
*   f  f  t  p  p  r  o  x  y  s  e  t  i  n  g  s                             *
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
  TFormFtpProxySettings = class(TForm)
    GBFtpSettings: TGroupBox;
    LEHost: TLabeledEdit;
    LEUser: TLabeledEdit;
    LEPassword: TLabeledEdit;
    LEPort: TLabeledEdit;
    UDPort: TUpDown;
    BOk: TButton;
    BCancel: TButton;
    CBProxyType: TComboBox;
    LProxyType: TLabel;
    LEDesc: TLabeledEdit;
  private
    { Private declarations }
    procedure SetProxyString(AProxy: String);
    function GetProxyString: String;
  public
    { Public declarations }
    property ProxyString: String read GetProxyString write SetProxyString;
  end;

var
  FormFtpProxySettings: TFormFtpProxySettings;

  function ComposeProxyString(const ADesc,AHost, AUserName, APassword: String;
    APort, AProxyType: Integer): String;
  function DecomposeProxyString(AUrl: String; var ADesc, AHost, AUserName, APassword: String;
    var APort, AProxyType: Integer): Boolean;

implementation

{$R *.dfm}

uses
  urlFuncs;

// desc=proxy://user:password@host:port/proxy type
procedure TFormFtpProxySettings.SetProxyString(AProxy: String);
var
  p: Integer;
  // ftp address
  desc, protocol, host, user, password, IPaddress, fn, bookmark: String;
  port: Integer;
begin
  // delete description if exists
  p:= Pos('=', AProxy);
  if p > 0 then begin
    desc:= Copy(AProxy, 1, p - 1);
    System.Delete(AProxy, 1, p);
  end else desc:= '';
  if urlFuncs.ParseUrl(AProxy, protocol, user, password, host, IPaddress, fn, bookmark, port, 'proxy', 21) then begin
    // if (Length(IPaddress) > 0) and (Length(host) = 0) then host:= IPaddress;
    // delete / from proxy type string /0
    if (Length(fn) > 0) and (fn[1] = '/')
    then Delete(fn, 1, 1);
    LEDesc.Text:= desc;
    LEUser.Text:= user;
    LEPassword.Text:= password;
    LEHost.Text:= host;
    UDPort.Position:= port;
    CBProxyType.ItemIndex:= StrToIntDef(fn, 0);
  end else begin
    LEDesc.Text:= '';
    LEUser.Text:= '';
    LEPassword.Text:= '';
    LEHost.Text:= '';
    UDPort.Position:= 21;
    CBProxyType.ItemIndex:= 0;
  end;
end;

function TFormFtpProxySettings.GetProxyString: String;
begin
  ComposeProxyString(Trim(LEDesc.Text), LEHost.Text, Trim(LEUser.Text), Trim(LEPassword.Text),
    UDPort.Position, CBProxyType.ItemIndex);
end;

function ComposeProxyString(const ADesc, AHost, AUserName, APassword: String;
  APort, AProxyType: Integer): String;
begin
  Result:= ADesc + '=' + 'proxy://' +
    AUserName + ':' + APassword + '@' + AHost + ':' + IntToStr(APort) + '/' + IntToStr(AProxyType);
end;

function DecomposeProxyString(AUrl: String; var ADesc, AHost, AUserName, APassword: String;
  var APort, AProxyType: Integer): Boolean;
var
  // ftp address
  desc, protocol, IPaddress, fn, bookmark: String;
  p, port: Integer;
begin
  // delete description if exists
  p:= Pos('=', AUrl);
  if p > 0 then begin
    desc:= Copy(AUrl, 1, p - 1);
    System.Delete(AUrl, 1, p);
  end else desc:= '';
  Result:= urlFuncs.ParseUrl(AUrl, protocol, AUserName, APassword, AHost, IPaddress, fn, bookmark, APort, 'proxy', 21);
  if (Length(fn) > 0) and (fn[1] = '/') then begin
    Delete(fn, 1, 1);
    AProxyType:= StrToIntDef(fn, 0);
  end else AProxyType:= 0;
end;

end.

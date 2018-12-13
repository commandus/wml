unit
  fLdapSettings;
(*##*)
(*******************************************************************************
*                                                                             *
*   f  l  d  a  p  s  e  t  i  n  g  s                                         *
*                                                                             *
*   Copyright © 2001-2003 Andrei Ivanov. All rights reserved.                  *
*   ldap settings dialog window, part of apooed                               *
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
  TFormLDAPSettings = class(TForm)
    GBLdapSettings: TGroupBox;
    LScope: TLabel;
    LEHost: TLabeledEdit;
    LEUser: TLabeledEdit;
    LEPassword: TLabeledEdit;
    LEPort: TLabeledEdit;
    UDPort: TUpDown;
    CBUtf8: TCheckBox;
    LEDesc: TLabeledEdit;
    LEBaseDN: TLabeledEdit;
    LEAttrs: TLabeledEdit;
    CBScope: TComboBox;
    LEFilter: TLabeledEdit;
    BOk: TButton;
    BCancel: TButton;
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
  FormLDAPSettings: TFormLDAPSettings;

implementation

{$R *.dfm}
uses
  urlFuncs;
  
procedure TFormLDAPSettings.SetSiteString(ASite: String);
var
  p, port: Integer;
  // ldap address
  desc, protocol, host, user, password, baseDN, Attributes, Scope, Filter: String;
begin
  // delete description if exists
  p:= Pos('=', ASite);
  if p > 0 then begin
    desc:= Copy(ASite, 1, p - 1);
    System.Delete(ASite, 1, p);
  end else desc:= '';
  if urlFuncs.ParseldapUrl(ASite, protocol, user, password, host, baseDN, Attributes, Scope, Filter, port, 'ldap', 389) then begin
  // if (Length(IPaddress) > 0) and (Length(host) = 0) then host:= IPaddress;
    LEDesc.Text:= desc;
    LEUser.Text:= user;
    LEPassword.Text:= password;
    LEHost.Text:= host;
    UDPort.Position:= port;
    LEBaseDN.Text:= baseDN;
    LEAttrs.Text:= Attributes;
    if Length(Scope) >= 1 then begin
      case Upcase(Scope[1]) of
      'O': CBScope.ItemIndex:= 1;
      'S': CBScope.ItemIndex:= 2;
      end;
    end else CBScope.ItemIndex:= 0;
    LEFilter.Text:= Filter;
  end else begin
    LEDesc.Text:= '';
    LEUser.Text:= '';
    LEPassword.Text:= '';
    LEHost.Text:= '';
    UDPort.Position:= 389;
    LEBaseDN.Text:= '';
    LEAttrs.Text:= '';
    CBScope.Text:= ''; // base
    LEFilter.Text:= ''; // (objectClass=*)
  end;
end;

function TFormLDAPSettings.GetSiteString: String;
begin
  // RFC: ldap[s]://<hostname>:<port>/<base_dn>?<attributes>?<scope>?<filter>
  Result:= Trim(LEDesc.Text) + '=' + ComposeLdapUrl(
  'ldap', LEUser.Text, LEPassword.Text, Trim(LEHost.Text),
  LEBaseDN.Text, LEAttrs.Text, CBScope.Text, LEFilter.Text, UDPort.Position);
end;

procedure TFormLDAPSettings.FormActivate(Sender: TObject);
begin
  LEHost.SetFocus;
end;

end.

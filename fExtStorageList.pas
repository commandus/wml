unit
  fExtStorageList;
(*##*)
(*******************************************************************************
*                                                                             *
*   f  f  t  p  l  i  s  t                                                     *
*                                                                             *
*   Copyright © 2001-2003 Andrei Ivanov. All rights reserved.                  *
*   ftp site settings list, part of apooed                                    *
*   Conditional defines:                                                       *
*                                                                             *
*   Revisions    : Mar 08 2003                                                 *
*   Last revision: Mar 08 2003                                                *
*   Lines        : 108                                                          *
*   History      :                                                            *
*   Printed      : ---                                                         *
*                                                                             *
********************************************************************************)
(*##*)

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ComCtrls, Registry,
{$IFNDEF NO_FTP}
  IdFtp,
{$ENDIF}
  dm, util1;

const
  IMG_IDX_FTP  = 33;
  IMG_IDX_LDAP = 34;

type
  TFormExtStorageSites = class(TForm)
    PanelTop: TPanel;
    PanelBottom: TPanel;
    BAdd: TButton;
    BDelete: TButton;
    BEdit: TButton;
    BProxySettings: TButton;
    BOK: TButton;
    BCancel: TButton;
    LVList: TListView;
    BAddLDAP: TButton;
    procedure BAddFTPClick(Sender: TObject);
    procedure BDeleteClick(Sender: TObject);
    procedure BEditClick(Sender: TObject);
    procedure BProxySettingsClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure BAddLDAPClick(Sender: TObject);
  private
    { Private declarations }
    FURLList: TStrings;
  public
    { Public declarations }
    procedure LoadIni;
    procedure StoreIni;
    procedure RefreshView;
    function FtpAddSite: Boolean;
    function LdapAddSite: Boolean;
    function DeleteSite(AIdx: Integer): Boolean;
    function EditSite(AIdx: Integer; AKind: Integer): Boolean;
    function FtpSetProxySettings: Boolean;
    property URLList: TStrings read FURLList;
  end;

var
  FormExtStorageSites: TFormExtStorageSites;

procedure LoadSiteList(const AKey: HKey; const ARegKey: String; AURLList: TStrings);
procedure StoreSiteList(const AKey: HKey; const ARegKey: String; AURLList: TStrings);

implementation

{$R *.dfm}

uses
  urlFuncs, fDockBase, fFtpSettings, fFtpProxySettings, fLdapSettings;

procedure LoadSiteList(const AKey: HKey; const ARegKey: String; AURLList: TStrings);
var
  rg: TRegistry;
  s: String;
  sl: TStrings;
  i: Integer;
  p: Integer;
begin
  AURLList.Clear;
  sl:= TStringList.Create;
  Rg:= TRegistry.Create;
  Rg.RootKey:= AKey;
  try
    if Rg.OpenKey(ARegKey, False) then begin
      Rg.GetValueNames(sl);
      for i:= 0 to sl.Count - 1 do begin
        s:= sl[i];
        p:= Pos(#32, s);
        if p > 0 then begin
          Delete(s, 1, p);
        end;
        s:= s + '=' + Rg.ReadString(sl[i]);
        if Length(s) > 0
        then AURLList.Add(s);
      end;
    end;
  except
  end;
  Rg.Free;
  sl.Free;
end;

procedure StoreSiteList(const AKey: HKey; const ARegKey: String; AURLList: TStrings);
var
  rg: TRegistry;
  vl: String;
  sl: TStrings;
  i, p: Integer;
begin
  Rg:= TRegistry.Create;
  Rg.RootKey:= AKey;
  try
    if Rg.OpenKey(ARegKey, True) then begin
      // delete all previous create sites
      sl:= TStringList.Create;
      Rg.GetValueNames(sl);
      for i:= 0 to sl.Count - 1 do begin
        Rg.DeleteValue(sl[i]);
      end;
      sl.Free;
      // store new ones
      for i:= 0 to AURLList.Count - 1 do begin
        p:= Pos('=', AURLList[i]);
        if p <= 0
        then Continue;
        vl:= Copy(AURLList[i], p + 1, MaxInt);
        if Length(vl) > 0 then begin
          Rg.WriteString(IntToStr(i) + #32 + AURLList.Names[i], vl);
        end;
      end;
    end;
  except
  end;
  Rg.Free;
end;

procedure TFormExtStorageSites.LoadIni;
begin
  LoadSiteList(HKEY_CURRENT_USER, RGPath + RG_EXTERNALSTORAGE_SITES, FURLList);
  RefreshView;
end;

procedure TFormExtStorageSites.StoreIni;
begin
  StoreSiteList(HKEY_CURRENT_USER, RGPath + RG_EXTERNALSTORAGE_SITES, FURLList)
end;

procedure TFormExtStorageSites.RefreshView;
var
  i, p: Integer;
  li: TListItem;
  s: String;
  // ftp address
  desc, protocol, host, user, password, IPaddress, fn, bookmark,
  baseDN, Attributes, Scope, Filter: String;
  port: Integer;
begin
  with LVList do begin
    Clear;
    for i:= 0 to FURLList.Count - 1 do begin
      li:= Items.Add;
      // get and delete description from url
      s:= FURLList[i];
      p:= Pos('=', s);
      if p > 0 then begin
        desc:= Copy(s, 1, p - 1);
        System.Delete(s, 1, p);
      end else desc:= '';
      // now s starts with 'ftp://' or 'ldap://'
      if Pos('ftp://', s) = 1 then begin
        { "ftp:" "//" host [ ":" port ] [ abs_path ] }
        if urlFuncs.ParseFtpUrl(s, protocol, user, password, host, IPaddress, fn, bookmark, port, 'ftp', 21) then begin
          with li do begin
            Caption:= host;
            ImageIndex:= IMG_IDX_FTP;
            SubItems.Add(IntToStr(port));
            SubItems.Add(user);
            if Length(password) > 0
            then SubItems.Add('*')
            else SubItems.Add('');
            SubItems.Add(fn);
            SubItems.Add(desc);
            Data:= Pointer(i);
          end;
        end;
      end;

      if Pos('ldap://', s) = 1 then begin
        { "ldap:" "//" host [ ":" port ] [ abs_path ] }
        if urlFuncs.ParseLdapUrl(s, protocol, user, password, host, baseDN, Attributes, Scope, Filter, port, 'ldap', 389) then begin
          with li do begin
            Caption:= host;
            ImageIndex:= IMG_IDX_LDAP;
            SubItems.Add(IntToStr(port));
            SubItems.Add(user);
            if Length(password) > 0
            then SubItems.Add('*')
            else SubItems.Add('');
            SubItems.Add(basedn);
            SubItems.Add(desc);
            Data:= Pointer(i);
          end;
        end;
      end;

    end;
  end;
end;

function TFormExtStorageSites.FtpAddSite: Boolean;
begin
  //
  Result:= False;
  FormFTPSettings:= TFormFTPSettings.Create(Nil);
  with FormFTPSettings do begin
    // get last opened for example
    if LVList.ItemIndex >= 0
    then SiteString:= FURLList[Integer(LVList.Items[LVList.ItemIndex].Data)]
    else SiteString:= '';

    if ShowModal = mrOK then begin
      FURLList.AddObject(SiteString, Pointer(FURLList.Count));
      Result:= True;
    end;
    Free;
  end;
end;

function TFormExtStorageSites.LdapAddSite: Boolean;
begin
  //
  Result:= False;
  FormLdapSettings:= TFormLdapSettings.Create(Nil);
  with FormLdapSettings do begin
    // get last opened for example
    if LVList.ItemIndex >= 0
    then SiteString:= FURLList[Integer(LVList.Items[LVList.ItemIndex].Data)]
    else SiteString:= '';

    if ShowModal = mrOK then begin
      FURLList.AddObject(SiteString, Pointer(FURLList.Count));
      Result:= True;
    end;
    Free;
  end;
end;

function TFormExtStorageSites.DeleteSite(AIdx: Integer): Boolean;
begin
  //
  Result:= False;
  if (AIdx < 0) or (AIdx >= FURLList.Count)
  then Exit;
  if MessageDlg('Delete site information:'#13#10 + FURLList.Names[AIdx] +
    #13#10'Are you sure?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then begin
    FURLList.Delete(AIdx);
    Result:= True;
    // do not forget to re-order index in caller
    // RefreshView;
  end;
end;

function TFormExtStorageSites.EditSite(AIdx: Integer; AKind: Integer): Boolean;
begin
  //
  Result:= False;
  if (AIdx < 0) or (AIdx >= FURLList.Count)
  then Exit;
  case AKind of
  1:begin
      FormFTPSettings:= TFormFTPSettings.Create(Nil);
      with FormFTPSettings do begin
        // get current
        SiteString:= FURLList[AIdx];
        if ShowModal = mrOK then begin
          FURLList[AIdx]:= SiteString;
          Result:= True;
        end;
        Free;
      end;
    end;
  2:begin
      FormLDAPSettings:= TFormLDAPSettings.Create(Nil);
      with FormLDAPSettings do begin
        // get current
        SiteString:= FURLList[AIdx];
        if ShowModal = mrOK then begin
          FURLList[AIdx]:= SiteString;
          Result:= True;
        end;
        Free;
      end;
    end;
  end; // case
end;

function TFormExtStorageSites.FtpSetProxySettings: Boolean;
begin
  //
  Result:= False;
  FormFTPProxySettings:= TFormFTPProxySettings.Create(Nil);
  with FormFTPProxySettings do begin
    // get current
    with dm.dm1 do begin
      ProxyString:= ComposeProxyString('ftp proxy', ProxyHost, ProxyUserName, ProxyPassword, ProxyPort, ProxyType);
      if ShowModal = mrOK then begin
        ProxyHost:= Trim(LEHost.Text);
        ProxyUserName:= Trim(LEUser.Text);
        ProxyPassword:= Trim(LEPassword.Text);
        ProxyPort:= UDPort.Position;
        if CBProxyType.ItemIndex >= 0
        then ProxyType:= CBProxyType.ItemIndex;
        Result:= True;
      end;
    end;
    Free;
  end;
end;

procedure TFormExtStorageSites.BAddFTPClick(Sender: TObject);
begin
  if FtpAddSite
  then RefreshView;
end;

procedure TFormExtStorageSites.BAddLDAPClick(Sender: TObject);
begin
  if LDAPAddSite
  then RefreshView;
end;

procedure TFormExtStorageSites.BDeleteClick(Sender: TObject);
begin
  if DeleteSite(LVList.ItemIndex)
  then RefreshView;
end;

procedure TFormExtStorageSites.BEditClick(Sender: TObject);
begin
  if LVList.ItemIndex < 0
  then Exit;
  if EditSite(LVList.ItemIndex, LVList.Selected.ImageIndex - IMG_IDX_FTP + 1)
  then RefreshView;
end;

procedure TFormExtStorageSites.BProxySettingsClick(Sender: TObject);
begin
  FtpSetProxySettings;
end;

procedure TFormExtStorageSites.FormCreate(Sender: TObject);
begin
  FURLList:= TStringList.Create;
  LoadIni;
end;

procedure TFormExtStorageSites.FormDestroy(Sender: TObject);
begin
  FURLList.Free;
end;

procedure TFormExtStorageSites.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
const
  pt: TPoint = (x: 0; y: 0);
begin
  case Key of
    VK_F1, VK_HELP: begin
      FormDockBase.ShowHelpByIndex(pt, Nil, 'howtoftp');
    end;
  end;
end;

end.

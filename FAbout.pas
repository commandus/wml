unit
  Fabout;
(*##*)
(*******************************************************************************
*                                                                             *
*   f  a  b  o  u  t                                                           *
*                                                                             *
*   Copyright © 2001, 2002 Andrei Ivanov. All rights reserved.                 *
*   Part of wmledit2                                                          *
*   Conditional defines:                                                       *
*                                                                             *
*   Revisions    : Jun 25 2001                                                 *
*   Last revision: Dec  3 2001                                                *
*   Lines        : 144                                                         *
*   History      :                                                            *
*   Printed      : ---                                                         *
*                                                                             *
********************************************************************************)
(*##*)

interface

uses
  Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls,
  Dialogs, WinInet, ShellAPI, Buttons, ExtCtrls, jpeg,
  jclSysInfo, jclUnicode, ComCtrls, StarWars;

type
  TAboutBox = class(TForm)
    PanelBottom: TPanel;
    OKButton: TButton;
    BRegister: TButton;
    PanelTop: TPanel;
    LRegistered: TLabel;
    LBetaVersion: TLabel;
    Timer1: TTimer;
    BCredits: TButton;
    PanelAbout: TPanel;
    PCAbout: TPageControl;
    TSTeam: TTabSheet;
    PanelHelp: TPanel;
    TSSystem: TTabSheet;
    LHttp: TLabel;
    LMail: TLabel;
    Label1: TLabel;
    ProgramIcon: TImage;
    MemoInfo: TMemo;
    procedure LHttpClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure LEMailClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure BCreditsClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure LRegisteredClick(Sender: TObject);
    procedure OKButtonClick(Sender: TObject);
  private
    { Private declarations }
    FhtmlHelpWnd: HWND;
    FGLController: TOpenGLWndControllerStar;
  public
    { Public declarations }
  end;

var
  AboutBox: TAboutBox;

implementation

{$R *.DFM}

uses
  FRegister, util1, utilwin, versions,
  appconst, fDockBase, wmleditutil;

procedure TAboutBox.LHttpClick(Sender: TObject);
var
  browser: String;
begin
  {
  if ShellAPI.ShellExecute(0, 'open', PChar((Sender as TLabel).Caption), Nil, Nil, SW_SHOWNORMAL) <= 32 then begin
    ShowMessage('Error: internet browser is not installed.'#13#10);
  end;
  }
  browser:= utilwin.GetMozillaBrowserPath;
  if ShellAPI.ShellExecute(HWND_DESKTOP, 'open', PChar(browser),
    PChar((Sender as TLabel).Caption), Nil, SW_SHOWNORMAL) <= 32 then begin
    ShowMessage(Format('Error: execute %s browser.'#13#10, [browser]));
  end;
end;

function GetWindowsList: String;
var
  WindowHandle2 : HWND;
  p: array[0..511] of Char;
begin
  Result:= '';
  WindowHandle2:= FindWindow(Nil, Nil);
  while (WindowHandle2 <> 0) do begin
    GetWindowText(WindowHandle2, P, SizeOf(p) - 1);
    Result:= Result + P + #32;
    GetClassName(WindowHandle2, P, SizeOf(p) - 1);
    Result:= Result + P + #32;
    if IsWindowVisible(WindowHandle2)
    then Result:= Result + 'visible'#32;
    Result:= Result + #13#10;
    // next step
    WindowHandle2:= GetWindow(WindowHandle2, GW_HWNDNEXT);
  end;
end;

function OSSpecString: String;
var
  v: Integer;
  disk: String;
  FOSVersionInfo: TOSVersionInfo;
begin
  Result:= '';
  with Screen do begin
    Result:= Result + Format('Installed monitors: %d; ', [MonitorCount]);
    for v:= 0 to MonitorCount - 1 do begin
      Result:= Result + Format('#%d %dx%d '#13#10, [Monitors[v].MonitorNum, Monitors[v].Width, Monitors[v].Height]);
    end;
  end;
  SetLength(disk, 1024);
  Windows.GetSystemDirectory(@(disk[1]), Length(disk));
  Result:= Result + 'Processor(s): ';
  FOSVersionInfo.dwOSVersionInfoSize:= SizeOf(FOSVersionInfo);
  GetVersionEx(FOSVersionInfo);
  with FOSVersionInfo do begin
    Result:= Result + Format( 'Windows v. %d.%d build %d %s',
      [dwMajorVersion, dwMinorVersion, dwBuildNumber and $FFFF, String(szCSDVersion)]);
    // dwBuildNumber: Windows NT: Identifies the build number of the operating system.
    //                Windows 95: The high-order word contains the major and minor version numbers.
    // szCSDVersion:  Windows NT: such as "Service Pack 3"
    //                Windows 95: provides arbitrary additional information about the operating system.
  end;
end;

procedure TAboutBox.FormCreate(Sender: TObject);
var
  FOSVersionInfo: TOSVersionInfo;
  s: String;
  v: Integer;
  disk: String;
  CPUInfo: TCPUInfo;
begin
  //
  FGLController:= Nil;    
  FhtmlHelpWnd:= wmleditutil.ShowHTMLHelpNag(PanelHelp,
    util1.ConcatPath(FormDockBase.FParameters.Values[ParameterNames[ID_ConfigDir]], DEFHELPFILE), 'z-about');  //  Self.Handle

  LBetaVersion.Visible:= wmleditutil.IsBetaVersion(fDockBase.FormDockBase.FParameters.Values[ParameterNames[ID_ConfigDir]]);
  s:= OSSpecString;
  MemoInfo.Lines.Insert(0, s);
  // s:= GetWindowsList;
  MemoInfo.Lines.Add('Browser path: '+ GetMozillaBrowserPath);
  SetLength(disk, 1024);
  Windows.GetSystemDirectory(@(disk[1]), Length(disk));
  v:= Pos(#0, disk);
  if v > 0 then begin
    SetLength(disk,  1);
    s:= Format('System volume "%s" s/n %s. ', [GetVolumeName(disk), GetVolumeSerialNumber(disk)]);
  end else s:= '';
  GetCpuInfo(CPUInfo);
  s:= s + 'Processor: ';
  with CPUInfo do begin
    s:= s + VendorIDString + ' ';
    s:= s + Manufacturer + ' ';
    s:= s + CpuName + ' ';
    if HasInstruction then begin
      if MMX
      then s:= s + 'MMX ';
      with FrequencyInfo do begin
        s:= s + Format('%d MHz ', [RawFreq]);
      end;
    end;
    case PType of
      0:;
      1: s:= s + 'overdrive, ';
    end;
    case CpuType of
      CPU_TYPE_INTEL: s:= s + 'Intel ';
      CPU_TYPE_CYRIX: s:= s + 'Cyrix ';
      CPU_TYPE_AMD: s:= s + 'AMD ';
    end;
    MemoInfo.Lines.Insert(0, s);
  end;

  FOSVersionInfo.dwOSVersionInfoSize:= SizeOf(FOSVersionInfo);
  GetVersionEx(FOSVersionInfo);
  with FOSVersionInfo do begin
    MemoInfo.Lines.Insert(0, Format( 'Windows v. %d.%d build %d %s',
      [dwMajorVersion, dwMinorVersion, dwBuildNumber and $FFFF, String(szCSDVersion)]));
    // dwBuildNumber: Windows NT: Identifies the build number of the operating system.
    //                Windows 95: The high-order word contains the major and minor version numbers.
    // szCSDVersion:  Windows NT: such as "Service Pack 3"
    //                Windows 95: provides arbitrary additional information about the operating system.
    MemoInfo.Lines.Insert(0, Versions.GetVersionInfo(LNG, 'ProductName') +
      ' version '+ Versions.GetVersionInfo(LNG, 'FileVersion'));
    MemoInfo.Lines.Insert(0, Versions.GetVersionInfo(LNG, 'LegalCopyright'));
  end;
  ProgramIcon.Hint:= 'Visit my other places:'#13#10'http://wap.commandus.com'+
    #13#10'http://wbmp.commandus.com/(wbmp image convertor)'+
    #13#10'http://ebook.commandus.com/(ebook utilities)';
  if FormDockBase.FRegistered then begin
    LRegistered.Caption:= Format('Registered to %s', [FormDockBase.FParameters.Values[ParameterNames[ID_USER]]]);
    BRegister.Enabled:= False;
    BRegister.Caption:= 'Registered copy';     
  end else begin
    LRegistered.Caption:= 'Evaluation copy';
    BRegister.Enabled:= True;
  end;
end;

procedure TAboutBox.LEMailClick(Sender: TObject);
const
  MyEmail = 'apoo editor developer team <support@commandus.com> (commandus)';
  Subj = 'apoo editor';
  Body = 'Hi All,'#13#10+
    #13#10'I have a question...'#13#10#13#10;
var
  s: String;
  ss: String;
begin
  ss:= UTF8Encode(OSSpecString);
  s:= 'mailto:'+ HTTPEncode(MyEmail, False) + '?subject=' + HTTPEncode(Subj, False) + '&body=' + HTTPEncode(Body + '[You can skip lines above] ' + #13#10#13#10 + ss, False);
  if ShellAPI.ShellExecute(0, 'open', PChar(s), Nil, Nil, SW_SHOWNORMAL) <= 32 then begin
    ShowMessage('Error: e-mail program is not installed.'#13#10);
  end;
end;

procedure TAboutBox.Timer1Timer(Sender: TObject);
var
  d: DWORD;
begin
  Timer1.Enabled:= False;
  d:= INTERNET_CONNECTION_MODEM + INTERNET_CONNECTION_LAN + INTERNET_CONNECTION_PROXY;
  if InternetGetConnectedState(@d, 0) then begin
    FhtmlHelpWnd:= wmleditutil.ShowHTMLHelpNag(PanelHelp,
      util1.ConcatPath(FormDockBase.FParameters.Values[ParameterNames[ID_ConfigDir]], DEFHELPFILE),
        'z-about-inet');  //  Self.Handle
  end;
end;

function LoadResFromInstance(const AResName: String; const AName, AType: String): String;
var
  hm: HMODULE;
  h: HRSRC;
  g: HGLOBAL;
  p: Pointer;
  len: Cardinal;
begin
  //
  if Length(AResName) = 0
  then hm:= HInstance
  else hm:= Windows.LoadLibrary(PChar(AResName));
  if hm = 0 then begin
    Result:= '*';
    Exit;
  end;
  h:= FindResource(hm, PChar(AName), PChar(AType));
  if h = 0 then begin
    Exit;
  end;
  len:= SizeofResource(hm, h);
  // load resource
  g:= LoadResource(hm, h);
  if (g = 0) or (len = 0) then Exit;
  // lock resource
  p:= LockResource(g);
  // copy resource
  SetLength(Result, len);
  Move(p^, Result[1], len);
  if hm  <> HInstance
  then FreeLibrary(hm);
end;

procedure TAboutBox.BCreditsClick(Sender: TObject);
var
  WS: TWideStrings;
begin
  if not Assigned(FGLController) then begin
    PCAbout.Visible:= False;
    // create controller
    ws:= TWideStringList.Create;
    ws.Text:= LoadResFromInstance(RESDLLNAME, 'credit', 'CRD');
    FGLController:= TOpenGLWndControllerStar.Create(ws, 10.0, 100, False,
      GetDC(PanelAbout.Handle), PanelAbout.Font.Handle, PanelAbout.ClientRect);
    ws.Free;
    FGLController.Resume;
  end else begin
    FGLController.Terminated:= not FGLController.Terminated;
    PCAbout.Visible:= FGLController.Terminated;
    if not FGLController.Terminated
    then FGLController.Execute;
  end;
end;

procedure TAboutBox.FormDestroy(Sender: TObject);
begin
  if Assigned(FGLController)
  then FreeAndNil(FGLController);
end;

procedure TAboutBox.LRegisteredClick(Sender: TObject);
begin
  BCredits.Click;
end;

procedure TAboutBox.OKButtonClick(Sender: TObject);
begin
  if Assigned(FGLController) then begin
    FGLController.Terminated:= not FGLController.Terminated;
    PCAbout.Visible:= FGLController.Terminated;
    if not FGLController.Terminated
    then FGLController.Execute;
  end;
end;

end.

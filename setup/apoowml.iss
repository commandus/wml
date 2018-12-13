; apoo wml editor installation script(apoowml.iss)

[Setup]
AppID=apoo wml
AppName=apoo wml editor
PrivilegesRequired=admin
AllowNoIcons=true
AlwaysShowComponentsList=true
AlwaysShowDirOnReadyPage=true
AlwaysShowGroupOnReadyPage=true
AppVerName=apoo wml editor 1.9.9
AppPublisher=Commandus software developer team
AppVersion=1.0
AppPublisherURL=http://wap.commandus.com/
AppSupportURL=http://support.commandus.com/
AppUpdatesURL=http://wap.commandus.com/
AppCopyright=Copyright © 2007, Commandus software developement group. Portions created by IBM Corporation and others are Copyright © 2004, IBM Coprporation. Portions created by Firebird Project are Copyright © 2000-2002, Firebird Project. Portions created by Andrei Ivamov are Copyright (c) 2007, Andrei Ivanov.
BackColor=clWhite
Compression=bzip
CreateAppDir=true

DefaultDirName={pf}\apoo editor
DefaultGroupName=apoo editor
DirExistsWarning=auto
DisableDirPage=false
DisableStartupPrompt=false
DisableProgramGroupPage=false

FlatComponentsList=true

LicenseFile=c:\src\wml\setup\Data\license.rtf

MinVersion=4.1.1998,5.0.2195

OutputDir=c:\src\wml\setup
OutputBaseFilename=setupApooEditorEN

ShowComponentSizes=true
SourceDir=c:\src\wml\setup\data

UninstallDisplayIcon={app}\bin\apooed.exe
UninstallLogMode=append
UninstallFilesDir={app}
Uninstallable=true
UsePreviousAppDir=true
UsePreviousGroup=true
UsePreviousSetupType=true

WizardStyle=modern
WindowShowCaption=true
WindowStartMaximized=false
WindowVisible=false
WindowResizable=true
WizardImageFile=compiler:WizModernImage.bmp
WizardImageBackColor=$808000
WizardSmallImageFile=compiler:WizModernSmallImage.bmp
;WizardDebug=false
SolidCompression=true
VersionInfoVersion=1.0
VersionInfoCompany=Commandus Software development group
VersionInfoDescription=apoo WML/xHTML editor
VersionInfoCopyright=Copyright (c) 2007 Commandus Software development group
ExtraDiskSpaceRequired=10
UserInfoPage=true

[Types]
Name: full; Description: Full installation
Name: compact; Description: Compact installation
Name: custom; Description: Customized installation; Flags: iscustom

[Components]
Name: Main; Description: Binaries; Types: full compact custom; Flags: fixed
Name: Docs; Description: Help, fixed bugs, features and release notes; Types: full custom; Flags: fixed
Name: Other; Description: Other files not necessary to run editor; Types: full custom

[Files]
Source: apoo.chm; DestDir: {app}; DestName: apoo.chm; Components: Docs; Flags: onlyifdoesntexist
Source: file_id.diz; DestDir: {app}; Components: Docs; Flags: onlyifdoesntexist
Source: apooed.exe; DestDir: {app}; Components: Main; Flags: onlyifdoesntexist
Source: readme.txt; DestDir: {app}; Components: Docs; Flags: onlyifdoesntexist
Source: license.txt; DestDir: {app}; Components: Main
Source: *.xsl; DestDir: {app}; Components: Main
Source: apooinfotip.dll; DestDir: {app}; Components: Main
Source: apooedr.dll; DestDir: {app}; Components: Main
Source: litgen.dll; DestDir: {app}; Components: Main
Source: format.txt; DestDir: {app}; Components: Main
Source: hint.wml; DestDir: {app}; Components: Main
Source: sample.wml; DestDir: {app}; Components: Other

[Icons]
Name: {group}\apoo editor; Filename: {app}\apooed.exe; WorkingDir: {app}; IconFilename: {app}\apooed.exe; Comment: apoo editor
Name: {group}\Help; Filename: {app}\apoo.chm; WorkingDir: {app}; IconFilename: {app}\apoo.chm; Comment: Help file
Name: {group}\License agreement; Filename: {app}\license.txt; WorkingDir: {app}
Name: {group}\Readme; Filename: {app}\readme.txt; WorkingDir: {app}
Name: {group}\Bug report; Filename: mailto:support@commandus.com?subject=apoo%20editor%20bug%20report&body=Bug%20report%0D%0AProduct:%20apoo%20editor%0D%0ADescription%20of%20problem:%20%0D%0AOperating%20system:%20%0D%0AHardware%20specific:%20%0D%0ANotes:%20%0D%0AContact%20name:%20%0D%0A; WorkingDir: {app}; Comment: Bug report apoo editor

[Registry]
Root: HKCU; Subkey: software\ensen\apoo editor\1.0; ValueType: string; ValueName: LastDirectory; ValueData: {app}
Root: HKCU; Subkey: software\ensen\apoo editor\1.0; ValueType: string; ValueName: ConfigDir; ValueData: {app}
Root: HKCU; Subkey: software\ensen\apoo editor\1.0; ValueType: string; ValueName: DesktopDock; ValueData: 0000040000000000F80200000000000002A00100000000000001000000017C0100000000000002000000025F010000000000000300000000BE0000000C00000050616E656C50726F6A65637403000000017C010000000000000400000000E0000000100000005472656556696577456C656D656E747304000000005F0100000E00000050726F7065727479456469746F720200000000A00100000B0000004C697374426F78496E666F0100000000F80200000B00000050616E656C456469746F72FFFFFFFF
Root: HKCU; Subkey: software\ensen\apoo editor\1.0; ValueType: string; ValueName: Geometry; ValueData: 000000000C000000BA0000005B0100007C0100000C000000F8020000A0010000BE0000000C00000078010000DC000000BE000000EC000000780100005B010000000000006B01000078010000A0010000
Root: HKCU; Subkey: software\ensen\apoo editor\1.0; ValueType: string; ValueName: Languages; ValueData: 00000409
Root: HKCU; Subkey: software\ensen\apoo editor\1.0; ValueType: string; ValueName: EncodingCharset; ValueData: 106
Root: HKCU; Subkey: software\ensen\apoo editor\1.0; ValueType: string; ValueName: BlockIndent; ValueData: 2


[Run]
;Filename: {app}\bin\instreg.exe; Parameters: "install ""{app}"""; WorkingDir: {app}\bin; Flags: runminimized
;Filename: {app}\bin\instsvc.exe; Parameters: "install ""{app}"" -auto"; WorkingDir: {app}\bin; Flags: runminimized
;FileName: {app}\bin\FbSvc.exe; Parameters: /install_guardian; WorkingDir: {app}\bin; Flags: runminimized
Filename: {app}\apooed.exe; WorkingDir: {app}; Description: Start apoo editor; StatusMsg: Start apoo editor; Flags: postinstall; Languages: 

[UninstallRun]
;FileName: {app}\bin\FbSvc.exe; Parameters: /deinstall_guardian; WorkingDir: {app}\bin; Flags: runminimized
;FileName: {app}\bin\FbSvc.exe; Parameters: /stop_server; WorkingDir: {app}\bin; Flags: runminimized
;Filename: {app}\bin\instsvc.exe; Parameters: remove; WorkingDir: {app}\bin; Flags: runminimized
;Filename: {app}\bin\instreg.exe; Parameters: remove; WorkingDir: {app}\bin; Flags: runminimized

[UninstallDelete]
Name: {app}; Type: filesandordirs
[Languages]
Name: default; MessagesFile: compiler:Default.isl

; SoftphonePro - Inno Setup 6 installer script.
;   iscc /DAppVersion=1.2.3 [/DSourceDir=C:\path\to\Release] [/DOutputDir=C:\out] softphonepro.iss
; Output: SoftphonePro-Setup-<ver>-x64.exe
#ifndef AppVersion
  #define AppVersion "1.0.0"
#endif
#ifndef SourceDir
  #define SourceDir "..\..\build\windows\x64\runner\Release"
#endif
#ifndef OutputDir
  #define OutputDir "..\..\build\windows\installer"
#endif

#define AppName "SoftphonePro"
#define AppExe  "softphonepro.exe"

[Setup]
AppId={{6F1D6C1E-3B7A-4C55-9E0B-5C0A5A6E2D41}
AppName={#AppName}
AppVersion={#AppVersion}
AppVerName={#AppName} {#AppVersion}
AppPublisher=SoftphonePro contributors
AppPublisherURL=https://github.com/softphonepro/softphonepro
DefaultDirName={autopf}\{#AppName}
DefaultGroupName={#AppName}
DisableProgramGroupPage=yes
UninstallDisplayIcon={app}\{#AppExe}
SetupIconFile=..\runner\resources\app_icon.ico
LicenseFile=..\..\..\LICENSE
OutputDir={#OutputDir}
OutputBaseFilename={#AppName}-Setup-{#AppVersion}-x64
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
PrivilegesRequired=admin
PrivilegesRequiredOverridesAllowed=dialog
Compression=lzma2/max
SolidCompression=yes
WizardStyle=modern
CloseApplications=yes
RestartApplications=no

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked
Name: "startup"; Description: "Start {#AppName} when Windows starts"; GroupDescription: "Startup:"; Flags: unchecked
Name: "urlhandlers"; Description: "Handle sip:, sips:, tel:, callto: links"; GroupDescription: "Integration:"

[Files]
Source: "{#SourceDir}\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{autoprograms}\{#AppName}"; Filename: "{app}\{#AppExe}"
Name: "{autodesktop}\{#AppName}"; Filename: "{app}\{#AppExe}"; Tasks: desktopicon

[Registry]
; Start with Windows (per-user, so it also works for a non-elevated "install for me only").
Root: HKCU; Subkey: "Software\Microsoft\Windows\CurrentVersion\Run"; ValueType: string; ValueName: "{#AppName}"; ValueData: """{app}\{#AppExe}"" --minimized"; Flags: uninsdeletevalue; Tasks: startup

; URL protocols (HKCU\Software\Classes works for admin and per-user installs alike)
Root: HKCU; Subkey: "Software\Classes\sip"; ValueType: string; ValueData: "URL:SIP Address"; Flags: uninsdeletekey; Tasks: urlhandlers
Root: HKCU; Subkey: "Software\Classes\sip"; ValueType: string; ValueName: "URL Protocol"; ValueData: ""; Tasks: urlhandlers
Root: HKCU; Subkey: "Software\Classes\sip\DefaultIcon"; ValueType: string; ValueData: "{app}\{#AppExe},0"; Tasks: urlhandlers
Root: HKCU; Subkey: "Software\Classes\sip\shell\open\command"; ValueType: string; ValueData: """{app}\{#AppExe}"" ""%1"""; Tasks: urlhandlers

Root: HKCU; Subkey: "Software\Classes\sips"; ValueType: string; ValueData: "URL:Secure SIP Address"; Flags: uninsdeletekey; Tasks: urlhandlers
Root: HKCU; Subkey: "Software\Classes\sips"; ValueType: string; ValueName: "URL Protocol"; ValueData: ""; Tasks: urlhandlers
Root: HKCU; Subkey: "Software\Classes\sips\DefaultIcon"; ValueType: string; ValueData: "{app}\{#AppExe},0"; Tasks: urlhandlers
Root: HKCU; Subkey: "Software\Classes\sips\shell\open\command"; ValueType: string; ValueData: """{app}\{#AppExe}"" ""%1"""; Tasks: urlhandlers

Root: HKCU; Subkey: "Software\Classes\tel"; ValueType: string; ValueData: "URL:Telephone Number"; Flags: uninsdeletekey; Tasks: urlhandlers
Root: HKCU; Subkey: "Software\Classes\tel"; ValueType: string; ValueName: "URL Protocol"; ValueData: ""; Tasks: urlhandlers
Root: HKCU; Subkey: "Software\Classes\tel\DefaultIcon"; ValueType: string; ValueData: "{app}\{#AppExe},0"; Tasks: urlhandlers
Root: HKCU; Subkey: "Software\Classes\tel\shell\open\command"; ValueType: string; ValueData: """{app}\{#AppExe}"" ""%1"""; Tasks: urlhandlers

Root: HKCU; Subkey: "Software\Classes\callto"; ValueType: string; ValueData: "URL:Callto Address"; Flags: uninsdeletekey; Tasks: urlhandlers
Root: HKCU; Subkey: "Software\Classes\callto"; ValueType: string; ValueName: "URL Protocol"; ValueData: ""; Tasks: urlhandlers
Root: HKCU; Subkey: "Software\Classes\callto\DefaultIcon"; ValueType: string; ValueData: "{app}\{#AppExe},0"; Tasks: urlhandlers
Root: HKCU; Subkey: "Software\Classes\callto\shell\open\command"; ValueType: string; ValueData: """{app}\{#AppExe}"" ""%1"""; Tasks: urlhandlers

; Custom scheme softphonepro: (provisioning links) is always registered.
Root: HKCU; Subkey: "Software\Classes\softphonepro"; ValueType: string; ValueData: "URL:SoftphonePro"; Flags: uninsdeletekey
Root: HKCU; Subkey: "Software\Classes\softphonepro"; ValueType: string; ValueName: "URL Protocol"; ValueData: ""
Root: HKCU; Subkey: "Software\Classes\softphonepro\DefaultIcon"; ValueType: string; ValueData: "{app}\{#AppExe},0"
Root: HKCU; Subkey: "Software\Classes\softphonepro\shell\open\command"; ValueType: string; ValueData: """{app}\{#AppExe}"" ""%1"""

[Run]
Filename: "{app}\{#AppExe}"; Description: "{cm:LaunchProgram,{#AppName}}"; Flags: nowait postinstall skipifsilent

[UninstallDelete]
Type: filesandordirs; Name: "{app}"

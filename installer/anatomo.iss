; Windows installer for Anatomo (Inno Setup 6).
; Built by .github/workflows/release.yml:
;   ISCC /DAppVersion=2.0.0 /DOutputName=Anatomo-v2.0.0-windows-setup installer\anatomo.iss

#ifndef AppVersion
  #define AppVersion "0.0.0"
#endif
#ifndef OutputName
  #define OutputName "Anatomo-windows-setup"
#endif

[Setup]
AppId={{6F1C2D4E-8B3A-4C57-9E21-A7D3B5F08C14}
AppName=Anatomo
AppVersion={#AppVersion}
AppPublisher=Lumio Apps
AppPublisherURL=https://github.com/lumio-apps/anatomo
DefaultDirName={autopf}\Anatomo
DefaultGroupName=Anatomo
DisableProgramGroupPage=yes
OutputDir=Output
OutputBaseFilename={#OutputName}
SetupIconFile=..\windows\runner\resources\app_icon.ico
UninstallDisplayIcon={app}\anatomo.exe
Compression=lzma2/max
SolidCompression=yes
ArchitecturesAllowed=x64
ArchitecturesInstallIn64BitMode=x64
PrivilegesRequired=lowest
PrivilegesRequiredOverridesAllowed=dialog
CloseApplications=yes
WizardStyle=modern

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"

[Files]
Source: "..\build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{autoprograms}\Anatomo"; Filename: "{app}\anatomo.exe"
Name: "{autodesktop}\Anatomo"; Filename: "{app}\anatomo.exe"; Tasks: desktopicon

[Run]
Filename: "{app}\anatomo.exe"; Description: "{cm:LaunchProgram,Anatomo}"; Flags: nowait postinstall

[Setup]
AppName=${project.launcherDescription}
AppPublisher=${project.finalName}
UninstallDisplayName=${project.finalName}
AppVersion=${project.version}
AppSupportURL=${project.website}
DefaultDirName={localappdata}\${project.finalName}

; ~30 mb for the repo the launcher downloads
ExtraDiskSpaceRequired=30000000
ArchitecturesAllowed=arm64
PrivilegesRequired=lowest

WizardSmallImageFile=${project.projectDir}/innosetup/runelite_small.bmp
SetupIconFile=${project.projectDir}/innosetup/runelite.ico
WizardImageFile=${basedir}/innosetup/left.bmp
UninstallDisplayIcon={app}\${project.finalName}.exe

Compression=lzma2
SolidCompression=yes

OutputDir=${project.projectDir}
OutputBaseFilename=${project.finalName}SetupAArch64

[Tasks]
Name: DesktopIcon; Description: "Create a &desktop icon";

[Files]
Source: "${project.projectDir}\build\win-aarch64\${project.finalName}.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "${project.projectDir}\build\win-aarch64\${project.finalName}.jar"; DestDir: "{app}"
Source: "${project.projectDir}\build\win-aarch64\launcher_aarch64.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "${project.projectDir}\build\win-aarch64\config.json"; DestDir: "{app}"
Source: "${project.projectDir}\build\win-aarch64\jre\*"; DestDir: "{app}\jre"; Flags: recursesubdirs

[Icons]
; start menu
Name: "{userprograms}\${project.finalName}\${project.finalName}"; Filename: "{app}\${project.finalName}.exe"
Name: "{userprograms}\${project.finalName}\${project.finalName} (configure)"; Filename: "{app}\${project.finalName}.exe"; Parameters: "--configure"
Name: "{userprograms}\${project.finalName}\${project.finalName} (safe mode)"; Filename: "{app}\${project.finalName}.exe"; Parameters: "--safe-mode"
Name: "{userdesktop}\${project.finalName}"; Filename: "{app}\${project.finalName}.exe"; Tasks: DesktopIcon

[Run]
Filename: "{app}\${project.finalName}.exe"; Parameters: "--postinstall"; Flags: nowait
Filename: "{app}\${project.finalName}.exe"; Description: "&Open ${project.finalName}"; Flags: postinstall skipifsilent nowait

[InstallDelete]
; Delete the old jvm so it doesn't try to load old stuff with the new vm and crash
Type: filesandordirs; Name: "{app}\jre"
; previous shortcut
Type: files; Name: "{userprograms}\${project.finalName}.lnk"

[UninstallDelete]
Type: filesandordirs; Name: "{%USERPROFILE}\.${project.lowerName}\repository2"
; includes install_id, settings, etc
Type: filesandordirs; Name: "{app}"

[Registry]
Root: HKCU; Subkey: "Software\Classes\runelite-jav"; ValueType: string; ValueName: ""; ValueData: "URL:runelite-jav Protocol"; Flags: uninsdeletekey
Root: HKCU; Subkey: "Software\Classes\runelite-jav"; ValueType: string; ValueName: "URL Protocol"; ValueData: ""; Flags: uninsdeletekey
Root: HKCU; Subkey: "Software\Classes\runelite-jav\shell"; Flags: uninsdeletekey
Root: HKCU; Subkey: "Software\Classes\runelite-jav\shell\open"; Flags: uninsdeletekey
Root: HKCU; Subkey: "Software\Classes\runelite-jav\shell\open\command"; ValueType: string; ValueName: ""; ValueData: """{app}\${project.finalName}.exe"" ""%1"""; Flags: uninsdeletekey

[Code]
#include "upgrade.pas"
#include "usernamecheck.pas"
#include "dircheck.pas"
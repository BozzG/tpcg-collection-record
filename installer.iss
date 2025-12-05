[Setup]
AppName=TPCG Collection Record
AppVersion=1.0.0
AppPublisher=BozzGuo
AppPublisherURL=https://github.com/bozzguo
DefaultDirName={autopf}\TPCG Collection Record
DefaultGroupName=TPCG Collection Record
AllowNoIcons=yes
OutputDir=installer
OutputBaseFilename=tpcg-collection-record-setup
SetupIconFile=windows\runner\resources\app_icon.ico
Compression=lzma
SolidCompression=yes
WizardStyle=modern
PrivilegesRequired=lowest
ArchitecturesAllowed=x64
ArchitecturesInstallIn64BitMode=x64

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"
Name: "chinesesimplified"; MessagesFile: "compiler:Languages\ChineseSimplified.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
Source: "build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\TPCG Collection Record"; Filename: "{app}\tpcg_collection_record.exe"
Name: "{group}\{cm:UninstallProgram,TPCG Collection Record}"; Filename: "{uninstallexe}"
Name: "{autodesktop}\TPCG Collection Record"; Filename: "{app}\tpcg_collection_record.exe"; Tasks: desktopicon

[Run]
Filename: "{app}\tpcg_collection_record.exe"; Description: "{cm:LaunchProgram,TPCG Collection Record}"; Flags: nowait postinstall skipifsilent

[UninstallDelete]
Type: filesandordirs; Name: "{app}"
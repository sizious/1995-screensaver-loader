{
                    * * * [b i g _ f u r y ] S i Z i O U S * * *
        _____________    _____________    _____________________________________
       /            /   /            /   /           /    /      /            /
      /     _______/___/_______     /___/           /    /      /     _______/
     /     /      /   /            /   /     /     /    /      /     /      /
    /            /   /            /   /     /     /    /      /            /
   /________/   /   /     _______/   /     /     /    /__    /_________/  /
  /            /   /            /   /           /           /            /
 /____________/___/____________/___/___________/___________/____________/

 Screensaver Demo Loader v1.0 (19/10/07)

 This unit contains some utilities and initialisation information for the loader
 unit.
}
unit declare;

interface

uses
  Windows, SysUtils, Messages, Classes, Forms, IniFiles;

type
  TssMode = ( ssAffiche , ssConfig , ssMotDePasse , ssPrevisu );
  TFindWindowType = (wtWindow, wtCtrl, wtListBox);

const
  DEMO_BASEDIR = '1995\'; // demo where is located the demo and all resources dirs
  CONFIG_DIR = 'config\'; // config directory
  
var
  // Screensaver mode
  ssMode          : TssMode = ssAffiche;

  // Valeur des paramètres passés au programme
  Param1          : string;
  Param2          : string;

  // Options
  optScreenResol  : Integer = 0;      // listbox demo resolution itemindex
  optScreenFormat : Integer = 0;      // listbox demo format itemindex
  optFSAA         : Boolean = True;   // anti-aliasing
  optSound        : Boolean = True;   // sound

  AppDir          : string;           // screensaver directory
  ConfigDir       : string;           // screensaver config directory
  
procedure ExtractFile(ResName, ResType: PChar; ToFileName: TFileName);
function FSize(const FileName: TFileName): Int64;
procedure HideTaskbarButton;
procedure LoadConfig;
function RipListBox(hListBox: HWND; Output: TFileName): Boolean;
procedure SaveConfig;
function WaitUntilIsValidWindowHandle(WindowType: TFindWindowType; const Caption: string;
  const TimeOut: Integer; hParentWindow: HWND = 0; CtrlID: Word = 0): HWND;

//==============================================================================
implementation
//==============================================================================

uses
  Loader;

var
  ConfigFile: TFileName;
  Ini: TIniFile;

//------------------------------------------------------------------------------

// load the config.
procedure LoadConfig;
begin
  Ini := TIniFile.Create(ConfigFile);
  try
    optScreenResol := Ini.ReadInteger('Config', 'ScreenResolutionItem', optScreenResol);
    optScreenFormat := Ini.ReadInteger('Config', 'ScreenFormatItem', optScreenFormat);
    optFSAA := Ini.ReadBool('Config', 'FSAA', optFSAA);
    optSound := Ini.ReadBool('Config', 'Sound', optSound);
  finally
    Ini.Free;
  end;
end;

//------------------------------------------------------------------------------

// save the config.
procedure SaveConfig;
begin
  Ini := TIniFile.Create(ConfigFile);
  try
    Ini.WriteInteger('Config', 'ScreenResolutionItem', optScreenResol);
    Ini.WriteInteger('Config', 'ScreenFormatItem', optScreenFormat);
    Ini.WriteBool('Config', 'FSAA', optFSAA);
    Ini.WriteBool('Config', 'Sound', optSound);
  finally
    Ini.Free;
  end;
end;

//------------------------------------------------------------------------------

// perform a FindWindow with a timeout.  
function WaitUntilIsValidWindowHandle(WindowType: TFindWindowType; const Caption: string;
  const TimeOut: Integer; hParentWindow: HWND = 0; CtrlID: Word = 0): HWND;
var
  SecurityCounter: Integer;

begin
  Result := 0;
  SecurityCounter := TimeOut;
  while (SecurityCounter > 0) do begin
    Sleep(1);
    Dec(SecurityCounter);

    case WindowType of
      wtWindow: Result := FindWindow(nil, PChar(Caption));
      wtCtrl: Result := FindWindowEx(hParentWindow, 0, nil, PChar(Caption));
      wtListBox: Result := GetDlgItem(hParentWindow, CtrlID);
    end;

    if (Result <> 0) then SecurityCounter := -1;
  end;
end;

//------------------------------------------------------------------------------

// Extract a file from the screensaver resource section.
procedure ExtractFile(ResName, ResType: PChar; ToFileName: TFileName);
var
 ResourceStream : TResourceStream;
 FichierStream  : TFileStream;

begin
  ResourceStream := TResourceStream.Create(hInstance, ResName, PChar(ResType));

  try
    FichierStream := TFileStream.Create(ToFileName, fmCreate);
    try
      FichierStream.CopyFrom(ResourceStream, 0);
    finally
      FichierStream.Free;
    end;
  finally
    ResourceStream.Free;
  end;
end;

//------------------------------------------------------------------------------

// Get the file size.
function FSize(const FileName: TFileName): Int64;
var
  F: file;

begin
  try
    AssignFile(F, FileName);
    Reset(F, 1);
    Result := FileSize(F);
    CloseFile(F);
  except
    Result := 0;
  end;
end;

//------------------------------------------------------------------------------

// Get all the listbox content and save it to a file.
function RipListBox(hListBox: HWND; Output: TFileName): Boolean;
var
  i, Counter, StrLen: Integer;
  F: TextFile;
  Buffer: PChar;
  s: string;
  
begin
  Result := True;
  try
    Counter := SendMessage(hListBox, LB_GETCOUNT, 0, 0);
    AssignFile(F, Output);
    ReWrite(F);
    for i := 0 to Counter - 1 do begin
      StrLen := SendMessage(hListBox, LB_GETTEXTLEN, i, 0);
      GetMem(Buffer, StrLen + 1);
      SendMessage(hListBox, LB_GETTEXT, i, LPARAM(Buffer));
      SetString(s, Buffer, StrLen);
      WriteLn(F, s);
      FreeMem(Buffer);
    end;
    CloseFile(F);
  except
    Result := False;
  end;
end;

//------------------------------------------------------------------------------
{
  A window doesn't have a taskbar button if:

  * The window is hidden (ShowWindow was called with SW_HIDE).
  * The window has an owner or was created with the WS_EX_TOOLWINDOW extended style.
}
{
procedure TFrmMain.FormCreate(Sender: TObject);
begin
Application.OnMinimize := OnApplicationMinimize ;

ShowWindow(Application.Handle, SW_HIDE);
SetWindowLong(Application.Handle, GWL_EXSTYLE,
GetWindowLong(Application.Handle, GWL_EXSTYLE) and not WS_EX_APPWINDOW
or WS_EX_TOOLWINDOW);
ShowWindow(Application.Handle, SW_SHOW);
end;

procedure TFrmMain.OnApplicationMinimize(Sender: TObject);
begin
Hide ;
end;
}
procedure HideTaskbarButton;
begin
  // ShowWindow(Application.Handle, SW_HIDE);
  ShowWindow(Application.Handle, SW_HIDE);
  SetWindowLong(Application.Handle, GWL_EXSTYLE,
  GetWindowLong(Application.Handle, GWL_EXSTYLE) and not WS_EX_APPWINDOW
  or WS_EX_TOOLWINDOW);
  ShowWindow(Application.Handle, SW_SHOW);
end;

//------------------------------------------------------------------------------

initialization
  AppDir := IncludeTrailingPathDelimiter(ExtractFilePath(Application.ExeName)) + DEMO_BASEDIR;
  ConfigDir := AppDir + CONFIG_DIR;
  if not DirectoryExists(ConfigDir) then ForceDirectories(ConfigDir);  
  ConfigFile := ConfigDir + ChangeFileExt(ExtractFileName(ParamStr(0)), '.ini');

//------------------------------------------------------------------------------

end.

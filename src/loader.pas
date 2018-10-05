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

 This unit contains all the stuff needed to load the demo as a screensaver.
}
unit loader;

interface

uses
  Windows, SysUtils, Messages, Classes, Forms, ShellApi;

const
  DEMO_TITLE =  '1995 demo by kewlers and mfx';
  DEMO_FILENAME = 'test3d.exe';             // demo filename

  DEMO_CFGWIN_TITLE = 'GLUE';             // demo config window title
  DEMO_TITLE1 = 'GLUE';                   // demo window title 1
  DEMO_TITLE2 = 'GLUE (FSAA)';            // title 2
  CBX_LOOP = 'Loop';                      // loop checkbox in demo config window
  BTN_RUN = 'Run';                        // run in demo config window
  BTN_EXIT = 'Exit';                      // exit button in demo config window
  CBX_FSAA = 'Anti-alias';                // FSAA

  SOUND_FILE = 'data\VR78f.mp3';          // SOUND FILE
  SOUND_SIZE = 7722005;                   // SOUND FILE SIZE
  NULLSND_SIZE = 325085;                  // NULL SOUND FILE SIZE

  RESOL_FILE = 'scresols.dat';            // contains all the resolutions listed by the demo
  FORMAT_FILE = 'scrfrts.dat';            // same but for the formats
  
  ID_LBRESOLUTION = 1005;                 // resolution listbox in demo config window
  ID_LBFORMAT = 1006;                     // format listbox in demo config window

  CTRLFIND_TIMEOUT = 200;                 // find controls timeout


procedure CloseDemo;
function DemoRunning: Boolean;
procedure GetVideoModes;
procedure OpenDemo(ResolutionItemSelect, FormatItemSelect: Uint; FSAA: Boolean; Sound: Boolean);

implementation

uses
  Declare;

//------------------------------------------------------------------------------

// Enable or disable sound.
procedure ApplySound(Enabled: Boolean);
var
  RealSoundFile: string;

begin
  RealSoundFile := AppDir + SOUND_FILE;

  if Enabled then begin
    // fichier son à désactiver
    if FSize(RealSoundFile) = NULLSND_SIZE then begin
      RenameFile(RealSoundFile, ChangeFileExt(RealSoundFile, '.null'));
      RenameFile(ChangeFileExt(RealSoundFile, '.bak'), ChangeFileExt(RealSoundFile, '.mp3'));
    end;
  end else begin
    // fichier son à désactiver
    if FSize(RealSoundFile) = SOUND_SIZE then begin
      RenameFile(RealSoundFile, ChangeFileExt(RealSoundFile, '.bak'));
      if FSize(ChangeFileExt(RealSoundFile, '.null')) <> NULLSND_SIZE then
        ExtractFile('NULLSND', RT_RCDATA, RealSoundFile)
      else
        RenameFile(ChangeFileExt(RealSoundFile, '.null'), ChangeFileExt(RealSoundFile, '.mp3'));
    end;
  end;
  
end;

//------------------------------------------------------------------------------

// run the demo with saved parameters.
procedure OpenDemo(ResolutionItemSelect, FormatItemSelect: Uint; FSAA: Boolean; Sound: Boolean);
var
  hMainWin, hCtrl: HWND;
  SecurityCounter: Integer;
  
begin
  ApplySound(Sound); // enable or disable sound

  SetCurrentDir(AppDir); // set the current dir for the demo
  ShellExecute(Application.Handle, 'open', PChar(DEMO_FILENAME), '', '', SW_HIDE);

  hMainWin := WaitUntilIsValidWindowHandle(wtWindow, DEMO_CFGWIN_TITLE, CTRLFIND_TIMEOUT); //Retrouve le Handle de la fenêtre principale
  if hMainWin <> 0 then begin

    SetForegroundWindow(hMainWin);
    ShowWindow(hMainWin, SW_HIDE);
    ShowWindow(hMainWin, SW_MINIMIZE);
    {SetWindowLong(hMainWin, GWL_EXSTYLE, GetWindowLong(hMainWin, GWL_EXSTYLE) or WS_EX_TOOLWINDOW);
    ShowWindow(hMainWin, SW_SHOW);}

    {$IFDEF DEBUG}
    // enlever le fullscreen
    hCtrl := WaitUntilIsValidWindowHandle(wtCtrl, 'Fullscreen', CTRLFIND_TIMEOUT, hMainWin);
    if hCtrl <> 0 then SendMessage(hCtrl, BM_CLICK, 0, 0);
    {$ENDIF}

    // FSAA
    if not optFSAA then begin
      hCtrl := WaitUntilIsValidWindowHandle(wtCtrl, CBX_FSAA, CTRLFIND_TIMEOUT, hMainWin);
      if hCtrl <> 0 then SendMessage(hCtrl, BM_CLICK, 0, 0);
    end;

    //Avoir le handle du bouton
    hCtrl := WaitUntilIsValidWindowHandle(wtCtrl, CBX_LOOP, CTRLFIND_TIMEOUT, hMainWin);
    if hCtrl <> 0 then SendMessage(hCtrl, BM_CLICK, 0, 0);  //on clique dessus

    // sélection de la résolution
    hCtrl := WaitUntilIsValidWindowHandle(wtListBox, '', CTRLFIND_TIMEOUT, hMainWin, ID_LBRESOLUTION);
    SendMessage(hCtrl, LB_SETCURSEL, ResolutionItemSelect, 0);

    // sélection du format d'image
    hCtrl := WaitUntilIsValidWindowHandle(wtListBox, '', CTRLFIND_TIMEOUT, hMainWin, ID_LBFORMAT);
    SendMessage(hCtrl, LB_SETCURSEL, FormatItemSelect, 0);

    // run!
    hCtrl := WaitUntilIsValidWindowHandle(wtCtrl, BTN_RUN, CTRLFIND_TIMEOUT, hMainWin);
    if hCtrl <> 0 then SendMessage(hCtrl, BM_CLICK, 0, 0);  //on clique dessus

    // activons la fenêtre de la démo
    SecurityCounter := CTRLFIND_TIMEOUT;
    while (SecurityCounter > 0) do begin
      Sleep(1);
      Dec(SecurityCounter);

      hMainWin := FindWindow(nil, PChar(DEMO_TITLE1));
      if hMainWin <> 0 then SecurityCounter := -1;
      hMainWin := FindWindow(nil, PChar(DEMO_TITLE2));
      if hMainWin <> 0 then SecurityCounter := -1;
    end;

    if hMainWin <> 0 then begin
      SetActiveWindow(hMainWin);
      SetForegroundWindow(hMainWin);
    end;
    
  end;
end;

//------------------------------------------------------------------------------

// Gets the window handle of the DEMO. Returns 0 if not found.
function DemoWindowHandle: HWND;
begin
  Result := FindWindow(nil, PChar(DEMO_CFGWIN_TITLE));
  if Result <> 0 then Exit;
  
  Result := FindWindow(nil, PChar(DEMO_TITLE1));
  if Result <> 0 then Exit;

  Result := FindWindow(nil, PChar(DEMO_TITLE2));
end;

//------------------------------------------------------------------------------

// Returns true if the demo is running.
function DemoRunning: Boolean;
begin
  Result := DemoWindowHandle <> 0;
end;

//------------------------------------------------------------------------------

// Quit the demo program.
procedure CloseDemo;
var
  hWin: HWND;

begin
  hWin := DemoWindowHandle;
  if hWin <> 0 then begin
    SendMessage(hWin, WM_CLOSE, 0, 0);
  end;
end;

//------------------------------------------------------------------------------

// Get the videos mode from the demo, including the resolution and the image format.
procedure GetVideoModes;
var
  hMainWin, hCtrl: HWND;
  
begin
  SetCurrentDir(AppDir);
  ShellExecute(Application.Handle, 'open', PChar(DEMO_FILENAME), '', '', SW_HIDE);

  hMainWin := WaitUntilIsValidWindowHandle(wtWindow, DEMO_CFGWIN_TITLE, CTRLFIND_TIMEOUT);
  if hMainWin <> 0 then begin

    ShowWindow(hMainWin, SW_MINIMIZE);

    // récuperer la liste des résolutions
    hCtrl := WaitUntilIsValidWindowHandle(wtListBox, '', CTRLFIND_TIMEOUT, hMainWin, ID_LBRESOLUTION);
    // écrire le contenu de la listbox dans le fichier
    RipListBox(hCtrl, ConfigDir + RESOL_FILE);
    
    // récuperer la liste des formats d'images
    hCtrl := WaitUntilIsValidWindowHandle(wtListBox, '', CTRLFIND_TIMEOUT, hMainWin, ID_LBFORMAT);
    RipListBox(hCtrl, ConfigDir + FORMAT_FILE);

    // sortir
    hCtrl := WaitUntilIsValidWindowHandle(wtCtrl, BTN_EXIT, CTRLFIND_TIMEOUT, hMainWin);
    if hCtrl <> 0 then SendMessage(hCtrl, BM_CLICK, 0, 0);  //on clique dessus
  end;
end;

//------------------------------------------------------------------------------

end.

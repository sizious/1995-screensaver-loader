program scrnload;

{$R 'scrname.res' 'scrname.rc'}
{$R 'externrc.res' 'externrc.rc'}

uses
messages,
  Windows,
  Forms,
  SysUtils,
  config in 'config.pas' {frmConfig},
  declare in 'declare.pas',
  main in 'main.pas' {frmScreen},
  loader in 'loader.pas',
  uFMOD in 'uFMOD.pas',
  about in 'about.pas' {frmAbout},
  oldskool_font_mapper in 'oldskool_font_mapper.pas',
  oldskool_font_vcl in 'oldskool_font_vcl.pas';

// Modification de l'extension
{$E scr}
{$R *.res}

var
  MdpFunc  : function (a : PChar; ParentHandle : THandle; b, c : Integer) : Integer; stdcall;
  MdpLib   : THandle;

begin
  // on v�rifie qu'il n'y a pas de d�mo lanc�e !
  if DemoRunning then Halt(0);

  // r�cup�rer la fen�tre courante
  hForeWin := GetForegroundWindow;
  
  // On commence par prendre les param�tres pass�s au programme
  Param1 := Copy(UpperCase(ParamStr(1)),1,2);
  Param2 := UpperCase(ParamStr(2));

  // On filtre le premier afin de ne garder que la lettre
  If (Length(Param1)>0)And Not (Param1[1] In ['A'..'Z']) Then
    Param1 := Copy(Param1,2,1);

  // On d�termine ce qu'il faut faire en fonction de Param1
  ssMode := ssConfig;
  If Param1='P' Then ssMode := ssPrevisu;
  If Param1='C' Then ssMode := ssConfig; // ou aucun param
  If Param1='S' Then ssMode := ssAffiche;
  If Param1='A' Then ssMode := ssMotDePasse;

  // Traitement en fonction des cas
  Case ssMode Of
    ssMotDePasse:Begin
      MdpLib := LoadLibrary('MPR.DLL');
      If MdpLib <> 0 Then
      Begin
        MdpFunc := GetProcAddress(MdpLib, 'PwdChangePasswordA');
        If Assigned(MdpFunc) Then
          MdpFunc('SCRSAVE',StrToInt(Param2),0,0);
        FreeLibrary(MdpLib);
      End;
      Exit;
    End;
  End;

  // Une application �cran de veille doit �tre mono-instance
  SetLastError(NO_ERROR);
  CreateMutex(nil, False, 'SIZ_DEMOSCREENSAVER');
  if GetLastError = ERROR_ALREADY_EXISTS Then Exit;

  // Traitement en fonction des cas
  Case ssMode Of
    ssAffiche, ssPrevisu:
    Begin
      Application.Initialize;
      Application.Title := 'Screensaver Demo Loader';
  Application.CreateForm(TfrmScreen, frmScreen);

      // mode pr�visualisation (la petite fen�tre dans l'�cran de windows)
      if ssMode = ssPrevisu then begin
        frmScreen.WindowState := wsMaximized;
        frmScreen.FormStyle := fsStayOnTop;
        frmScreen.Position := poDefault;
        frmScreen.Parent := nil;
        frmScreen.ParentWindow := StrToInt(Param2);
      end else begin
        // mode en screenshot: on lance notre programme
        frmScreen.Timer.Enabled := False;
        frmScreen.Left := 0;
        frmScreen.Top := 0;
        frmScreen.Width := 0;
        frmScreen.Height := 0;
      end;

      Application.Run;
    End;
    ssConfig:
    Begin
      Application.Initialize;
      Application.CreateForm(TfrmConfig, frmConfig);
      Application.Run;
    End;
  End;


end.

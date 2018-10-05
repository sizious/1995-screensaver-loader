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

 Previsualisation simple window
}
unit main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, HookTimer;

type
  TfrmScreen = class(TForm)
    Image: TImage;
    Timer: TTimer;
    HookTimer: THookTimer;
    RenableTimer: TTimer;
    procedure TimerTimer(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure HookTimerMouseMove(Sender: TObject; Shift: TShiftState; PrevX,
      PrevY, X, Y: Integer);
    procedure HookTimerKeyUp(Sender: TObject; Key: Word);
    procedure RenableTimerTimer(Sender: TObject);
    procedure HookTimerMouseUp(Sender: TObject; Button: TMouseButton; X,
      Y: Integer);
  private
    { D�clarations priv�es }
    procedure QuitScreenSaver;
  public
    { D�clarations publiques }
  end;

var
  frmScreen: TfrmScreen;
  hForeWin: HWND;
  
implementation

{$R *.dfm}

uses
  Declare, Registry, Loader;

var
  // Valeur de d�placement de l'image
  DecX        : Integer = 3;
  DecY        : Integer = 3;

//------------------------------------------------------------------------------

procedure TfrmScreen.FormCreate(Sender: TObject);
begin
  Color := clBlack;
  Image.Picture.Bitmap.Handle := LoadBitmap(hInstance, 'LOGO');
  DoubleBuffered := True;
  
  // Lecture des param�tres de configuration
  LoadConfig;
end;

//------------------------------------------------------------------------------

procedure TfrmScreen.FormShow(Sender: TObject);
var
  i: Integer;
  
begin
  HideTaskbarButton; // On masque l'application dans la barre des t�ches
  
  // On dit au syst�me que l'on est en mode veille
  SystemParametersInfo(SPI_SCREENSAVERRUNNING, 1, @i, 0);
    
  if ssMode = ssAffiche then begin
    OpenDemo(optScreenResol, optScreenFormat, optFSAA, optSound);
    frmScreen.RenableTimer.Enabled := True;
  end else begin
    // BUG DE MERDE, LA FENETRE PROPRIETE D'AFFICHAGE PERD LE FOCUS!
    Sleep(100);
    Application.ProcessMessages;
    SetForegroundWindow(hForeWin);
    SetActiveWindow(hForeWin);
    Windows.SetFocus(hForeWin);
  end;
end;

//------------------------------------------------------------------------------

procedure TfrmScreen.HookTimerKeyUp(Sender: TObject; Key: Word);
begin
  QuitScreenSaver;
end;

//------------------------------------------------------------------------------

procedure TfrmScreen.HookTimerMouseMove(Sender: TObject; Shift: TShiftState;
  PrevX, PrevY, X, Y: Integer);
begin
  QuitScreenSaver;
end;

//------------------------------------------------------------------------------

procedure TfrmScreen.HookTimerMouseUp(Sender: TObject; Button: TMouseButton; X,
  Y: Integer);
begin
  QuitScreenSaver;
end;

//------------------------------------------------------------------------------

procedure TfrmScreen.QuitScreenSaver;
begin
  HookTimer.Enabled := False;
  Close;
end;

//------------------------------------------------------------------------------

procedure TfrmScreen.RenableTimerTimer(Sender: TObject);
begin
  RenableTimer.Enabled := False;

  // on r�active le timer si le mot de passe fourni s'est r�v�l� invalide
  HookTimer.Reset(True);
  HookTimer.Enabled := True;
end;

//------------------------------------------------------------------------------

procedure TfrmScreen.TimerTimer(Sender: TObject);
begin
  // Code de d�placement de l'image
  Image.Left := Image.Left + DecX;
  Image.Top := Image.Top + DecY;
  If (Image.Left + Image.Width)>=ClientWidth Then DecX := -3;
  If (Image.Top + Image.Height)>=ClientHeight Then DecY := -3;
  If Image.Left <= 0 Then DecX := 3;
  If Image.Top  <= 0 Then DecY := 3;
end;

//------------------------------------------------------------------------------

procedure TfrmScreen.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
Var Reg:TRegistry;
    MdpFunc   : function (Parent : THandle) : Boolean; stdcall;
    MdpLib  : THandle;

begin
  // On teste le mot de passe �ventuel dans le cas de demande de fermeture de la fiche
  // For Windows 9x/ME
  CanClose := True;

  If ssMode = ssAffiche Then
  Try
    // Test seulement en affichage normal
    Reg := TRegistry.Create;
    Try
      // Lecture de la clef
      Reg.RootKey := HKEY_CURRENT_USER;
      If Reg.OpenKey('Control Panel\Desktop', False) Then
        if Reg.ValueExists('ScreenSaveUsePassword') then
          If Reg.ReadInteger('ScreenSaveUsePassword') <> 0 Then
          Begin
            MdpLib := LoadLibrary('PASSWORD.CPL');
            If MdpLib <> 0 Then
            Begin
              // Appel de la proc�dure de demande de mot de passe
              MdpFunc := GetProcAddress(MdpLib, 'VerifyScreenSavePwd');
              CanClose := MdpFunc(Handle);
              FreeLibrary(MdpLib);
            End;
          End;
    Finally
      Reg.Free;
    End;
  Except
    // Sur erreur, par d�faut on ferme.
    CanClose := True;
  End;

  // on r�active le timer pour sortir
  if not CanClose then
    RenableTimer.Enabled := True;
end;

//------------------------------------------------------------------------------

procedure TfrmScreen.FormClose(Sender: TObject; var Action: TCloseAction);
var
  i: Integer;
  
begin
  // On dit au syst�me qu'il n'est plus en mode veille
  SystemParametersInfo(SPI_SCREENSAVERRUNNING, 0, @i, 0);
    
  if ssMode = ssAffiche then begin

    // on dit � la d�mo que c'est fini
    while DemoRunning do begin
      CloseDemo;
      Application.ProcessMessages;
      Sleep(1000);
    end;
    
  end;
end;

//------------------------------------------------------------------------------

end.

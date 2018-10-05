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

 Configuration window

 Bugs:  When the config window retrives resolutions/formats modes from the demo,
        the config window lose the focus
}
unit config;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, XPMan, ExtCtrls;

type
  TfrmConfig = class(TForm)
    XPManifest1: TXPManifest;
    Panel1: TPanel;
    btnOK: TBitBtn;
    btnCancel: TBitBtn;
    Bevel1: TBevel;
    btnAbout: TBitBtn;
    cbFSAA: TCheckBox;
    cbSound: TCheckBox;
    cbxScreenResol: TComboBox;
    cbxScreenFormat: TComboBox;
    Label1: TLabel;
    Label2: TLabel;
    Shape1: TShape;
    Bevel2: TBevel;
    Image1: TImage;
    Label3: TLabel;
    lConfigDemoTitle: TLabel;
    procedure btnCancelClick(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnAboutClick(Sender: TObject);
  private
    { Déclarations privées }
  public
    { Déclarations publiques }
  end;

var
  frmConfig: TfrmConfig;

implementation

{$R *.dfm}

uses
  Loader, Declare, about, main;

//------------------------------------------------------------------------------

procedure TfrmConfig.FormCreate(Sender: TObject);
begin
  HideTaskbarButton;
  Self.lConfigDemoTitle.Caption := 'For ' + DEMO_TITLE;
end;

//------------------------------------------------------------------------------

procedure TfrmConfig.FormShow(Sender: TObject);
begin
  // On masque l'application dans la barre des tâches
  HideTaskbarButton;

  // vérifions si nous avons extrait les modes vidéos / format
  if (not FileExists(ConfigDir + RESOL_FILE)) or (not FileExists(ConfigDir + FORMAT_FILE)) then
    GetVideoModes;

  cbxScreenResol.Items.LoadFromFile(ConfigDir + RESOL_FILE);
  cbxScreenFormat.Items.LoadFromFile(ConfigDir + FORMAT_FILE);

  // Lecture et affichage des paramètres
  LoadConfig;
  cbxScreenResol.ItemIndex := optScreenResol;
  cbxScreenFormat.ItemIndex := optScreenFormat;
  cbFSAA.Checked := optFSAA;
  cbSound.Checked := optSound;
end;

//------------------------------------------------------------------------------

procedure TfrmConfig.btnAboutClick(Sender: TObject);
begin
  frmAbout := TfrmAbout.Create(Application);
  try
    frmAbout.ShowModal;
  finally
    frmAbout.Free;
  end;
end;

procedure TfrmConfig.btnCancelClick(Sender: TObject);
begin
  // Pour annuler, on ferme simplement...
  Close;
end;

//------------------------------------------------------------------------------

procedure TfrmConfig.btnOKClick(Sender: TObject);
begin
  // En cas de validation il faut sauver les paramètres
  optScreenResol  := cbxScreenResol.ItemIndex;
  optScreenFormat := cbxScreenFormat.ItemIndex;
  optFSAA         := cbFSAA.Checked;
  optSound        := cbSound.Checked;
  SaveConfig;
  
  // Puis fermer la fenêtre
  Close;
end;

//------------------------------------------------------------------------------

end.

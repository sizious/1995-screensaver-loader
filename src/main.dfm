object frmScreen: TfrmScreen
  Left = 1
  Top = 106
  BorderStyle = bsNone
  Caption = 'frmScreen'
  ClientHeight = 200
  ClientWidth = 320
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnClose = FormClose
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Image: TImage
    Left = 32
    Top = 16
    Width = 40
    Height = 40
    AutoSize = True
  end
  object Timer: TTimer
    Interval = 50
    OnTimer = TimerTimer
    Left = 4
    Top = 4
  end
  object HookTimer: THookTimer
    Enabled = False
    Interval = 100
    OnMouseMove = HookTimerMouseMove
    OnMouseUp = HookTimerMouseUp
    OnKeyUp = HookTimerKeyUp
    Left = 4
    Top = 168
  end
  object RenableTimer: TTimer
    Enabled = False
    Interval = 500
    OnTimer = RenableTimerTimer
    Left = 288
    Top = 168
  end
end

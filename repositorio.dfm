object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Form1'
  ClientHeight = 389
  ClientWidth = 679
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object BitBtn1: TBitBtn
    Left = 32
    Top = 272
    Width = 145
    Height = 25
    Caption = 'BitBtn1'
    TabOrder = 0
    OnClick = BitBtn1Click
  end
  object btn1: TBitBtn
    Left = 336
    Top = 272
    Width = 75
    Height = 25
    Caption = 'btn1'
    TabOrder = 1
    OnClick = btn1Click
  end
  object Connection: TSQLConnection
    DriverName = 'DevartMySQLDirect'
    LoginPrompt = False
    Params.Strings = (
      'DriverUnit=DbxDevartMySql'
      
        'DriverPackageLoader=TDBXDynalinkDriverLoader,DBXCommonDriver190.' +
        'bpl'
      
        'MetaDataPackageLoader=TDBXDevartMySqlMetaDataCommandFactory,DbxD' +
        'evartMySqlDriver190.bpl'
      'ProductName=DevartMySQL'
      'GetDriverFunc=getSQLDriverMySQLDirect'
      'LibraryName=dbexpmda40.dll'
      'VendorLib=not used'
      'MaxBlobSize=-1'
      'FetchAll=True'
      'EnableBoolean=False'
      'UseUnicode=True'
      'IPVersion=IPv4'
      'BlobSize=-1'
      'HostName=localhost:3307'
      'DataBase=orm'
      'User_Name=root'
      'Password=p@ssw0rd')
    Connected = True
    Left = 16
    Top = 16
  end
end

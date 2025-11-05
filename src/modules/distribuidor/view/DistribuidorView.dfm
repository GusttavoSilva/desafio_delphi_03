object frmDistribuidorView: TfrmDistribuidorView
  Left = 0
  Top = 0
  Caption = 'Cadastro de Distribuidores'
  ClientHeight = 440
  ClientWidth = 720
  Color = clWhite
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'Segoe UI'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 17
  object pnlTop: TPanel
    AlignWithMargins = True
    Left = 8
    Top = 8
    Width = 704
    Height = 56
    Margins.Left = 8
    Margins.Top = 8
    Margins.Right = 8
    Align = alTop
    BevelOuter = bvNone
    Color = 16744448
    ParentBackground = False
    TabOrder = 0
    ExplicitLeft = 12
    ExplicitTop = 12
    ExplicitWidth = 696
    object lblTitulo: TLabel
      Left = 24
      Top = 16
      Width = 260
      Height = 30
      Caption = 'Cadastro de Distribuidores'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -21
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
    end
  end
  object pnlButtons: TPanel
    AlignWithMargins = True
    Left = 8
    Top = 374
    Width = 704
    Height = 54
    Margins.Left = 8
    Margins.Right = 8
    Margins.Bottom = 12
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 2
    ExplicitLeft = 12
    ExplicitWidth = 696
    object btnNovo: TButton
      Left = 0
      Top = 14
      Width = 100
      Height = 30
      Caption = 'Novo'
      TabOrder = 0
      OnClick = btnNovoClick
    end
    object btnSalvar: TButton
      Left = 112
      Top = 14
      Width = 100
      Height = 30
      Caption = 'Salvar'
      TabOrder = 1
      OnClick = btnSalvarClick
    end
    object btnExcluir: TButton
      Left = 224
      Top = 14
      Width = 100
      Height = 30
      Caption = 'Excluir'
      TabOrder = 2
      OnClick = btnExcluirClick
    end
    object btnCancelar: TButton
      Left = 336
      Top = 14
      Width = 100
      Height = 30
      Caption = 'Cancelar'
      TabOrder = 3
      OnClick = btnCancelarClick
    end
    object btnAtualizar: TButton
      Left = 448
      Top = 14
      Width = 100
      Height = 30
      Caption = 'Atualizar'
      TabOrder = 4
      OnClick = btnAtualizarClick
    end
    object btnFechar: TButton
      Left = 560
      Top = 14
      Width = 100
      Height = 30
      Caption = 'Fechar'
      TabOrder = 5
      OnClick = btnFecharClick
    end
  end
  object pgcMain: TPageControl
    AlignWithMargins = True
    Left = 8
    Top = 67
    Width = 704
    Height = 304
    Margins.Left = 8
    Margins.Top = 0
    Margins.Right = 8
    Margins.Bottom = 0
    ActivePage = tabConsulta
    Align = alClient
    TabOrder = 1
    object tabConsulta: TTabSheet
      Caption = 'Consulta'
      TabVisible = False
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object dbgDistribuidores: TDBGrid
        Left = 0
        Top = 0
        Width = 688
        Height = 256
        Align = alClient
        DataSource = dsDistribuidor
        FixedColor = 15790320
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Segoe UI'
        Font.Style = []
        Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgConfirmDelete, dgCancelOnExit]
        ParentFont = False
        ReadOnly = True
        TabOrder = 0
        TitleFont.Charset = DEFAULT_CHARSET
        TitleFont.Color = clWindowText
        TitleFont.Height = -13
        TitleFont.Name = 'Segoe UI'
        TitleFont.Style = [fsBold]
        OnCellClick = dbgDistribuidoresCellClick
      end
    end
    object tabCadastro: TTabSheet
      Caption = 'Cadastro'
      ImageIndex = 1
      TabVisible = False
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object pnlCadastro: TPanel
        AlignWithMargins = True
        Left = 12
        Top = 12
        Width = 664
        Height = 232
        Align = alClient
        BevelOuter = bvNone
        TabOrder = 0
        object lblNome: TLabel
          Left = 0
          Top = 0
          Width = 39
          Height = 17
          Caption = 'Nome:'
        end
        object lblCnpj: TLabel
          Left = 0
          Top = 72
          Width = 32
          Height = 17
          Caption = 'CNPJ:'
        end
        object edtNome: TEdit
          Left = 0
          Top = 24
          Width = 360
          Height = 25
          TabOrder = 0
        end
        object edtCnpj: TEdit
          Left = 0
          Top = 96
          Width = 200
          Height = 25
          TabOrder = 1
        end
      end
    end
  end
  object dsDistribuidor: TDataSource
    Left = 524
    Top = 164
  end
end

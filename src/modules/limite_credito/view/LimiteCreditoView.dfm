object frmLimiteCreditoView: TfrmLimiteCreditoView
  Left = 0
  Top = 0
  Caption = 'Gerenciamento de Limites de Cr'#233'dito'
  ClientHeight = 550
  ClientWidth = 900
  Color = clWhite
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  TextHeight = 17
  object pnlTop: TPanel
    AlignWithMargins = True
    Left = 8
    Top = 8
    Width = 884
    Height = 80
    Margins.Left = 8
    Margins.Top = 8
    Margins.Right = 8
    Align = alTop
    BevelOuter = bvNone
    Color = 16744448
    ParentBackground = False
    TabOrder = 0
    object lblTitulo: TLabel
      Left = 24
      Top = 16
      Width = 363
      Height = 30
      Caption = 'Gerenciamento de Limites de Cr'#233'dito'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -21
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblDistribuidorLogado: TLabel
      Left = 24
      Top = 52
      Width = 129
      Height = 17
      Caption = 'Distribuidor Logado:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object cboDistribuidorLogado: TComboBox
      Left = 168
      Top = 48
      Width = 300
      Height = 25
      Style = csDropDownList
      TabOrder = 0
      OnChange = cboDistribuidorLogadoChange
    end
  end
  object pnlButtons: TPanel
    AlignWithMargins = True
    Left = 8
    Top = 486
    Width = 884
    Height = 52
    Margins.Left = 8
    Margins.Right = 8
    Margins.Bottom = 12
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 1
    object btnNovo: TButton
      Left = 0
      Top = 12
      Width = 100
      Height = 30
      Caption = 'Novo'
      TabOrder = 0
      OnClick = btnNovoClick
    end
    object btnSalvar: TButton
      Left = 112
      Top = 12
      Width = 100
      Height = 30
      Caption = 'Salvar'
      TabOrder = 1
      OnClick = btnSalvarClick
    end
    object btnExcluir: TButton
      Left = 224
      Top = 12
      Width = 100
      Height = 30
      Caption = 'Excluir'
      TabOrder = 2
      OnClick = btnExcluirClick
    end
    object btnCancelar: TButton
      Left = 336
      Top = 12
      Width = 100
      Height = 30
      Caption = 'Cancelar'
      TabOrder = 3
      OnClick = btnCancelarClick
    end
    object btnAtualizar: TButton
      Left = 448
      Top = 12
      Width = 100
      Height = 30
      Caption = 'Atualizar'
      TabOrder = 4
      OnClick = btnAtualizarClick
    end
    object btnFechar: TButton
      Left = 560
      Top = 12
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
    Top = 91
    Width = 884
    Height = 392
    Margins.Left = 8
    Margins.Top = 0
    Margins.Right = 8
    Margins.Bottom = 0
    ActivePage = tabConsulta
    Align = alClient
    TabOrder = 2
    object tabConsulta: TTabSheet
      Caption = 'Consulta'
      TabVisible = False
      object dbgLimites: TDBGrid
        Left = 0
        Top = 0
        Width = 876
        Height = 382
        Align = alClient
        DataSource = dsLimites
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
        OnCellClick = dbgLimitesCellClick
      end
    end
    object tabCadastro: TTabSheet
      Caption = 'Cadastro'
      ImageIndex = 1
      TabVisible = False
      object pnlCadastro: TPanel
        AlignWithMargins = True
        Left = 3
        Top = 3
        Width = 870
        Height = 376
        Align = alClient
        BevelOuter = bvNone
        TabOrder = 0
        object lblProdutor: TLabel
          Left = 0
          Top = 0
          Width = 55
          Height = 17
          Caption = 'Produtor:'
        end
        object lblLimite: TLabel
          Left = 0
          Top = 72
          Width = 91
          Height = 17
          Caption = 'Valor do Limite:'
        end
        object cboProdutor: TComboBox
          Left = 0
          Top = 24
          Width = 400
          Height = 25
          Style = csDropDownList
          TabOrder = 0
        end
        object edtLimite: TEdit
          Left = 0
          Top = 96
          Width = 200
          Height = 25
          TabOrder = 1
          Text = '0,00'
        end
      end
    end
  end
  object dsLimites: TDataSource
    Left = 720
    Top = 256
  end
end

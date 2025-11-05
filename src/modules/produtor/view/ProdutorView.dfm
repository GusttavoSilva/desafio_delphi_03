object frmProdutorView: TfrmProdutorView
  Left = 0
  Top = 0
  Caption = 'Cadastro de Produtores'
  ClientHeight = 420
  ClientWidth = 720
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
    object lblTitulo: TLabel
      Left = 24
      Top = 16
      Width = 231
      Height = 30
      Caption = 'Cadastro de Produtores'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -21
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
    end
  end
  object pgcMain: TPageControl
    AlignWithMargins = True
    Left = 8
    Top = 67
    Width = 704
    Height = 286
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
      object dbgProdutores: TDBGrid
        Left = 0
        Top = 0
        Width = 696
        Height = 276
        Align = alClient
        DataSource = dsProdutor
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
        OnCellClick = dbgProdutoresCellClick
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
        Width = 690
        Height = 270
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
        object lblCpfCnpj: TLabel
          Left = 0
          Top = 72
          Width = 58
          Height = 17
          Caption = 'CPF/CNPJ:'
        end
        object edtNome: TEdit
          Left = 0
          Top = 24
          Width = 360
          Height = 25
          TabOrder = 0
        end
        object edtCpfCnpj: TEdit
          Left = 0
          Top = 96
          Width = 200
          Height = 25
          TabOrder = 1
        end
      end
    end
  end
  object pnlButtons: TPanel
    AlignWithMargins = True
    Left = 8
    Top = 356
    Width = 704
    Height = 52
    Margins.Left = 8
    Margins.Right = 8
    Margins.Bottom = 12
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 2
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
  object dsProdutor: TDataSource
    Left = 520
    Top = 176
  end
end

object frmProdutoView: TfrmProdutoView
  Left = 0
  Top = 0
  Caption = 'Cadastro de Produtos'
  ClientHeight = 600
  ClientWidth = 900
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  TextHeight = 13
  object pnlTop: TPanel
    Left = 0
    Top = 0
    Width = 900
    Height = 60
    Align = alTop
    BevelOuter = bvNone
    Color = clNavy
    ParentBackground = False
    TabOrder = 0
    object lblTitulo: TLabel
      Left = 20
      Top = 15
      Width = 257
      Height = 29
      Caption = 'Cadastro de Produtos'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -24
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
  end
  object pnlButtons: TPanel
    Left = 0
    Top = 60
    Width = 900
    Height = 50
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 1
    object btnNovo: TButton
      Left = 10
      Top = 10
      Width = 90
      Height = 30
      Caption = 'Novo'
      TabOrder = 0
      OnClick = btnNovoClick
    end
    object btnSalvar: TButton
      Left = 106
      Top = 14
      Width = 90
      Height = 30
      Caption = 'Salvar'
      Enabled = False
      TabOrder = 1
      OnClick = btnSalvarClick
    end
    object btnExcluir: TButton
      Left = 210
      Top = 10
      Width = 90
      Height = 30
      Caption = 'Excluir'
      Enabled = False
      TabOrder = 2
      OnClick = btnExcluirClick
    end
    object btnCancelar: TButton
      Left = 310
      Top = 10
      Width = 90
      Height = 30
      Caption = 'Cancelar'
      Enabled = False
      TabOrder = 3
      OnClick = btnCancelarClick
    end
    object btnAtualizar: TButton
      Left = 410
      Top = 10
      Width = 90
      Height = 30
      Caption = 'Atualizar'
      TabOrder = 4
      OnClick = btnAtualizarClick
    end
    object btnFechar: TButton
      Left = 510
      Top = 10
      Width = 90
      Height = 30
      Caption = 'Fechar'
      TabOrder = 5
      OnClick = btnFecharClick
    end
  end
  object pgcMain: TPageControl
    Left = 0
    Top = 110
    Width = 900
    Height = 490
    ActivePage = tabConsulta
    Align = alClient
    TabOrder = 2
    object tabConsulta: TTabSheet
      Caption = 'Consulta'
      object dbgProdutos: TDBGrid
        Left = 0
        Top = 0
        Width = 892
        Height = 462
        Align = alClient
        DataSource = dsProduto
        Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgConfirmDelete, dgCancelOnExit]
        TabOrder = 0
        TitleFont.Charset = DEFAULT_CHARSET
        TitleFont.Color = clWindowText
        TitleFont.Height = -11
        TitleFont.Name = 'Tahoma'
        TitleFont.Style = []
        OnCellClick = dbgProdutosCellClick
      end
    end
    object tabCadastro: TTabSheet
      Caption = 'Cadastro'
      ImageIndex = 1
      object pnlCadastro: TPanel
        Left = 0
        Top = 0
        Width = 892
        Height = 462
        Align = alClient
        BevelOuter = bvNone
        TabOrder = 0
        object lblNome: TLabel
          Left = 20
          Top = 20
          Width = 31
          Height = 13
          Caption = 'Nome:'
        end
        object lblPrecoVenda: TLabel
          Left = 20
          Top = 80
          Width = 79
          Height = 13
          Caption = 'Pre'#231'o de Venda:'
        end
        object edtNome: TEdit
          Left = 20
          Top = 40
          Width = 400
          Height = 21
          Enabled = False
          TabOrder = 0
        end
        object edtPrecoVenda: TEdit
          Left = 20
          Top = 100
          Width = 150
          Height = 21
          Enabled = False
          TabOrder = 1
          Text = '0,00'
        end
      end
    end
  end
  object dsProduto: TDataSource
    Left = 800
    Top = 200
  end
end

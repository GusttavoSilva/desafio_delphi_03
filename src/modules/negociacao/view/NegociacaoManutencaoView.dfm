object frmNegociacaoManutencaoView: TfrmNegociacaoManutencaoView
  Left = 0
  Top = 0
  Caption = 'Manuten'#231#227'o de Status - Negocia'#231#245'es'
  ClientHeight = 550
  ClientWidth = 700
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
    Width = 700
    Height = 60
    Align = alTop
    BevelOuter = bvNone
    Color = clNavy
    ParentBackground = False
    TabOrder = 0
    object lblTitulo: TLabel
      Left = 20
      Top = 15
      Width = 440
      Height = 29
      Caption = 'Manuten'#231#227'o de Status - Negocia'#231#245'es'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -24
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
  end
  object pnlFiltros: TPanel
    Left = 0
    Top = 60
    Width = 700
    Height = 80
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 1
    object lblFiltro: TLabel
      Left = 20
      Top = 15
      Width = 116
      Height = 13
      Caption = 'Selecione a Negocia'#231#227'o:'
    end
    object cboNegociacoes: TComboBox
      Left = 20
      Top = 35
      Width = 450
      Height = 21
      Style = csDropDownList
      TabOrder = 0
      OnChange = cboNegociacoesChange
    end
    object btnCarregar: TButton
      Left = 480
      Top = 33
      Width = 90
      Height = 25
      Caption = 'Carregar'
      TabOrder = 1
      OnClick = btnCarregarClick
    end
    object btnLimpar: TButton
      Left = 580
      Top = 33
      Width = 90
      Height = 25
      Caption = 'Limpar'
      TabOrder = 2
      OnClick = btnLimparClick
    end
  end
  object grpDados: TGroupBox
    Left = 0
    Top = 140
    Width = 700
    Height = 300
    Align = alTop
    Caption = ' Dados da Negocia'#231#227'o '
    TabOrder = 2
    object lblCodigo: TLabel
      Left = 20
      Top = 30
      Width = 37
      Height = 13
      Caption = 'C'#243'digo:'
    end
    object lblProdutor: TLabel
      Left = 20
      Top = 80
      Width = 46
      Height = 13
      Caption = 'Produtor:'
    end
    object lblDistribuidor: TLabel
      Left = 20
      Top = 130
      Width = 58
      Height = 13
      Caption = 'Distribuidor:'
    end
    object lblValorTotal: TLabel
      Left = 20
      Top = 180
      Width = 55
      Height = 13
      Caption = 'Valor Total:'
    end
    object lblStatusAtual: TLabel
      Left = 250
      Top = 180
      Width = 63
      Height = 13
      Caption = 'Status Atual:'
    end
    object lblDataCadastro: TLabel
      Left = 20
      Top = 230
      Width = 89
      Height = 13
      Caption = 'Data de Cadastro:'
    end
    object edtCodigo: TEdit
      Left = 20
      Top = 50
      Width = 650
      Height = 21
      Color = clBtnFace
      Enabled = False
      ReadOnly = True
      TabOrder = 0
    end
    object edtProdutor: TEdit
      Left = 20
      Top = 100
      Width = 650
      Height = 21
      Color = clBtnFace
      Enabled = False
      ReadOnly = True
      TabOrder = 1
    end
    object edtDistribuidor: TEdit
      Left = 20
      Top = 150
      Width = 650
      Height = 21
      Color = clBtnFace
      Enabled = False
      ReadOnly = True
      TabOrder = 2
    end
    object edtValorTotal: TEdit
      Left = 20
      Top = 200
      Width = 200
      Height = 21
      Color = clBtnFace
      Enabled = False
      ReadOnly = True
      TabOrder = 3
    end
    object edtStatusAtual: TEdit
      Left = 250
      Top = 200
      Width = 200
      Height = 21
      Color = clBtnFace
      Enabled = False
      ReadOnly = True
      TabOrder = 4
    end
    object edtDataCadastro: TEdit
      Left = 20
      Top = 250
      Width = 200
      Height = 21
      Color = clBtnFace
      Enabled = False
      ReadOnly = True
      TabOrder = 5
    end
  end
  object pnlAcoes: TPanel
    Left = 0
    Top = 440
    Width = 700
    Height = 110
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 3
    object btnAprovar: TButton
      Left = 20
      Top = 20
      Width = 150
      Height = 35
      Caption = 'Aprovar Negocia'#231#227'o'
      Enabled = False
      TabOrder = 0
      OnClick = btnAprovarClick
    end
    object btnConcluir: TButton
      Left = 190
      Top = 20
      Width = 150
      Height = 35
      Caption = 'Concluir Negocia'#231#227'o'
      Enabled = False
      TabOrder = 1
      OnClick = btnConcluirClick
    end
    object btnCancelar: TButton
      Left = 360
      Top = 20
      Width = 150
      Height = 35
      Caption = 'Cancelar Negocia'#231#227'o'
      Enabled = False
      TabOrder = 2
      OnClick = btnCancelarClick
    end
    object btnFechar: TButton
      Left = 20
      Top = 65
      Width = 150
      Height = 35
      Caption = 'Fechar'
      TabOrder = 3
      OnClick = btnFecharClick
    end
  end
end

object frmNegociacaoConsultaView: TfrmNegociacaoConsultaView
  Left = 0
  Top = 0
  Caption = 'Consulta de Negocia'#231#245'es'
  ClientHeight = 600
  ClientWidth = 1000
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
    Width = 1000
    Height = 60
    Align = alTop
    BevelOuter = bvNone
    Color = clNavy
    ParentBackground = False
    TabOrder = 0
    object lblTitulo: TLabel
      Left = 20
      Top = 15
      Width = 298
      Height = 29
      Caption = 'Consulta de Negocia'#231#245'es'
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
    Width = 1000
    Height = 100
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 1
    object lblProdutor: TLabel
      Left = 20
      Top = 15
      Width = 46
      Height = 13
      Caption = 'Produtor:'
    end
    object lblDistribuidor: TLabel
      Left = 350
      Top = 15
      Width = 58
      Height = 13
      Caption = 'Distribuidor:'
    end
    object cboProdutor: TComboBox
      Left = 20
      Top = 35
      Width = 300
      Height = 21
      Style = csDropDownList
      TabOrder = 0
    end
    object cboDistribuidor: TComboBox
      Left = 350
      Top = 35
      Width = 300
      Height = 21
      Style = csDropDownList
      TabOrder = 1
    end
    object btnFiltrar: TButton
      Left = 20
      Top = 65
      Width = 100
      Height = 25
      Caption = 'Filtrar'
      TabOrder = 2
      OnClick = btnFiltrarClick
    end
    object btnLimparFiltro: TButton
      Left = 130
      Top = 65
      Width = 100
      Height = 25
      Caption = 'Limpar Filtro'
      TabOrder = 3
      OnClick = btnLimparFiltroClick
    end
    object btnRelatorioResumido: TButton
      Left = 252
      Top = 65
      Width = 130
      Height = 25
      Caption = 'Relat'#243'rio'
      Enabled = False
      TabOrder = 4
      OnClick = btnRelatorioResumidoClick
    end
  end
  object dbgNegociacoes: TDBGrid
    Left = 0
    Top = 160
    Width = 1000
    Height = 390
    Align = alClient
    DataSource = dsNegociacoes
    Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgConfirmDelete, dgCancelOnExit]
    TabOrder = 2
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -11
    TitleFont.Name = 'Tahoma'
    TitleFont.Style = []
    Columns = <
      item
        Expanded = False
        FieldName = 'produtor'
        Title.Caption = 'Produtor'
        Width = 180
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'distribuidor'
        Title.Caption = 'Distribuidor'
        Width = 180
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'valor_total'
        Title.Caption = 'Valor Total'
        Width = 100
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'status'
        Title.Caption = 'Status'
        Width = 80
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'data_cadastro'
        Title.Caption = 'Data Cadastro'
        Width = 120
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'data_aprovacao'
        Title.Caption = 'Data Aprova'#231#227'o'
        Width = 120
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'data_conclusao'
        Title.Caption = 'Data Conclus'#227'o'
        Width = 120
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'data_cancelamento'
        Title.Caption = 'Data Cancelamento'
        Width = 120
        Visible = True
      end>
  end
  object pnlButtons: TPanel
    Left = 0
    Top = 550
    Width = 1000
    Height = 50
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 3
    object btnFechar: TButton
      Left = 20
      Top = 10
      Width = 100
      Height = 30
      Caption = 'Fechar'
      TabOrder = 0
      OnClick = btnFecharClick
    end
  end
  object dsNegociacoes: TDataSource
    Left = 900
    Top = 200
  end
  object frxReportResumido: TfrxReport
    Version = '2024.2.5'
    DotMatrixReport = False
    IniFile = '\Software\Fast Reports'
    PreviewOptions.Buttons = [pbPrint, pbLoad, pbSave, pbExport, pbZoom, pbFind, pbOutline, pbPageSetup, pbTools, pbEdit, pbNavigator, pbExportQuick, pbCopy, pbSelection]
    PreviewOptions.Zoom = 1.000000000000000000
    PrintOptions.Printer = 'Default'
    PrintOptions.PrintOnSheet = 0
    ReportOptions.CreateDate = 45968.430468356480000000
    ReportOptions.LastChange = 45968.430468356480000000
    ScriptLanguage = 'PascalScript'
    ScriptText.Strings = (
      'begin'
      ''
      'end.')
    Left = 800
    Top = 252
    Datasets = <
      item
        DataSet = frxDBNegociacoes
        DataSetName = 'frxDBNegociacoes'
      end>
    Variables = <>
    Style = <>
    object Data: TfrxDataPage
      Height = 1000.000000000000000000
      Width = 1000.000000000000000000
    end
    object Page1: TfrxReportPage
      PaperWidth = 210.000000000000000000
      PaperHeight = 297.000000000000000000
      PaperSize = 9
      LeftMargin = 10.000000000000000000
      RightMargin = 10.000000000000000000
      TopMargin = 10.000000000000000000
      BottomMargin = 10.000000000000000000
      Frame.Typ = []
      MirrorMode = []
    end
  end
  object frxDBNegociacoes: TfrxDBDataset
    UserName = 'frxDBNegociacoes'
    CloseDataSource = False
    DataSource = dsNegociacoes
    BCDToCurrency = False
    DataSetOptions = []
    Left = 800
    Top = 368
  end
end

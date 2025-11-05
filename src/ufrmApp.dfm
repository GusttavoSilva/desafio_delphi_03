object frmAliare: TfrmAliare
  Left = 0
  Top = 0
  Caption = 'Aliare - Painel Principal'
  ClientHeight = 700
  ClientWidth = 1200
  Color = 15461355
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  OnCreate = FormCreate
  TextHeight = 17
  object pnlSidebar: TPanel
    Left = 0
    Top = 0
    Width = 260
    Height = 700
    Align = alLeft
    BevelOuter = bvNone
    Color = 2105376
    ParentBackground = False
    TabOrder = 0
    object pnlSidebarHeader: TPanel
      Left = 0
      Top = 0
      Width = 260
      Height = 80
      Align = alTop
      BevelOuter = bvNone
      Color = 1644825
      ParentBackground = False
      TabOrder = 0
      object lblLogo: TLabel
        Left = 20
        Top = 20
        Width = 110
        Height = 45
        Alignment = taCenter
        Caption = 'ALIARE'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWhite
        Font.Height = -32
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
      end
    end
    object pnlMenuContainer: TPanel
      Left = 0
      Top = 80
      Width = 260
      Height = 620
      Align = alClient
      BevelOuter = bvNone
      Color = 2105376
      ParentBackground = False
      TabOrder = 1
      object btnCadastros: TButton
        Left = 10
        Top = 20
        Width = 240
        Height = 45
        Caption = '  '#9654' CADASTROS'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWhite
        Font.Height = -13
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
        TabOrder = 0
        OnClick = btnCadastrosClick
      end
      object btnProdutores: TButton
        Left = 30
        Top = 70
        Width = 220
        Height = 35
        Caption = 'Produtores'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWhite
        Font.Height = -11
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
        TabOrder = 1
        OnClick = btnAbrirProdutoresClick
      end
      object btnDistribuidores: TButton
        Left = 30
        Top = 110
        Width = 220
        Height = 35
        Caption = 'Distribuidores'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWhite
        Font.Height = -11
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
        TabOrder = 2
        OnClick = btnAbrirDistribuidoresClick
      end
      object btnProdutos: TButton
        Left = 30
        Top = 150
        Width = 220
        Height = 35
        Caption = 'Produtos'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWhite
        Font.Height = -11
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
        TabOrder = 3
        OnClick = btnAbrirProdutosClick
      end
      object btnLimites: TButton
        Left = 30
        Top = 190
        Width = 220
        Height = 35
        Caption = 'Limites de Cr'#233'dito'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWhite
        Font.Height = -11
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
        TabOrder = 4
        OnClick = btnAbrirLimitesClick
      end
      object btnNegociacoes: TButton
        Left = 10
        Top = 250
        Width = 240
        Height = 45
        Caption = '  '#9654' NEGOCIA'#199#213'ES'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWhite
        Font.Height = -13
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
        TabOrder = 5
        OnClick = btnNegociacoesClick
      end
      object btnNovaNeg: TButton
        Left = 30
        Top = 300
        Width = 220
        Height = 35
        Caption = 'Nova Negocia'#231#227'o'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWhite
        Font.Height = -11
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
        TabOrder = 6
        OnClick = btnAbrirNovaNegClick
      end
      object btnGestaoNeg: TButton
        Left = 30
        Top = 340
        Width = 220
        Height = 35
        Caption = 'Gest'#227'o de Negocia'#231#245'es'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWhite
        Font.Height = -11
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
        TabOrder = 7
        OnClick = btnAbrirManutencaoClick
      end
      object btnConsultaNeg: TButton
        Left = 30
        Top = 380
        Width = 220
        Height = 35
        Caption = 'Consulta de Negocia'#231#245'es'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWhite
        Font.Height = -11
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
        TabOrder = 8
        OnClick = btnAbrirConsultaClick
      end
      object btnRelatorios: TButton
        Left = 10
        Top = 440
        Width = 240
        Height = 45
        Caption = '  '#9654' RELAT'#211'RIOS'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWhite
        Font.Height = -13
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
        TabOrder = 9
        OnClick = btnRelatoriosClick
      end
      object btnRelLimites: TButton
        Left = 30
        Top = 490
        Width = 220
        Height = 35
        Caption = 'Limites por Cliente'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWhite
        Font.Height = -11
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
        TabOrder = 10
        OnClick = btnRelLimitesClick
      end
      object btnRelNegociacoes: TButton
        Left = 30
        Top = 530
        Width = 220
        Height = 35
        Caption = 'Negocia'#231#245'es Aprovadas'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWhite
        Font.Height = -11
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
        TabOrder = 11
        OnClick = btnRelNegociacoesClick
      end
    end
  end
  object pnlMain: TPanel
    Left = 260
    Top = 0
    Width = 940
    Height = 700
    Align = alClient
    BevelOuter = bvNone
    Color = 15461355
    ParentBackground = False
    TabOrder = 1
    object pnlHeader: TPanel
      Left = 0
      Top = 0
      Width = 940
      Height = 80
      Align = alTop
      BevelOuter = bvNone
      Color = clWhite
      ParentBackground = False
      TabOrder = 0
      object lblHeaderTitle: TLabel
        Left = 40
        Top = 20
        Width = 308
        Height = 45
        Caption = 'Bem-vindo ao Aliare'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 2105376
        Font.Height = -32
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
      end
    end
    object pnlContent: TPanel
      Left = 0
      Top = 80
      Width = 940
      Height = 589
      Align = alClient
      BevelOuter = bvNone
      Color = 15461355
      ParentBackground = False
      TabOrder = 1
      object pnlWelcome: TPanel
        Left = 40
        Top = 80
        Width = 860
        Height = 400
        BevelOuter = bvNone
        Color = clWhite
        ParentBackground = False
        TabOrder = 0
        object lblWelcomeTitle: TLabel
          Left = 30
          Top = 30
          Width = 386
          Height = 32
          Caption = 'Sistema de Cr'#233'dito e Negocia'#231#245'es'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = 2105376
          Font.Height = -24
          Font.Name = 'Segoe UI'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object lblWelcomeText: TLabel
          Left = 30
          Top = 90
          Width = 800
          Height = 60
          AutoSize = False
          Caption = 
            'Bem-vindo ao Aliare, seu painel central para gest'#227'o de cr'#233'dito e' +
            ' negocia'#231#245'es.'#13#10#13#10'Use o menu lateral para acessar cadastros, nego' +
            'cia'#231#245'es, relat'#243'rios e ferramentas de gest'#227'o.'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clGray
          Font.Height = -14
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
          WordWrap = True
        end
        object lblFeature1: TLabel
          Left = 30
          Top = 170
          Width = 288
          Height = 17
          Caption = '#9679 Valida'#231#227'o autom'#225'tica de limites de cr'#233'dito'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clGray
          Font.Height = -13
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
        end
        object lblFeature2: TLabel
          Left = 30
          Top = 200
          Width = 332
          Height = 17
          Caption = '#9679 Acompanhamento de negocia'#231#245'es em tempo real'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clGray
          Font.Height = -13
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
        end
        object lblFeature3: TLabel
          Left = 30
          Top = 230
          Width = 330
          Height = 17
          Caption = '#9679 Relat'#243'rios detalhados de clientes e distribuidores'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clGray
          Font.Height = -13
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
        end
        object lblFeature4: TLabel
          Left = 30
          Top = 260
          Width = 327
          Height = 17
          Caption = '#9679 Gerenciamento centralizado de limites de cr'#233'dito'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clGray
          Font.Height = -13
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
        end
        object btnGetStarted: TButton
          Left = 30
          Top = 310
          Width = 200
          Height = 50
          Caption = 'Iniciar'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWhite
          Font.Height = -13
          Font.Name = 'Segoe UI'
          Font.Style = [fsBold]
          ParentFont = False
          TabOrder = 0
          OnClick = btnGetStartedClick
        end
      end
    end
    object StatusBar: TStatusBar
      Left = 0
      Top = 669
      Width = 940
      Height = 31
      Panels = <>
      SimplePanel = True
    end
  end
end

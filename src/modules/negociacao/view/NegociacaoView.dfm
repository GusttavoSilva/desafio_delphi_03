object frmNegociacaoView: TfrmNegociacaoView
  Left = 0
  Top = 0
  Caption = 'Cadastro de Negocia'#231#245'es'
  ClientHeight = 700
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
    Height = 90
    Align = alTop
    BevelOuter = bvNone
    Color = clNavy
    ParentBackground = False
    TabOrder = 0
    object lblTitulo: TLabel
      Left = 20
      Top = 15
      Width = 300
      Height = 29
      Caption = 'Cadastro de Negocia'#231#245'es'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -24
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblDistribuidorLogado: TLabel
      Left = 20
      Top = 55
      Width = 131
      Height = 16
      Caption = 'Distribuidor Logado:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object cboDistribuidorLogado: TComboBox
      Left = 160
      Top = 52
      Width = 300
      Height = 21
      Style = csDropDownList
      TabOrder = 0
      OnChange = cboDistribuidorLogadoChange
    end
  end
  object pnlButtons: TPanel
    Left = 0
    Top = 90
    Width = 1000
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
      Left = 110
      Top = 10
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
    Top = 140
    Width = 1000
    Height = 560
    ActivePage = tabCadastro
    Align = alClient
    TabOrder = 2
    object tabConsulta: TTabSheet
      Caption = 'Consulta'
      object dbgNegociacoes: TDBGrid
        Left = 0
        Top = 0
        Width = 992
        Height = 532
        Align = alClient
        DataSource = dsNegociacao
        Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgConfirmDelete, dgCancelOnExit]
        TabOrder = 0
        TitleFont.Charset = DEFAULT_CHARSET
        TitleFont.Color = clWindowText
        TitleFont.Height = -11
        TitleFont.Name = 'Tahoma'
        TitleFont.Style = []
        OnCellClick = dbgNegociacoesCellClick
        Columns = <
          item
            Expanded = False
            FieldName = 'produtor'
            Title.Caption = 'Produtor'
            Width = 200
            Visible = True
          end
          item
            Expanded = False
            FieldName = 'distribuidor'
            Title.Caption = 'Distribuidor'
            Width = 200
            Visible = True
          end
          item
            Expanded = False
            FieldName = 'valor_total'
            Title.Caption = 'Valor Total'
            Width = 120
            Visible = True
          end
          item
            Expanded = False
            FieldName = 'status'
            Title.Caption = 'Status'
            Width = 100
            Visible = True
          end
          item
            Expanded = False
            FieldName = 'data_cadastro'
            Title.Caption = 'Data de Cadastro'
            Width = 150
            Visible = True
          end>
      end
    end
    object tabCadastro: TTabSheet
      Caption = 'Cadastro'
      ImageIndex = 1
      object pnlCadastro: TPanel
        Left = 0
        Top = 0
        Width = 992
        Height = 532
        Align = alClient
        BevelOuter = bvNone
        TabOrder = 0
        object lblProdutor: TLabel
          Left = 20
          Top = 20
          Width = 46
          Height = 13
          Caption = 'Produtor:'
        end
        object lblDistribuidor: TLabel
          Left = 20
          Top = 80
          Width = 58
          Height = 13
          Caption = 'Distribuidor:'
        end
        object lblValorTotal: TLabel
          Left = 20
          Top = 440
          Width = 55
          Height = 13
          Caption = 'Valor Total:'
        end
        object lblStatus: TLabel
          Left = 200
          Top = 440
          Width = 35
          Height = 13
          Caption = 'Status:'
        end
        object cboProdutor: TComboBox
          Left = 20
          Top = 40
          Width = 400
          Height = 21
          Style = csDropDownList
          Enabled = False
          TabOrder = 0
        end
        object cboDistribuidor: TComboBox
          Left = 20
          Top = 100
          Width = 400
          Height = 21
          Style = csDropDownList
          Enabled = False
          TabOrder = 1
        end
        object edtValorTotal: TEdit
          Left = 20
          Top = 460
          Width = 150
          Height = 21
          Enabled = False
          ReadOnly = True
          TabOrder = 2
          Text = '0,00'
        end
        object edtStatus: TEdit
          Left = 200
          Top = 460
          Width = 150
          Height = 21
          Enabled = False
          ReadOnly = True
          TabOrder = 3
        end
        object grpItens: TGroupBox
          Left = 20
          Top = 140
          Width = 950
          Height = 280
          Caption = ' Itens da Negocia'#231#227'o '
          TabOrder = 4
          object pnlItensButtons: TPanel
            Left = 2
            Top = 15
            Width = 946
            Height = 45
            Align = alTop
            BevelOuter = bvNone
            TabOrder = 0
            object btnAdicionarItem: TButton
              Left = 10
              Top = 8
              Width = 100
              Height = 30
              Caption = 'Adicionar Item'
              Enabled = False
              TabOrder = 0
              OnClick = btnAdicionarItemClick
            end
            object btnRemoverItem: TButton
              Left = 120
              Top = 8
              Width = 100
              Height = 30
              Caption = 'Remover Item'
              Enabled = False
              TabOrder = 1
              OnClick = btnRemoverItemClick
            end
          end
          object dbgItens: TDBGrid
            Left = 2
            Top = 60
            Width = 946
            Height = 218
            Align = alClient
            DataSource = dsItens
            Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgConfirmDelete, dgCancelOnExit]
            TabOrder = 1
            TitleFont.Charset = DEFAULT_CHARSET
            TitleFont.Color = clWindowText
            TitleFont.Height = -11
            TitleFont.Name = 'Tahoma'
            TitleFont.Style = []
            Columns = <
              item
                Expanded = False
                FieldName = 'produto'
                Title.Caption = 'Produto'
                Width = 400
                Visible = True
              end
              item
                Expanded = False
                FieldName = 'quantidade'
                Title.Caption = 'Quantidade'
                Width = 100
                Visible = True
              end
              item
                Expanded = False
                FieldName = 'preco_unitario'
                Title.Caption = 'Pre'#231'o Unit'#225'rio'
                Width = 120
                Visible = True
              end
              item
                Expanded = False
                FieldName = 'subtotal'
                Title.Caption = 'Subtotal'
                Width = 120
                Visible = True
              end>
          end
          object pnlAddItem: TPanel
            Left = 150
            Top = 80
            Width = 650
            Height = 180
            BevelOuter = bvNone
            BorderStyle = bsSingle
            Color = clWhite
            ParentBackground = False
            TabOrder = 2
            Visible = False
            object lblProduto: TLabel
              Left = 20
              Top = 20
              Width = 42
              Height = 13
              Caption = 'Produto:'
            end
            object lblQuantidade: TLabel
              Left = 20
              Top = 80
              Width = 60
              Height = 13
              Caption = 'Quantidade:'
            end
            object lblPrecoUnitario: TLabel
              Left = 250
              Top = 80
              Width = 71
              Height = 13
              Caption = 'Pre'#231'o Unit'#225'rio:'
            end
            object cboProduto: TComboBox
              Left = 20
              Top = 40
              Width = 600
              Height = 21
              Style = csDropDownList
              TabOrder = 0
              OnChange = cboProdutoChange
            end
            object edtQuantidade: TEdit
              Left = 20
              Top = 100
              Width = 200
              Height = 21
              TabOrder = 1
              Text = '1'
            end
            object edtPrecoUnitario: TEdit
              Left = 250
              Top = 100
              Width = 150
              Height = 21
              TabOrder = 2
              Text = '0,00'
            end
            object btnConfirmarItem: TButton
              Left = 20
              Top = 140
              Width = 100
              Height = 30
              Caption = 'Confirmar'
              TabOrder = 3
              OnClick = btnConfirmarItemClick
            end
            object btnCancelarItem: TButton
              Left = 130
              Top = 140
              Width = 100
              Height = 30
              Caption = 'Cancelar'
              TabOrder = 4
              OnClick = btnCancelarItemClick
            end
          end
        end
        object pnlResumo: TPanel
          Left = 0
          Top = 487
          Width = 992
          Height = 45
          Align = alBottom
          BevelOuter = bvNone
          TabOrder = 5
        end
      end
    end
  end
  object dsNegociacao: TDataSource
    Left = 900
    Top = 200
  end
  object dsItens: TDataSource
    Left = 900
    Top = 250
  end
end

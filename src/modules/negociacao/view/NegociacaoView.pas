unit NegociacaoView;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.DBGrids, Data.DB, System.Generics.Collections, FireDAC.Comp.Client,
  NegociacaoEntity, NegociacaoItemEntity, NegociacaoModule, NegociacaoItemModule,
  ProdutorEntity, ProdutorModule, DistribuidorEntity, DistribuidorModule,
  ProdutoEntity, ProdutoModule, LimiteCreditoModule,
  ConnectionDataBase, Vcl.Grids, Vcl.ComCtrls, System.UITypes;

type
  TfrmNegociacaoView = class(TForm)
    pnlTop: TPanel;
    lblTitulo: TLabel;
    lblDistribuidorLogado: TLabel;
    cboDistribuidorLogado: TComboBox;
    pnlButtons: TPanel;
    btnNovo: TButton;
    btnSalvar: TButton;
    btnExcluir: TButton;
    btnCancelar: TButton;
    btnAtualizar: TButton;
    btnFechar: TButton;
    pgcMain: TPageControl;
    tabConsulta: TTabSheet;
    tabCadastro: TTabSheet;
    dbgNegociacoes: TDBGrid;
    dsNegociacao: TDataSource;
    pnlCadastro: TPanel;
    lblProdutor: TLabel;
    cboProdutor: TComboBox;
    lblDistribuidor: TLabel;
    cboDistribuidor: TComboBox;
    grpItens: TGroupBox;
    pnlItensButtons: TPanel;
    btnAdicionarItem: TButton;
    btnRemoverItem: TButton;
    dbgItens: TDBGrid;
    dsItens: TDataSource;
    pnlResumo: TPanel;
    lblValorTotal: TLabel;
    edtValorTotal: TEdit;
    lblStatus: TLabel;
    edtStatus: TEdit;
    pnlAddItem: TPanel;
    lblProduto: TLabel;
    cboProduto: TComboBox;
    lblQuantidade: TLabel;
    edtQuantidade: TEdit;
    lblPrecoUnitario: TLabel;
    edtPrecoUnitario: TEdit;
    btnConfirmarItem: TButton;
    btnCancelarItem: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnNovoClick(Sender: TObject);
    procedure btnSalvarClick(Sender: TObject);
    procedure btnExcluirClick(Sender: TObject);
    procedure btnCancelarClick(Sender: TObject);
    procedure btnAtualizarClick(Sender: TObject);
    procedure btnFecharClick(Sender: TObject);
    procedure dbgNegociacoesCellClick(Column: TColumn);
    procedure btnAdicionarItemClick(Sender: TObject);
    procedure btnRemoverItemClick(Sender: TObject);
    procedure btnConfirmarItemClick(Sender: TObject);
    procedure btnCancelarItemClick(Sender: TObject);
    procedure cboProdutoChange(Sender: TObject);
    procedure cboDistribuidorLogadoChange(Sender: TObject);
  private
    FNegociacaoModule: TNegociacaoModule;
    FNegociacaoItemModule: TNegociacaoItemModule;
    FProdutorModule: TProdutorModule;
    FDistribuidorModule: TDistribuidorModule;
    FProdutoModule: TProdutoModule;
    FLimiteCreditoModule: TLimiteCreditoModule;
    
    FNegociacaoAtual: TNegociacaoEntity;
    FNegociacoes: TObjectList<TNegociacaoEntity>;
    
    FDataSet: TFDMemTable;
    FItensDataSet: TFDMemTable;
    
    FProdutores: TObjectList<TProdutorEntity>;
    FDistribuidores: TObjectList<TDistribuidorEntity>;
    FProdutos: TObjectList<TProdutoEntity>;
    
    FDistribuidorLogadoId: string;
    
    procedure InicializarDataSets;
    procedure CarregarNegociacoes;
    procedure CarregarProdutores;
    procedure CarregarDistribuidores;
    procedure CarregarProdutos;
    procedure PreencherGrid;
    procedure PreencherGridItens;
    procedure LimparCampos;
    procedure HabilitarEdicao(const AHabilitar: Boolean);
    procedure CarregarNegociacaoNaTela(ANegociacao: TNegociacaoEntity);
    procedure SincronizarNegociacaoComTela;
    function ValidarLimiteCredito: Boolean;
    function ValidarDistribuidorLogado: Boolean;
    procedure AtivarConsulta;
    procedure AtivarCadastro;
    procedure CalcularTotais;
    procedure MostrarPainelAddItem(const AMostrar: Boolean);
    procedure LimparCamposItem;
    procedure CarregarPrecoProduto;
    procedure FiltrarNegociacoesPorDistribuidor;
  public
  end;

var
  frmNegociacaoView: TfrmNegociacaoView;

implementation

uses
  GsBaseEntity, GsValidation;

{$R *.dfm}

{ TfrmNegociacaoView }

procedure TfrmNegociacaoView.FormCreate(Sender: TObject);
begin
  dmConnection.Connect;
  
  FNegociacaoModule := TNegociacaoModule.Create(dmConnection.FDConnection);
  FNegociacaoItemModule := TNegociacaoItemModule.Create(dmConnection.FDConnection);
  FProdutorModule := TProdutorModule.Create(dmConnection.FDConnection);
  FDistribuidorModule := TDistribuidorModule.Create(dmConnection.FDConnection);
  FProdutoModule := TProdutoModule.Create(dmConnection.FDConnection);
  FLimiteCreditoModule := TLimiteCreditoModule.Create(dmConnection.FDConnection);
  
  FNegociacoes := TObjectList<TNegociacaoEntity>.Create(True);
  FProdutores := TObjectList<TProdutorEntity>.Create(True);
  FDistribuidores := TObjectList<TDistribuidorEntity>.Create(True);
  FProdutos := TObjectList<TProdutoEntity>.Create(True);
  
  FDataSet := TFDMemTable.Create(nil);
  FItensDataSet := TFDMemTable.Create(nil);
  dsNegociacao.DataSet := FDataSet;
  dsItens.DataSet := FItensDataSet;
  
  InicializarDataSets;
  FNegociacaoAtual := nil;
  FDistribuidorLogadoId := '';
  
  CarregarProdutores;
  CarregarDistribuidores;
  CarregarProdutos;

  cboDistribuidorLogado.ItemIndex := -1;
  
  MostrarPainelAddItem(False);
  HabilitarEdicao(False);
  CarregarNegociacoes;
end;

procedure TfrmNegociacaoView.FormDestroy(Sender: TObject);
begin
  FDataSet.Free;
  FItensDataSet.Free;
  FNegociacoes.Free;
  FProdutores.Free;
  FDistribuidores.Free;
  FProdutos.Free;
  
  FNegociacaoModule.Free;
  FNegociacaoItemModule.Free;
  FProdutorModule.Free;
  FDistribuidorModule.Free;
  FProdutoModule.Free;
  FLimiteCreditoModule.Free;
  
  FNegociacaoAtual.Free;
end;

procedure TfrmNegociacaoView.InicializarDataSets;
begin
  // DataSet de negociações
  FDataSet.Close;
  FDataSet.FieldDefs.Clear;
  FDataSet.FieldDefs.Add('id', ftString, 38);
  FDataSet.FieldDefs.Add('produtor', ftString, 255);
  FDataSet.FieldDefs.Add('distribuidor', ftString, 255);
  FDataSet.FieldDefs.Add('valor_total', ftCurrency);
  FDataSet.FieldDefs.Add('status', ftString, 20);
  FDataSet.FieldDefs.Add('data_cadastro', ftDateTime);
  FDataSet.CreateDataSet;
  
  // DataSet de itens
  FItensDataSet.Close;
  FItensDataSet.FieldDefs.Clear;
  FItensDataSet.FieldDefs.Add('id', ftString, 38);
  FItensDataSet.FieldDefs.Add('produto', ftString, 255);
  FItensDataSet.FieldDefs.Add('quantidade', ftFloat);
  FItensDataSet.FieldDefs.Add('preco_unitario', ftCurrency);
  FItensDataSet.FieldDefs.Add('subtotal', ftCurrency);
  FItensDataSet.CreateDataSet;
end;

procedure TfrmNegociacaoView.CarregarProdutores;
var
  LLista: TObjectList<TProdutorEntity>;
  LItem: TProdutorEntity;
begin
  LLista := FProdutorModule.Controller.ListarTodos;
  try
    FProdutores.Clear;
    cboProdutor.Clear;
    for LItem in LLista do
    begin
      FProdutores.Add(LItem);
      cboProdutor.Items.AddObject(LItem.Nome, Pointer(FProdutores.Count - 1));
    end;
    LLista.OwnsObjects := False;
  finally
    LLista.Free;
  end;
end;

procedure TfrmNegociacaoView.CarregarDistribuidores;
var
  LLista: TObjectList<TDistribuidorEntity>;
  LItem: TDistribuidorEntity;
begin
  LLista := FDistribuidorModule.Controller.ListarTodos;
  try
    FDistribuidores.Clear;
    cboDistribuidor.Clear;
    cboDistribuidorLogado.Clear;
    for LItem in LLista do
    begin
      FDistribuidores.Add(LItem);
      cboDistribuidor.Items.AddObject(LItem.Nome, Pointer(FDistribuidores.Count - 1));
      cboDistribuidorLogado.Items.AddObject(LItem.Nome, Pointer(FDistribuidores.Count - 1));
    end;
    LLista.OwnsObjects := False;
  finally
    LLista.Free;
  end;
end;

procedure TfrmNegociacaoView.CarregarProdutos;
var
  LLista: TObjectList<TProdutoEntity>;
  LItem: TProdutoEntity;
begin
  LLista := FProdutoModule.Controller.ListarTodos;
  try
    FProdutos.Clear;
    cboProduto.Clear;
    for LItem in LLista do
    begin
      FProdutos.Add(LItem);
      cboProduto.Items.AddObject(
        Format('%s - R$ %s', [LItem.Nome, FormatFloat('#,##0.00', LItem.PrecoVenda)]),
        Pointer(FProdutos.Count - 1)
      );
    end;
    LLista.OwnsObjects := False;
  finally
    LLista.Free;
  end;
end;

procedure TfrmNegociacaoView.CarregarNegociacoes;
var
  LLista: TObjectList<TNegociacaoEntity>;
  LItem: TNegociacaoEntity;
begin
  LLista := FNegociacaoModule.Controller.ListarTodos;
  try
    FNegociacoes.Clear;
    for LItem in LLista do
      FNegociacoes.Add(LItem);
    LLista.OwnsObjects := False;
  finally
    LLista.Free;
  end;
  PreencherGrid;
end;

procedure TfrmNegociacaoView.PreencherGrid;
var
  LNegociacao: TNegociacaoEntity;
  PI, DI: Integer;
begin
  FDataSet.DisableControls;
  try
    FDataSet.EmptyDataSet;
    for LNegociacao in FNegociacoes do
    begin
      FDataSet.Append;
      FDataSet.FieldByName('id').AsString := LNegociacao.Id;
      
      // Buscar nome do produtor a partir das listas carregadas (evita criar/free inesperado)
      if Assigned(FProdutores) then
      begin
        for PI := 0 to FProdutores.Count - 1 do
        begin
          if Assigned(FProdutores[PI]) and (FProdutores[PI].Id = LNegociacao.ProdutorId) then
          begin
            FDataSet.FieldByName('produtor').AsString := FProdutores[PI].Nome;
            Break;
          end;
        end;
      end;

      // Buscar nome do distribuidor a partir das listas carregadas
      if Assigned(FDistribuidores) then
      begin
        for DI := 0 to FDistribuidores.Count - 1 do
        begin
          if Assigned(FDistribuidores[DI]) and (FDistribuidores[DI].Id = LNegociacao.DistribuidorId) then
          begin
            FDataSet.FieldByName('distribuidor').AsString := FDistribuidores[DI].Nome;
            Break;
          end;
        end;
      end;
      
      FDataSet.FieldByName('valor_total').AsCurrency := LNegociacao.ValorTotal;
      FDataSet.FieldByName('status').AsString := LNegociacao.Status;
      FDataSet.FieldByName('data_cadastro').AsDateTime := LNegociacao.DataCadastro;
      FDataSet.Post;
    end;
  finally
    FDataSet.EnableControls;
  end;
  
  btnExcluir.Enabled := (dsNegociacao.DataSet <> nil) and (not dsNegociacao.DataSet.IsEmpty);
end;

procedure TfrmNegociacaoView.PreencherGridItens;
var
  LItem: TNegociacaoItemEntity;
  PI: Integer;
  LProdutoNome: string;
begin
  FItensDataSet.DisableControls;
  try
    FItensDataSet.EmptyDataSet;
    
    if Assigned(FNegociacaoAtual) and Assigned(FNegociacaoAtual.Itens) then
    begin
      for LItem in FNegociacaoAtual.Itens do
      begin
        if not Assigned(LItem) then
          Continue;
          
        FItensDataSet.Append;
        FItensDataSet.FieldByName('id').AsString := LItem.Id;

        // Buscar nome do produto a partir das listas carregadas
        LProdutoNome := '';
        if Assigned(FProdutos) then
        begin
          for PI := 0 to FProdutos.Count - 1 do
          begin
            if Assigned(FProdutos[PI]) and (FProdutos[PI].Id = LItem.ProdutoId) then
            begin
              LProdutoNome := FProdutos[PI].Nome;
              Break;
            end;
          end;
        end;
        
        FItensDataSet.FieldByName('produto').AsString := LProdutoNome;
        FItensDataSet.FieldByName('quantidade').AsFloat := LItem.Quantidade;
        FItensDataSet.FieldByName('preco_unitario').AsCurrency := LItem.PrecoUnitario;
        FItensDataSet.FieldByName('subtotal').AsCurrency := LItem.Subtotal;
        FItensDataSet.Post;
      end;
    end;
  finally
    FItensDataSet.EnableControls;
  end;
end;

procedure TfrmNegociacaoView.btnNovoClick(Sender: TObject);
var
  I: Integer;
begin
  if not ValidarDistribuidorLogado then
    Exit;
    
  LimparCampos;
  HabilitarEdicao(True);
  
  FreeAndNil(FNegociacaoAtual);
  FNegociacaoAtual := TNegociacaoEntity.Create;
  FNegociacaoAtual.State := esInsert;
  FNegociacaoAtual.StatusEnum := nsPendente;
  FNegociacaoAtual.DistribuidorId := FDistribuidorLogadoId;
  
  // Pré-selecionar distribuidor logado
  for I := 0 to FDistribuidores.Count - 1 do
  begin
    if FDistribuidores[I].Id = FDistribuidorLogadoId then
    begin
      cboDistribuidor.ItemIndex := I;
      Break;
    end;
  end;
  
  PreencherGridItens;
  
  edtStatus.Text := 'PENDENTE';
  edtValorTotal.Text := '0,00';
  
  cboProdutor.SetFocus;
end;

procedure TfrmNegociacaoView.btnSalvarClick(Sender: TObject);
var
  LItem: TNegociacaoItemEntity;
begin
  if not ValidarLimiteCredito then
    Exit;
  
  try
    SincronizarNegociacaoComTela;
    
    // Salvar negociação
    FNegociacaoAtual := FNegociacaoModule.Controller.Salvar(FNegociacaoAtual);
    
    // Salvar itens
    if Assigned(FNegociacaoAtual) and Assigned(FNegociacaoAtual.Itens) then
    begin
      for LItem in FNegociacaoAtual.Itens do
      begin
        LItem.NegociacaoId := FNegociacaoAtual.Id;
        FNegociacaoItemModule.Controller.Salvar(LItem);
      end;
    end;
    
    ShowMessage('Negociação salva com sucesso!');
    
    btnCancelarClick(Sender);
    CarregarNegociacoes;
  except
    on E: Exception do
      ShowMessage('Erro ao salvar: ' + E.Message);
  end;
end;

procedure TfrmNegociacaoView.btnExcluirClick(Sender: TObject);
var
  LNegociacaoId: string;
begin
  if not Assigned(FNegociacaoAtual) then
  begin
    ShowMessage('Selecione uma negociação para excluir.');
    Exit;
  end;
  
  if MessageDlg('Deseja realmente excluir esta negociação?', 
                mtConfirmation, [mbYes, mbNo], 0) = mrYes then
  begin
    try
      // Guardar o ID antes de excluir
      LNegociacaoId := FNegociacaoAtual.Id;
      
      // Excluir itens primeiro (usa o método que já exclui todos os itens de uma vez)
      FNegociacaoItemModule.Controller.ExcluirPorNegociacao(LNegociacaoId);
      
      // Excluir negociação
      FNegociacaoModule.Controller.Excluir(FNegociacaoAtual);
      ShowMessage('Negociação excluída com sucesso!');
      
      LimparCampos;
      HabilitarEdicao(False);
      CarregarNegociacoes;
    except
      on E: Exception do
        ShowMessage('Erro ao excluir: ' + E.Message);
    end;
  end;
end;

procedure TfrmNegociacaoView.btnCancelarClick(Sender: TObject);
begin
  LimparCampos;
  HabilitarEdicao(False);
  FreeAndNil(FNegociacaoAtual);
  PreencherGridItens;
end;

procedure TfrmNegociacaoView.dbgNegociacoesCellClick(Column: TColumn);
var
  LId: string;
  LCountItens: Integer;
begin
  if not Assigned(dsNegociacao.DataSet) or dsNegociacao.DataSet.IsEmpty then
    Exit;
  
  LId := dsNegociacao.DataSet.FieldByName('id').AsString;
  if LId.IsEmpty then
    Exit;
  
  try
    FreeAndNil(FNegociacaoAtual);
    FNegociacaoAtual := FNegociacaoModule.Controller.BuscarPorId(LId);
    
    if Assigned(FNegociacaoAtual) then
    begin
      FNegociacaoAtual.State := esUpdate;
      // Os itens já foram carregados pelo controller via CarregarItens
      
      // Debug: verificar quantos itens foram carregados
      LCountItens := 0;
      if Assigned(FNegociacaoAtual.Itens) then
        LCountItens := FNegociacaoAtual.Itens.Count;
      
      // Descomentar para debug:
      // ShowMessage(Format('Negociação ID: %s - Itens carregados: %d', [LId, LCountItens]));
      
      CarregarNegociacaoNaTela(FNegociacaoAtual);
      PreencherGridItens;
      HabilitarEdicao(True);
    end;
  except
    on E: Exception do
      ShowMessage('Erro ao carregar negociação: ' + E.Message);
  end;
end;

procedure TfrmNegociacaoView.btnAdicionarItemClick(Sender: TObject);
begin
  LimparCamposItem;
  MostrarPainelAddItem(True);
  cboProduto.SetFocus;
end;

procedure TfrmNegociacaoView.btnRemoverItemClick(Sender: TObject);
var
  LId: string;
  I: Integer;
begin
  if FItensDataSet.IsEmpty then
  begin
    ShowMessage('Selecione um item para remover.');
    Exit;
  end;
  
  LId := FItensDataSet.FieldByName('id').AsString;
  
  for I := 0 to FNegociacaoAtual.Itens.Count - 1 do
  begin
    if FNegociacaoAtual.Itens[I].Id = LId then
    begin
      FNegociacaoAtual.Itens.Delete(I);
      Break;
    end;
  end;
  
  PreencherGridItens;
  CalcularTotais;
end;

procedure TfrmNegociacaoView.btnConfirmarItemClick(Sender: TObject);
var
  LItem: TNegociacaoItemEntity;
  LProdutoIdx: Integer;
  LQuantidade: Double;
  LPreco: Currency;
begin
  // Validações
  if cboProduto.ItemIndex < 0 then
  begin
    ShowMessage('Selecione um produto.');
    cboProduto.SetFocus;
    Exit;
  end;
  
  try
    LQuantidade := StrToFloat(StringReplace(edtQuantidade.Text, ',', '.', [rfReplaceAll]));
    if LQuantidade <= 0 then
      raise Exception.Create('');
  except
    ShowMessage('Quantidade inválida.');
    edtQuantidade.SetFocus;
    Exit;
  end;
  
  LPreco := TgsValidation.TratarValorMonetario(edtPrecoUnitario.Text);
  if LPreco <= 0 then
  begin
    ShowMessage('Preço unitário inválido.');
    edtPrecoUnitario.SetFocus;
    Exit;
  end;
  
  // Criar item
  LProdutoIdx := Integer(cboProduto.Items.Objects[cboProduto.ItemIndex]);
  
  if (LProdutoIdx < 0) or (LProdutoIdx >= FProdutos.Count) then
  begin
    ShowMessage('Índice de produto inválido.');
    Exit;
  end;
  
  LItem := TNegociacaoItemEntity.Create;
  LItem.State := esInsert;
  LItem.ProdutoId := FProdutos[LProdutoIdx].Id;
  LItem.Quantidade := LQuantidade;
  LItem.PrecoUnitario := LPreco;
  LItem.Subtotal := LQuantidade * LPreco;
  
  if Assigned(FNegociacaoAtual) then
    FNegociacaoAtual.AdicionarItem(LItem)
  else
  begin
    LItem.Free;
    ShowMessage('Erro: negociação atual não está carregada.');
    Exit;
  end;
  
  PreencherGridItens;
  CalcularTotais;
  MostrarPainelAddItem(False);
end;

procedure TfrmNegociacaoView.btnCancelarItemClick(Sender: TObject);
begin
  MostrarPainelAddItem(False);
end;

procedure TfrmNegociacaoView.LimparCampos;
begin
  cboProdutor.ItemIndex := -1;
  cboDistribuidor.ItemIndex := -1;
  edtValorTotal.Text := '0,00';
  edtStatus.Text := '';
  PreencherGridItens;
end;

procedure TfrmNegociacaoView.LimparCamposItem;
begin
  cboProduto.ItemIndex := -1;
  edtQuantidade.Text := '1';
  edtPrecoUnitario.Text := '0,00';
end;

procedure TfrmNegociacaoView.HabilitarEdicao(const AHabilitar: Boolean);
var
  LTemItens: Boolean;
  LPodeEditar: Boolean;
begin
  // Só pode editar se estiver pendente
  LPodeEditar := AHabilitar and (not Assigned(FNegociacaoAtual) or 
                                 (FNegociacaoAtual.StatusEnum = nsPendente));
  
  cboProdutor.Enabled := LPodeEditar;
  cboDistribuidor.Enabled := False; // Distribuidor sempre fixo (logado)
  btnAdicionarItem.Enabled := LPodeEditar;
  btnRemoverItem.Enabled := LPodeEditar;// and (not FItensDataSet.IsEmpty);
  
  btnSalvar.Enabled := LPodeEditar;
  btnCancelar.Enabled := AHabilitar;
  btnNovo.Enabled := not AHabilitar;
  
  LTemItens := (dsNegociacao.DataSet <> nil) and (not dsNegociacao.DataSet.IsEmpty);
  if AHabilitar then
    btnExcluir.Enabled := Assigned(FNegociacaoAtual) and (FNegociacaoAtual.State = esUpdate)
  else
    btnExcluir.Enabled := LTemItens;
  btnAtualizar.Enabled := not AHabilitar;
  
  cboDistribuidorLogado.Enabled := not AHabilitar;
  
  if AHabilitar then
    AtivarCadastro
  else
    AtivarConsulta;
end;

procedure TfrmNegociacaoView.CarregarNegociacaoNaTela(ANegociacao: TNegociacaoEntity);
var
  I: Integer;
begin
  if not Assigned(ANegociacao) then
    Exit;
  
  // Selecionar produtor
  if Assigned(FProdutores) then
  begin
    for I := 0 to FProdutores.Count - 1 do
    begin
      if Assigned(FProdutores[I]) and (FProdutores[I].Id = ANegociacao.ProdutorId) then
      begin
        cboProdutor.ItemIndex := I;
        Break;
      end;
    end;
  end;
  
  // Selecionar distribuidor
  if Assigned(FDistribuidores) then
  begin
    for I := 0 to FDistribuidores.Count - 1 do
    begin
      if Assigned(FDistribuidores[I]) and (FDistribuidores[I].Id = ANegociacao.DistribuidorId) then
      begin
        cboDistribuidor.ItemIndex := I;
        Break;
      end;
    end;
  end;
  
  edtValorTotal.Text := FormatFloat('#,##0.00', ANegociacao.ValorTotal);
  edtStatus.Text := ANegociacao.Status;
end;

function TfrmNegociacaoView.ValidarLimiteCredito: Boolean;
var
  LProdutorIdx: Integer;
  LLimite: Currency;
  LTotalAprovadas: Currency;
  LValorNegociacao: Currency;
  LSaldoDisponivel: Currency;
begin
  Result := False;
  
  if not ValidarDistribuidorLogado then
    Exit;
  // Validar seleção de produtor
  if (cboProdutor.ItemIndex < 0) then
  begin
    ShowMessage('Selecione um produtor.');
    cboProdutor.SetFocus;
    Exit;
  end;

  LProdutorIdx := Integer(cboProdutor.Items.Objects[cboProdutor.ItemIndex]);
  if (LProdutorIdx < 0) or (not Assigned(FProdutores)) or (LProdutorIdx >= FProdutores.Count) then
  begin
    ShowMessage('Produtor inválido.');
    Exit;
  end;

  // Buscar limite de crédito para o distribuidor logado
  LLimite := FLimiteCreditoModule.Controller.ObterLimiteCredito(
    FProdutores[LProdutorIdx].Id,
    FDistribuidorLogadoId
  );
  
  if LLimite <= 0 then
  begin
    ShowMessage('Produtor não possui limite de crédito com o distribuidor logado.');
    Exit;
  end;
  
  // Calcular total de negociações aprovadas
  LTotalAprovadas := FNegociacaoModule.Controller.CalcularTotalAprovadas(
    FProdutores[LProdutorIdx].Id,
    FDistribuidorLogadoId
  );
  
  LValorNegociacao := TgsValidation.TratarValorMonetario(edtValorTotal.Text);
  LSaldoDisponivel := LLimite - LTotalAprovadas;
  
  if LValorNegociacao > LSaldoDisponivel then
  begin
    ShowMessage(Format(
      'Limite de crédito insuficiente!' + sLineBreak +
      'Limite total: R$ %s' + sLineBreak +
      'Já utilizado: R$ %s' + sLineBreak +
      'Disponível: R$ %s' + sLineBreak +
      'Valor desta negociação: R$ %s',
      [
        FormatFloat('#,##0.00', LLimite),
        FormatFloat('#,##0.00', LTotalAprovadas),
        FormatFloat('#,##0.00', LSaldoDisponivel),
        FormatFloat('#,##0.00', LValorNegociacao)
      ]
    ));
    Exit;
  end;
  
  Result := True;
end;

procedure TfrmNegociacaoView.SincronizarNegociacaoComTela;
var
  LProdutorIdx: Integer;
begin
  if not Assigned(FNegociacaoAtual) then
    Exit;
  // Garantir que um produtor esteja selecionado
  if (cboProdutor.ItemIndex < 0) then
    Exit;

  LProdutorIdx := Integer(cboProdutor.Items.Objects[cboProdutor.ItemIndex]);
  if (LProdutorIdx < 0) or (not Assigned(FProdutores)) or (LProdutorIdx >= FProdutores.Count) then
    Exit;

  FNegociacaoAtual.ProdutorId := FProdutores[LProdutorIdx].Id;
  FNegociacaoAtual.DistribuidorId := FDistribuidorLogadoId;
  FNegociacaoAtual.ValorTotal := TgsValidation.TratarValorMonetario(edtValorTotal.Text);
  
  if FNegociacaoAtual.State = esInsert then
  begin
    FNegociacaoAtual.StatusEnum := nsPendente;
    FNegociacaoAtual.DataCadastro := Now;
  end;
end;

procedure TfrmNegociacaoView.CalcularTotais;
var
  LItem: TNegociacaoItemEntity;
  LTotal: Currency;
begin
  LTotal := 0;
  
  if Assigned(FNegociacaoAtual) and Assigned(FNegociacaoAtual.Itens) then
  begin
    for LItem in FNegociacaoAtual.Itens do
      LTotal := LTotal + LItem.Subtotal;
  end;
  
  edtValorTotal.Text := FormatFloat('#,##0.00', LTotal);
end;

procedure TfrmNegociacaoView.AtivarCadastro;
begin
  if Assigned(pgcMain) and Assigned(tabCadastro) then
    pgcMain.ActivePage := tabCadastro;
end;

procedure TfrmNegociacaoView.AtivarConsulta;
begin
  if Assigned(pgcMain) and Assigned(tabConsulta) then
    pgcMain.ActivePage := tabConsulta;
end;

procedure TfrmNegociacaoView.btnAtualizarClick(Sender: TObject);
begin
  CarregarNegociacoes;
end;

procedure TfrmNegociacaoView.btnFecharClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmNegociacaoView.MostrarPainelAddItem(const AMostrar: Boolean);
begin
  pnlAddItem.Visible := AMostrar;
  if AMostrar then
    pnlAddItem.BringToFront;
end;

procedure TfrmNegociacaoView.CarregarPrecoProduto;
var
  LProdutoIdx: Integer;
begin
  if cboProduto.ItemIndex < 0 then
  begin
    edtPrecoUnitario.Text := '0,00';
    Exit;
  end;

  LProdutoIdx := Integer(cboProduto.Items.Objects[cboProduto.ItemIndex]);
  if (LProdutoIdx >= 0) and (LProdutoIdx < FProdutos.Count) then
    edtPrecoUnitario.Text := FormatFloat('#,##0.00', FProdutos[LProdutoIdx].PrecoVenda)
  else
    edtPrecoUnitario.Text := '0,00';
end;

procedure TfrmNegociacaoView.cboProdutoChange(Sender: TObject);
begin
  CarregarPrecoProduto;
end;

procedure TfrmNegociacaoView.cboDistribuidorLogadoChange(Sender: TObject);
var
  LDistribuidorIdx: Integer;
begin
  if cboDistribuidorLogado.ItemIndex < 0 then
  begin
    FDistribuidorLogadoId := '';
    Exit;
  end;

  LDistribuidorIdx := Integer(cboDistribuidorLogado.Items.Objects[cboDistribuidorLogado.ItemIndex]);
  FDistribuidorLogadoId := FDistribuidores[LDistribuidorIdx].Id;
  
  FiltrarNegociacoesPorDistribuidor;
end;

function TfrmNegociacaoView.ValidarDistribuidorLogado: Boolean;
begin
  Result := False;
  
  if FDistribuidorLogadoId.IsEmpty then
  begin
    ShowMessage('Selecione o distribuidor logado.');
    cboDistribuidorLogado.SetFocus;
    Exit;
  end;
  
  Result := True;
end;

procedure TfrmNegociacaoView.FiltrarNegociacoesPorDistribuidor;
begin
  CarregarNegociacoes;
end;

end.

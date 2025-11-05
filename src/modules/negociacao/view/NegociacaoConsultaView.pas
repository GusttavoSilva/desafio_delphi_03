unit NegociacaoConsultaView;

interface

uses
  Winapi.Windows, Winapi.Messages, Winapi.ShellAPI, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ExtCtrls, Vcl.DBGrids, Data.DB, System.Generics.Collections, FireDAC.Comp.Client,
  NegociacaoEntity, NegociacaoModule, ProdutorEntity, ProdutorModule,
  DistribuidorEntity, DistribuidorModule,
  ConnectionDataBase, Vcl.Grids, frxClass, frxDBSet,
  frxSmartMemo, frCoreClasses;

type
  TfrmNegociacaoConsultaView = class(TForm)
    pnlTop: TPanel;
    lblTitulo: TLabel;
    pnlFiltros: TPanel;
    lblProdutor: TLabel;
    cboProdutor: TComboBox;
    lblDistribuidor: TLabel;
    cboDistribuidor: TComboBox;
    btnFiltrar: TButton;
    btnLimparFiltro: TButton;
    dbgNegociacoes: TDBGrid;
    dsNegociacoes: TDataSource;
    pnlButtons: TPanel;
    btnFechar: TButton;
    btnRelatorioResumido: TButton;
    frxReportResumido: TfrxReport;
    frxDBNegociacoes: TfrxDBDataset;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnFiltrarClick(Sender: TObject);
    procedure btnLimparFiltroClick(Sender: TObject);
    procedure btnFecharClick(Sender: TObject);
    procedure btnRelatorioResumidoClick(Sender: TObject);
  private
    FNegociacaoModule: TNegociacaoModule;
    FProdutorModule: TProdutorModule;
    FDistribuidorModule: TDistribuidorModule;
    
    FProdutores: TObjectList<TProdutorEntity>;
    FDistribuidores: TObjectList<TDistribuidorEntity>;
    FNegociacoes: TObjectList<TNegociacaoEntity>;
    FDataSet: TFDMemTable;
    FTotalNegociacoes: Integer;
    FSomaValorTotal: Currency;
    
    procedure InicializarDataSet;
    procedure CarregarProdutores;
    procedure CarregarDistribuidores;
    procedure CarregarNegociacoes(const AProdutorId, ADistribuidorId: string);
    procedure PreencherGrid;
    procedure GerarRelatorioResumido;
    procedure ConfigurarDataSets(const AReport: TfrxReport);
    procedure frxReportGetValue(const VarName: string; var Value: Variant);
  public
  end;

var
  frmNegociacaoConsultaView: TfrmNegociacaoConsultaView;

implementation

{$R *.dfm}

{ TfrmNegociacaoConsultaView }

procedure TfrmNegociacaoConsultaView.FormCreate(Sender: TObject);
begin
  dmConnection.Connect;
  
  FNegociacaoModule := TNegociacaoModule.Create(dmConnection.FDConnection);
  FProdutorModule := TProdutorModule.Create(dmConnection.FDConnection);
  FDistribuidorModule := TDistribuidorModule.Create(dmConnection.FDConnection);
  
  FProdutores := TObjectList<TProdutorEntity>.Create(True);
  FDistribuidores := TObjectList<TDistribuidorEntity>.Create(True);
  FNegociacoes := TObjectList<TNegociacaoEntity>.Create(True);
  
  FDataSet := TFDMemTable.Create(nil);
  dsNegociacoes.DataSet := FDataSet;
  
  // Conectar dataset ao componente FastReport
  frxDBNegociacoes.DataSet := FDataSet;
  
  // Configurar eventos OnGetValue
  frxReportResumido.OnGetValue := frxReportGetValue;
  
  FTotalNegociacoes := 0;
  FSomaValorTotal := 0;
  
  InicializarDataSet;
  CarregarProdutores;
  CarregarDistribuidores;
end;

procedure TfrmNegociacaoConsultaView.FormDestroy(Sender: TObject);
begin
  FDataSet.Free;
  FNegociacoes.Free;
  FProdutores.Free;
  FDistribuidores.Free;
  FNegociacaoModule.Free;
  FProdutorModule.Free;
  FDistribuidorModule.Free;
end;

procedure TfrmNegociacaoConsultaView.InicializarDataSet;
begin
  FDataSet.Close;
  FDataSet.FieldDefs.Clear;
  FDataSet.FieldDefs.Add('codigo', ftString, 38);
  FDataSet.FieldDefs.Add('produtor', ftString, 255);
  FDataSet.FieldDefs.Add('distribuidor', ftString, 255);
  FDataSet.FieldDefs.Add('valor_total', ftCurrency);
  FDataSet.FieldDefs.Add('status', ftString, 20);
  FDataSet.FieldDefs.Add('data_cadastro', ftDateTime);
  FDataSet.FieldDefs.Add('data_aprovacao', ftDateTime);
  FDataSet.FieldDefs.Add('data_conclusao', ftDateTime);
  FDataSet.FieldDefs.Add('data_cancelamento', ftDateTime);
  FDataSet.CreateDataSet;
end;

procedure TfrmNegociacaoConsultaView.CarregarProdutores;
var
  LLista: TObjectList<TProdutorEntity>;
  LItem: TProdutorEntity;
  LIdStr: string;
begin
  LLista := FProdutorModule.Controller.ListarTodos;
  try
    FProdutores.Clear;
    cboProdutor.Clear;
    
    // Adicionar "Todos" como primeiro item (ID vazio)
    cboProdutor.Items.AddObject('-- Todos --', TObject(0));  // Usar 0 para indicar "Todos"
    
    // Adicionar produtores com seus IDs armazenados
    for LItem in LLista do
    begin
      if Assigned(LItem) then
      begin
        FProdutores.Add(LItem);
        // Armazenar o ID da entidade no Object do combobox
        cboProdutor.Items.AddObject(LItem.Nome, Pointer(NativeInt(cboProdutor.Items.Count - 1)));
      end;
    end;
    LLista.OwnsObjects := False;
  finally
    LLista.Free;
  end;
  
  cboProdutor.ItemIndex := 0;
end;

procedure TfrmNegociacaoConsultaView.CarregarDistribuidores;
var
  LLista: TObjectList<TDistribuidorEntity>;
  LItem: TDistribuidorEntity;
begin
  LLista := FDistribuidorModule.Controller.ListarTodos;
  try
    FDistribuidores.Clear;
    cboDistribuidor.Clear;
    
    // Adicionar "Todos" como primeiro item (ID vazio)
    cboDistribuidor.Items.AddObject('-- Todos --', TObject(0));  // Usar 0 para indicar "Todos"
    
    // Adicionar distribuidores com seus IDs armazenados
    for LItem in LLista do
    begin
      if Assigned(LItem) then
      begin
        FDistribuidores.Add(LItem);
        // Armazenar o índice do distribuidor na lista
        cboDistribuidor.Items.AddObject(LItem.Nome, Pointer(NativeInt(cboDistribuidor.Items.Count - 1)));
      end;
    end;
    LLista.OwnsObjects := False;
  finally
    LLista.Free;
  end;
  
  cboDistribuidor.ItemIndex := 0;
end;

procedure TfrmNegociacaoConsultaView.btnFiltrarClick(Sender: TObject);
var
  LProdutorId, LDistribuidorId: string;
  LProdutorIdx, LDistribuidorIdx: Integer;
begin
  LProdutorId := '';
  LDistribuidorId := '';
  
  // Se selecionou um produtor específico (não "Todos")
  if (cboProdutor.ItemIndex > 0) then
  begin
    // Obter o índice armazenado no Object do combobox
    LProdutorIdx := NativeInt(cboProdutor.Items.Objects[cboProdutor.ItemIndex]);
    
    // Validar índice
    if (LProdutorIdx >= 0) and (LProdutorIdx < FProdutores.Count) then
    begin
      if Assigned(FProdutores[LProdutorIdx]) then
        LProdutorId := FProdutores[LProdutorIdx].Id;
    end;
  end;
  
  // Se selecionou um distribuidor específico (não "Todos")
  if (cboDistribuidor.ItemIndex > 0) then
  begin
    // Obter o índice armazenado no Object do combobox
    LDistribuidorIdx := NativeInt(cboDistribuidor.Items.Objects[cboDistribuidor.ItemIndex]);
    
    // Validar índice
    if (LDistribuidorIdx >= 0) and (LDistribuidorIdx < FDistribuidores.Count) then
    begin
      if Assigned(FDistribuidores[LDistribuidorIdx]) then
        LDistribuidorId := FDistribuidores[LDistribuidorIdx].Id;
    end;
  end;
  
  try
    CarregarNegociacoes(LProdutorId, LDistribuidorId);
  except
    on E: Exception do
      ShowMessage('Erro ao filtrar negociações: ' + E.Message);
  end;
end;

procedure TfrmNegociacaoConsultaView.CarregarNegociacoes(const AProdutorId, ADistribuidorId: string);
var
  LLista: TObjectList<TNegociacaoEntity>;
  LItem: TNegociacaoEntity;
  LProdutorId, LDistribuidorId: string;
begin
  FNegociacoes.Clear;
  
  // Garantir que IDs vazios são tratados como vazios
  LProdutorId := Trim(AProdutorId);
  LDistribuidorId := Trim(ADistribuidorId);
  
  // Se ambos vazios, buscar todos
  if LProdutorId.IsEmpty and LDistribuidorId.IsEmpty then
  begin
    LLista := FNegociacaoModule.Controller.ListarTodos;
    if Assigned(LLista) then
    try
      for LItem in LLista do
      begin
        if Assigned(LItem) then
          FNegociacoes.Add(LItem);
      end;
      LLista.OwnsObjects := False;
    finally
      LLista.Free;
    end;
  end
  // Se só produtor (distribuidor vazio)
  else if (not LProdutorId.IsEmpty) and LDistribuidorId.IsEmpty then
  begin
    LLista := FNegociacaoModule.Controller.ListarPorProdutor(LProdutorId);
    if Assigned(LLista) then
    try
      for LItem in LLista do
      begin
        if Assigned(LItem) then
          FNegociacoes.Add(LItem);
      end;
      LLista.OwnsObjects := False;
    finally
      LLista.Free;
    end;
  end
  // Se só distribuidor (produtor vazio)
  else if LProdutorId.IsEmpty and (not LDistribuidorId.IsEmpty) then
  begin
    LLista := FNegociacaoModule.Controller.ListarPorDistribuidor(LDistribuidorId);
    if Assigned(LLista) then
    try
      for LItem in LLista do
      begin
        if Assigned(LItem) then
          FNegociacoes.Add(LItem);
      end;
      LLista.OwnsObjects := False;
    finally
      LLista.Free;
    end;
  end
  // Se ambos preenchidos, filtrar manualmente
  else if (not LProdutorId.IsEmpty) and (not LDistribuidorId.IsEmpty) then
  begin
    LLista := FNegociacaoModule.Controller.ListarTodos;
    if Assigned(LLista) then
    try
      for LItem in LLista do
      begin
        if Assigned(LItem) then
        begin
          if (LItem.ProdutorId = LProdutorId) and (LItem.DistribuidorId = LDistribuidorId) then
            FNegociacoes.Add(LItem);
        end;
      end;
      LLista.OwnsObjects := False;
    finally
      LLista.Free;
    end;
  end;
  
  PreencherGrid;
end;

procedure TfrmNegociacaoConsultaView.PreencherGrid;
var
  LNegociacao: TNegociacaoEntity;
  LProdutor: TProdutorEntity;
  LDistribuidor: TDistribuidorEntity;
begin
  FDataSet.DisableControls;
  try
    FDataSet.EmptyDataSet;
    FTotalNegociacoes := 0;
    FSomaValorTotal := 0;
    
    for LNegociacao in FNegociacoes do
    begin
      FDataSet.Append;
      FDataSet.FieldByName('codigo').AsString := LNegociacao.Id;
      
      // Buscar nome do produtor
      LProdutor := FProdutorModule.Controller.BuscarPorId(LNegociacao.ProdutorId);
      if Assigned(LProdutor) then
      begin
        FDataSet.FieldByName('produtor').AsString := LProdutor.Nome;
        LProdutor.Free;
      end;
      
      // Buscar nome do distribuidor
      LDistribuidor := FDistribuidorModule.Controller.BuscarPorId(LNegociacao.DistribuidorId);
      if Assigned(LDistribuidor) then
      begin
        FDataSet.FieldByName('distribuidor').AsString := LDistribuidor.Nome;
        LDistribuidor.Free;
      end;
      
      FDataSet.FieldByName('valor_total').AsCurrency := LNegociacao.ValorTotal;
      FDataSet.FieldByName('status').AsString := LNegociacao.Status;
      FDataSet.FieldByName('data_cadastro').AsDateTime := LNegociacao.DataCadastro;
      
      // Preencher datas opcionais
      if LNegociacao.DataAprovacao > 0 then
        FDataSet.FieldByName('data_aprovacao').AsDateTime := LNegociacao.DataAprovacao
      else
        FDataSet.FieldByName('data_aprovacao').Clear;
      
      if LNegociacao.DataConclusao > 0 then
        FDataSet.FieldByName('data_conclusao').AsDateTime := LNegociacao.DataConclusao
      else
        FDataSet.FieldByName('data_conclusao').Clear;
      
      if LNegociacao.DataCancelamento > 0 then
        FDataSet.FieldByName('data_cancelamento').AsDateTime := LNegociacao.DataCancelamento
      else
        FDataSet.FieldByName('data_cancelamento').Clear;
      
      FDataSet.Post;
      
      Inc(FTotalNegociacoes);
      FSomaValorTotal := FSomaValorTotal + LNegociacao.ValorTotal;
    end;
  finally
    FDataSet.EnableControls;
  end;

  btnRelatorioResumido.Enabled := not FDataSet.IsEmpty;
end;

procedure TfrmNegociacaoConsultaView.btnLimparFiltroClick(Sender: TObject);
begin
  cboProdutor.ItemIndex := 0;
  cboDistribuidor.ItemIndex := 0;
  FNegociacoes.Clear;
  FDataSet.EmptyDataSet;
  FTotalNegociacoes := 0;
  FSomaValorTotal := 0;
  btnRelatorioResumido.Enabled := False;
end;

procedure TfrmNegociacaoConsultaView.btnRelatorioResumidoClick(Sender: TObject);
begin
  try
    GerarRelatorioResumido;
  except
    on E: Exception do
      ShowMessage('Erro ao gerar relatório resumido: ' + E.Message);
  end;
end;

procedure TfrmNegociacaoConsultaView.GerarRelatorioResumido;
var
  LCaminhoRelatorio: string;
begin
  if FNegociacoes.Count = 0 then
  begin
    ShowMessage('Nenhuma negociação para imprimir.');
    Exit;
  end;
  
  // Carregar relatório externo
  LCaminhoRelatorio := ExtractFilePath(ParamStr(0)) + 'reports\report_negociacao_resumido.fr3';
  if FileExists(LCaminhoRelatorio) then
  begin
    // Primeiro configurar os datasets ANTES de carregar o arquivo
    ConfigurarDataSets(frxReportResumido);
    
    // Depois carregar o arquivo
    frxReportResumido.LoadFromFile(LCaminhoRelatorio);
    
    // Reconfigurar após o carregamento (para garantir)
    ConfigurarDataSets(frxReportResumido);
    
    // Posicionar dataset no primeiro registro
    if not FDataSet.IsEmpty then
      FDataSet.First;
    
    frxReportResumido.ShowReport;
  end
  else
    ShowMessage('Arquivo de relatório não encontrado: ' + LCaminhoRelatorio);
end;

procedure TfrmNegociacaoConsultaView.ConfigurarDataSets(const AReport: TfrxReport);
var
  LItem: TfrxDataSetItem;
begin
  // Limpar todos os datasets existentes no relatório
  while AReport.DataSets.Count > 0 do
    AReport.DataSets.Delete(0);

  // Adicionar dataset de negociações com o nome esperado
  LItem := TfrxDataSetItem(AReport.DataSets.Add);
  LItem.DataSet := frxDBNegociacoes;
  LItem.DataSetName := 'frxDBNegociacoes';
  frxDBNegociacoes.DataSet := FDataSet;
end;

procedure TfrmNegociacaoConsultaView.frxReportGetValue(const VarName: string;
  var Value: Variant);
begin
  if SameText(VarName, 'TotalNegociacoes') then
    Value := FTotalNegociacoes
  else if SameText(VarName, 'SomaValorTotal') then
    Value := FSomaValorTotal;
end;

procedure TfrmNegociacaoConsultaView.btnFecharClick(Sender: TObject);
begin
  Close;
end;

end.

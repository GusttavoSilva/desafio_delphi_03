unit LimiteCreditoRelatorioView;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, 
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, 
  Vcl.ExtCtrls, Vcl.DBGrids, Data.DB, System.Generics.Collections, FireDAC.Comp.Client,
  LimiteCreditoEntity, LimiteCreditoModule, ProdutorEntity, ProdutorModule,
  DistribuidorEntity, DistribuidorModule, ConnectionDataBase, Vcl.Grids,
  frxClass, frxDBSet, frxSmartMemo, frCoreClasses;

type
  TfrmLimiteCreditoRelatorioView = class(TForm)
    pnlTop: TPanel;
    lblTitulo: TLabel;
    pnlFiltros: TPanel;
    lblProdutor: TLabel;
    cboProdutor: TComboBox;
    btnFiltrar: TButton;
    btnLimparFiltro: TButton;
    btnImprimirRelatorio: TButton;
    dbgLimites: TDBGrid;
    dsLimites: TDataSource;
    pnlButtons: TPanel;
    btnFechar: TButton;
    frxReport: TfrxReport;
    frxDBLimites: TfrxDBDataset;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnFiltrarClick(Sender: TObject);
    procedure btnLimparFiltroClick(Sender: TObject);
    procedure btnImprimirRelatorioClick(Sender: TObject);
    procedure btnFecharClick(Sender: TObject);
  private
    FLimiteCreditoModule: TLimiteCreditoModule;
    FProdutorModule: TProdutorModule;
    FDistribuidorModule: TDistribuidorModule;
    
    FProdutores: TObjectList<TProdutorEntity>;
    FLimites: TObjectList<TLimiteCreditoEntity>;
    FDataSet: TFDMemTable;
    FTotalLimites: Integer;
    FSomaLimites: Currency;
    
    procedure InicializarDataSet;
    procedure CarregarProdutores;
    procedure CarregarLimites(const AProdutorId: string);
    procedure PreencherGrid;
    procedure GerarRelatorio;
    procedure frxReportGetValue(const VarName: string; var Value: Variant);
  public
  end;

var
  frmLimiteCreditoRelatorioView: TfrmLimiteCreditoRelatorioView;

implementation

{$R *.dfm}

{ TfrmLimiteCreditoRelatorioView }

procedure TfrmLimiteCreditoRelatorioView.FormCreate(Sender: TObject);
begin
  dmConnection.Connect;
  
  FLimiteCreditoModule := TLimiteCreditoModule.Create(dmConnection.FDConnection);
  FProdutorModule := TProdutorModule.Create(dmConnection.FDConnection);
  FDistribuidorModule := TDistribuidorModule.Create(dmConnection.FDConnection);
  
  FProdutores := TObjectList<TProdutorEntity>.Create(True);
  FLimites := TObjectList<TLimiteCreditoEntity>.Create(True);
  
  FDataSet := TFDMemTable.Create(nil);
  dsLimites.DataSet := FDataSet;
  
  // Conectar o frxDBLimites ao dataset em memória
  frxDBLimites.DataSet := FDataSet;
  
  // Inicializar totais
  FTotalLimites := 0;
  FSomaLimites := 0;
  
  // Configurar evento OnGetValue do relatório
  frxReport.OnGetValue := frxReportGetValue;
  
  InicializarDataSet;
  CarregarProdutores;
end;

procedure TfrmLimiteCreditoRelatorioView.FormDestroy(Sender: TObject);
begin
  FDataSet.Free;
  FLimites.Free;
  FProdutores.Free;
  FLimiteCreditoModule.Free;
  FProdutorModule.Free;
  FDistribuidorModule.Free;
end;

procedure TfrmLimiteCreditoRelatorioView.InicializarDataSet;
begin
  FDataSet.Close;
  FDataSet.FieldDefs.Clear;
  FDataSet.FieldDefs.Add('produtor', ftString, 255);
  FDataSet.FieldDefs.Add('distribuidor', ftString, 255);
  FDataSet.FieldDefs.Add('limite', ftCurrency);
  FDataSet.CreateDataSet;
end;

procedure TfrmLimiteCreditoRelatorioView.CarregarProdutores;
var
  LLista: TObjectList<TProdutorEntity>;
  LItem: TProdutorEntity;
begin
  LLista := FProdutorModule.Controller.ListarTodos;
  try
    FProdutores.Clear;
    cboProdutor.Clear;
    cboProdutor.Items.Add('-- Todos --');
    
    for LItem in LLista do
    begin
      FProdutores.Add(LItem);
      cboProdutor.Items.AddObject(LItem.Nome, Pointer(FProdutores.Count - 1));
    end;
    LLista.OwnsObjects := False;
  finally
    LLista.Free;
  end;
  
  cboProdutor.ItemIndex := 0;
end;

procedure TfrmLimiteCreditoRelatorioView.btnFiltrarClick(Sender: TObject);
var
  LProdutorId: string;
  LProdutorIdx: Integer;
begin
  LProdutorId := '';
  
  // Verificar se selecionou produtor
  if (cboProdutor.ItemIndex > 0) then
  begin
    LProdutorIdx := Integer(cboProdutor.Items.Objects[cboProdutor.ItemIndex]);
    LProdutorId := FProdutores[LProdutorIdx].Id;
  end;
  
  try
    CarregarLimites(LProdutorId);
  except
    on E: Exception do
      ShowMessage('Erro ao filtrar limites: ' + E.Message);
  end;
end;

procedure TfrmLimiteCreditoRelatorioView.CarregarLimites(const AProdutorId: string);
var
  LLista: TObjectList<TLimiteCreditoEntity>;
  LItem: TLimiteCreditoEntity;
begin
  FLimites.Clear;
  
  // Buscar todos os limites
  LLista := FLimiteCreditoModule.Controller.ListarTodos;
  try
    LLista.OwnsObjects := False;
    for LItem in LLista do
    begin
      // Se filtro vazio, adicionar todos
      // Se filtro preenchido, adicionar só os que correspondem ao produtor
      if AProdutorId.IsEmpty or (LItem.ProdutorId = AProdutorId) then
        FLimites.Add(LItem);
    end;
  finally
    LLista.Free;
  end;
  
  PreencherGrid;
end;

procedure TfrmLimiteCreditoRelatorioView.PreencherGrid;
var
  LLimite: TLimiteCreditoEntity;
  LProdutor: TProdutorEntity;
  LDistribuidor: TDistribuidorEntity;
begin
  FDataSet.DisableControls;
  try
    FDataSet.EmptyDataSet;
    FTotalLimites := 0;
    FSomaLimites := 0;
    
    for LLimite in FLimites do
    begin
      FDataSet.Append;
      
      // Buscar nome do produtor
      LProdutor := FProdutorModule.Controller.BuscarPorId(LLimite.ProdutorId);
      if Assigned(LProdutor) then
      begin
        FDataSet.FieldByName('produtor').AsString := LProdutor.Nome;
        LProdutor.Free;
      end;
      
      // Buscar nome do distribuidor
      LDistribuidor := FDistribuidorModule.Controller.BuscarPorId(LLimite.DistribuidorId);
      if Assigned(LDistribuidor) then
      begin
        FDataSet.FieldByName('distribuidor').AsString := LDistribuidor.Nome;
        LDistribuidor.Free;
      end;
      
      FDataSet.FieldByName('limite').AsCurrency := LLimite.Limite;
      FDataSet.Post;
      
      // Acumular totais
      Inc(FTotalLimites);
      FSomaLimites := FSomaLimites + LLimite.Limite;
    end;
  finally
    FDataSet.EnableControls;
  end;
  
  btnImprimirRelatorio.Enabled := not FDataSet.IsEmpty;
end;

procedure TfrmLimiteCreditoRelatorioView.btnLimparFiltroClick(Sender: TObject);
begin
  cboProdutor.ItemIndex := 0;
  FLimites.Clear;
  FDataSet.EmptyDataSet;
  FTotalLimites := 0;
  FSomaLimites := 0;
  btnImprimirRelatorio.Enabled := False;
end;

procedure TfrmLimiteCreditoRelatorioView.btnImprimirRelatorioClick(Sender: TObject);
begin
  try
    GerarRelatorio;
  except
    on E: Exception do
      ShowMessage('Erro ao gerar relatório: ' + E.Message);
  end;
end;

procedure TfrmLimiteCreditoRelatorioView.GerarRelatorio;
begin
  if FLimites.Count = 0 then
  begin
    ShowMessage('Nenhum limite para imprimir.');
    Exit;
  end;
  
  // Verificar se o dataset está ativo
  if not FDataSet.Active then
  begin
    ShowMessage('Dataset não está ativo. Por favor, filtre os dados primeiro.');
    Exit;
  end;
  
  try
    // Posicionar o dataset no primeiro registro
    FDataSet.First;
    
    // Garantir que o dataset está conectado ao frxDBLimites
    frxDBLimites.DataSet := FDataSet;
    
    // Exibir o relatório (usa o design embutido no DFM)
    frxReport.ShowReport;
  except
    on E: Exception do
      ShowMessage('Erro ao gerar relatório: ' + E.Message);
  end;
end;

procedure TfrmLimiteCreditoRelatorioView.frxReportGetValue(const VarName: string;
  var Value: Variant);
begin
  if SameText(VarName, 'TotalLimites') then
    Value := FTotalLimites
  else if SameText(VarName, 'SomaLimites') then
    Value := FSomaLimites;
end;

procedure TfrmLimiteCreditoRelatorioView.btnFecharClick(Sender: TObject);
begin
  Close;
end;

end.

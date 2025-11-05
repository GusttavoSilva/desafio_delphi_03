unit LimiteCreditoView;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.DBGrids, Data.DB, System.Generics.Collections, FireDAC.Comp.Client,
  LimiteCreditoEntity, LimiteCreditoModule, ProdutorEntity, ProdutorModule,
  DistribuidorEntity, DistribuidorModule, ConnectionDataBase, Vcl.Grids, Vcl.ComCtrls,
  System.UITypes;

type
  TfrmLimiteCreditoView = class(TForm)
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
    dbgLimites: TDBGrid;
    pnlCadastro: TPanel;
    lblProdutor: TLabel;
    cboProdutor: TComboBox;
    lblLimite: TLabel;
    edtLimite: TEdit;
    dsLimites: TDataSource;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnNovoClick(Sender: TObject);
    procedure btnSalvarClick(Sender: TObject);
    procedure btnExcluirClick(Sender: TObject);
    procedure btnCancelarClick(Sender: TObject);
    procedure btnAtualizarClick(Sender: TObject);
    procedure btnFecharClick(Sender: TObject);
    procedure dbgLimitesCellClick(Column: TColumn);
    procedure cboDistribuidorLogadoChange(Sender: TObject);
  private
    FLimiteCreditoModule: TLimiteCreditoModule;
    FProdutorModule: TProdutorModule;
    FDistribuidorModule: TDistribuidorModule;
    FLimiteAtual: TLimiteCreditoEntity;
    FLimites: TObjectList<TLimiteCreditoEntity>;
    FProdutores: TObjectList<TProdutorEntity>;
    FDistribuidores: TObjectList<TDistribuidorEntity>;
    FDataSet: TFDMemTable;
    FDistribuidorLogadoId: string;
    
    procedure CarregarDistribuidores;
    procedure CarregarProdutores;
    procedure CarregarLimitesPorDistribuidor;
    procedure PreencherGrid;
    procedure LimparCampos;
    procedure HabilitarEdicao(const AHabilitar: Boolean);
    procedure CarregarLimiteNaTela(ALimite: TLimiteCreditoEntity);
    procedure SincronizarLimiteComTela;
    function ValidarDistribuidorLogado: Boolean;
    procedure InicializarDataSet;
    procedure AtivarCadastro;
    procedure AtivarConsulta;
  public
  end;

var
  frmLimiteCreditoView: TfrmLimiteCreditoView;

implementation

uses
  GsBaseEntity, GsValidation;

{$R *.dfm}

{ TfrmLimiteCreditoView }

procedure TfrmLimiteCreditoView.FormCreate(Sender: TObject);
begin
  dmConnection.Connect;
  FLimiteCreditoModule := TLimiteCreditoModule.Create(dmConnection.FDConnection);
  FProdutorModule := TProdutorModule.Create(dmConnection.FDConnection);
  FDistribuidorModule := TDistribuidorModule.Create(dmConnection.FDConnection);
  FLimites := TObjectList<TLimiteCreditoEntity>.Create(True);
  FProdutores := TObjectList<TProdutorEntity>.Create(True);
  FDistribuidores := TObjectList<TDistribuidorEntity>.Create(True);
  FDataSet := TFDMemTable.Create(nil);
  dsLimites.DataSet := FDataSet;
  InicializarDataSet;
  FLimiteAtual := nil;
  FDistribuidorLogadoId := '';

  CarregarDistribuidores;
  CarregarProdutores;
  HabilitarEdicao(False);
end;

procedure TfrmLimiteCreditoView.FormDestroy(Sender: TObject);
begin
  FDataSet.Free;
  FLimites.Free;
  FProdutores.Free;
  FDistribuidores.Free;
  FLimiteCreditoModule.Free;
  FProdutorModule.Free;
  FDistribuidorModule.Free;
  FLimiteAtual.Free;
end;

procedure TfrmLimiteCreditoView.CarregarDistribuidores;
var
  LLista: TObjectList<TDistribuidorEntity>;
  LItem: TDistribuidorEntity;
begin
  LLista := FDistribuidorModule.Controller.ListarTodos;
  try
    FDistribuidores.Clear;
    cboDistribuidorLogado.Clear;
    for LItem in LLista do
    begin
      FDistribuidores.Add(LItem);
      cboDistribuidorLogado.Items.AddObject(LItem.Nome, Pointer(FDistribuidores.Count - 1));
    end;
    LLista.OwnsObjects := False;
  finally
    LLista.Free;
  end;

  cboDistribuidorLogado.ItemIndex := -1;
end;

procedure TfrmLimiteCreditoView.CarregarProdutores;
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

procedure TfrmLimiteCreditoView.cboDistribuidorLogadoChange(Sender: TObject);
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
  
  CarregarLimitesPorDistribuidor;
end;

procedure TfrmLimiteCreditoView.CarregarLimitesPorDistribuidor;
var
  LLista: TObjectList<TLimiteCreditoEntity>;
  LItem: TLimiteCreditoEntity;
begin
  FLimites.Clear;
  
  if FDistribuidorLogadoId.IsEmpty then
  begin
    PreencherGrid;
    Exit;
  end;

  LLista := FLimiteCreditoModule.Controller.ListarTodos;
  try
    for LItem in LLista do
    begin
      if LItem.DistribuidorId = FDistribuidorLogadoId then
        FLimites.Add(LItem);
    end;
    LLista.OwnsObjects := False;
  finally
    LLista.Free;
  end;
  PreencherGrid;
end;

procedure TfrmLimiteCreditoView.PreencherGrid;
var
  LLimite: TLimiteCreditoEntity;
  LProdutor: TProdutorEntity;
begin
  FDataSet.DisableControls;
  try
    FDataSet.EmptyDataSet;
    for LLimite in FLimites do
    begin
      FDataSet.Append;
      FDataSet.FieldByName('id').AsString := LLimite.Id;
      
      // Buscar nome do produtor
      for LProdutor in FProdutores do
      begin
        if LProdutor.Id = LLimite.ProdutorId then
        begin
          FDataSet.FieldByName('produtor').AsString := LProdutor.Nome;
          Break;
        end;
      end;
      
      FDataSet.FieldByName('limite').AsCurrency := LLimite.Limite;
      FDataSet.FieldByName('data_criacao').AsDateTime := LLimite.CreatedAt;
      FDataSet.Post;
    end;
  finally
    FDataSet.EnableControls;
  end;

  btnExcluir.Enabled := (dsLimites.DataSet <> nil) and (not dsLimites.DataSet.IsEmpty);
end;

procedure TfrmLimiteCreditoView.btnNovoClick(Sender: TObject);
begin
  if not ValidarDistribuidorLogado then
    Exit;
    
  LimparCampos;
  HabilitarEdicao(True);

  FreeAndNil(FLimiteAtual);
  FLimiteAtual := TLimiteCreditoEntity.Create;
  FLimiteAtual.State := esInsert;
  FLimiteAtual.DistribuidorId := FDistribuidorLogadoId;

  cboProdutor.SetFocus;
end;

procedure TfrmLimiteCreditoView.btnSalvarClick(Sender: TObject);
begin
  try
    SincronizarLimiteComTela;
    FLimiteAtual := FLimiteCreditoModule.Controller.Salvar(FLimiteAtual);

    ShowMessage('Limite de crédito salvo com sucesso!');

    btnCancelarClick(Sender);
    CarregarLimitesPorDistribuidor;
  except
    on E: Exception do
      ShowMessage('Erro ao salvar: ' + E.Message);
  end;
end;

procedure TfrmLimiteCreditoView.btnExcluirClick(Sender: TObject);
begin
  if not Assigned(FLimiteAtual) then
  begin
    ShowMessage('Selecione um limite para excluir.');
    Exit;
  end;
  
  if MessageDlg('Deseja realmente excluir este limite de crédito?', 
                mtConfirmation, [mbYes, mbNo], 0) = mrYes then
  begin
    try
      FLimiteCreditoModule.Controller.Excluir(FLimiteAtual);
      ShowMessage('Limite de crédito excluído com sucesso!');

      LimparCampos;
      HabilitarEdicao(False);
      CarregarLimitesPorDistribuidor;
    except
      on E: Exception do
        ShowMessage('Erro ao excluir: ' + E.Message);
    end;
  end;
end;

procedure TfrmLimiteCreditoView.btnCancelarClick(Sender: TObject);
begin
  LimparCampos;
  HabilitarEdicao(False);
  FreeAndNil(FLimiteAtual);
end;

procedure TfrmLimiteCreditoView.dbgLimitesCellClick(Column: TColumn);
var
  LId: string;
begin
  if not Assigned(dsLimites.DataSet) or dsLimites.DataSet.IsEmpty then
    Exit;

  LId := dsLimites.DataSet.FieldByName('id').AsString;
  if LId.IsEmpty then
    Exit;

  try
    FreeAndNil(FLimiteAtual);
    FLimiteAtual := FLimiteCreditoModule.Controller.BuscarPorId(LId);

    if Assigned(FLimiteAtual) then
    begin
      FLimiteAtual.State := esUpdate;
      CarregarLimiteNaTela(FLimiteAtual);
      HabilitarEdicao(True);
    end;
  except
    on E: Exception do
      ShowMessage('Erro ao carregar limite: ' + E.Message);
  end;
end;

procedure TfrmLimiteCreditoView.LimparCampos;
begin
  cboProdutor.ItemIndex := -1;
  edtLimite.Text := '0,00';
end;

procedure TfrmLimiteCreditoView.HabilitarEdicao(const AHabilitar: Boolean);
var
  LTemItens: Boolean;
begin
  cboProdutor.Enabled := AHabilitar and (not Assigned(FLimiteAtual) or (FLimiteAtual.State = esInsert));
  edtLimite.Enabled := AHabilitar;
  btnSalvar.Enabled := AHabilitar;
  btnCancelar.Enabled := AHabilitar;
  btnNovo.Enabled := not AHabilitar;

  LTemItens := (dsLimites.DataSet <> nil) and (not dsLimites.DataSet.IsEmpty);
  if AHabilitar then
    btnExcluir.Enabled := Assigned(FLimiteAtual) and (FLimiteAtual.State = esUpdate)
  else
    btnExcluir.Enabled := LTemItens;
  btnAtualizar.Enabled := not AHabilitar;

  cboDistribuidorLogado.Enabled := not AHabilitar;

  if AHabilitar then
    AtivarCadastro
  else
    AtivarConsulta;
end;

procedure TfrmLimiteCreditoView.CarregarLimiteNaTela(ALimite: TLimiteCreditoEntity);
var
  I: Integer;
begin
  if not Assigned(ALimite) then
    Exit;

  // Selecionar produtor
  for I := 0 to FProdutores.Count - 1 do
  begin
    if FProdutores[I].Id = ALimite.ProdutorId then
    begin
      cboProdutor.ItemIndex := I;
      Break;
    end;
  end;
    
  edtLimite.Text := FormatFloat('#,##0.00', ALimite.Limite);
end;

function TfrmLimiteCreditoView.ValidarDistribuidorLogado: Boolean;
begin
  Result := False;
  
  if FDistribuidorLogadoId.IsEmpty then
  begin
    ShowMessage('Selecione um distribuidor logado.');
    cboDistribuidorLogado.SetFocus;
    Exit;
  end;
  
  Result := True;
end;

procedure TfrmLimiteCreditoView.InicializarDataSet;
begin
  FDataSet.Close;
  FDataSet.FieldDefs.Clear;
  FDataSet.FieldDefs.Add('id', ftString, 38);
  FDataSet.FieldDefs.Add('produtor', ftString, 255);
  FDataSet.FieldDefs.Add('limite', ftCurrency);
  FDataSet.FieldDefs.Add('data_criacao', ftDateTime);
  FDataSet.CreateDataSet;
end;

procedure TfrmLimiteCreditoView.AtivarCadastro;
begin
  pgcMain.ActivePage := tabCadastro;
end;

procedure TfrmLimiteCreditoView.AtivarConsulta;
begin
  pgcMain.ActivePage := tabConsulta;
end;

procedure TfrmLimiteCreditoView.btnAtualizarClick(Sender: TObject);
begin
  CarregarLimitesPorDistribuidor;
end;

procedure TfrmLimiteCreditoView.btnFecharClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmLimiteCreditoView.SincronizarLimiteComTela;
var
  LProdutorIdx: Integer;
begin
  if not Assigned(FLimiteAtual) then
    Exit;

  LProdutorIdx := Integer(cboProdutor.Items.Objects[cboProdutor.ItemIndex]);
  FLimiteAtual.ProdutorId := FProdutores[LProdutorIdx].Id;
  FLimiteAtual.DistribuidorId := FDistribuidorLogadoId;
  FLimiteAtual.Limite := TgsValidation.TratarValorMonetario(edtLimite.Text);
end;

end.

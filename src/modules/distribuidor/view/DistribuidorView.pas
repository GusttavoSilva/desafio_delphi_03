unit DistribuidorView;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.DBGrids, Data.DB, System.Generics.Collections, FireDAC.Comp.Client,
  DistribuidorEntity, DistribuidorModule, ConnectionDataBase, Vcl.Grids,
  Vcl.ComCtrls, System.UITypes;

type
  TfrmDistribuidorView = class(TForm)
    pnlTop: TPanel;
    lblTitulo: TLabel;
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
    pnlCadastro: TPanel;
    lblNome: TLabel;
    lblCnpj: TLabel;
    edtNome: TEdit;
    edtCnpj: TEdit;
    dbgDistribuidores: TDBGrid;
    dsDistribuidor: TDataSource;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnNovoClick(Sender: TObject);
    procedure btnSalvarClick(Sender: TObject);
    procedure btnExcluirClick(Sender: TObject);
    procedure btnCancelarClick(Sender: TObject);
    procedure btnAtualizarClick(Sender: TObject);
    procedure btnFecharClick(Sender: TObject);
    procedure dbgDistribuidoresCellClick(Column: TColumn);
  private
    FModule: TDistribuidorModule;
    FDistribuidores: TObjectList<TDistribuidorEntity>;
    FDistribuidorAtual: TDistribuidorEntity;
    FDataSet: TFDMemTable;

    procedure InicializarDataSet;
    procedure CarregarDistribuidores;
    procedure PreencherGrid;
    procedure LimparCampos;
    procedure HabilitarEdicao(const AHabilitar: Boolean);
    procedure CarregarDistribuidorNaTela(ADistribuidor: TDistribuidorEntity);
    procedure SincronizarDistribuidorComTela;
    procedure AtivarConsulta;
    procedure AtivarCadastro;
  public
  end;

var
  frmDistribuidorView: TfrmDistribuidorView;

implementation

uses
  GsBaseEntity;

{$R *.dfm}

{ TfrmDistribuidorView }

procedure TfrmDistribuidorView.FormCreate(Sender: TObject);
begin
  dmConnection.Connect;
  FModule := TDistribuidorModule.Create(dmConnection.FDConnection);
  FDistribuidores := TObjectList<TDistribuidorEntity>.Create(True);
  FDataSet := TFDMemTable.Create(nil);
  dsDistribuidor.DataSet := FDataSet;
  InicializarDataSet;
  HabilitarEdicao(False);
  CarregarDistribuidores;
end;

procedure TfrmDistribuidorView.FormDestroy(Sender: TObject);
begin
  FDataSet.Free;
  FDistribuidores.Free;
  FModule.Free;
  FDistribuidorAtual.Free;
end;

procedure TfrmDistribuidorView.InicializarDataSet;
begin
  FDataSet.Close;
  FDataSet.FieldDefs.Clear;
  FDataSet.FieldDefs.Add('id', ftString, 38);
  FDataSet.FieldDefs.Add('nome', ftString, 255);
  FDataSet.FieldDefs.Add('cnpj', ftString, 18);
  FDataSet.FieldDefs.Add('data_criacao', ftDateTime);
  FDataSet.CreateDataSet;
end;

procedure TfrmDistribuidorView.CarregarDistribuidores;
var
  LLista: TObjectList<TDistribuidorEntity>;
  LItem: TDistribuidorEntity;
begin
  LLista := FModule.Controller.ListarTodos;
  try
    FDistribuidores.Clear;
    for LItem in LLista do
      FDistribuidores.Add(LItem);
    LLista.OwnsObjects := False;
  finally
    LLista.Free;
  end;
  PreencherGrid;
end;

procedure TfrmDistribuidorView.PreencherGrid;
var
  LDistribuidor: TDistribuidorEntity;
begin
  FDataSet.DisableControls;
  try
    FDataSet.EmptyDataSet;
    for LDistribuidor in FDistribuidores do
    begin
      FDataSet.Append;
      FDataSet.FieldByName('id').AsString := LDistribuidor.Id;
      FDataSet.FieldByName('nome').AsString := LDistribuidor.Nome;
      FDataSet.FieldByName('cnpj').AsString := LDistribuidor.Cnpj;
      FDataSet.FieldByName('data_criacao').AsDateTime := LDistribuidor.CreatedAt;
      FDataSet.Post;
    end;
  finally
    FDataSet.EnableControls;
  end;

  btnExcluir.Enabled := (dsDistribuidor.DataSet <> nil) and (not dsDistribuidor.DataSet.IsEmpty);
end;

procedure TfrmDistribuidorView.btnAtualizarClick(Sender: TObject);
begin
  CarregarDistribuidores;
end;

procedure TfrmDistribuidorView.btnCancelarClick(Sender: TObject);
begin
  LimparCampos;
  HabilitarEdicao(False);
  FreeAndNil(FDistribuidorAtual);
end;

procedure TfrmDistribuidorView.btnExcluirClick(Sender: TObject);
var
  LId: string;
begin
  if not Assigned(FDistribuidorAtual) then
  begin
    ShowMessage('Selecione um distribuidor para excluir.');
    Exit;
  end;

  if MessageDlg('Deseja realmente excluir este distribuidor?', mtConfirmation, [mbYes, mbNo], 0) <> mrYes then
    Exit;

  try
  LId := FDistribuidorAtual.Id;
  FModule.Controller.Excluir(FDistribuidorAtual);
    ShowMessage('Distribuidor excluído com sucesso.');
    btnCancelarClick(Sender);
    CarregarDistribuidores;
  except
    on E: Exception do
      ShowMessage('Erro ao excluir: ' + E.Message);
  end;
end;

procedure TfrmDistribuidorView.btnFecharClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmDistribuidorView.btnNovoClick(Sender: TObject);
begin
  LimparCampos;
  FreeAndNil(FDistribuidorAtual);
  FDistribuidorAtual := TDistribuidorEntity.Create;
  FDistribuidorAtual.State := esInsert;
  HabilitarEdicao(True);
  edtNome.SetFocus;
end;

procedure TfrmDistribuidorView.btnSalvarClick(Sender: TObject);
begin
  try
    SincronizarDistribuidorComTela;
    FDistribuidorAtual := FModule.Controller.Salvar(FDistribuidorAtual);

    ShowMessage('Distribuidor salvo com sucesso.');
    btnCancelarClick(Sender);
    CarregarDistribuidores;
  except
    on E: Exception do
      ShowMessage('Erro ao salvar: ' + E.Message);
  end;
end;

procedure TfrmDistribuidorView.CarregarDistribuidorNaTela(ADistribuidor: TDistribuidorEntity);
begin
  if not Assigned(ADistribuidor) then
    Exit;

  edtNome.Text := ADistribuidor.Nome;
  edtCnpj.Text := ADistribuidor.Cnpj;
end;

procedure TfrmDistribuidorView.dbgDistribuidoresCellClick(Column: TColumn);
var
  LId: string;
  LDistribuidor: TDistribuidorEntity;
begin
  if not Assigned(dsDistribuidor.DataSet) or dsDistribuidor.DataSet.IsEmpty then
    Exit;

  LId := dsDistribuidor.DataSet.FieldByName('id').AsString;
  if LId.IsEmpty then
    Exit;

  FreeAndNil(FDistribuidorAtual);
  LDistribuidor := FModule.Controller.BuscarPorId(LId);
  FDistribuidorAtual := LDistribuidor;
  FDistribuidorAtual.State := esUpdate;
  CarregarDistribuidorNaTela(FDistribuidorAtual);
  HabilitarEdicao(True);
end;

procedure TfrmDistribuidorView.HabilitarEdicao(const AHabilitar: Boolean);
begin
  edtNome.Enabled := AHabilitar;
  edtCnpj.Enabled := AHabilitar;
  btnSalvar.Enabled := AHabilitar;
  btnCancelar.Enabled := AHabilitar;
  btnNovo.Enabled := not AHabilitar;
  if AHabilitar and Assigned(FDistribuidorAtual) and (FDistribuidorAtual.State = esUpdate) then
    btnExcluir.Enabled := True
  else if not AHabilitar then
    btnExcluir.Enabled := (dsDistribuidor.DataSet <> nil) and (not dsDistribuidor.DataSet.IsEmpty)
  else
    btnExcluir.Enabled := False;

  if AHabilitar then
    AtivarCadastro
  else
    AtivarConsulta;
end;

procedure TfrmDistribuidorView.LimparCampos;
begin
  edtNome.Clear;
  edtCnpj.Clear;
end;

procedure TfrmDistribuidorView.SincronizarDistribuidorComTela;
begin
  if not Assigned(FDistribuidorAtual) then
    Exit;

  FDistribuidorAtual.Nome := Trim(edtNome.Text);
  FDistribuidorAtual.Cnpj := Trim(edtCnpj.Text);
end;

procedure TfrmDistribuidorView.AtivarCadastro;
begin
  if Assigned(pgcMain) and Assigned(tabCadastro) then
    pgcMain.ActivePage := tabCadastro;
end;

procedure TfrmDistribuidorView.AtivarConsulta;
begin
  if Assigned(pgcMain) and Assigned(tabConsulta) then
    pgcMain.ActivePage := tabConsulta;
end;

end.

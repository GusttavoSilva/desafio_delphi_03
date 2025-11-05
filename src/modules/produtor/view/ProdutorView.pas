unit ProdutorView;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.DBGrids, Data.DB, System.Generics.Collections, FireDAC.Comp.Client,
  ProdutorEntity, ProdutorModule, ConnectionDataBase, Vcl.Grids, Vcl.ComCtrls,
  System.UITypes;

type
  TfrmProdutorView = class(TForm)
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
    dbgProdutores: TDBGrid;
    pnlCadastro: TPanel;
    lblNome: TLabel;
    edtNome: TEdit;
    lblCpfCnpj: TLabel;
    edtCpfCnpj: TEdit;
    dsProdutor: TDataSource;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnNovoClick(Sender: TObject);
    procedure btnSalvarClick(Sender: TObject);
    procedure btnExcluirClick(Sender: TObject);
    procedure btnCancelarClick(Sender: TObject);
    procedure btnAtualizarClick(Sender: TObject);
    procedure btnFecharClick(Sender: TObject);
    procedure dbgProdutoresCellClick(Column: TColumn);
  private
    FProdutorModule: TProdutorModule;
    FProdutorAtual: TProdutorEntity;
    FProdutores: TObjectList<TProdutorEntity>;
    FDataSet: TFDMemTable;
    
    procedure CarregarProdutores;
    procedure PreencherGrid;
    procedure LimparCampos;
    procedure HabilitarEdicao(const AHabilitar: Boolean);
    procedure CarregarProdutorNaTela(AProdutor: TProdutorEntity);
    procedure SincronizarProdutorComTela;
    procedure InicializarDataSet;
    procedure AtivarConsulta;
    procedure AtivarCadastro;
  public
    { Public declarations }
  end;

var
  frmProdutorView: TfrmProdutorView;

implementation

uses
  GsBaseEntity;

{$R *.dfm}

{ TfrmProdutorView }

procedure TfrmProdutorView.FormCreate(Sender: TObject);
begin
  dmConnection.Connect;
  FProdutorModule := TProdutorModule.Create(dmConnection.FDConnection);
  FProdutores := TObjectList<TProdutorEntity>.Create(True);
  FDataSet := TFDMemTable.Create(nil);
  dsProdutor.DataSet := FDataSet;
  InicializarDataSet;
  FProdutorAtual := nil;

  HabilitarEdicao(False);
  CarregarProdutores;
end;

procedure TfrmProdutorView.FormDestroy(Sender: TObject);
begin
  FDataSet.Free;
  FProdutores.Free;
  FProdutorModule.Free;
  FProdutorAtual.Free;
end;

procedure TfrmProdutorView.CarregarProdutores;
var
  LLista: TObjectList<TProdutorEntity>;
  LItem: TProdutorEntity;
begin
  LLista := FProdutorModule.Controller.ListarTodos;
  try
    FProdutores.Clear;
    for LItem in LLista do
      FProdutores.Add(LItem);
    LLista.OwnsObjects := False;
  finally
    LLista.Free;
  end;
  PreencherGrid;
end;

procedure TfrmProdutorView.PreencherGrid;
var
  LProdutor: TProdutorEntity;
begin
  FDataSet.DisableControls;
  try
    FDataSet.EmptyDataSet;
    for LProdutor in FProdutores do
    begin
      FDataSet.Append;
      FDataSet.FieldByName('id').AsString := LProdutor.Id;
      FDataSet.FieldByName('nome').AsString := LProdutor.Nome;
      FDataSet.FieldByName('cpf_cnpj').AsString := LProdutor.CpfCnpj;
      FDataSet.FieldByName('data_criacao').AsDateTime := LProdutor.CreatedAt;
      FDataSet.Post;
    end;
  finally
    FDataSet.EnableControls;
  end;

  btnExcluir.Enabled := (dsProdutor.DataSet <> nil) and (not dsProdutor.DataSet.IsEmpty);
end;

procedure TfrmProdutorView.btnNovoClick(Sender: TObject);
begin
  LimparCampos;
  HabilitarEdicao(True);

  FreeAndNil(FProdutorAtual);
  FProdutorAtual := TProdutorEntity.Create;
  FProdutorAtual.State := esInsert;

  edtNome.SetFocus;
end;

procedure TfrmProdutorView.btnSalvarClick(Sender: TObject);
begin
  try
    SincronizarProdutorComTela;
    FProdutorAtual := FProdutorModule.Controller.Salvar(FProdutorAtual);

    ShowMessage('Produtor salvo com sucesso!');

    btnCancelarClick(Sender);
    CarregarProdutores;
  except
    on E: Exception do
      ShowMessage('Erro ao salvar: ' + E.Message);
  end;
end;

procedure TfrmProdutorView.btnExcluirClick(Sender: TObject);
begin
  if not Assigned(FProdutorAtual) then
  begin
    ShowMessage('Selecione um produtor para excluir.');
    Exit;
  end;
  
  if MessageDlg('Deseja realmente excluir este produtor?', 
                mtConfirmation, [mbYes, mbNo], 0) = mrYes then
  begin
    try
  FProdutorModule.Controller.Excluir(FProdutorAtual);
  ShowMessage('Produtor exclu�do com sucesso!');

  LimparCampos;
  HabilitarEdicao(False);
  CarregarProdutores;
    except
      on E: Exception do
        ShowMessage('Erro ao excluir: ' + E.Message);
    end;
  end;
end;

procedure TfrmProdutorView.btnCancelarClick(Sender: TObject);
begin
  LimparCampos;
  HabilitarEdicao(False);
  FreeAndNil(FProdutorAtual);
end;

procedure TfrmProdutorView.dbgProdutoresCellClick(Column: TColumn);
var
  LId: string;
begin
  if not Assigned(dsProdutor.DataSet) or dsProdutor.DataSet.IsEmpty then
    Exit;

  LId := dsProdutor.DataSet.FieldByName('id').AsString;
  if LId.IsEmpty then
    Exit;

  try
    FreeAndNil(FProdutorAtual);
    FProdutorAtual := FProdutorModule.Controller.BuscarPorId(LId);

    if Assigned(FProdutorAtual) then
    begin
      FProdutorAtual.State := esUpdate;
      CarregarProdutorNaTela(FProdutorAtual);
      HabilitarEdicao(True);
    end;
  except
    on E: Exception do
      ShowMessage('Erro ao carregar produtor: ' + E.Message);
  end;
end;

procedure TfrmProdutorView.LimparCampos;
begin
  edtNome.Clear;
  edtCpfCnpj.Clear;
end;

procedure TfrmProdutorView.HabilitarEdicao(const AHabilitar: Boolean);
var
  LTemItens: Boolean;
begin
  edtNome.Enabled := AHabilitar;
  edtCpfCnpj.Enabled := AHabilitar;
  btnSalvar.Enabled := AHabilitar;
  btnCancelar.Enabled := AHabilitar;
  btnNovo.Enabled := not AHabilitar;

  LTemItens := (dsProdutor.DataSet <> nil) and (not dsProdutor.DataSet.IsEmpty);
  if AHabilitar then
    btnExcluir.Enabled := Assigned(FProdutorAtual) and (FProdutorAtual.State = esUpdate)
  else
    btnExcluir.Enabled := LTemItens;
  btnAtualizar.Enabled := not AHabilitar;

  if AHabilitar then
    AtivarCadastro
  else
    AtivarConsulta;
end;

procedure TfrmProdutorView.CarregarProdutorNaTela(AProdutor: TProdutorEntity);
begin
  if not Assigned(AProdutor) then
    Exit;
    
  edtNome.Text := AProdutor.Nome;
  edtCpfCnpj.Text := AProdutor.CpfCnpj;
end;

procedure TfrmProdutorView.InicializarDataSet;
begin
  FDataSet.Close;
  FDataSet.FieldDefs.Clear;
  FDataSet.FieldDefs.Add('id', ftString, 38);
  FDataSet.FieldDefs.Add('nome', ftString, 255);
  FDataSet.FieldDefs.Add('cpf_cnpj', ftString, 18);
  FDataSet.FieldDefs.Add('data_criacao', ftDateTime);
  FDataSet.CreateDataSet;
end;

procedure TfrmProdutorView.AtivarCadastro;
begin
  if Assigned(pgcMain) and Assigned(tabCadastro) then
    pgcMain.ActivePage := tabCadastro;
end;

procedure TfrmProdutorView.AtivarConsulta;
begin
  if Assigned(pgcMain) and Assigned(tabConsulta) then
    pgcMain.ActivePage := tabConsulta;
end;

procedure TfrmProdutorView.btnAtualizarClick(Sender: TObject);
begin
  CarregarProdutores;
end;

procedure TfrmProdutorView.btnFecharClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmProdutorView.SincronizarProdutorComTela;
begin
  if not Assigned(FProdutorAtual) then
    Exit;

  FProdutorAtual.Nome := Trim(edtNome.Text);
  FProdutorAtual.CpfCnpj := Trim(edtCpfCnpj.Text);
end;

end.

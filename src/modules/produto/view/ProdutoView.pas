unit ProdutoView;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, System.UITypes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.DBGrids, Data.DB, System.Generics.Collections, FireDAC.Comp.Client,
  ProdutoEntity, ProdutoModule, ConnectionDataBase, Vcl.Grids, Vcl.ComCtrls;

type
  TfrmProdutoView = class(TForm)
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
    dbgProdutos: TDBGrid;
    pnlCadastro: TPanel;
    lblNome: TLabel;
    edtNome: TEdit;
    lblPrecoVenda: TLabel;
    edtPrecoVenda: TEdit;
    dsProduto: TDataSource;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnNovoClick(Sender: TObject);
    procedure btnSalvarClick(Sender: TObject);
    procedure btnExcluirClick(Sender: TObject);
    procedure btnCancelarClick(Sender: TObject);
    procedure btnAtualizarClick(Sender: TObject);
    procedure btnFecharClick(Sender: TObject);
    procedure dbgProdutosCellClick(Column: TColumn);
  private
    FProdutoModule: TProdutoModule;
    FProdutoAtual: TProdutoEntity;
    FProdutos: TObjectList<TProdutoEntity>;
    FDataSet: TFDMemTable;
    
    procedure CarregarProdutos;
    procedure PreencherGrid;
    procedure LimparCampos;
    procedure HabilitarEdicao(const AHabilitar: Boolean);
    procedure CarregarProdutoNaTela(AProduto: TProdutoEntity);
    procedure SincronizarProdutoComTela;
    procedure InicializarDataSet;
    procedure AtivarCadastro;
    procedure AtivarConsulta;
  public
  end;

var
  frmProdutoView: TfrmProdutoView;

implementation

uses
  GsBaseEntity, GsValidation;

{$R *.dfm}

{ TfrmProdutoView }

procedure TfrmProdutoView.FormCreate(Sender: TObject);
begin
  dmConnection.Connect;
  FProdutoModule := TProdutoModule.Create(dmConnection.FDConnection);
  FProdutos := TObjectList<TProdutoEntity>.Create(True);
  FDataSet := TFDMemTable.Create(nil);
  dsProduto.DataSet := FDataSet;
  InicializarDataSet;
  FProdutoAtual := nil;

  HabilitarEdicao(False);
  CarregarProdutos;
end;

procedure TfrmProdutoView.FormDestroy(Sender: TObject);
begin
  FDataSet.Free;
  FProdutos.Free;
  FProdutoModule.Free;
  FProdutoAtual.Free;
end;

procedure TfrmProdutoView.CarregarProdutos;
var
  LLista: TObjectList<TProdutoEntity>;
  LItem: TProdutoEntity;
begin
  LLista := FProdutoModule.Controller.ListarTodos;
  try
    FProdutos.Clear;
    for LItem in LLista do
      FProdutos.Add(LItem);
    LLista.OwnsObjects := False;
  finally
    LLista.Free;
  end;
  PreencherGrid;
end;

procedure TfrmProdutoView.PreencherGrid;
var
  LProduto: TProdutoEntity;
begin
  FDataSet.DisableControls;
  try
    FDataSet.EmptyDataSet;
    for LProduto in FProdutos do
    begin
      FDataSet.Append;
      FDataSet.FieldByName('id').AsString := LProduto.Id;
      FDataSet.FieldByName('nome').AsString := LProduto.Nome;
      FDataSet.FieldByName('preco_venda').AsCurrency := LProduto.PrecoVenda;
      FDataSet.FieldByName('data_criacao').AsDateTime := LProduto.CreatedAt;
      FDataSet.Post;
    end;
  finally
    FDataSet.EnableControls;
  end;

  btnExcluir.Enabled := (dsProduto.DataSet <> nil) and (not dsProduto.DataSet.IsEmpty);
end;

procedure TfrmProdutoView.btnNovoClick(Sender: TObject);
begin
  LimparCampos;
  HabilitarEdicao(True);

  FreeAndNil(FProdutoAtual);
  FProdutoAtual := TProdutoEntity.Create;
  FProdutoAtual.State := esInsert;

  edtNome.SetFocus;
end;

procedure TfrmProdutoView.btnSalvarClick(Sender: TObject);
begin
  try
    SincronizarProdutoComTela;
    FProdutoAtual := FProdutoModule.Controller.Salvar(FProdutoAtual);

    ShowMessage('Produto salvo com sucesso!');

    btnCancelarClick(Sender);
    CarregarProdutos;
  except
    on E: Exception do
      ShowMessage('Erro ao salvar: ' + E.Message);
  end;
end;

procedure TfrmProdutoView.btnExcluirClick(Sender: TObject);
begin
  if not Assigned(FProdutoAtual) then
  begin
    ShowMessage('Selecione um produto para excluir.');
    Exit;
  end;
  
  if MessageDlg('Deseja realmente excluir este produto?',
                mtConfirmation, [mbYes, mbNo], 0) = mrYes then
  begin
    try
      FProdutoModule.Controller.Excluir(FProdutoAtual);
      ShowMessage('Produto excluído com sucesso!');

      LimparCampos;
      HabilitarEdicao(False);
      CarregarProdutos;
    except
      on E: Exception do
        ShowMessage('Erro ao excluir: ' + E.Message);
    end;
  end;
end;

procedure TfrmProdutoView.btnCancelarClick(Sender: TObject);
begin
  LimparCampos;
  HabilitarEdicao(False);
  FreeAndNil(FProdutoAtual);
end;

procedure TfrmProdutoView.dbgProdutosCellClick(Column: TColumn);
var
  LId: string;
begin
  if not Assigned(dsProduto.DataSet) or dsProduto.DataSet.IsEmpty then
    Exit;

  LId := dsProduto.DataSet.FieldByName('id').AsString;
  if LId.IsEmpty then
    Exit;

  try
    FreeAndNil(FProdutoAtual);
    FProdutoAtual := FProdutoModule.Controller.BuscarPorId(LId);

    if Assigned(FProdutoAtual) then
    begin
      FProdutoAtual.State := esUpdate;
      CarregarProdutoNaTela(FProdutoAtual);
      HabilitarEdicao(True);
    end;
  except
    on E: Exception do
      ShowMessage('Erro ao carregar produto: ' + E.Message);
  end;
end;

procedure TfrmProdutoView.LimparCampos;
begin
  edtNome.Clear;
  edtPrecoVenda.Text := '0,00';
end;

procedure TfrmProdutoView.HabilitarEdicao(const AHabilitar: Boolean);
var
  LTemItens: Boolean;
begin
  edtNome.Enabled := AHabilitar;
  edtPrecoVenda.Enabled := AHabilitar;
  btnSalvar.Enabled := AHabilitar;
  btnCancelar.Enabled := AHabilitar;
  btnNovo.Enabled := not AHabilitar;

  LTemItens := (dsProduto.DataSet <> nil) and (not dsProduto.DataSet.IsEmpty);
  if AHabilitar then
    btnExcluir.Enabled := Assigned(FProdutoAtual) and (FProdutoAtual.State = esUpdate)
  else
    btnExcluir.Enabled := LTemItens;
  btnAtualizar.Enabled := not AHabilitar;

  if AHabilitar then
    AtivarCadastro
  else
    AtivarConsulta;
end;

procedure TfrmProdutoView.CarregarProdutoNaTela(AProduto: TProdutoEntity);
begin
  if not Assigned(AProduto) then
    Exit;
    
  edtNome.Text := AProduto.Nome;
  edtPrecoVenda.Text := FormatFloat('#,##0.00', AProduto.PrecoVenda);
end;

procedure TfrmProdutoView.InicializarDataSet;
begin
  FDataSet.Close;
  FDataSet.FieldDefs.Clear;
  FDataSet.FieldDefs.Add('id', ftString, 38);
  FDataSet.FieldDefs.Add('nome', ftString, 80);
  FDataSet.FieldDefs.Add('preco_venda', ftCurrency);
  FDataSet.FieldDefs.Add('data_criacao', ftDateTime);
  FDataSet.CreateDataSet;
end;

procedure TfrmProdutoView.AtivarCadastro;
begin
  pgcMain.ActivePage := tabCadastro;
end;

procedure TfrmProdutoView.AtivarConsulta;
begin
  pgcMain.ActivePage := tabConsulta;
end;

procedure TfrmProdutoView.btnAtualizarClick(Sender: TObject);
begin
  CarregarProdutos;
end;

procedure TfrmProdutoView.btnFecharClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmProdutoView.SincronizarProdutoComTela;
begin
  if not Assigned(FProdutoAtual) then
    Exit;

  FProdutoAtual.Nome := Trim(edtNome.Text);
  FProdutoAtual.PrecoVenda := TgsValidation.TratarValorMonetario(edtPrecoVenda.Text);
end;

end.

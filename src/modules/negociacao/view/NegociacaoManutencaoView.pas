unit NegociacaoManutencaoView;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.DBGrids, Data.DB, System.Generics.Collections, FireDAC.Comp.Client,
  NegociacaoEntity, NegociacaoModule, ProdutorModule, DistribuidorModule,
  ConnectionDataBase, Vcl.Grids, System.UITypes;

type
  TfrmNegociacaoManutencaoView = class(TForm)
    pnlTop: TPanel;
    lblTitulo: TLabel;
    pnlFiltros: TPanel;
    lblFiltro: TLabel;
    cboNegociacoes: TComboBox;
    btnCarregar: TButton;
    btnLimpar: TButton;
    grpDados: TGroupBox;
    lblCodigo: TLabel;
    edtCodigo: TEdit;
    lblProdutor: TLabel;
    edtProdutor: TEdit;
    lblDistribuidor: TLabel;
    edtDistribuidor: TEdit;
    lblValorTotal: TLabel;
    edtValorTotal: TEdit;
    lblStatusAtual: TLabel;
    edtStatusAtual: TEdit;
    lblDataCadastro: TLabel;
    edtDataCadastro: TEdit;
    pnlAcoes: TPanel;
    btnAprovar: TButton;
    btnConcluir: TButton;
    btnCancelar: TButton;
    btnFechar: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure cboNegociacoesChange(Sender: TObject);
    procedure btnCarregarClick(Sender: TObject);
    procedure btnLimparClick(Sender: TObject);
    procedure btnAprovarClick(Sender: TObject);
    procedure btnConcluirClick(Sender: TObject);
    procedure btnCancelarClick(Sender: TObject);
    procedure btnFecharClick(Sender: TObject);
  private
    FNegociacaoModule: TNegociacaoModule;
    FProdutorModule: TProdutorModule;
    FDistribuidorModule: TDistribuidorModule;
    FNegociacaoAtual: TNegociacaoEntity;
    FNegociacoes: TObjectList<TNegociacaoEntity>;
    
    procedure LimparDados;
    procedure CarregarListaNegociacoes;
    procedure CarregarNegociacao(const AId: string);
    procedure HabilitarBotoes(const AStatus: TNegociacaoStatus);
    procedure AtualizarStatus(ANovoStatus: TNegociacaoStatus);
  public
  end;

var
  frmNegociacaoManutencaoView: TfrmNegociacaoManutencaoView;

implementation

uses
  GsBaseEntity, ProdutorEntity, DistribuidorEntity;

{$R *.dfm}

{ TfrmNegociacaoManutencaoView }

procedure TfrmNegociacaoManutencaoView.FormCreate(Sender: TObject);
begin
  dmConnection.Connect;
  FNegociacaoModule := TNegociacaoModule.Create(dmConnection.FDConnection);
  FProdutorModule := TProdutorModule.Create(dmConnection.FDConnection);
  FDistribuidorModule := TDistribuidorModule.Create(dmConnection.FDConnection);
  FNegociacaoAtual := nil;
  FNegociacoes := TObjectList<TNegociacaoEntity>.Create(True);
  
  LimparDados;
  HabilitarBotoes(nsPendente);
  CarregarListaNegociacoes;
end;

procedure TfrmNegociacaoManutencaoView.FormDestroy(Sender: TObject);
begin
  FNegociacaoAtual.Free;
  FNegociacoes.Free;
  FNegociacaoModule.Free;
  FProdutorModule.Free;
  FDistribuidorModule.Free;
end;

procedure TfrmNegociacaoManutencaoView.CarregarListaNegociacoes;
var
  LLista: TObjectList<TNegociacaoEntity>;
  LItem: TNegociacaoEntity;
  LProdutor: TProdutorEntity;
  LDistribuidor: TDistribuidorEntity;
  LDescricao: string;
begin
  cboNegociacoes.Clear;
  FNegociacoes.Clear;
  
  LLista := FNegociacaoModule.Controller.ListarTodos;
  try
    for LItem in LLista do
    begin
      FNegociacoes.Add(LItem);
      
      // Montar descrição para o combo: "ID - Produtor - Distribuidor - Status - Valor"
      LDescricao := Copy(LItem.Id, 1, 8) + '... - ';
      
      // Buscar nome do produtor
      LProdutor := FProdutorModule.Controller.BuscarPorId(LItem.ProdutorId);
      if Assigned(LProdutor) then
      begin
        LDescricao := LDescricao + LProdutor.Nome + ' - ';
        LProdutor.Free;
      end;
      
      // Buscar nome do distribuidor
      LDistribuidor := FDistribuidorModule.Controller.BuscarPorId(LItem.DistribuidorId);
      if Assigned(LDistribuidor) then
      begin
        LDescricao := LDescricao + LDistribuidor.Nome + ' - ';
        LDistribuidor.Free;
      end;
      
      LDescricao := LDescricao + LItem.Status + ' - R$ ' + FormatFloat('#,##0.00', LItem.ValorTotal);
      
      cboNegociacoes.Items.AddObject(LDescricao, Pointer(FNegociacoes.Count - 1));
    end;
    LLista.OwnsObjects := False;
  finally
    LLista.Free;
  end;
end;

procedure TfrmNegociacaoManutencaoView.cboNegociacoesChange(Sender: TObject);
begin
  // Evento disparado quando muda a seleção
  // Não faz nada aqui, usuário deve clicar em Carregar
end;

procedure TfrmNegociacaoManutencaoView.btnCarregarClick(Sender: TObject);
var
  LIdx: Integer;
  LId: string;
begin
  if cboNegociacoes.ItemIndex < 0 then
  begin
    ShowMessage('Selecione uma negociação.');
    cboNegociacoes.SetFocus;
    Exit;
  end;
  
  try
    LIdx := Integer(cboNegociacoes.Items.Objects[cboNegociacoes.ItemIndex]);
    LId := FNegociacoes[LIdx].Id;
    CarregarNegociacao(LId);
  except
    on E: Exception do
    begin
      ShowMessage('Erro ao carregar negociação: ' + E.Message);
      LimparDados;
    end;
  end;
end;


procedure TfrmNegociacaoManutencaoView.CarregarNegociacao(const AId: string);
var
  LProdutor: TProdutorEntity;
  LDistribuidor: TDistribuidorEntity;
begin
  FreeAndNil(FNegociacaoAtual);
  
  FNegociacaoAtual := FNegociacaoModule.Controller.BuscarPorId(AId);
  
  if not Assigned(FNegociacaoAtual) then
  begin
    ShowMessage('Negociação não encontrada.');
    LimparDados;
    Exit;
  end;
  
  // Preencher dados
  edtCodigo.Text := FNegociacaoAtual.Id;
  edtStatusAtual.Text := FNegociacaoAtual.Status;
  edtValorTotal.Text := FormatFloat('R$ #,##0.00', FNegociacaoAtual.ValorTotal);
  edtDataCadastro.Text := DateTimeToStr(FNegociacaoAtual.DataCadastro);
  
  // Buscar nome do produtor
  LProdutor := FProdutorModule.Controller.BuscarPorId(FNegociacaoAtual.ProdutorId);
  if Assigned(LProdutor) then
  begin
    try
      edtProdutor.Text := LProdutor.Nome;
    finally
      LProdutor.Free;
    end;
  end;
  
  // Buscar nome do distribuidor
  LDistribuidor := FDistribuidorModule.Controller.BuscarPorId(FNegociacaoAtual.DistribuidorId);
  if Assigned(LDistribuidor) then
  begin
    try
      edtDistribuidor.Text := LDistribuidor.Nome;
    finally
      LDistribuidor.Free;
    end;
  end;
  
  HabilitarBotoes(FNegociacaoAtual.StatusEnum);
end;

procedure TfrmNegociacaoManutencaoView.LimparDados;
begin
  edtCodigo.Clear;
  edtProdutor.Clear;
  edtDistribuidor.Clear;
  edtValorTotal.Clear;
  edtStatusAtual.Clear;
  edtDataCadastro.Clear;
  
  FreeAndNil(FNegociacaoAtual);
  HabilitarBotoes(nsPendente);
end;

procedure TfrmNegociacaoManutencaoView.btnLimparClick(Sender: TObject);
begin
  cboNegociacoes.ItemIndex := -1;
  LimparDados;
  cboNegociacoes.SetFocus;
end;

procedure TfrmNegociacaoManutencaoView.HabilitarBotoes(const AStatus: TNegociacaoStatus);
begin
  // Regras:
  // Pendente -> pode Aprovar ou Cancelar
  // Aprovada -> pode Concluir ou Cancelar
  // Concluída -> nenhuma ação
  // Cancelada -> nenhuma ação
  
  case AStatus of
    nsPendente:
    begin
      btnAprovar.Enabled := True;
      btnConcluir.Enabled := False;
      btnCancelar.Enabled := True;
    end;
    
    nsAprovada:
    begin
      btnAprovar.Enabled := False;
      btnConcluir.Enabled := True;
      btnCancelar.Enabled := True;
    end;
    
    nsConcluida, nsCancelada:
    begin
      btnAprovar.Enabled := False;
      btnConcluir.Enabled := False;
      btnCancelar.Enabled := False;
    end;
  end;
end;

procedure TfrmNegociacaoManutencaoView.btnAprovarClick(Sender: TObject);
begin
  if not Assigned(FNegociacaoAtual) then
  begin
    ShowMessage('Nenhuma negociação carregada.');
    Exit;
  end;
  
  if MessageDlg('Deseja aprovar esta negociação?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
  begin
    try
      AtualizarStatus(nsAprovada);
      ShowMessage('Negociação aprovada com sucesso!');
      CarregarNegociacao(FNegociacaoAtual.Id);
    except
      on E: Exception do
        ShowMessage('Erro ao aprovar negociação: ' + E.Message);
    end;
  end;
end;

procedure TfrmNegociacaoManutencaoView.btnConcluirClick(Sender: TObject);
begin
  if not Assigned(FNegociacaoAtual) then
  begin
    ShowMessage('Nenhuma negociação carregada.');
    Exit;
  end;
  
  if MessageDlg('Deseja concluir esta negociação?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
  begin
    try
      AtualizarStatus(nsConcluida);
      ShowMessage('Negociação concluída com sucesso!');
      CarregarNegociacao(FNegociacaoAtual.Id);
    except
      on E: Exception do
        ShowMessage('Erro ao concluir negociação: ' + E.Message);
    end;
  end;
end;

procedure TfrmNegociacaoManutencaoView.btnCancelarClick(Sender: TObject);
begin
  if not Assigned(FNegociacaoAtual) then
  begin
    ShowMessage('Nenhuma negociação carregada.');
    Exit;
  end;
  
  if MessageDlg('Deseja cancelar esta negociação?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
  begin
    try
      AtualizarStatus(nsCancelada);
      ShowMessage('Negociação cancelada com sucesso!');
      CarregarNegociacao(FNegociacaoAtual.Id);
    except
      on E: Exception do
        ShowMessage('Erro ao cancelar negociação: ' + E.Message);
    end;
  end;
end;

procedure TfrmNegociacaoManutencaoView.AtualizarStatus(ANovoStatus: TNegociacaoStatus);
const
  CStatusStrings: array[TNegociacaoStatus] of string = ('PENDENTE', 'APROVADA', 'CONCLUIDA', 'CANCELADA');
var
  LDataRef: TDateTime;
begin
  if not Assigned(FNegociacaoAtual) then
    Exit;
  
  LDataRef := Now;
  FNegociacaoModule.Controller.AtualizarStatus(
    FNegociacaoAtual.Id,
    CStatusStrings[ANovoStatus],
    LDataRef
  );
end;

procedure TfrmNegociacaoManutencaoView.btnFecharClick(Sender: TObject);
begin
  Close;
end;

end.

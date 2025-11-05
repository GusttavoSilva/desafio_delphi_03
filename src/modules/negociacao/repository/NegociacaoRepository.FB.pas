unit NegociacaoRepository.FB;

interface

uses
  System.SysUtils,
  System.Generics.Collections,
  FireDAC.Comp.Client,
  FireDAC.Stan.Param,
  Data.DB,
  NegociacaoRepository.Intf,
  NegociacaoEntity,
  NegociacaoItemEntity;

type
  TNegociacaoRepositoryFB = class(TInterfacedObject, INegociacaoRepository)
  private
    FConnection: TFDConnection;
    function MapResultToEntity(AQuery: TFDQuery): TNegociacaoEntity;
    procedure MapOptionalDates(AEntity: TNegociacaoEntity; AQuery: TFDQuery);
    procedure CarregarItens(AEntity: TNegociacaoEntity);
  public
    constructor Create(AConnection: TFDConnection);

    function ObterTodos: TObjectList<TNegociacaoEntity>;
    function ObterPorId(const AId: string): TNegociacaoEntity;
  function ObterTotalAprovado(const AProdutorId, ADistribuidorId, AIgnorarNegociacaoId: string): Currency;
    procedure Inserir(const AEntity: TNegociacaoEntity);
    procedure Atualizar(const AEntity: TNegociacaoEntity);
    procedure AtualizarStatus(const AId, AStatus: string; const ADataReferencia: TDateTime);
    procedure Excluir(const AId: string);
  end;

implementation

uses
  GsBaseEntity;

{ TNegociacaoRepositoryFB }

constructor TNegociacaoRepositoryFB.Create(AConnection: TFDConnection);
begin
  inherited Create;
  FConnection := AConnection;
end;

procedure TNegociacaoRepositoryFB.MapOptionalDates(AEntity: TNegociacaoEntity; AQuery: TFDQuery);
begin
  if AQuery.FieldByName('data_aprovacao').IsNull then
    AEntity.DataAprovacao := 0
  else
    AEntity.DataAprovacao := AQuery.FieldByName('data_aprovacao').AsDateTime;

  if AQuery.FieldByName('data_conclusao').IsNull then
    AEntity.DataConclusao := 0
  else
    AEntity.DataConclusao := AQuery.FieldByName('data_conclusao').AsDateTime;

  if AQuery.FieldByName('data_cancelamento').IsNull then
    AEntity.DataCancelamento := 0
  else
    AEntity.DataCancelamento := AQuery.FieldByName('data_cancelamento').AsDateTime;
end;

function TNegociacaoRepositoryFB.MapResultToEntity(AQuery: TFDQuery): TNegociacaoEntity;
begin
  Result := TNegociacaoEntity.Create;
  try
    Result.Id := AQuery.FieldByName('id').AsString;
    Result.ProdutorId := AQuery.FieldByName('produtor_id').AsString;
    Result.DistribuidorId := AQuery.FieldByName('distribuidor_id').AsString;
    Result.ValorTotal := AQuery.FieldByName('valor_total').AsCurrency;
    Result.Status := AQuery.FieldByName('status').AsString;
    Result.DataCadastro := AQuery.FieldByName('data_cadastro').AsDateTime;
    MapOptionalDates(Result, AQuery);
    Result.CreatedAt := Result.DataCadastro;
    Result.UpdatedAt := AQuery.FieldByName('data_cadastro').AsDateTime;
    Result.State := esUpdate;
    CarregarItens(Result);
  except
    Result.Free;
    raise;
  end;
end;

procedure TNegociacaoRepositoryFB.CarregarItens(AEntity: TNegociacaoEntity);
var
  LQuery: TFDQuery;
  LItem: TNegociacaoItemEntity;
begin
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := FConnection;
    LQuery.SQL.Text :=
      'SELECT id, negociacao_id, produto_id, quantidade, preco_unitario, subtotal ' +
      'FROM negociacao_item WHERE negociacao_id = :negociacao_id';
    LQuery.ParamByName('negociacao_id').AsString := AEntity.Id;
    LQuery.Open;
    
    while not LQuery.Eof do
    begin
      LItem := TNegociacaoItemEntity.Create;
      try
        LItem.Id := LQuery.FieldByName('id').AsString;
        LItem.NegociacaoId := LQuery.FieldByName('negociacao_id').AsString;
        LItem.ProdutoId := LQuery.FieldByName('produto_id').AsString;
        LItem.Quantidade := LQuery.FieldByName('quantidade').AsFloat;
        LItem.PrecoUnitario := LQuery.FieldByName('preco_unitario').AsCurrency;
        LItem.Subtotal := LQuery.FieldByName('subtotal').AsCurrency;
        LItem.State := esUpdate;
        
        AEntity.AdicionarItem(LItem);
      except
        LItem.Free;
        raise;
      end;
      LQuery.Next;
    end;
  finally
    LQuery.Free;
  end;
end;

function TNegociacaoRepositoryFB.ObterTodos: TObjectList<TNegociacaoEntity>;
var
  LQuery: TFDQuery;
begin
  Result := TObjectList<TNegociacaoEntity>.Create(True);
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := FConnection;
    LQuery.SQL.Text :=
      'SELECT id, produtor_id, distribuidor_id, valor_total, status, data_cadastro, ' +
      'data_aprovacao, data_conclusao, data_cancelamento ' +
      'FROM negociacao ' +
      'ORDER BY data_cadastro DESC';
    LQuery.Open;
    while not LQuery.Eof do
    begin
      Result.Add(MapResultToEntity(LQuery));
      LQuery.Next;
    end;
  finally
    LQuery.Free;
  end;
end;

function TNegociacaoRepositoryFB.ObterPorId(const AId: string): TNegociacaoEntity;
var
  LQuery: TFDQuery;
begin
  Result := nil;
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := FConnection;
    LQuery.SQL.Text :=
      'SELECT id, produtor_id, distribuidor_id, valor_total, status, data_cadastro, ' +
      'data_aprovacao, data_conclusao, data_cancelamento ' +
      'FROM negociacao WHERE id = :id';
    LQuery.ParamByName('id').AsString := AId;
    LQuery.Open;
    if not LQuery.IsEmpty then
      Result := MapResultToEntity(LQuery);
  finally
    LQuery.Free;
  end;
end;

function TNegociacaoRepositoryFB.ObterTotalAprovado(const AProdutorId, ADistribuidorId, AIgnorarNegociacaoId: string): Currency;
var
  LQuery: TFDQuery;
begin
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := FConnection;
    LQuery.SQL.Text :=
      'SELECT COALESCE(SUM(valor_total), 0) AS total '
      + 'FROM negociacao '
      + 'WHERE status = ''APROVADA'' '
      + 'AND produtor_id = :produtor_id '
      + 'AND distribuidor_id = :distribuidor_id';

    if not AIgnorarNegociacaoId.Trim.IsEmpty then
      LQuery.SQL.Add('AND id <> :id_ignore');

    LQuery.ParamByName('produtor_id').AsString := AProdutorId;
    LQuery.ParamByName('distribuidor_id').AsString := ADistribuidorId;

    if not AIgnorarNegociacaoId.Trim.IsEmpty then
      LQuery.ParamByName('id_ignore').AsString := AIgnorarNegociacaoId;

    LQuery.Open;
    Result := LQuery.FieldByName('total').AsCurrency;
  finally
    LQuery.Free;
  end;
end;

procedure TNegociacaoRepositoryFB.Inserir(const AEntity: TNegociacaoEntity);
var
  LQuery: TFDQuery;
begin
  AEntity.BeforeSave;
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := FConnection;
    LQuery.SQL.Text :=
      'INSERT INTO negociacao ' +
      '(id, produtor_id, distribuidor_id, valor_total, status, data_cadastro, data_aprovacao, data_conclusao, data_cancelamento) ' +
      'VALUES (:id, :produtor_id, :distribuidor_id, :valor_total, :status, :data_cadastro, :data_aprovacao, :data_conclusao, :data_cancelamento)';
    LQuery.ParamByName('id').AsString := AEntity.Id;
    LQuery.ParamByName('produtor_id').AsString := AEntity.ProdutorId;
    LQuery.ParamByName('distribuidor_id').AsString := AEntity.DistribuidorId;
    LQuery.ParamByName('valor_total').AsCurrency := AEntity.ValorTotal;
    LQuery.ParamByName('status').AsString := AEntity.Status;
    LQuery.ParamByName('data_cadastro').AsDateTime := AEntity.DataCadastro;

    if AEntity.DataAprovacao = 0 then
      LQuery.ParamByName('data_aprovacao').Clear
    else
      LQuery.ParamByName('data_aprovacao').AsDateTime := AEntity.DataAprovacao;

    if AEntity.DataConclusao = 0 then
      LQuery.ParamByName('data_conclusao').Clear
    else
      LQuery.ParamByName('data_conclusao').AsDateTime := AEntity.DataConclusao;

    if AEntity.DataCancelamento = 0 then
      LQuery.ParamByName('data_cancelamento').Clear
    else
      LQuery.ParamByName('data_cancelamento').AsDateTime := AEntity.DataCancelamento;

    LQuery.ExecSQL;
    AEntity.AfterSave;
  finally
    LQuery.Free;
  end;
end;

procedure TNegociacaoRepositoryFB.Atualizar(const AEntity: TNegociacaoEntity);
var
  LQuery: TFDQuery;
begin
  AEntity.BeforeSave;
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := FConnection;
    LQuery.SQL.Text :=
      'UPDATE negociacao SET ' +
      'produtor_id = :produtor_id, distribuidor_id = :distribuidor_id, valor_total = :valor_total, ' +
      'status = :status, data_cadastro = :data_cadastro, ' +
      'data_aprovacao = :data_aprovacao, data_conclusao = :data_conclusao, data_cancelamento = :data_cancelamento ' +
      'WHERE id = :id';
    LQuery.ParamByName('id').AsString := AEntity.Id;
    LQuery.ParamByName('produtor_id').AsString := AEntity.ProdutorId;
    LQuery.ParamByName('distribuidor_id').AsString := AEntity.DistribuidorId;
    LQuery.ParamByName('valor_total').AsCurrency := AEntity.ValorTotal;
    LQuery.ParamByName('status').AsString := AEntity.Status;
    LQuery.ParamByName('data_cadastro').AsDateTime := AEntity.DataCadastro;

    if AEntity.DataAprovacao = 0 then
      LQuery.ParamByName('data_aprovacao').Clear
    else
      LQuery.ParamByName('data_aprovacao').AsDateTime := AEntity.DataAprovacao;

    if AEntity.DataConclusao = 0 then
      LQuery.ParamByName('data_conclusao').Clear
    else
      LQuery.ParamByName('data_conclusao').AsDateTime := AEntity.DataConclusao;

    if AEntity.DataCancelamento = 0 then
      LQuery.ParamByName('data_cancelamento').Clear
    else
      LQuery.ParamByName('data_cancelamento').AsDateTime := AEntity.DataCancelamento;

    LQuery.ExecSQL;
    AEntity.AfterSave;
  finally
    LQuery.Free;
  end;
end;

procedure TNegociacaoRepositoryFB.AtualizarStatus(const AId, AStatus: string; const ADataReferencia: TDateTime);
var
  LQuery: TFDQuery;
begin
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := FConnection;
    LQuery.SQL.Text :=
      'UPDATE negociacao SET status = :status, ' +
      'data_aprovacao = CASE WHEN :status = ''APROVADA'' THEN :data_ref_aprovacao ELSE data_aprovacao END, ' +
      'data_conclusao = CASE WHEN :status = ''CONCLUIDA'' THEN :data_ref_conclusao ELSE data_conclusao END, ' +
      'data_cancelamento = CASE WHEN :status = ''CANCELADA'' THEN :data_ref_cancelamento ELSE data_cancelamento END ' +
      'WHERE id = :id';
    LQuery.ParamByName('id').AsString := AId;
    LQuery.ParamByName('status').AsString := AStatus;
    
    // Usar a mesma data para todos os parâmetros
    if ADataReferencia = 0 then
    begin
      LQuery.ParamByName('data_ref_aprovacao').Clear;
      LQuery.ParamByName('data_ref_conclusao').Clear;
      LQuery.ParamByName('data_ref_cancelamento').Clear;
    end
    else
    begin
      LQuery.ParamByName('data_ref_aprovacao').AsDateTime := ADataReferencia;
      LQuery.ParamByName('data_ref_conclusao').AsDateTime := ADataReferencia;
      LQuery.ParamByName('data_ref_cancelamento').AsDateTime := ADataReferencia;
    end;
    
    LQuery.ExecSQL;
  finally
    LQuery.Free;
  end;
end;

procedure TNegociacaoRepositoryFB.Excluir(const AId: string);
var
  LQuery: TFDQuery;
begin
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := FConnection;
    LQuery.SQL.Text := 'DELETE FROM negociacao WHERE id = :id';
    LQuery.ParamByName('id').AsString := AId;
    LQuery.ExecSQL;
  finally
    LQuery.Free;
  end;
end;

end.

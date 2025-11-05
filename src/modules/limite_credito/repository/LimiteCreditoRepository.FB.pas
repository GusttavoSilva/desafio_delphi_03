unit LimiteCreditoRepository.FB;

interface

uses
  System.SysUtils,
  System.Generics.Collections,
  FireDAC.Comp.Client,
  FireDAC.Stan.Param,
  Data.DB,
  LimiteCreditoRepository.Intf,
  LimiteCreditoEntity;

type
  TLimiteCreditoRepositoryFB = class(TInterfacedObject, ILimiteCreditoRepository)
  private
    FConnection: TFDConnection;
    function MapResultToEntity(AQuery: TFDQuery): TLimiteCreditoEntity;
  public
    constructor Create(AConnection: TFDConnection);

    function ObterTodos: TObjectList<TLimiteCreditoEntity>;
    function ObterPorId(const AId: string): TLimiteCreditoEntity;
    function ObterPorRelacionamento(const AProdutorId, ADistribuidorId: string): TLimiteCreditoEntity;
    procedure Inserir(const AEntity: TLimiteCreditoEntity);
    procedure Atualizar(const AEntity: TLimiteCreditoEntity);
    procedure Excluir(const AId: string);
  end;

implementation

uses
  GsBaseEntity;

{ TLimiteCreditoRepositoryFB }

constructor TLimiteCreditoRepositoryFB.Create(AConnection: TFDConnection);
begin
  inherited Create;
  FConnection := AConnection;
end;

function TLimiteCreditoRepositoryFB.MapResultToEntity(AQuery: TFDQuery): TLimiteCreditoEntity;
begin
  Result := TLimiteCreditoEntity.Create;
  try
    Result.Id := AQuery.FieldByName('id').AsString;
    Result.ProdutorId := AQuery.FieldByName('produtor_id').AsString;
    Result.DistribuidorId := AQuery.FieldByName('distribuidor_id').AsString;
    Result.Limite := AQuery.FieldByName('limite').AsCurrency;
    Result.CreatedAt := AQuery.FieldByName('data_criacao').AsDateTime;
    Result.UpdatedAt := AQuery.FieldByName('data_atualizacao').AsDateTime;
    Result.State := esUpdate;
  except
    Result.Free;
    raise;
  end;
end;

function TLimiteCreditoRepositoryFB.ObterTodos: TObjectList<TLimiteCreditoEntity>;
var
  LQuery: TFDQuery;
begin
  Result := TObjectList<TLimiteCreditoEntity>.Create(True);
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := FConnection;
    LQuery.SQL.Text :=
      'SELECT id, produtor_id, distribuidor_id, limite, data_criacao, data_atualizacao ' +
      'FROM limite_credito ' +
      'ORDER BY data_criacao DESC';
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

function TLimiteCreditoRepositoryFB.ObterPorId(const AId: string): TLimiteCreditoEntity;
var
  LQuery: TFDQuery;
begin
  Result := nil;
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := FConnection;
    LQuery.SQL.Text :=
      'SELECT id, produtor_id, distribuidor_id, limite, data_criacao, data_atualizacao ' +
      'FROM limite_credito WHERE id = :id';
    LQuery.ParamByName('id').AsString := AId;
    LQuery.Open;
    if not LQuery.IsEmpty then
      Result := MapResultToEntity(LQuery);
  finally
    LQuery.Free;
  end;
end;

function TLimiteCreditoRepositoryFB.ObterPorRelacionamento(const AProdutorId, ADistribuidorId: string): TLimiteCreditoEntity;
var
  LQuery: TFDQuery;
begin
  Result := nil;
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := FConnection;
    LQuery.SQL.Text :=
      'SELECT id, produtor_id, distribuidor_id, limite, data_criacao, data_atualizacao ' +
      'FROM limite_credito ' +
      'WHERE produtor_id = :produtor_id AND distribuidor_id = :distribuidor_id';
    LQuery.ParamByName('produtor_id').AsString := AProdutorId;
    LQuery.ParamByName('distribuidor_id').AsString := ADistribuidorId;
    LQuery.Open;
    if not LQuery.IsEmpty then
      Result := MapResultToEntity(LQuery);
  finally
    LQuery.Free;
  end;
end;

procedure TLimiteCreditoRepositoryFB.Inserir(const AEntity: TLimiteCreditoEntity);
var
  LQuery: TFDQuery;
begin
  AEntity.BeforeSave;
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := FConnection;
    LQuery.SQL.Text :=
      'INSERT INTO limite_credito ' +
      '(id, produtor_id, distribuidor_id, limite, data_criacao, data_atualizacao) ' +
      'VALUES (:id, :produtor_id, :distribuidor_id, :limite, :data_criacao, :data_atualizacao)';
    LQuery.ParamByName('id').AsString := AEntity.Id;
    LQuery.ParamByName('produtor_id').AsString := AEntity.ProdutorId;
    LQuery.ParamByName('distribuidor_id').AsString := AEntity.DistribuidorId;
    LQuery.ParamByName('limite').AsCurrency := AEntity.Limite;
    LQuery.ParamByName('data_criacao').AsDateTime := AEntity.CreatedAt;
    LQuery.ParamByName('data_atualizacao').AsDateTime := AEntity.UpdatedAt;
    LQuery.ExecSQL;
    AEntity.AfterSave;
  finally
    LQuery.Free;
  end;
end;

procedure TLimiteCreditoRepositoryFB.Atualizar(const AEntity: TLimiteCreditoEntity);
var
  LQuery: TFDQuery;
begin
  AEntity.BeforeSave;
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := FConnection;
    LQuery.SQL.Text :=
      'UPDATE limite_credito ' +
      'SET produtor_id = :produtor_id, distribuidor_id = :distribuidor_id, limite = :limite, data_atualizacao = :data_atualizacao ' +
      'WHERE id = :id';
    LQuery.ParamByName('id').AsString := AEntity.Id;
    LQuery.ParamByName('produtor_id').AsString := AEntity.ProdutorId;
    LQuery.ParamByName('distribuidor_id').AsString := AEntity.DistribuidorId;
    LQuery.ParamByName('limite').AsCurrency := AEntity.Limite;
    LQuery.ParamByName('data_atualizacao').AsDateTime := Now;
    LQuery.ExecSQL;
    AEntity.AfterSave;
  finally
    LQuery.Free;
  end;
end;

procedure TLimiteCreditoRepositoryFB.Excluir(const AId: string);
var
  LQuery: TFDQuery;
begin
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := FConnection;
    LQuery.SQL.Text := 'DELETE FROM limite_credito WHERE id = :id';
    LQuery.ParamByName('id').AsString := AId;
    LQuery.ExecSQL;
  finally
    LQuery.Free;
  end;
end;

end.

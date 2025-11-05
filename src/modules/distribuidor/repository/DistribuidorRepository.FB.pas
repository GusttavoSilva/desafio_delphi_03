unit DistribuidorRepository.FB;

interface

uses
  System.SysUtils,
  System.Generics.Collections,
  FireDAC.Comp.Client,
  FireDAC.Stan.Param,
  Data.DB,
  DistribuidorRepository.Intf,
  DistribuidorEntity;

type
  TDistribuidorRepositoryFB = class(TInterfacedObject, IDistribuidorRepository)
  private
    FConnection: TFDConnection;
    function MapResultToEntity(AQuery: TFDQuery): TDistribuidorEntity;
  public
    constructor Create(AConnection: TFDConnection);

    function FindAll: TObjectList<TDistribuidorEntity>;
    function FindById(const AId: string): TDistribuidorEntity;
    function FindByCnpj(const ACnpj: string): TDistribuidorEntity;
    function Insert(AEntity: TDistribuidorEntity): TDistribuidorEntity;
    function Update(AEntity: TDistribuidorEntity): TDistribuidorEntity;
    function Delete(AEntity: TDistribuidorEntity): Boolean;
  end;

implementation

uses
  GsBaseEntity;

{ TDistribuidorRepositoryFB }

constructor TDistribuidorRepositoryFB.Create(AConnection: TFDConnection);
begin
  inherited Create;
  FConnection := AConnection;
end;

function TDistribuidorRepositoryFB.MapResultToEntity(AQuery: TFDQuery): TDistribuidorEntity;
begin
  Result := TDistribuidorEntity.Create;
  try
    Result.Id := AQuery.FieldByName('id').AsString;
    Result.Nome := AQuery.FieldByName('nome').AsString;
    Result.Cnpj := AQuery.FieldByName('cnpj').AsString;
    Result.CreatedAt := AQuery.FieldByName('data_criacao').AsDateTime;
    Result.UpdatedAt := AQuery.FieldByName('data_atualizacao').AsDateTime;
    Result.State := esUpdate;
  except
    Result.Free;
    raise;
  end;
end;

function TDistribuidorRepositoryFB.FindAll: TObjectList<TDistribuidorEntity>;
var
  LQuery: TFDQuery;
  LEntity: TDistribuidorEntity;
begin
  Result := TObjectList<TDistribuidorEntity>.Create(True);
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := FConnection;
    LQuery.SQL.Text :=
      'SELECT id, nome, cnpj, data_criacao, data_atualizacao ' +
      'FROM distribuidor ' +
      'ORDER BY nome';
    LQuery.Open;
    while not LQuery.Eof do
    begin
      LEntity := MapResultToEntity(LQuery);
      Result.Add(LEntity);
      LQuery.Next;
    end;
  finally
    LQuery.Free;
  end;
end;

function TDistribuidorRepositoryFB.FindById(const AId: string): TDistribuidorEntity;
var
  LQuery: TFDQuery;
begin
  Result := nil;
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := FConnection;
    LQuery.SQL.Text :=
      'SELECT id, nome, cnpj, data_criacao, data_atualizacao ' +
      'FROM distribuidor ' +
      'WHERE id = :id';
    LQuery.ParamByName('id').AsString := AId;
    LQuery.Open;
    if not LQuery.IsEmpty then
      Result := MapResultToEntity(LQuery);
  finally
    LQuery.Free;
  end;
end;

function TDistribuidorRepositoryFB.FindByCnpj(const ACnpj: string): TDistribuidorEntity;
var
  LQuery: TFDQuery;
begin
  Result := nil;
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := FConnection;
    LQuery.SQL.Text :=
      'SELECT id, nome, cnpj, data_criacao, data_atualizacao ' +
      'FROM distribuidor ' +
      'WHERE cnpj = :cnpj';
    LQuery.ParamByName('cnpj').AsString := ACnpj;
    LQuery.Open;
    if not LQuery.IsEmpty then
      Result := MapResultToEntity(LQuery);
  finally
    LQuery.Free;
  end;
end;

function TDistribuidorRepositoryFB.Insert(AEntity: TDistribuidorEntity): TDistribuidorEntity;
var
  LQuery: TFDQuery;
begin
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := FConnection;
    AEntity.BeforeSave;
    LQuery.SQL.Text :=
      'INSERT INTO distribuidor (id, nome, cnpj, data_criacao, data_atualizacao) ' +
      'VALUES (:id, :nome, :cnpj, :data_criacao, :data_atualizacao)';
    LQuery.ParamByName('id').AsString := AEntity.Id;
    LQuery.ParamByName('nome').AsString := AEntity.Nome;
    LQuery.ParamByName('cnpj').AsString := AEntity.Cnpj;
    LQuery.ParamByName('data_criacao').AsDateTime := AEntity.CreatedAt;
    LQuery.ParamByName('data_atualizacao').AsDateTime := AEntity.UpdatedAt;
    LQuery.ExecSQL;
    AEntity.AfterSave;
    Result := AEntity;
  finally
    LQuery.Free;
  end;
end;

function TDistribuidorRepositoryFB.Update(AEntity: TDistribuidorEntity): TDistribuidorEntity;
var
  LQuery: TFDQuery;
begin
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := FConnection;
    AEntity.BeforeSave;
    LQuery.SQL.Text :=
      'UPDATE distribuidor SET ' +
      '  nome = :nome, ' +
      '  cnpj = :cnpj, ' +
      '  data_atualizacao = :data_atualizacao ' +
      'WHERE id = :id';
    LQuery.ParamByName('id').AsString := AEntity.Id;
    LQuery.ParamByName('nome').AsString := AEntity.Nome;
    LQuery.ParamByName('cnpj').AsString := AEntity.Cnpj;
    LQuery.ParamByName('data_atualizacao').AsDateTime := Now;
    LQuery.ExecSQL;
    AEntity.AfterSave;
    Result := AEntity;
  finally
    LQuery.Free;
  end;
end;

function TDistribuidorRepositoryFB.Delete(AEntity: TDistribuidorEntity): Boolean;
var
  LQuery: TFDQuery;
begin
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := FConnection;
    LQuery.SQL.Text := 'DELETE FROM distribuidor WHERE id = :id';
    LQuery.ParamByName('id').AsString := AEntity.Id;
    LQuery.ExecSQL;
    Result := True;
  finally
    LQuery.Free;
  end;
end;

end.

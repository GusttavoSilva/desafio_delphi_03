unit ProdutorRepository.FB;

interface

uses
  System.SysUtils,
  System.Generics.Collections,
  FireDAC.Comp.Client,
  FireDAC.Stan.Param,
  Data.DB,
  ProdutorRepository.Intf,
  ProdutorEntity;

type
  TProdutorRepositoryFB = class(TInterfacedObject, IProdutorRepository)
  private
    FConnection: TFDConnection;
    function MapResultToEntity(AQuery: TFDQuery): TProdutorEntity;
  public
    constructor Create(AConnection: TFDConnection);
    
    // Implementação da interface
    function FindAll: TObjectList<TProdutorEntity>;
    function FindByDocument(const ADocumento: string): TProdutorEntity;
    function FindById(const AId: string): TProdutorEntity;
    function Insert(AEntity: TProdutorEntity): TProdutorEntity;
    function Update(AEntity: TProdutorEntity): TProdutorEntity;
    function Delete(AEntity: TProdutorEntity): Boolean;
  end;

implementation

uses
  GsBaseEntity;

{ TProdutorRepositoryFB }

constructor TProdutorRepositoryFB.Create(AConnection: TFDConnection);
begin
  inherited Create;
  FConnection := AConnection;
end;

function TProdutorRepositoryFB.MapResultToEntity(AQuery: TFDQuery): TProdutorEntity;
begin
  Result := TProdutorEntity.Create;
  try
    Result.Id := AQuery.FieldByName('id').AsString;
    Result.Nome := AQuery.FieldByName('nome').AsString;
    Result.CpfCnpj := AQuery.FieldByName('cpf_cnpj').AsString;
    Result.CreatedAt := AQuery.FieldByName('data_criacao').AsDateTime;
    Result.UpdatedAt := AQuery.FieldByName('data_atualizacao').AsDateTime;
    Result.State := esUpdate; // Registro já existe no banco
  except
    Result.Free;
    raise;
  end;
end;

function TProdutorRepositoryFB.FindAll: TObjectList<TProdutorEntity>;
var
  LQuery: TFDQuery;
  LProdutor: TProdutorEntity;
begin
  Result := TObjectList<TProdutorEntity>.Create(True);
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := FConnection;
    LQuery.SQL.Text := 
      'SELECT id, nome, cpf_cnpj, data_criacao, data_atualizacao ' +
      'FROM produtor ' +
      'ORDER BY nome';
    
    LQuery.Open;
    
    while not LQuery.Eof do
    begin
      LProdutor := MapResultToEntity(LQuery);
      Result.Add(LProdutor);
      LQuery.Next;
    end;
  finally
    LQuery.Free;
  end;
end;

function TProdutorRepositoryFB.FindByDocument(const ADocumento: string): TProdutorEntity;
var
  LQuery: TFDQuery;
begin
  Result := nil;
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := FConnection;
    LQuery.SQL.Text := 
      'SELECT id, nome, cpf_cnpj, data_criacao, data_atualizacao ' +
      'FROM produtor ' +
      'WHERE cpf_cnpj = :cpf_cnpj';
    
    LQuery.ParamByName('cpf_cnpj').AsString := ADocumento;
    LQuery.Open;
    
    if not LQuery.IsEmpty then
      Result := MapResultToEntity(LQuery);
  finally
    LQuery.Free;
  end;
end;

function TProdutorRepositoryFB.FindById(const AId: string): TProdutorEntity;
var
  LQuery: TFDQuery;
begin
  Result := nil;
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := FConnection;
    LQuery.SQL.Text := 
      'SELECT id, nome, cpf_cnpj, data_criacao, data_atualizacao ' +
      'FROM produtor ' +
      'WHERE id = :id';
    
    LQuery.ParamByName('id').AsString := AId;
    LQuery.Open;
    
    if not LQuery.IsEmpty then
      Result := MapResultToEntity(LQuery);
  finally
    LQuery.Free;
  end;
end;

function TProdutorRepositoryFB.Insert(AEntity: TProdutorEntity): TProdutorEntity;
var
  LQuery: TFDQuery;
begin
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := FConnection;
    
    // Chama validações antes de inserir
    AEntity.BeforeSave;
    
    LQuery.SQL.Text := 
  'INSERT INTO produtor (id, nome, cpf_cnpj, data_criacao, data_atualizacao) ' +
      'VALUES (:id, :nome, :cpf_cnpj, :data_criacao, :data_atualizacao)';
    
    LQuery.ParamByName('id').AsString := AEntity.Id;
    LQuery.ParamByName('nome').AsString := AEntity.Nome;
    LQuery.ParamByName('cpf_cnpj').AsString := AEntity.CpfCnpj;
    LQuery.ParamByName('data_criacao').AsDateTime := AEntity.CreatedAt;
    LQuery.ParamByName('data_atualizacao').AsDateTime := AEntity.UpdatedAt;
    
    LQuery.ExecSQL;
    
    AEntity.AfterSave;
    Result := AEntity;
  finally
    LQuery.Free;
  end;
end;

function TProdutorRepositoryFB.Update(AEntity: TProdutorEntity): TProdutorEntity;
var
  LQuery: TFDQuery;
begin
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := FConnection;
    
    // Chama validações antes de atualizar
    AEntity.BeforeSave;
    
    LQuery.SQL.Text := 
  'UPDATE produtor SET ' +
      '  nome = :nome, ' +
      '  cpf_cnpj = :cpf_cnpj, ' +
      '  data_atualizacao = :data_atualizacao ' +
      'WHERE id = :id';
    
    LQuery.ParamByName('id').AsString := AEntity.Id;
    LQuery.ParamByName('nome').AsString := AEntity.Nome;
    LQuery.ParamByName('cpf_cnpj').AsString := AEntity.CpfCnpj;
    LQuery.ParamByName('data_atualizacao').AsDateTime := Now;
    
    LQuery.ExecSQL;
    
    AEntity.AfterSave;
    Result := AEntity;
  finally
    LQuery.Free;
  end;
end;

function TProdutorRepositoryFB.Delete(AEntity: TProdutorEntity): Boolean;
var
  LQuery: TFDQuery;
begin
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := FConnection;
  LQuery.SQL.Text := 'DELETE FROM produtor WHERE id = :id';
    LQuery.ParamByName('id').AsString := AEntity.Id;
    LQuery.ExecSQL;
    Result := True;
  finally
    LQuery.Free;
  end;
end;

end.

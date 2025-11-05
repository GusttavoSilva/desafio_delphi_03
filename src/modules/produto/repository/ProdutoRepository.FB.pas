unit ProdutoRepository.FB;

interface

uses
  System.SysUtils,
  System.Generics.Collections,
  FireDAC.Comp.Client,
  FireDAC.Stan.Param,
  Data.DB,
  ProdutoRepository.Intf,
  ProdutoEntity, GsBaseEntity;

type
  TProdutoRepositoryFB = class(TInterfacedObject, IProdutoRepository)
  private
    FConnection: TFDConnection;
    function MapResultToEntity(AQuery: TFDQuery): TProdutoEntity;
  public
    constructor Create(AConnection: TFDConnection);

    function ObterTodos: TObjectList<TProdutoEntity>;
    function ObterPorId(const AId: string): TProdutoEntity;
    procedure Inserir(const AEntity: TProdutoEntity);
    procedure Atualizar(const AEntity: TProdutoEntity);
    procedure Excluir(const AId: string);
  end;

implementation

{ TProdutoRepositoryFB }

constructor TProdutoRepositoryFB.Create(AConnection: TFDConnection);
begin
  inherited Create;
  FConnection := AConnection;
end;

procedure MapDates(AEntity: TProdutoEntity; AQuery: TFDQuery);
begin
  AEntity.CreatedAt := AQuery.FieldByName('data_criacao').AsDateTime;
  AEntity.UpdatedAt := AQuery.FieldByName('data_atualizacao').AsDateTime;
end;

function TProdutoRepositoryFB.MapResultToEntity(AQuery: TFDQuery): TProdutoEntity;
begin
  Result := TProdutoEntity.Create;
  try
    Result.Id := AQuery.FieldByName('id').AsString;
    Result.Nome := AQuery.FieldByName('nome').AsString;
    Result.PrecoVenda := AQuery.FieldByName('preco_venda').AsCurrency;
    MapDates(Result, AQuery);
    Result.State := esUpdate;
  except
    Result.Free;
    raise;
  end;
end;

function TProdutoRepositoryFB.ObterTodos: TObjectList<TProdutoEntity>;
var
  LQuery: TFDQuery;
begin
  Result := TObjectList<TProdutoEntity>.Create(True);
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := FConnection;
    LQuery.SQL.Text :=
      'SELECT id, nome, preco_venda, data_criacao, data_atualizacao ' +
      'FROM produto ' +
      'ORDER BY nome';
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

function TProdutoRepositoryFB.ObterPorId(const AId: string): TProdutoEntity;
var
  LQuery: TFDQuery;
begin
  Result := nil;
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := FConnection;
    LQuery.SQL.Text :=
      'SELECT id, nome, preco_venda, data_criacao, data_atualizacao ' +
      'FROM produto ' +
      'WHERE id = :id';
    LQuery.ParamByName('id').AsString := AId;
    LQuery.Open;
    if not LQuery.IsEmpty then
      Result := MapResultToEntity(LQuery);
  finally
    LQuery.Free;
  end;
end;

procedure TProdutoRepositoryFB.Inserir(const AEntity: TProdutoEntity);
var
  LQuery: TFDQuery;
begin
  AEntity.BeforeSave;
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := FConnection;
    LQuery.SQL.Text :=
      'INSERT INTO produto (id, nome, preco_venda, data_criacao, data_atualizacao) ' +
      'VALUES (:id, :nome, :preco_venda, :data_criacao, :data_atualizacao)';
    LQuery.ParamByName('id').AsString := AEntity.Id;
    LQuery.ParamByName('nome').AsString := AEntity.Nome;
    LQuery.ParamByName('preco_venda').AsCurrency := AEntity.PrecoVenda;
    LQuery.ParamByName('data_criacao').AsDateTime := AEntity.CreatedAt;
    LQuery.ParamByName('data_atualizacao').AsDateTime := AEntity.UpdatedAt;
    LQuery.ExecSQL;
    AEntity.AfterSave;
  finally
    LQuery.Free;
  end;
end;

procedure TProdutoRepositoryFB.Atualizar(const AEntity: TProdutoEntity);
var
  LQuery: TFDQuery;
begin
  AEntity.BeforeSave;
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := FConnection;
    LQuery.SQL.Text :=
      'UPDATE produto ' +
      'SET nome = :nome, preco_venda = :preco_venda, data_atualizacao = :data_atualizacao ' +
      'WHERE id = :id';
    LQuery.ParamByName('id').AsString := AEntity.Id;
    LQuery.ParamByName('nome').AsString := AEntity.Nome;
    LQuery.ParamByName('preco_venda').AsCurrency := AEntity.PrecoVenda;
    LQuery.ParamByName('data_atualizacao').AsDateTime := Now;
    LQuery.ExecSQL;
    AEntity.AfterSave;
  finally
    LQuery.Free;
  end;
end;

procedure TProdutoRepositoryFB.Excluir(const AId: string);
var
  LQuery: TFDQuery;
begin
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := FConnection;
    LQuery.SQL.Text := 'DELETE FROM produto WHERE id = :id';
    LQuery.ParamByName('id').AsString := AId;
    LQuery.ExecSQL;
  finally
    LQuery.Free;
  end;
end;

end.

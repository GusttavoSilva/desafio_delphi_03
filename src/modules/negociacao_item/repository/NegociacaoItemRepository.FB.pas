unit NegociacaoItemRepository.FB;

interface

uses
  System.SysUtils,
  System.Generics.Collections,
  FireDAC.Comp.Client,
  FireDAC.Stan.Param,
  Data.DB,
  NegociacaoItemRepository.Intf,
  NegociacaoItemEntity;

type
  TNegociacaoItemRepositoryFB = class(TInterfacedObject, INegociacaoItemRepository)
  private
    FConnection: TFDConnection;
    function MapResultToEntity(AQuery: TFDQuery): TNegociacaoItemEntity;
  public
    constructor Create(AConnection: TFDConnection);

    function ObterPorId(const AId: string): TNegociacaoItemEntity;
    function ObterPorNegociacao(const ANegociacaoId: string): TObjectList<TNegociacaoItemEntity>;
    procedure Inserir(const AEntity: TNegociacaoItemEntity);
    procedure Atualizar(const AEntity: TNegociacaoItemEntity);
    procedure Excluir(const AId: string);
    procedure ExcluirPorNegociacao(const ANegociacaoId: string);
  end;

implementation

uses
  GsBaseEntity;

{ TNegociacaoItemRepositoryFB }

constructor TNegociacaoItemRepositoryFB.Create(AConnection: TFDConnection);
begin
  inherited Create;
  FConnection := AConnection;
end;

function TNegociacaoItemRepositoryFB.MapResultToEntity(AQuery: TFDQuery): TNegociacaoItemEntity;
begin
  Result := TNegociacaoItemEntity.Create;
  try
    Result.Id := AQuery.FieldByName('id').AsString;
    Result.NegociacaoId := AQuery.FieldByName('negociacao_id').AsString;
    Result.ProdutoId := AQuery.FieldByName('produto_id').AsString;
    Result.Quantidade := AQuery.FieldByName('quantidade').AsFloat;
    Result.PrecoUnitario := AQuery.FieldByName('preco_unitario').AsCurrency;
    Result.Subtotal := AQuery.FieldByName('subtotal').AsCurrency;
    Result.State := esUpdate;
  except
    Result.Free;
    raise;
  end;
end;

function TNegociacaoItemRepositoryFB.ObterPorId(const AId: string): TNegociacaoItemEntity;
var
  LQuery: TFDQuery;
begin
  Result := nil;
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := FConnection;
    LQuery.SQL.Text :=
      'SELECT id, negociacao_id, produto_id, quantidade, preco_unitario, subtotal ' +
      'FROM negociacao_item WHERE id = :id';
    LQuery.ParamByName('id').AsString := AId;
    LQuery.Open;
    if not LQuery.IsEmpty then
      Result := MapResultToEntity(LQuery);
  finally
    LQuery.Free;
  end;
end;

function TNegociacaoItemRepositoryFB.ObterPorNegociacao(const ANegociacaoId: string): TObjectList<TNegociacaoItemEntity>;
var
  LQuery: TFDQuery;
begin
  Result := TObjectList<TNegociacaoItemEntity>.Create(True);
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := FConnection;
    LQuery.SQL.Text :=
      'SELECT id, negociacao_id, produto_id, quantidade, preco_unitario, subtotal ' +
      'FROM negociacao_item WHERE negociacao_id = :negociacao_id';
    LQuery.ParamByName('negociacao_id').AsString := ANegociacaoId;
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

procedure TNegociacaoItemRepositoryFB.Inserir(const AEntity: TNegociacaoItemEntity);
var
  LQuery: TFDQuery;
begin
  AEntity.BeforeSave;
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := FConnection;
    LQuery.SQL.Text :=
      'INSERT INTO negociacao_item ' +
      '(id, negociacao_id, produto_id, quantidade, preco_unitario, subtotal) ' +
      'VALUES (:id, :negociacao_id, :produto_id, :quantidade, :preco_unitario, :subtotal)';
    LQuery.ParamByName('id').AsString := AEntity.Id;
    LQuery.ParamByName('negociacao_id').AsString := AEntity.NegociacaoId;
    LQuery.ParamByName('produto_id').AsString := AEntity.ProdutoId;
    LQuery.ParamByName('quantidade').AsFloat := AEntity.Quantidade;
    LQuery.ParamByName('preco_unitario').AsCurrency := AEntity.PrecoUnitario;
    LQuery.ParamByName('subtotal').AsCurrency := AEntity.Subtotal;
    LQuery.ExecSQL;
    AEntity.AfterSave;
  finally
    LQuery.Free;
  end;
end;

procedure TNegociacaoItemRepositoryFB.Atualizar(const AEntity: TNegociacaoItemEntity);
var
  LQuery: TFDQuery;
begin
  AEntity.BeforeSave;
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := FConnection;
    LQuery.SQL.Text :=
      'UPDATE negociacao_item SET ' +
      'negociacao_id = :negociacao_id, produto_id = :produto_id, quantidade = :quantidade, ' +
      'preco_unitario = :preco_unitario, subtotal = :subtotal ' +
      'WHERE id = :id';
    LQuery.ParamByName('id').AsString := AEntity.Id;
    LQuery.ParamByName('negociacao_id').AsString := AEntity.NegociacaoId;
    LQuery.ParamByName('produto_id').AsString := AEntity.ProdutoId;
    LQuery.ParamByName('quantidade').AsFloat := AEntity.Quantidade;
    LQuery.ParamByName('preco_unitario').AsCurrency := AEntity.PrecoUnitario;
    LQuery.ParamByName('subtotal').AsCurrency := AEntity.Subtotal;
    LQuery.ExecSQL;
    AEntity.AfterSave;
  finally
    LQuery.Free;
  end;
end;

procedure TNegociacaoItemRepositoryFB.Excluir(const AId: string);
var
  LQuery: TFDQuery;
begin
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := FConnection;
    LQuery.SQL.Text := 'DELETE FROM negociacao_item WHERE id = :id';
    LQuery.ParamByName('id').AsString := AId;
    LQuery.ExecSQL;
  finally
    LQuery.Free;
  end;
end;

procedure TNegociacaoItemRepositoryFB.ExcluirPorNegociacao(const ANegociacaoId: string);
var
  LQuery: TFDQuery;
begin
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := FConnection;
    LQuery.SQL.Text := 'DELETE FROM negociacao_item WHERE negociacao_id = :negociacao_id';
    LQuery.ParamByName('negociacao_id').AsString := ANegociacaoId;
    LQuery.ExecSQL;
  finally
    LQuery.Free;
  end;
end;

end.

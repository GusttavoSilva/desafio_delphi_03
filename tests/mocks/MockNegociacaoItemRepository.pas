unit MockNegociacaoItemRepository;

interface

uses
  System.SysUtils,
  System.Generics.Collections,
  NegociacaoItemEntity,
  NegociacaoItemRepository.Intf;

type
  TMockNegociacaoItemRepository = class(TInterfacedObject, INegociacaoItemRepository)
  private
    FData: TObjectList<TNegociacaoItemEntity>;
    function FindById(const AId: string): TNegociacaoItemEntity;
    function CloneEntity(AEntity: TNegociacaoItemEntity): TNegociacaoItemEntity;
  public
    constructor Create;
    destructor Destroy; override;

    // Interface INegociacaoItemRepository
    function ObterTodos: TObjectList<TNegociacaoItemEntity>;
    function ObterPorId(const AId: string): TNegociacaoItemEntity;
    function ObterPorNegociacao(const ANegociacaoId: string): TObjectList<TNegociacaoItemEntity>;
    procedure Inserir(const AEntity: TNegociacaoItemEntity);
    procedure Atualizar(const AEntity: TNegociacaoItemEntity);
    procedure Excluir(const AId: string);
    procedure ExcluirPorNegociacao(const ANegociacaoId: string);

    // Métodos auxiliares para testes
    procedure Clear;
    procedure AddTestData(AEntity: TNegociacaoItemEntity);
    function Count: Integer;
  end;

implementation

uses
  GsBaseEntity;

{ TMockNegociacaoItemRepository }

constructor TMockNegociacaoItemRepository.Create;
begin
  inherited Create;
  FData := TObjectList<TNegociacaoItemEntity>.Create(True);
end;

destructor TMockNegociacaoItemRepository.Destroy;
begin
  FData.Free;
  inherited;
end;

procedure TMockNegociacaoItemRepository.Clear;
begin
  FData.Clear;
end;

procedure TMockNegociacaoItemRepository.AddTestData(AEntity: TNegociacaoItemEntity);
var
  LClone: TNegociacaoItemEntity;
begin
  LClone := CloneEntity(AEntity);
  FData.Add(LClone);
end;

function TMockNegociacaoItemRepository.Count: Integer;
begin
  Result := FData.Count;
end;

function TMockNegociacaoItemRepository.CloneEntity(AEntity: TNegociacaoItemEntity): TNegociacaoItemEntity;
begin
  Result := TNegociacaoItemEntity.Create;
  Result.Id := AEntity.Id;
  Result.NegociacaoId := AEntity.NegociacaoId;
  Result.ProdutoId := AEntity.ProdutoId;
  Result.Quantidade := AEntity.Quantidade;
  Result.PrecoUnitario := AEntity.PrecoUnitario;
  Result.Subtotal := AEntity.Subtotal;
  Result.CreatedAt := AEntity.CreatedAt;
  Result.UpdatedAt := AEntity.UpdatedAt;
  Result.State := AEntity.State;
end;

function TMockNegociacaoItemRepository.FindById(const AId: string): TNegociacaoItemEntity;
var
  LEntity: TNegociacaoItemEntity;
begin
  Result := nil;
  for LEntity in FData do
  begin
    if SameText(LEntity.Id, AId) then
    begin
      Result := LEntity;
      Break;
    end;
  end;
end;

function TMockNegociacaoItemRepository.ObterTodos: TObjectList<TNegociacaoItemEntity>;
var
  LEntity: TNegociacaoItemEntity;
  LClone: TNegociacaoItemEntity;
begin
  Result := TObjectList<TNegociacaoItemEntity>.Create(True);
  for LEntity in FData do
  begin
    LClone := CloneEntity(LEntity);
    Result.Add(LClone);
  end;
end;

function TMockNegociacaoItemRepository.ObterPorId(const AId: string): TNegociacaoItemEntity;
var
  LEntity: TNegociacaoItemEntity;
begin
  LEntity := FindById(AId);
  if Assigned(LEntity) then
    Result := CloneEntity(LEntity)
  else
    Result := nil;
end;

function TMockNegociacaoItemRepository.ObterPorNegociacao(const ANegociacaoId: string): TObjectList<TNegociacaoItemEntity>;
var
  LEntity: TNegociacaoItemEntity;
  LClone: TNegociacaoItemEntity;
begin
  Result := TObjectList<TNegociacaoItemEntity>.Create(True);
  for LEntity in FData do
  begin
    if SameText(LEntity.NegociacaoId, ANegociacaoId) then
    begin
      LClone := CloneEntity(LEntity);
      Result.Add(LClone);
    end;
  end;
end;

procedure TMockNegociacaoItemRepository.Inserir(const AEntity: TNegociacaoItemEntity);
var
  LClone: TNegociacaoItemEntity;
begin
  LClone := CloneEntity(AEntity);
  if LClone.Id = '' then
    LClone.Id := TGUID.NewGuid.ToString;
  LClone.CreatedAt := Now;
  LClone.UpdatedAt := Now;
  FData.Add(LClone);
  
  // Atualiza o ID na entidade original
  AEntity.Id := LClone.Id;
end;

procedure TMockNegociacaoItemRepository.Atualizar(const AEntity: TNegociacaoItemEntity);
var
  LExisting: TNegociacaoItemEntity;
  LIndex: Integer;
begin
  LExisting := FindById(AEntity.Id);
  if not Assigned(LExisting) then
    raise Exception.Create('Entidade não encontrada para atualização');

  LIndex := FData.IndexOf(LExisting);
  FData.Delete(LIndex);
  
  LExisting := CloneEntity(AEntity);
  LExisting.UpdatedAt := Now;
  FData.Insert(LIndex, LExisting);
end;

procedure TMockNegociacaoItemRepository.Excluir(const AId: string);
var
  LExisting: TNegociacaoItemEntity;
begin
  LExisting := FindById(AId);
  if not Assigned(LExisting) then
    raise Exception.Create('Entidade não encontrada para exclusão');
  FData.Remove(LExisting);
end;

procedure TMockNegociacaoItemRepository.ExcluirPorNegociacao(const ANegociacaoId: string);
var
  i: Integer;
begin
  for i := FData.Count - 1 downto 0 do
  begin
    if SameText(FData[i].NegociacaoId, ANegociacaoId) then
      FData.Delete(i);
  end;
end;

end.

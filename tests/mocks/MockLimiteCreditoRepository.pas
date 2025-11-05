unit MockLimiteCreditoRepository;

interface

uses
  System.SysUtils,
  System.Generics.Collections,
  LimiteCreditoEntity,
  LimiteCreditoRepository.Intf;

type
  TMockLimiteCreditoRepository = class(TInterfacedObject, ILimiteCreditoRepository)
  private
    FData: TObjectList<TLimiteCreditoEntity>;
    FRaiseErrorOnInserir: Boolean;
    FRaiseErrorOnAtualizar: Boolean;
    function FindById(const AId: string): TLimiteCreditoEntity;
    function CloneEntity(AEntity: TLimiteCreditoEntity): TLimiteCreditoEntity;
  public
    constructor Create;
    destructor Destroy; override;

    // Interface ILimiteCreditoRepository
    function ObterTodos: TObjectList<TLimiteCreditoEntity>;
    function ObterPorId(const AId: string): TLimiteCreditoEntity;
    function ObterPorRelacionamento(const AProdutorId, ADistribuidorId: string): TLimiteCreditoEntity;
    procedure Inserir(const AEntity: TLimiteCreditoEntity);
    procedure Atualizar(const AEntity: TLimiteCreditoEntity);
    procedure Excluir(const AId: string);

    // Métodos auxiliares para testes
    procedure Clear;
    procedure AddTestData(AEntity: TLimiteCreditoEntity);
    function Count: Integer;
    property RaiseErrorOnInserir: Boolean read FRaiseErrorOnInserir write FRaiseErrorOnInserir;
    property RaiseErrorOnAtualizar: Boolean read FRaiseErrorOnAtualizar write FRaiseErrorOnAtualizar;
  end;

implementation

uses
  GsBaseEntity;

{ TMockLimiteCreditoRepository }

constructor TMockLimiteCreditoRepository.Create;
begin
  inherited Create;
  FData := TObjectList<TLimiteCreditoEntity>.Create(True);
  FRaiseErrorOnInserir := False;
  FRaiseErrorOnAtualizar := False;
end;

destructor TMockLimiteCreditoRepository.Destroy;
begin
  FData.Free;
  inherited;
end;

procedure TMockLimiteCreditoRepository.Clear;
begin
  FData.Clear;
end;

procedure TMockLimiteCreditoRepository.AddTestData(AEntity: TLimiteCreditoEntity);
var
  LClone: TLimiteCreditoEntity;
begin
  LClone := CloneEntity(AEntity);
  FData.Add(LClone);
end;

function TMockLimiteCreditoRepository.Count: Integer;
begin
  Result := FData.Count;
end;

function TMockLimiteCreditoRepository.CloneEntity(AEntity: TLimiteCreditoEntity): TLimiteCreditoEntity;
begin
  Result := TLimiteCreditoEntity.Create;
  Result.Id := AEntity.Id;
  Result.ProdutorId := AEntity.ProdutorId;
  Result.DistribuidorId := AEntity.DistribuidorId;
  Result.Limite := AEntity.Limite;
  Result.CreatedAt := AEntity.CreatedAt;
  Result.UpdatedAt := AEntity.UpdatedAt;
  Result.State := AEntity.State;
end;

function TMockLimiteCreditoRepository.FindById(const AId: string): TLimiteCreditoEntity;
var
  LEntity: TLimiteCreditoEntity;
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

function TMockLimiteCreditoRepository.ObterTodos: TObjectList<TLimiteCreditoEntity>;
var
  LEntity: TLimiteCreditoEntity;
  LClone: TLimiteCreditoEntity;
begin
  Result := TObjectList<TLimiteCreditoEntity>.Create(True);
  for LEntity in FData do
  begin
    LClone := CloneEntity(LEntity);
    Result.Add(LClone);
  end;
end;

function TMockLimiteCreditoRepository.ObterPorId(const AId: string): TLimiteCreditoEntity;
var
  LEntity: TLimiteCreditoEntity;
begin
  LEntity := FindById(AId);
  if Assigned(LEntity) then
    Result := CloneEntity(LEntity)
  else
    Result := nil;
end;

function TMockLimiteCreditoRepository.ObterPorRelacionamento(
  const AProdutorId, ADistribuidorId: string): TLimiteCreditoEntity;
var
  LEntity: TLimiteCreditoEntity;
begin
  Result := nil;
  for LEntity in FData do
  begin
    if SameText(LEntity.ProdutorId, AProdutorId) and 
       SameText(LEntity.DistribuidorId, ADistribuidorId) then
    begin
      Result := CloneEntity(LEntity);
      Break;
    end;
  end;
end;

procedure TMockLimiteCreditoRepository.Inserir(const AEntity: TLimiteCreditoEntity);
var
  LClone: TLimiteCreditoEntity;
begin
  if FRaiseErrorOnInserir then
    raise Exception.Create('Erro simulado ao inserir');

  LClone := CloneEntity(AEntity);
  if LClone.Id = '' then
    LClone.Id := TGUID.NewGuid.ToString;
  LClone.CreatedAt := Now;
  LClone.UpdatedAt := Now;
  FData.Add(LClone);
  
  // Atualiza o ID na entidade original
  AEntity.Id := LClone.Id;
end;

procedure TMockLimiteCreditoRepository.Atualizar(const AEntity: TLimiteCreditoEntity);
var
  LExisting: TLimiteCreditoEntity;
  LIndex: Integer;
begin
  if FRaiseErrorOnAtualizar then
    raise Exception.Create('Erro simulado ao atualizar');

  LExisting := FindById(AEntity.Id);
  if not Assigned(LExisting) then
    raise Exception.Create('Entidade não encontrada para atualização');

  LIndex := FData.IndexOf(LExisting);
  FData.Delete(LIndex);
  
  LExisting := CloneEntity(AEntity);
  LExisting.UpdatedAt := Now;
  FData.Insert(LIndex, LExisting);
end;

procedure TMockLimiteCreditoRepository.Excluir(const AId: string);
var
  LExisting: TLimiteCreditoEntity;
begin
  LExisting := FindById(AId);
  if not Assigned(LExisting) then
    raise Exception.Create('Entidade não encontrada para exclusão');
  FData.Remove(LExisting);
end;

end.

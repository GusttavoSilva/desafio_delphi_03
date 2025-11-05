unit MockNegociacaoRepository;

interface

uses
  System.SysUtils,
  System.Generics.Collections,
  NegociacaoEntity,
  NegociacaoRepository.Intf;

type
  TMockNegociacaoRepository = class(TInterfacedObject, INegociacaoRepository)
  private
    FData: TObjectList<TNegociacaoEntity>;
    function FindById(const AId: string): TNegociacaoEntity;
    function CloneEntity(AEntity: TNegociacaoEntity): TNegociacaoEntity;
  public
    constructor Create;
    destructor Destroy; override;

    // Interface INegociacaoRepository
    function ObterTodos: TObjectList<TNegociacaoEntity>;
    function ObterPorId(const AId: string): TNegociacaoEntity;
    function ObterTotalAprovado(const AProdutorId, ADistribuidorId, AIgnorarNegociacaoId: string): Currency;
    procedure Inserir(const AEntity: TNegociacaoEntity);
    procedure Atualizar(const AEntity: TNegociacaoEntity);
    procedure AtualizarStatus(const AId, AStatus: string; const ADataReferencia: TDateTime);
    procedure Excluir(const AId: string);

    // Métodos auxiliares para testes
    procedure Clear;
    procedure AddTestData(AEntity: TNegociacaoEntity);
    function Count: Integer;
  end;

implementation

uses
  GsBaseEntity;

{ TMockNegociacaoRepository }

constructor TMockNegociacaoRepository.Create;
begin
  inherited Create;
  FData := TObjectList<TNegociacaoEntity>.Create(True);
end;

destructor TMockNegociacaoRepository.Destroy;
begin
  FData.Free;
  inherited;
end;

procedure TMockNegociacaoRepository.Clear;
begin
  FData.Clear;
end;

procedure TMockNegociacaoRepository.AddTestData(AEntity: TNegociacaoEntity);
var
  LClone: TNegociacaoEntity;
begin
  LClone := CloneEntity(AEntity);
  FData.Add(LClone);
end;

function TMockNegociacaoRepository.Count: Integer;
begin
  Result := FData.Count;
end;

function TMockNegociacaoRepository.CloneEntity(AEntity: TNegociacaoEntity): TNegociacaoEntity;
begin
  Result := TNegociacaoEntity.Create;
  Result.Id := AEntity.Id;
  Result.ProdutorId := AEntity.ProdutorId;
  Result.DistribuidorId := AEntity.DistribuidorId;
  Result.ValorTotal := AEntity.ValorTotal;
  Result.Status := AEntity.Status;
  Result.DataCadastro := AEntity.DataCadastro;
  Result.DataAprovacao := AEntity.DataAprovacao;
  Result.DataConclusao := AEntity.DataConclusao;
  Result.DataCancelamento := AEntity.DataCancelamento;
  Result.CreatedAt := AEntity.CreatedAt;
  Result.UpdatedAt := AEntity.UpdatedAt;
  Result.State := AEntity.State;
end;

function TMockNegociacaoRepository.FindById(const AId: string): TNegociacaoEntity;
var
  LEntity: TNegociacaoEntity;
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

function TMockNegociacaoRepository.ObterTodos: TObjectList<TNegociacaoEntity>;
var
  LEntity: TNegociacaoEntity;
  LClone: TNegociacaoEntity;
begin
  Result := TObjectList<TNegociacaoEntity>.Create(True);
  for LEntity in FData do
  begin
    LClone := CloneEntity(LEntity);
    Result.Add(LClone);
  end;
end;

function TMockNegociacaoRepository.ObterPorId(const AId: string): TNegociacaoEntity;
var
  LEntity: TNegociacaoEntity;
begin
  LEntity := FindById(AId);
  if Assigned(LEntity) then
    Result := CloneEntity(LEntity)
  else
    Result := nil;
end;

function TMockNegociacaoRepository.ObterTotalAprovado(
  const AProdutorId, ADistribuidorId, AIgnorarNegociacaoId: string): Currency;
var
  LEntity: TNegociacaoEntity;
begin
  Result := 0;
  for LEntity in FData do
  begin
    // Considerar apenas negociações aprovadas
    if SameText(LEntity.Status, 'APROVADA') and
       SameText(LEntity.ProdutorId, AProdutorId) and
       SameText(LEntity.DistribuidorId, ADistribuidorId) then
    begin
      // Se tiver ID para ignorar, pular se for o mesmo
      if not AIgnorarNegociacaoId.Trim.IsEmpty then
      begin
        if not SameText(LEntity.Id, AIgnorarNegociacaoId) then
          Result := Result + LEntity.ValorTotal;
      end
      else
        Result := Result + LEntity.ValorTotal;
    end;
  end;
end;

procedure TMockNegociacaoRepository.Inserir(const AEntity: TNegociacaoEntity);
var
  LClone: TNegociacaoEntity;
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

procedure TMockNegociacaoRepository.Atualizar(const AEntity: TNegociacaoEntity);
var
  LExisting: TNegociacaoEntity;
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

procedure TMockNegociacaoRepository.AtualizarStatus(const AId, AStatus: string; const ADataReferencia: TDateTime);
var
  LExisting: TNegociacaoEntity;
begin
  LExisting := FindById(AId);
  if not Assigned(LExisting) then
    raise Exception.Create('Entidade não encontrada para atualização de status');

  LExisting.Status := AStatus;
  
  if SameText(AStatus, 'APROVADA') then
    LExisting.DataAprovacao := ADataReferencia
  else if SameText(AStatus, 'CONCLUIDA') then
    LExisting.DataConclusao := ADataReferencia
  else if SameText(AStatus, 'CANCELADA') then
    LExisting.DataCancelamento := ADataReferencia;
  
  LExisting.UpdatedAt := Now;
end;

procedure TMockNegociacaoRepository.Excluir(const AId: string);
var
  LExisting: TNegociacaoEntity;
begin
  LExisting := FindById(AId);
  if not Assigned(LExisting) then
    raise Exception.Create('Entidade não encontrada para exclusão');
  FData.Remove(LExisting);
end;

end.

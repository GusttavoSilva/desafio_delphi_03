unit MockDistribuidorRepository;

interface

uses
  System.SysUtils,
  System.Generics.Collections,
  DistribuidorEntity,
  DistribuidorRepository.Intf;

type
  TMockDistribuidorRepository = class(TInterfacedObject, IDistribuidorRepository)
  private
    FData: TObjectList<TDistribuidorEntity>;
    function InternalFindById(const AId: string): TDistribuidorEntity;
    function CloneEntity(AEntity: TDistribuidorEntity): TDistribuidorEntity;
  public
    constructor Create;
    destructor Destroy; override;

    // Interface IDistribuidorRepository
    function FindAll: TObjectList<TDistribuidorEntity>;
    function FindById(const AId: string): TDistribuidorEntity;
    function FindByCnpj(const ACnpj: string): TDistribuidorEntity;
    function Insert(AEntity: TDistribuidorEntity): TDistribuidorEntity;
    function Update(AEntity: TDistribuidorEntity): TDistribuidorEntity;
    function Delete(AEntity: TDistribuidorEntity): Boolean;

    // Métodos auxiliares para testes
    procedure Clear;
    procedure AddTestData(AEntity: TDistribuidorEntity);
    function Count: Integer;
  end;

implementation

uses
  GsBaseEntity;

{ TMockDistribuidorRepository }

constructor TMockDistribuidorRepository.Create;
begin
  inherited Create;
  FData := TObjectList<TDistribuidorEntity>.Create(True);
end;

destructor TMockDistribuidorRepository.Destroy;
begin
  FData.Free;
  inherited;
end;

procedure TMockDistribuidorRepository.Clear;
begin
  FData.Clear;
end;

procedure TMockDistribuidorRepository.AddTestData(AEntity: TDistribuidorEntity);
var
  LClone: TDistribuidorEntity;
begin
  LClone := CloneEntity(AEntity);
  FData.Add(LClone);
end;

function TMockDistribuidorRepository.Count: Integer;
begin
  Result := FData.Count;
end;

function TMockDistribuidorRepository.CloneEntity(AEntity: TDistribuidorEntity): TDistribuidorEntity;
begin
  Result := TDistribuidorEntity.Create;
  Result.Id := AEntity.Id;
  Result.Nome := AEntity.Nome;
  Result.Cnpj := AEntity.Cnpj;
  Result.CreatedAt := AEntity.CreatedAt;
  Result.UpdatedAt := AEntity.UpdatedAt;
  Result.State := AEntity.State;
end;

function TMockDistribuidorRepository.InternalFindById(const AId: string): TDistribuidorEntity;
var
  LEntity: TDistribuidorEntity;
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

function TMockDistribuidorRepository.FindAll: TObjectList<TDistribuidorEntity>;
var
  LEntity: TDistribuidorEntity;
  LClone: TDistribuidorEntity;
begin
  Result := TObjectList<TDistribuidorEntity>.Create(True);
  for LEntity in FData do
  begin
    LClone := CloneEntity(LEntity);
    Result.Add(LClone);
  end;
end;

function TMockDistribuidorRepository.FindById(const AId: string): TDistribuidorEntity;
var
  LEntity: TDistribuidorEntity;
begin
  LEntity := InternalFindById(AId);
  if Assigned(LEntity) then
    Result := CloneEntity(LEntity)
  else
    Result := nil;
end;

function TMockDistribuidorRepository.FindByCnpj(const ACnpj: string): TDistribuidorEntity;
var
  LEntity: TDistribuidorEntity;
  LCnpjLimpo: string;
begin
  Result := nil;
  LCnpjLimpo := ACnpj.Replace('.', '').Replace('-', '').Replace('/', '');
  
  for LEntity in FData do
  begin
    if SameText(LEntity.Cnpj.Replace('.', '').Replace('-', '').Replace('/', ''), LCnpjLimpo) then
    begin
      Result := CloneEntity(LEntity);
      Break;
    end;
  end;
end;

function TMockDistribuidorRepository.Insert(AEntity: TDistribuidorEntity): TDistribuidorEntity;
var
  LClone: TDistribuidorEntity;
begin
  LClone := CloneEntity(AEntity);
  if LClone.Id = '' then
    LClone.Id := TGUID.NewGuid.ToString;
  LClone.CreatedAt := Now;
  LClone.UpdatedAt := Now;
  FData.Add(LClone);
  
  AEntity.Id := LClone.Id;
  Result := AEntity;
end;

function TMockDistribuidorRepository.Update(AEntity: TDistribuidorEntity): TDistribuidorEntity;
var
  LExisting: TDistribuidorEntity;
  LIndex: Integer;
begin
  LExisting := InternalFindById(AEntity.Id);
  if not Assigned(LExisting) then
    raise Exception.Create('Distribuidor não encontrado para atualização');

  LIndex := FData.IndexOf(LExisting);
  FData.Delete(LIndex);
  
  LExisting := CloneEntity(AEntity);
  LExisting.UpdatedAt := Now;
  FData.Insert(LIndex, LExisting);
  Result := AEntity;
end;

function TMockDistribuidorRepository.Delete(AEntity: TDistribuidorEntity): Boolean;
var
  LExisting: TDistribuidorEntity;
begin
  Result := False;
  if not Assigned(AEntity) then
    Exit;
    
  LExisting := InternalFindById(AEntity.Id);
  if Assigned(LExisting) then
  begin
    FData.Remove(LExisting);
    Result := True;
  end;
end;

end.

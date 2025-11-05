unit MockProdutorRepository;

interface

uses
  System.SysUtils,
  System.Generics.Collections,
  ProdutorEntity,
  ProdutorRepository.Intf;

type
  TMockProdutorRepository = class(TInterfacedObject, IProdutorRepository)
  private
    FData: TObjectList<TProdutorEntity>;
    function InternalFindById(const AId: string): TProdutorEntity;
    function CloneEntity(AEntity: TProdutorEntity): TProdutorEntity;
  public
    constructor Create;
    destructor Destroy; override;

    // Interface IProdutorRepository
    function FindAll: TObjectList<TProdutorEntity>;
    function FindByDocument(const ADocumento: string): TProdutorEntity;
    function FindById(const AId: string): TProdutorEntity;
    function Insert(AEntity: TProdutorEntity): TProdutorEntity;
    function Update(AEntity: TProdutorEntity): TProdutorEntity;
    function Delete(AEntity: TProdutorEntity): Boolean;

    // Métodos auxiliares para testes
    procedure Clear;
    procedure AddTestData(AEntity: TProdutorEntity);
    function Count: Integer;
  end;

implementation

uses
  GsBaseEntity;

{ TMockProdutorRepository }

constructor TMockProdutorRepository.Create;
begin
  inherited Create;
  FData := TObjectList<TProdutorEntity>.Create(True);
end;

destructor TMockProdutorRepository.Destroy;
begin
  FData.Free;
  inherited;
end;

procedure TMockProdutorRepository.Clear;
begin
  FData.Clear;
end;

procedure TMockProdutorRepository.AddTestData(AEntity: TProdutorEntity);
var
  LClone: TProdutorEntity;
begin
  LClone := CloneEntity(AEntity);
  FData.Add(LClone);
end;

function TMockProdutorRepository.Count: Integer;
begin
  Result := FData.Count;
end;

function TMockProdutorRepository.CloneEntity(AEntity: TProdutorEntity): TProdutorEntity;
begin
  Result := TProdutorEntity.Create;
  Result.Id := AEntity.Id;
  Result.Nome := AEntity.Nome;
  Result.CpfCnpj := AEntity.CpfCnpj;
  Result.CreatedAt := AEntity.CreatedAt;
  Result.UpdatedAt := AEntity.UpdatedAt;
  Result.State := AEntity.State;
end;

function TMockProdutorRepository.InternalFindById(const AId: string): TProdutorEntity;
var
  LEntity: TProdutorEntity;
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

function TMockProdutorRepository.FindAll: TObjectList<TProdutorEntity>;
var
  LEntity: TProdutorEntity;
  LClone: TProdutorEntity;
begin
  Result := TObjectList<TProdutorEntity>.Create(True);
  for LEntity in FData do
  begin
    LClone := CloneEntity(LEntity);
    Result.Add(LClone);
  end;
end;

function TMockProdutorRepository.FindById(const AId: string): TProdutorEntity;
var
  LEntity: TProdutorEntity;
begin
  LEntity := InternalFindById(AId);
  if Assigned(LEntity) then
    Result := CloneEntity(LEntity)
  else
    Result := nil;
end;

function TMockProdutorRepository.FindByDocument(const ADocumento: string): TProdutorEntity;
var
  LEntity: TProdutorEntity;
  LDocLimpo: string;
begin
  Result := nil;
  LDocLimpo := ADocumento.Replace('.', '').Replace('-', '').Replace('/', '');
  
  for LEntity in FData do
  begin
    if SameText(LEntity.CpfCnpj.Replace('.', '').Replace('-', '').Replace('/', ''), LDocLimpo) then
    begin
      Result := CloneEntity(LEntity);
      Break;
    end;
  end;
end;

function TMockProdutorRepository.Insert(AEntity: TProdutorEntity): TProdutorEntity;
var
  LClone: TProdutorEntity;
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

function TMockProdutorRepository.Update(AEntity: TProdutorEntity): TProdutorEntity;
var
  LExisting: TProdutorEntity;
  LIndex: Integer;
begin
  LExisting := InternalFindById(AEntity.Id);
  if not Assigned(LExisting) then
    raise Exception.Create('Produtor não encontrado para atualização');

  LIndex := FData.IndexOf(LExisting);
  FData.Delete(LIndex);
  
  LExisting := CloneEntity(AEntity);
  LExisting.UpdatedAt := Now;
  FData.Insert(LIndex, LExisting);
  Result := AEntity;
end;

function TMockProdutorRepository.Delete(AEntity: TProdutorEntity): Boolean;
var
  LExisting: TProdutorEntity;
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

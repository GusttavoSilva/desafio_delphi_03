unit DistribuidorController;

interface

uses
  System.SysUtils,
  System.Generics.Collections,
  DistribuidorEntity,
  DistribuidorRepository.Intf;

type
  TDistribuidorController = class
  private
    FRepository: IDistribuidorRepository;
    procedure ValidarDuplicidade(ADistribuidor: TDistribuidorEntity);
  public
    constructor Create(ARepository: IDistribuidorRepository);

    function ListarTodos: TObjectList<TDistribuidorEntity>;
    function BuscarPorId(const AId: string): TDistribuidorEntity;
    function BuscarPorCnpj(const ACnpj: string): TDistribuidorEntity;
    function Salvar(ADistribuidor: TDistribuidorEntity): TDistribuidorEntity;
    function Excluir(ADistribuidor: TDistribuidorEntity): Boolean;
  end;

implementation

uses
  GsBaseEntity;

{ TDistribuidorController }

constructor TDistribuidorController.Create(ARepository: IDistribuidorRepository);
begin
  inherited Create;
  FRepository := ARepository;
end;

function TDistribuidorController.ListarTodos: TObjectList<TDistribuidorEntity>;
begin
  Result := FRepository.FindAll;
end;

function TDistribuidorController.BuscarPorId(const AId: string): TDistribuidorEntity;
begin
  if AId.Trim.IsEmpty then
    raise Exception.Create('ID não pode ser vazio.');
  Result := FRepository.FindById(AId);
  if not Assigned(Result) then
    raise Exception.Create('Distribuidor não encontrado.');
end;

function TDistribuidorController.BuscarPorCnpj(const ACnpj: string): TDistribuidorEntity;
begin
  if ACnpj.Trim.IsEmpty then
    raise Exception.Create('CNPJ não pode ser vazio.');
  Result := FRepository.FindByCnpj(ACnpj);
end;

function TDistribuidorController.Salvar(ADistribuidor: TDistribuidorEntity): TDistribuidorEntity;
begin
  if not Assigned(ADistribuidor) then
    raise Exception.Create('Distribuidor não pode ser nulo.');

  ValidarDuplicidade(ADistribuidor);

  case ADistribuidor.State of
    esInsert:
      Result := FRepository.Insert(ADistribuidor);
    esUpdate:
      Result := FRepository.Update(ADistribuidor);
    esDelete:
      raise Exception.Create('Use Excluir para remover um distribuidor.');
  else
    raise Exception.Create('Estado inválido para o distribuidor.');
  end;
end;

function TDistribuidorController.Excluir(ADistribuidor: TDistribuidorEntity): Boolean;
begin
  if not Assigned(ADistribuidor) then
    raise Exception.Create('Distribuidor não pode ser nulo.');
  if ADistribuidor.Id.Trim.IsEmpty then
    raise Exception.Create('Distribuidor sem ID não pode ser excluído.');
  Result := FRepository.Delete(ADistribuidor);
end;

procedure TDistribuidorController.ValidarDuplicidade(ADistribuidor: TDistribuidorEntity);
var
  LExistente: TDistribuidorEntity;
begin
  LExistente := FRepository.FindByCnpj(ADistribuidor.Cnpj);
  try
    if Assigned(LExistente) then
    begin
      if (ADistribuidor.State = esUpdate) and (LExistente.Id = ADistribuidor.Id) then
        Exit;
      raise Exception.Create('Já existe um distribuidor cadastrado com este CNPJ.');
    end;
  finally
    LExistente.Free;
  end;
end;

end.

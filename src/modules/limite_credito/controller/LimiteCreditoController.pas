unit LimiteCreditoController;

interface

uses
  System.SysUtils,
  System.Generics.Collections,
  LimiteCreditoEntity,
  LimiteCreditoRepository.Intf;

type
  TLimiteCreditoController = class
  private
    FRepository: ILimiteCreditoRepository;
    procedure ValidarDuplicidade(const AEntity: TLimiteCreditoEntity);
  public
    constructor Create(ARepository: ILimiteCreditoRepository);

    function ListarTodos: TObjectList<TLimiteCreditoEntity>;
    function BuscarPorId(const AId: string): TLimiteCreditoEntity;
    function BuscarPorRelacionamento(const AProdutorId, ADistribuidorId: string): TLimiteCreditoEntity;
    function Salvar(AEntity: TLimiteCreditoEntity): TLimiteCreditoEntity;
    procedure Excluir(AEntity: TLimiteCreditoEntity);
    function ObterLimiteCredito(const AProdutorId, ADistribuidorId: string): Currency;
  end;

implementation

uses
  GsBaseEntity;

{ TLimiteCreditoController }

constructor TLimiteCreditoController.Create(ARepository: ILimiteCreditoRepository);
begin
  inherited Create;
  FRepository := ARepository;
end;

procedure TLimiteCreditoController.Excluir(AEntity: TLimiteCreditoEntity);
begin
  if not Assigned(AEntity) then
    raise Exception.Create('Entidade inválida.');
  if AEntity.Id.Trim.IsEmpty then
    raise Exception.Create('ID inválido para exclusão.');
  FRepository.Excluir(AEntity.Id);
end;

function TLimiteCreditoController.ListarTodos: TObjectList<TLimiteCreditoEntity>;
begin
  Result := FRepository.ObterTodos;
end;

function TLimiteCreditoController.BuscarPorId(const AId: string): TLimiteCreditoEntity;
begin
  if AId.Trim.IsEmpty then
    raise Exception.Create('ID inválido.');
  Result := FRepository.ObterPorId(AId);
  if not Assigned(Result) then
    raise Exception.Create('Limite de crédito não encontrado.');
end;

function TLimiteCreditoController.BuscarPorRelacionamento(const AProdutorId, ADistribuidorId: string): TLimiteCreditoEntity;
begin
  if AProdutorId.Trim.IsEmpty or ADistribuidorId.Trim.IsEmpty then
    raise Exception.Create('Produtor e Distribuidor são obrigatórios.');
  Result := FRepository.ObterPorRelacionamento(AProdutorId, ADistribuidorId);
end;

function TLimiteCreditoController.ObterLimiteCredito(const AProdutorId, ADistribuidorId: string): Currency;
var
  LLimite: TLimiteCreditoEntity;
begin
  Result := 0;
  LLimite := BuscarPorRelacionamento(AProdutorId, ADistribuidorId);
  if Assigned(LLimite) then
  begin
    try
      Result := LLimite.Limite;
    finally
      LLimite.Free;
    end;
  end;
end;

function TLimiteCreditoController.Salvar(AEntity: TLimiteCreditoEntity): TLimiteCreditoEntity;
begin
  if not Assigned(AEntity) then
    raise Exception.Create('Entidade inválida.');

  ValidarDuplicidade(AEntity);

  case AEntity.State of
    esInsert: FRepository.Inserir(AEntity);
    esUpdate: FRepository.Atualizar(AEntity);
  else
    raise Exception.Create('Estado inválido para persistência.');
  end;
  
  Result := AEntity;
end;

procedure TLimiteCreditoController.ValidarDuplicidade(const AEntity: TLimiteCreditoEntity);
var
  LExistente: TLimiteCreditoEntity;
begin
  LExistente := FRepository.ObterPorRelacionamento(AEntity.ProdutorId, AEntity.DistribuidorId);
  try
    if Assigned(LExistente) then
    begin
      if (AEntity.State = esUpdate) and (LExistente.Id = AEntity.Id) then
        Exit;
      raise Exception.Create('Já existe limite definido para este Produtor e Distribuidor.');
    end;
  finally
    LExistente.Free;
  end;
end;

end.

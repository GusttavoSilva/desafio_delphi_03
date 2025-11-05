unit ProdutorController;

interface

uses
  System.SysUtils,
  System.Generics.Collections,
  ProdutorEntity,
  ProdutorRepository.Intf;

type
  TProdutorController = class
  private
    FRepository: IProdutorRepository;
  public
    constructor Create(ARepository: IProdutorRepository);
    
    // Regras de negócio do Produtor
    // Aqui fica a ponte entre a View e o Repository
    
    // Listar todos os produtores
    function ListarTodos: TObjectList<TProdutorEntity>;
    
    // Buscar produtor por ID
    function BuscarPorId(const AId: string): TProdutorEntity;
    
    // Buscar produtor por documento (CPF/CNPJ)
    function BuscarPorDocumento(const ADocumento: string): TProdutorEntity;
    
    // Salvar produtor (cria novo ou atualiza existente)
    function Salvar(AProdutor: TProdutorEntity): TProdutorEntity;
    
    // Excluir produtor
    function Excluir(AProdutor: TProdutorEntity): Boolean;
    
    // Validações adicionais de negócio
    procedure ValidarDuplicidade(AProdutor: TProdutorEntity);
  end;

implementation

uses
  GsBaseEntity;

{ TProdutorController }

constructor TProdutorController.Create(ARepository: IProdutorRepository);
begin
  inherited Create;
  FRepository := ARepository;
end;

function TProdutorController.ListarTodos: TObjectList<TProdutorEntity>;
begin
  try
    Result := FRepository.FindAll;
  except
    on E: Exception do
    begin
      raise Exception.Create('Erro ao listar produtores: ' + E.Message);
    end;
  end;
end;

function TProdutorController.BuscarPorId(const AId: string): TProdutorEntity;
begin
  try
    if AId.Trim.IsEmpty then
      raise Exception.Create('ID não pode ser vazio.');
      
    Result := FRepository.FindById(AId);
    
    if not Assigned(Result) then
      raise Exception.Create('Produtor não encontrado.');
  except
    on E: Exception do
    begin
      raise Exception.Create('Erro ao buscar produtor: ' + E.Message);
    end;
  end;
end;

function TProdutorController.BuscarPorDocumento(const ADocumento: string): TProdutorEntity;
begin
  try
    if ADocumento.Trim.IsEmpty then
      raise Exception.Create('CPF/CNPJ não pode ser vazio.');
      
    Result := FRepository.FindByDocument(ADocumento);
  except
    on E: Exception do
    begin
      raise Exception.Create('Erro ao buscar produtor por documento: ' + E.Message);
    end;
  end;
end;

function TProdutorController.Salvar(AProdutor: TProdutorEntity): TProdutorEntity;
begin
  try
    if not Assigned(AProdutor) then
      raise Exception.Create('Produtor não pode ser nulo.');
    
    // Validar duplicidade de CPF/CNPJ
    ValidarDuplicidade(AProdutor);

    // Determinar se é Insert ou Update baseado no State
    case AProdutor.State of
      esInsert:
        Result := FRepository.Insert(AProdutor);
      
      esUpdate:
        Result := FRepository.Update(AProdutor);
      
      esDelete:
        raise Exception.Create('Use o método Excluir para deletar um produtor.');
    else
      raise Exception.Create('Estado da entidade inválido.');
    end;
  except
    on E: Exception do
    begin
      raise Exception.Create('Erro ao salvar produtor: ' + E.Message);
    end;
  end;
end;

function TProdutorController.Excluir(AProdutor: TProdutorEntity): Boolean;
begin
  try
    if not Assigned(AProdutor) then
      raise Exception.Create('Produtor não pode ser nulo.');
      
    if AProdutor.Id.Trim.IsEmpty then
      raise Exception.Create('Não é possível excluir um produtor sem ID.');
    
    Result := FRepository.Delete(AProdutor);
  except
    on E: Exception do
    begin
      raise Exception.Create('Erro ao excluir produtor: ' + E.Message);
    end;
  end;
end;

procedure TProdutorController.ValidarDuplicidade(AProdutor: TProdutorEntity);
var
  LProdutorExistente: TProdutorEntity;
begin
  // Verificar se já existe um produtor com o mesmo CPF/CNPJ
  LProdutorExistente := FRepository.FindByDocument(AProdutor.CpfCnpj);
  try
    if Assigned(LProdutorExistente) then
    begin
      // Se está atualizando, permitir se for o mesmo registro
      if (AProdutor.State = esUpdate) and (LProdutorExistente.Id = AProdutor.Id) then
        Exit;
        
      // Senão, é duplicidade
      raise Exception.Create('Já existe um produtor cadastrado com este CPF/CNPJ.');
    end;
  finally
    if Assigned(LProdutorExistente) then
      LProdutorExistente.Free;
  end;
end;

end.

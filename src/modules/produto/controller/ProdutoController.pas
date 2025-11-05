unit ProdutoController;

interface

uses
  System.SysUtils,
  System.Generics.Collections,
  ProdutoEntity,
  ProdutoRepository.Intf;

type
  TProdutoController = class
  private
    FRepository: IProdutoRepository;
  public
    constructor Create(ARepository: IProdutoRepository);

    function ListarTodos: TObjectList<TProdutoEntity>;
    function BuscarPorId(const AId: string): TProdutoEntity;
    function Salvar(AProduto: TProdutoEntity): TProdutoEntity;
    procedure Excluir(AProduto: TProdutoEntity);
  end;

implementation

uses
  GsBaseEntity;

{ TProdutoController }

function TProdutoController.BuscarPorId(const AId: string): TProdutoEntity;
begin
  if AId.Trim.IsEmpty then
    raise Exception.Create('ID do produto não pode ser vazio.');
  Result := FRepository.ObterPorId(AId);
  if not Assigned(Result) then
    raise Exception.Create('Produto não encontrado.');
end;

constructor TProdutoController.Create(ARepository: IProdutoRepository);
begin
  inherited Create;
  FRepository := ARepository;
end;

procedure TProdutoController.Excluir(AProduto: TProdutoEntity);
begin
  if not Assigned(AProduto) then
    raise Exception.Create('Produto inválido.');
  if AProduto.Id.Trim.IsEmpty then
    raise Exception.Create('ID do produto não pode ser vazio.');
  FRepository.Excluir(AProduto.Id);
end;

function TProdutoController.ListarTodos: TObjectList<TProdutoEntity>;
begin
  Result := FRepository.ObterTodos;
end;

function TProdutoController.Salvar(AProduto: TProdutoEntity): TProdutoEntity;
begin
  if not Assigned(AProduto) then
    raise Exception.Create('Produto inválido.');

  case AProduto.State of
    esInsert: FRepository.Inserir(AProduto);
    esUpdate: FRepository.Atualizar(AProduto);
  else
    raise Exception.Create('Estado do produto não suportado.');
  end;
  
  Result := AProduto;
end;

end.

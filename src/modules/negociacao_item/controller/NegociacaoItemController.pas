unit NegociacaoItemController;

interface

uses
  System.SysUtils,
  System.Generics.Collections,
  NegociacaoItemEntity,
  NegociacaoItemRepository.Intf;

type
  TNegociacaoItemController = class
  private
    FRepository: INegociacaoItemRepository;
  public
    constructor Create(ARepository: INegociacaoItemRepository);

    function BuscarPorId(const AId: string): TNegociacaoItemEntity;
    function ListarPorNegociacao(const ANegociacaoId: string): TObjectList<TNegociacaoItemEntity>;
    function Salvar(AItem: TNegociacaoItemEntity): TNegociacaoItemEntity;
    procedure Excluir(AItem: TNegociacaoItemEntity);
    procedure ExcluirPorNegociacao(const ANegociacaoId: string);
  end;

implementation

uses
  GsBaseEntity;

{ TNegociacaoItemController }

function TNegociacaoItemController.BuscarPorId(const AId: string): TNegociacaoItemEntity;
begin
  if AId.Trim.IsEmpty then
    raise Exception.Create('ID do item não pode ser vazio.');
  Result := FRepository.ObterPorId(AId);
  if not Assigned(Result) then
    raise Exception.Create('Item da negociação não encontrado.');
end;

constructor TNegociacaoItemController.Create(ARepository: INegociacaoItemRepository);
begin
  inherited Create;
  FRepository := ARepository;
end;

procedure TNegociacaoItemController.Excluir(AItem: TNegociacaoItemEntity);
begin
  if not Assigned(AItem) then
    raise Exception.Create('Item inválido.');
  if AItem.Id.Trim.IsEmpty then
    raise Exception.Create('ID do item não pode ser vazio.');
  FRepository.Excluir(AItem.Id);
end;

procedure TNegociacaoItemController.ExcluirPorNegociacao(const ANegociacaoId: string);
begin
  if ANegociacaoId.Trim.IsEmpty then
    raise Exception.Create('ID da negociação não pode ser vazio.');
  FRepository.ExcluirPorNegociacao(ANegociacaoId);
end;

function TNegociacaoItemController.ListarPorNegociacao(const ANegociacaoId: string): TObjectList<TNegociacaoItemEntity>;
var
  LLista: TObjectList<TNegociacaoItemEntity>;
  LItem: TNegociacaoItemEntity;
begin
  if ANegociacaoId.Trim.IsEmpty then
    raise Exception.Create('ID da negociação não pode ser vazio.');
    
  Result := TObjectList<TNegociacaoItemEntity>.Create(True);
  LLista := FRepository.ObterPorNegociacao(ANegociacaoId);
  try
    for LItem in LLista do
      Result.Add(LItem);
  finally
    LLista.Free;
  end;
end;

function TNegociacaoItemController.Salvar(AItem: TNegociacaoItemEntity): TNegociacaoItemEntity;
begin
  if not Assigned(AItem) then
    raise Exception.Create('Item inválido.');

  case AItem.State of
    esInsert: FRepository.Inserir(AItem);
    esUpdate: FRepository.Atualizar(AItem);
  else
    raise Exception.Create('Estado do item não suportado.');
  end;
  
  Result := AItem;
end;

end.

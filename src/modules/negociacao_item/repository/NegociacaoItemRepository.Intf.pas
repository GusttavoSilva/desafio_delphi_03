unit NegociacaoItemRepository.Intf;

interface

uses
  System.Generics.Collections,
  NegociacaoItemEntity;

type
  INegociacaoItemRepository = interface
    ['{9B1F37BB-2C71-4336-9D0A-573139EECF60}']
    function ObterPorId(const AId: string): TNegociacaoItemEntity;
    function ObterPorNegociacao(const ANegociacaoId: string): TObjectList<TNegociacaoItemEntity>;
    procedure Inserir(const AEntity: TNegociacaoItemEntity);
    procedure Atualizar(const AEntity: TNegociacaoItemEntity);
    procedure Excluir(const AId: string);
    procedure ExcluirPorNegociacao(const ANegociacaoId: string);
  end;

implementation

end.

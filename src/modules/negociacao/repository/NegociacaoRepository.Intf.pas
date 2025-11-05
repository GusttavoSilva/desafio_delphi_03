unit NegociacaoRepository.Intf;

interface

uses
  System.Generics.Collections,
  NegociacaoEntity;

type
  INegociacaoRepository = interface
    ['{7B3BBD42-020C-4EAA-A3E6-104938F471AD}']
    function ObterTodos: TObjectList<TNegociacaoEntity>;
    function ObterPorId(const AId: string): TNegociacaoEntity;
    function ObterTotalAprovado(const AProdutorId, ADistribuidorId, AIgnorarNegociacaoId: string): Currency;
    procedure Inserir(const AEntity: TNegociacaoEntity);
    procedure Atualizar(const AEntity: TNegociacaoEntity);
    procedure AtualizarStatus(const AId, AStatus: string; const ADataReferencia: TDateTime);
    procedure Excluir(const AId: string);
  end;

implementation

end.

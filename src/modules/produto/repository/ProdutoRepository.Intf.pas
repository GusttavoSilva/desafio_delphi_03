unit ProdutoRepository.Intf;

interface

uses
  System.Generics.Collections, ProdutoEntity;

type
  IProdutoRepository = interface
    ['{D5610E2B-7C44-4C60-AC96-708989354152}']
    function ObterTodos: TObjectList<TProdutoEntity>;
    function ObterPorId(const AId: string): TProdutoEntity;
    procedure Inserir(const AEntity: TProdutoEntity);
    procedure Atualizar(const AEntity: TProdutoEntity);
    procedure Excluir(const AId: string);
  end;

implementation

end.

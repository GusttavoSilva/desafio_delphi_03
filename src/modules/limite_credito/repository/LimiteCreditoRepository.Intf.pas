unit LimiteCreditoRepository.Intf;

interface

uses
  System.Generics.Collections,
  LimiteCreditoEntity;

type
  ILimiteCreditoRepository = interface
    ['{61F3F55A-7716-4C79-BD40-DAD0F80CB9A1}']
    function ObterTodos: TObjectList<TLimiteCreditoEntity>;
    function ObterPorId(const AId: string): TLimiteCreditoEntity;
    function ObterPorRelacionamento(const AProdutorId, ADistribuidorId: string): TLimiteCreditoEntity;
    procedure Inserir(const AEntity: TLimiteCreditoEntity);
    procedure Atualizar(const AEntity: TLimiteCreditoEntity);
    procedure Excluir(const AId: string);
  end;

implementation

end.

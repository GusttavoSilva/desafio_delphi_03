unit DistribuidorRepository.Intf;

interface

uses
  System.Generics.Collections,
  DistribuidorEntity;

type
  IDistribuidorRepository = interface
    ['{F8D51134-7B51-4F3D-8F5D-6F1C2F77E8B5}']

    function FindAll: TObjectList<TDistribuidorEntity>;
    function FindById(const AId: string): TDistribuidorEntity;
    function FindByCnpj(const ACnpj: string): TDistribuidorEntity;
    function Insert(AEntity: TDistribuidorEntity): TDistribuidorEntity;
    function Update(AEntity: TDistribuidorEntity): TDistribuidorEntity;
    function Delete(AEntity: TDistribuidorEntity): Boolean;
  end;

implementation

end.

unit ProdutorRepository.Intf;

interface

uses
  System.Generics.Collections,
  ProdutorEntity;

type
  IProdutorRepository = interface
    ['{B8F2E5A1-4D3C-4E2F-9A1B-5C6D7E8F9A0B}']
    
    // Buscar todos os produtores
    function FindAll: TObjectList<TProdutorEntity>;
    
    // Buscar produtor por documento (CPF/CNPJ)
    function FindByDocument(const ADocumento: string): TProdutorEntity;
    
    // Buscar produtor por ID
    function FindById(const AId: string): TProdutorEntity;
    
    // Criar novo produtor
    function Insert(AEntity: TProdutorEntity): TProdutorEntity;
    
    // Atualizar produtor existente
    function Update(AEntity: TProdutorEntity): TProdutorEntity;
    
    // Deletar produtor
    function Delete(AEntity: TProdutorEntity): Boolean;
  end;

implementation

end.

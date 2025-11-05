unit ProdutorModule;

interface

uses
  System.SysUtils,
  FireDAC.Comp.Client,
  ProdutorEntity,
  ProdutorRepository.Intf,
  ProdutorRepository.FB,
  ProdutorController;

type
  /// <summary>
  /// Módulo centralizador do Produtor
  /// Gerencia a criação e acesso ao Repository e Controller
  /// Singleton pattern para reutilização em outros módulos
  /// </summary>
  TProdutorModule = class
  private
    FConnection: TFDConnection;
    FRepository: IProdutorRepository;
    FController: TProdutorController;
    FOwnsConnection: Boolean;
    
    class var FInstance: TProdutorModule;
    
    constructor CreateInternal(AConnection: TFDConnection; AOwnsConnection: Boolean);
  public
    destructor Destroy; override;
    
    /// <summary>
    /// Cria uma instância do módulo com uma conexão específica
    /// </summary>
    class function Create(AConnection: TFDConnection): TProdutorModule; overload;
    
    /// <summary>
    /// Obtém a instância singleton (precisa ser inicializado antes com Initialize)
    /// </summary>
    class function GetInstance: TProdutorModule;
    
    /// <summary>
    /// Inicializa o módulo singleton com uma conexão compartilhada
    /// </summary>
    class procedure Initialize(AConnection: TFDConnection);
    
    /// <summary>
    /// Libera a instância singleton
    /// </summary>
    class procedure Finalize;
    
    /// <summary>
    /// Acessa o Repository do Produtor
    /// </summary>
    function GetRepository: IProdutorRepository;
    
    /// <summary>
    /// Acessa o Controller do Produtor
    /// </summary>
    function GetController: TProdutorController;
    
    /// <summary>
    /// Acessa a Connection
    /// </summary>
    function GetConnection: TFDConnection;
    
    // Properties para acesso direto
    property Repository: IProdutorRepository read GetRepository;
    property Controller: TProdutorController read GetController;
    property Connection: TFDConnection read GetConnection;
  end;

implementation

{ TProdutorModule }

constructor TProdutorModule.CreateInternal(AConnection: TFDConnection; AOwnsConnection: Boolean);
begin
  inherited Create;
  FConnection := AConnection;
  FOwnsConnection := AOwnsConnection;
  FRepository := nil;
  FController := nil;
end;

destructor TProdutorModule.Destroy;
begin
  if Assigned(FController) then
    FController.Free;
    
  // FRepository é interface, será liberado automaticamente
  FRepository := nil;
  
  if FOwnsConnection and Assigned(FConnection) then
    FConnection.Free;
    
  inherited;
end;

class function TProdutorModule.Create(AConnection: TFDConnection): TProdutorModule;
begin
  if not Assigned(AConnection) then
    raise Exception.Create('Connection não pode ser nil.');
    
  Result := TProdutorModule.CreateInternal(AConnection, False);
end;

class function TProdutorModule.GetInstance: TProdutorModule;
begin
  if not Assigned(FInstance) then
    raise Exception.Create('TProdutorModule não foi inicializado. Chame Initialize primeiro.');
    
  Result := FInstance;
end;

class procedure TProdutorModule.Initialize(AConnection: TFDConnection);
begin
  if Assigned(FInstance) then
    raise Exception.Create('TProdutorModule já foi inicializado.');
    
  if not Assigned(AConnection) then
    raise Exception.Create('Connection não pode ser nil.');
    
  FInstance := TProdutorModule.CreateInternal(AConnection, False);
end;

class procedure TProdutorModule.Finalize;
begin
  if Assigned(FInstance) then
  begin
    FInstance.Free;
    FInstance := nil;
  end;
end;

function TProdutorModule.GetRepository: IProdutorRepository;
begin
  // Lazy initialization do Repository
  if not Assigned(FRepository) then
  begin
    if not Assigned(FConnection) then
      raise Exception.Create('Connection não está configurada.');
      
    FRepository := TProdutorRepositoryFB.Create(FConnection);
  end;
  
  Result := FRepository;
end;

function TProdutorModule.GetController: TProdutorController;
begin
  // Lazy initialization do Controller
  if not Assigned(FController) then
  begin
    // Garante que o Repository foi criado
    if not Assigned(FRepository) then
      GetRepository;
      
    FController := TProdutorController.Create(FRepository);
  end;
  
  Result := FController;
end;

function TProdutorModule.GetConnection: TFDConnection;
begin
  Result := FConnection;
end;

end.

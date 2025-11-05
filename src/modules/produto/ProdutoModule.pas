unit ProdutoModule;

interface

uses
  System.SysUtils,
  FireDAC.Comp.Client,
  ProdutoRepository.Intf,
  ProdutoRepository.FB,
  ProdutoController;

type
  TProdutoModule = class
  private
    FConnection: TFDConnection;
    FRepository: IProdutoRepository;
    FController: TProdutoController;
    FOwnsConnection: Boolean;
    class var FInstance: TProdutoModule;
    constructor CreateInternal(AConnection: TFDConnection; AOwnsConnection: Boolean);
  public
    destructor Destroy; override;

    class function Create(AConnection: TFDConnection): TProdutoModule;
    class function GetInstance: TProdutoModule;
    class procedure Initialize(AConnection: TFDConnection);
    class procedure Finalize;

    function GetRepository: IProdutoRepository;
    function GetController: TProdutoController;
    function GetConnection: TFDConnection;

    property Repository: IProdutoRepository read GetRepository;
    property Controller: TProdutoController read GetController;
    property Connection: TFDConnection read GetConnection;
  end;

implementation

{ TProdutoModule }

constructor TProdutoModule.CreateInternal(AConnection: TFDConnection; AOwnsConnection: Boolean);
begin
  inherited Create;
  FConnection := AConnection;
  FOwnsConnection := AOwnsConnection;
  FRepository := nil;
  FController := nil;
end;

destructor TProdutoModule.Destroy;
begin
  if Assigned(FController) then
    FController.Free;

  FRepository := nil;

  if FOwnsConnection and Assigned(FConnection) then
    FConnection.Free;
  inherited;
end;

class function TProdutoModule.Create(AConnection: TFDConnection): TProdutoModule;
begin
  if not Assigned(AConnection) then
    raise Exception.Create('Connection não pode ser nil.');
  Result := TProdutoModule.CreateInternal(AConnection, False);
end;

function TProdutoModule.GetConnection: TFDConnection;
begin
  Result := FConnection;
end;

function TProdutoModule.GetController: TProdutoController;
begin
  if not Assigned(FController) then
  begin
    if not Assigned(FRepository) then
      GetRepository;
    FController := TProdutoController.Create(FRepository);
  end;
  Result := FController;
end;

class function TProdutoModule.GetInstance: TProdutoModule;
begin
  if not Assigned(FInstance) then
    raise Exception.Create('TProdutoModule não foi inicializado.');
  Result := FInstance;
end;

function TProdutoModule.GetRepository: IProdutoRepository;
begin
  if not Assigned(FRepository) then
  begin
    if not Assigned(FConnection) then
      raise Exception.Create('Connection não está configurada.');
    FRepository := TProdutoRepositoryFB.Create(FConnection);
  end;
  Result := FRepository;
end;

class procedure TProdutoModule.Initialize(AConnection: TFDConnection);
begin
  if Assigned(FInstance) then
    raise Exception.Create('TProdutoModule já foi inicializado.');
  if not Assigned(AConnection) then
    raise Exception.Create('Connection não pode ser nil.');
  FInstance := TProdutoModule.CreateInternal(AConnection, False);
end;

class procedure TProdutoModule.Finalize;
begin
  if Assigned(FInstance) then
  begin
    FInstance.Free;
    FInstance := nil;
  end;
end;

end.

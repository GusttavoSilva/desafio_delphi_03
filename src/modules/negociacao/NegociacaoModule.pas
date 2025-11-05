unit NegociacaoModule;

interface

uses
  System.SysUtils,
  FireDAC.Comp.Client,
  NegociacaoRepository.Intf,
  NegociacaoRepository.FB,
  NegociacaoController,
  LimiteCreditoRepository.Intf,
  LimiteCreditoRepository.FB,
  NegociacaoItemRepository.Intf,
  NegociacaoItemRepository.FB;

type
  TNegociacaoModule = class
  private
    FConnection: TFDConnection;
    FRepository: INegociacaoRepository;
    FLimiteRepository: ILimiteCreditoRepository;
    FItemRepository: INegociacaoItemRepository;
    FController: TNegociacaoController;
    FOwnsConnection: Boolean;
    class var FInstance: TNegociacaoModule;
    constructor CreateInternal(AConnection: TFDConnection; AOwnsConnection: Boolean);
  public
    destructor Destroy; override;

    class function Create(AConnection: TFDConnection): TNegociacaoModule;
    class function GetInstance: TNegociacaoModule;
    class procedure Initialize(AConnection: TFDConnection);
    class procedure Finalize;

    function GetRepository: INegociacaoRepository;
    function GetLimiteRepository: ILimiteCreditoRepository;
    function GetItemRepository: INegociacaoItemRepository;
    function GetController: TNegociacaoController;
    function GetConnection: TFDConnection;

    property Repository: INegociacaoRepository read GetRepository;
    property Controller: TNegociacaoController read GetController;
    property Connection: TFDConnection read GetConnection;
  end;

implementation

{ TNegociacaoModule }

constructor TNegociacaoModule.CreateInternal(AConnection: TFDConnection; AOwnsConnection: Boolean);
begin
  inherited Create;
  FConnection := AConnection;
  FOwnsConnection := AOwnsConnection;
end;

destructor TNegociacaoModule.Destroy;
begin
  if Assigned(FController) then
    FController.Free;
  FRepository := nil;
  FLimiteRepository := nil;
  FItemRepository := nil;
  if FOwnsConnection and Assigned(FConnection) then
    FConnection.Free;
  inherited;
end;

class function TNegociacaoModule.Create(AConnection: TFDConnection): TNegociacaoModule;
begin
  if not Assigned(AConnection) then
    raise Exception.Create('Connection não pode ser nil.');
  Result := TNegociacaoModule.CreateInternal(AConnection, False);
end;

function TNegociacaoModule.GetConnection: TFDConnection;
begin
  Result := FConnection;
end;

function TNegociacaoModule.GetController: TNegociacaoController;
begin
  if not Assigned(FController) then
  begin
    if not Assigned(FRepository) then
      GetRepository;
    FController := TNegociacaoController.Create(FRepository, GetLimiteRepository, GetItemRepository);
  end;
  Result := FController;
end;

class function TNegociacaoModule.GetInstance: TNegociacaoModule;
begin
  if not Assigned(FInstance) then
    raise Exception.Create('TNegociacaoModule não foi inicializado.');
  Result := FInstance;
end;

function TNegociacaoModule.GetRepository: INegociacaoRepository;
begin
  if not Assigned(FRepository) then
  begin
    if not Assigned(FConnection) then
      raise Exception.Create('Connection não está configurada.');
    FRepository := TNegociacaoRepositoryFB.Create(FConnection);
  end;
  Result := FRepository;
end;

function TNegociacaoModule.GetLimiteRepository: ILimiteCreditoRepository;
begin
  if not Assigned(FLimiteRepository) then
  begin
    if not Assigned(FConnection) then
      raise Exception.Create('Connection não está configurada.');
    FLimiteRepository := TLimiteCreditoRepositoryFB.Create(FConnection);
  end;
  Result := FLimiteRepository;
end;

function TNegociacaoModule.GetItemRepository: INegociacaoItemRepository;
begin
  if not Assigned(FItemRepository) then
  begin
    if not Assigned(FConnection) then
      raise Exception.Create('Connection não está configurada.');
    FItemRepository := TNegociacaoItemRepositoryFB.Create(FConnection);
  end;
  Result := FItemRepository;
end;

class procedure TNegociacaoModule.Initialize(AConnection: TFDConnection);
begin
  if Assigned(FInstance) then
    raise Exception.Create('TNegociacaoModule já foi inicializado.');
  if not Assigned(AConnection) then
    raise Exception.Create('Connection não pode ser nil.');
  FInstance := TNegociacaoModule.CreateInternal(AConnection, False);
end;

class procedure TNegociacaoModule.Finalize;
begin
  if Assigned(FInstance) then
  begin
    FInstance.Free;
    FInstance := nil;
  end;
end;

end.

unit NegociacaoItemModule;

interface

uses
  System.SysUtils,
  FireDAC.Comp.Client,
  NegociacaoItemRepository.Intf,
  NegociacaoItemRepository.FB,
  NegociacaoItemController;

type
  TNegociacaoItemModule = class
  private
    FConnection: TFDConnection;
    FRepository: INegociacaoItemRepository;
    FController: TNegociacaoItemController;
    FOwnsConnection: Boolean;
    class var FInstance: TNegociacaoItemModule;
    constructor CreateInternal(AConnection: TFDConnection; AOwnsConnection: Boolean);
  public
    destructor Destroy; override;

    class function Create(AConnection: TFDConnection): TNegociacaoItemModule;
    class function GetInstance: TNegociacaoItemModule;
    class procedure Initialize(AConnection: TFDConnection);
    class procedure Finalize;

    function GetRepository: INegociacaoItemRepository;
    function GetController: TNegociacaoItemController;
    function GetConnection: TFDConnection;

    property Repository: INegociacaoItemRepository read GetRepository;
    property Controller: TNegociacaoItemController read GetController;
    property Connection: TFDConnection read GetConnection;
  end;

implementation

{ TNegociacaoItemModule }

constructor TNegociacaoItemModule.CreateInternal(AConnection: TFDConnection; AOwnsConnection: Boolean);
begin
  inherited Create;
  FConnection := AConnection;
  FOwnsConnection := AOwnsConnection;
end;

destructor TNegociacaoItemModule.Destroy;
begin
  if Assigned(FController) then
    FController.Free;
  FRepository := nil;
  if FOwnsConnection and Assigned(FConnection) then
    FConnection.Free;
  inherited;
end;

class function TNegociacaoItemModule.Create(AConnection: TFDConnection): TNegociacaoItemModule;
begin
  if not Assigned(AConnection) then
    raise Exception.Create('Connection não pode ser nil.');
  Result := TNegociacaoItemModule.CreateInternal(AConnection, False);
end;

function TNegociacaoItemModule.GetConnection: TFDConnection;
begin
  Result := FConnection;
end;

function TNegociacaoItemModule.GetController: TNegociacaoItemController;
begin
  if not Assigned(FController) then
  begin
    if not Assigned(FRepository) then
      GetRepository;
    FController := TNegociacaoItemController.Create(FRepository);
  end;
  Result := FController;
end;

class function TNegociacaoItemModule.GetInstance: TNegociacaoItemModule;
begin
  if not Assigned(FInstance) then
    raise Exception.Create('TNegociacaoItemModule não foi inicializado.');
  Result := FInstance;
end;

function TNegociacaoItemModule.GetRepository: INegociacaoItemRepository;
begin
  if not Assigned(FRepository) then
  begin
    if not Assigned(FConnection) then
      raise Exception.Create('Connection não está configurada.');
    FRepository := TNegociacaoItemRepositoryFB.Create(FConnection);
  end;
  Result := FRepository;
end;

class procedure TNegociacaoItemModule.Initialize(AConnection: TFDConnection);
begin
  if Assigned(FInstance) then
    raise Exception.Create('TNegociacaoItemModule já foi inicializado.');
  if not Assigned(AConnection) then
    raise Exception.Create('Connection não pode ser nil.');
  FInstance := TNegociacaoItemModule.CreateInternal(AConnection, False);
end;

class procedure TNegociacaoItemModule.Finalize;
begin
  if Assigned(FInstance) then
  begin
    FInstance.Free;
    FInstance := nil;
  end;
end;

end.

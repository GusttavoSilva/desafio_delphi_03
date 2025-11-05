unit LimiteCreditoModule;

interface

uses
  System.SysUtils,
  FireDAC.Comp.Client,
  LimiteCreditoRepository.Intf,
  LimiteCreditoRepository.FB,
  LimiteCreditoController;

type
  TLimiteCreditoModule = class
  private
    FConnection: TFDConnection;
    FRepository: ILimiteCreditoRepository;
    FController: TLimiteCreditoController;
    FOwnsConnection: Boolean;
    class var FInstance: TLimiteCreditoModule;
    constructor CreateInternal(AConnection: TFDConnection; AOwnsConnection: Boolean);
  public
    destructor Destroy; override;

    class function Create(AConnection: TFDConnection): TLimiteCreditoModule;
    class function GetInstance: TLimiteCreditoModule;
    class procedure Initialize(AConnection: TFDConnection);
    class procedure Finalize;

    function GetRepository: ILimiteCreditoRepository;
    function GetController: TLimiteCreditoController;
    function GetConnection: TFDConnection;

    property Repository: ILimiteCreditoRepository read GetRepository;
    property Controller: TLimiteCreditoController read GetController;
    property Connection: TFDConnection read GetConnection;
  end;

implementation

{ TLimiteCreditoModule }

constructor TLimiteCreditoModule.CreateInternal(AConnection: TFDConnection; AOwnsConnection: Boolean);
begin
  inherited Create;
  FConnection := AConnection;
  FOwnsConnection := AOwnsConnection;
end;

destructor TLimiteCreditoModule.Destroy;
begin
  if Assigned(FController) then
    FController.Free;
  FRepository := nil;
  if FOwnsConnection and Assigned(FConnection) then
    FConnection.Free;
  inherited;
end;

class function TLimiteCreditoModule.Create(AConnection: TFDConnection): TLimiteCreditoModule;
begin
  if not Assigned(AConnection) then
    raise Exception.Create('Connection não pode ser nil.');
  Result := TLimiteCreditoModule.CreateInternal(AConnection, False);
end;

function TLimiteCreditoModule.GetConnection: TFDConnection;
begin
  Result := FConnection;
end;

function TLimiteCreditoModule.GetController: TLimiteCreditoController;
begin
  if not Assigned(FController) then
  begin
    if not Assigned(FRepository) then
      GetRepository;
    FController := TLimiteCreditoController.Create(FRepository);
  end;
  Result := FController;
end;

class function TLimiteCreditoModule.GetInstance: TLimiteCreditoModule;
begin
  if not Assigned(FInstance) then
    raise Exception.Create('TLimiteCreditoModule não foi inicializado.');
  Result := FInstance;
end;

function TLimiteCreditoModule.GetRepository: ILimiteCreditoRepository;
begin
  if not Assigned(FRepository) then
  begin
    if not Assigned(FConnection) then
      raise Exception.Create('Connection não está configurada.');
    FRepository := TLimiteCreditoRepositoryFB.Create(FConnection);
  end;
  Result := FRepository;
end;

class procedure TLimiteCreditoModule.Initialize(AConnection: TFDConnection);
begin
  if Assigned(FInstance) then
    raise Exception.Create('TLimiteCreditoModule já foi inicializado.');
  if not Assigned(AConnection) then
    raise Exception.Create('Connection não pode ser nil.');
  FInstance := TLimiteCreditoModule.CreateInternal(AConnection, False);
end;

class procedure TLimiteCreditoModule.Finalize;
begin
  if Assigned(FInstance) then
  begin
    FInstance.Free;
    FInstance := nil;
  end;
end;

end.

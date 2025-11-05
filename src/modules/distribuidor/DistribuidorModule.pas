unit DistribuidorModule;

interface

uses
  System.SysUtils,
  FireDAC.Comp.Client,
  DistribuidorRepository.Intf,
  DistribuidorRepository.FB,
  DistribuidorController;

type
  TDistribuidorModule = class
  private
    FConnection: TFDConnection;
    FRepository: IDistribuidorRepository;
    FController: TDistribuidorController;
    FOwnsConnection: Boolean;
    class var FInstance: TDistribuidorModule;
    constructor CreateInternal(AConnection: TFDConnection; AOwnsConnection: Boolean);
  public
    destructor Destroy; override;

    class function Create(AConnection: TFDConnection): TDistribuidorModule; overload;
    class function GetInstance: TDistribuidorModule;
    class procedure Initialize(AConnection: TFDConnection);
    class procedure Finalize;

    function GetRepository: IDistribuidorRepository;
    function GetController: TDistribuidorController;
    function GetConnection: TFDConnection;

    property Repository: IDistribuidorRepository read GetRepository;
    property Controller: TDistribuidorController read GetController;
    property Connection: TFDConnection read GetConnection;
  end;

implementation

{ TDistribuidorModule }

constructor TDistribuidorModule.CreateInternal(AConnection: TFDConnection; AOwnsConnection: Boolean);
begin
  inherited Create;
  FConnection := AConnection;
  FOwnsConnection := AOwnsConnection;
end;

destructor TDistribuidorModule.Destroy;
begin
  if Assigned(FController) then
    FController.Free;
  FRepository := nil;
  if FOwnsConnection and Assigned(FConnection) then
    FConnection.Free;
  inherited;
end;

class function TDistribuidorModule.Create(AConnection: TFDConnection): TDistribuidorModule;
begin
  if not Assigned(AConnection) then
    raise Exception.Create('Connection não pode ser nil.');
  Result := TDistribuidorModule.CreateInternal(AConnection, False);
end;

class function TDistribuidorModule.GetInstance: TDistribuidorModule;
begin
  if not Assigned(FInstance) then
    raise Exception.Create('TDistribuidorModule não inicializado.');
  Result := FInstance;
end;

class procedure TDistribuidorModule.Initialize(AConnection: TFDConnection);
begin
  if Assigned(FInstance) then
    raise Exception.Create('TDistribuidorModule já foi inicializado.');
  if not Assigned(AConnection) then
    raise Exception.Create('Connection não pode ser nil.');
  FInstance := TDistribuidorModule.CreateInternal(AConnection, False);
end;

class procedure TDistribuidorModule.Finalize;
begin
  FreeAndNil(FInstance);
end;

function TDistribuidorModule.GetRepository: IDistribuidorRepository;
begin
  if not Assigned(FRepository) then
    FRepository := TDistribuidorRepositoryFB.Create(FConnection);
  Result := FRepository;
end;

function TDistribuidorModule.GetController: TDistribuidorController;
begin
  if not Assigned(FController) then
    FController := TDistribuidorController.Create(GetRepository);
  Result := FController;
end;

function TDistribuidorModule.GetConnection: TFDConnection;
begin
  Result := FConnection;
end;

end.

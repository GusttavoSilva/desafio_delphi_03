unit ConnectionDataBase;

interface

uses
  System.SysUtils, System.Classes,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf,
  FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async,
  FireDAC.Phys, FireDAC.Phys.FB, FireDAC.Comp.Client, Data.DB,
  FireDAC.Phys.IBBase, FireDAC.Phys.FBDef, FireDAC.VCLUI.Wait, AppConfig;

type
  TdmConnection = class(TDataModule)
    FDConnection: TFDConnection;
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
  private
    FAppConfig: TAppConfig;
    FDriverLink: TFDPhysFBDriverLink;
    class var FInstance: TdmConnection;
    procedure ConfigureConnection;
  public
    class function GetInstance: TdmConnection;
    class procedure ReleaseInstance;

    procedure Connect;
    procedure Disconnect;
    function TestConnection: Boolean;
    procedure Reconnect;
  end;

var
  dmConnection: TdmConnection;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}
{$R *.dfm}

uses
  DatabaseMigrator;

procedure TdmConnection.ConfigureConnection;
var
  LDatabasePath: string;
begin
  FDConnection.Params.Clear;
  FDConnection.DriverName := 'FB';

  if Pos(':\', FAppConfig.DatabaseName) > 0 then
  begin
    LDatabasePath := FAppConfig.DatabaseName;
    FDConnection.Params.Values['Protocol'] := 'Local';
  end
  else
  begin
    LDatabasePath := Format('%s/%d:%s',
      [FAppConfig.DatabaseServer, FAppConfig.DatabasePort, FAppConfig.DatabaseName]);
    FDConnection.Params.Values['Protocol'] := 'TCPIP';
  end;

  FDConnection.Params.Values['Database'] := LDatabasePath;
  FDConnection.Params.Values['User_Name'] := FAppConfig.DatabaseUser;
  FDConnection.Params.Values['Password'] := FAppConfig.DatabasePassword;
  FDConnection.Params.Values['CharacterSet'] := FAppConfig.DatabaseCharset;
end;

class function TdmConnection.GetInstance: TdmConnection;
begin
  if not Assigned(FInstance) then
    FInstance := TdmConnection.Create(nil);
  Result := FInstance;
end;

class procedure TdmConnection.ReleaseInstance;
begin
  FreeAndNil(FInstance);
end;

procedure TdmConnection.DataModuleCreate(Sender: TObject);
var
  LVendorLib: string;
begin
  FAppConfig := TAppConfig.Create;
  // Create the Firebird driver link so the class is registered before streaming.
  FDriverLink := TFDPhysFBDriverLink.Create(Self);
  FDriverLink.DriverID := 'FB';
  LVendorLib := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0))) + 'fbclient.dll';
  if FileExists(LVendorLib) then
    FDriverLink.VendorLib := LVendorLib;
  FDConnection.LoginPrompt := False;
end;

procedure TdmConnection.DataModuleDestroy(Sender: TObject);
begin
  Disconnect;
  FAppConfig.Free;
end;

procedure TdmConnection.Connect;
var
  LDatabasePath: string;
  LMigrator: TDatabaseMigrator;
  LCreateConn: TFDConnection;
begin
  if FDConnection.Connected then
    Exit;

  try
    ConfigureConnection;
    LDatabasePath := FDConnection.Params.Values['Database'];

    // Verificar se é banco local
    if Pos(':\', LDatabasePath) > 0 then
    begin
      // Banco local - verificar se arquivo existe
      if not FileExists(LDatabasePath) then
      begin
        // Criar diretório se não existir
        if not DirectoryExists(ExtractFilePath(LDatabasePath)) then
          ForceDirectories(ExtractFilePath(LDatabasePath));

        // Criar banco vazio usando TFDConnection
        LCreateConn := TFDConnection.Create(nil);
        try
          LCreateConn.DriverName := 'FB';
          LCreateConn.Params.Values['User_Name'] := FAppConfig.DatabaseUser;
          LCreateConn.Params.Values['Password'] := FAppConfig.DatabasePassword;
          LCreateConn.Params.Values['CharacterSet'] := FAppConfig.DatabaseCharset;
          LCreateConn.Params.Values['Protocol'] := 'Local';
          LCreateConn.Params.Values['Database'] := LDatabasePath;
          LCreateConn.Params.Values['CreateDatabase'] := 'Yes';
          LCreateConn.LoginPrompt := False;
          
          // Esta ação cria o banco
          LCreateConn.Connected := True;
          LCreateConn.Connected := False;
        finally
          LCreateConn.Free;
        end;

        // Aguardar um pouco para garantir que o arquivo foi criado
        Sleep(300);
      end;
    end;

    // Conectar ao banco (agora ele deve existir)
    FDConnection.Connected := True;

    // Executar migrations
    LMigrator := TDatabaseMigrator.Create(FDConnection);
    try
      LMigrator.Execute;
    finally
      LMigrator.Free;
    end;
  except
    on E: Exception do
    begin
      LDatabasePath := FDConnection.Params.Values['Database'];
      if LDatabasePath.IsEmpty then
        LDatabasePath := FAppConfig.DatabaseName;
      raise Exception.CreateFmt('Erro ao conectar/criar banco de dados (%s): %s',
        [LDatabasePath, E.Message]);
    end;
  end;
end;

procedure TdmConnection.Disconnect;
begin
  if FDConnection.Connected then
    FDConnection.Connected := False;
end;

function TdmConnection.TestConnection: Boolean;
begin
  try
    ConfigureConnection;
    FDConnection.Connected := True;
    Result := True;
  finally
    FDConnection.Connected := False;
  end;
end;

procedure TdmConnection.Reconnect;
begin
  Disconnect;
  FAppConfig.Reload;
  Connect;
end;

end.


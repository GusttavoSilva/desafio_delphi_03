unit ConnectionDataBase;

interface

uses
  System.SysUtils, System.Classes,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf,
  FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async,
  FireDAC.Phys, FireDAC.Phys.FB, FireDAC.Comp.Client, Data.DB,
  FireDAC.Phys.IBBase, FireDAC.Phys.FBDef, FireDAC.VCLUI.Wait, AppConfig,  FireDAC.DApt;

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
  LQuery: TFDQuery;
  LCreateScript: string;
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
        // Criar banco automaticamente
        LQuery := TFDQuery.Create(nil);
        try
          LQuery.Connection := FDConnection;
          
          // Script para criar banco vazio no Firebird
          LCreateScript :=
            'EXECUTE BLOCK AS ' +
            'BEGIN ' +
            '  EXECUTE STATEMENT ''CREATE DATABASE ''' + QuotedStr(LDatabasePath) + ''' '' || ' +
            '    ''USER ''' + QuotedStr(FAppConfig.DatabaseUser) + ''' '' || ' +
            '    ''PASSWORD ''' + QuotedStr(FAppConfig.DatabasePassword) + ''' '' || ' +
            '    ''PAGE_SIZE 8192 '';' +
            'END';

          // Tentar conexão sem banco existente para criar
          FDConnection.Params.Values['Database'] := 'localhost:' + LDatabasePath;
          FDConnection.Connected := True;
          LQuery.ExecSQL(LCreateScript);
          FDConnection.Connected := False;
          
          // Reconfigurar e reconectar
          ConfigureConnection;
          FDConnection.Connected := True;
        finally
          LQuery.Free;
        end;
      end
      else
      begin
        // Arquivo existe, conectar normalmente
        FDConnection.Connected := True;
      end;
    end
    else
    begin
      // Banco remoto - conectar direto
      FDConnection.Connected := True;
    end;

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


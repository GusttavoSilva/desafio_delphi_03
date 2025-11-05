unit AppConfig;

interface

uses
  System.SysUtils, System.IniFiles, System.Classes;

type
  /// <summary>
  /// Configurações da aplicação
  /// Carrega e salva configurações em arquivo INI
  /// </summary>
  TAppConfig = class
  private
    FIniFile: TIniFile;
    FConfigFilePath: string;
    
    // Database
    FDatabaseServer: string;
    FDatabasePort: Integer;
    FDatabaseName: string;
    FDatabaseUser: string;
    FDatabasePassword: string;
    FDatabaseCharset: string;
    
    // Application
    FAppTitle: string;
    FAppVersion: string;
    
    procedure LoadFromFile;
    procedure SetDefaultValues;
    function DefaultDatabasePath: string;
    function EffectiveDatabaseName: string;
  public
    constructor Create(const AConfigFilePath: string = '');
    destructor Destroy; override;
    
    /// <summary>
    /// Salva as configurações no arquivo INI
    /// </summary>
    procedure SaveToFile;
    
    /// <summary>
    /// Recarrega as configurações do arquivo
    /// </summary>
    procedure Reload;
    
    /// <summary>
    /// Retorna string de conexão formatada para o banco
    /// </summary>
    function GetConnectionString: string;
    
    // Database Properties
    property DatabaseServer: string read FDatabaseServer write FDatabaseServer;
    property DatabasePort: Integer read FDatabasePort write FDatabasePort;
    property DatabaseName: string read FDatabaseName write FDatabaseName;
    property DatabaseUser: string read FDatabaseUser write FDatabaseUser;
    property DatabasePassword: string read FDatabasePassword write FDatabasePassword;
    property DatabaseCharset: string read FDatabaseCharset write FDatabaseCharset;
    
    // Application Properties
    property AppTitle: string read FAppTitle write FAppTitle;
    property AppVersion: string read FAppVersion write FAppVersion;
    
    property ConfigFilePath: string read FConfigFilePath;
  end;

implementation

{ TAppConfig }

constructor TAppConfig.Create(const AConfigFilePath: string);
begin
  inherited Create;
  
  // Define caminho do arquivo de configuração
  if AConfigFilePath.IsEmpty then
    FConfigFilePath := ExtractFilePath(ParamStr(0)) + 'config.ini'
  else
    FConfigFilePath := AConfigFilePath;
  
  FIniFile := TIniFile.Create(FConfigFilePath);
  
  // Carrega configurações ou define valores padrão
  if FileExists(FConfigFilePath) then
    LoadFromFile
  else
  begin
    SetDefaultValues;
    SaveToFile;
  end;
end;

destructor TAppConfig.Destroy;
begin
  FIniFile.Free;
  inherited;
end;

procedure TAppConfig.SetDefaultValues;
begin
  // Database - valores padrão para Firebird
  FDatabaseServer := 'localhost';
  FDatabasePort := 3050;
  FDatabaseName := DefaultDatabasePath;
  FDatabaseUser := 'SYSDBA';
  FDatabasePassword := 'masterkey';
  FDatabaseCharset := 'UTF8';
  
  // Application
  FAppTitle := 'Sistema Aliare';
  FAppVersion := '1.0.0';
end;

procedure TAppConfig.LoadFromFile;
begin
  // Database
  FDatabaseServer := FIniFile.ReadString('Database', 'Server', 'localhost');
  FDatabasePort := FIniFile.ReadInteger('Database', 'Port', 3050);
  FDatabaseName := FIniFile.ReadString('Database', 'DatabaseName', DefaultDatabasePath);
  FDatabaseUser := FIniFile.ReadString('Database', 'Username', 'SYSDBA');
  FDatabasePassword := FIniFile.ReadString('Database', 'Password', 'masterkey');
  FDatabaseCharset := FIniFile.ReadString('Database', 'Charset', 'UTF8');
  
  // Application
  FAppTitle := FIniFile.ReadString('Application', 'Title', 'Sistema Aliare');
  FAppVersion := FIniFile.ReadString('Application', 'Version', '1.0.0');
end;

procedure TAppConfig.SaveToFile;
begin
  // Database
  FIniFile.WriteString('Database', 'Server', FDatabaseServer);
  FIniFile.WriteInteger('Database', 'Port', FDatabasePort);
  FIniFile.WriteString('Database', 'DatabaseName', FDatabaseName);
  FIniFile.WriteString('Database', 'Username', FDatabaseUser);
  FIniFile.WriteString('Database', 'Password', FDatabasePassword);
  FIniFile.WriteString('Database', 'Charset', FDatabaseCharset);
  
  // Application
  FIniFile.WriteString('Application', 'Title', FAppTitle);
  FIniFile.WriteString('Application', 'Version', FAppVersion);
  
  FIniFile.UpdateFile;
end;

procedure TAppConfig.Reload;
begin
  LoadFromFile;
end;

function TAppConfig.GetConnectionString: string;
begin
  Result := Format('DriverID=FB;Protocol=TCPIP;Database=%s;User_Name=%s;Password=%s;CharacterSet=%s',
    [EffectiveDatabaseName, FDatabaseUser, FDatabasePassword, FDatabaseCharset]);
end;

function TAppConfig.DefaultDatabasePath: string;
var
  LBaseDir: string;
begin
  LBaseDir := IncludeTrailingPathDelimiter(ExtractFilePath(FConfigFilePath));
  Result := ExpandFileName(LBaseDir + '..\db\aliare.fdb');
end;

function TAppConfig.EffectiveDatabaseName: string;
begin
  if (Pos(':\', FDatabaseName) > 0) or (Copy(FDatabaseName, 1, 2) = '\\') then
    Result := FDatabaseName
  else
    Result := Format('%s/%d:%s', [FDatabaseServer, FDatabasePort, FDatabaseName]);
end;

end.

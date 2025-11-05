unit DatabaseMigrator;

interface

uses
  System.SysUtils, System.Generics.Collections, FireDAC.Stan.Param, Data.DB ,

  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf,
  FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async,
  FireDAC.Phys, FireDAC.Phys.FB, FireDAC.Comp.Client,
  FireDAC.Phys.IBBase, FireDAC.Phys.FBDef, FireDAC.VCLUI.Wait, FireDAC.DApt;

type
  TMigrationStep = record
    Id: string;
    Commands: TArray<string>;
  end;

  TDatabaseMigrator = class
  private
    FConnection: TFDConnection;
    procedure EnsureScriptsTable;
    function HasExecuted(const AId: string): Boolean;
    procedure MarkExecuted(const AId: string);
    procedure ExecuteCommands(const ACommands: TArray<string>);
    function GetMigrations: TArray<TMigrationStep>;
  public
    constructor Create(AConnection: TFDConnection);
    procedure Execute;
  end;

implementation

{ TDatabaseMigrator }

constructor TDatabaseMigrator.Create(AConnection: TFDConnection);
begin
  inherited Create;
  FConnection := AConnection;
end;

procedure TDatabaseMigrator.Execute;
var
  LStep: TMigrationStep;
begin
  EnsureScriptsTable;
  for LStep in GetMigrations do
  begin
    if HasExecuted(LStep.Id) then
      Continue;
    ExecuteCommands(LStep.Commands);
    MarkExecuted(LStep.Id);
  end;
end;

procedure TDatabaseMigrator.EnsureScriptsTable;
const
  CCreateScriptsTable =
    'EXECUTE BLOCK AS ' +
    'BEGIN ' +
    '  IF (NOT EXISTS (SELECT 1 FROM RDB$RELATIONS WHERE RDB$RELATION_NAME = ''SCRIPTS'')) THEN ' +
    '    EXECUTE STATEMENT ''CREATE TABLE SCRIPTS ('' || ' +
    '      ''ID VARCHAR(100) NOT NULL PRIMARY KEY, '' || ' +
    '      ''EXECUTED_AT TIMESTAMP NOT NULL, '' || ' +
    '      ''DESCRIPTION VARCHAR(255))''; ' +
    'END';
begin
  FConnection.ExecSQL(CCreateScriptsTable);
end;

procedure TDatabaseMigrator.ExecuteCommands(const ACommands: TArray<string>);
var
  LCommand: string;
begin
  for LCommand in ACommands do
  begin
    if Trim(LCommand).IsEmpty then
      Continue;
    FConnection.ExecSQL(LCommand);
  end;
end;

function TDatabaseMigrator.GetMigrations: TArray<TMigrationStep>;
var
  LMigrations: TList<TMigrationStep>;
  LStep: TMigrationStep;
begin
  LMigrations := TList<TMigrationStep>.Create;
  try
    LStep.Id := '001_CREATE_PRODUTOR';
    LStep.Commands := [
      'EXECUTE BLOCK AS ' +
      'BEGIN ' +
      '  IF (NOT EXISTS (SELECT 1 FROM RDB$RELATIONS WHERE RDB$RELATION_NAME = ''PRODUTOR'')) THEN ' +
      '    EXECUTE STATEMENT ''CREATE TABLE PRODUTOR ('' || ' +
      '      ''ID VARCHAR(38) NOT NULL, '' || ' +
      '      ''NOME VARCHAR(255) NOT NULL, '' || ' +
      '      ''CPF_CNPJ VARCHAR(18) NOT NULL, '' || ' +
      '      ''DATA_CRIACAO TIMESTAMP NOT NULL, '' || ' +
      '      ''DATA_ATUALIZACAO TIMESTAMP NOT NULL, '' || ' +
      '      ''CONSTRAINT PK_PRODUTOR PRIMARY KEY (ID))''; ' +
      'END',
      'EXECUTE BLOCK AS ' +
      'BEGIN ' +
      '  IF (NOT EXISTS (SELECT 1 FROM RDB$INDICES WHERE RDB$INDEX_NAME = ''IDX_PRODUTOR_DOC'')) THEN ' +
      '    EXECUTE STATEMENT ''CREATE UNIQUE INDEX IDX_PRODUTOR_DOC ON PRODUTOR (CPF_CNPJ)''; ' +
      'END'
    ];
    LMigrations.Add(LStep);

    LStep.Id := '002_CREATE_DISTRIBUIDOR';
    LStep.Commands := [
      'EXECUTE BLOCK AS ' +
      'BEGIN ' +
      '  IF (NOT EXISTS (SELECT 1 FROM RDB$RELATIONS WHERE RDB$RELATION_NAME = ''DISTRIBUIDOR'')) THEN ' +
      '    EXECUTE STATEMENT ''CREATE TABLE DISTRIBUIDOR ('' || ' +
      '      ''ID VARCHAR(38) NOT NULL, '' || ' +
      '      ''NOME VARCHAR(255) NOT NULL, '' || ' +
      '      ''CNPJ VARCHAR(18) NOT NULL, '' || ' +
      '      ''DATA_CRIACAO TIMESTAMP NOT NULL, '' || ' +
      '      ''DATA_ATUALIZACAO TIMESTAMP NOT NULL, '' || ' +
      '      ''CONSTRAINT PK_DISTRIBUIDOR PRIMARY KEY (ID))''; ' +
      'END',
      'EXECUTE BLOCK AS ' +
      'BEGIN ' +
      '  IF (NOT EXISTS (SELECT 1 FROM RDB$INDICES WHERE RDB$INDEX_NAME = ''IDX_DISTRIB_CNPJ'')) THEN ' +
      '    EXECUTE STATEMENT ''CREATE UNIQUE INDEX IDX_DISTRIB_CNPJ ON DISTRIBUIDOR (CNPJ)''; ' +
      'END'
    ];
    LMigrations.Add(LStep);

    LStep.Id := '003_CREATE_PRODUTO';
    LStep.Commands := [
      'EXECUTE BLOCK AS ' +
      'BEGIN ' +
      '  IF (NOT EXISTS (SELECT 1 FROM RDB$RELATIONS WHERE RDB$RELATION_NAME = ''PRODUTO'')) THEN ' +
      '    EXECUTE STATEMENT ''CREATE TABLE PRODUTO ('' || ' +
      '      ''ID VARCHAR(38) NOT NULL, '' || ' +
      '      ''NOME VARCHAR(255) NOT NULL, '' || ' +
      '      ''PRECO_VENDA NUMERIC(18,2) NOT NULL, '' || ' +
      '      ''DATA_CRIACAO TIMESTAMP NOT NULL, '' || ' +
      '      ''DATA_ATUALIZACAO TIMESTAMP NOT NULL, '' || ' +
      '      ''CONSTRAINT PK_PRODUTO PRIMARY KEY (ID))''; ' +
      'END'
    ];
    LMigrations.Add(LStep);

    LStep.Id := '004_CREATE_LIMITE_CREDITO';
    LStep.Commands := [
      'EXECUTE BLOCK AS ' +
      'BEGIN ' +
      '  IF (NOT EXISTS (SELECT 1 FROM RDB$RELATIONS WHERE RDB$RELATION_NAME = ''LIMITE_CREDITO'')) THEN ' +
      '    EXECUTE STATEMENT ''CREATE TABLE LIMITE_CREDITO ('' || ' +
      '      ''ID VARCHAR(38) NOT NULL, '' || ' +
      '      ''PRODUTOR_ID VARCHAR(38) NOT NULL, '' || ' +
      '      ''DISTRIBUIDOR_ID VARCHAR(38) NOT NULL, '' || ' +
      '      ''LIMITE NUMERIC(18,2) NOT NULL, '' || ' +
      '      ''DATA_CRIACAO TIMESTAMP NOT NULL, '' || ' +
      '      ''DATA_ATUALIZACAO TIMESTAMP NOT NULL, '' || ' +
      '      ''CONSTRAINT PK_LIMITE PRIMARY KEY (ID), '' || ' +
      '      ''CONSTRAINT UQ_LIMITE UNIQUE (PRODUTOR_ID, DISTRIBUIDOR_ID), '' || ' +
      '      ''CONSTRAINT FK_LIMITE_PROD FOREIGN KEY (PRODUTOR_ID) REFERENCES PRODUTOR(ID), '' || ' +
      '      ''CONSTRAINT FK_LIMITE_DIST FOREIGN KEY (DISTRIBUIDOR_ID) REFERENCES DISTRIBUIDOR(ID))''; ' +
      'END'
    ];
    LMigrations.Add(LStep);

    LStep.Id := '005_CREATE_NEGOCIACAO';
    LStep.Commands := [
      'EXECUTE BLOCK AS ' +
      'BEGIN ' +
      '  IF (NOT EXISTS (SELECT 1 FROM RDB$RELATIONS WHERE RDB$RELATION_NAME = ''NEGOCIACAO'')) THEN ' +
      '    EXECUTE STATEMENT ''CREATE TABLE NEGOCIACAO ('' || ' +
      '      ''ID VARCHAR(38) NOT NULL, '' || ' +
      '      ''PRODUTOR_ID VARCHAR(38) NOT NULL, '' || ' +
      '      ''DISTRIBUIDOR_ID VARCHAR(38) NOT NULL, '' || ' +
      '      ''VALOR_TOTAL NUMERIC(18,2) NOT NULL, '' || ' +
      '      ''STATUS VARCHAR(20) NOT NULL, '' || ' +
      '      ''DATA_CADASTRO TIMESTAMP NOT NULL, '' || ' +
      '      ''DATA_APROVACAO TIMESTAMP, '' || ' +
      '      ''DATA_CONCLUSAO TIMESTAMP, '' || ' +
      '      ''DATA_CANCELAMENTO TIMESTAMP, '' || ' +
      '      ''CONSTRAINT PK_NEGOC PRIMARY KEY (ID), '' || ' +
      '      ''CONSTRAINT CK_NEGOC_STATUS CHECK (STATUS IN (''''PENDENTE'''', ''''APROVADA'''', ''''CONCLUIDA'''', ''''CANCELADA'''')), '' || ' +
      '      ''CONSTRAINT FK_NEGOC_PROD FOREIGN KEY (PRODUTOR_ID) REFERENCES PRODUTOR(ID), '' || ' +
      '      ''CONSTRAINT FK_NEGOC_DIST FOREIGN KEY (DISTRIBUIDOR_ID) REFERENCES DISTRIBUIDOR(ID))''; ' +
      'END'
    ];
    LMigrations.Add(LStep);

    LStep.Id := '006_CREATE_NEGOC_ITEM';
    LStep.Commands := [
      'EXECUTE BLOCK AS ' +
      'BEGIN ' +
      '  IF (NOT EXISTS (SELECT 1 FROM RDB$RELATIONS WHERE RDB$RELATION_NAME = ''NEGOCIACAO_ITEM'')) THEN ' +
      '    EXECUTE STATEMENT ''CREATE TABLE NEGOCIACAO_ITEM ('' || ' +
      '      ''ID VARCHAR(38) NOT NULL, '' || ' +
      '      ''NEGOCIACAO_ID VARCHAR(38) NOT NULL, '' || ' +
      '      ''PRODUTO_ID VARCHAR(38) NOT NULL, '' || ' +
      '      ''QUANTIDADE NUMERIC(18,4) NOT NULL, '' || ' +
      '      ''PRECO_UNITARIO NUMERIC(18,2) NOT NULL, '' || ' +
      '      ''SUBTOTAL NUMERIC(18,2) NOT NULL, '' || ' +
      '      ''CONSTRAINT PK_NEGOC_ITEM PRIMARY KEY (ID), '' || ' +
      '      ''CONSTRAINT FK_ITEM_NEGOC FOREIGN KEY (NEGOCIACAO_ID) REFERENCES NEGOCIACAO(ID), '' || ' +
      '      ''CONSTRAINT FK_ITEM_PROD FOREIGN KEY (PRODUTO_ID) REFERENCES PRODUTO(ID))''; ' +
      'END',
      'EXECUTE BLOCK AS ' +
      'BEGIN ' +
      '  IF (NOT EXISTS (SELECT 1 FROM RDB$INDICES WHERE RDB$INDEX_NAME = ''IDX_ITEM_NEGOC'')) THEN ' +
      '    EXECUTE STATEMENT ''CREATE INDEX IDX_ITEM_NEGOC ON NEGOCIACAO_ITEM (NEGOCIACAO_ID)''; ' +
      'END'
    ];
    LMigrations.Add(LStep);

    Result := LMigrations.ToArray;
  finally
    LMigrations.Free;
  end;
end;

function TDatabaseMigrator.HasExecuted(const AId: string): Boolean;
var
  LQuery: TFDQuery;
begin
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := FConnection;
    LQuery.SQL.Text := 'SELECT 1 FROM SCRIPTS WHERE ID = :ID';
    LQuery.ParamByName('ID').AsString := AId;
    LQuery.Open;
    Result := not LQuery.IsEmpty;
  finally
    LQuery.Free;
  end;
end;

procedure TDatabaseMigrator.MarkExecuted(const AId: string);
var
  LQuery: TFDQuery;
begin
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := FConnection;
    LQuery.SQL.Text := 'INSERT INTO SCRIPTS (ID, EXECUTED_AT) VALUES (:ID, :EXECUTED_AT)';
    LQuery.ParamByName('ID').AsString := AId;
    LQuery.ParamByName('EXECUTED_AT').AsDateTime := Now;
    LQuery.ExecSQL;
  finally
    LQuery.Free;
  end;
end;

end.

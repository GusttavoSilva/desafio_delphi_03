unit GsBaseEntity;

interface

uses
  System.SysUtils, System.Rtti, System.TypInfo, System.Generics.Collections;

type
  // Atributos customizados para mapeamento
  TableAttribute = class(TCustomAttribute)
  private
    FTableName: string;
  public
    constructor Create(const ATableName: string);
    property TableName: string read FTableName;
  end;

  ColumnAttribute = class(TCustomAttribute)
  private
    FColumnName: string;
  public
    constructor Create(const AColumnName: string);
    property ColumnName: string read FColumnName;
  end;

  TEntityState = (esInsert, esUpdate, esDelete);

  TgsBaseEntity = class
  private
    FId: string;
    FCreatedAt: TDateTime;
    FUpdatedAt: TDateTime;
    FState: TEntityState;
  public
    constructor Create; virtual;
    procedure BeforeSave; virtual;
    procedure AfterSave; virtual;
    
    property Id: string read FId write FId;
    property CreatedAt: TDateTime read FCreatedAt write FCreatedAt;
    property UpdatedAt: TDateTime read FUpdatedAt write FUpdatedAt;
    property State: TEntityState read FState write FState;
  end;

implementation

{ TableAttribute }

constructor TableAttribute.Create(const ATableName: string);
begin
  inherited Create;
  FTableName := ATableName;
end;

{ ColumnAttribute }

constructor ColumnAttribute.Create(const AColumnName: string);
begin
  inherited Create;
  FColumnName := AColumnName;
end;

{ TgsBaseEntity }

constructor TgsBaseEntity.Create;
begin
  inherited Create;
  FId := '';
  FCreatedAt := Now;
  FUpdatedAt := Now;
  FState := esInsert;
end;

procedure TgsBaseEntity.BeforeSave;
begin
  FUpdatedAt := Now;
  if FState = esInsert then
  begin
    if FId = '' then
      FId := TGUID.NewGuid.ToString;
    FCreatedAt := Now;
  end;
end;

procedure TgsBaseEntity.AfterSave;
begin
  // Override em classes derivadas se necessário
end;

end.

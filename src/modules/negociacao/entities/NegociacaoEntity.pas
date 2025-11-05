unit NegociacaoEntity;

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections,
  GsBaseEntity, GsValidation, NegociacaoItemEntity;

type
  TNegociacaoStatus = (nsPendente, nsAprovada, nsConcluida, nsCancelada);

  [Table('negociacao')]
  TNegociacaoEntity = class(TgsBaseEntity)
  private
    FProdutorId: string;
    FDistribuidorId: string;
    FValorTotal: Currency;
    FStatus: string;
    FDataCadastro: TDateTime;
    FDataAprovacao: TDateTime;
    FDataConclusao: TDateTime;
    FDataCancelamento: TDateTime;
    FItens: TObjectList<TNegociacaoItemEntity>;
    function StatusToEnum: TNegociacaoStatus;
    procedure EnumToStatus(AStatus: TNegociacaoStatus);
  public
    constructor Create; override;
    destructor Destroy; override;
    procedure BeforeSave; override;
    
    procedure AdicionarItem(AItem: TNegociacaoItemEntity);
    function RemoverItem(AItem: TNegociacaoItemEntity): Boolean;

    [Column('produtor_id')]
    property ProdutorId: string read FProdutorId write FProdutorId;

    [Column('distribuidor_id')]
    property DistribuidorId: string read FDistribuidorId write FDistribuidorId;

    [Column('valor_total')]
    property ValorTotal: Currency read FValorTotal write FValorTotal;

    [Column('status')]
    property Status: string read FStatus write FStatus;

    [Column('data_cadastro')]
    property DataCadastro: TDateTime read FDataCadastro write FDataCadastro;

    [Column('data_aprovacao')]
    property DataAprovacao: TDateTime read FDataAprovacao write FDataAprovacao;

    [Column('data_conclusao')]
    property DataConclusao: TDateTime read FDataConclusao write FDataConclusao;

    [Column('data_cancelamento')]
    property DataCancelamento: TDateTime read FDataCancelamento write FDataCancelamento;

    property StatusEnum: TNegociacaoStatus read StatusToEnum write EnumToStatus;
    
    // Lista de itens da negociação (não persiste direto, é carregada separadamente)
    property Itens: TObjectList<TNegociacaoItemEntity> read FItens;
  end;

implementation

const
  CStatusStrings: array[TNegociacaoStatus] of string = (
    'PENDENTE',
    'APROVADA',
    'CONCLUIDA',
    'CANCELADA'
  );

{ TNegociacaoEntity }

constructor TNegociacaoEntity.Create;
begin
  inherited Create;
  FProdutorId := '';
  FDistribuidorId := '';
  FStatus := CStatusStrings[nsPendente];
  FValorTotal := 0;
  FDataCadastro := Now;
  FDataAprovacao := 0;
  FDataConclusao := 0;
  FDataCancelamento := 0;
  FItens := TObjectList<TNegociacaoItemEntity>.Create(True); // OwnsObjects = True
end;

destructor TNegociacaoEntity.Destroy;
begin
  FItens.Free;
  inherited;
end;

procedure TNegociacaoEntity.BeforeSave;
var
  LStatusValid: Boolean;
  LStatus: TNegociacaoStatus;
begin
  inherited;

  TgsValidation.IsRequired(FProdutorId, 'Produtor');
  TgsValidation.IsRequired(FDistribuidorId, 'Distribuidor');

  if FValorTotal < 0 then
    raise Exception.Create('Valor total não pode ser negativo.');

  LStatusValid := False;
  for LStatus := Low(TNegociacaoStatus) to High(TNegociacaoStatus) do
  begin
    if SameText(FStatus, CStatusStrings[LStatus]) then
    begin
      LStatusValid := True;
      Break;
    end;
  end;

  if not LStatusValid then
    raise Exception.Create('Status informado é inválido.');

  if (FStatus = 'APROVADA') and (FDataAprovacao = 0) then
    raise Exception.Create('Data de aprovação deve ser informada quando status for APROVADA.');

  if (FStatus = 'CONCLUIDA') and (FDataConclusao = 0) then
    raise Exception.Create('Data de conclusão deve ser informada quando status for CONCLUIDA.');

  if (FStatus = 'CANCELADA') and (FDataCancelamento = 0) then
    raise Exception.Create('Data de cancelamento deve ser informada quando status for CANCELADA.');
end;

procedure TNegociacaoEntity.EnumToStatus(AStatus: TNegociacaoStatus);
begin
  FStatus := CStatusStrings[AStatus];
end;

function TNegociacaoEntity.StatusToEnum: TNegociacaoStatus;
var
  LStatus: TNegociacaoStatus;
begin
  for LStatus := Low(TNegociacaoStatus) to High(TNegociacaoStatus) do
    if SameText(FStatus, CStatusStrings[LStatus]) then
      Exit(LStatus);
  raise Exception.Create('Status inválido armazenado na negociação.');
end;

procedure TNegociacaoEntity.AdicionarItem(AItem: TNegociacaoItemEntity);
begin
  if Assigned(AItem) then
    FItens.Add(AItem);
end;

function TNegociacaoEntity.RemoverItem(AItem: TNegociacaoItemEntity): Boolean;
begin
  Result := False;
  if Assigned(AItem) and Assigned(FItens) then
  begin
    Result := FItens.Remove(AItem) >= 0;
  end;
end;

end.

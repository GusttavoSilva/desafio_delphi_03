unit LimiteCreditoEntity;

interface

uses
  System.SysUtils, GsBaseEntity, GsValidation;

type
  [Table('limite_credito')]
  TLimiteCreditoEntity = class(TgsBaseEntity)
  private
    FProdutorId: string;
    FDistribuidorId: string;
    FLimite: Currency;
  public
    constructor Create; override;
    procedure BeforeSave; override;

    [Column('produtor_id')]
    property ProdutorId: string read FProdutorId write FProdutorId;

    [Column('distribuidor_id')]
    property DistribuidorId: string read FDistribuidorId write FDistribuidorId;

    [Column('limite')]
    property Limite: Currency read FLimite write FLimite;
  end;

implementation

{ TLimiteCreditoEntity }

constructor TLimiteCreditoEntity.Create;
begin
  inherited Create;
  FProdutorId := '';
  FDistribuidorId := '';
  FLimite := 0;
end;

procedure TLimiteCreditoEntity.BeforeSave;
begin
  inherited;

  TgsValidation.IsRequired(FProdutorId, 'Produtor');
  TgsValidation.IsRequired(FDistribuidorId, 'Distribuidor');

  if SameText(FProdutorId, FDistribuidorId) then
    raise Exception.Create('Produtor e Distribuidor devem ser distintos.');

  if FLimite <= 0 then
    raise Exception.Create('Limite deve ser maior que zero.');
end;

end.

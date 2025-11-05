unit NegociacaoItemEntity;

interface

uses
  System.SysUtils, GsBaseEntity, GsValidation;

type
  [Table('negociacao_item')]
  TNegociacaoItemEntity = class(TgsBaseEntity)
  private
    FNegociacaoId: string;
    FProdutoId: string;
    FQuantidade: Double;
    FPrecoUnitario: Currency;
    FSubtotal: Currency;
  public
    constructor Create; override;
    procedure BeforeSave; override;

    [Column('negociacao_id')]
    property NegociacaoId: string read FNegociacaoId write FNegociacaoId;

    [Column('produto_id')]
    property ProdutoId: string read FProdutoId write FProdutoId;

    [Column('quantidade')]
    property Quantidade: Double read FQuantidade write FQuantidade;

    [Column('preco_unitario')]
    property PrecoUnitario: Currency read FPrecoUnitario write FPrecoUnitario;

    [Column('subtotal')]
    property Subtotal: Currency read FSubtotal write FSubtotal;
  end;

implementation

{ TNegociacaoItemEntity }

constructor TNegociacaoItemEntity.Create;
begin
  inherited Create;
  FNegociacaoId := '';
  FProdutoId := '';
  FQuantidade := 0;
  FPrecoUnitario := 0;
  FSubtotal := 0;
end;

procedure TNegociacaoItemEntity.BeforeSave;
var
  LCalculado: Currency;
begin
  inherited;

  TgsValidation.IsRequired(FNegociacaoId, 'Negociação');
  TgsValidation.IsRequired(FProdutoId, 'Produto');

  if FQuantidade <= 0 then
    raise Exception.Create('Quantidade deve ser maior que zero.');

  if FPrecoUnitario <= 0 then
    raise Exception.Create('Preço unitário deve ser maior que zero.');

  LCalculado := FQuantidade * FPrecoUnitario;
  if Abs(LCalculado - FSubtotal) > 0.01 then
    raise Exception.Create('Subtotal deve ser igual à quantidade multiplicada pelo preço unitário.');
end;

end.

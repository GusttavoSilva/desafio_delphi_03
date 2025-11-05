unit ProdutoEntity;

interface

uses
  System.SysUtils, GsBaseEntity, GsValidation;

type
  [Table('produto')]
  TProdutoEntity = class(TgsBaseEntity)
  private
    FNome: string;
    FPrecoVenda: Currency;
  public
    constructor Create; override;
    procedure BeforeSave; override;

    [Column('nome')]
    property Nome: string read FNome write FNome;

    [Column('preco_venda')]
    property PrecoVenda: Currency read FPrecoVenda write FPrecoVenda;
  end;

implementation

{ TProdutoEntity }

constructor TProdutoEntity.Create;
begin
  inherited Create;
  FNome := '';
  FPrecoVenda := 0;
end;

procedure TProdutoEntity.BeforeSave;
begin
  inherited;

  TgsValidation.IsRequired(FNome, 'Nome');
  TgsValidation.MinLength(FNome, 2, 'Nome');
  TgsValidation.MaxLength(FNome, 255, 'Nome');

  if FPrecoVenda <= 0 then
    raise Exception.Create('Preço de venda deve ser maior que zero.');
end;

end.

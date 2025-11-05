unit DistribuidorEntity;

interface

uses
  System.SysUtils, GsBaseEntity, GsValidation;

type
  [Table('distribuidor')]
  TDistribuidorEntity = class(TgsBaseEntity)
  private
    FNome: string;
    FCnpj: string;
    procedure ValidateCnpj;
  public
    constructor Create; override;
    procedure BeforeSave; override;

    [Column('nome')]
    property Nome: string read FNome write FNome;

    [Column('cnpj')]
    property Cnpj: string read FCnpj write FCnpj;
  end;

implementation

{ TDistribuidorEntity }

constructor TDistribuidorEntity.Create;
begin
  inherited Create;
  FNome := '';
  FCnpj := '';
end;

procedure TDistribuidorEntity.BeforeSave;
begin
  inherited;

  TgsValidation.IsRequired(FNome, 'Nome');
  TgsValidation.MinLength(FNome, 3, 'Nome');
  TgsValidation.MaxLength(FNome, 255, 'Nome');

  TgsValidation.IsRequired(FCnpj, 'CNPJ');
  ValidateCnpj;
end;

procedure TDistribuidorEntity.ValidateCnpj;
begin
  if not TgsValidation.IsValidCNPJ(FCnpj) then
    raise Exception.Create('CNPJ inválido.');
end;

end.

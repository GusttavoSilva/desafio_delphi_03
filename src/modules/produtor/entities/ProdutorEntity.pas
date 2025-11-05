unit ProdutorEntity;

interface

uses
  System.SysUtils, GsBaseEntity, GsValidation;

type
  [Table('produtor')]
  TProdutorEntity = class(TgsBaseEntity)
  private
    FNome: string;
    FCpfCnpj: string;
    procedure ValidateCpfCnpj;
  public
    constructor Create; override;
    procedure BeforeSave; override;
    
    [Column('nome')]
    property Nome: string read FNome write FNome;
    
    [Column('cpf_cnpj')]
    property CpfCnpj: string read FCpfCnpj write FCpfCnpj;
  end;

implementation

{ TProdutorEntity }

constructor TProdutorEntity.Create;
begin
  inherited Create;
  FNome := '';
  FCpfCnpj := '';
end;

procedure TProdutorEntity.BeforeSave;
begin
  inherited;
  
  // Validações automáticas antes de salvar
  TgsValidation.IsRequired(FNome, 'Nome');
  TgsValidation.MinLength(FNome, 3, 'Nome');
  TgsValidation.MaxLength(FNome, 255, 'Nome');
  
  TgsValidation.IsRequired(FCpfCnpj, 'CPF/CNPJ');
  ValidateCpfCnpj;
end;

procedure TProdutorEntity.ValidateCpfCnpj;
var
  LDocLimpo: string;
begin
  // Remove caracteres não numéricos
  LDocLimpo := FCpfCnpj.Replace('.', '').Replace('-', '').Replace('/', '').Trim;
  
  // Verifica se é CPF (11 dígitos) ou CNPJ (14 dígitos)
  if Length(LDocLimpo) = 11 then
  begin
    if not TgsValidation.IsValidCPF(FCpfCnpj) then
      raise Exception.Create('CPF inválido.');
  end
  else if Length(LDocLimpo) = 14 then
  begin
    if not TgsValidation.IsValidCNPJ(FCpfCnpj) then
      raise Exception.Create('CNPJ inválido.');
  end
  else
    raise Exception.Create('CPF/CNPJ deve conter 11 (CPF) ou 14 (CNPJ) dígitos.');
end;

end.

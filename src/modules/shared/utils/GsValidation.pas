unit GsValidation;

interface

uses
  System.SysUtils, System.RegularExpressions;

type
  TgsValidation = class
  public
    class function IsEmpty(const AValue: string): Boolean;
    class function IsValidEmail(const AEmail: string): Boolean;
    class function IsValidCPF(const ACPF: string): Boolean;
    class function IsValidCNPJ(const ACNPJ: string): Boolean;
    class function IsRequired(const AValue: string; const AFieldName: string): Boolean;
    class function MinLength(const AValue: string; const AMinLength: Integer; const AFieldName: string): Boolean;
    class function MaxLength(const AValue: string; const AMaxLength: Integer; const AFieldName: string): Boolean;
    class function IsNumeric(const AValue: string): Boolean;
    class function IsValidPhone(const APhone: string): Boolean;
    class function IsValidDate(const ADate: string): Boolean;
    class function TratarValorMonetario(const ATexto: string): Currency;
    
    // Formatação
    class function FormatarCPF(const ACPF: string): string;
    class function FormatarCNPJ(const ACNPJ: string): string;
    class function FormatarCPFCNPJ(const ADocumento: string): string;
    class function FormatarTelefone(const ATelefone: string): string;
    class function RemoverFormatacao(const ATexto: string): string;
    
    // Validação de valores monetários
    class function ValidarValorPositivo(const AValor: Currency; const AFieldName: string): Boolean;
    class function ValidarValorMaiorQueZero(const AValor: Currency; const AFieldName: string): Boolean;
  end;

implementation

{ TgsValidation }

class function TgsValidation.IsEmpty(const AValue: string): Boolean;
begin
  Result := AValue.Trim.IsEmpty;
end;

class function TgsValidation.IsValidEmail(const AEmail: string): Boolean;
const
  EMAIL_PATTERN = '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
begin
  Result := TRegEx.IsMatch(AEmail, EMAIL_PATTERN);
end;

class function TgsValidation.IsValidCPF(const ACPF: string): Boolean;
var
  LDigits: string;
  I, LSum, LRemainder, LDigit1, LDigit2: Integer;
begin
  Result := False;
  
  // Remove caracteres não numéricos
  LDigits := TRegEx.Replace(ACPF, '[^0-9]', '');
  
  if Length(LDigits) <> 11 then
    Exit;
    
  // Verifica se todos os dígitos são iguais
  if LDigits = StringOfChar(LDigits[1], 11) then
    Exit;
    
  // Calcula o primeiro dígito verificador
  LSum := 0;
  for I := 1 to 9 do
    LSum := LSum + StrToInt(LDigits[I]) * (11 - I);
  LRemainder := (LSum * 10) mod 11;
  if LRemainder = 10 then
    LRemainder := 0;
  LDigit1 := LRemainder;
  
  if LDigit1 <> StrToInt(LDigits[10]) then
    Exit;
    
  // Calcula o segundo dígito verificador
  LSum := 0;
  for I := 1 to 10 do
    LSum := LSum + StrToInt(LDigits[I]) * (12 - I);
  LRemainder := (LSum * 10) mod 11;
  if LRemainder = 10 then
    LRemainder := 0;
  LDigit2 := LRemainder;
  
  Result := (LDigit2 = StrToInt(LDigits[11]));
end;

class function TgsValidation.IsValidCNPJ(const ACNPJ: string): Boolean;
var
  LDigits: string;
  I, LSum, LRemainder, LDigit1, LDigit2: Integer;
  LWeights1, LWeights2: array[1..12] of Integer;
begin
  Result := False;
  
  // Remove caracteres não numéricos
  LDigits := TRegEx.Replace(ACNPJ, '[^0-9]', '');
  
  if Length(LDigits) <> 14 then
    Exit;
    
  // Verifica se todos os dígitos são iguais
  if LDigits = StringOfChar(LDigits[1], 14) then
    Exit;
    
  // Pesos para o primeiro dígito
  LWeights1[1] := 5; LWeights1[2] := 4; LWeights1[3] := 3; LWeights1[4] := 2;
  LWeights1[5] := 9; LWeights1[6] := 8; LWeights1[7] := 7; LWeights1[8] := 6;
  LWeights1[9] := 5; LWeights1[10] := 4; LWeights1[11] := 3; LWeights1[12] := 2;
  
  // Calcula o primeiro dígito verificador
  LSum := 0;
  for I := 1 to 12 do
    LSum := LSum + StrToInt(LDigits[I]) * LWeights1[I];
  LRemainder := LSum mod 11;
  if LRemainder < 2 then
    LDigit1 := 0
  else
    LDigit1 := 11 - LRemainder;
    
  if LDigit1 <> StrToInt(LDigits[13]) then
    Exit;
    
  // Pesos para o segundo dígito
  LWeights2[1] := 6; LWeights2[2] := 5; LWeights2[3] := 4; LWeights2[4] := 3;
  LWeights2[5] := 2; LWeights2[6] := 9; LWeights2[7] := 8; LWeights2[8] := 7;
  LWeights2[9] := 6; LWeights2[10] := 5; LWeights2[11] := 4; LWeights2[12] := 3;
  
  // Calcula o segundo dígito verificador
  LSum := 0;
  for I := 1 to 12 do
    LSum := LSum + StrToInt(LDigits[I]) * LWeights2[I];
  LSum := LSum + LDigit1 * 2;
  LRemainder := LSum mod 11;
  if LRemainder < 2 then
    LDigit2 := 0
  else
    LDigit2 := 11 - LRemainder;
    
  Result := (LDigit2 = StrToInt(LDigits[14]));
end;

class function TgsValidation.IsRequired(const AValue: string; const AFieldName: string): Boolean;
begin
  Result := not IsEmpty(AValue);
  if not Result then
    raise Exception.CreateFmt('O campo "%s" é obrigatório.', [AFieldName]);
end;

class function TgsValidation.MinLength(const AValue: string; const AMinLength: Integer; const AFieldName: string): Boolean;
begin
  Result := Length(AValue) >= AMinLength;
  if not Result then
    raise Exception.CreateFmt('O campo "%s" deve ter no mínimo %d caracteres.', [AFieldName, AMinLength]);
end;

class function TgsValidation.MaxLength(const AValue: string; const AMaxLength: Integer; const AFieldName: string): Boolean;
begin
  Result := Length(AValue) <= AMaxLength;
  if not Result then
    raise Exception.CreateFmt('O campo "%s" deve ter no máximo %d caracteres.', [AFieldName, AMaxLength]);
end;

class function TgsValidation.IsNumeric(const AValue: string): Boolean;
var
  LDummy: Extended;
begin
  Result := TryStrToFloat(AValue, LDummy);
end;

class function TgsValidation.IsValidPhone(const APhone: string): Boolean;
var
  LDigits: string;
begin
  // Remove caracteres não numéricos
  LDigits := TRegEx.Replace(APhone, '[^0-9]', '');
  
  // Telefone fixo: 10 dígitos (com DDD) ou celular: 11 dígitos (com DDD e 9)
  Result := (Length(LDigits) = 10) or (Length(LDigits) = 11);
end;

class function TgsValidation.IsValidDate(const ADate: string): Boolean;
var
  LDummy: TDateTime;
begin
  Result := TryStrToDate(ADate, LDummy);
end;

class function TgsValidation.TratarValorMonetario(const ATexto: string): Currency;
var
  LTextoLimpo: string;
  LFormatSettings: TFormatSettings;
begin
  // Remove pontos de milhares e substitui vírgula por ponto
  LTextoLimpo := TRegEx.Replace(ATexto, '\.', '');
  LTextoLimpo := StringReplace(LTextoLimpo, ',', '.', [rfReplaceAll]);
  LTextoLimpo := Trim(LTextoLimpo);
  
  if LTextoLimpo.IsEmpty then
    Result := 0
  else
    try
      LFormatSettings := TFormatSettings.Create;
      LFormatSettings.DecimalSeparator := '.';
      Result := StrToCurr(LTextoLimpo, LFormatSettings);
    except
      Result := 0;
    end;
end;

class function TgsValidation.FormatarCPF(const ACPF: string): string;
var
  LDigits: string;
begin
  LDigits := RemoverFormatacao(ACPF);
  if Length(LDigits) = 11 then
    Result := Format('%s.%s.%s-%s', [
      Copy(LDigits, 1, 3),
      Copy(LDigits, 4, 3),
      Copy(LDigits, 7, 3),
      Copy(LDigits, 10, 2)
    ])
  else
    Result := ACPF;
end;

class function TgsValidation.FormatarCNPJ(const ACNPJ: string): string;
var
  LDigits: string;
begin
  LDigits := RemoverFormatacao(ACNPJ);
  if Length(LDigits) = 14 then
    Result := Format('%s.%s.%s/%s-%s', [
      Copy(LDigits, 1, 2),
      Copy(LDigits, 3, 3),
      Copy(LDigits, 6, 3),
      Copy(LDigits, 9, 4),
      Copy(LDigits, 13, 2)
    ])
  else
    Result := ACNPJ;
end;

class function TgsValidation.FormatarCPFCNPJ(const ADocumento: string): string;
var
  LDigits: string;
begin
  LDigits := RemoverFormatacao(ADocumento);
  case Length(LDigits) of
    11: Result := FormatarCPF(ADocumento);
    14: Result := FormatarCNPJ(ADocumento);
  else
    Result := ADocumento;
  end;
end;

class function TgsValidation.FormatarTelefone(const ATelefone: string): string;
var
  LDigits: string;
begin
  LDigits := RemoverFormatacao(ATelefone);
  case Length(LDigits) of
    10: Result := Format('(%s) %s-%s', [
          Copy(LDigits, 1, 2),
          Copy(LDigits, 3, 4),
          Copy(LDigits, 7, 4)
        ]);
    11: Result := Format('(%s) %s-%s', [
          Copy(LDigits, 1, 2),
          Copy(LDigits, 3, 5),
          Copy(LDigits, 8, 4)
        ]);
  else
    Result := ATelefone;
  end;
end;

class function TgsValidation.RemoverFormatacao(const ATexto: string): string;
begin
  Result := TRegEx.Replace(ATexto, '[^0-9]', '');
end;

class function TgsValidation.ValidarValorPositivo(const AValor: Currency; const AFieldName: string): Boolean;
begin
  Result := AValor >= 0;
  if not Result then
    raise Exception.CreateFmt('%s deve ser um valor positivo.', [AFieldName]);
end;

class function TgsValidation.ValidarValorMaiorQueZero(const AValor: Currency; const AFieldName: string): Boolean;
begin
  Result := AValor > 0;
  if not Result then
    raise Exception.CreateFmt('%s deve ser maior que zero.', [AFieldName]);
end;

end.

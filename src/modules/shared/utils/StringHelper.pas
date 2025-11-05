unit StringHelper;

interface

uses
  System.SysUtils,
  System.Classes;

type
  TStringHelper = class
  public
    // Manipulação de strings
    class function RemoverEspacosDuplicados(const ATexto: string): string;
    class function PrimeiraLetraMaiuscula(const ATexto: string): string;
    class function TodasPrimeirasMaiusculas(const ATexto: string): string;
    class function RemoverAcentos(const ATexto: string): string;
    
    // Conversões seguras
    class function ToIntegerSafe(const ATexto: string; const AValorPadrao: Integer = 0): Integer;
    class function ToFloatSafe(const ATexto: string; const AValorPadrao: Double = 0): Double;
    class function ToCurrencySafe(const ATexto: string; const AValorPadrao: Currency = 0): Currency;
    class function ToDateTimeSafe(const ATexto: string; const AValorPadrao: TDateTime): TDateTime;
    
    // Verificações
    class function ContemTexto(const ATexto, ABusca: string; ACaseSensitive: Boolean = False): Boolean;
    class function ComecaCom(const ATexto, APrefixo: string; ACaseSensitive: Boolean = False): Boolean;
    class function TerminaCom(const ATexto, ASufixo: string; ACaseSensitive: Boolean = False): Boolean;
    
    // Formatação
    class function ZerosEsquerda(const ANumero: Integer; const ATamanho: Integer): string;
    class function TruncateString(const ATexto: string; AMaxLength: Integer; const AReticencias: Boolean = True): string;
  end;

implementation

uses
  System.StrUtils, System.Character;

{ TStringHelper }

class function TStringHelper.RemoverEspacosDuplicados(const ATexto: string): string;
var
  I: Integer;
  LUltimoFoiEspaco: Boolean;
begin
  Result := '';
  LUltimoFoiEspaco := False;
  
  for I := 1 to Length(ATexto) do
  begin
    if ATexto[I] = ' ' then
    begin
      if not LUltimoFoiEspaco then
      begin
        Result := Result + ATexto[I];
        LUltimoFoiEspaco := True;
      end;
    end
    else
    begin
      Result := Result + ATexto[I];
      LUltimoFoiEspaco := False;
    end;
  end;
  
  Result := Trim(Result);
end;

class function TStringHelper.PrimeiraLetraMaiuscula(const ATexto: string): string;
begin
  if ATexto.IsEmpty then
    Exit('');
    
  Result := ATexto.ToLower;
  Result[1] := UpCase(Result[1]);
end;

class function TStringHelper.TodasPrimeirasMaiusculas(const ATexto: string): string;
var
  LPalavras: TArray<string>;
  I: Integer;
begin
  LPalavras := ATexto.Split([' ']);
  
  for I := Low(LPalavras) to High(LPalavras) do
    if not LPalavras[I].IsEmpty then
      LPalavras[I] := PrimeiraLetraMaiuscula(LPalavras[I]);
      
  Result := string.Join(' ', LPalavras);
end;

class function TStringHelper.RemoverAcentos(const ATexto: string): string;
const
  ComAcento = 'ÀÁÂÃÄÅàáâãäåÈÉÊËèéêëÌÍÎÏìíîïÒÓÔÕÖòóôõöÙÚÛÜùúûüÇçÑñ';
  SemAcento = 'AAAAAAaaaaaaEEEEeeeeIIIIiiiiOOOOOoooooUUUUuuuuCcNn';
var
  I, J: Integer;
begin
  Result := ATexto;
  for I := 1 to Length(Result) do
  begin
    J := Pos(Result[I], ComAcento);
    if J > 0 then
      Result[I] := SemAcento[J];
  end;
end;

class function TStringHelper.ToIntegerSafe(const ATexto: string; const AValorPadrao: Integer): Integer;
begin
  if not TryStrToInt(ATexto, Result) then
    Result := AValorPadrao;
end;

class function TStringHelper.ToFloatSafe(const ATexto: string; const AValorPadrao: Double): Double;
begin
  if not TryStrToFloat(ATexto, Result) then
    Result := AValorPadrao;
end;

class function TStringHelper.ToCurrencySafe(const ATexto: string; const AValorPadrao: Currency): Currency;
begin
  if not TryStrToCurr(ATexto, Result) then
    Result := AValorPadrao;
end;

class function TStringHelper.ToDateTimeSafe(const ATexto: string; const AValorPadrao: TDateTime): TDateTime;
begin
  if not TryStrToDateTime(ATexto, Result) then
    Result := AValorPadrao;
end;

class function TStringHelper.ContemTexto(const ATexto, ABusca: string; ACaseSensitive: Boolean): Boolean;
begin
  if ACaseSensitive then
    Result := ContainsStr(ATexto, ABusca)
  else
    Result := ContainsText(ATexto, ABusca);
end;

class function TStringHelper.ComecaCom(const ATexto, APrefixo: string; ACaseSensitive: Boolean): Boolean;
begin
  if ACaseSensitive then
    Result := StartsStr(APrefixo, ATexto)
  else
    Result := StartsText(APrefixo, ATexto);
end;

class function TStringHelper.TerminaCom(const ATexto, ASufixo: string; ACaseSensitive: Boolean): Boolean;
begin
  if ACaseSensitive then
    Result := EndsStr(ASufixo, ATexto)
  else
    Result := EndsText(ASufixo, ATexto);
end;

class function TStringHelper.ZerosEsquerda(const ANumero: Integer; const ATamanho: Integer): string;
begin
  Result := Format('%.*d', [ATamanho, ANumero]);
end;

class function TStringHelper.TruncateString(const ATexto: string; AMaxLength: Integer; const AReticencias: Boolean): string;
begin
  if Length(ATexto) <= AMaxLength then
    Exit(ATexto);
    
  if AReticencias and (AMaxLength > 3) then
    Result := Copy(ATexto, 1, AMaxLength - 3) + '...'
  else
    Result := Copy(ATexto, 1, AMaxLength);
end;

end.

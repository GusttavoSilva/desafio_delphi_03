unit DataSetHelper;

interface

uses
  System.SysUtils,
  Data.DB,
  FireDAC.Comp.Client;

type
  TDataSetHelper = class
  public
    // Inicialização de DataSet
    class procedure InicializarMemTable(ADataSet: TFDMemTable);
    class procedure AdicionarCampo(ADataSet: TFDMemTable; const ANome: string; 
      ATipo: TFieldType; ATamanho: Integer = 0);
    class procedure CriarDataSet(ADataSet: TFDMemTable);
    
    // Operações com DataSet
    class procedure LimparDataSet(ADataSet: TDataSet);
    class function DataSetVazio(ADataSet: TDataSet): Boolean;
    class function ObterValorCampo(ADataSet: TDataSet; const ANomeCampo: string; 
      const AValorPadrao: Variant): Variant;
    
    // Navegação
    class procedure PrimeiroRegistro(ADataSet: TDataSet);
    class procedure UltimoRegistro(ADataSet: TDataSet);
    class function TemRegistros(ADataSet: TDataSet): Boolean;
  end;

implementation

{ TDataSetHelper }

class procedure TDataSetHelper.InicializarMemTable(ADataSet: TFDMemTable);
begin
  if not Assigned(ADataSet) then
    Exit;
    
  ADataSet.Close;
  ADataSet.FieldDefs.Clear;
end;

class procedure TDataSetHelper.AdicionarCampo(ADataSet: TFDMemTable; 
  const ANome: string; ATipo: TFieldType; ATamanho: Integer);
begin
  if not Assigned(ADataSet) then
    Exit;
    
  if ATamanho > 0 then
    ADataSet.FieldDefs.Add(ANome, ATipo, ATamanho)
  else
    ADataSet.FieldDefs.Add(ANome, ATipo);
end;

class procedure TDataSetHelper.CriarDataSet(ADataSet: TFDMemTable);
begin
  if Assigned(ADataSet) then
    ADataSet.CreateDataSet;
end;

class procedure TDataSetHelper.LimparDataSet(ADataSet: TDataSet);
begin
  if not Assigned(ADataSet) then
    Exit;
    
  if ADataSet.Active then
  begin
    ADataSet.DisableControls;
    try
      ADataSet.First;
      while not ADataSet.Eof do
        ADataSet.Delete;
    finally
      ADataSet.EnableControls;
    end;
  end;
end;

class function TDataSetHelper.DataSetVazio(ADataSet: TDataSet): Boolean;
begin
  Result := not Assigned(ADataSet) or ADataSet.IsEmpty;
end;

class function TDataSetHelper.ObterValorCampo(ADataSet: TDataSet; 
  const ANomeCampo: string; const AValorPadrao: Variant): Variant;
var
  LField: TField;
begin
  Result := AValorPadrao;
  
  if not Assigned(ADataSet) or not ADataSet.Active then
    Exit;
    
  LField := ADataSet.FindField(ANomeCampo);
  if Assigned(LField) and not LField.IsNull then
    Result := LField.Value;
end;

class procedure TDataSetHelper.PrimeiroRegistro(ADataSet: TDataSet);
begin
  if Assigned(ADataSet) and ADataSet.Active and not ADataSet.IsEmpty then
    ADataSet.First;
end;

class procedure TDataSetHelper.UltimoRegistro(ADataSet: TDataSet);
begin
  if Assigned(ADataSet) and ADataSet.Active and not ADataSet.IsEmpty then
    ADataSet.Last;
end;

class function TDataSetHelper.TemRegistros(ADataSet: TDataSet): Boolean;
begin
  Result := Assigned(ADataSet) and ADataSet.Active and not ADataSet.IsEmpty;
end;

end.

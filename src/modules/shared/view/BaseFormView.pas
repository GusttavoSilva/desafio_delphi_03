unit BaseFormView;

interface

uses
  System.SysUtils,
  System.Classes,
  Vcl.Forms,
  Vcl.Controls,
  Vcl.ComCtrls,
  Vcl.StdCtrls,
  Data.DB,
  FireDAC.Comp.Client;

type
  TBaseFormView = class(TForm)
  protected
    // Métodos auxiliares para navegação entre abas
    procedure AtivarAba(APageControl: TPageControl; ATabSheet: TTabSheet);
    
    // Métodos auxiliares para habilitação de controles
    procedure HabilitarControle(AControl: TControl; AHabilitar: Boolean);
    procedure HabilitarControles(AControles: array of TControl; AHabilitar: Boolean);
    
    // Métodos auxiliares para limpeza de campos
    procedure LimparEdit(AEdit: TEdit);
    procedure LimparEdits(AEdits: array of TEdit);
    
    // Métodos auxiliares para inicialização de DataSet
    procedure AdicionarCampoDataSet(ADataSet: TFDMemTable; const ANome: string; 
      ATipo: TFieldType; ATamanho: Integer = 0);
  public
    { Public declarations }
  end;

implementation

{ TBaseFormView }

procedure TBaseFormView.AtivarAba(APageControl: TPageControl; ATabSheet: TTabSheet);
begin
  if Assigned(APageControl) and Assigned(ATabSheet) then
    APageControl.ActivePage := ATabSheet;
end;

procedure TBaseFormView.HabilitarControle(AControl: TControl; AHabilitar: Boolean);
begin
  if Assigned(AControl) then
    AControl.Enabled := AHabilitar;
end;

procedure TBaseFormView.HabilitarControles(AControles: array of TControl; AHabilitar: Boolean);
var
  I: Integer;
begin
  for I := Low(AControles) to High(AControles) do
    HabilitarControle(AControles[I], AHabilitar);
end;

procedure TBaseFormView.LimparEdit(AEdit: TEdit);
begin
  if Assigned(AEdit) then
    AEdit.Clear;
end;

procedure TBaseFormView.LimparEdits(AEdits: array of TEdit);
var
  I: Integer;
begin
  for I := Low(AEdits) to High(AEdits) do
    LimparEdit(AEdits[I]);
end;

procedure TBaseFormView.AdicionarCampoDataSet(ADataSet: TFDMemTable; 
  const ANome: string; ATipo: TFieldType; ATamanho: Integer);
begin
  if not Assigned(ADataSet) then
    Exit;
    
  if ATamanho > 0 then
    ADataSet.FieldDefs.Add(ANome, ATipo, ATamanho)
  else
    ADataSet.FieldDefs.Add(ANome, ATipo);
end;

end.

unit BaseController;

interface

uses
  System.SysUtils,
  GsBaseEntity;

type
  TBaseController = class
  protected
    // Validações comuns
    procedure ValidarEntidadeNaoNula(AEntity: TgsBaseEntity; const AMensagem: string = '');
    procedure ValidarIdNaoVazio(const AId: string; const AMensagem: string = '');
    procedure ValidarEstadoParaPersistencia(AEntity: TgsBaseEntity);
    
    // Mensagens de erro padronizadas
    function MensagemErroEntidadeInvalida(const ATipoEntidade: string): string;
    function MensagemErroIdInvalido(const ATipoEntidade: string): string;
    function MensagemErroEstadoInvalido: string;
    function MensagemErroNaoEncontrado(const ATipoEntidade: string): string;
  public
    { Public declarations }
  end;

implementation

{ TBaseController }

procedure TBaseController.ValidarEntidadeNaoNula(AEntity: TgsBaseEntity; const AMensagem: string);
begin
  if not Assigned(AEntity) then
  begin
    if AMensagem.IsEmpty then
      raise Exception.Create('Entidade inválida.')
    else
      raise Exception.Create(AMensagem);
  end;
end;

procedure TBaseController.ValidarIdNaoVazio(const AId: string; const AMensagem: string);
begin
  if AId.Trim.IsEmpty then
  begin
    if AMensagem.IsEmpty then
      raise Exception.Create('ID inválido.')
    else
      raise Exception.Create(AMensagem);
  end;
end;

procedure TBaseController.ValidarEstadoParaPersistencia(AEntity: TgsBaseEntity);
begin
  if not (AEntity.State in [esInsert, esUpdate]) then
    raise Exception.Create(MensagemErroEstadoInvalido);
end;

function TBaseController.MensagemErroEntidadeInvalida(const ATipoEntidade: string): string;
begin
  Result := Format('%s não pode ser nulo.', [ATipoEntidade]);
end;

function TBaseController.MensagemErroIdInvalido(const ATipoEntidade: string): string;
begin
  Result := Format('ID do %s é inválido.', [ATipoEntidade]);
end;

function TBaseController.MensagemErroEstadoInvalido: string;
begin
  Result := 'Estado da entidade inválido para persistência.';
end;

function TBaseController.MensagemErroNaoEncontrado(const ATipoEntidade: string): string;
begin
  Result := Format('%s não encontrado(a).', [ATipoEntidade]);
end;

end.

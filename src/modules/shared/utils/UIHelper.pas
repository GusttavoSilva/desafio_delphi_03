unit UIHelper;

interface

uses
  System.SysUtils,
  Vcl.Dialogs,
  System.UITypes;

type
  TUIHelper = class
  public
    // Mensagens de sucesso
    class procedure MostrarSucesso(const AMensagem: string);
    class procedure MostrarSalvoComSucesso(const ATipoEntidade: string);
    class procedure MostrarExcluidoComSucesso(const ATipoEntidade: string);
    
    // Mensagens de erro
    class procedure MostrarErro(const AMensagem: string);
    class procedure MostrarErroAoSalvar(const AErro: Exception);
    class procedure MostrarErroAoExcluir(const AErro: Exception);
    class procedure MostrarErroAoCarregar(const AErro: Exception);
    
    // Confirmações
    class function ConfirmarExclusao(const ATipoEntidade: string): Boolean;
    class function ConfirmarAcao(const AMensagem: string): Boolean;
    
    // Alertas
    class procedure AlertarSelecaoNecessaria(const ATipoEntidade: string);
    class procedure AlertarCampoObrigatorio(const ACampo: string);
  end;

implementation

{ TUIHelper }

class procedure TUIHelper.MostrarSucesso(const AMensagem: string);
begin
  ShowMessage(AMensagem);
end;

class procedure TUIHelper.MostrarSalvoComSucesso(const ATipoEntidade: string);
begin
  ShowMessage(Format('%s salvo(a) com sucesso!', [ATipoEntidade]));
end;

class procedure TUIHelper.MostrarExcluidoComSucesso(const ATipoEntidade: string);
begin
  ShowMessage(Format('%s excluído(a) com sucesso!', [ATipoEntidade]));
end;

class procedure TUIHelper.MostrarErro(const AMensagem: string);
begin
  ShowMessage(AMensagem);
end;

class procedure TUIHelper.MostrarErroAoSalvar(const AErro: Exception);
begin
  ShowMessage('Erro ao salvar: ' + AErro.Message);
end;

class procedure TUIHelper.MostrarErroAoExcluir(const AErro: Exception);
begin
  ShowMessage('Erro ao excluir: ' + AErro.Message);
end;

class procedure TUIHelper.MostrarErroAoCarregar(const AErro: Exception);
begin
  ShowMessage('Erro ao carregar: ' + AErro.Message);
end;

class function TUIHelper.ConfirmarExclusao(const ATipoEntidade: string): Boolean;
begin
  Result := MessageDlg(
    Format('Deseja realmente excluir este(a) %s?', [ATipoEntidade]),
    mtConfirmation,
    [mbYes, mbNo],
    0
  ) = mrYes;
end;

class function TUIHelper.ConfirmarAcao(const AMensagem: string): Boolean;
begin
  Result := MessageDlg(AMensagem, mtConfirmation, [mbYes, mbNo], 0) = mrYes;
end;

class procedure TUIHelper.AlertarSelecaoNecessaria(const ATipoEntidade: string);
begin
  ShowMessage(Format('Selecione um(a) %s.', [ATipoEntidade]));
end;

class procedure TUIHelper.AlertarCampoObrigatorio(const ACampo: string);
begin
  ShowMessage(Format('O campo "%s" é obrigatório.', [ACampo]));
end;

end.

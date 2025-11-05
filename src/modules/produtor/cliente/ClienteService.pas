unit ClienteService;

interface

uses
  System.SysUtils, System.Generics.Collections, GsBaseEntity, GsBaseService,
  ClienteEntity, ClienteRepository, IRepository;

type
  TClienteService = class(TgsBaseService<TClienteEntity>)
  private
    function GetClienteRepository: TClienteRepository;
  protected
    procedure ValidateEntity(AEntity: TClienteEntity); override;
    procedure BeforeSave(AEntity: TClienteEntity); override;
  public
    function FindByEmail(const AEmail: string): TClienteEntity;
    function FindByCPF(const ACPF: string): TClienteEntity;
    function FindByNome(const ANome: string): TObjectList<TClienteEntity>;
    function FindAtivos: TObjectList<TClienteEntity>;
    procedure Ativar(AEntity: TClienteEntity);
    procedure Desativar(AEntity: TClienteEntity);
  end;

implementation

{ TClienteService }

function TClienteService.GetClienteRepository: TClienteRepository;
begin
  Result := Repository as TClienteRepository;
end;

procedure TClienteService.ValidateEntity(AEntity: TClienteEntity);
var LExistente : TClienteEntity;
begin
  inherited;
  
  // Validações customizadas
  if AEntity.Nome.Trim.IsEmpty then
    raise Exception.Create('Nome é obrigatório.');
    
  if not AEntity.Email.Trim.IsEmpty then
  begin
    AEntity.ValidateEmail;
    
    // Verifica se o e-mail já existe (apenas para novos registros)
    if AEntity.State = esInsert then
    begin
      LExistente := GetClienteRepository.FindByEmail(AEntity.Email);
      try
        if Assigned(LExistente) then
          raise Exception.Create('E-mail já cadastrado.');
      finally
        LExistente.Free;
      end;
    end;
  end;
  
  if not AEntity.CPF.Trim.IsEmpty then
  begin
    AEntity.ValidateCPF;
    
    // Verifica se o CPF já existe (apenas para novos registros)
    if AEntity.State = esInsert then
    begin
      LExistente := GetClienteRepository.FindByCPF(AEntity.CPF);
      try
        if Assigned(LExistente) then
          raise Exception.Create('CPF já cadastrado.');
      finally
        LExistente.Free;
      end;
    end;
  end;
end;

procedure TClienteService.BeforeSave(AEntity: TClienteEntity);
begin
  inherited;
  
  // Lógicas adicionais antes de salvar
  // Ex: normalizar dados, aplicar máscaras, etc.
  AEntity.Nome := AEntity.Nome.Trim;
  AEntity.Email := AEntity.Email.Trim.ToLower;
end;

function TClienteService.FindByEmail(const AEmail: string): TClienteEntity;
begin
  if AEmail.Trim.IsEmpty then
    raise Exception.Create('E-mail não pode ser vazio.');
    
  Result := GetClienteRepository.FindByEmail(AEmail);
end;

function TClienteService.FindByCPF(const ACPF: string): TClienteEntity;
begin
  if ACPF.Trim.IsEmpty then
    raise Exception.Create('CPF não pode ser vazio.');
    
  Result := GetClienteRepository.FindByCPF(ACPF);
end;

function TClienteService.FindByNome(const ANome: string): TObjectList<TClienteEntity>;
begin
  if ANome.Trim.IsEmpty then
    raise Exception.Create('Nome não pode ser vazio.');
    
  Result := GetClienteRepository.FindByNome(ANome);
end;

function TClienteService.FindAtivos: TObjectList<TClienteEntity>;
begin
  Result := GetClienteRepository.FindAtivos;
end;

procedure TClienteService.Ativar(AEntity: TClienteEntity);
begin
  if not Assigned(AEntity) then
    raise Exception.Create('Cliente não pode ser nulo.');
    
  AEntity.Ativo := True;
  AEntity.State := esUpdate;
  Save(AEntity);
end;

procedure TClienteService.Desativar(AEntity: TClienteEntity);
begin
  if not Assigned(AEntity) then
    raise Exception.Create('Cliente não pode ser nulo.');
    
  AEntity.Ativo := False;
  AEntity.State := esUpdate;
  Save(AEntity);
end;

end.

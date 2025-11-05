unit NegociacaoController;

interface

uses
  System.SysUtils,
  System.Generics.Collections,
  NegociacaoEntity,
  NegociacaoRepository.Intf,
  LimiteCreditoRepository.Intf,
  NegociacaoItemRepository.Intf;

type
  TNegociacaoController = class
  private
    FRepository: INegociacaoRepository;
    FLimiteRepository: ILimiteCreditoRepository;
    FItemRepository: INegociacaoItemRepository;
    procedure CarregarItens(ANegociacao: TNegociacaoEntity);
  public
    constructor Create(ARepository: INegociacaoRepository; ALimiteRepository: ILimiteCreditoRepository; AItemRepository: INegociacaoItemRepository);

    function ListarTodos: TObjectList<TNegociacaoEntity>;
    function BuscarPorId(const AId: string): TNegociacaoEntity;
    function Salvar(ANegociacao: TNegociacaoEntity): TNegociacaoEntity;
    procedure AtualizarStatus(const AId, AStatus: string; const ADataReferencia: TDateTime);
    procedure Excluir(ANegociacao: TNegociacaoEntity);
    function CalcularTotalAprovadas(const AProdutorId, ADistribuidorId: string): Currency;
    function ListarPorProdutor(const AProdutorId: string): TObjectList<TNegociacaoEntity>;
    function ListarPorDistribuidor(const ADistribuidorId: string): TObjectList<TNegociacaoEntity>;
  end;

implementation

uses
  GsBaseEntity,
  LimiteCreditoEntity,
  NegociacaoItemEntity;

{ TNegociacaoController }

procedure TNegociacaoController.CarregarItens(ANegociacao: TNegociacaoEntity);
var
  LItens: TObjectList<TNegociacaoItemEntity>;
  LItem: TNegociacaoItemEntity;
begin
  if not Assigned(ANegociacao) then
    Exit;

  if ANegociacao.Id.Trim.IsEmpty then
    Exit;

  ANegociacao.Itens.Clear;
  
  if Assigned(FItemRepository) then
  begin
    LItens := FItemRepository.ObterPorNegociacao(ANegociacao.Id);
    if Assigned(LItens) then
    try
      for LItem in LItens do
        ANegociacao.Itens.Add(LItem);
    finally
      // Não liberar a lista pois os itens foram movidos para ANegociacao.Itens
      LItens.OwnsObjects := False;
      LItens.Free;
    end;
  end;
end;

procedure TNegociacaoController.AtualizarStatus(const AId, AStatus: string; const ADataReferencia: TDateTime);
begin
  if AId.Trim.IsEmpty then
    raise Exception.Create('ID da negociação não pode ser vazio.');
  if AStatus.Trim.IsEmpty then
    raise Exception.Create('Status é obrigatório.');
  FRepository.AtualizarStatus(AId, AStatus, ADataReferencia);
end;

function TNegociacaoController.BuscarPorId(const AId: string): TNegociacaoEntity;
begin
  if AId.Trim.IsEmpty then
    raise Exception.Create('ID da negociação não pode ser vazio.');
  Result := FRepository.ObterPorId(AId);

  if not Assigned(Result) then
    raise Exception.Create('Negociação não encontrada.');
    
  CarregarItens(Result);
end;

constructor TNegociacaoController.Create(ARepository: INegociacaoRepository; ALimiteRepository: ILimiteCreditoRepository; AItemRepository: INegociacaoItemRepository);
begin
  inherited Create;
  FRepository := ARepository;
  FLimiteRepository := ALimiteRepository;
  FItemRepository := AItemRepository;
end;

procedure TNegociacaoController.Excluir(ANegociacao: TNegociacaoEntity);
begin
  if not Assigned(ANegociacao) then
    raise Exception.Create('Negociação inválida.');
  if ANegociacao.Id.Trim.IsEmpty then
    raise Exception.Create('ID da negociação não pode ser vazio.');
  FRepository.Excluir(ANegociacao.Id);
end;

function TNegociacaoController.ListarTodos: TObjectList<TNegociacaoEntity>;
var
  LNegociacao: TNegociacaoEntity;
begin
  Result := FRepository.ObterTodos;
  
  if Assigned(Result) then
  begin
    for LNegociacao in Result do
      CarregarItens(LNegociacao);
  end;
end;

function TNegociacaoController.CalcularTotalAprovadas(const AProdutorId, ADistribuidorId: string): Currency;
begin
  if AProdutorId.Trim.IsEmpty then
    raise Exception.Create('Produtor é obrigatório.');
  if ADistribuidorId.Trim.IsEmpty then
    raise Exception.Create('Distribuidor é obrigatório.');
  Result := FRepository.ObterTotalAprovado(AProdutorId, ADistribuidorId, '');
end;

function TNegociacaoController.ListarPorProdutor(const AProdutorId: string): TObjectList<TNegociacaoEntity>;
var
  LLista: TObjectList<TNegociacaoEntity>;
  LItem: TNegociacaoEntity;
begin
  Result := TObjectList<TNegociacaoEntity>.Create(True);
  LLista := FRepository.ObterTodos;
  try
    if Assigned(LLista) then
    begin
      for LItem in LLista do
      begin
        if Assigned(LItem) then
        begin
          if LItem.ProdutorId = AProdutorId then
            Result.Add(LItem);
        end;
      end;
      LLista.OwnsObjects := False;  // Não liberar objetos que foram movidos para Result
    end;
  finally
    LLista.Free;
  end;
end;

function TNegociacaoController.ListarPorDistribuidor(const ADistribuidorId: string): TObjectList<TNegociacaoEntity>;
var
  LLista: TObjectList<TNegociacaoEntity>;
  LItem: TNegociacaoEntity;
begin
  Result := TObjectList<TNegociacaoEntity>.Create(True);
  LLista := FRepository.ObterTodos;
  try
    if Assigned(LLista) then
    begin
      for LItem in LLista do
      begin
        if Assigned(LItem) then
        begin
          if LItem.DistribuidorId = ADistribuidorId then
            Result.Add(LItem);
        end;
      end;
      LLista.OwnsObjects := False;  // Não liberar objetos que foram movidos para Result
    end;
  finally
    LLista.Free;
  end;
end;

function TNegociacaoController.Salvar(ANegociacao: TNegociacaoEntity): TNegociacaoEntity;
var
  LLimite: TLimiteCreditoEntity;
  LTotalAprovado, LTotalProjetado: Currency;
  LIgnorarId: string;
begin
  if not Assigned(ANegociacao) then
    raise Exception.Create('Negociação inválida.');

  if not Assigned(FLimiteRepository) then
    raise Exception.Create('Repositório de limite de crédito não configurado.');
  if not Assigned(FRepository) then
    raise Exception.Create('Repositório de negociação não configurado.');

  if ANegociacao.ProdutorId.Trim.IsEmpty then
    raise Exception.Create('Produtor é obrigatório.');
  if ANegociacao.DistribuidorId.Trim.IsEmpty then
    raise Exception.Create('Distribuidor é obrigatório.');
  if ANegociacao.ValorTotal <= 0 then
    raise Exception.Create('Valor total da negociação deve ser maior que zero.');

  if ANegociacao.Status.Trim.IsEmpty then
    ANegociacao.Status := 'PENDENTE';

  if ANegociacao.State = esInsert then
  begin
    ANegociacao.Status := 'PENDENTE';
    ANegociacao.DataCadastro := Now;
  end;

  LLimite := FLimiteRepository.ObterPorRelacionamento(ANegociacao.ProdutorId, ANegociacao.DistribuidorId);
  if not Assigned(LLimite) then
    raise Exception.Create('Limite de crédito não definido para este produtor com o distribuidor informado.');
  try
    LIgnorarId := '';
    if ANegociacao.State = esUpdate then
      LIgnorarId := ANegociacao.Id;

    LTotalAprovado := FRepository.ObterTotalAprovado(ANegociacao.ProdutorId, ANegociacao.DistribuidorId, LIgnorarId);
    LTotalProjetado := LTotalAprovado + ANegociacao.ValorTotal;

    if LTotalProjetado > LLimite.Limite then
      raise Exception.CreateFmt('Limite de crédito excedido. Limite disponível: R$%.2f; Total projetado: R$%.2f.',
        [LLimite.Limite - LTotalAprovado, LTotalProjetado]);
  finally
    LLimite.Free;
  end;

  case ANegociacao.State of
    esInsert: FRepository.Inserir(ANegociacao);
    esUpdate: FRepository.Atualizar(ANegociacao);
  else
    raise Exception.Create('Estado da negociação não suportado.');
  end;
  
  Result := ANegociacao;
end;

end.

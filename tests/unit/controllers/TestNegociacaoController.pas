unit TestNegociacaoController;

interface

uses
  DUnitX.TestFramework,
  System.SysUtils,
  System.Generics.Collections,
  NegociacaoController,
  NegociacaoEntity,
  NegociacaoRepository.Intf,
  LimiteCreditoRepository.Intf,
  NegociacaoItemRepository.Intf,
  MockNegociacaoRepository,
  MockLimiteCreditoRepository,
  MockNegociacaoItemRepository,
  LimiteCreditoEntity,
  GsBaseEntity;

type
  [TestFixture]
  TTestNegociacaoController = class
  private
    FController: TNegociacaoController;
    FMockRepository: TMockNegociacaoRepository;
    FMockLimiteRepository: TMockLimiteCreditoRepository;
    FMockItemRepository: TMockNegociacaoItemRepository;
    
    procedure PrepararDadosTeste;
  public
    [Setup]
    procedure Setup;
    
    [TearDown]
    procedure TearDown;

    [Test]
    [TestCase('SemAprovadas', 'PRODUTOR_001,DISTRIBUIDOR_001,50000.00,CORRETO')]
    procedure TestSalvarNegociacaoSemAprovadas;

    [Test]
    procedure TestSalvarNegociacaoComAprovadas;

    [Test]
    procedure TestSalvarNegociacaoUltrapassaLimite;

    [Test]
    procedure TestSalvarNegociacaoAjustaNoLimite;

    [Test]
    procedure TestCalcularTotalAprovadas;

    [Test]
    procedure TestValidacaoProdutor;

    [Test]
    procedure TestValidacaoDistribuidor;

    [Test]
    procedure TestValidacaoValor;
  end;

implementation

{ TTestNegociacaoController }

procedure TTestNegociacaoController.Setup;
begin
  FMockRepository := TMockNegociacaoRepository.Create;
  FMockLimiteRepository := TMockLimiteCreditoRepository.Create;
  FMockItemRepository := TMockNegociacaoItemRepository.Create;
  FController := TNegociacaoController.Create(
    FMockRepository as INegociacaoRepository,
    FMockLimiteRepository as ILimiteCreditoRepository,
    FMockItemRepository as INegociacaoItemRepository
  );
end;

procedure TTestNegociacaoController.TearDown;
begin
  FController.Free;
end;

procedure TTestNegociacaoController.PrepararDadosTeste;
var
  LLimite: TLimiteCreditoEntity;
  LNegociacao: TNegociacaoEntity;
begin
  // Criar limite de crédito de 60.000 para Produtor 001 com Distribuidor 001
  LLimite := TLimiteCreditoEntity.Create;
  try
    LLimite.Id := '{LIMITE-001}';
    LLimite.ProdutorId := '{PRODUTOR-001}';
    LLimite.DistribuidorId := '{DISTRIBUIDOR-001}';
    LLimite.Limite := 60000.00;
    FMockLimiteRepository.AddTestData(LLimite);
  finally
    LLimite.Free;
  end;
  
  // Criar uma negociação aprovada de 20.000
  LNegociacao := TNegociacaoEntity.Create;
  try
    LNegociacao.Id := '{NEG-APROVADA-001}';
    LNegociacao.ProdutorId := '{PRODUTOR-001}';
    LNegociacao.DistribuidorId := '{DISTRIBUIDOR-001}';
    LNegociacao.ValorTotal := 20000.00;
    LNegociacao.Status := 'APROVADA';
    LNegociacao.DataCadastro := Now;
    LNegociacao.DataAprovacao := Now;
    FMockRepository.AddTestData(LNegociacao);
  finally
    LNegociacao.Free;
  end;
end;

procedure TTestNegociacaoController.TestSalvarNegociacaoSemAprovadas;
var
  LNegociacao: TNegociacaoEntity;
  LLimite: TLimiteCreditoEntity;
begin
  // Preparar: Limit de 60.000 sem negociações aprovadas
  LLimite := TLimiteCreditoEntity.Create;
  try
    LLimite.Id := '{LIMITE-002}';
    LLimite.ProdutorId := '{PRODUTOR-002}';
    LLimite.DistribuidorId := '{DISTRIBUIDOR-002}';
    LLimite.Limite := 60000.00;
    FMockLimiteRepository.AddTestData(LLimite);
  finally
    LLimite.Free;
  end;
  
  // Tentar salvar negociação de 50.000 (deve passar pois não há aprovadas)
  LNegociacao := TNegociacaoEntity.Create;
  try
    LNegociacao.ProdutorId := '{PRODUTOR-002}';
    LNegociacao.DistribuidorId := '{DISTRIBUIDOR-002}';
    LNegociacao.ValorTotal := 50000.00;
    LNegociacao.State := esInsert;
    
    FController.Salvar(LNegociacao);
    
    Assert.Pass('Negociação deveria ser salva com sucesso');
  finally
    LNegociacao.Free;
  end;
end;

procedure TTestNegociacaoController.TestSalvarNegociacaoComAprovadas;
var
  LNegociacao: TNegociacaoEntity;
  LExcecaoLancada: Boolean;
  LMensagemErro: string;
begin
  // Preparar dados: Limite 60.000 com 20.000 já aprovados
  PrepararDadosTeste;
  
  // Tentar salvar negociação de 50.000
  // Esperado: BLOQUEADO porque 20.000 (aprovadas) + 50.000 (nova) = 70.000 > 60.000 (limite)
  LNegociacao := TNegociacaoEntity.Create;
  try
    LNegociacao.ProdutorId := '{PRODUTOR-001}';
    LNegociacao.DistribuidorId := '{DISTRIBUIDOR-001}';
    LNegociacao.ValorTotal := 50000.00;
    LNegociacao.State := esInsert;
    
    LExcecaoLancada := False;
    LMensagemErro := '';
    try
      FController.Salvar(LNegociacao);
    except
      on E: Exception do
      begin
        LExcecaoLancada := True;
        LMensagemErro := E.Message;
      end;
    end;
    
    Assert.IsTrue(LExcecaoLancada, 
      'Deveria lançar exceção ao tentar ultrapassar o limite com aprovadas');
    Assert.Contains(LMensagemErro, 'excedido', True,
      'Mensagem deveria conter "excedido"');
  finally
    LNegociacao.Free;
  end;
end;

procedure TTestNegociacaoController.TestSalvarNegociacaoUltrapassaLimite;
var
  LNegociacao: TNegociacaoEntity;
  LLimite: TLimiteCreditoEntity;
  LExcecaoLancada: Boolean;
begin
  // Preparar: Limite de 30.000 com 20.000 já aprovados
  LLimite := TLimiteCreditoEntity.Create;
  try
    LLimite.Id := '{LIMITE-003}';
    LLimite.ProdutorId := '{PRODUTOR-003}';
    LLimite.DistribuidorId := '{DISTRIBUIDOR-003}';
    LLimite.Limite := 30000.00;
    FMockLimiteRepository.AddTestData(LLimite);
  finally
    LLimite.Free;
  end;
  
  var LNegociacaoAprovada := TNegociacaoEntity.Create;
  try
    LNegociacaoAprovada.Id := '{NEG-APROVADA-002}';
    LNegociacaoAprovada.ProdutorId := '{PRODUTOR-003}';
    LNegociacaoAprovada.DistribuidorId := '{DISTRIBUIDOR-003}';
    LNegociacaoAprovada.ValorTotal := 20000.00;
    LNegociacaoAprovada.Status := 'APROVADA';
    LNegociacaoAprovada.DataCadastro := Now;
    LNegociacaoAprovada.DataAprovacao := Now;
    FMockRepository.AddTestData(LNegociacaoAprovada);
  finally
    LNegociacaoAprovada.Free;
  end;
  
  // Tentar salvar negociação de 15.000 (20.000 + 15.000 = 35.000 > 30.000)
  LNegociacao := TNegociacaoEntity.Create;
  try
    LNegociacao.ProdutorId := '{PRODUTOR-003}';
    LNegociacao.DistribuidorId := '{DISTRIBUIDOR-003}';
    LNegociacao.ValorTotal := 15000.00;
    LNegociacao.State := esInsert;
    
    LExcecaoLancada := False;
    try
      FController.Salvar(LNegociacao);
    except
      on E: Exception do
        LExcecaoLancada := True;
    end;
    
    Assert.IsTrue(LExcecaoLancada, 
      'Deveria bloquear negociação que ultrapassa limite considerando aprovadas');
  finally
    LNegociacao.Free;
  end;
end;

procedure TTestNegociacaoController.TestSalvarNegociacaoAjustaNoLimite;
var
  LNegociacao: TNegociacaoEntity;
  LLimite: TLimiteCreditoEntity;
begin
  // Preparar: Limite de 60.000 com 20.000 já aprovados
  LLimite := TLimiteCreditoEntity.Create;
  try
    LLimite.Id := '{LIMITE-004}';
    LLimite.ProdutorId := '{PRODUTOR-004}';
    LLimite.DistribuidorId := '{DISTRIBUIDOR-004}';
    LLimite.Limite := 60000.00;
    FMockLimiteRepository.AddTestData(LLimite);
  finally
    LLimite.Free;
  end;
  
  var LNegociacaoAprovada := TNegociacaoEntity.Create;
  try
    LNegociacaoAprovada.Id := '{NEG-APROVADA-003}';
    LNegociacaoAprovada.ProdutorId := '{PRODUTOR-004}';
    LNegociacaoAprovada.DistribuidorId := '{DISTRIBUIDOR-004}';
    LNegociacaoAprovada.ValorTotal := 20000.00;
    LNegociacaoAprovada.Status := 'APROVADA';
    LNegociacaoAprovada.DataCadastro := Now;
    LNegociacaoAprovada.DataAprovacao := Now;
    FMockRepository.AddTestData(LNegociacaoAprovada);
  finally
    LNegociacaoAprovada.Free;
  end;
  
  // Tentar salvar negociação de 40.000 (20.000 + 40.000 = 60.000 = limite, deve passar)
  LNegociacao := TNegociacaoEntity.Create;
  try
    LNegociacao.ProdutorId := '{PRODUTOR-004}';
    LNegociacao.DistribuidorId := '{DISTRIBUIDOR-004}';
    LNegociacao.ValorTotal := 40000.00;
    LNegociacao.State := esInsert;
    
    FController.Salvar(LNegociacao);
    
    Assert.Pass('Negociação deveria ser salva quando iguala exatamente o limite');
  finally
    LNegociacao.Free;
  end;
end;

procedure TTestNegociacaoController.TestCalcularTotalAprovadas;
var
  LLimite: TLimiteCreditoEntity;
  LNeg1, LNeg2, LNeg3: TNegociacaoEntity;
  LTotal: Currency;
begin
  // Preparar: Limite para Produtor 005
  LLimite := TLimiteCreditoEntity.Create;
  try
    LLimite.Id := '{LIMITE-005}';
    LLimite.ProdutorId := '{PRODUTOR-005}';
    LLimite.DistribuidorId := '{DISTRIBUIDOR-005}';
    LLimite.Limite := 100000.00;
    FMockLimiteRepository.AddTestData(LLimite);
  finally
    LLimite.Free;
  end;
  
  // Criar 3 negociações: 2 aprovadas (20.000 + 15.000) e 1 pendente (10.000)
  LNeg1 := TNegociacaoEntity.Create;
  try
    LNeg1.Id := '{NEG-005-001}';
    LNeg1.ProdutorId := '{PRODUTOR-005}';
    LNeg1.DistribuidorId := '{DISTRIBUIDOR-005}';
    LNeg1.ValorTotal := 20000.00;
    LNeg1.Status := 'APROVADA';
    LNeg1.DataCadastro := Now;
    LNeg1.DataAprovacao := Now;
    FMockRepository.AddTestData(LNeg1);
  finally
    LNeg1.Free;
  end;
  
  LNeg2 := TNegociacaoEntity.Create;
  try
    LNeg2.Id := '{NEG-005-002}';
    LNeg2.ProdutorId := '{PRODUTOR-005}';
    LNeg2.DistribuidorId := '{DISTRIBUIDOR-005}';
    LNeg2.ValorTotal := 15000.00;
    LNeg2.Status := 'APROVADA';
    LNeg2.DataCadastro := Now;
    LNeg2.DataAprovacao := Now;
    FMockRepository.AddTestData(LNeg2);
  finally
    LNeg2.Free;
  end;
  
  LNeg3 := TNegociacaoEntity.Create;
  try
    LNeg3.Id := '{NEG-005-003}';
    LNeg3.ProdutorId := '{PRODUTOR-005}';
    LNeg3.DistribuidorId := '{DISTRIBUIDOR-005}';
    LNeg3.ValorTotal := 10000.00;
    LNeg3.Status := 'PENDENTE';
    LNeg3.DataCadastro := Now;
    FMockRepository.AddTestData(LNeg3);
  finally
    LNeg3.Free;
  end;
  
  // Calcular total de aprovadas
  LTotal := FController.CalcularTotalAprovadas('{PRODUTOR-005}', '{DISTRIBUIDOR-005}');
  
  // Deveria retornar 35.000 (20.000 + 15.000), NÃO incluindo a pendente (10.000)
  Assert.AreEqual(35000.00, LTotal, 0.01,
    'Total de negociações aprovadas deveria ser 35.000');
end;

procedure TTestNegociacaoController.TestValidacaoProdutor;
var
  LNegociacao: TNegociacaoEntity;
  LExcecaoLancada: Boolean;
begin
  LNegociacao := TNegociacaoEntity.Create;
  try
    LNegociacao.ProdutorId := ''; // Vazio
    LNegociacao.DistribuidorId := '{DISTRIBUIDOR-001}';
    LNegociacao.ValorTotal := 1000.00;
    LNegociacao.State := esInsert;
    
    LExcecaoLancada := False;
    try
      FController.Salvar(LNegociacao);
    except
      on E: Exception do
        LExcecaoLancada := True;
    end;
    
    Assert.IsTrue(LExcecaoLancada, 'Deveria validar que produtor é obrigatório');
  finally
    LNegociacao.Free;
  end;
end;

procedure TTestNegociacaoController.TestValidacaoDistribuidor;
var
  LNegociacao: TNegociacaoEntity;
  LExcecaoLancada: Boolean;
begin
  LNegociacao := TNegociacaoEntity.Create;
  try
    LNegociacao.ProdutorId := '{PRODUTOR-001}';
    LNegociacao.DistribuidorId := ''; // Vazio
    LNegociacao.ValorTotal := 1000.00;
    LNegociacao.State := esInsert;
    
    LExcecaoLancada := False;
    try
      FController.Salvar(LNegociacao);
    except
      on E: Exception do
        LExcecaoLancada := True;
    end;
    
    Assert.IsTrue(LExcecaoLancada, 'Deveria validar que distribuidor é obrigatório');
  finally
    LNegociacao.Free;
  end;
end;

procedure TTestNegociacaoController.TestValidacaoValor;
var
  LNegociacao: TNegociacaoEntity;
  LExcecaoLancada: Boolean;
  LLimite: TLimiteCreditoEntity;
begin
  // Preparar limite
  LLimite := TLimiteCreditoEntity.Create;
  try
    LLimite.Id := '{LIMITE-006}';
    LLimite.ProdutorId := '{PRODUTOR-006}';
    LLimite.DistribuidorId := '{DISTRIBUIDOR-006}';
    LLimite.Limite := 60000.00;
    FMockLimiteRepository.AddTestData(LLimite);
  finally
    LLimite.Free;
  end;
  
  // Tentar salvar com valor zero
  LNegociacao := TNegociacaoEntity.Create;
  try
    LNegociacao.ProdutorId := '{PRODUTOR-006}';
    LNegociacao.DistribuidorId := '{DISTRIBUIDOR-006}';
    LNegociacao.ValorTotal := 0;
    LNegociacao.State := esInsert;
    
    LExcecaoLancada := False;
    try
      FController.Salvar(LNegociacao);
    except
      on E: Exception do
        LExcecaoLancada := True;
    end;
    
    Assert.IsTrue(LExcecaoLancada, 'Deveria validar que valor deve ser maior que zero');
  finally
    LNegociacao.Free;
  end;
end;

initialization
  TDUnitX.RegisterTestFixture(TTestNegociacaoController);

end.

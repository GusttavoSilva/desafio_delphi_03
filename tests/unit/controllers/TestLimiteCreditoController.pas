unit TestLimiteCreditoController;

interface

uses
  DUnitX.TestFramework,
  System.SysUtils,
  System.Generics.Collections,
  LimiteCreditoController,
  LimiteCreditoEntity,
  LimiteCreditoRepository.Intf,
  MockLimiteCreditoRepository,
  GsBaseEntity;

type
  [TestFixture]
  TTestLimiteCreditoController = class
  private
    FController: TLimiteCreditoController;
    FMockRepository: TMockLimiteCreditoRepository;
  public
    [Setup]
    procedure Setup;
    
    [TearDown]
    procedure TearDown;

    [Test]
    procedure TestSalvarNovoLimite;

    [Test]
    procedure TestSalvarLimiteDuplicado;

    [Test]
    procedure TestAtualizarLimiteExistente;

    [Test]
    procedure TestBuscarPorId;

    [Test]
    procedure TestBuscarPorIdInexistente;

    [Test]
    procedure TestBuscarPorRelacionamento;

    [Test]
    procedure TestObterLimiteCredito;

    [Test]
    procedure TestObterLimiteCreditoInexistente;

    [Test]
    procedure TestExcluirLimite;

    [Test]
    procedure TestListarTodos;

    [Test]
    procedure TestValidacaoEntidadeNula;
  end;

implementation

{ TTestLimiteCreditoController }

procedure TTestLimiteCreditoController.Setup;
begin
  FMockRepository := TMockLimiteCreditoRepository.Create;
  FController := TLimiteCreditoController.Create(FMockRepository);
end;

procedure TTestLimiteCreditoController.TearDown;
begin
  FController.Free;
  // Mock é liberado automaticamente pela interface
end;

procedure TTestLimiteCreditoController.TestSalvarNovoLimite;
var
  LLimite: TLimiteCreditoEntity;
  LResult: TLimiteCreditoEntity;
begin
  LLimite := TLimiteCreditoEntity.Create;
  try
    LLimite.ProdutorId := '{PRODUTOR-001}';
    LLimite.DistribuidorId := '{DISTRIBUIDOR-001}';
    LLimite.Limite := 50000.00;
    LLimite.State := esInsert;
    
    LResult := FController.Salvar(LLimite);
    
    Assert.IsNotNull(LResult, 'Resultado não deveria ser nulo');
    Assert.IsNotEmpty(LResult.Id, 'ID deveria ser gerado');
    Assert.AreEqual(1, FMockRepository.Count, 'Deveria ter 1 registro');
  finally
    LLimite.Free;
  end;
end;

procedure TTestLimiteCreditoController.TestSalvarLimiteDuplicado;
var
  LLimite1, LLimite2: TLimiteCreditoEntity;
  LExcecaoLancada: Boolean;
begin
  // Insere o primeiro
  LLimite1 := TLimiteCreditoEntity.Create;
  try
    LLimite1.ProdutorId := '{PRODUTOR-001}';
    LLimite1.DistribuidorId := '{DISTRIBUIDOR-001}';
    LLimite1.Limite := 50000.00;
    LLimite1.State := esInsert;
    FController.Salvar(LLimite1);
  finally
    LLimite1.Free;
  end;
  
  // Tenta inserir duplicado
  LLimite2 := TLimiteCreditoEntity.Create;
  try
    LLimite2.ProdutorId := '{PRODUTOR-001}';
    LLimite2.DistribuidorId := '{DISTRIBUIDOR-001}';
    LLimite2.Limite := 60000.00;
    LLimite2.State := esInsert;
    
    LExcecaoLancada := False;
    try
      FController.Salvar(LLimite2);
    except
      on E: Exception do
        LExcecaoLancada := True;
    end;
    
    Assert.IsTrue(LExcecaoLancada, 'Deveria lançar exceção ao tentar inserir limite duplicado');
  finally
    LLimite2.Free;
  end;
end;

procedure TTestLimiteCreditoController.TestAtualizarLimiteExistente;
var
  LLimite: TLimiteCreditoEntity;
  LBuscado: TLimiteCreditoEntity;
begin
  // Insere
  LLimite := TLimiteCreditoEntity.Create;
  try
    LLimite.ProdutorId := '{PRODUTOR-001}';
    LLimite.DistribuidorId := '{DISTRIBUIDOR-001}';
    LLimite.Limite := 50000.00;
    LLimite.State := esInsert;
    FController.Salvar(LLimite);
    
    // Atualiza
    LLimite.Limite := 75000.00;
    LLimite.State := esUpdate;
    FController.Salvar(LLimite);
    
    // Verifica
    LBuscado := FController.BuscarPorId(LLimite.Id);
    try
      Assert.AreEqual(75000.00, LBuscado.Limite, 0.01, 'Limite deveria estar atualizado');
    finally
      LBuscado.Free;
    end;
  finally
    LLimite.Free;
  end;
end;

procedure TTestLimiteCreditoController.TestBuscarPorId;
var
  LLimite: TLimiteCreditoEntity;
  LBuscado: TLimiteCreditoEntity;
begin
  // Insere dados de teste
  LLimite := TLimiteCreditoEntity.Create;
  try
    LLimite.Id := '{LIMITE-001}';
    LLimite.ProdutorId := '{PRODUTOR-001}';
    LLimite.DistribuidorId := '{DISTRIBUIDOR-001}';
    LLimite.Limite := 50000.00;
    FMockRepository.AddTestData(LLimite);
  finally
    LLimite.Free;
  end;
  
  // Busca
  LBuscado := FController.BuscarPorId('{LIMITE-001}');
  try
    Assert.IsNotNull(LBuscado, 'Deveria encontrar o limite');
    Assert.AreEqual('{LIMITE-001}', LBuscado.Id);
    Assert.AreEqual(50000.00, LBuscado.Limite, 0.01);
  finally
    LBuscado.Free;
  end;
end;

procedure TTestLimiteCreditoController.TestBuscarPorIdInexistente;
var
  LExcecaoLancada: Boolean;
begin
  LExcecaoLancada := False;
  try
    FController.BuscarPorId('{ID-INEXISTENTE}');
  except
    on E: Exception do
      LExcecaoLancada := True;
  end;
  
  Assert.IsTrue(LExcecaoLancada, 'Deveria lançar exceção ao buscar ID inexistente');
end;

procedure TTestLimiteCreditoController.TestBuscarPorRelacionamento;
var
  LLimite: TLimiteCreditoEntity;
  LBuscado: TLimiteCreditoEntity;
begin
  // Insere dados de teste
  LLimite := TLimiteCreditoEntity.Create;
  try
    LLimite.Id := '{LIMITE-001}';
    LLimite.ProdutorId := '{PRODUTOR-001}';
    LLimite.DistribuidorId := '{DISTRIBUIDOR-001}';
    LLimite.Limite := 50000.00;
    FMockRepository.AddTestData(LLimite);
  finally
    LLimite.Free;
  end;
  
  // Busca por relacionamento
  LBuscado := FController.BuscarPorRelacionamento('{PRODUTOR-001}', '{DISTRIBUIDOR-001}');
  try
    Assert.IsNotNull(LBuscado, 'Deveria encontrar o limite');
    Assert.AreEqual(50000.00, LBuscado.Limite, 0.01);
  finally
    LBuscado.Free;
  end;
end;

procedure TTestLimiteCreditoController.TestObterLimiteCredito;
var
  LLimite: TLimiteCreditoEntity;
  LValor: Currency;
begin
  // Insere dados de teste
  LLimite := TLimiteCreditoEntity.Create;
  try
    LLimite.Id := '{LIMITE-001}';
    LLimite.ProdutorId := '{PRODUTOR-001}';
    LLimite.DistribuidorId := '{DISTRIBUIDOR-001}';
    LLimite.Limite := 50000.00;
    FMockRepository.AddTestData(LLimite);
  finally
    LLimite.Free;
  end;
  
  // Obtém valor do limite
  LValor := FController.ObterLimiteCredito('{PRODUTOR-001}', '{DISTRIBUIDOR-001}');
  
  Assert.AreEqual(50000.00, LValor, 0.01, 'Valor do limite deveria ser 50000.00');
end;

procedure TTestLimiteCreditoController.TestObterLimiteCreditoInexistente;
var
  LValor: Currency;
begin
  // Busca limite inexistente
  LValor := FController.ObterLimiteCredito('{PRODUTOR-999}', '{DISTRIBUIDOR-999}');
  
  Assert.AreEqual(0.0, LValor, 0.01, 'Valor deveria ser zero para limite inexistente');
end;

procedure TTestLimiteCreditoController.TestExcluirLimite;
var
  LLimite: TLimiteCreditoEntity;
begin
  // Insere
  LLimite := TLimiteCreditoEntity.Create;
  try
    LLimite.ProdutorId := '{PRODUTOR-001}';
    LLimite.DistribuidorId := '{DISTRIBUIDOR-001}';
    LLimite.Limite := 50000.00;
    LLimite.State := esInsert;
    FController.Salvar(LLimite);
    
    Assert.AreEqual(1, FMockRepository.Count, 'Deveria ter 1 registro antes de excluir');
    
    // Exclui
    FController.Excluir(LLimite);
    
    Assert.AreEqual(0, FMockRepository.Count, 'Deveria ter 0 registros após excluir');
  finally
    LLimite.Free;
  end;
end;

procedure TTestLimiteCreditoController.TestListarTodos;
var
  LLimite1, LLimite2: TLimiteCreditoEntity;
  LLista: TObjectList<TLimiteCreditoEntity>;
begin
  // Insere dados de teste
  LLimite1 := TLimiteCreditoEntity.Create;
  try
    LLimite1.Id := '{LIMITE-001}';
    LLimite1.ProdutorId := '{PRODUTOR-001}';
    LLimite1.DistribuidorId := '{DISTRIBUIDOR-001}';
    LLimite1.Limite := 50000.00;
    FMockRepository.AddTestData(LLimite1);
  finally
    LLimite1.Free;
  end;
  
  LLimite2 := TLimiteCreditoEntity.Create;
  try
    LLimite2.Id := '{LIMITE-002}';
    LLimite2.ProdutorId := '{PRODUTOR-002}';
    LLimite2.DistribuidorId := '{DISTRIBUIDOR-002}';
    LLimite2.Limite := 75000.00;
    FMockRepository.AddTestData(LLimite2);
  finally
    LLimite2.Free;
  end;
  
  // Lista todos
  LLista := FController.ListarTodos;
  try
    Assert.AreEqual(2, LLista.Count, 'Deveria retornar 2 limites');
  finally
    LLista.Free;
  end;
end;

procedure TTestLimiteCreditoController.TestValidacaoEntidadeNula;
var
  LExcecaoLancada: Boolean;
begin
  LExcecaoLancada := False;
  try
    FController.Salvar(nil);
  except
    on E: Exception do
      LExcecaoLancada := True;
  end;
  
  Assert.IsTrue(LExcecaoLancada, 'Deveria lançar exceção ao tentar salvar entidade nula');
end;

initialization
  TDUnitX.RegisterTestFixture(TTestLimiteCreditoController);

end.

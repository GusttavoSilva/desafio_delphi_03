unit TestFluxoLimiteCreditoE2E;

interface

uses
  DUnitX.TestFramework,
  System.SysUtils,
  System.Generics.Collections,
  LimiteCreditoController,
  LimiteCreditoEntity,
  ProdutorEntity,
  DistribuidorEntity,
  MockLimiteCreditoRepository,
  MockProdutorRepository,
  MockDistribuidorRepository,
  GsBaseEntity;

type
  /// <summary>
  /// Testes End-to-End (E2E) simulando fluxos completos de uso do sistema.
  /// Estes testes validam a integração entre múltiplos componentes.
  /// </summary>
  [TestFixture]
  TTestFluxoLimiteCreditoE2E = class
  private
    FLimiteCreditoController: TLimiteCreditoController;
    FMockLimiteCreditoRepo: TMockLimiteCreditoRepository;
    FMockProdutorRepo: TMockProdutorRepository;
    FMockDistribuidorRepo: TMockDistribuidorRepository;
    
    function CriarProdutor(const ANome, ACpfCnpj: string): TProdutorEntity;
    function CriarDistribuidor(const ANome, ACnpj: string): TDistribuidorEntity;
    function CriarLimite(const AProdutorId, ADistribuidorId: string; ALimite: Currency): TLimiteCreditoEntity;
  public
    [Setup]
    procedure Setup;
    
    [TearDown]
    procedure TearDown;

    [Test]
    [Description('Fluxo completo: cadastrar produtor, distribuidor e definir limite de crédito')]
    procedure TestFluxoCompleto_CadastroEDefinicaoLimite;

    [Test]
    [Description('Fluxo: múltiplos limites para o mesmo produtor com distribuidores diferentes')]
    procedure TestFluxo_MultiplosLimitesParaMesmoProdutor;

    [Test]
    [Description('Fluxo: tentativa de criar limite duplicado deve falhar')]
    procedure TestFluxo_TentativaCriarLimiteDuplicado;

    [Test]
    [Description('Fluxo: atualizar limite de crédito existente')]
    procedure TestFluxo_AtualizarLimiteExistente;

    [Test]
    [Description('Fluxo: validação de limite disponível para negociação')]
    procedure TestFluxo_ValidarLimiteDisponivel;
  end;

implementation

{ TTestFluxoLimiteCreditoE2E }

procedure TTestFluxoLimiteCreditoE2E.Setup;
begin
  FMockLimiteCreditoRepo := TMockLimiteCreditoRepository.Create;
  FMockProdutorRepo := TMockProdutorRepository.Create;
  FMockDistribuidorRepo := TMockDistribuidorRepository.Create;
  
  FLimiteCreditoController := TLimiteCreditoController.Create(FMockLimiteCreditoRepo);
end;

procedure TTestFluxoLimiteCreditoE2E.TearDown;
begin
  FLimiteCreditoController.Free;
  // Mocks são liberados automaticamente
end;

function TTestFluxoLimiteCreditoE2E.CriarProdutor(const ANome, ACpfCnpj: string): TProdutorEntity;
begin
  Result := TProdutorEntity.Create;
  Result.Nome := ANome;
  Result.CpfCnpj := ACpfCnpj;
  Result.State := esInsert;
  Result.BeforeSave;
  FMockProdutorRepo.Insert(Result);
end;

function TTestFluxoLimiteCreditoE2E.CriarDistribuidor(const ANome, ACnpj: string): TDistribuidorEntity;
begin
  Result := TDistribuidorEntity.Create;
  Result.Nome := ANome;
  Result.Cnpj := ACnpj;
  Result.State := esInsert;
  Result.BeforeSave;
  FMockDistribuidorRepo.Insert(Result);
end;

function TTestFluxoLimiteCreditoE2E.CriarLimite(const AProdutorId, ADistribuidorId: string; 
  ALimite: Currency): TLimiteCreditoEntity;
begin
  Result := TLimiteCreditoEntity.Create;
  Result.ProdutorId := AProdutorId;
  Result.DistribuidorId := ADistribuidorId;
  Result.Limite := ALimite;
  Result.State := esInsert;
end;

procedure TTestFluxoLimiteCreditoE2E.TestFluxoCompleto_CadastroEDefinicaoLimite;
var
  LProdutor: TProdutorEntity;
  LDistribuidor: TDistribuidorEntity;
  LLimite: TLimiteCreditoEntity;
  LValorLimite: Currency;
begin
  // 1. Cadastrar Produtor
  LProdutor := CriarProdutor('João da Silva', '123.456.789-09');
  try
    Assert.IsNotEmpty(LProdutor.Id, 'Produtor deveria ter ID gerado');
    Assert.AreEqual('João da Silva', LProdutor.Nome);
    
    // 2. Cadastrar Distribuidor
    LDistribuidor := CriarDistribuidor('Agro Distribuidora LTDA', '11.222.333/0001-81');
    try
      Assert.IsNotEmpty(LDistribuidor.Id, 'Distribuidor deveria ter ID gerado');
      Assert.AreEqual('Agro Distribuidora LTDA', LDistribuidor.Nome);
      
      // 3. Definir Limite de Crédito
      LLimite := CriarLimite(LProdutor.Id, LDistribuidor.Id, 100000.00);
      try
        FLimiteCreditoController.Salvar(LLimite);
        Assert.IsNotEmpty(LLimite.Id, 'Limite deveria ter ID gerado');
        
        // 4. Verificar se o limite foi salvo corretamente
        LValorLimite := FLimiteCreditoController.ObterLimiteCredito(
          LProdutor.Id, LDistribuidor.Id);
        Assert.AreEqual(100000.00, LValorLimite, 0.01, 
          'Valor do limite deveria ser 100000.00');
      finally
        LLimite.Free;
      end;
    finally
      LDistribuidor.Free;
    end;
  finally
    LProdutor.Free;
  end;
end;

procedure TTestFluxoLimiteCreditoE2E.TestFluxo_MultiplosLimitesParaMesmoProdutor;
var
  LProdutor: TProdutorEntity;
  LDistribuidor1, LDistribuidor2: TDistribuidorEntity;
  LLimite1, LLimite2: TLimiteCreditoEntity;
begin
  // Cria um produtor
  LProdutor := CriarProdutor('Maria Oliveira', '987.654.321-00');
  try
    // Cria dois distribuidores diferentes
    LDistribuidor1 := CriarDistribuidor('Distribuidor A', '11.111.111/0001-11');
    try
      LDistribuidor2 := CriarDistribuidor('Distribuidor B', '22.222.222/0001-22');
      try
        // Define limite com Distribuidor A
        LLimite1 := CriarLimite(LProdutor.Id, LDistribuidor1.Id, 50000.00);
        try
          FLimiteCreditoController.Salvar(LLimite1);
        finally
          LLimite1.Free;
        end;
        
        // Define limite com Distribuidor B
        LLimite2 := CriarLimite(LProdutor.Id, LDistribuidor2.Id, 75000.00);
        try
          FLimiteCreditoController.Salvar(LLimite2);
        finally
          LLimite2.Free;
        end;
        
        // Verifica ambos os limites
        Assert.AreEqual(50000.00, 
          FLimiteCreditoController.ObterLimiteCredito(LProdutor.Id, LDistribuidor1.Id), 0.01);
        Assert.AreEqual(75000.00, 
          FLimiteCreditoController.ObterLimiteCredito(LProdutor.Id, LDistribuidor2.Id), 0.01);
        
        Assert.AreEqual(2, FMockLimiteCreditoRepo.Count, 
          'Deveria ter 2 limites cadastrados');
      finally
        LDistribuidor2.Free;
      end;
    finally
      LDistribuidor1.Free;
    end;
  finally
    LProdutor.Free;
  end;
end;

procedure TTestFluxoLimiteCreditoE2E.TestFluxo_TentativaCriarLimiteDuplicado;
var
  LProdutor: TProdutorEntity;
  LDistribuidor: TDistribuidorEntity;
  LLimite1, LLimite2: TLimiteCreditoEntity;
  LExcecaoLancada: Boolean;
begin
  LProdutor := CriarProdutor('Carlos Santos', '111.222.333-44');
  try
    LDistribuidor := CriarDistribuidor('Distribuidor X', '33.333.333/0001-33');
    try
      // Cria primeiro limite
      LLimite1 := CriarLimite(LProdutor.Id, LDistribuidor.Id, 60000.00);
      try
        FLimiteCreditoController.Salvar(LLimite1);
      finally
        LLimite1.Free;
      end;
      
      // Tenta criar limite duplicado
      LLimite2 := CriarLimite(LProdutor.Id, LDistribuidor.Id, 80000.00);
      try
        LExcecaoLancada := False;
        try
          FLimiteCreditoController.Salvar(LLimite2);
        except
          on E: Exception do
            LExcecaoLancada := True;
        end;
        
        Assert.IsTrue(LExcecaoLancada, 'Deveria lançar exceção ao tentar criar limite duplicado');
      finally
        LLimite2.Free;
      end;
    finally
      LDistribuidor.Free;
    end;
  finally
    LProdutor.Free;
  end;
end;

procedure TTestFluxoLimiteCreditoE2E.TestFluxo_AtualizarLimiteExistente;
var
  LProdutor: TProdutorEntity;
  LDistribuidor: TDistribuidorEntity;
  LLimite: TLimiteCreditoEntity;
  LValorAtualizado: Currency;
begin
  LProdutor := CriarProdutor('Ana Paula', '555.666.777-88');
  try
    LDistribuidor := CriarDistribuidor('Distribuidor Y', '44.444.444/0001-44');
    try
      // Cria limite inicial
      LLimite := CriarLimite(LProdutor.Id, LDistribuidor.Id, 40000.00);
      try
        FLimiteCreditoController.Salvar(LLimite);
        
        // Atualiza o limite
        LLimite.Limite := 90000.00;
        LLimite.State := esUpdate;
        FLimiteCreditoController.Salvar(LLimite);
        
        // Verifica se foi atualizado
        LValorAtualizado := FLimiteCreditoController.ObterLimiteCredito(
          LProdutor.Id, LDistribuidor.Id);
        Assert.AreEqual(90000.00, LValorAtualizado, 0.01, 
          'Limite deveria estar atualizado para 90000.00');
      finally
        LLimite.Free;
      end;
    finally
      LDistribuidor.Free;
    end;
  finally
    LProdutor.Free;
  end;
end;

procedure TTestFluxoLimiteCreditoE2E.TestFluxo_ValidarLimiteDisponivel;
var
  LProdutor: TProdutorEntity;
  LDistribuidor: TDistribuidorEntity;
  LLimite: TLimiteCreditoEntity;
  LLimiteTotal, LLimiteUtilizado, LLimiteDisponivel: Currency;
begin
  LProdutor := CriarProdutor('Pedro Alves', '999.888.777-66');
  try
    LDistribuidor := CriarDistribuidor('Distribuidor Z', '55.555.555/0001-55');
    try
      // Define limite total de R$ 100.000,00
      LLimiteTotal := 100000.00;
      LLimite := CriarLimite(LProdutor.Id, LDistribuidor.Id, LLimiteTotal);
      try
        FLimiteCreditoController.Salvar(LLimite);
      finally
        LLimite.Free;
      end;
      
      // Simula que R$ 60.000,00 já foram utilizados em negociações aprovadas
      LLimiteUtilizado := 60000.00;
      LLimiteDisponivel := LLimiteTotal - LLimiteUtilizado;
      
      // Verifica se há limite disponível para uma nova negociação de R$ 30.000,00
      Assert.IsTrue(LLimiteDisponivel >= 30000.00, 
        'Deveria haver limite disponível para negociação de R$ 30.000,00');
      
      // Verifica se NÃO há limite para uma negociação de R$ 50.000,00
      Assert.IsFalse(LLimiteDisponivel >= 50000.00, 
        'NÃO deveria haver limite disponível para negociação de R$ 50.000,00');
    finally
      LDistribuidor.Free;
    end;
  finally
    LProdutor.Free;
  end;
end;

initialization
  TDUnitX.RegisterTestFixture(TTestFluxoLimiteCreditoE2E);

end.

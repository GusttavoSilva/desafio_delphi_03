unit TestLimiteCreditoEntity;

interface

uses
  DUnitX.TestFramework,
  System.SysUtils,
  LimiteCreditoEntity,
  GsBaseEntity;

type
  [TestFixture]
  TTestLimiteCreditoEntity = class
  public
    [Test]
    procedure TestCriacaoComDadosValidos;

    [Test]
    procedure TestValidacaoProdutorIdObrigatorio;

    [Test]
    procedure TestValidacaoDistribuidorIdObrigatorio;

    [Test]
    procedure TestValidacaoLimiteMaiorQueZero;

    [Test]
    procedure TestValidacaoProdutorDistribuidorDistintos;

    [Test]
    procedure TestEstadoInicialInsert;

    [Test]
    procedure TestValoresIniciaisCorretos;
  end;

implementation

{ TTestLimiteCreditoEntity }

procedure TTestLimiteCreditoEntity.TestCriacaoComDadosValidos;
var
  LLimite: TLimiteCreditoEntity;
begin
  LLimite := TLimiteCreditoEntity.Create;
  try
    LLimite.ProdutorId := '{PRODUTOR-001}';
    LLimite.DistribuidorId := '{DISTRIBUIDOR-001}';
    LLimite.Limite := 50000.00;
    
    // Não deveria lançar exceção para dados válidos
    LLimite.BeforeSave;
    
    Assert.IsNotEmpty(LLimite.Id, 'ID deve ser gerado automaticamente');
    Assert.AreEqual('{PRODUTOR-001}', LLimite.ProdutorId);
    Assert.AreEqual('{DISTRIBUIDOR-001}', LLimite.DistribuidorId);
    Assert.AreEqual(50000.00, LLimite.Limite, 0.01);
  finally
    LLimite.Free;
  end;
end;

procedure TTestLimiteCreditoEntity.TestValidacaoProdutorIdObrigatorio;
var
  LLimite: TLimiteCreditoEntity;
  LExcecaoLancada: Boolean;
begin
  LLimite := TLimiteCreditoEntity.Create;
  try
    LLimite.ProdutorId := '';
    LLimite.DistribuidorId := '{DISTRIBUIDOR-001}';
    LLimite.Limite := 50000.00;
    
    LExcecaoLancada := False;
    try
      LLimite.BeforeSave;
    except
      on E: Exception do
        LExcecaoLancada := True;
    end;
    
    Assert.IsTrue(LExcecaoLancada, 'Deveria lançar exceção quando ProdutorId está vazio');
  finally
    LLimite.Free;
  end;
end;

procedure TTestLimiteCreditoEntity.TestValidacaoDistribuidorIdObrigatorio;
var
  LLimite: TLimiteCreditoEntity;
  LExcecaoLancada: Boolean;
begin
  LLimite := TLimiteCreditoEntity.Create;
  try
    LLimite.ProdutorId := '{PRODUTOR-001}';
    LLimite.DistribuidorId := '';
    LLimite.Limite := 50000.00;
    
    LExcecaoLancada := False;
    try
      LLimite.BeforeSave;
    except
      on E: Exception do
        LExcecaoLancada := True;
    end;
    
    Assert.IsTrue(LExcecaoLancada, 'Deveria lançar exceção quando DistribuidorId está vazio');
  finally
    LLimite.Free;
  end;
end;

procedure TTestLimiteCreditoEntity.TestValidacaoLimiteMaiorQueZero;
var
  LLimite: TLimiteCreditoEntity;
  LExcecaoLancada: Boolean;
begin
  LLimite := TLimiteCreditoEntity.Create;
  try
    LLimite.ProdutorId := '{PRODUTOR-001}';
    LLimite.DistribuidorId := '{DISTRIBUIDOR-001}';
    LLimite.Limite := 0; // Inválido
    
    LExcecaoLancada := False;
    try
      LLimite.BeforeSave;
    except
      on E: Exception do
        LExcecaoLancada := True;
    end;
    
    Assert.IsTrue(LExcecaoLancada, 'Deveria lançar exceção quando limite é zero ou negativo');
  finally
    LLimite.Free;
  end;
end;

procedure TTestLimiteCreditoEntity.TestValidacaoProdutorDistribuidorDistintos;
var
  LLimite: TLimiteCreditoEntity;
  LExcecaoLancada: Boolean;
begin
  LLimite := TLimiteCreditoEntity.Create;
  try
    LLimite.ProdutorId := '{MESMO-ID}';
    LLimite.DistribuidorId := '{MESMO-ID}'; // Mesmos IDs - inválido
    LLimite.Limite := 50000.00;
    
    LExcecaoLancada := False;
    try
      LLimite.BeforeSave;
    except
      on E: Exception do
        LExcecaoLancada := True;
    end;
    
    Assert.IsTrue(LExcecaoLancada, 'Deveria lançar exceção quando Produtor e Distribuidor têm mesmo ID');
  finally
    LLimite.Free;
  end;
end;

procedure TTestLimiteCreditoEntity.TestEstadoInicialInsert;
var
  LLimite: TLimiteCreditoEntity;
begin
  LLimite := TLimiteCreditoEntity.Create;
  try
    Assert.AreEqual(Integer(esInsert), Integer(LLimite.State), 
      'Estado inicial deve ser esInsert');
  finally
    LLimite.Free;
  end;
end;

procedure TTestLimiteCreditoEntity.TestValoresIniciaisCorretos;
var
  LLimite: TLimiteCreditoEntity;
begin
  LLimite := TLimiteCreditoEntity.Create;
  try
    Assert.AreEqual('', LLimite.ProdutorId, 'ProdutorId inicial deve ser vazio');
    Assert.AreEqual('', LLimite.DistribuidorId, 'DistribuidorId inicial deve ser vazio');
    Assert.AreEqual(0.0, LLimite.Limite, 0.01, 'Limite inicial deve ser zero');
  finally
    LLimite.Free;
  end;
end;

initialization
  TDUnitX.RegisterTestFixture(TTestLimiteCreditoEntity);

end.

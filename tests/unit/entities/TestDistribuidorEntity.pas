unit TestDistribuidorEntity;

interface

uses
  DUnitX.TestFramework,
  System.SysUtils,
  DistribuidorEntity,
  GsBaseEntity;

type
  [TestFixture]
  TTestDistribuidorEntity = class
  public
    [Test]
    procedure TestCriacaoComDadosValidos;

    [Test]
    procedure TestValidacaoNomeObrigatorio;

    [Test]
    procedure TestValidacaoNomeTamanhoMinimo;

    [Test]
    procedure TestValidacaoCnpjObrigatorio;

    [Test]
    [TestCase('CNPJ Inválido - Zeros', '00.000.000/0000-00')]
    [TestCase('CNPJ Inválido - Sequencial', '11.111.111/1111-11')]
    [TestCase('CNPJ Inválido - Tamanho', '123456')]
    procedure TestValidacaoCnpjInvalido(const ACnpj: string);

    [Test]
    procedure TestEstadoInicialInsert;

    [Test]
    procedure TestGeracaoAutomaticaId;
  end;

implementation

{ TTestDistribuidorEntity }

procedure TTestDistribuidorEntity.TestCriacaoComDadosValidos;
var
  LDistribuidor: TDistribuidorEntity;
begin
  LDistribuidor := TDistribuidorEntity.Create;
  try
    LDistribuidor.Nome := 'Distribuidora Agro LTDA';
    LDistribuidor.Cnpj := '11.222.333/0001-81';
    
    // Não deveria lançar exceção para dados válidos
    LDistribuidor.BeforeSave;
    
    Assert.IsNotEmpty(LDistribuidor.Id, 'ID deve ser gerado automaticamente');
    Assert.AreEqual('Distribuidora Agro LTDA', LDistribuidor.Nome);
    Assert.AreEqual('11.222.333/0001-81', LDistribuidor.Cnpj);
  finally
    LDistribuidor.Free;
  end;
end;

procedure TTestDistribuidorEntity.TestValidacaoNomeObrigatorio;
var
  LDistribuidor: TDistribuidorEntity;
  LExcecaoLancada: Boolean;
begin
  LDistribuidor := TDistribuidorEntity.Create;
  try
    LDistribuidor.Nome := '';
    LDistribuidor.Cnpj := '11.222.333/0001-81';
    
    LExcecaoLancada := False;
    try
      LDistribuidor.BeforeSave;
    except
      on E: Exception do
        LExcecaoLancada := True;
    end;
    
    Assert.IsTrue(LExcecaoLancada, 'Deveria lançar exceção quando nome está vazio');
  finally
    LDistribuidor.Free;
  end;
end;

procedure TTestDistribuidorEntity.TestValidacaoNomeTamanhoMinimo;
var
  LDistribuidor: TDistribuidorEntity;
  LExcecaoLancada: Boolean;
begin
  LDistribuidor := TDistribuidorEntity.Create;
  try
    LDistribuidor.Nome := 'Ab'; // Menos de 3 caracteres
    LDistribuidor.Cnpj := '11.222.333/0001-81';
    
    LExcecaoLancada := False;
    try
      LDistribuidor.BeforeSave;
    except
      on E: Exception do
        LExcecaoLancada := True;
    end;
    
    Assert.IsTrue(LExcecaoLancada, 'Deveria lançar exceção quando nome tem menos de 3 caracteres');
  finally
    LDistribuidor.Free;
  end;
end;

procedure TTestDistribuidorEntity.TestValidacaoCnpjObrigatorio;
var
  LDistribuidor: TDistribuidorEntity;
  LExcecaoLancada: Boolean;
begin
  LDistribuidor := TDistribuidorEntity.Create;
  try
    LDistribuidor.Nome := 'Distribuidora Agro LTDA';
    LDistribuidor.Cnpj := '';
    
    LExcecaoLancada := False;
    try
      LDistribuidor.BeforeSave;
    except
      on E: Exception do
        LExcecaoLancada := True;
    end;
    
    Assert.IsTrue(LExcecaoLancada, 'Deveria lançar exceção quando CNPJ está vazio');
  finally
    LDistribuidor.Free;
  end;
end;

procedure TTestDistribuidorEntity.TestValidacaoCnpjInvalido(const ACnpj: string);
var
  LDistribuidor: TDistribuidorEntity;
  LExcecaoLancada: Boolean;
begin
  LDistribuidor := TDistribuidorEntity.Create;
  try
    LDistribuidor.Nome := 'Distribuidora Agro LTDA';
    LDistribuidor.Cnpj := ACnpj;
    
    LExcecaoLancada := False;
    try
      LDistribuidor.BeforeSave;
    except
      on E: Exception do
        LExcecaoLancada := True;
    end;
    
    Assert.IsTrue(LExcecaoLancada, Format('Deveria lançar exceção para CNPJ inválido: %s', [ACnpj]));
  finally
    LDistribuidor.Free;
  end;
end;

procedure TTestDistribuidorEntity.TestEstadoInicialInsert;
var
  LDistribuidor: TDistribuidorEntity;
begin
  LDistribuidor := TDistribuidorEntity.Create;
  try
    Assert.AreEqual(Integer(esInsert), Integer(LDistribuidor.State), 
      'Estado inicial deve ser esInsert');
  finally
    LDistribuidor.Free;
  end;
end;

procedure TTestDistribuidorEntity.TestGeracaoAutomaticaId;
var
  LDistribuidor: TDistribuidorEntity;
begin
  LDistribuidor := TDistribuidorEntity.Create;
  try
    LDistribuidor.Nome := 'Distribuidora Agro LTDA';
    LDistribuidor.Cnpj := '11.222.333/0001-81';
    LDistribuidor.BeforeSave;
    
    Assert.IsNotEmpty(LDistribuidor.Id, 'ID deve ser gerado automaticamente');
    Assert.IsTrue(LDistribuidor.Id.Contains('{'), 'ID deve ser um GUID');
  finally
    LDistribuidor.Free;
  end;
end;

initialization
  TDUnitX.RegisterTestFixture(TTestDistribuidorEntity);

end.

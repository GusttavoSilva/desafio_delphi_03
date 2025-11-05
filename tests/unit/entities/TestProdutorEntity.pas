unit TestProdutorEntity;

interface

uses
  DUnitX.TestFramework,
  System.SysUtils,
  ProdutorEntity,
  GsBaseEntity;

type
  [TestFixture]
  TTestProdutorEntity = class
  public
    [Test]
    [TestCase('CPF Válido', '123.456.789-09')]
    [TestCase('CNPJ Válido', '11.222.333/0001-81')]
    procedure TestCriacaoComDadosValidos(const ACpfCnpj: string);

    [Test]
    procedure TestValidacaoNomeObrigatorio;

    [Test]
    procedure TestValidacaoNomeTamanhoMinimo;

    [Test]
    procedure TestValidacaoCpfCnpjObrigatorio;

    [Test]
    [TestCase('CPF Inválido - Zeros', '000.000.000-00')]
    [TestCase('CPF Inválido - Sequencial', '111.111.111-11')]
    [TestCase('CNPJ Inválido - Zeros', '00.000.000/0000-00')]
    [TestCase('Tamanho Inválido', '123456')]
    procedure TestValidacaoCpfCnpjInvalido(const ACpfCnpj: string);

    [Test]
    procedure TestEstadoInicialInsert;

    [Test]
    procedure TestGeracaoAutomaticaId;

    [Test]
    procedure TestAtualizacaoDataHora;
  end;

implementation

{ TTestProdutorEntity }

procedure TTestProdutorEntity.TestCriacaoComDadosValidos(const ACpfCnpj: string);
var
  LProdutor: TProdutorEntity;
begin
  LProdutor := TProdutorEntity.Create;
  try
    LProdutor.Nome := 'João da Silva';
    LProdutor.CpfCnpj := ACpfCnpj;
    
    // Não deveria lançar exceção para dados válidos
    LProdutor.BeforeSave;
    
    Assert.IsNotEmpty(LProdutor.Id, 'ID deve ser gerado automaticamente');
    Assert.AreEqual('João da Silva', LProdutor.Nome);
    Assert.AreEqual(ACpfCnpj, LProdutor.CpfCnpj);
  finally
    LProdutor.Free;
  end;
end;

procedure TTestProdutorEntity.TestValidacaoNomeObrigatorio;
var
  LProdutor: TProdutorEntity;
  LExcecaoLancada: Boolean;
begin
  LProdutor := TProdutorEntity.Create;
  try
    LProdutor.Nome := '';
    LProdutor.CpfCnpj := '123.456.789-09';
    
    LExcecaoLancada := False;
    try
      LProdutor.BeforeSave;
    except
      on E: Exception do
        LExcecaoLancada := True;
    end;
    
    Assert.IsTrue(LExcecaoLancada, 'Deveria lançar exceção quando nome está vazio');
  finally
    LProdutor.Free;
  end;
end;

procedure TTestProdutorEntity.TestValidacaoNomeTamanhoMinimo;
var
  LProdutor: TProdutorEntity;
  LExcecaoLancada: Boolean;
begin
  LProdutor := TProdutorEntity.Create;
  try
    LProdutor.Nome := 'Ab'; // Menos de 3 caracteres
    LProdutor.CpfCnpj := '123.456.789-09';
    
    LExcecaoLancada := False;
    try
      LProdutor.BeforeSave;
    except
      on E: Exception do
        LExcecaoLancada := True;
    end;
    
    Assert.IsTrue(LExcecaoLancada, 'Deveria lançar exceção quando nome tem menos de 3 caracteres');
  finally
    LProdutor.Free;
  end;
end;

procedure TTestProdutorEntity.TestValidacaoCpfCnpjObrigatorio;
var
  LProdutor: TProdutorEntity;
  LExcecaoLancada: Boolean;
begin
  LProdutor := TProdutorEntity.Create;
  try
    LProdutor.Nome := 'João da Silva';
    LProdutor.CpfCnpj := '';
    
    LExcecaoLancada := False;
    try
      LProdutor.BeforeSave;
    except
      on E: Exception do
        LExcecaoLancada := True;
    end;
    
    Assert.IsTrue(LExcecaoLancada, 'Deveria lançar exceção quando CPF/CNPJ está vazio');
  finally
    LProdutor.Free;
  end;
end;

procedure TTestProdutorEntity.TestValidacaoCpfCnpjInvalido(const ACpfCnpj: string);
var
  LProdutor: TProdutorEntity;
  LExcecaoLancada: Boolean;
begin
  LProdutor := TProdutorEntity.Create;
  try
    LProdutor.Nome := 'João da Silva';
    LProdutor.CpfCnpj := ACpfCnpj;
    
    LExcecaoLancada := False;
    try
      LProdutor.BeforeSave;
    except
      on E: Exception do
        LExcecaoLancada := True;
    end;
    
    Assert.IsTrue(LExcecaoLancada, Format('Deveria lançar exceção para CPF/CNPJ inválido: %s', [ACpfCnpj]));
  finally
    LProdutor.Free;
  end;
end;

procedure TTestProdutorEntity.TestEstadoInicialInsert;
var
  LProdutor: TProdutorEntity;
begin
  LProdutor := TProdutorEntity.Create;
  try
    Assert.AreEqual(Integer(esInsert), Integer(LProdutor.State), 
      'Estado inicial deve ser esInsert');
  finally
    LProdutor.Free;
  end;
end;

procedure TTestProdutorEntity.TestGeracaoAutomaticaId;
var
  LProdutor: TProdutorEntity;
begin
  LProdutor := TProdutorEntity.Create;
  try
    LProdutor.Nome := 'João da Silva';
    LProdutor.CpfCnpj := '123.456.789-09';
    LProdutor.BeforeSave;
    
    Assert.IsNotEmpty(LProdutor.Id, 'ID deve ser gerado automaticamente');
    Assert.IsTrue(LProdutor.Id.Contains('{'), 'ID deve ser um GUID');
  finally
    LProdutor.Free;
  end;
end;

procedure TTestProdutorEntity.TestAtualizacaoDataHora;
var
  LProdutor: TProdutorEntity;
  LDataAntes: TDateTime;
begin
  LProdutor := TProdutorEntity.Create;
  try
    LDataAntes := Now;
    Sleep(10); // Aguarda um pouco
    
    LProdutor.Nome := 'João da Silva';
    LProdutor.CpfCnpj := '123.456.789-09';
    LProdutor.BeforeSave;
    
    Assert.IsTrue(LProdutor.CreatedAt >= LDataAntes, 
      'CreatedAt deve ser definido ao salvar');
    Assert.IsTrue(LProdutor.UpdatedAt >= LDataAntes, 
      'UpdatedAt deve ser definido ao salvar');
  finally
    LProdutor.Free;
  end;
end;

initialization
  TDUnitX.RegisterTestFixture(TTestProdutorEntity);

end.

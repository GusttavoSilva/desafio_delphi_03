program TestAliare;

{$IFNDEF TESTINSIGHT}
{$APPTYPE CONSOLE}
{$ENDIF}
{$STRONGLINKTYPES ON}

uses
  System.SysUtils,
  {$IFDEF TESTINSIGHT}
  TestInsight.DUnitX,
  {$ELSE}
  DUnitX.Loggers.Console,
  DUnitX.Loggers.Xml.NUnit,
  {$ENDIF }
  DUnitX.TestFramework,
  GsBaseEntity in '..\src\core\GsBaseEntity.pas',
  GsValidation in '..\src\modules\shared\utils\GsValidation.pas',
  ProdutorEntity in '..\src\modules\produtor\entities\ProdutorEntity.pas',
  DistribuidorEntity in '..\src\modules\distribuidor\entities\DistribuidorEntity.pas',
  LimiteCreditoEntity in '..\src\modules\limite_credito\entities\LimiteCreditoEntity.pas',
  LimiteCreditoController in '..\src\modules\limite_credito\controller\LimiteCreditoController.pas',
  LimiteCreditoRepository.Intf in '..\src\modules\limite_credito\repository\LimiteCreditoRepository.Intf.pas',
  ProdutorRepository.Intf in '..\src\modules\produtor\repository\ProdutorRepository.Intf.pas',
  DistribuidorRepository.Intf in '..\src\modules\distribuidor\repository\DistribuidorRepository.Intf.pas',
  MockLimiteCreditoRepository in 'mocks\MockLimiteCreditoRepository.pas',
  MockProdutorRepository in 'mocks\MockProdutorRepository.pas',
  MockDistribuidorRepository in 'mocks\MockDistribuidorRepository.pas',
  TestProdutorEntity in 'unit\entities\TestProdutorEntity.pas',
  TestDistribuidorEntity in 'unit\entities\TestDistribuidorEntity.pas',
  TestLimiteCreditoEntity in 'unit\entities\TestLimiteCreditoEntity.pas',
  TestLimiteCreditoController in 'unit\controllers\TestLimiteCreditoController.pas';

var
  runner: ITestRunner;
  results: IRunResults;
  logger: ITestLogger;
  nunitLogger : ITestLogger;

begin
{$IFDEF TESTINSIGHT}
  TestInsight.DUnitX.RunRegisteredTests;
  exit;
{$ENDIF}
  try
    // Verifica argumentos da linha de comando para CI/CD
    TDUnitX.CheckCommandLine;
    
    // Cria o runner
    runner := TDUnitX.CreateRunner;
    
    // Informa ao runner onde encontrar os testes
    runner.UseRTTI := True;
    
    // Logger para console
    logger := TDUnitXConsoleLogger.Create(true);
    runner.AddLogger(logger);
    
    // Logger para XML NUnit (útil para CI/CD)
    nunitLogger := TDUnitXXMLNUnitFileLogger.Create(TDUnitX.Options.XMLOutputFile);
    runner.AddLogger(nunitLogger);
    
    // Executa os testes
    results := runner.Execute;
    
    // Mantém o console aberto se estiver rodando em modo debug
    if not results.AllPassed then
    begin
      System.ExitCode := EXIT_ERRORS;
    end;
    
    {$IFNDEF CI}
    // Mantém o console aberto em modo interativo
    if TDUnitX.Options.ExitBehavior = TDUnitXExitBehavior.Pause then
    begin
      System.Write('Pressione Enter para sair...');
      System.Readln;
    end;
    {$ENDIF}
  except
    on E: Exception do
    begin
      System.Writeln(E.ClassName, ': ', E.Message);
      System.ExitCode := EXIT_ERRORS;
    end;
  end;
end.

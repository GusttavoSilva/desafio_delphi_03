@echo off
echo ====================================
echo EXECUTANDO TESTES COM RELATORIO XML
echo ====================================
echo.

cd /d "%~dp0"

REM Verifica se o executável existe
if not exist "TestAliare.exe" (
    echo [ERRO] TestAliare.exe nao encontrado!
    echo.
    echo Compile o projeto primeiro no Delphi.
    echo.
    pause
    exit /b 1
)

echo Executando testes e gerando relatorio XML...
echo.

REM Executa os testes com output XML
TestAliare.exe --xml=test-results.xml

echo.
if exist "test-results.xml" (
    echo [OK] Relatorio XML gerado: test-results.xml
) else (
    echo [AVISO] Relatorio XML nao foi gerado
)

echo.
echo ====================================
echo    TESTES FINALIZADOS
echo ====================================
echo.
echo Pressione qualquer tecla para fechar...
pause > nul

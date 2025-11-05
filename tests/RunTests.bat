@echo off
cls
color 0A
echo.
echo  ========================================
echo     SUITE DE TESTES - SISTEMA ALIARE
echo  ========================================
echo.
echo  [*] Preparando ambiente...
echo.

cd /d "%~dp0"

if not exist "TestAliare.exe" (
    color 0C
    echo  [ERRO] Executavel nao encontrado!
    echo.
    echo  Compile o projeto TestAliare.dpr primeiro.
    echo.
    pause
    exit /b 1
)

echo  [*] Executando testes...
echo.
echo  ========================================
echo.

REM Força output no console e pausa ao final
TestAliare.exe --exitbehavior:pause --consolemode:verbose 2>&1

if %ERRORLEVEL% EQU 0 (
    color 0A
    echo.
    echo  ========================================
    echo    [OK] TODOS OS TESTES PASSARAM!
    echo  ========================================
) else (
    color 0C
    echo.
    echo  ========================================
    echo    [FALHA] Alguns testes falharam!
    echo  ========================================
)

echo.
echo  Pressione qualquer tecla para sair...
pause > nul

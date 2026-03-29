@echo off
setlocal

:: Try to find mvn in PATH
where mvn >nul 2>nul
if %errorlevel% equ 0 (
    set "MVN_CMD=mvn"
) else (
    :: Try common IntelliJ IDEA Maven path
    set "INTELIJ_MVN=C:\Program Files\JetBrains\IntelliJ IDEA Community Edition 2025.2.1\plugins\maven\lib\maven3\bin\mvn.cmd"
    if exist "%INTELIJ_MVN%" (
        set "MVN_CMD=%INTELIJ_MVN%"
    ) else (
        echo Error: Maven (mvn) not found in PATH and not found at common IntelliJ IDEA location.
        echo Please install Maven or add it to your PATH.
        pause
        exit /b 1
    )
)

echo Using Maven: %MVN_CMD%
"%MVN_CMD%" jetty:run

rem Author: Matti
@echo off
set PROGRAMFILES32=%PROGRAMFILES(x86)%
if not exist "%PROGRAMFILES(x86)%" set PROGRAMFILES32=%PROGRAMFILES%

set VSWHERE=%PROGRAMFILES32%\Microsoft Visual Studio\Installer\vswhere.exe
if not exist "%VSWHERE%" (
    echo VS2017/VS2019 installation directory does not exist, or the vswhere.exe tool is missing.
    exit /b
)

"%VSWHERE%" -nologo -latest -requires Microsoft.Component.MSBuild -find MSBuild\**\Bin\MSBuild.exe 1>nul 2>&1
if not %ERRORLEVEL%==0 (
    @rem Fetch some version that gets it
    echo Fetching vswhere.exe...
    curl -O -L https://github.com/microsoft/vswhere/releases/download/2.8.4/vswhere.exe 1>nul
    set VSWHERE=vswhere.exe
)

set VSPATH=
for /f "usebackq tokens=*" %%i in (`"%VSWHERE%" -nologo -latest -latest -property installationPath`) do (
    set VSPATH=%%i
)
del vswhere.exe 1>nul 2>&1
call "%VSPATH%\VC\Auxiliary\Build\vcvarsall.bat" %*
@echo off

:check_dependencies
if not exist "%ProgramFiles%\dotnet\dotnet.exe" (
	color 4f
    echo ERROR: dotnet not found. Please install dotnet to continue.
    goto end
)
if "%VSINSTALLDIR%"=="" (
	color 4f
    echo ERROR: Visual Studio not found. Please install Visual Studio to continue.
    goto end
)

for /F "tokens=4 delims=\\" %%G in ("%VSINSTALLDIR%") do set "vsversion=%%G"
if %vsversion% LSS 2022 (
	color 4f
    echo ERROR: This script requires Visual Studio 2022 or newer. You are using version %vsversion%.
    goto end
)

goto run_build

:run_build
echo *** RUNNING BUILD ***
dotnet run --project build\build-serene.csproj --no-dependencies
if %ERRORLEVEL% GEQ 1 GOTO :error
goto build_template_package

:build_template_package
echo *** BUILDING TEMPLATE PACKAGE ***
"%VSINSTALLDIR%\MSBuild\Current\Bin\MSBuild.exe" "Template\Serene.Templates.sln" -verbosity:m
if %ERRORLEVEL% GEQ 1 GOTO :error
start Template\bin\Serene.Template.vsix
goto push_confirmation

:push_confirmation

echo.
color 1f
choice /C PC /N /M "[P]ush NuGet Package, or [C]ancel?: "
if errorlevel 2 goto end
if errorlevel 1 goto push

:push
color
nuget push Template\Assets\Serene.Template*.nupkg
if %ERRORLEVEL% GEQ 1 GOTO :error
start https://visualstudiogallery.msdn.microsoft.com/559ec6fc-feef-4077-b6d5-5a99408a6681/edit?newSession=True
goto end

:error
color 4f
echo ERROR: An error occurred during the build process.
echo ERROR CODE: %ERRORLEVEL%
pause
goto end

:end
color
exit /B 0
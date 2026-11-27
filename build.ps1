param([string]$OutputPath)

$ErrorActionPreference = 'Stop'
$framework = Join-Path $env:WINDIR 'Microsoft.NET\Framework64\v4.0.30319'
$compiler = Join-Path $framework 'csc.exe'
if (-not (Test-Path -LiteralPath $compiler)) {
    throw 'The Windows .NET Framework compiler could not be found.'
}

$source = Join-Path $PSScriptRoot 'src'
$output = Join-Path $PSScriptRoot ([string][char]0x421 + [char]0x435 + [char]0x43A + [char]0x442 + [char]0x43E + [char]0x440 + '.exe')
if ($OutputPath) {
    $output = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($OutputPath)
}
$references = @(
    (Join-Path $framework 'WPF\PresentationFramework.dll')
    (Join-Path $framework 'WPF\PresentationCore.dll')
    (Join-Path $framework 'WPF\WindowsBase.dll')
    (Join-Path $framework 'System.Xaml.dll')
    (Join-Path $framework 'System.Windows.Forms.dll')
    (Join-Path $framework 'System.IO.Compression.dll')
) | ForEach-Object { "/reference:$_" }

$files = (Get-ChildItem -LiteralPath $source -Filter '*.cs').FullName
$options = @(
    '/nologo', '/target:winexe', '/platform:x64', '/optimize+', '/codepage:65001', '/utf8output'
    "/out:$output", "/resource:$source\MainWindow.xaml,Sector.MainWindow.xaml"
    "/resource:$source\ReviewWindow.xaml,Sector.ReviewWindow.xaml"
    "/resource:$source\assets\cash-bundle.s3d,Sector.CashBundle.s3d"
    "/resource:$source\assets\sector-field.zip,Sector.SectorField.zip"
    "/win32manifest:$source\Sector.manifest", "/win32icon:$source\Sector.ico"
)
& $compiler @options @references @files
if ($LASTEXITCODE -ne 0) {
    throw "Compiler exited with status $LASTEXITCODE."
}
Get-Item -LiteralPath $output | Select-Object FullName, Length

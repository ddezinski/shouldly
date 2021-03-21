$ErrorActionPreference = 'Stop'

# Options
$configuration = 'Release'
$artifactsDir = Join-Path (Resolve-Path .) 'artifacts'
$packagesDir = Join-Path $artifactsDir 'Packages'
$testResultsDir = Join-Path $artifactsDir 'Test results'
$logsDir = Join-Path $artifactsDir 'Logs'

$dotnetArgs = @(
    '--configuration', $configuration
    '/p:ContinuousIntegrationBuild=' + ($env:CI -or $env:TF_BUILD)
)

# Build
# `/bl:$logsDir\build.binlog` removed to work around https://github.com/SimonCropp/MarkdownSnippets/issues/370
dotnet build @dotnetArgs
if ($LastExitCode) { exit 1 }

# Pack
Remove-Item -Recurse -Force $packagesDir -ErrorAction Ignore

dotnet pack src\Shouldly --no-build --output $packagesDir /bl:$logsDir\pack.binlog @dotnetArgs
if ($LastExitCode) { exit 1 }

# Test
Remove-Item -Recurse -Force $testResultsDir -ErrorAction Ignore

dotnet test --no-build --configuration $configuration --logger trx --results-directory $testResultsDir /bl:"$logsDir\test.binlog"
if ($LastExitCode) { exit 1 }

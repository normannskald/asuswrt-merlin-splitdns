<#
.SYNOPSIS
    Master Test Runner for Asuswrt-Merlin Split DNS GUI Addon.
    Executes E2E test suites (Tiers 1-5) using Python 3 and PowerShell 7.

.DESCRIPTION
    Runs opaque-box, requirement-driven tests covering feature contracts,
    boundary/corner cases, cross-feature combinations, real-world scenarios,
    and adversarial stress hardening.

.PARAMETER Tier
    Optional tier number (1, 2, 3, 4, 5). Default is 0 (runs all tiers).

.PARAMETER Verbose
    Enables detailed per-test execution output.

.EXAMPLE
    pwsh tests/run_all_tests.ps1
    pwsh tests/run_all_tests.ps1 -Tier 1
    pwsh tests/run_all_tests.ps1 -Verbose
#>

[CmdletBinding()]
param(
    [ValidateSet(0, 1, 2, 3, 4, 5)]
    [int]$Tier = 0,

    [switch]$VerboseOutput
)

$ErrorActionPreference = "Stop"

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$projectRoot = Split-Path -Parent $scriptDir
$testRunner = Join-Path $scriptDir "test_e2e.py"

Write-Host "==================================================================" -ForegroundColor Cyan
Write-Host " Asuswrt-Merlin Split DNS — Automated Test Suite Runner" -ForegroundColor Cyan
Write-Host " PowerShell Version: $($PSVersionTable.PSVersion)" -ForegroundColor DarkGray
Write-Host " Project Directory : $projectRoot" -ForegroundColor DarkGray
Write-Host "==================================================================" -ForegroundColor Cyan

# Locate Python 3
$pythonCmd = Get-Command "python" -ErrorAction SilentlyContinue
if (-not $pythonCmd) {
    $pythonCmd = Get-Command "python3" -ErrorAction SilentlyContinue
}

if (-not $pythonCmd) {
    Write-Host "[ERROR] Python 3 executable not found in PATH! Tests require Python 3.8+." -ForegroundColor Red
    exit 1
}

$pyArgs = @($testRunner)
if ($Tier -ne 0) {
    $pyArgs += "--tier=$Tier"
}
if ($VerboseOutput) {
    $pyArgs += "--verbose"
}

Write-Host "[*] Executing: $($pythonCmd.Source) $($pyArgs -join ' ')" -ForegroundColor Yellow
& $pythonCmd.Source $pyArgs
$exitCode = $LASTEXITCODE

if ($exitCode -eq 0) {
    Write-Host "`n[SUCCESS] All test suites completed successfully with exit code 0." -ForegroundColor Green
} else {
    Write-Host "`n[FAILURE] Test suite failed with exit code $exitCode!" -ForegroundColor Red
}

exit $exitCode

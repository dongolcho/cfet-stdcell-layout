# Runs the CFET DRC and LVS decks on one GDS file with KLayout in batch mode.
#
# Usage (PowerShell):
#   powershell -ExecutionPolicy Bypass -File run_checks.ps1 -Gds <layout.gds> [-Cell AOI21D1] [-Schematic ..\netlists\AOI21D1_4t.cir]
#
# Reports are written next to the GDS: <name>.drc.lyrdb (marker browser) and <name>.lvsdb (netlist browser).

param(
    [Parameter(Mandatory = $true)] [string] $Gds,
    [string] $Cell = "AOI21D1",
    [string] $Schematic = "",
    [string] $KLayout = (Join-Path $env:APPDATA "KLayout\klayout_app.exe")
)

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
if (-not $Schematic) { $Schematic = Join-Path $scriptDir "..\netlists\AOI21D1_4t.cir" }

if (-not (Test-Path -LiteralPath $Gds)) {
    Write-Output "Error: missing layout file '$Gds'. Pass the path of the saved GDS with -Gds."
    exit 1
}
if (-not (Test-Path -LiteralPath $KLayout)) {
    Write-Output "Error: missing KLayout executable '$KLayout'. Pass its path with -KLayout."
    exit 1
}

$gdsPath = (Resolve-Path -LiteralPath $Gds).Path
$stem = Join-Path (Split-Path $gdsPath) ([System.IO.Path]::GetFileNameWithoutExtension($gdsPath))
$drcReport = "$stem.drc.lyrdb"
$lvsReport = "$stem.lvsdb"

# klayout_app.exe is a GUI program, so its console output is captured through files.
function Invoke-KLayoutDeck([string] $deck, [string[]] $variables) {
    $arguments = @('-b', '-r', "`"$deck`"")
    foreach ($variable in $variables) { $arguments += @('-rd', "`"$variable`"") }
    $stdout = [System.IO.Path]::GetTempFileName()
    $stderr = [System.IO.Path]::GetTempFileName()
    Start-Process -FilePath $KLayout -ArgumentList $arguments -NoNewWindow -Wait `
        -RedirectStandardOutput $stdout -RedirectStandardError $stderr
    Get-Content $stdout
    Get-Content $stderr
    Remove-Item $stdout, $stderr
}

Write-Output "== DRC =="
Invoke-KLayoutDeck (Join-Path $scriptDir "cfet.drc") @("input=$gdsPath", "report=$drcReport", "cell=$Cell")
Write-Output ""
Write-Output "== LVS =="
Invoke-KLayoutDeck (Join-Path $scriptDir "cfet.lvs") @("input=$gdsPath", "schematic=$Schematic", "report=$lvsReport", "cell=$Cell")
Write-Output ""
Write-Output "Reports: $drcReport"
Write-Output "         $lvsReport"

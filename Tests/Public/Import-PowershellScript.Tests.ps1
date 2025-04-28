$here = (Split-Path -Parent $MyInvocation.MyCommand.Path).Replace((Join-Path "Tests" Public), (Join-Path PSNovusTools Public))
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")

. (Join-Path $here $sut)

# To make test runable from project root, and from test directory itself. Do quick validation.
$testsPath = Join-Path "Tests" "Public"
if ((Get-Location).Path -match [Regex]::Escape($testsPath)) {
    $psmPath = (Resolve-Path "..\..\PSNovusTools\PSNovusTools.psm1").Path    
} else {
    $psmPath = (Resolve-Path ".\PSNovusTools\PSNovusTools.psm1").Path
}

Import-Module $psmPath -Force -NoClobber

InModuleScope "PSNovusTools" {

    Describe "Import-PowershellScript" {

    }

}

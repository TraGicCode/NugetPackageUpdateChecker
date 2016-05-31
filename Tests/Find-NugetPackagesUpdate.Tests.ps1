$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
. "$here\..\Source\$sut"

Describe "Find-NugetPackagesUpdate" {
    It "does something useful" {
        $true | Should Be $false
    }
}
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
. "$here\..\Source\$sut"

Describe "Find-NugetPackagesUpdate" {
    
    Context "Parameter Validation" {
        
        It "should require a path that is not null or an empty string" {
            { Find-NugetPackagesUpdate -Path "" } | Should Throw "The argument is null or empty"
        }
    }
}
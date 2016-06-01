$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
. "$here\..\Source\$sut"

Describe "Find-NugetPackagesUpdate" {

    Context "Parameter Validation" {
        It "should require a path that is not null or an empty string" {
            { Find-NugetPackagesUpdate -Path "" } | Should Throw
        }

        It "should require a path that ends with a packages.config file" {
            { Find-NugetPackagesUpdate -Path "Xpackages.config" } | Should Throw
        }
        
        It "should throw when the file doesn't exist on the filesystem" {
            { Find-NugetPackagesUpdate -Path "C:\SomeFolder\packages.config" } | Should Throw "is not a valid file located on the filesystem."
        }

        It "should not throw when the file exists on the filesystem" {
            Mock Test-Path -MockWith { $True }
            { Find-NugetPackagesUpdate -Path "C:\SomeFolder\packages.config" } | Should Not Throw
        }
    }
}
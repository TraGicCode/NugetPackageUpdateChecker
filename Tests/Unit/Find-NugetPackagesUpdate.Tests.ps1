$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
. "$here\..\..\Source\$sut"

# Notes for me
# ====================================================
# Mocks scope to only describe and context blocks

# TestDrive
# ====================================================
# It is scope to describe blocks!
# Is 'virtual file system' just for tests.  Its implemented as a PSDrive
# When you enter a describe block you get a BRAND NEW virtual test file system that is just for your test.
# You can
# 1.) Write Files to it
# 2.) Read files from it
# 3.) Change Files from it
# Doesn't affect the files on your machine
# Doesn't depend on the users personal file system

# Under the hood its creating a temporary drive in $env:Temp
# $TestDrive contains absolute path to the testdrive
# NOTE: Should be $env:Temp
# Accessed like so TestDrive:\

# Example
# ====================================================
# Describe {
#   New-Item -Type File -Path TestDrive:\Describe.txt

#   Context {
#      "Hello" | Add-Content TestDrive:\Describe.txt
#      New-Item -Type File -Path TestDrive:\Context.txt
#   }
# }
Function Create-PackagesConfigXml
{
    [CmdletBinding()]
    [OutputType([String])]
    Param(
        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [System.Collections.Hashtable]
        $Packages
    )
$configFile =
@"
<?xml version="1.0" encoding="utf-8"?>
<packages>
"@
    ForEach ($key in $Packages.Keys)
    {
        $configFile += "<package id='$key' version='$($Packages[$key])' />"
    }
return $configFile += "</packages>"
}

Function Create-RandomPackageSource
{
    [CmdletBinding()]
    [OutputType([String[]])]
    Param(
    )
    return "https://RandomPackageSource.com/api/v3/$(Get-Random).json"
}

$packageSource1 = Create-RandomPackageSource
$packageSource2 = Create-RandomPackageSource

Describe "When getting the latest nuget package version for one package" {

    New-Item -Type File -Path TestDrive:\packages.config
    Create-PackagesConfigXml -Packages @{'PackageA'='1.0.0'} | Add-Content TestDrive:\packages.config

    Context "and there is not an update" {

        Mock Invoke-RestMethod -MockWith { 
            return [PSCustomObject]@{
                properties = @{
                    Version = "1.0.0"
                }
            }
        }

        It "should return no results for one package source" {
            $results = Find-NugetPackagesUpdate -Path TestDrive:\packages.config -PackageSources Create-RandomPackageSource
            $results | Should BeNullOrEmpty
        }

        It "should return no results for 2 or more package sources" {
            $results = Find-NugetPackagesUpdate -Path TestDrive:\packages.config -PackageSources Create-RandomPackageSource, Create-RandomPackageSource
            $results | Should BeNullOrEmpty
        }

    }

    Context "and there is an update" {

        Mock Invoke-RestMethod -ParameterFilter { $Uri -like "*$packageSource1*" } -MockWith { 
            return [PSCustomObject]@{
                properties = @{
                    Version = "2.0.0"
                }
            }
        }

        Mock Invoke-RestMethod -ParameterFilter { $Uri -like "*$packageSource2*" } -MockWith { 
            return [PSCustomObject]@{
                properties = @{
                    Version = "1.0.0"
                }
            }
        }

        It "should return the updated package from one package source" {
            $results = Find-NugetPackagesUpdate -Path TestDrive:\packages.config -PackageSources $packageSource1
            $results | Should Not BeNullOrEmpty
            $results[0].PackageId | Should BeExactly "PackageA"
            $results[0].CurrentVersion | Should BeExactly "1.0.0"
            $results[0].NewVersion | Should BeExactly "2.0.0"
        }


        It "should return the updated package from two package sources" {
            $results = Find-NugetPackagesUpdate -Path TestDrive:\packages.config -PackageSources $packageSource2, $packageSource1
            $results | Should Not BeNullOrEmpty
            $results[0].PackageId | Should BeExactly "PackageA"
            $results[0].CurrentVersion | Should BeExactly "1.0.0"
            $results[0].NewVersion | Should BeExactly "2.0.0"
        }
    }
}


Describe "When getting the latest nuget package version for two or more packages" {

    New-Item -Type File -Path TestDrive:\packages.config
    Create-PackagesConfigXml -Packages @{'PackageA'='1.0.0'; 'PackageB'='2.0.0'} | Add-Content TestDrive:\packages.config

    Context "and there is not an update to none" {

        Mock Invoke-RestMethod -MockWith { 
            return [PSCustomObject]@{
                properties = @{
                    Version = "1.0.0"
                }
            }
        }

        It "should return no results for one package source" {
            $results = Find-NugetPackagesUpdate -Path TestDrive:\packages.config -PackageSources $packageSource1
            $results | Should BeNullOrEmpty
        }

        It "should return no results for two package source" {
            $results = Find-NugetPackagesUpdate -Path TestDrive:\packages.config -PackageSources $packageSource2, $packageSource1
            $results | Should BeNullOrEmpty
        }

    }


    Context "and there is an update to one" {

        It "should return one result for one package source" {

        Mock Invoke-RestMethod -ParameterFilter { $Uri -like "*PackageA*" } -MockWith { 
            return [PSCustomObject]@{
                properties = @{
                    PackageId = "PackageA"
                    Version = "1.0.0"
                }
            }
        }

        Mock Invoke-RestMethod -ParameterFilter { $Uri -like "*PackageB*" } -MockWith { 
            return [PSCustomObject]@{
                properties = @{
                    PackageId = "PackageB"
                    Version = "3.0.0"
                }
            }
        }

            $results = Find-NugetPackagesUpdate -Path TestDrive:\packages.config -PackageSources $packageSource1
            $results | Should Not BeNullOrEmpty
            $results[0].PackageId | Should BeExactly "PackageB"
            $results[0].CurrentVersion | Should BeExactly "2.0.0"
            $results[0].NewVersion | Should BeExactly "3.0.0"
            { $results[1] } | Should Throw
        }

        It "should return one result for two or more package source" {


        Mock Invoke-RestMethod -ParameterFilter { $Uri -like "*PackageA*" -and $Uri -like "*$packageSource1*" } -MockWith { 
            return [PSCustomObject]@{
                properties = @{
                    PackageId = "PackageA"
                    Version = "1.0.0"
                }
            }
        }

        Mock Invoke-RestMethod -ParameterFilter { $Uri -like "*PackageB*" -and $Uri -like "*$packageSource1*" } -MockWith { 
            return [PSCustomObject]@{
                properties = @{
                    PackageId = "PackageB"
                    Version = "2.0.0"
                }
            }
        }

        Mock Invoke-RestMethod -ParameterFilter { $Uri -like "*PackageA*" -and $Uri -like "*$packageSource2*" } -MockWith { 
            return [PSCustomObject]@{
                properties = @{
                    PackageId = "PackageA"
                    Version = "1.0.0"
                }
            }
        }


        Mock Invoke-RestMethod -ParameterFilter { $Uri -like "*PackageB*" -and $Uri -like "*$packageSource2*" } -MockWith { 
            return [PSCustomObject]@{
                properties = @{
                    PackageId = "PackageB"
                    Version = "3.0.0"
                }
            }
        }

            $results = Find-NugetPackagesUpdate -Path TestDrive:\packages.config -PackageSources $packageSource2, $packageSource1
            $results | Should Not BeNullOrEmpty
            $results[0].PackageId | Should BeExactly "PackageB"
            $results[0].CurrentVersion | Should BeExactly "2.0.0"
            $results[0].NewVersion | Should BeExactly "3.0.0"
            { $results[1] } | Should Throw
        }
    }

    Context "and there is an update to both" {

        It "should return two results for one package source" {

        Mock Invoke-RestMethod -ParameterFilter { $Uri -like "*PackageA*" } -MockWith { 
            return [PSCustomObject]@{
                properties = @{
                    PackageId = "PackageA"
                    Version = "2.0.0"
                }
            }
        }

        Mock Invoke-RestMethod -ParameterFilter { $Uri -like "*PackageB*" } -MockWith { 
            return [PSCustomObject]@{
                properties = @{
                    PackageId = "PackageB"
                    Version = "3.0.0"
                }
            }
        }

            $results = Find-NugetPackagesUpdate -Path TestDrive:\packages.config -PackageSources $packageSource1
            $results | Should Not BeNullOrEmpty
            $results[0].PackageId | Should BeExactly "PackageA"
            $results[0].CurrentVersion | Should BeExactly "1.0.0"
            $results[0].NewVersion | Should BeExactly "2.0.0"
            $results[1].PackageId | Should BeExactly "PackageB"
            $results[1].CurrentVersion | Should BeExactly "2.0.0"
            $results[1].NewVersion | Should BeExactly "3.0.0"
        }

        It "should return two results for two or more package sources" {

        Mock Invoke-RestMethod -ParameterFilter { $Uri -like "*PackageA*" -and $Uri -like "*$packageSource1*" } -MockWith { 
            return [PSCustomObject]@{
                properties = @{
                    PackageId = "PackageA"
                    Version = "2.0.0"
                }
            }
        }

        Mock Invoke-RestMethod -ParameterFilter { $Uri -like "*PackageB*" -and $Uri -like "*$packageSource1*" } -MockWith { 
            return [PSCustomObject]@{
                properties = @{
                    PackageId = "PackageB"
                    Version = "2.0.0"
                }
            }
        }

        Mock Invoke-RestMethod -ParameterFilter { $Uri -like "*PackageA*" -and $Uri -like "*$packageSource2*" } -MockWith { 
            return [PSCustomObject]@{
                properties = @{
                    PackageId = "PackageA"
                    Version = "1.0.0"
                }
            }
        }


        Mock Invoke-RestMethod -ParameterFilter { $Uri -like "*PackageB*" -and $Uri -like "*$packageSource2*" } -MockWith { 
            return [PSCustomObject]@{
                properties = @{
                    PackageId = "PackageB"
                    Version = "3.0.0"
                }
            }
        }

            $results = Find-NugetPackagesUpdate -Path TestDrive:\packages.config -PackageSources $packageSource2, $packageSource1
            $results | Should Not BeNullOrEmpty
            $results[0].PackageId | Should BeExactly "PackageA"
            $results[0].CurrentVersion | Should BeExactly "1.0.0"
            $results[0].NewVersion | Should BeExactly "2.0.0"
            $results[1].PackageId | Should BeExactly "PackageB"
            $results[1].CurrentVersion | Should BeExactly "2.0.0"
            $results[1].NewVersion | Should BeExactly "3.0.0"
        }
    }
}
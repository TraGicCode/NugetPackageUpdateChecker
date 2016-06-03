$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
. "$here\..\Source\$sut"

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

Describe "Find-NugetPackagesUpdate" {

    Context "Parameter Validation" {
        It "should require a path that is not null or an empty string" {
            { Find-NugetPackagesUpdate -Path "" } | Should Throw
        }

        It "should require a path that ends with a packages.config file" {
            { Find-NugetPackagesUpdate -Path "Xpackages.config" } | Should Throw
        }
        
        It "should throw when the file doesn't exist on the filesystem" {
            { Find-NugetPackagesUpdate -Path "TestDrive:\packages.config" } | Should Throw "is not a valid file located on the filesystem."
        }
        
        It "should not throw when the file exists on the filesystem" {
            New-Item -Type File -Path TestDrive:\packages.config
            { Find-NugetPackagesUpdate -Path "TestDrive:\packages.config" } | Should Not Throw
        }
    }
    
    Context "Method Body" {
        It "should return an object of type array" {
            { Find-NugetPackagesUpdate -Path "packages.config" } | Should BeOfType [PSCustomObject]
        }
        
        New-Item -Type File -Path TestDrive:\packages.config
        Create-PackagesConfigXml -Packages @{'PackageA'='1.0.0'} | Add-Content TestDrive:\packages.config
        
        It "should return no results for no package updates" {
            Mock Invoke-RestMethod -MockWith { 
                return [PSCustomObject]@{
                    data = @{
                        version = "1.0.0"
                    }
                }
            }

            $results = Find-NugetPackagesUpdate -Path TestDrive:\packages.config
            $results | Should BeNullOrEmpty
        }
        
        It "should return results for Pester package" {
            Mock Invoke-RestMethod -MockWith { 
                $innerObject = New-Object –TypeName PSObject
                $innerObject | Add-Member –MemberType NoteProperty –Name version –Value "2.0.0"
                $object = New-Object –TypeName PSObject
                $object | Add-Member –MemberType NoteProperty –Name data –Value $innerObject
                return $object
            }
            $results = Find-NugetPackagesUpdate -Path TestDrive:\packages.config
            $results | Should Not BeNullOrEmpty
        }
    }
}
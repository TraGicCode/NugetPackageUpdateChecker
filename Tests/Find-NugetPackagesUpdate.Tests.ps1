﻿$here = Split-Path -Parent $MyInvocation.MyCommand.Path
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
            # Arrange
            New-Item -Type File -Path TestDrive:\packages.config
            { Find-NugetPackagesUpdate -Path "TestDrive:\packages.config" } | Should Not Throw
            # Assert
            Remove-Item -Path TestDrive:\packages.config
        }
    }
    
    Context "Method Body" {
        It "should return an object of type array" {
            { Find-NugetPackagesUpdate -Path "packages.config" } | Should BeOfType [PSCustomObject]
        }
    }
}
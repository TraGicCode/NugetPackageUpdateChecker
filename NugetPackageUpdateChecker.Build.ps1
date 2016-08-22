<#
.Synopsis
    NugetPackageUpdateChecker Build Script
#>

[CmdletBinding()]
Param(
)

Set-StrictMode -Version Latest

# Includes
. ".\Scripts\Nuget-Helpers.ps1"
. ".\Scripts\Find-NugetTool.ps1"
. ".\Source\Find-NugetPackagesUpdate.ps1"

# Script Variables
$BuildArtifactsFolder = "$BuildRoot\.BuildArtifacts"
$NugetFolder = "$BuildRoot\.nuget"
$NugetExe = "$NugetFolder\nuget.exe"
$NugetPackageConfig = "$BuildRoot\packages.config"
$NuGetPackagesFolder = "$BuildRoot\packages"
$SourceFolder = "$BuildRoot\Source"

#=================================================================================================
# Synopsis: Performs a Clean of all build artifacts
#=================================================================================================
Task Clean {
    If (Test-Path -Path $BuildArtifactsFolder)
	{
		Remove-Item $BuildArtifactsFolder -Force -Recurse
	}
    
    If (Test-Path -Path $NugetFolder)
	{
		Remove-Item $NugetFolder -Force -Recurse
	}

    New-Item -Path $BuildArtifactsFolder -ItemType Directory | Out-Null
    New-Item -Path $NugetFolder -ItemType Directory | Out-Null
}

#=================================================================================================
# Synopsis: Downloads Nuget.exe
#=================================================================================================
Task Download-Nuget {
    Download-NugetExe -OutputDirectory $NugetFolder
}

#=================================================================================================
# Synopsis: Restores NuGet Packages
#=================================================================================================
Task Restore-NugetPackages Download-Nuget, {
    Exec { & $NugetExe restore $NugetPackageConfig -output $NuGetPackagesFolder  }
}

#=================================================================================================
# Synopsis: Run Code Quality on Powershell Scripts
#=================================================================================================
Task Run-CodeQualityPowerShell {
    Import-Module -Name (Find-NugetTool -ToolName PSScriptAnalyzer.psm1 -PackagesFolder $NuGetPackagesFolder)

    Invoke-ScriptAnalyzer -Path "$SourceFolder\Find-NugetPackagesUpdate.ps1"
}

#=================================================================================================
# Synopsis: Run NugetPackageUpdater on self (dogfood)
#=================================================================================================
Task Run-NugetPackageUpdateChecker {
    Find-NugetPackagesUpdate -Path $NugetPackageConfig -PackageSources "https://www.powershellgallery.com/api/v2"
}

#=================================================================================================
# Synopsis: Run Code Quality on Powershell Scripts
#=================================================================================================
Task Run-Tests {
    Import-Module -Name (Find-NugetTool -ToolName Pester.psm1 -PackagesFolder $NuGetPackagesFolder)

    Invoke-Pester -Path .\Tests\ -OutputFile "$BuildArtifactsFolder\TestResults.xml" -OutputFormat NUnitxml -CodeCoverage .\Source\*
}

Task . Clean, Restore-NugetPackages, Run-CodeQualityPowerShell, Run-NugetPackageUpdateChecker, Run-Tests, {
}

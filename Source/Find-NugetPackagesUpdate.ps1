<#
.SYNOPSIS
Determine which nuget packages contain stable updates

.DESCRIPTION
Use to parse a nuget packages.config file and query the nuget RESTful api to check for any
stable updates available.

.EXAMPLE
$PackagesWithUpdates = Find-NugetPackagesUpdate

#>
Function Find-NugetPackagesUpdate
{
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    Param(
        [ValidatePattern('[\\?]packages.config')]
        [ValidateScript({
            If (Test-Path $_) {
                $True
            }
            else {
                Throw "$_ is not a valid file located on the filesystem."
            }
        })]
        [Parameter(Mandatory=$True)]
        [String]
        $Path,
        [Parameter(Mandatory=$False)]
        [switch]
        $ShowPreRelease
    )
    return New-Object PSCustomObject -Property @{}
}


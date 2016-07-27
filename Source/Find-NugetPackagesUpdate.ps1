<#
.SYNOPSIS
Check for nuget package updates.

.DESCRIPTION
Use to parse a nuget packages.config file and query the nuget RESTful api to check for any
stable updates available.

.PARAMETER Path
Absolute or relative path to your packages.config file.

.PARAMETER ShowPreRelease
Take into consideration prelease versions.

.EXAMPLE
$PackagesWithUpdates = Find-NugetPackagesUpdate

#>
Function Find-NugetPackagesUpdate
{
    [CmdletBinding()]
    [OutputType([PSCustomObject[]])]
    Param(
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
    [PSCustomObject[]]$results = @()
    $packages = Select-Xml -Path $Path -XPath "/packages/package" | Select-Object -ExpandProperty Node
    ForEach ($package in $packages)
    {
          $response = Invoke-RestMethod -Method Get -Uri "https://api-v2v3search-0.nuget.org/query?q=$($package.id)&skip=0&take=1&prerelease=$(if ($ShowPreRelease.IsPresent) { $True } else { $False })&supportedFramework=.NETFramework,Version=v4.5"
          If ($response[0].data.version -gt $package.version)
          {
              $results += [PSCustomObject]@{
                  PackageId = $package.id
                  CurrentVersion = $package.version
                  NewVersion = $response[0].data.version
              }
          }

    }
    return $results
}
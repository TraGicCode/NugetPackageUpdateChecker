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
        [Parameter(Mandatory=$True)]
        [String[]]
        $PackageSources,
        [Parameter(Mandatory=$False)]
        [switch]
        $ShowPreRelease
    )
    [PSCustomObject[]]$results = @()
    $packages = Get-NugetPackage -Path $Path





    ## 1.) Search through all packages 1 by 1
    ##     If your find the package in a package source continue searching because a newer one might be in another package source that is specified

    ForEach($package in $packages)
    {
        $found = $false
        ForEach($packageSource in $PackageSources)
        {
            
        }
    }


    ## 2.) Is there a way i can ask a package source what version of nuget api its using
    ##     http://nuget.org/api/v2/$metadata
    ##     http://nuget.org/api/v1/$metadata
    ##     https://www.powershellgallery.com/api/v2/$metadata
    ##     https://www.powershellgallery.com/api/v1/$metadata
    ##     https://api.nuget.org/v3/index.json
    ## 3.) Extract methods to be able to build the url for the correct query for a package taking into account prerelease..

    <#

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

    #>

    ForEach ($package in $packages)
    {
          $response = Invoke-RestMethod -Method Get -Uri "https://www.powershellgallery.com/api/v2/FindPackagesById()?id='$($package.id)'&`$filter=IsAbsoluteLatestVersion&includePrerelease=$(if ($ShowPreRelease.IsPresent) { $True } else { $False })"
          If ($response.properties.Version -gt $package.Version)
          {
              $results += [PSCustomObject]@{
                  PackageId = $package.Id
                  CurrentVersion = $package.Version
                  NewVersion = $response.properties.Version
              }
          }
    }


    return $results
}

Function Get-NugetPackage
{
    [CmdletBinding()]
    [OutputType([PSCustomObject[]])]
    Param(
        [Parameter(Mandatory=$True)]
        [String]
        $Path
    )
    [PSCustomObject[]]$packages = @()
    $packagesXml = Select-Xml -Path $Path -XPath "/packages/package" | Select-Object -ExpandProperty Node
    ForEach ($package in $packagesXml)
    {
        $packages += [PSCustomObject]@{
            Id = $package.id
            Version = $package.version
        }
    }
    return $packages
}
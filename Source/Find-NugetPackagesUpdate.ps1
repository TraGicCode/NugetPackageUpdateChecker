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
    [OutputType([PSCustomObject[]])]
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
    [PSCustomObject[]]$results = @()
    $packages = Select-Xml -Path $Path -XPath "/packages/package" | Select-Object -ExpandProperty Node
    ForEach ($package in $packages)
    {
          $response = Invoke-RestMethod -Method Get -Uri "https://api-v2v3search-0.nuget.org/query?q=$($package.id)&skip=0&take=1&prerelease=$(if ($ShowPreRelease.IsPresent) { $True } else { $False })&supportedFramework=.NETFramework,Version=v4.5"
          If ($response[0].data.version -gt $package.version)
          {
            $object = New-Object –TypeName PSObject
            $object | Add-Member –MemberType NoteProperty –Name PackageId –Value $package.id
            $object | Add-Member –MemberType NoteProperty –Name CurrentVersion –Value $package.version
            $object | Add-Member -MemberType NoteProperty –Name NewVersion –Value $response[0].data.version
            $results += $object
          }

    }
    return $results
}


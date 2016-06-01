
#Requires -Version 3
Function Set-NugetPackageVersion {
Param(
    [String]
    $NuspecFile,
    [String]
    $Version
)
    $nuspec = [xml](Get-Content -Path $NuspecFile)
	$nuspec.package.metadata.version = $Version
	$nuspec.Save($NuspecFile);
}

Function Create-NugetPackage {
Param(
    [String]
    $NugetExe,
    [String]
    $NuspecFile,
    [String]
    $OutputDirectory
)
    If ((Test-Path -Path $OutputDirectory) -eq $False)
    {
        New-Item -Path $OutputDirectory -ItemType Directory | Out-Null
    }
    Exec { & $NuGetExe pack $NuspecFile -OutputDirectory $OutputDirectory  }
}

Function Download-NugetExe {
Param(
    [String]
    $OutputDirectory
)
    $cachedNugetFolder = "$env:LOCALAPPDATA\NuGet"
    $cachedNugetExe = "$cachedNugetFolder\NuGet.exe"
    If ((Test-Path -Path $cachedNugetFolder) -eq $False)
    {
        New-Item -ItemType Directory -Path $cachedNugetFolder | Out-Null
    }

    If ((Test-Path -Path $cachedNugetExe) -eq $False)
    {
        Invoke-WebRequest 'https://www.nuget.org/nuget.exe' -OutFile $cachedNugetExe -ErrorAction SilentlyContinue
    }
    
    If ((Test-Path -Path $OutputDirectory) -eq $False)
    {
         New-Item -ItemType Directory -Path $OutputDirectory | Out-Null
    }

    Copy-Item -Path $cachedNugetExe -Destination $OutputDirectory
}
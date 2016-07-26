# NugetPackageUpdateChecker


[![Version](https://img.shields.io/badge/Version-1.0.0-blue.svg)]()
[![Version](https://ci.appveyor.com/api/projects/status/github/TraGicCode/NugetPackageUpdateChecker?svg=true)](https://ci.appveyor.com/project/TraGicCode/nugetpackageupdatechecker)
[![Version](https://img.shields.io/badge/Coverage-94.44%25-brightgreen.svg)]()
[![Version](https://img.shields.io/badge/Dependencies-up--to--date-brightgreen.svg)]()
[![Version](https://img.shields.io/badge/License-MIT-blue.svg)](https://github.com/TraGicCode/NugetPackageUpdateChecker/blob/master/LICENSE)
[![Version](https://img.shields.io/badge/Contact-@TraGicCode-blue.svg)](https://twitter.com/TraGicCode)

It's vital to always be aware of when your application's third party nuget packages drift from the latest version.  This tool is meant to be easily used for local builds and build server builds.

## Whats wrong with falling to far behind?
The issue with falling to far behind on a version of a certain core thirdparty library is that fact that risk goes up.  Risk actually gets worse the longer you wait to perform upgrades.  If anything you should atleast take small steps by incrementally upgrading on each release instead of a giant jump.  This is known as a 'big bang' update according to Andreas Ohlund.  In order to solve this you simply need to be willing to bring awareness of version changes to third parties along with willingness to perform the upgrade and their possible breaking changes.  Also reading release notes...etc.  Generally Libraries should strive to keep in mind backwards compatibility so that users can update the library, continue to use the old deprecated stuff, but implement new things using the new stuff while at the same time slowly taking chunks of code using old deperecated functionality and upgrading it slowly.  If the third party doesnt keep this part of the deal your out of luck! :(

## Usage

    C:\PS> Find-NugetPackagesUpdate -Path "C:\Source\Project\packages.config"

This command will report out of date nuget packages from the nuget.org v3 authorative package source.

    C:\PS> Find-NugetPackagesUpdate -Path "C:\Source\Project\packages.config" -ShowPreRelease

Providing the PreRelease switch will show you the latest version of a package taking into account prereleases.

## Contributing

1. Fork it ( https://github.com/TraGicCode/NugetPackageUpdateChecker/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request


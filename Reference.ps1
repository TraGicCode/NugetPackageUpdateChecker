# Nuget v1 Feed Info
#
# http://elegantcode.com/2011/09/27/whats-happening-on-the-nuget-feed-leveraging-odata-in-an-rss-reader
# https://www.nuget.org/api/v1
#
# Nuget v2 Feed Info
# https://www.nuget.org/api/v2
#
# http://chris.eldredge.io/blog/2013/02/25/fun-with-nuget-rest-api/
#
# Nuget V3 feed info
# https://api.nuget.org/v3/index.json


# Nuget v2 Feed Info
# https://www.nuget.org/api/v2
#
#
## https://www.nuget.org/api/v2/curated-feeds/microsoftdotnet/Search()?$filter=IsAbsoluteLatestVersion&searchTerm=''&targetFramework='net45'&includePrerelease=true&$skip=0&$top=26 
# Basic Search
Invoke-RestMethod -Method Get -Uri "https://www.powershellgallery.com/api/v2/FindPackagesById()?id='Pester'"

# Search only show latest along with including prerelease
Invoke-RestMethod -Method Get -Uri "https://www.powershellgallery.com/api/v2/FindPackagesById()?id='Pester'&`$filter=IsAbsoluteLatestVersion&includePrerelease=true"
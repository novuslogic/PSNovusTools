<#
.SYNOPSIS
    Gets the version from a .csproj file.
.DESCRIPTION
    Returns the <Version> or <PackageVersion> from the first <PropertyGroup> in the provided .csproj file.
#>
function Get-VSPackage {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, HelpMessage = "Enter the full path to the .csproj file.")]
        [ValidateNotNullOrEmpty()]
        [string]$ProjectFile
    )

    process {
        # Optional: Require admin
        if (-not (Get-IsAdministrator)) {
            Write-Error "Please run as administrator."
            return ""
        }

        if (-not (Test-Path -LiteralPath $ProjectFile)) {
            Write-Error "The specified project file does not exist: $ProjectFile"
            return ""
        }

        # Load the XML as a single string (not line-by-line)
        [xml]$projectXml = Get-Content -Path $ProjectFile -Raw

        if (-not $projectXml.Project) {
            Write-Error "Invalid .csproj structure. <Project> root not found."
            return ""
        }

        $propertyGroup = $projectXml.Project.PropertyGroup | Select-Object -First 1
        if (-not $propertyGroup) {
            Write-Error "No <PropertyGroup> found."
            return ""
        }

        # Try to get Version or PackageVersion
        $versionNode = $propertyGroup.Version
        $packageVersionNode = $propertyGroup.PackageVersion

        $Version = $null

        if ($versionNode) {
            $Version = $versionNode.'#text'
        }
        elseif ($packageVersionNode) {
            $Version = $packageVersionNode.'#text'
        }
        else {
            Write-Warning "Did not find <Version> or <PackageVersion> in first <PropertyGroup>."
            $Version = ""
        }

        return $Version
    }
}

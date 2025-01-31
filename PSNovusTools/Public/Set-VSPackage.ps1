<#
.SYNOPSIS
    Updates the <Version> or <PackageVersion> in a .csproj file.

.DESCRIPTION
    This command updates or sets the version information for a Visual Studio 
    .NET project file (.csproj). It locates <Version> or <PackageVersion>
    in the first <PropertyGroup> section. If neither is found, it creates a new 
    <Version> element under a <PropertyGroup>.

.EXAMPLE
    Set-VSPackageVersion -ProjectFile "C:\Repos\MyApp\MyApp.csproj" -Version "2.0.0"

    This example updates or sets the version to 2.0.0.
#>
function Set-VSPackage {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, 
                   HelpMessage = "Enter the full path to the .csproj file.")]
        [ValidateNotNullOrEmpty()]
        [string]$ProjectFile,
        
        [Parameter(Mandatory = $true, 
                   HelpMessage = "Enter the new version (e.g. 1.2.3).")]
        [ValidateNotNullOrEmpty()]
        [string]$Version
    )

    process {
        # (Optional) Check if the script is running with administrative privileges
        # Comment this block out if you don't need admin checks.
        if (-not (Get-IsAdministrator)) {
            Write-Error "Please run as administrator."
            return $false
        }

        # Ensure the file exists
        if (-not (Test-Path -LiteralPath $ProjectFile)) {
            Write-Error "The specified project file does not exist: $ProjectFile"
            return $false
        }

        # Load the .csproj as XML
        [xml]$projectXml = Get-Content -Path $ProjectFile

        # Ensure <Project> root exists
        if (-not $projectXml.Project) {
            Write-Error "Invalid .csproj structure. <Project> root not found."
            return $false
        }

        # Get the first PropertyGroup (create one if none exist)
        $propertyGroup = $projectXml.Project.PropertyGroup | Select-Object -First 1
        if (-not $propertyGroup) {
            Write-Verbose "No <PropertyGroup> found; creating a new one..."
            $propertyGroup = $projectXml.CreateElement("PropertyGroup")
            [void]$projectXml.Project.AppendChild($propertyGroup)
        }

        # Find existing Version or PackageVersion
        #   Note: .NET XML nodes are case-sensitive by default when using the DOM. 
        #   To make it simpler, we try each one explicitly.
        $versionNode = $propertyGroup.Version
        $packageVersionNode = $propertyGroup.PackageVersion
        
        if ($versionNode) {
            # If <Version> exists, just update it
            Write-Verbose "Found existing <Version> element. Updating..."
            $propertyGroup.Version = $Version
        }
        elseif ($packageVersionNode) {
            # Else if <PackageVersion> exists, update it
            Write-Verbose "Found existing <PackageVersion> element. Updating..."
            $propertyGroup.PackageVersion = $Version
        }
        else {
            # Neither <Version> nor <PackageVersion> exist, so create a new <Version> element
            Write-Verbose "Did not find <Version> or <PackageVersion>. Creating a new <Version> element..."
            
            # Create a new <Version> element under the first <PropertyGroup>
            $newVersionElement = $projectXml.CreateElement("Version")
            $newVersionElement.InnerText = $Version
            [void]$propertyGroup.AppendChild($newVersionElement)
        }

        # Save the file
        try {
            $projectXml.Save($ProjectFile)
            Write-Verbose "Successfully updated version in $ProjectFile."
        }
        catch {
            Write-Error "Failed to save project file. Error: $_"
            return $false
        }

        return $true
    }
}

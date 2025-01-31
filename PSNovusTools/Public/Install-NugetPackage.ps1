function Install-NugetPackage {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, HelpMessage = "Enter NuGet package name")]
        [ValidateNotNullOrEmpty()]
        [string]$PackageName,

        [Parameter(Mandatory = $false)]
        [string]$Version,

        [Parameter(Mandatory = $false)]
        [string]$Source = "https://www.nuget.org/api/v2"
    )

    process {
        # Check if the script is running with administrative privileges
        if (-not (Get-IsAdministrator)) {
            Write-Error "Please run as administrator."
            return $nill
        }


        try {
            Install-Package -Name $PackageName -Source $Source -RequiredVersion $Version -ErrorAction Stop
            Write-Verbose "Package '$PackageName' installed successfully from $Source."
            $result = $true
        }
        catch {
            Write-Error "Failed to install package '$PackageName'. Error: $_"
            $result = $false 
        }

        return $result
    }
}

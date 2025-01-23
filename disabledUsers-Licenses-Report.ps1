# Script: Disabled Users License Report
# Date: 2025-01-23
# Author: Edward Crotty
# License: BSD License
#
#
# Description:
# This script retrieves all disabled users from Microsoft 365 and their assigned licenses.
# It provides a detailed report of each user's licenses and a summary of total license counts.
# The script automatically handles the installation of required Microsoft Graph modules if they're not present.
# The results are displayed in the console and automatically exported to a CSV file in the script's directory.
#
# Output:
# - Console display of user licenses and summary
# - CSV file with detailed results (saved in script directory with timestamp)
#
# Example Usage:
# .\disabledUsers-Licenses-Report.ps1    # Run the report

# Function to ensure required modules are installed
function Ensure-ModuleInstalled {
    param(
        [string]$ModuleName
    )
    
    if (!(Get-Module -ListAvailable -Name $ModuleName)) {
        Write-Host "Installing required module: $ModuleName..." -ForegroundColor Yellow
        Install-Module -Name $ModuleName -Force -AllowClobber -Scope CurrentUser
    }
}

# Check and install required modules
$requiredModules = @(
    'Microsoft.Graph.Authentication',
    'Microsoft.Graph.Users',
    'Microsoft.Graph.Identity.DirectoryManagement'
)

foreach ($module in $requiredModules) {
    Ensure-ModuleInstalled -ModuleName $module
}

# Import required modules
foreach ($module in $requiredModules) {
    Import-Module $module
}

# Function to format license names for better readability
function Format-LicenseName {
    param([string]$SkuId)
    
    $licenseNames = @{
        'SPE_E5' = 'Microsoft 365 E5'
        'WIN10_VDA_E5' = 'Windows 10/11 Enterprise E5'
        'FLOW_FREE' = 'Power Automate Free'
        'POWER_BI_STANDARD' = 'Power BI Pro'
        'POWERAPPS_DEV' = 'Power Apps Developer Plan'
        'POWERAUTOMATE_ATTENDED_RPA' = 'Power Automate per user with attended RPA'
        'ENTERPRISEPACK' = 'Office 365 E3'
        'STANDARDPACK' = 'Office 365 E1'
        'ENTERPRISEPREMIUM' = 'Office 365 E5'
        'EXCHANGESTANDARD' = 'Exchange Online Plan 1'
        'MCOSTANDARD' = 'Teams'
    }
    
    if ($licenseNames.ContainsKey($SkuId)) {
        return $licenseNames[$SkuId]
    }
    return $SkuId
}

# Connect to Microsoft Graph
Write-Host "Connecting to Microsoft Graph..." -ForegroundColor Cyan
Connect-MgGraph -Scopes "User.Read.All", "Directory.Read.All"

# Get all disabled users
Write-Host "Retrieving disabled users..." -ForegroundColor Cyan
$disabledUsers = Get-MgUser -Filter "accountEnabled eq false" -All | 
    Select-Object DisplayName, UserPrincipalName, Id, AccountEnabled, 
                  @{Name='Licenses';Expression={$_.AssignedLicenses.SkuId}}

# Process users and their licenses
$results = @()
$licenseSummary = @{}

Write-Host "Processing user licenses..." -ForegroundColor Cyan
foreach ($user in $disabledUsers) {
    $licenses = Get-MgUserLicenseDetail -UserId $user.Id
    
    foreach ($license in $licenses) {
        $licenseName = Format-LicenseName $license.SkuPartNumber
        
        # Add to summary count
        if ($licenseSummary.ContainsKey($licenseName)) {
            $licenseSummary[$licenseName]++
        } else {
            $licenseSummary[$licenseName] = 1
        }
        
        # Add to detailed results
        $results += [PSCustomObject]@{
            DisplayName = $user.DisplayName
            UserPrincipalName = $user.UserPrincipalName
            LicenseName = $licenseName
            SkuPartNumber = $license.SkuPartNumber
        }
    }
}

# Display results in a format that's easy to copy/paste
Write-Host "`nDisabled Users and Their Licenses:`n" -ForegroundColor Green
$results | Format-Table -AutoSize | Out-String -Width 4096 | Write-Host

# Display license summary in a clean format
Write-Host "`nLicense Summary:`n" -ForegroundColor Green
$licenseSummary.GetEnumerator() | Sort-Object Name | ForEach-Object {
    Write-Host "$($_.Key): $($_.Value) users"
}

# Export results to CSV
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$csvPath = Join-Path $PSScriptRoot "DisabledUsers-Licenses-Report_$timestamp.csv"
$results | Export-Csv -Path $csvPath -NoTypeInformation
Write-Host "`nResults exported to: $csvPath" -ForegroundColor Green

Write-Host "`nScript completed!" -ForegroundColor Green

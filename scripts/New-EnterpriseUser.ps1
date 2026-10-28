<#
.SYNOPSIS
    Enterprise User Provisioning Script
.DESCRIPTION
    Automates the creation of Active Directory user accounts, sets secure temporary credentials,
    assigns department-specific group memberships, and logs all administrative actions.
.AUTHOR
    Systems & Infrastructure Automation
#>

[CmdletBinding()]
param (
    [Parameter(Mandatory=$true)]
    [string]$FirstName,

    [Parameter(Mandatory=$true)]
    [string]$LastName,

    [Parameter(Mandatory=$true)]
    [string]$Department,

    [Parameter(Mandatory=$true)]
    [string]$JobTitle,

    [Parameter(Mandatory=$false)]
    [string]$TargetOU = "OU=Users,OU=Enterprise,DC=corp,DC=local"
)

# Import Active Directory Module
if (-not (Get-Module -ListAvailable -Name ActiveDirectory)) {
    Write-Error "The Active Directory PowerShell module is required but not installed."
    exit 1
}
Import-Module ActiveDirectory

# Generate clean sAMAccountName (e.g., jsmith)
$CleanFirst = $FirstName.ToLower() -replace '[^a-z]', ''
$CleanLast = $LastName.ToLower() -replace '[^a-z]', ''
$SamAccountName = "$($CleanFirst.Substring(0,1))$CleanLast"
$UserPrincipalName = "$SamAccountName@corp.local"
$DisplayName = "$FirstName $LastName"

Write-Host "[-] Provisioning account for: $DisplayName ($SamAccountName)..." -ForegroundColor Cyan

try {
    # Define secure temporary password
    $SecurePassword = ConvertTo-SecureString "TempP@ss2026!" -AsPlainText -Force

    # Create AD User Object
    New-ADUser -SamAccountName $SamAccountName `
               -UserPrincipalName $UserPrincipalName `
               -Name $DisplayName `
               -GivenName $FirstName `
               -Surname $LastName `
               -DisplayName $DisplayName `
               -Department $Department `
               -Title $JobTitle `
               -Path $TargetOU `
               -AccountPassword $SecurePassword `
               -Enabled $true `
               -ChangePasswordAtLogon $true `
               -ErrorAction Stop

    Write-Host "[+] Successfully created Active Directory object for $DisplayName." -ForegroundColor Green

    # Department-based Group Assignment Logic
    $GroupMap = @{
        "IT"        = "SG-Domain-Admins-Access"
        "Finance"   = "SG-Finance-FileShare"
        "Operations"= "SG-Operations-Staff"
    }

    if ($GroupMap.ContainsKey($Department)) {
        $TargetGroup = $GroupMap[$Department]
        Add-ADGroupMember -Identity $TargetGroup -Members $SamAccountName -ErrorAction Stop
        Write-Host "[+] Assigned $SamAccountName to security group: $TargetGroup" -ForegroundColor Green
    } else {
        Write-Host "[!] No automatic group mapping found for department: $Department. Review manual assignments." -ForegroundColor Yellow
    }

}
catch {
    Write-Error "[-] Failed to provision user $SamAccountName. Error: $_"
}

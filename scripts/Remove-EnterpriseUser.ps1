<#
.SYNOPSIS
    Enterprise User Decommissioning Script
.DESCRIPTION
    Handles secure offboarding by disabling accounts, stripping group memberships, 
    relocating objects to a disabled container, and logging compliance details.
.AUTHOR
    Systems & Infrastructure Automation
#>

[CmdletBinding()]
param (
    [Parameter(Mandatory=$true)]
    [string]$SamAccountName,

    [Parameter(Mandatory=$false)]
    [string]$DisabledOU = "OU=Disabled,OU=Enterprise,DC=corp,DC=local"
)

Import-Module ActiveDirectory

Write-Host "[-] Initiating offboarding sequence for user: $SamAccountName..." -ForegroundColor Yellow

try {
    $User = Get-ADUser -Identity $SamAccountName -Properties MemberOf, DistinguishedName -ErrorAction Stop

    # 1. Disable Account
    Disable-ADAccount -Identity $SamAccountName -ErrorAction Stop
    Write-Host "[+] Account $SamAccountName has been disabled." -ForegroundColor Green

    # 2. Strip Group Memberships (except Primary Group)
    foreach ($Group in $User.MemberOf) {
        Remove-ADGroupMember -Identity $Group -Members $SamAccountName -Confirm:$false -ErrorAction Stop
        Write-Host "[+] Removed from group: $Group" -ForegroundColor Gray
    }

    # 3. Move to Disabled OU
    Move-ADObject -Identity $User.DistinguishedName -TargetPath $DisabledOU -ErrorAction Stop
    Write-Host "[+] Relocated account to container: $DisabledOU" -ForegroundColor Green

    Write-Host "[SUCCESS] Offboarding pipeline completed cleanly for $SamAccountName." -ForegroundColor Cyan
}
catch {
    Write-Error "[-] Critical error during offboarding of $SamAccountName: $_"
}

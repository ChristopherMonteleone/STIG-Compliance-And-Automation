<#
.SYNOPSIS
    This PowerShell script ensures that the maximum size of the Windows Security event log is at least 1,024,000 KB.

.NOTES
    Author       : Christopher Monteleone
    LinkedIn     : https://www.linkedin.com/in/christopher-monteleone/
    GitHub       : https://github.com/ChristopherMonteleone
    Date Created : 2026-02-17
    Last Modified: 2026-02-17
    Version      : 1.0
    CVEs         : N/A
    Plugin IDs   : N/A
    STIG-ID      : WN10-AU-000505

.TESTED ON
    Date(s) Tested : 2026-02-17
    Tested By      : Christopher Monteleone
    Systems Tested : Windows 10
    PowerShell Ver.: 5.1

.USAGE
    Run this script with administrative privileges to enforce the Security log size policy.
    Example syntax:
    PS C:\> .\Remediate_WN10-AU-000505.ps1
#>

# Define the STIG requirement (1,024,000 KB)
$LogSizeRequirement = 1024000
# Define the Policy Registry Path (STIGs check the Policy path, not just the current setting)
$RegPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\EventLog\Security"
$RegName = "MaxSize"

try {
    # Check if the Registry Key exists
    if (-not (Test-Path $RegPath)) {
        Write-Host "[-] Non-Compliant: Registry key for Security Event Log policy does not exist." -ForegroundColor Red
        New-Item -Path $RegPath -Force | Out-Null
        Write-Host "    Created registry path: $RegPath"
    }

    # Get the current value
    $CurrentValue = Get-ItemProperty -Path $RegPath -Name $RegName -ErrorAction SilentlyContinue

    if ($null -eq $CurrentValue -or $CurrentValue.MaxSize -lt $LogSizeRequirement) {
        Write-Host "[-] Non-Compliant: Security log size is not correctly enforced (Current: $(if($CurrentValue){$CurrentValue.MaxSize}else{'Not Set'}) KB)." -ForegroundColor Red
        
        # Remediate: Set the registry value to 1024000
        Write-Host "    Setting Security Event Log MaxSize to $LogSizeRequirement KB..."
        Set-ItemProperty -Path $RegPath -Name $RegName -Value $LogSizeRequirement -Type DWord
        
        # Force a Group Policy update to apply the setting immediately to the OS
        Write-Host "    Forcing Group Policy update to apply changes..."
        gpupdate /force
        
        # Verify the fix
        $Verify = Get-ItemProperty -Path $RegPath -Name $RegName
        if ($Verify.MaxSize -ge $LogSizeRequirement) {
            Write-Host "[+] Success: Security Event Log size enforced at $($Verify.MaxSize) KB." -ForegroundColor Green
        } else {
            Write-Host "[!] Failure: Could not update registry key." -ForegroundColor Red
        }
    }
    else {
        Write-Host "[+] Compliant: Security Event Log size is already set to $($CurrentValue.MaxSize) KB." -ForegroundColor Green
    }
}
catch {
    Write-Host "[!] Error: $_" -ForegroundColor Red
}

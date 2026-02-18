# STIG Compliance And Automation with PowerShell
Documented the remediation of 10 Windows Security Technical Implementation Guides (STIGs). This project demonstrates a workflow of vulnerability auditing, manual patching, and developing PowerShell scripts for automated compliance.

## High-Level Process

The following workflow was executed for **10 specific Windows 10 STIG vulnerabilities**. This cycl (Audit, Remediate, Verify) was repeated for each finding to ensure a robust understanding of both manual system hardening and automated compliance.

### 1. Baseline Auditing & Analysis
* **Ingested Compliance Policies:** Loaded the **DISA Windows 10 STIG** benchmark into the **SCAP Compliance Checker**.
* **Initial Scan:** Performed an automated scan of the Windows 10 lab environment to establish a baseline security posture.
* **Vulnerability Identification:** Analyzed the generated compliance report to identify high-severity "Open" findings (e.g., *WN10-CC-000206 - WinRM Unencrypted Traffic*).

### 2. Manual Remediation (Research Phase)
* **Root Cause Analysis:** Investigated the specific Registry Keys and Group Policy (GPO) settings required to satisfy the STIG requirement.
* **Manual Implementation:** Applied the remediation manually via `regedit` or `gpedit.msc` to understand the system-level impact of the control.
* **Verification:** Re-scanned the target to confirm the manual fix successfully resolved the finding.

### 3. Automation Development (Scripting Phase)
* **Environment Reset:** Reverted the system configuration to its previous **non-compliant state** to prepare for automation testing.
* **PowerShell Scripting:** Developed a custom PowerShell script for the finding.
    * *Logic Implemented:* The scripts utilize "Idempotency"—checking the current registry value before attempting a change to avoid redundant operations.
    * *Error Handling:* Included `Try/Catch` blocks to ensure robust execution.
* **Script Execution:** Deployed the script (`.\Remediate_STIG-ID.ps1`) against the target environment.

### 4. Final Validation
* **Post-Remediation Scanning:** Conducted a final SCAP scan to verify that the script successfully enforced the policy.
* **Compliance Confirmation:** Confirmed the finding status transitioned from **"Open"** to **"Not a Finding"**.
* **Documentation:** Committed the verified script to the repository with detailed comments explaining the STIG ID, registry path, and remediation logic.

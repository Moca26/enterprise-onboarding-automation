# Enterprise Onboarding & Lifecycle Automation Framework

A production-grade PowerShell automation framework designed to streamline and secure user provisioning, Active Directory (AD) management, and Microsoft 365 / Entra ID lifecycle operations across enterprise IT environments.

## 🚀 Overview
Managing user lifecycle across 400+ endpoints and multiple administrative consoles introduces human error, security gaps, and significant administrative overhead. This framework provides structured, audited, and repeatable scripts to handle automated user onboarding and offboarding.

## 🛠️ Core Features
* **Automated Provisioning:** Creates AD user objects, sets secure temporary passwords, assigns department-specific security/distribution groups, and configures home folder paths.
* **Role-Based Access Control (RBAC):** Automatically maps group memberships based on organizational unit (OU) and department metadata.
* **Secure Offboarding Safeguards:** Disables accounts, revokes active sessions, strips group memberships, relocates objects to a designated "Disabled Users" container, and archives audit logs.
* **Robust Error Handling:** Utilizes structured `try/catch` blocks, colored console logging, and rolling log files for compliance and troubleshooting.

## 📂 Repository Structure
```text
├── config/
│   └── settings.json.example    # Configuration template for paths and OU DNs
└── scripts/
    ├── New-EnterpriseUser.ps1     # Automated onboarding provisioning script
    └── Remove-EnterpriseUser.ps1  # Automated offboarding & decommissioning script


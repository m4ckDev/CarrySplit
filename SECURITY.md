# Security Policy

Carry Splits is a local-first iOS application. Version 1.0 does not require accounts, remote APIs, cloud storage, analytics SDKs, advertising SDKs, or payment processing.

## Security Principles

- Minimize collected data.
- Keep expense data on-device for v1.0.
- Do not add network access without a documented product requirement.
- Do not commit secrets, signing credentials, API keys, provisioning profiles, or private certificates.
- Prefer Apple platform security controls and system frameworks.
- Validate all user-entered monetary values and allocations.
- Treat persistence migrations as data-integrity changes and test them accordingly.

## Reporting a Vulnerability

Do not publish sensitive vulnerability details in a public issue. Contact the repository owner privately with reproduction steps, affected versions, and impact.

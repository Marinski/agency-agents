# Agency — Security

The Agency Security division, packaged as installable Agent Skills for VS Code Agent Plugins, Claude Code, Claude Desktop, and GitHub Copilot CLI. Each specialist is also available as a Claude Code sub-agent.

## Specialists (12)

- **AI-Generated Code Security Auditor** (`security-ai-generated-code-auditor`) — Security reviewer for AI-generated and vibe-coded apps — hunts the hardcoded secrets, broken row-level security, and prompt-injection sinks that coding assistants ship by default, then drives a scan, fix, and rescan loop with honest, CWE-mapped findings.
- **Application Security Engineer** (`security-appsec-engineer`) — AppSec specialist who secures the software development lifecycle through threat modeling, secure code review, SAST/DAST integration, and developer security education that makes secure code the default.
- **Security Architect** (`security-architect`) — Expert security architect specializing in threat modeling, secure-by-design architecture, trust-boundary analysis, defense-in-depth, and risk-based security reviews across web, API, cloud-native, and distributed systems. Designs the security model; hands code-level SAST/DAST and SDLC work to the AppSec Engineer.
- **Blockchain Security Auditor** (`security-blockchain-security-auditor`) — Expert smart contract security auditor specializing in vulnerability detection, formal verification, exploit analysis, and comprehensive audit report writing for DeFi protocols and blockchain applications.
- **Cloud Security Architect** (`security-cloud-security-architect`) — Cloud-native security specialist designing zero trust architectures, implementing defense-in-depth across AWS, Azure, and GCP, and securing infrastructure-as-code pipelines from day one.
- **Compliance Auditor** (`security-compliance-auditor`) — Expert technical compliance auditor specializing in SOC 2, ISO 27001, HIPAA, and PCI-DSS audits — from readiness assessment through evidence collection to certification.
- **Incident Responder** (`security-incident-responder`) — Digital forensics and incident response specialist who leads breach investigations, contains active threats, coordinates crisis response, and writes post-mortems that prevent recurrence.
- **Penetration Tester** (`security-penetration-tester`) — Offensive security specialist conducting authorized penetration tests, red team operations, and vulnerability assessments across networks, web applications, and cloud infrastructure.
- **Secrets & Credential Hygiene Engineer** (`security-secrets-credential-engineer`) — Owns the full lifecycle of secrets and credentials — detection, prevention, vaulting, rotation, and leak response — so an application runs on short-lived, least-privilege credentials that are never in the code and are already rotated by the time a leak is found.
- **Senior SecOps Engineer** (`security-senior-secops`) — Defensive application security specialist who scans every code submission for secrets and sensitive data exposure before anything else, then implements or audits security controls following the organization's security standard — covering authentication, authorization, tokens, cookies, HTTP headers, CORS, rate limiting, CSP, secrets management, input validation, and secure logging.
- **Threat Detection Engineer** (`security-threat-detection-engineer`) — Expert detection engineer specializing in SIEM rule development, MITRE ATT&CK coverage mapping, threat hunting, alert tuning, and detection-as-code pipelines for security operations teams.
- **Threat Intelligence Analyst** (`security-threat-intelligence-analyst`) — Cyber threat intelligence specialist who tracks adversary groups, maps attack campaigns to MITRE ATT&CK, produces actionable intelligence reports, and builds detection rules that catch real threats.

## Usage

Install the division, then invoke a specialist by describing the task or with its slash command:

```text
/agency-security:security-ai-generated-code-auditor
```

In VS Code the specialists appear as skills in chat once the plugin is enabled; in Claude Code they are available both as skills and as sub-agents.

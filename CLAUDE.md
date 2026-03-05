# CLAUDE.md — Agentic InfoSec Platform

> This file provides Claude Code with full context on this project — what it is, where it's going, how it's being built, and the principles behind it. Read this before doing anything.

---

## What Is This Project?

An agentic security platform that automates how software is built, deployed, and monitored.

Instead of manually reviewing code, running security checks, and managing risk in spreadsheets — a connected system of AI agents does it continuously. Developers (or non-technical users) publish a spec, agents build and test it securely, and the platform monitors the impact on the organisation's security posture in real time. Humans observe and approve, rather than operate.

**This is being built in 3 tracks:**
- **Track 1 (now):** A standalone personal PoC — built end-to-end in a personal AWS account to validate the workflow (spec → pipeline → deploy → evidence) before involving FrankieOne.
- **Track 2 (future shortly):** An internal platform at FrankieOne — proving the concept in a real RegTech environment with real compliance requirements (this remains a PoC, but is deployed and validated inside FrankieOne once Track 1 is solid).
- **Track 3 (future far):** A commercial product targeting AI-first companies that are scaling fast without a dedicated DevSecOps function.

---

## The Problem Being Solved

AI-assisted "vibe coding" means non-technical people are shipping applications faster than ever. But there is no consistent way to ensure those deployments meet security, compliance, or infrastructure standards. The gap between "I built an app" and "this is running securely in production" is growing rapidly.

Existing tools (Vercel, Railway, GitHub Actions, Snyk) either require technical literacy or treat security as a bolt-on afterthought. This platform treats governance as the foundation — not the gate at the end.

---

## Core Concepts

### The Three Circles (from the InfoSec Strategic Vision diagram)

**ASDLC — Agentic Secure Development Lifecycle**
Specs are published into a backlog. AI agents plan, threat model, risk assess, and build the code. A developer portal provides observability, governance, and human-on-the-loop oversight. PID controllers monitor pipeline health and trigger failsafes when processes step outside tolerance.

**ROC — Risk Operations Center**
Cyber risk posture is monitored 24/7 using KCRIs (Key Control Risk Indicators). The highest-impact controls are kept within tolerance via self-healing agents. Predictive risk posture reporting is informed directly from real-time ASDLC pipeline data and ITCC conformance.

**SOC — Security Operations Center**
All releases are tested and validated against a digital twin or production-grade UAT environment before reaching production. Cyber threat assessments and threat models are continuously updated using CTI and digital-twin-informed analysis.

These three functions are not siloed — they form a single continuous system feeding each other in real time.

### The Digital Twin (Graph Database)
The connective tissue beneath all three circles. A graph database that models the relationships between:
- Security controls and policies
- AWS infrastructure resources
- Application code and Terraform
- Threat models
- Deployment history and pipeline status

This enables the system to understand *context* — a misconfigured S3 bucket isn't just a finding, it's a node connected to three controls, two threat scenarios, and a production service handling customer PII. That context changes everything about how you respond and what risk it actually represents.

### Spec Driven Development
The core development workflow. Instead of writing code directly, a developer (or agent) publishes a spec in plain language. The spec is elaborated into requirements, broken into tasks, and executed by an agent swarm. Humans review and approve — they don't operate. Eventually specs come from Jira tickets with an "approved" label, picked up automatically by a backend agent swarm with no human initiation required.

### ITPF and ITCC
**ITPF — IT Policy Framework:** The overarching set of IT policies that define how the organisation manages security, risk, and compliance. The source of truth for what "good" looks like.

**ITCC — IT Control Catalogue:** The specific, actionable controls derived from the ITPF. These are what get mapped to deployments, monitored for conformance, and reported against. In this platform, the ITCC is exposed as an MCP service so agents can query and validate against it automatically.

### CRQ — Cyber Risk Quantification
The practice of expressing cybersecurity risk in measurable, often financial terms rather than qualitative ratings (high/medium/low). In this platform, CRQ is informed directly by real-time pipeline data — control conformance, technical debt, deployment frequency, and security scan results — to produce a continuously updated risk score. KCRIs (Key Control Risk Indicators) are the specific metrics monitored to detect when risk is moving outside acceptable tolerance.

### Self Healing
Risk-impacting cybersecurity vulnerabilities or controls issues are auto-remediated by AI agents via Spec Driven Development and Agent MCP Orchestration. The system doesn't just alert — it fixes.

---

## Architecture Overview

### Key Components

| Component | Purpose | Technology |
|---|---|---|
| Policy Engine | Enforces deployment governance rules | Open Policy Agent (OPA) |
| Pipeline Orchestration | Runs builds, tests, security checks | GitHub Actions |
| Security Scanning | SAST, dependency, IaC misconfiguration | Trivy, Checkov, Semgrep |
| Infrastructure Provisioning | Deploys to AWS | Terraform |
| Agent Orchestration | Multi-agent workflow execution | LangGraph |
| Digital Twin | Relationship modelling and risk correlation | Graph Database (Neo4j or Neptune) |
| Developer Portal | Observability, lifecycle dashboard, governance UI | Next.js |
| Controls MCP Service | Exposes IT policies and controls as agent-callable tools | MCP Server |
| IDE | Spec driven development environment | Kiro (AWS) |
| AI Model | Powers agent execution | Claude Opus |

### Compliance Frameworks
The platform is aligned against three frameworks from the start. All policy templates and control mappings are designed to produce evidence against these:

- **SOC 2** — Trust Services Criteria covering security, availability, and confidentiality. Critical for FrankieOne's enterprise customer relationships and a key requirement in the commercial product for AI-first startups going upmarket.
- **ISO 27001** — International standard for information security management systems. Provides the broader control framework structure.
- **NIST CSF** — NIST Cybersecurity Framework. Used for risk categorisation and the identify → protect → detect → respond → recover lifecycle which maps naturally to the ASDLC → ROC → SOC model.

Where controls overlap across frameworks, the platform maps them once and reports against all three — avoiding duplicate compliance work.

### Deployment Target
AWS — primary cloud provider. All infrastructure defined in Terraform.

### Key AWS Services in Use
- Lambda (compute for PoC)
- ECS (container workloads)
- App Runner (managed container deployment)
- S3 (artefact storage)
- RDS / Neptune (data layer)
- CloudWatch (observability)
- IAM / AWS SSO (access control)

---

## Development Principles

### Security by Design, Not by Default
Security checks are not a gate at the end of the pipeline. They are baked into the pipeline from the first commit. The platform performs a risk analysis of the app first, then automatically aligns it against the appropriate security controls based on what the app actually does.

### Policy as the Foundation
A technical lead defines deployment policies once through a checklist of pre-built templates. Every deployment — regardless of who ships it — is automatically enforced against those policies. Non-technical users never see the underlying checks.

### Humans on the Loop, Not in It
Agents build, test, scan, and deploy. Humans review, approve, and observe. The goal is to move humans out of the operational path and into the oversight layer.

### Abstraction Over Complexity
Each layer of the platform hides the complexity below it. The non-technical deployer never sees Terraform, OPA, or security scan output. They see a deploy button and a status dashboard. This is the "next abstraction layer" above CI/CD.

### Async Agent Execution — No Laptop Required
Agent workloads run on a backend service, not a local machine. The workflow is: publish a spec, close the laptop, come back to a completed PR or a flagged blocker. This requires the agent runtime to live on a persistent backend — ECS tasks or Lambda-powered orchestration via LangGraph — triggered by events (a Jira ticket label, a GitHub webhook, a scheduled job). A developer should never need to sit and watch an agent work.

### Spec Driven Everything
All changes — features, fixes, infrastructure updates — begin as a spec. No spec, no build. This ensures every change is planned, documented, and traceable before a line of code is written.

---

## Phased Roadmap

### Phase 1 — Learn the tools, prove the concept *(current)*
- Create a simple spec (markdown is fine) for a Lambda + API Gateway deployment — GET endpoint returning 200
- Implement a GitHub Actions pipeline that runs a full vertical slice:
  - Build
  - Test
  - **(Optional early gate)** One security check (prefer starting with Checkov for Terraform)
  - Deploy via Terraform (Lambda + API Gateway)
  - Verify by calling the API Gateway invoke URL and asserting 200
  - Write a run-record JSON to S3 **on both success and failure** (stage status, timestamps, outputs, and plain-language error)
- Agent-driven workflow is the target, but early scaffolding/setup can be manual if it accelerates proving the loop
- **Goal:** Prove the closed loop (spec → pipeline → deploy → verify → evidence in S3) end to end.

### Phase 2 — Developer portal and lifecycle dashboard
- Build a dashboard showing deployment lifecycle stages: build → test → security scan → deploy
- Show pass/fail status, failure insights, basic logs
- Non-technical friendly — no raw log output, plain language status
- **Goal:** Full observability of the pipeline in one place

### Phase 3 — Security baked into the pipeline
- Integrate Trivy (container scanning), Checkov (IaC misconfiguration), Semgrep (SAST)
- Policy defined once by a technical lead via tick-box UI backed by pre-built templates
- Every deployment automatically scanned — pipeline blocks on failure
- Plain language failure explanations surfaced in the portal
- **Goal:** Nothing ships without passing security checks

### Phase 4 — Controls and compliance mapping
- Turn IT policies and controls into an MCP service
- Every deployment automatically maps against the control framework
- Current conformance posture visible in real time
- **Goal:** Replace quarterly spreadsheet assessments with continuous automated evidence

### Phase 5 — Graph database digital twin
- Model relationships between controls, AWS infrastructure, application code, and threat models
- Validate overall conformance and posture
- Alert on deviations with full relationship context
- **Goal:** System understands context, not just individual findings

### Phase 6 — Predictive risk posture
- Feed ASDLC pipeline data into cyber risk quantification model
- Monitor KCRIs informed by real pipeline status
- Predict whether a release will improve or degrade security posture before it ships
- **Goal:** Forward-looking risk intelligence — see risk changes coming before they hit production

### Phase 7 — Autonomous agents and self-healing
- Automated threat modelling and CRQ analysis
- Self-healing agents auto-remediate findings via spec driven development
- Jira ticket → approved label → agent swarm picks up → builds → PRs → deploys
- **Goal:** Full vision operational — humans observe, agents operate

---

## Commercial Vision (Track 2)

**Target market:** AI-first companies (10–100 people) scaling fast with vibe-coded apps but without a dedicated DevSecOps function — especially those facing enterprise procurement requirements (SOC 2, data handling, security posture questions).

**The buyer:** Technical co-founder or first infrastructure hire who needs to give non-technical teammates a safe deployment interface while maintaining control over standards.

**The moat:** The pre-built policy template library. Tick boxes are simple UX — the battle-tested, opinionated implementations behind them are what's hard to replicate.

**Template bundles (future):**
- SOC 2 readiness bundle
- AI-specific bundle (model logging, data handling, input/output audit trails)
- "Startup going upmarket" bundle (most common enterprise procurement requirements)

**Comparable tools to understand:**
- Port.io — internal developer portal (built for developers, not non-technical deployers)
- Spacelift / Atlantis — infrastructure governance layer
- Qovery / Porter — "deploy without knowing Kubernetes" (no enterprise policy layer)

None have nailed the combination of: non-technical deployer UX + enterprise policy enforcement + risk posture intelligence.

---

## Repository Structure (intended)

```
/
├── CLAUDE.md                  # This file
├── specs/                     # All specs for features and releases
├── infrastructure/            # Terraform modules
│   ├── modules/
│   └── environments/
├── services/                  # Application services
│   ├── lambda/
│   └── portal/
├── policies/                  # OPA policies and control definitions
├── .github/
│   └── workflows/             # GitHub Actions (auto-generated where possible)
└── docs/                      # Architecture decisions and runbooks
```

**Industry references and direction of travel:**
- **LinkedIn SPP (Software Production Platform)** — LinkedIn's internal platform for standardised, governed software delivery at scale. Demonstrates enterprise appetite for opinionated deployment platforms.
- **StronDM Dark Factory** — The concept of fully automated, human-free infrastructure operation. The long-term north star for what autonomous agentic operations looks like in practice.

These validate that the abstraction layer this platform sits on is where the industry is heading, not just a speculative vision.

---

## Environment Context

**Personal AWS account** — The PoC and all personal development work is built on Nick's personal AWS account, not FrankieOne's infrastructure. This keeps experimentation clean and separate from production systems. When the platform matures, a parallel deployment into FrankieOne's AWS environment will be scoped separately.

**FrankieOne context:** KYC/KYB compliance platform handling sensitive financial identity data for enterprise customers. Security posture and compliance evidence are genuine competitive differentiators in this market. The internal strategy work (ASDLC, ROC, SOC vision) is being developed in parallel with the personal PoC build.

---

## Context: Who Is Building This

Nick — IT Service Lead at FrankieOne (RegTech, Melbourne). Background in AWS infrastructure, GitHub Actions, DevSecOps. Holds multiple AWS certifications. Transitioning toward IT architect role. Building this hands-on, learning spec driven development as he goes. Preference for hands-on learning over theory. PoC is being built on a personal AWS account independently of FrankieOne's production infrastructure.

---

## What Claude Code Should Know

- Always start with a spec before writing any code
- Prefer MCP tool calls over manual steps wherever possible
- Infrastructure goes in Terraform — no manual AWS console changes
- Security checks are not optional — they are part of every pipeline
- Plain language output always — no raw scan results surfaced to end users
- When in doubt about scope, refer back to the current phase above
- The digital twin graph database is the long-term connective tissue — design with it in mind even in early phases

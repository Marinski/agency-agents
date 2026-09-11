# Agency — Testing

The Agency Testing division, packaged as installable Agent Skills for VS Code Agent Plugins, Claude Code, Claude Desktop, and GitHub Copilot CLI. Each specialist is also available as a Claude Code sub-agent.

## Specialists (9)

- **Accessibility Auditor** (`testing-accessibility-auditor`) — Expert accessibility specialist who audits interfaces against WCAG standards, tests with assistive technologies, and ensures inclusive design. Defaults to finding barriers — if it's not tested with a screen reader, it's not accessible.
- **API Tester** (`testing-api-tester`) — Expert API testing specialist focused on comprehensive API validation, performance testing, and quality assurance across all systems and third-party integrations
- **Evidence Collector** (`testing-evidence-collector`) — Screenshot-obsessed, fantasy-allergic QA specialist - Default to finding 3-5 issues, requires visual proof for everything
- **Performance Benchmarker** (`testing-performance-benchmarker`) — Expert performance testing and optimization specialist focused on measuring, analyzing, and improving system performance across all applications and infrastructure
- **Reality Checker** (`testing-reality-checker`) — Stops fantasy approvals, evidence-based certification - Default to "NEEDS WORK", requires overwhelming proof for production readiness
- **Test Automation Engineer** (`testing-test-automation-engineer`) — Expert end-to-end test automation engineer for Playwright and Cypress — resilient selectors, flake elimination, isolated test data, CI parallelization, and trace-driven failure debugging.
- **Test Results Analyzer** (`testing-test-results-analyzer`) — Expert test analysis specialist focused on comprehensive test result evaluation, quality metrics analysis, and actionable insight generation from testing activities
- **Tool Evaluator** (`testing-tool-evaluator`) — Expert technology assessment specialist focused on evaluating, testing, and recommending tools, software, and platforms for business use and productivity optimization
- **Workflow Optimizer** (`testing-workflow-optimizer`) — Expert process improvement specialist focused on analyzing, optimizing, and automating workflows across all business functions for maximum productivity and efficiency

## Usage

Install the division, then invoke a specialist by describing the task or with its slash command:

```text
/agency-testing:testing-accessibility-auditor
```

In VS Code the specialists appear as skills in chat once the plugin is enabled; in Claude Code they are available both as skills and as sub-agents.

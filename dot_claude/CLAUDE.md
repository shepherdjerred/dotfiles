# Global Claude Instructions

## Tool & Skill Usage — MANDATORY

Before doing ANY work, scan the available skills list for relevant skills and LOAD THEM. This is not optional.

- **ALWAYS load matching skills first** - If the task involves a technology that has a skill (Dagger, Docker, Terraform, Kubernetes, Git, TypeScript, etc.), load that skill BEFORE taking any action. Do not attempt to solve the problem without the skill.
- **Use MCP tools first** - When MCP servers provide relevant functionality, prefer them over manual approaches
- **Leverage plugins** - Check available plugins before implementing something from scratch
- **Look deeper** - If CI is failing, a build tool is erroring, or infrastructure has issues, don't just report the surface error. Load the relevant skill and investigate the root cause. The user wants solutions, not descriptions of problems.

Examples of what NOT to do:
- Seeing Dagger CI failures and NOT loading the dagger-helper skill
- Seeing Kubernetes errors and NOT loading kubectl-helper
- Seeing TypeScript errors and NOT loading typescript-helper
- Reporting "your API key is expired" without investigating how to fix it

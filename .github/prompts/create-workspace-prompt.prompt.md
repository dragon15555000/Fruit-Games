---
description: "Create a reusable workspace prompt file (.prompt.md) for a common task."
name: "Create Workspace Prompt"
argument-hint: "Describe the task this prompt should perform"
agent: "agent"
---
Based on the task description you provide, draft the full contents of a reusable `.prompt.md` file for this repository.
- Keep the prompt narrowly focused on one well-defined task.
- Include YAML frontmatter with `description`, `name`, and `argument-hint`.
- Prefer workspace scope and `.github/prompts/` storage.
- Return only the complete prompt file content, ready to save.

Task:
Describe the task in one sentence or short paragraph.

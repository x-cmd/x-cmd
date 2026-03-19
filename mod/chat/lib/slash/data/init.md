---
description: Initialize the context file, create or update the context file in the project root.
---

<!-- BEGIN Repository Guidelines file Generation Prompt -->
Goal: Create or update a file named `%{FILENAME}%` in the project root.
The task must produce **a %{FILENAME}% file**, not printed the file content.

Strict requirement:
- Never fabricate, guess, or rely on assumptions. Use only information that is directly observable from the repository’s files, directories (including hidden files and directories starting with `.`), configurations, naming patterns, and `.git/` contents.
- If any detail cannot be confirmed with certainty, leave that section empty or omit it entirely.
- If an %{FILENAME}% file exists, incorporate only verifiable information from it.
- Only the %{FILENAME}% file should be produced.

When analyzing the project, inspect elements such as:
- Directory structure and file layout
- Source code organization
- Configuration files (e.g., package.json, pyproject.toml, tsconfig.json, Makefile, Dockerfile, CI configs, environment files, dotfiles)
- Tooling definitions and scripts
- `.git/` contents (HEAD, branches, logs, hooks, attributes, ignore rules, submodules), and any observable commit/branch patterns
- Observable commit history patterns (if readable)
- Naming conventions and formatting indicators from the codebase

Document requirements:
- Output pure Markdown only.
- Use clear headings and a professional, instructional tone.
- Aim for ~200–400 words, based solely on observable information.
- Provide short examples only when they match actual evidence.
- You may freely add, remove, or reorganize sections depending on what the repository truly contains.

Suggested areas to cover when applicable:
- Project Overview: purpose and main components.
- Repository Layout: key folders, source locations, test placement, and structural patterns.
- Tooling & Stack: languages, frameworks, build tools, package managers, and config systems.
- Development Tasks: common scripts or commands for building, testing, linting, formatting, or running the project.
- Style & Conventions: formatting rules, naming approaches, lint behavior, or other observable coding norms.
- Testing Approach: frameworks, directory structure, naming conventions, and how tests are executed.
- Version Control Practices: commit patterns, branch naming habits, and PR expectations derived from history.

Final note: The output must **create or update the %{FILENAME}% file** in the project root. Do not print or return Markdown text elsewhere.
Only one file named `%{FILENAME}%` should be produced.

<!-- END Repository Guidelines file Generation Prompt -->
---
%{ARGUMENTS}%

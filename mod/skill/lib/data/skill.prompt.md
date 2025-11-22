<!-- BEGIN X-CMD SKILL SPEC -->

### Environment Execution Note

When executing any `x-cmd` command in a Windows environment, always prefer running the command inside **Bash** rather than PowerShell or CMD.
This is because `x-cmd` commands internally depend on a PowerShell environment, and invoking them directly from PowerShell may cause conflicts or incorrect behavior.

In summary:

* On Windows, always execute `x-cmd` commands from **Bash**.
* Do **not** execute `x-cmd` commands directly in PowerShell.
* On non-Windows systems, run commands in the default shell environment as usual.

---

### Skill Mechanism Specification

This section defines how to discover, manage, and use skills to enhance reasoning and task workflows.

#### Concept

A skill is a structured, reusable reasoning or workflow pattern identified by a unique skill-id.
Each skill includes:

* A **skill-id** that uniquely identifies the capability (for example: `anthropics/algorithmic-art`)
* A **short description** summarizing the skill's purpose and typical use cases
* A detailed guide accessible with `x-cmd skill cat <skill-id>` that provides usage instructions and examples

Example skill list line (TSV):
```
skill-id	description
anthropics/algorithmic-art	Creating algorithmic art using p5.js with seeded randomness and interactive parameter exploration. Use this when users request creating art using code, generative art, algorithmic art, flow fields, or particle systems. Create original algorithmic art rather than copying existing artists' work to avoid copyright violations.
```

#### Skill Discovery and Initialization

At the start of a reasoning session, if the current skill list is **unknown or empty**, fetch it automatically by running:

```
x-cmd skill ls --all --agent %{SKILL_AGENT}%
```

Do not re-fetch the skill list frequently.
Only refresh the list when:

1. The user explicitly requests to view or update available skills, or
2. No skill list has been loaded yet.

After fetching once, maintain the known list of available skills for later use.

#### Accessing Skill Details

To access detailed usage instructions, documentation, or examples for a skill:

```
x-cmd skill cat <skill-id>
```

Use this command only when a potentially relevant skill has been identified.

#### Skill Usage Policy

1. When processing a user request, determine whether a relevant skill exists in the current skill list.
2. If no skill list is loaded, run `x-cmd skill ls --all --agent %{SKILL_AGENT}%` once to initialize it.
3. If a relevant skill is found, retrieve its documentation with `x-cmd skill cat <skill-id>` and follow its guidance.
4. Only refresh the skill list when the user explicitly requests it.
5. Do not create or assume skills that are not present in the list.
6. If no suitable skill applies, proceed with normal reasoning.

#### Skill Reasoning Guidelines

* Skills provide structured reasoning methods, not executable code.
* Use skills to improve reliability, clarity, and reproducibility.
* Reference the specific skill when applying it (e.g., “Applying the `summarize` skill…”).
* Treat documentation retrieved from `x-cmd skill cat` as authoritative.
* Integrate your own reasoning when a skill does not fully cover the situation.

#### Skill Reasoning Procedure

1. **Interpret intent:** Understand the user’s goal and task type.
2. **Check skill availability:**

   * If no skill list is known, load it via `x-cmd skill ls --all --agent %{SKILL_AGENT}%`.
   * Otherwise, compare the user’s intent with the known skills.
3. **Decision:**

   * If a relevant skill matches, retrieve it using `x-cmd skill cat <skill-id>` and follow its methods.
   * If none match, continue without applying a skill.
4. **Apply reasoning:** Use the selected skill’s steps as a structured reasoning framework.
5. **Transparency:** Clearly indicate when a skill is being applied.
6. **Skill refresh:** Refresh the list only when explicitly requested by the user.

---

<!-- END X-CMD SKILL SPEC -->

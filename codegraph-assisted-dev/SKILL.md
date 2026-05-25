---
name: codegraph-first
description: Use this skill when the task needs codebase understanding before planning or editing. It requires using CodeGraph/index first when available to inspect related files, symbols, imports, references, and call flows.
---

# CodeGraph First

Use CodeGraph/index before making a plan or editing code.

## Activation notice

When this skill is used, start the response with:

[ACTIVE SKILL: codegraph-first]

Then continue with the task.

## Required workflow

1. Check current repo state with `git status --short`.

2. Check whether CodeGraph is available with `codegraph --help`.

3. If CodeGraph is available and the project has not been indexed, run `codegraph init -i`.

4. Before answering, use CodeGraph/index or CodeGraph-supported commands to identify:

- related files
- related functions/classes
- imports
- references
- callers/callees
- entry points connected to the requested behavior

5. If CodeGraph has no usable query command in this environment, use the CodeGraph index result plus normal search commands such as `rg "<symbol_or_keyword>"`.

6. If CodeGraph fails or is unavailable, state briefly:

CodeGraph is unavailable, falling back to rg/file inspection.

Then continue using normal file inspection.

## Output requirement

When responding, briefly say whether CodeGraph was used:

CodeGraph: used

or:

CodeGraph: unavailable, fallback used

Do not claim CodeGraph was used unless it was actually used.
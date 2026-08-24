# Code Analysis

Code reading, analysis, and navigation scenarios must prioritize LSP tools (search_symbols, find_references, goto_definition, get_hover, etc.) over grep/fs_read line-by-line searching.

Rationale: LSP provides semantic-level analysis (types, reference chains, definition jumping), while grep only does text matching and easily misses or falsely matches.

Applicable scenarios:
- Finding symbol definitions/references → search_symbols + find_references
- Understanding types/signatures → get_hover
- File structure overview → get_document_symbols
- Architecture understanding → generate_codebase_overview
- Debugging → get_diagnostics as the primary tool, obtain compiler errors and warnings first, then use search_symbols + find_references to locate root cause

Cold start:
- When entering a code-intensive project (containing .py/.ts/.rs etc.), first run initialize_workspace to initialize LSP, ensuring subsequent tools are available

Exploration phase:
- Before diving into specific files, first use generate_codebase_overview to get the project overview

Structural search:
- Finding code patterns (e.g., all error handling, all API calls) → pattern_search, not grep
- pattern_search is AST-based, matching structure rather than text

Safe code transformations:
- Structural code replacement → pattern_rewrite (dry_run preview first), replacing sed
- Motivation: sed operating on JSON/code easily breaks structure (block-sed-json.sh hook will intercept)

Python pattern notes:
- `def $FUNC($$$):` doesn't work, must write `def $FUNC($$$ARGS): $$$BODY`
- Python ast-grep patterns must include a function body placeholder

Exceptions:
- Searching text in comments/strings → grep
- Reading non-code files (markdown, config) → fs_read

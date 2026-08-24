# Agent Rules — Staging Area

> Auto-distilled from episodes. Injected by context-enrichment per message.
> 🔴 = CRITICAL (always injected) | 🟡 = RELEVANT (keyword-matched)
> Sections auto-created by distill.sh. Max 5 rules per section.

## [memory,formation,hot-path,background]
🟡 1. Memory forms in two modes: hot-path (real-time during conversation, immediate effect but adds latency) suited for critical corrections; background (async post-conversation, no impact on response) suited for pattern discovery and rule distillation. Current auto-capture=hot-path, session-init=background, combination is reasonable but lacks automatic distillation in the background phase. Source: langchain-ai.github.io/langmem concepts
## [cc,macos,timeout,compatibility]
🔴 1. macOS does not have the `timeout` command (GNU coreutils). Writing `timeout 60s` in a plan will cause "command not found" on macOS. Alternatives: `gtimeout` (brew install coreutils) or `perl -e 'alarm(N); exec @ARGV'`. All cross-platform bash scripts must not assume timeout exists
## [research,socratic,depth,compaction]
🔴 1. When researching complex problems (long-running agent optimization), skipped Socratic self-check and directly output 6 optimization directions. Root cause: after research, entered "hammer looking for nails" mode—saw a paper saying X is a problem and assumed the framework also has problem X, without first verifying whether the existing solution already covers it (Ralph Loop iteration restart = strongest compaction, was misjudged as "missing"). Mechanism fix: every "suggestion/gap" produced by research must pass Socratic three layers before being written to findings: ①Does this problem actually exist in the current framework? (check existing solutions) ②Is it feasible on the target platform? (Kiro/CC constraints) ③Is benefit > maintenance cost? Trigger condition: "research conclusion output" itself is a key decision point, not just "design/solution selection" that triggers it
## [principle,reform,timid,optimization]
🟡 1. When analyzing optimization approaches, retreated to minor optimizations (3-9% improvement) due to "many side effects" and "large changes", avoiding architecture-level reform (multi-process parallelism + worktree isolation). User correction: top-level principle "Bold reform over timid patches" requires results-first thinking, not fear of complexity. Side effects are not reasons to retreat but engineering problems to solve. DO: first define the optimal outcome target, then solve implementation side effects. DON'T: lower the target and pick a mediocre solution because of side effects
## [refactor,capability]
🟡 1. Over-focused on new features during refactoring, nearly lost core capabilities of the old framework

## [fs_write,kiro,tool,revert,modify]
🔴 1. Kiro's fs_write tool reverts modified files to their original state between two tool calls. All source code modifications must be completed in a single execute_bash call (Python script for batch modifications), and git committed in the same call to persist. Do not use fs_write to modify source code and expect the next tool call to see the changes

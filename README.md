# prompts

A system prompt and preference package for Claude that replaces default AI behavior with direct, opinionated, example-driven responses.

## Why This Exists

Claude's defaults are cautious — hedging, over-apologizing, asking permission to be useful, and burying answers under sycophantic filler. These prompts fix that. 
It was built by a CS professor and CTO with 22+ years of coding experience who needed Claude to behave like a sharp colleague: lead with the answer, commit to opinions with reasoning, correct mistakes without groveling, and ship working code instead of suggesting approaches.

## Write Like Me

The customizations fall into two categories. 
**Voice rules** eliminate minimizing language ("this is pretty straightforward"), sycophantic openers ("Great question!"), and correction theatrics ("I sincerely apologize for that error!") — replacing them with direct, practical responses grounded in real conversation examples.
**Operational rules** enforce a specific code delivery workflow (Plan → Code → Tests → README → Run/Deploy), language defaults (Go for CLIs, Python/Django for APIs, Bash for glue), unified diffs for revisions, structured error handling, clean GFM markdown, and footnote-style citations with a confidence scale. 
Every rule is demonstrated with bad/good example pairs drawn from actual usage rather than described in prose.

## Usage

1. Paste `slim.txt` into **Settings → Profile → User Preferences**
2. Create a Claude Project (e.g., "Dev"), paste `project.txt` into **Project Instructions**

The project version is the full ruleset with all examples. Custom instructions are a compressed fallback for chats outside the project. Both layer on top of user preferences, which handle tone only. 
For reference:
    - User Preferences  →  always active (tone/personality)
    - Custom Instructions  →  non-project chats (slim rules)
    - Project Instructions  →  inside project (full examples + rules, takes precedence)

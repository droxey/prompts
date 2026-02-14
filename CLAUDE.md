# CLAUDE.md

## What This Repository Is

A system prompt and preference package for Claude (codename **PRISM**). It replaces Claude's default cautious, hedging behavior with direct, opinionated, example-driven responses trained on the creator's writing style. Built by a CS professor and CTO with 22+ years of coding experience.

There is no application code here — only curated text files that define Claude's behavior when pasted into its settings UI, plus infrastructure to publish them via GitHub Pages.

## Repository Structure

```
prompts/
├── CLAUDE.md                          # This file — AI assistant guide
├── README.md                          # User-facing documentation (purpose, usage, layering model)
├── project.txt                        # Full ruleset (642 lines) — Claude Project Instructions
├── slim.txt                           # Compressed ruleset (18 lines) — User Preferences / Custom Instructions
└── .github/
    └── workflows/
        └── static.yml                 # GitHub Actions: deploy to GitHub Pages on push to main
```

### File Roles

| File | Destination | Purpose |
|------|------------|---------|
| `project.txt` | Project Instructions (inside a Claude Project) | Authoritative version. Contains every rule demonstrated with bad/good example pairs. |
| `slim.txt` | Settings → Profile → User Preferences | Compressed fallback for non-project chats. Same rules, dense abbreviated form. Tone only. |
| `README.md` | GitHub / GitHub Pages | Explains the project to humans: what it is, why it exists, how to use it. |
| `.github/workflows/static.yml` | GitHub Actions | Deploys the entire repo to GitHub Pages on push to `main`. |

### Layering Model (how the files interact)

1. **User Preferences** (`slim.txt`) — always active, handles tone/personality
2. **Custom Instructions** (`slim.txt` alternate) — non-project chats
3. **Project Instructions** (`project.txt`) — inside a Claude Project, takes precedence with full examples and rules

## Content Architecture of project.txt

The file uses XML-like tags to organize rules into sections. Each section contains bad/good example pairs drawn from real usage.

| Section | Lines | Content |
|---------|-------|---------|
| `<core>` | 1–19 | Priority order (accuracy > goals > efficiency > style), uncertainty handling, correction behavior |
| `<examples label="voice-and-tone">` | 21–56 | Minimizing language, sycophantic filler, correction handling |
| `<examples label="engagement-and-teaching">` | 58–107 | Beginner explanations, expert comparisons, strong pushback, teaching patterns, next steps |
| `<examples label="creative-mode">` | 109–124 | Committing to creative choices vs. hedging |
| `<edu_mode>` | 126–132 | Progression model: intuition → example → deeper mechanics |
| `<code_mode>` | 134–410 | Delivery workflow, language selection, error handling, testing, logging, README structure, packaging, revisions, claim ledger |
| `<examples label="revisions">` | 412–468 | Unified diffs only — never reprint full files |
| `<examples label="markdown-export">` | 470–525 | Clean export rules, nested fences |
| `<examples label="markdown-style">` | 527–565 | GFM conventions, heading rules |
| `<examples label="diagrams">` | 568–605 | Mermaid diagram rules and correct patterns |
| `<formatting>` | 607–615 | Title Case headers, list conventions, paragraph length |
| `<reasoning>` | 617–630 | Confidence scale (High/Med/Low), footnote citations, source quality |
| `<continuity>` | 632–640 | Latest instructions win, track context, don't re-explain |

## Key Conventions

### Voice and Tone

- Lead with the answer — no sycophantic openers ("Great question!") or filler
- Never minimize complexity ("this is straightforward", "just do X")
- On corrections: acknowledge once, fix, move on — no excessive apologies
- In creative mode: commit fully, don't hedge with "here are three approaches"

### Code Delivery Workflow

Every code response follows this order:

1. **Plan** — what we're building, what we're NOT building, key decisions
2. **Code** — minimal, idiomatic, structured for testability
3. **Tests** — happy path + edge case + failure case (written last, verified before delivery)
4. **README** — overview, install, usage, examples, limitations, security, run/deploy
5. **Run/Deploy** — exact commands, expected output, smoke test command

### Language Defaults

| Task Type | Language | Reasoning |
|-----------|----------|-----------|
| CLI tools | Go | Static binary, no runtime deps |
| APIs/web | Python (Django + DRF) | ORM, admin panel, ecosystem |
| Shell glue | Bash | No dependencies for simple tasks |
| Last resort | Node.js | Only when ecosystem demands it |

### Error Handling Pattern

- Fail fast on programmer/config errors
- Graceful retry on recoverable ops errors
- Catch at the highest reasonable level (main/handlers)
- Always add context to errors
- Never swallow exceptions silently

### Config Precedence

CLI flags > config file > `.env` > environment variables

### Formatting Rules

- GFM (GitHub Flavored Markdown), one H1, ATX headings
- Blank lines around headings and code fences
- Fenced code blocks with language identifiers
- Title Case for headers
- Mermaid diagrams: declare direction, quote special-char labels, avoid reserved words

## Development Workflow

### Branching

- Trunk-based development on `main`
- Feature branches prefixed with `claude/` for AI-assisted changes
- No tag-based releases currently

### CI/CD

A single GitHub Actions workflow (`.github/workflows/static.yml`) deploys the entire repository to GitHub Pages on every push to `main`. No build step, linting, or testing — these are plain text files.

- Triggers: push to `main`, manual dispatch via Actions tab
- Concurrency: one deployment at a time, in-progress runs are not cancelled

### Making Changes

1. Edit `project.txt` and/or `slim.txt` as needed
2. Keep `slim.txt` in sync as a compressed version of `project.txt`
3. Update `README.md` if the usage model or layering changes
4. Push to `main` to trigger GitHub Pages deployment

### Important Constraints

- **Do not modify the `.txt` files** unless explicitly asked — they are the core product
- `slim.txt` must remain a compressed mirror of `project.txt` rules
- Every rule in `project.txt` should be demonstrated with a bad/good example pair where applicable
- The XML-like tag structure (`<core>`, `<examples>`, `<code_mode>`, etc.) is intentional and must be preserved

## Quick Reference for AI Assistants

- This is a **documentation-only** repository — no application code, no dependencies, no build process
- The `.txt` files are the product; treat them as carefully as source code
- When suggesting changes, use unified diffs — consistent with the project's own rules
- Match the writing style: direct, opinionated, example-driven, no hedging
- The creator's priorities: accuracy > user goals > efficiency > style

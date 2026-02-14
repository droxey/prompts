#!/usr/bin/env bash
# validate.sh — structural and content checks for the prompts repository
# Run: ./validate.sh
# Exit code: 0 = all pass, 1 = failures found
set -euo pipefail

RED="\033[91m"
GREEN="\033[92m"
YELLOW="\033[93m"
RESET="\033[0m"

FAILURES=0

pass() { echo -e "${GREEN}PASS${RESET}  $1"; }
fail() { echo -e "${RED}FAIL${RESET}  $1"; FAILURES=$((FAILURES + 1)); }
warn() { echo -e "${YELLOW}WARN${RESET}  $1"; }

# ---------------------------------------------------------------------------
# 1. File existence and minimum size (catch truncation / accidental deletion)
# ---------------------------------------------------------------------------
echo "=== File Integrity ==="

for f in project.txt slim.txt README.md CLAUDE.md .github/workflows/static.yml; do
  if [ ! -f "$f" ]; then
    fail "$f is missing"
  else
    lines=$(wc -l < "$f")
    if [ "$lines" -lt 5 ]; then
      fail "$f has only $lines lines (possible truncation)"
    else
      pass "$f exists ($lines lines)"
    fi
  fi
done

# ---------------------------------------------------------------------------
# 2. Line count ranges (detect major unintended additions or deletions)
# ---------------------------------------------------------------------------
echo ""
echo "=== Line Count Ranges ==="

project_lines=$(wc -l < project.txt)
slim_lines=$(wc -l < slim.txt)

if [ "$project_lines" -ge 500 ] && [ "$project_lines" -le 800 ]; then
  pass "project.txt line count in range ($project_lines, expected 500-800)"
else
  fail "project.txt line count out of range ($project_lines, expected 500-800)"
fi

if [ "$slim_lines" -ge 10 ] && [ "$slim_lines" -le 40 ]; then
  pass "slim.txt line count in range ($slim_lines, expected 10-40)"
else
  fail "slim.txt line count out of range ($slim_lines, expected 10-40)"
fi

# ---------------------------------------------------------------------------
# 3. XML tag balance in project.txt
# ---------------------------------------------------------------------------
echo ""
echo "=== Tag Balance (project.txt) ==="

# Extract unique tag names (excluding self-closing and code-embedded tags)
check_tag_balance() {
  local tag="$1"
  local file="$2"
  local open close
  open=$(grep -c "<${tag}[ >]" "$file" 2>/dev/null || echo 0)
  close=$(grep -c "</${tag}>" "$file" 2>/dev/null || echo 0)
  if [ "$open" -eq "$close" ]; then
    pass "<$tag> balanced ($open open, $close close)"
  else
    fail "<$tag> UNBALANCED ($open open, $close close)"
  fi
}

for tag in prism core examples example edu_mode code_mode formatting reasoning continuity; do
  check_tag_balance "$tag" "project.txt"
done

# ---------------------------------------------------------------------------
# 4. Example attributes — every <example> should have type and label
# ---------------------------------------------------------------------------
echo ""
echo "=== Example Attributes ==="

missing_type=$(grep -n '<example ' project.txt | grep -v 'type=' | head -5 || true)
if [ -z "$missing_type" ]; then
  pass "All <example> tags have type attribute"
else
  fail "Examples missing type attribute: $missing_type"
fi

missing_label=$(grep -n '<example ' project.txt | grep -v 'label=' | head -5 || true)
if [ -z "$missing_label" ]; then
  pass "All <example> tags have label attribute"
else
  fail "Examples missing label attribute: $missing_label"
fi

# ---------------------------------------------------------------------------
# 5. Example pair completeness
# ---------------------------------------------------------------------------
echo ""
echo "=== Example Pair Coverage ==="

bad_count=$(grep -c 'type="bad"' project.txt || echo 0)
good_count=$(grep -c 'type="good"' project.txt || echo 0)
echo "  Bad examples: $bad_count"
echo "  Good examples: $good_count"

if [ "$bad_count" -gt 0 ] && [ "$good_count" -gt 0 ]; then
  pass "Both bad and good examples present"
else
  fail "Missing bad or good examples"
fi

# Check each <examples> section has at least one good example
sections=$(grep '<examples label=' project.txt | grep -o 'label="[^"]*"' | sort -u | sed 's/label="//;s/"//')
for section in $sections; do
  section_good=$(sed -n "/<examples label=\"${section}\">/,/<\/examples>/p" project.txt | grep -c 'type="good"' || echo 0)
  if [ "$section_good" -eq 0 ]; then
    fail "Section '$section' has no good examples"
  else
    pass "Section '$section' has $section_good good example(s)"
  fi
done

# ---------------------------------------------------------------------------
# 6. Markdown quality checks (self-consistency with project rules)
# ---------------------------------------------------------------------------
echo ""
echo "=== Markdown Quality ==="

for md in README.md CLAUDE.md; do
  [ ! -f "$md" ] && continue
  h1_count=$(grep -c '^# ' "$md" || echo 0)
  if [ "$h1_count" -eq 1 ]; then
    pass "$md has exactly one H1"
  else
    fail "$md has $h1_count H1 headings (expected 1)"
  fi
done

# Check code blocks have language identifiers
for md in README.md CLAUDE.md; do
  [ ! -f "$md" ] && continue
  bare_fences=$(grep -n '^```$' "$md" | head -5 || true)
  if [ -z "$bare_fences" ]; then
    pass "$md: all code fences have language identifiers"
  else
    warn "$md: bare code fences (no language) at lines: $(echo "$bare_fences" | cut -d: -f1 | tr '\n' ' ')"
  fi
done

# ---------------------------------------------------------------------------
# 7. slim.txt keyword coverage (check key topics from project.txt appear)
# ---------------------------------------------------------------------------
echo ""
echo "=== slim.txt Sync Check ==="

check_keyword() {
  local keyword="$1"
  local description="$2"
  if grep -Eqi "$keyword" slim.txt; then
    pass "slim.txt covers: $description"
  else
    warn "slim.txt may be missing: $description (keyword '$keyword' not found)"
  fi
}

check_keyword "accuracy" "priority order"
check_keyword "Go" "language defaults"
check_keyword "Django" "API framework"
check_keyword "diff" "revision format"
check_keyword "Title Case" "formatting rules"
check_keyword "confidence" "reasoning scale"
check_keyword "continuity" "context tracking"
check_keyword "creative" "creative mode"
check_keyword "edu" "education mode"
check_keyword "docker" "deployment"
check_keyword "diagram|mermaid" "diagram rules"

# ---------------------------------------------------------------------------
# 8. GitHub Actions workflow validation (basic YAML structure)
# ---------------------------------------------------------------------------
echo ""
echo "=== Workflow Validation ==="

workflow=".github/workflows/static.yml"
if [ -f "$workflow" ]; then
  if grep -q '^name:' "$workflow" && grep -q '^on:' "$workflow" && grep -q '^jobs:' "$workflow"; then
    pass "Workflow has required top-level keys (name, on, jobs)"
  else
    fail "Workflow missing required top-level keys"
  fi

  if grep -q 'actions/checkout@' "$workflow"; then
    pass "Workflow uses pinned checkout action"
  else
    warn "Workflow checkout action may not be pinned"
  fi
fi

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------
echo ""
echo "==============================="
if [ "$FAILURES" -eq 0 ]; then
  echo -e "${GREEN}All checks passed.${RESET}"
  exit 0
else
  echo -e "${RED}$FAILURES check(s) failed.${RESET}"
  exit 1
fi

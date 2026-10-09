#!/usr/bin/env bash
# Fails if git tracks or is about to commit individual-level data. Run before every commit.
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"
bad=$(git ls-files --cached --others --exclude-standard \
  | grep -E '\.(dta|sav|xlsx|xls|parquet|csv)$' \
  | grep -v -E '^(config/|output/tables/)' | grep -v -x 'tests/synthetic_kobo.csv' || true)
# The synthetic file is allowed only if every record ID starts with SYN
if [[ -f tests/synthetic_kobo.csv ]]; then
  if awk -F, 'NR > 1 && $1 !~ /^SYN/ {found = 1} END {exit !found}' tests/synthetic_kobo.csv; then
    echo "ERROR: tests/synthetic_kobo.csv has record IDs that do not start with SYN and may contain real data." >&2
    exit 1
  fi
fi
bad_data=$(git ls-files --cached | grep -E '^data/' | grep -v -E '(README\.md|\.gitkeep)$' || true)
if [[ -n "$bad$bad_data" ]]; then
  echo "ERROR: data files are about to be committed:" >&2
  printf '%s\n' $bad $bad_data >&2
  exit 1
fi
echo "OK: no individual-level data files in the commit."

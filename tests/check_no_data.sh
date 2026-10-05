#!/usr/bin/env bash
# Báo lỗi nếu git đang theo dõi tệp dữ liệu cấp cá nhân. Chạy trước khi commit.
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"
bad=$(git ls-files --cached --others --exclude-standard \
  | grep -E '\.(dta|sav|xlsx|xls|parquet|csv)$' \
  | grep -v -E '^(config/|output/tables/)' | grep -v -x 'tests/synthetic_kobo.csv' || true)
# Tệp giả lập chỉ được phép nếu mọi mã phiếu bắt đầu bằng SYN
if [[ -f tests/synthetic_kobo.csv ]]; then
  if awk -F, 'NR > 1 && $1 !~ /^SYN/ {found = 1} END {exit !found}' tests/synthetic_kobo.csv; then
    echo "LỖI: tests/synthetic_kobo.csv có mã phiếu không phải SYN..., có thể chứa dữ liệu thật." >&2
    exit 1
  fi
fi
bad_data=$(git ls-files --cached | grep -E '^data/' | grep -v -E '(README\.md|\.gitkeep)$' || true)
if [[ -n "$bad$bad_data" ]]; then
  echo "LỖI: có tệp dữ liệu sắp bị commit:" >&2
  printf '%s\n' $bad $bad_data >&2
  exit 1
fi
echo "OK: không có tệp dữ liệu cấp cá nhân trong danh sách commit."

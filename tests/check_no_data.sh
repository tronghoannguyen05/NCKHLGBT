#!/usr/bin/env bash
# Báo lỗi nếu git đang theo dõi tệp dữ liệu cấp cá nhân. Chạy trước khi commit.
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"
bad=$(git ls-files --cached --others --exclude-standard \
  | grep -E '\.(dta|sav|xlsx|xls|parquet|csv)$' \
  | grep -v -E '^(config/|output/tables/)' || true)
bad_data=$(git ls-files --cached | grep -E '^data/' | grep -v -E '(README\.md|\.gitkeep)$' || true)
if [[ -n "$bad$bad_data" ]]; then
  echo "LỖI: có tệp dữ liệu sắp bị commit:" >&2
  printf '%s\n' $bad $bad_data >&2
  exit 1
fi
echo "OK: không có tệp dữ liệu cấp cá nhân trong danh sách commit."

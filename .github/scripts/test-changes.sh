#!/usr/bin/env bash
set -euo pipefail

case "$EVENT_NAME" in
  pull_request)
    comparison="${BASE_SHA}...${HEAD_SHA}"
    ;;
  push)
    if [[ "$BASE_SHA" == 0000000000000000000000000000000000000000 ]] ||
       ! git cat-file -e "${BASE_SHA}^{commit}" 2>/dev/null; then
      echo '::notice::No previous push revision available; running the full test matrix.'
      echo 'run_tests=true' >> "$GITHUB_OUTPUT"
      exit 0
    fi
    comparison="${BASE_SHA}..${HEAD_SHA}"
    ;;
  *)
    echo "::error::Unsupported event: $EVENT_NAME"
    exit 1
    ;;
esac

changed_files="$(mktemp)"
trap 'rm -f "$changed_files"' EXIT
git diff --name-only --no-renames -z "$comparison" > "$changed_files"

run_tests=false
while IFS= read -r -d '' path; do
  case "$path" in
    *.md|LICENSE|LICENSE.txt|images/*) ;;
    *) run_tests=true ;;
  esac
done < "$changed_files"

echo "run_tests=$run_tests" >> "$GITHUB_OUTPUT"

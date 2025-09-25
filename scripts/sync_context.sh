#!/usr/bin/env bash
set -euo pipefail

SRC="context.md"

copy_if_diff () {
  local dst="$1"
  if [[ ! -f "$SRC" ]]; then
    echo "ERROR: Source $SRC does not exist." >&2
    exit 1
  fi
  if ! cmp -s "$SRC" "$dst" 2>/dev/null; then
    cp "$SRC" "$dst"
    echo "Updated $dst"
  else
    echo "No change in $dst"
  fi
}

ensure_context () {
  if [[ -f "$SRC" ]]; then
    echo "Found $SRC (canonical)."
    return
  fi

  if [[ -f "claude.md" ]]; then
    cp "claude.md" "$SRC"
    echo "Bootstrapped $SRC from claude.md"
    return
  fi

  if [[ -f ".cursorrules" ]]; then
    cp ".cursorrules" "$SRC"
    echo "Bootstrapped $SRC from .cursorrules"
    return
  fi

  # Neither file exists — create an empty canonical context.md
  touch "$SRC"
  echo "Created new empty $SRC (canonical)."
}

ensure_ignore_files () {
  local ignore_patterns=(
    "*.env"
    ".DS_Store"
    "node_modules/"
    "venv/"
  )

  for file in .gitignore .cursorignore; do
    touch "$file"
    for pat in "${ignore_patterns[@]}"; do
      if ! grep -Fxq "$pat" "$file"; then
        echo "$pat" >> "$file"
      fi
    done
    echo "Ensured patterns in $file"
  done
}

main () {
  ensure_context
  copy_if_diff "claude.md"
  copy_if_diff ".cursorrules"
  ensure_ignore_files
}

main "$@"

#!/usr/bin/env bash
# Compiles a .tex file to PDF, building in an isolated temp directory so no
# build artifacts (.aux, .log, etc.) land next to the source -- only the
# resulting PDF is copied back. Uses a local latexmk install if present,
# otherwise falls back to a Docker TeX Live image (override with
# LATEX_DOCKER_IMAGE).
set -euo pipefail

DOCKER_IMAGE="${LATEX_DOCKER_IMAGE:-ghcr.io/xu-cheng/texlive-full}"

TEXFILE="${1:-}"
if [ -z "$TEXFILE" ]; then
  PROJECT_ROOT="$(pwd)"
  tex_candidates=()
  while IFS= read -r f; do tex_candidates+=("$f"); done \
    < <(find "$PROJECT_ROOT" -maxdepth 1 -type f -name '*.tex')
  if [ "${#tex_candidates[@]}" -ne 1 ]; then
    echo "Usage: compile.sh <file.tex> -- found ${#tex_candidates[@]} .tex files in $PROJECT_ROOT, specify one." >&2
    exit 1
  fi
  TEXFILE="$(basename "${tex_candidates[0]}")"
else
  # Accept a bare filename, a relative/absolute POSIX path, or a Windows-style
  # path (C:\...\file.tex) -- normalize to POSIX and derive PROJECT_ROOT from
  # the file's own directory instead of assuming the caller already cd'd there.
  NORMALIZED="${TEXFILE//\\//}"
  if [[ "$NORMALIZED" =~ ^([A-Za-z]):(/.*)$ ]]; then
    NORMALIZED="/${BASH_REMATCH[1],,}${BASH_REMATCH[2]}"
  fi
  NORMALIZED="$(realpath "$NORMALIZED")"
  PROJECT_ROOT="$(dirname "$NORMALIZED")"
  TEXFILE="$(basename "$NORMALIZED")"
fi
BASENAME="${TEXFILE%.tex}"

BUILD_DIR="$(mktemp -d)"
trap 'rm -rf "$BUILD_DIR"' EXIT
BUILD_DIR_WIN="$(cd "$BUILD_DIR" && pwd -W 2>/dev/null || pwd)"

# ponytail: full recompile in a fresh temp dir every run, no incremental
# cache. Trades latexmk's normal incremental speed for isolation/cleanliness
# of PROJECT_ROOT. Revisit only if compile time becomes a real problem.
find "$PROJECT_ROOT" -maxdepth 1 -type f \
  ! -name '*.aux' ! -name '*.bbl' ! -name '*.blg' ! -name '*.fdb_latexmk' \
  ! -name '*.fls' ! -name '*.log' ! -name '*.out' ! -name '*.pdf' \
  ! -name '*.synctex.gz' \
  -exec cp {} "$BUILD_DIR/" \;

BUILD_OK=0
if command -v latexmk >/dev/null 2>&1; then
  ( cd "$BUILD_DIR" && latexmk -pdf -interaction=nonstopmode -file-line-error "$TEXFILE" ) || BUILD_OK=1
else
  MSYS_NO_PATHCONV=1 docker run --rm -v "$BUILD_DIR_WIN:/work" -w /work \
    "$DOCKER_IMAGE" latexmk -pdf -interaction=nonstopmode -file-line-error "$TEXFILE" || BUILD_OK=1
fi

if [ "$BUILD_OK" -eq 0 ]; then
  cp "$BUILD_DIR/$BASENAME.pdf" "$PROJECT_ROOT/"
  echo "Built $PROJECT_ROOT/$BASENAME.pdf"
else
  echo "--- latexmk failed, tail of $BASENAME.log ---" >&2
  tail -n 40 "$BUILD_DIR/$BASENAME.log" >&2 2>/dev/null || true
  exit 1
fi

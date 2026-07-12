# compile-tex

Compiles a `.tex` file to PDF, building in an isolated temp directory so no build artifacts (`.aux`, `.log`, etc.) land next to your source — only the finished PDF is copied back.

Uses `latexmk` directly if it's already on `PATH`. Otherwise falls back to the `ghcr.io/xu-cheng/texlive-full` Docker image (override with the `LATEX_DOCKER_IMAGE` env var).

## Prerequisites

One of:
- `latexmk` installed and on `PATH`, or
- Docker running (pulls `ghcr.io/xu-cheng/texlive-full` on first use)

## Install

```bash
npx skills add https://github.com/hmasum52/skills --skill compile-tex
```

This installs the skill to `.claude/skills/compile-tex/` in your project.

## Usage

```bash
bash .claude/skills/compile-tex/scripts/compile.sh [file.tex]
```

If no filename is given and exactly one `.tex` file exists in your project root, it's used automatically.

### Try it

This folder ships [example.tex](example.tex) as a working demo:

```bash
cd compile-tex
bash scripts/compile.sh example.tex
```

produces `example.pdf` alongside it, with no leftover build artifacts.

# compile-tex

A [Claude Code](https://claude.com/claude-code) skill that compiles a `.tex` file to PDF, building in an isolated temp directory so no build artifacts (`.aux`, `.log`, etc.) land next to your source — only the finished PDF is copied back.

Uses `latexmk` directly if it's already on `PATH`. Otherwise falls back to the `ghcr.io/xu-cheng/texlive-full` Docker image (override with the `LATEX_DOCKER_IMAGE` env var).

## Prerequisites

One of:
- `latexmk` installed and on `PATH`, or
- Docker running (the skill pulls `ghcr.io/xu-cheng/texlive-full` on first use)

## Install

```bash
npx skills add <owner>/<repo>@compile-tex
```

This installs the skill to `.claude/skills/compile-tex/` in your project.

## Usage

```bash
bash .claude/skills/compile-tex/scripts/compile.sh [file.tex]
```

If no filename is given and exactly one `.tex` file exists in your project root, it's used automatically.

### Try it

This repo ships [example.tex](example.tex) as a working demo. After installing the skill into this repo (or by pointing the script at this repo's own `.claude/skills/compile-tex/`), run:

```bash
bash .claude/skills/compile-tex/scripts/compile.sh example.tex
```

which produces `example.pdf` in the project root with no leftover build artifacts.

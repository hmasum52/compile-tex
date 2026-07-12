---
name: compile-tex
description: Compile a LaTeX (.tex) project to PDF, building in an isolated temp directory so no build artifacts land in the project directory. Uses a local latexmk install if present, otherwise falls back to a Docker TeX Live image. Use when asked to compile, build, or typeset a LaTeX paper.
---

Compiles a `.tex` file to PDF, isolating the build in a temp directory so the project directory stays free of `.aux`/`.log`/etc. artifacts -- only the finished PDF is copied back.

Uses `latexmk` directly if it's already on `PATH`. Otherwise falls back to the `ghcr.io/xu-cheng/texlive-full` Docker image (requires Docker running) -- override with the `LATEX_DOCKER_IMAGE` env var.

```bash
bash .claude/skills/compile-tex/scripts/compile.sh [file.tex]
```

If no filename is given and exactly one `.tex` file exists in the project root, it's used automatically.

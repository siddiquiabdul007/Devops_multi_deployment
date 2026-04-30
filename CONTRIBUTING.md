# Contributing Guidelines

Welcome to the project! We appreciate your interest in contributing.

## Branching Strategy
We follow a GitFlow-like strategy but streamlined for GitOps:
- `main`: The stable branch representing production readiness. Direct pushes are disabled.
- `feature/*`: For new features. Create PRs against `main`.
- `fix/*`: For bug fixes. Create PRs against `main`.

## Pull Request Conventions
1. Ensure your code passes all local linting by using `pre-commit`.
2. Write meaningful commit messages.
3. Open a Pull Request and complete the provided PR template.
4. CI checks (Trivy scans, builds, terraform plans) must pass before a merge is allowed.

## Local Development
Run `pre-commit install` after cloning to set up the git hooks.

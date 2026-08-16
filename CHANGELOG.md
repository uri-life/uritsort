# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.0] - 2026-08-16

### Added

- A file-oriented `uritsort` command-line tool that reads dependency graphs and writes each dependency before its dependents.
- A generic `TopologicalSort` library with APIs for topological sorting and strongly connected component discovery.
- Deterministic, dependency-first graph ordering with stable results for equivalent inputs.
- Deterministic cycle detection with consistently ordered nodes and clear command-line diagnostics.
- Semantic version and source commit metadata through `uritsort --version`.

[Unreleased]: https://github.com/uri-life/uritsort/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/uri-life/uritsort/releases/tag/v0.1.0

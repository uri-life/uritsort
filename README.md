# uritsort

`uritsort` topologically sorts nodes by their dependencies. It reads a dependency graph from a text file and writes one node per line, with every dependency before its dependents.

## Requirements

- macOS 13 or later
- Swift 6.2

## Build

Build the release executable with Swift Package Manager:

```console
$ swift build -c release
```

The executable is written to `.build/release/uritsort`.

## Usage

```console
$ .build/release/uritsort <file>
```

`<file>` is the path to a UTF-8 text file containing the nodes and their dependencies.

### Input format

Each nonempty line starts with a node, followed by zero or more nodes it depends on. Separate every token with spaces:

```text
node dependency ...
```

Empty lines and lines containing only spaces are ignored. A dependency does not need its own line; `uritsort` includes referenced dependencies as nodes with no dependencies of their own.

### Example

Given `dependencies.txt`:

```text
application library
library runtime
```

Run:

```console
$ .build/release/uritsort dependencies.txt
runtime
library
application
```

The command writes one node per line. The relative order of nodes that are unrelated by dependencies is unspecified.

If the graph contains a dependency cycle, `uritsort` writes an error to standard error and exits with a failure status.

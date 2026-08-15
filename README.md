# uritsort

`uritsort` writes a dependency graph in deterministic topological order, with every dependency before its dependents. Its goal is repeatable output for equivalent graphs, not the fastest possible sorting algorithm.

## Quick start

Requires macOS 13 or later and Swift 6.2.

Build the release executable:

```console
$ swift build -c release
```

Create `dependencies.txt`:

```text
application library
library runtime
```

Run `uritsort`:

```console
$ .build/release/uritsort dependencies.txt
runtime
library
application
```

## Ordering

Each nonempty input line starts with a node, followed by zero or more nodes it depends on, separated by spaces. A dependency is included even if it does not have its own line.

Every dependency is written before its dependents. Whenever multiple nodes are available because all of their dependencies have already been written, `uritsort` writes the lexicographically smallest one next using Swift's locale-independent `String` ordering. Equivalent graphs therefore produce identical output even when their input lines or dependency tokens are reordered.

If the graph contains a dependency cycle, `uritsort` writes an error to standard error and exits with a failure status.

## Complexity

Sorting takes **O(E + V log V)** time, where **V** is the total number of nodes, including nodes that appear only as dependencies, and **E** is the number of dependency references.

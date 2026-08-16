import ArgumentParser

private import Foundation
private import TopologicalSort

@main
struct TopologicalSortCommand: ParsableCommand {

    @Argument(
        help: "The path to the file containing nodes and their dependencies.",
    )
    var file: String

    func _graph() throws -> [String: [String]] {
        let data = try Data(contentsOf: .init(filePath: file, directoryHint: .notDirectory))
        let lines = String(data: data, encoding: .utf8)?.split(separator: "\n") ?? []
        let graph = lines.reduce(into: [String: [String]]()) { graph, line in
            let nodes = line.split(separator: " ", omittingEmptySubsequences: true).map({String($0)})
            guard let node = nodes.first
            else {
                return
            }
            graph[node] = .init(nodes.dropFirst())
        }
        return graph
    }

    // MARK: - ParsableCommand

    static var configuration: CommandConfiguration {
        .init(
            commandName: "uritsort",
            abstract: "Topologically sort nodes by their dependencies.",
            discussion:
                """
                Each nonempty line in the input file must begin with a node, followed by zero or more nodes it depends on, separated by spaces. The command writes one node per line, with every dependency before its dependents.
                """,
            version: Versions.semver,
        )
    }

    func run() throws(ExitCode) {
        let graph: [String: [String]]
        do {
            graph = try _graph()
        }
        catch {
            try? FileHandle.standardError.write(
                contentsOf: "error: failed to read file at path '\(file)': \(error)\n".data(using: .utf8)!,
            )
            throw .failure
        }
        do {
            let sorted = try graph.topologicalSort()
            for node in sorted {
                print(node)
            }
        }
        catch {
            switch error {
            case .cycle(let nodes):
                try? FileHandle.standardError.write(
                    contentsOf: "error: cycle detected among nodes: \(nodes)\n".data(using: .utf8)!,
                )
            }
            throw .failure
        }
    }
}

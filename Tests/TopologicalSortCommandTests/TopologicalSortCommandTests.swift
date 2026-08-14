import Testing

private import Foundation

@testable
import TopologicalSortCommand

@Test
func parsesNodesAndDependencies() throws {
    let graph = try withTemporaryInput(
        contents:
            """
            application network storage
            network   core

            standalone
            storage core
            """,
    ) { file in
        var command = TopologicalSortCommand()
        command.file = file.path
        return try command._graph()
    }

    #expect(
        graph
            == [
                "application": ["network", "storage"],
                "network": ["core"],
                "standalone": [],
                "storage": ["core"],
            ],
    )
}

@Test(arguments: ["", "\n   \n\n"])
func emptyAndWhitespaceOnlyInput(contents: String) throws {
    let graph = try withTemporaryInput(contents: contents) { file in
        var command = TopologicalSortCommand()
        command.file = file.path
        return try command._graph()
    }

    #expect(graph.isEmpty)
}

@Test
func missingFileThrows() {
    let file = FileManager.default.temporaryDirectory
        .appendingPathComponent(UUID().uuidString, isDirectory: false)
    var command = TopologicalSortCommand()
    command.file = file.path

    #expect(throws: (any Error).self) {
        try command._graph()
    }
}

private func withTemporaryInput<Result>(
    contents: String,
    perform: (URL) throws -> Result,
) throws -> Result {
    let directory = FileManager.default.temporaryDirectory
        .appendingPathComponent("uritsort-tests-\(UUID().uuidString)", isDirectory: true)
    try FileManager.default.createDirectory(
        at: directory,
        withIntermediateDirectories: false,
    )
    defer {
        try? FileManager.default.removeItem(at: directory)
    }

    let file = directory.appendingPathComponent("input.txt", isDirectory: false)
    try contents.write(to: file, atomically: true, encoding: .utf8)
    return try perform(file)
}

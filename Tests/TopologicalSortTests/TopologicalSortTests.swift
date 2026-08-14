import Testing

@testable
import TopologicalSort

@Test
func emptyGraph() throws {
    let graph: [String: [String]] = .init()

    #expect(graph.stronglyConnectedComponents().isEmpty)
    #expect(try graph.topologicalSort().isEmpty)
}

@Test
func isolatedNodes() throws {
    let graph: [String: [String]] = [
        "alpha": [],
        "beta": [],
    ]

    let components = graph.stronglyConnectedComponents()
    let sorted = try graph.topologicalSort()

    #expect(components == [["alpha"], ["beta"]])
    #expect(sorted == ["alpha", "beta"])
}

@Test
func linearDependencies() throws {
    let graph = [
        "application": ["library"],
        "library": ["runtime"],
    ]

    let sorted = try graph.topologicalSort()

    #expect(sorted == ["runtime", "library", "application"])
}

@Test
func initializedSorterUsesMinimumAvailableNode() throws {
    let graph = [
        "application": ["network", "storage"],
        "network": ["core"],
        "standalone": [],
        "storage": ["core"],
    ]
    let nodes = ["application", "standalone"]
    var componentSorter: TopologicalSorter<String> = .init(
        nodes: nodes,
        dependenciesOf: {graph[$0, default: []]},
    )
    var topologicalSorter: TopologicalSorter<String> = .init(
        nodes: nodes,
        dependenciesOf: {graph[$0, default: []]},
    )

    #expect(
        componentSorter.stronglyConnectedComponents()
            == [
                ["core"],
                ["network"],
                ["standalone"],
                ["storage"],
                ["application"],
            ],
    )
    #expect(
        try topologicalSorter.topologicalSort()
            == ["core", "network", "standalone", "storage", "application"],
    )
}

@Test
func branchingAndDisconnectedDependencies() throws {
    let graph = [
        "application": ["network", "storage"],
        "network": ["core"],
        "standalone": [],
        "storage": ["core"],
    ]

    let sorted = try graph.topologicalSort()
    #expect(sorted == ["core", "network", "standalone", "storage", "application"])
}

@Test
func minimumAvailableOrderDiffersFromSortedDepthFirstTraversal() throws {
    let graph = [
        "alpha": ["zeta"],
        "bravo": [],
    ]

    #expect(
        graph.stronglyConnectedComponents()
            == [["bravo"], ["zeta"], ["alpha"]],
    )
    #expect(try graph.topologicalSort() == ["bravo", "zeta", "alpha"])
}

@Test
func equivalentGraphRepresentationsHaveIdenticalOrder() throws {
    let first = Dictionary(
        uniqueKeysWithValues: [
            ("application", ["storage", "network"]),
            ("network", ["core"]),
            ("standalone", []),
            ("storage", ["core"]),
        ],
    )
    let second = Dictionary(
        uniqueKeysWithValues: [
            ("storage", ["core"]),
            ("standalone", []),
            ("network", ["core"]),
            ("application", ["network", "storage"]),
        ],
    )
    let expectedComponents = [
        ["core"],
        ["network"],
        ["standalone"],
        ["storage"],
        ["application"],
    ]
    let expectedSorted = ["core", "network", "standalone", "storage", "application"]

    #expect(first.stronglyConnectedComponents() == expectedComponents)
    #expect(second.stronglyConnectedComponents() == expectedComponents)
    #expect(try first.topologicalSort() == expectedSorted)
    #expect(try second.topologicalSort() == expectedSorted)
}

@Test
func referencedNodesAndDuplicateDependencies() throws {
    let graph = [
        "application": ["runtime", "runtime"],
    ]

    let components = graph.stronglyConnectedComponents()
    let sorted = try graph.topologicalSort()

    #expect(components == [["runtime"], ["application"]])
    #expect(sorted == ["runtime", "application"])
}

@Test
func stronglyConnectedComponents() throws {
    let graph = [
        "application": ["parser"],
        "lexer": ["parser"],
        "parser": ["lexer"],
        "standalone": [],
    ]

    let components = graph.stronglyConnectedComponents()
    #expect(
        components
            == [
                ["lexer", "parser"],
                ["application"],
                ["standalone"],
            ],
    )
}

@Test
func multiNodeCycleThrows() {
    let graph = [
        "alpha": ["beta"],
        "beta": ["alpha"],
    ]

    do {
        _ = try graph.topologicalSort()
        Issue.record("Expected a cycle error.")
    }
    catch {
        switch error {
        case .cycle(let nodes):
            #expect(nodes == ["alpha", "beta"])
        }
    }
}

@Test
func firstCycleUsesDeterministicComponentOrder() {
    let graph = [
        "alpha": ["delta"],
        "bravo": ["charlie"],
        "charlie": ["bravo"],
        "delta": ["alpha"],
    ]

    #expect(
        graph.stronglyConnectedComponents()
            == [
                ["alpha", "delta"],
                ["bravo", "charlie"],
            ],
    )

    do {
        _ = try graph.topologicalSort()
        Issue.record("Expected a cycle error.")
    }
    catch {
        switch error {
        case .cycle(let nodes):
            #expect(nodes == ["alpha", "delta"])
        }
    }
}

@Test
func selfCycleThrows() {
    let graph = [
        "alpha": ["alpha"],
    ]

    let components = graph.stronglyConnectedComponents()
    #expect(components == [["alpha"]])

    do {
        _ = try graph.topologicalSort()
        Issue.record("Expected a cycle error.")
    }
    catch {
        switch error {
        case .cycle(let nodes):
            #expect(nodes == ["alpha"])
        }
    }
}

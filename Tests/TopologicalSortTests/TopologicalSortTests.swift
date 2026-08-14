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

    #expect(components.count == 2)
    #expect(components.allSatisfy({$0.count == 1}))
    #expect(Set(components.joined()) == ["alpha", "beta"])
    #expect(Set(sorted) == ["alpha", "beta"])
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
func initializedSorterTraversalOrder() throws {
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
                ["storage"],
                ["application"],
                ["standalone"],
            ],
    )
    #expect(
        try topologicalSorter.topologicalSort()
            == ["core", "network", "storage", "application", "standalone"],
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
    let positions = Dictionary(uniqueKeysWithValues: sorted.enumerated().map({($1, $0)}))
    let core = try #require(positions["core"])
    let network = try #require(positions["network"])
    let storage = try #require(positions["storage"])
    let application = try #require(positions["application"])

    #expect(Set(sorted) == ["application", "core", "network", "standalone", "storage"])
    #expect(core < network)
    #expect(core < storage)
    #expect(network < application)
    #expect(storage < application)
}

@Test
func repeatedTraversalsAreDeterministic() throws {
    let graph = [
        "application": ["network", "storage"],
        "network": ["core"],
        "standalone": [],
        "storage": ["core"],
    ]
    let expectedComponents = graph.stronglyConnectedComponents()
    let expectedSorted = try graph.topologicalSort()

    for _ in 0..<20 {
        #expect(graph.stronglyConnectedComponents() == expectedComponents)
        #expect(try graph.topologicalSort() == expectedSorted)
    }
}

@Test
func referencedNodesAndDuplicateDependencies() throws {
    let graph = [
        "application": ["runtime", "runtime"],
    ]

    let components = graph.stronglyConnectedComponents()
    let sorted = try graph.topologicalSort()

    #expect(components.count == 2)
    #expect(components.allSatisfy({$0.count == 1}))
    #expect(Set(components.joined()) == ["application", "runtime"])
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
    let cycle = try #require(
        components.firstIndex(where: {Set($0) == ["lexer", "parser"]}),
    )
    let application = try #require(
        components.firstIndex(where: {$0 == ["application"]}),
    )

    #expect(components.count == 3)
    #expect(Set(components.joined()) == ["application", "lexer", "parser", "standalone"])
    #expect(cycle < application)
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
            #expect(Set(nodes) == ["alpha", "beta"])
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

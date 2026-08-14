internal struct TopologicalSorter<Node>: ~Copyable
where Node: Hashable & Sendable {

    private let nodes: any Collection<Node>

    private let dependenciesOf: (Node) -> [Node]

    private var nextIndex: Int = 0

    private var indices: [Node: Int] = .init()

    private var lowLinks: [Node: Int] = .init()

    private var stack: [Node] = .init()

    private var nodesOnStack: Set<Node> = .init()

    private var components: [[Node]] = .init()

    internal init(
        nodes: any Collection<Node>,
        dependenciesOf: @escaping (Node) -> [Node],
    ) {
        self.nodes = nodes
        self.dependenciesOf = dependenciesOf
    }

    internal mutating func stronglyConnectedComponents() -> [[Node]] {
        for node in nodes where indices[node] == nil {
            connect(node)
        }

        return components
    }

    internal mutating func topologicalSort() throws(TopologicalSortError<Node>) -> [Node] {
        let components = stronglyConnectedComponents()

        for component in components {
            if component.count > 1 {
                throw .cycle(component)
            }

            if
                let node = component.first,
                dependenciesOf(node).contains(node)
            {
                throw .cycle(component)
            }
        }

        return components.flatMap({$0})
    }

    private mutating func connect(_ node: Node) {
        let nodeIndex = nextIndex
        nextIndex += 1
        indices[node] = nodeIndex
        lowLinks[node] = nodeIndex
        stack.append(node)
        nodesOnStack.insert(node)

        for dependency in dependenciesOf(node) {
            if indices[dependency] == nil {
                connect(dependency)
                lowLinks[node] = min(
                    lowLink(of: node),
                    lowLink(of: dependency),
                )
            }
            else if nodesOnStack.contains(dependency) {
                lowLinks[node] = min(
                    lowLink(of: node),
                    index(of: dependency),
                )
            }
        }

        guard lowLink(of: node) == nodeIndex else {
            return
        }

        var component: [Node] = .init()
        while true {
            guard let member = stack.popLast() else {
                fatalError("A strongly connected component must end at its root node.")
            }

            nodesOnStack.remove(member)
            component.append(member)

            if member == node {
                break
            }
        }

        components.append(component)
    }

    private func index(of node: Node) -> Int {
        guard let index = indices[node] else {
            fatalError("A visited node must have an index.")
        }

        return index
    }

    private func lowLink(of node: Node) -> Int {
        guard let lowLink = lowLinks[node] else {
            fatalError("A visited node must have a low-link value.")
        }

        return lowLink
    }
}

internal struct TopologicalSorter<Node>: ~Copyable
where Node: Comparable & Hashable & Sendable {

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

        return dependencyFirstOrder(of: components.map({$0.sorted()}))
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

    private func dependencyFirstOrder(of components: [[Node]]) -> [[Node]] {
        var componentOfNode: [Node: Int] = .init()
        for (componentIndex, component) in components.enumerated() {
            for node in component {
                componentOfNode[node] = componentIndex
            }
        }

        var dependencyCounts = Array(repeating: 0, count: components.count)
        var dependents = Array(repeating: Set<Int>(), count: components.count)

        for (componentIndex, component) in components.enumerated() {
            var dependencyComponents: Set<Int> = .init()
            for node in component {
                for dependency in dependenciesOf(node) {
                    guard let dependencyComponent = componentOfNode[dependency] else {
                        fatalError("Every dependency must belong to a strongly connected component.")
                    }

                    if dependencyComponent != componentIndex {
                        dependencyComponents.insert(dependencyComponent)
                    }
                }
            }

            dependencyCounts[componentIndex] = dependencyComponents.count
            for dependencyComponent in dependencyComponents {
                dependents[dependencyComponent].insert(componentIndex)
            }
        }

        var available: MinimumHeap<ComponentCandidate<Node>> = .init()
        for componentIndex in components.indices where dependencyCounts[componentIndex] == 0 {
            available.insert(candidate(for: componentIndex, in: components))
        }

        var orderedComponents: [[Node]] = .init()
        while let nextComponent = available.removeMinimum() {
            orderedComponents.append(components[nextComponent.index])

            for dependent in dependents[nextComponent.index] {
                dependencyCounts[dependent] -= 1
                if dependencyCounts[dependent] == 0 {
                    available.insert(candidate(for: dependent, in: components))
                }
            }
        }

        guard orderedComponents.count == components.count else {
            fatalError("A strongly connected component graph must be acyclic.")
        }

        return orderedComponents
    }

    private func candidate(
        for componentIndex: Int,
        in components: [[Node]],
    ) -> ComponentCandidate<Node> {
        guard let minimumNode = components[componentIndex].first else {
            fatalError("A strongly connected component must contain a node.")
        }

        return .init(minimumNode: minimumNode, index: componentIndex)
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

private struct ComponentCandidate<Node>: Comparable
where Node: Comparable {

    let minimumNode: Node

    let index: Int

    static func < (lhs: Self, rhs: Self) -> Bool {
        if lhs.minimumNode != rhs.minimumNode {
            return lhs.minimumNode < rhs.minimumNode
        }

        return lhs.index < rhs.index
    }
}

private struct MinimumHeap<Element>
where Element: Comparable {

    private var elements: [Element] = .init()

    mutating func insert(_ element: Element) {
        elements.append(element)

        var index = elements.index(before: elements.endIndex)
        while index > elements.startIndex {
            let parent = (index - 1) / 2
            guard elements[index] < elements[parent] else {
                return
            }

            elements.swapAt(index, parent)
            index = parent
        }
    }

    mutating func removeMinimum() -> Element? {
        guard let minimum = elements.first else {
            return nil
        }

        guard elements.count > 1 else {
            return elements.removeLast()
        }

        elements[0] = elements.removeLast()

        var index = elements.startIndex
        while true {
            let left = index * 2 + 1
            guard left < elements.endIndex else {
                break
            }

            let right = left + 1
            let child =
                right < elements.endIndex && elements[right] < elements[left]
                ? right
                : left
            guard elements[child] < elements[index] else {
                break
            }

            elements.swapAt(index, child)
            index = child
        }

        return minimum
    }
}

extension Dictionary
where Key: Comparable & Hashable & Sendable, Value == [Key] {

    /// Returns the graph's strongly connected components in dependency-first order.
    ///
    /// Each key is a node that depends on the nodes in its value. A dependency that
    /// is not itself a key is included as a node with no dependencies. Nodes within
    /// each component are in ascending order. Components are dependency-first, with
    /// the component containing the smallest node chosen whenever multiple
    /// components are available.
    ///
    /// - Complexity: O(E + V log V), where V is the number of reachable nodes and E
    ///   is the number of dependency references.
    public func stronglyConnectedComponents() -> [[Key]] {
        var sorter: TopologicalSorter<Key> = .init(
            nodes: keys,
            dependenciesOf: {self[$0, default: []]},
        )
        return sorter.stronglyConnectedComponents()
    }

    /// Returns the graph's nodes with every dependency before its dependent node.
    ///
    /// Each key is a node that depends on the nodes in its value. A dependency that
    /// is not itself a key is included as a node with no dependencies. Whenever
    /// multiple nodes are available, the smallest node is returned first.
    ///
    /// - Throws: `TopologicalSortError.cycle` with the nodes in ascending order from
    ///   the first cyclic strongly connected component in deterministic
    ///   dependency-first order.
    /// - Complexity: O(E + V log V), where V is the number of reachable nodes and E
    ///   is the number of dependency references.
    public func topologicalSort() throws(TopologicalSortError<Key>) -> [Key] {
        var sorter: TopologicalSorter<Key> = .init(
            nodes: keys,
            dependenciesOf: {self[$0, default: []]},
        )
        return try sorter.topologicalSort()
    }
}

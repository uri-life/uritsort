extension Dictionary
where Key: Hashable & Sendable, Value == [Key] {

    /// Returns the graph's strongly connected components in dependency-first order.
    ///
    /// Each key is a node that depends on the nodes in its value. A dependency that
    /// is not itself a key is included as a node with no dependencies. The order of
    /// nodes within a component and of components unrelated by dependencies is
    /// unspecified.
    ///
    /// - Complexity: O(V + E), where V is the number of reachable nodes and E is the
    ///   number of dependency references.
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
    /// is not itself a key is included as a node with no dependencies. The relative
    /// order of nodes unrelated by dependencies is unspecified.
    ///
    /// - Throws: `TopologicalSortError.cycle` with the nodes in the first cyclic
    ///   strongly connected component encountered during traversal.
    /// - Complexity: O(V + E), where V is the number of reachable nodes and E is the
    ///   number of dependency references.
    public func topologicalSort() throws(TopologicalSortError<Key>) -> [Key] {
        var sorter: TopologicalSorter<Key> = .init(
            nodes: keys,
            dependenciesOf: {self[$0, default: []]},
        )
        return try sorter.topologicalSort()
    }
}

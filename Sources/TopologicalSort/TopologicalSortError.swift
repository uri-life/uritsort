/// An error produced when a graph cannot be topologically sorted.
public enum TopologicalSortError<Node>: Error
where Node: Hashable & Sendable {

    /// The graph contains a cycle among the nodes in the associated strongly
    /// connected component. Sorting operations list these nodes in ascending order.
    case cycle([Node])
}

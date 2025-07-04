extension RandomAccessCollection {
	subscript(safe index: Index) -> Element? {
		indices.contains(index)
			? self[index]
			: nil
	}
}

extension MutableCollection {
	subscript(safe index: Index) -> Element? {
		get {
			indices.contains(index) ? self[index] : nil
		}
		set(newValue) {
			guard indices.contains(index), let newValue else { return }
			self[index] = newValue
		}
	}
}

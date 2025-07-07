import SwiftUI

public struct ViewControllerPreview<UIViewControllerType: UIViewController>: UIViewControllerRepresentable {
	private let base: UIViewControllerType
	public init(_ base: () -> UIViewControllerType) {
		self.base = base()
	}

	public func makeUIViewController(context: Context) -> UIViewControllerType { base }
	public func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}
}

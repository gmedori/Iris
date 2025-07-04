import UIKit

protocol AddressBarViewDelegate: AnyObject {
	func addressBarView(_ addressBarView: AddresssBarView, didSubmit url: URL)
}

final class AddresssBarView: UIView {
	// MARK: Public

	var text: String? {
		get { self.textField.text }
		set { self.textField.text = newValue }
	}

	// MARK: Delegate

	weak var delegate: (any AddressBarViewDelegate)?

	// MARK: Subviews

	private let capsuleBackground = UIVisualEffectView(effect: UIGlassEffect())
	private let textField = UITextField()

	// MARK: Initialization

	override init(frame: CGRect) {
		super.init(frame: frame)
		setUpViews()
		setUpConstraints()
	}

	override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
		/*
		 We want to ensure that any tap on the visible portion of this view (that is, anything within the capsule) gets
		 picked up by the text field.
		 */
		let convertedPoint = convert(point, to: capsuleBackground)
		if self.capsuleBackground.bounds.contains(convertedPoint) {
			return self.textField
		}
		return super.hitTest(point, with: event)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

// MARK: - Private Helpers

extension AddresssBarView {
	func setUpViews() {
		addSubview(self.capsuleBackground)
		self.capsuleBackground.contentView.addSubview(self.textField)

		self.capsuleBackground.translatesAutoresizingMaskIntoConstraints = false

		self.textField.translatesAutoresizingMaskIntoConstraints = false
		self.textField.returnKeyType = .go
		self.textField.autocapitalizationType = .none
		self.textField.autocorrectionType = .no
		self.textField.textAlignment = .center
		self.textField.delegate = self
	}

	func setUpConstraints() {
		// We define the ideal height constraint outside the array below so we can control its priority
		let idealHeight = 50.0
		let idealHeightConstraint = self.capsuleBackground.heightAnchor.constraint(equalToConstant: idealHeight)
		idealHeightConstraint.priority = .defaultHigh
		NSLayoutConstraint.activate([
			// background constraints
			self.capsuleBackground.leadingAnchor.constraint(equalTo: leadingAnchor),
			self.capsuleBackground.trailingAnchor.constraint(equalTo: trailingAnchor),
			self.capsuleBackground.bottomAnchor.constraint(equalTo: bottomAnchor),
			self.capsuleBackground.heightAnchor.constraint(greaterThanOrEqualToConstant: idealHeight),
			idealHeightConstraint,

			// text field constraints
			self.textField.centerXAnchor.constraint(equalTo: self.capsuleBackground.centerXAnchor),
			self.textField.centerYAnchor.constraint(equalTo: self.capsuleBackground.centerYAnchor),
			self.textField.heightAnchor.constraint(equalTo: self.capsuleBackground.heightAnchor, constant: -8),
			/*
			 TODO: Update this widthAnchor constraint to scale nicely with dynamic type.
			 We want to prevent the text field from going into the rounded part of the capsule but, as written, this
			 will only work if the capsule background is at the ideal height (i.e. at the default font size or smaller).
			 */
			self.textField.widthAnchor.constraint(equalTo: self.capsuleBackground.widthAnchor, constant: -idealHeight),
		])
	}
}

// MARK: - AddressBarView + UITextFieldDelegate

extension AddresssBarView: UITextFieldDelegate {
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		guard var text = textField.text?.lowercased() else { return false }
		if !text.starts(with: /https?:\/\//) { text = "https://" + text }

		guard let url = URL(string: text) else { return false }
		self.delegate?.addressBarView(self, didSubmit: url)
		self.textField.resignFirstResponder()
		return true
	}

	func textFieldDidBeginEditing(_ textField: UITextField) {
		textField.selectAll(nil)
	}
}

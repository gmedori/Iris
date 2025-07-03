import UIKit

protocol AddressBarViewDelegate: AnyObject {
	func addressBarView(_ addressBarView: AddresssBarView, didSubmit url: URL)
}

final class AddresssBarView: UIView {
	private let capsuleBackground = UIVisualEffectView(effect: UIGlassEffect())

	private let textField = UITextField()
	private var textFieldWidthConstraint: NSLayoutConstraint? = nil

	weak var delegate: (any AddressBarViewDelegate)?

	var text: String? {
		get { self.textField.text }
		set { self.textField.text = newValue }
	}

	override init(frame: CGRect) {
		super.init(frame: frame)

		self.isUserInteractionEnabled = true

		addSubview(self.capsuleBackground)
		self.capsuleBackground.contentView.addSubview(self.textField)

		self.capsuleBackground.translatesAutoresizingMaskIntoConstraints = false
		self.capsuleBackground.isUserInteractionEnabled = true

		self.textField.translatesAutoresizingMaskIntoConstraints = false
		self.textField.returnKeyType = .go
		self.textField.autocapitalizationType = .none
		self.textField.autocorrectionType = .no
		self.textField.textAlignment = .center
		self.textField.delegate = self

		let idealHeightConstraint = self.capsuleBackground.heightAnchor.constraint(equalToConstant: 50)
		idealHeightConstraint.priority = .defaultHigh
		let minimumHeightConstraint = self.capsuleBackground.heightAnchor.constraint(greaterThanOrEqualToConstant: 50)
		NSLayoutConstraint.activate([
			self.capsuleBackground.leadingAnchor.constraint(equalTo: leadingAnchor),
			self.capsuleBackground.trailingAnchor.constraint(equalTo: trailingAnchor),
			self.capsuleBackground.bottomAnchor.constraint(equalTo: bottomAnchor),
			idealHeightConstraint,
			minimumHeightConstraint,
			self.textField.centerXAnchor.constraint(equalTo: self.capsuleBackground.centerXAnchor),
			self.textField.centerYAnchor.constraint(equalTo: self.capsuleBackground.centerYAnchor),
			self.textField.heightAnchor.constraint(equalTo: self.capsuleBackground.heightAnchor, constant: -8),
		])
		self.textFieldWidthConstraint = self.textField.widthAnchor.constraint(
			equalTo: self.capsuleBackground.widthAnchor,
			constant: -50
		)
		self.textFieldWidthConstraint?.isActive = true
	}

	override func layoutSubviews() {
		super.layoutSubviews()
		self.capsuleBackground.layer.cornerRadius = bounds.height / 2
		self.textFieldWidthConstraint?.constant = bounds.height
	}

	override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
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

// MARK: AddressBarView + UITextFieldDelegate

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

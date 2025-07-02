import UIKit
import WebKit

class RootViewController: UIViewController {

	private let webView = WKWebView()
	private let addressBar = UITextField()
	private var addressBarBottomConstraint: NSLayoutConstraint? = nil

	override func loadView() {
		view = UIView()
		view.addSubview(webView)
		view.addSubview(addressBar)
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		webView.translatesAutoresizingMaskIntoConstraints = false
		webView.navigationDelegate = self

		addressBar.translatesAutoresizingMaskIntoConstraints = false
		addressBar.borderStyle = .roundedRect
		addressBar.returnKeyType = .go
		addressBar.autocapitalizationType = .none
		addressBar.autocorrectionType = .no
		addressBar.delegate = self

		NSLayoutConstraint.activate([
			// Web View
			webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
			webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
			webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			// Addresss Bar
			addressBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
			addressBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
		])

		addressBarBottomConstraint = addressBar.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
		addressBarBottomConstraint?.isActive = true

		let myURL = URL(string: "https://thebrowser.company")
		let myRequest = URLRequest(url: myURL!)
		webView.load(myRequest)

	}
}

// MARK: - User Actions

extension RootViewController {
	func didSubmitAddressBar(withURL url: URL) {
		webView.load(URLRequest(url: url))
		addressBar.text = url.absoluteString.lowercased()
	}
}

// MARK: - RootViewController + UITextFieldDelegate

extension RootViewController: UITextFieldDelegate {
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		//
		guard var text = textField.text?.lowercased() else { return false }
		if !text.starts(with: /https?:\/\//) { text.insert(contentsOf: "https://", at: text.startIndex) }

		guard let url = URL(string: text) else { return false }
		didSubmitAddressBar(withURL: url)
		addressBar.resignFirstResponder()
		return true
	}

	func textFieldDidBeginEditing(_ textField: UITextField) {
		textField.selectAll(nil)
	}
}

extension RootViewController: WKNavigationDelegate {
	func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
		if let url = webView.url {
			addressBar.text = url.absoluteString.lowercased()
		}
	}
}


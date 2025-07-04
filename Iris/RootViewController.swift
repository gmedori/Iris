import UIKit
import WebKit

class RootViewController: UIViewController {
	private let webView = WKWebView()

	private let toolbar = UIToolbar()
	private let addressBar = AddresssBarView()
	private var addressBarBottomConstraint: NSLayoutConstraint? = nil

	override func loadView() {
		view = UIView()
		view.addSubview(self.webView)
		view.addSubview(self.toolbar)
		view.addSubview(self.addressBar)
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		self.webView.translatesAutoresizingMaskIntoConstraints = false
		self.webView.navigationDelegate = self

		self.toolbar.items = [
			UIBarButtonItem(
				title: "Go Back",
				image: UIImage(systemName: "chevron.left"),
				target: nil,
				action: #selector(self.goBack)
			),
			UIBarButtonItem(
				title: "Go Forward",
				image: UIImage(systemName: "chevron.right"),
				target: nil,
				action: #selector(self.goBack)
			),
			UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
			UIBarButtonItem(
				title: "Show Tabs",
				image: UIImage(systemName: "square.on.square"),
				target: nil,
				action: #selector(self.goBack)
			),
		]
		self.toolbar.translatesAutoresizingMaskIntoConstraints = false

		self.addressBar.translatesAutoresizingMaskIntoConstraints = false
		self.addressBar.delegate = self

		NSLayoutConstraint.activate([
			// Web View
			self.webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
			self.webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
			self.webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			self.webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			// Toolbar
			self.toolbar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
			self.toolbar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			self.toolbar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			// Addresss Bar
			self.addressBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
			self.addressBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
		])

		self.addressBarBottomConstraint = self.addressBar.bottomAnchor.constraint(
			lessThanOrEqualTo: self.toolbar.topAnchor,
			constant: -20
		)
		self.addressBarBottomConstraint?.isActive = true

		let myURL = URL(string: "https://thebrowser.company")
		let myRequest = URLRequest(url: myURL!)
		self.webView.load(myRequest)
	}

	@objc
	func goBack() {}
}

// MARK: - RootViewController + AddressBarViewDelegate

extension RootViewController: AddressBarViewDelegate {
	func addressBarView(_ addressBarView: AddresssBarView, didSubmit url: URL) {
		self.webView.load(URLRequest(url: url))
		addressBarView.text = url.absoluteString.lowercased()
	}
}

// MARK: - RootViewController + WKNavigationDelegate

extension RootViewController: WKNavigationDelegate {
	func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
		if let url = webView.url {
			self.addressBar.text = url.absoluteString.lowercased()
		}
	}
}

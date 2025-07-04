import UIKit
import WebKit

class RootViewController: UIViewController {
	// MARK: Subviews

	private let webView = WKWebView()
	private let toolbar = UIToolbar()
	private let addressBar = AddresssBarView()
	private var addressBarBottomConstraint: NSLayoutConstraint? = nil

	// MARK: Feature Controllers

	private let webHistoryTracker = WebHistoryTracker()

	override func loadView() {
		view = UIView()
		view.addSubview(webView)
		view.addSubview(toolbar)
		view.addSubview(addressBar)
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		setUpViews()
		setUpConstraints()
	}
}

// MARK: - User Actions

extension RootViewController {
	@objc
	func goBack() {
		if let url = webHistoryTracker.goBack() {
			addressBar.text = url.absoluteString.lowercased()
			webView.load(URLRequest(url: url))
		}
	}

	@objc
	func goForward() {
		if let url = webHistoryTracker.goForward() {
			addressBar.text = url.absoluteString.lowercased()
			webView.load(URLRequest(url: url))
		}
	}

	@objc
	func showTabs() {}
}

// MARK: - Private Helpers

extension RootViewController {
	private func setUpViews() {
		webView.translatesAutoresizingMaskIntoConstraints = false
		webView.navigationDelegate = self
		let initialURL = URL(string: "https://thebrowser.company")!
		webView.load(URLRequest(url: initialURL))

		toolbar.translatesAutoresizingMaskIntoConstraints = false
		toolbar.items = [
			UIBarButtonItem(
				title: "Go Back",
				image: UIImage(systemName: "chevron.left"),
				target: nil,
				action: #selector(goBack)
			),
			UIBarButtonItem(
				title: "Go Forward",
				image: UIImage(systemName: "chevron.right"),
				target: nil,
				action: #selector(goForward)
			),
			UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
			UIBarButtonItem(
				title: "Show Tabs",
				image: UIImage(systemName: "square.on.square"),
				target: nil,
				action: #selector(showTabs)
			),
		]

		addressBar.translatesAutoresizingMaskIntoConstraints = false
		addressBar.delegate = self
	}

	private func setUpConstraints() {
		NSLayoutConstraint.activate([
			// Web View
			webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
			webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
			webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			// Toolbar
			toolbar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
			toolbar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			toolbar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			// Addresss Bar
			addressBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
			addressBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
		])

		addressBarBottomConstraint = addressBar.bottomAnchor.constraint(
			lessThanOrEqualTo: toolbar.topAnchor,
			constant: -20
		)
		addressBarBottomConstraint?.isActive = true
	}
}

// MARK: - RootViewController + AddressBarViewDelegate

extension RootViewController: AddressBarViewDelegate {
	func addressBarView(_ addressBarView: AddresssBarView, didSubmit url: URL) {
		webView.load(URLRequest(url: url))
		addressBarView.text = url.absoluteString.lowercased()
	}
}

// MARK: - RootViewController + WKNavigationDelegate

extension RootViewController: WKNavigationDelegate {
	func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
		// TODO: Add a loading indicator
	}

	func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
		guard let url = webView.url else { return }
		addressBar.text = url.absoluteString.lowercased()

		/*
		 TODO: Fix the race condition that can happen if forward/back navigation is done before loading is complete.
		 In particular, manipulating webHistoryTracker.currentURL happens instantaneously, while checking it as we do
		 here only happens when we begin to receive a response from the server.

		 A solution would likely involve associating a history manipulation with a particular WKNavigation, or something
		 along those lines. Well beyond the scope of this toy project.
		 */
		if url != webHistoryTracker.currentURL {
			webHistoryTracker.visited(url: url)
		}
	}
}

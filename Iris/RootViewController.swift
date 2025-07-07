import UIKit
import WebKit

class RootViewController: UIViewController {
	// MARK: Modesl

	private let tabsModel = TabsModel()

	// MARK: Subviews

	private let webView = WKWebView()
	private let toolbar = UIToolbar()
	private let addressBar = AddresssBarView()
	private var backButton: UIBarButtonItem?
	private var forwardButton: UIBarButtonItem?
	private var addressBarBottomConstraint: NSLayoutConstraint? = nil

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
	func showTabs() {
		let tabsViewController = TabsViewController(tabsModel: tabsModel)
		let navController = UINavigationController(rootViewController: tabsViewController)
		present(navController, animated: true)
	}
}

// MARK: - Private Helpers

extension RootViewController {
	private func setUpViews() {
		// Web View
		webView.translatesAutoresizingMaskIntoConstraints = false
		webView.navigationDelegate = self
		let initialURL = URL(string: "https://apple.com/")!
		webView.load(URLRequest(url: initialURL))

		// Toolbar Buttons
		let backButton = UIBarButtonItem(
			title: "Go Back",
			image: UIImage(systemName: "chevron.left"),
			target: webView,
			action: #selector(webView.goBack)
		)
		backButton.isEnabled = webView.canGoBack
		self.backButton = backButton
		let forwardButton = UIBarButtonItem(
			title: "Go Forward",
			image: UIImage(systemName: "chevron.right"),
			target: webView,
			action: #selector(webView.goForward)
		)
		forwardButton.isEnabled = webView.canGoForward
		self.forwardButton = forwardButton

		// Toolbar
		toolbar.translatesAutoresizingMaskIntoConstraints = false
		toolbar.items = [
			backButton,
			forwardButton,
			UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
			UIBarButtonItem(
				title: "Show Tabs",
				image: UIImage(systemName: "square.on.square"),
				target: self,
				action: #selector(showTabs)
			),
		]

		// Address Bar
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

	private func updateAddressBarText(from url: URL?) {
		guard let url else { return }
		addressBar.text = url.absoluteString
	}

	private func updateForwardBackButtons(from webView: WKWebView) {
		/*
		 TODO: Identify the source of inconsistency with the isEnabled status on these buttons
		 It doesn't take much fiddling to tap on the back or forward buttons and reach a state that doesn't make sense.
		 For example, I just tried going to a website, then a second website. I hit the back button to go back to the
		 first website, and the back button was still enabled, while the forward button was not.
		 */
		backButton?.menu = UIMenu(children: webView.backForwardList.backList.map { backListItem in
			UIAction(title: backListItem.title ?? backListItem.url.absoluteString) { _ in
				webView.go(to: backListItem)
			}
		})
		backButton?.isEnabled = webView.canGoBack

		forwardButton?.menu = UIMenu(children: webView.backForwardList.forwardList.map { forwardListItem in
			UIAction(title: forwardListItem.title ?? forwardListItem.url.absoluteString) { _ in
				webView.go(to: forwardListItem)
			}
		})
		forwardButton?.isEnabled = webView.canGoForward
	}
}

// MARK: - RootViewController + AddressBarViewDelegate

extension RootViewController: AddressBarViewDelegate {
	func addressBarView(_ addressBarView: AddresssBarView, didSubmit url: URL) {
		webView.load(URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData))
		updateAddressBarText(from: url)
	}
}

// MARK: - RootViewController + WKNavigationDelegate

extension RootViewController: WKNavigationDelegate {
	func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
		// TODO: Add a loading indicator
	}

	func webView(
		_ webView: WKWebView,
		decidePolicyFor navigationAction: WKNavigationAction
	) async -> WKNavigationActionPolicy {
		updateAddressBarText(from: webView.url)
		return .allow
	}

	func webView(
		_ webView: WKWebView,
		shouldGoTo backForwardListItem: WKBackForwardListItem,
		willUseInstantBack: Bool
	) async -> Bool {
		updateAddressBarText(from: webView.url)
		return true
	}

	func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
		if let name = webView.title, let url = webView.url {
			tabsModel.updateCurrentTab(name: name, url: url)
		}
		updateForwardBackButtons(from: webView)
	}
}

// MARK: - RootViewController + TabsModelDelegate

extension RootViewController: TabsModelDelegate {
	func tabsModel(_ tabsModel: TabsModel, didSwitchTabs newTab: Tab) {
		switch newTab.content {
			case .empty:
				webView.loadHTMLString("<html><body></body></html>", baseURL: nil)
			case let .page(_, url):
				webView.load(URLRequest(url: url))
		}
	}
}

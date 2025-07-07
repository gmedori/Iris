import Foundation

struct Tab: Hashable {
	var name: String
	var url: URL
	/*
	 In a perfect world, I could store the backList and forwardList in my own model and replace WKWebView's
	 backForwardList with our own on tab switch, but it doesn't seem like there's an API for that. I'd have to
	 investigate a workaround, so for the purposes of this toy app, we're going to nuke our history when we switch tabs.

	 struct Page {
	 var name: String
	 var url: URL
	 }
	 var currentPage: Page?

	 var backList: [Page]
	 var forwardList: [Page]
	 */
}

final class TabsModel {
	private(set) var tabs: [Tab]
	private var currentTabIndex: [Tab].Index? = nil
	
	var currentTab: Tab? {
		guard let currentTabIndex else { return nil }
		return tabs[safe: currentTabIndex]
	}

	init(tabs: [Tab] = [], currentTabIndex: [Tab].Index? = nil) {
		self.tabs = tabs
		self.currentTabIndex = currentTabIndex
	}
}

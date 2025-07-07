import Foundation

/**
 In a perfect world, I could store the backList and forwardList in my own model and replace WKWebView's
 backForwardList with our own on tab switch, but it doesn't seem like there's an API for that. I'd have to
 investigate a workaround, so for the purposes of this toy app, we're going to nuke our history when we switch tabs.
 */
struct Tab: Hashable, Identifiable {
	enum Content: Hashable {
		case empty
		case page(name: String, url: URL)
	}

	let id = UUID()
	var content: Content

	init() {
		self.content = .empty
	}

	init(name: String, url: URL) {
		self.content = .page(name: name, url: url)
	}

	var name: String {
		switch content {
			case .empty: "Empty"
			case let .page(name, _): name
		}
	}

	var url: URL? {
		switch content {
			case .empty: nil
			case let .page(_, url): url
		}
	}
}

final class TabsModel {
	private(set) var tabs: [Tab]
	private var currentTabIndex: [Tab].Index? = nil

	weak var delegate: (any TabsModelDelegate)? = nil

	var currentTab: Tab? {
		guard let currentTabIndex else { return nil }
		return tabs[safe: currentTabIndex]
	}

	init() {
		tabs = [.init()]
		currentTabIndex = tabs.indices.first
	}

	init(tabs: [Tab], currentTabIndex: [Tab].Index? = nil) {
		self.tabs = tabs
		self.currentTabIndex = currentTabIndex ?? tabs.indices.first ?? nil
	}

	func switchTabs(to tab: Tab) {
		guard let newTabIndex = tabs.firstIndex(where: { $0.id == tab.id }) else {
			print("ERROR: Attempting to switch tabs to nonexistent tab: \(tab)")
			return
		}
		print("Switching tabs to \(tab.name) (\(tab.id))")
		currentTabIndex = newTabIndex
		delegate?.tabsModel(self, didSwitchTabs: tabs[newTabIndex])
	}

	func updateCurrentTab(name: String, url: URL) {
		guard let currentTabIndex else { return }
		tabs[safe: currentTabIndex]?.content = .page(name: name, url: url)
	}

	func addNewtab() {
		let newTab = Tab()
		tabs.append(newTab)
		switchTabs(to: newTab)
	}
}

/*
 It's possible that this delegate is overkill. Might be easier to just have a callback that you can set either on
 initialization of the TabsModel, or after the fact depending on the call site.
 */
protocol TabsModelDelegate: AnyObject {
	func tabsModel(_ tabsModel: TabsModel, didSwitchTabs newTab: Tab)
}

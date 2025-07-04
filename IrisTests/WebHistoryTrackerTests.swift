@testable import Iris
import Foundation
import Testing

@Suite
struct WebHistoryTrackerTests {
	let webHistoryTracker = WebHistoryTracker()

	@Test
	func `visiting urls should append them to the visited url list`() {
		visitTwoWebsites()
		#expect(webHistoryTracker.currentURL == appleDotCom)
		#expect(webHistoryTracker.visitedURLs == [browserCoDotCom, googleDotCom, appleDotCom])
	}

	@Test
	func `going back should move the current url cursor back`() {
		visitTwoWebsites()
		let newURL = webHistoryTracker.goBack()
		#expect(newURL == googleDotCom)
	}

	@Test
	func `going back then visiting a new url should invalidate the forward urls`() {
		visitTwoWebsites()
		webHistoryTracker.goBack()
		webHistoryTracker.goBack()
		webHistoryTracker.visited(url: appleDotCom)
		#expect(webHistoryTracker.currentURL == appleDotCom)
		#expect(webHistoryTracker.visitedURLs == [browserCoDotCom, appleDotCom])
	}

	@Test
	func `going back with only one url in the history should do nothing`() {
		#expect(webHistoryTracker.currentURL == browserCoDotCom)
		#expect(webHistoryTracker.visitedURLs == [browserCoDotCom])
		webHistoryTracker.goBack()
		#expect(webHistoryTracker.currentURL == browserCoDotCom)
		#expect(webHistoryTracker.visitedURLs == [browserCoDotCom])
	}

	@Test
	func `going back then going forward should return you to where you were`() {
		visitTwoWebsites()
		webHistoryTracker.goBack()
		webHistoryTracker.goForward()
		#expect(webHistoryTracker.currentURL == appleDotCom)
		#expect(webHistoryTracker.visitedURLs == [browserCoDotCom, googleDotCom, appleDotCom])

	}

	@Test
	func `going forward while you're at the end of the history should do nothing`() {
		#expect(webHistoryTracker.currentURL == browserCoDotCom)
		#expect(webHistoryTracker.visitedURLs == [browserCoDotCom])
		webHistoryTracker.goForward()
		#expect(webHistoryTracker.currentURL == browserCoDotCom)
		#expect(webHistoryTracker.visitedURLs == [browserCoDotCom])
	}
}

// MARK: - Test Setup Helpers

extension WebHistoryTrackerTests {
	var browserCoDotCom: URL { URL(string: "https://thebrowser.company")! }
	var googleDotCom: URL { URL(string: "https://google.com")! }
	var appleDotCom: URL { URL(string: "https://apple.com")! }

	func visitTwoWebsites() {
		webHistoryTracker.visited(url: googleDotCom)
		webHistoryTracker.visited(url: appleDotCom)
	}
}


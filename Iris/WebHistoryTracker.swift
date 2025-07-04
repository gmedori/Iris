import Foundation

final class WebHistoryTracker {
	private(set) var visitedURLs: [URL] = [] {
		didSet {
			print("Current History: \(visitedURLs)")
		}
	}
	private(set) var currentURLPosition: [URL].Index = 0

	var currentURL: URL? { visitedURLs[safe: currentURLPosition] }

	func visited(url: URL) {
		// Handle the edge case where our current URL cursor has somehow been misplaced
		if !visitedURLs.indices.contains(currentURLPosition) {
			currentURLPosition = visitedURLs.startIndex
		}
		/*
		 Once you visit a new URL, we invalidate everything that might be ahead of the cursor. Consider the case
		 where you tap the "back" button several times, then click on a new link. You can no longer go forward in your
		 history.
		 */
		if currentURLPosition < visitedURLs.endIndex {
			visitedURLs.removeSubrange(visitedURLs.index(after: currentURLPosition) ..< visitedURLs.endIndex)
		}
		visitedURLs.append(url)
		currentURLPosition = visitedURLs.index(before: visitedURLs.endIndex)
	}

	@discardableResult
	func goBack() -> URL? {
		if currentURLPosition > visitedURLs.startIndex {
			visitedURLs.formIndex(before: &currentURLPosition)
		}
		return visitedURLs[safe: currentURLPosition]
	}

	@discardableResult
	func goForward() -> URL? {
		if currentURLPosition < visitedURLs.index(before: visitedURLs.endIndex) {
			visitedURLs.formIndex(after: &currentURLPosition)
		}
		return visitedURLs[safe: currentURLPosition]
	}
}


import SwiftUI

final class TabsViewController: UICollectionViewController {
	// MARK: Model

	private let tabsModel: TabsModel

	// MARK: Internal State

	private var dataSource: UICollectionViewDiffableDataSource<Section, Item>!

	// MARK: Initialization

	init(tabsModel: TabsModel) {
		self.tabsModel = tabsModel
		let listConfig = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
		super.init(collectionViewLayout: UICollectionViewCompositionalLayout.list(using: listConfig))
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: Lifecycle

	override func viewDidLoad() {
		super.viewDidLoad()
		navigationItem.title = "Tabs"
		let cellRegistration = UICollectionView.CellRegistration<UICollectionViewCell, Item> {
			[weak self] cell, indexPath, item in
			guard let self else { return }
			configure(cell: cell, indexPath: indexPath, item: item)
		}
		dataSource = UICollectionViewDiffableDataSource(collectionView: collectionView) {
			collectionView, indexPath, item in
			collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item)
		}
		dataSource.apply(.init(model: tabsModel), animatingDifferences: true)
	}
}

// MARK: - Supporting Types

extension TabsViewController {
	nonisolated enum Section: Sendable, Hashable {
		case category(String)
		case uncategorized
	}

	nonisolated enum Item: Sendable, Hashable {
		case tab(Tab)
	}

	struct TabCellView: View {
		let tab: Tab
		let isCurrentTab: Bool

		var body: some View {
			VStack(alignment: .leading) {
				HStack(alignment: .firstTextBaseline, spacing: .zero) {
					Text(tab.name)
						.frame(maxWidth: .infinity, alignment: .leading)
					if isCurrentTab {
						Image(systemName: "checkmark")
							.fontWeight(.black)
							.foregroundStyle(.green)
							.transition(.symbolEffect(.drawOn))
					}
				}
				Text(tab.url?.absoluteString ?? "")
					.font(.caption)
					.foregroundStyle(.secondary)
			}
		}
	}
}

// MARK: - TabsViewController + UICollectionViewControllerDelegate

extension TabsViewController {
	override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		guard let item = dataSource.itemIdentifier(for: indexPath) else {
			print("ERROR: Selected an item that does not exist at index path: \(indexPath)")
			return
		}

		switch item {
			case let .tab(tab):
				if tabsModel.currentTab != tab {
					tabsModel.switchTabs(to: tab)
					var snapshot = dataSource.snapshot()
					snapshot.reconfigureItems(snapshot.itemIdentifiers)
					dataSource.apply(snapshot, animatingDifferences: true)
				}
		}
	}
}

// MARK: - Private Helpers

extension TabsViewController {
	private func configure(cell: UICollectionViewCell, indexPath: IndexPath, item: Item) {
		switch item {
			case let .tab(tab):
				cell.contentConfiguration = UIHostingConfiguration {
					TabCellView(tab: tab, isCurrentTab: tabsModel.currentTab == tab)
				}
				cell.backgroundColor = .systemBackground
		}
	}
}

extension NSDiffableDataSourceSnapshot<TabsViewController.Section, TabsViewController.Item> {
	init(model: TabsModel) {
		self.init()
		appendSections([.uncategorized])
		appendItems(model.tabs.map(TabsViewController.Item.tab), toSection: .uncategorized)
	}
}

// MARK: - Previews

#if DEBUG
	#Preview {
		ViewControllerPreview {
			TabsViewController(tabsModel: TabsModel(
				tabs: [
					Tab(name: "Apple", url: URL(string: "https://www.apple.com/")!),
					Tab(name: "The Browser Company", url: URL(string: "https://thebrowser.company/")!),
				],
				currentTabIndex: 0
			))
		}
	}

#endif

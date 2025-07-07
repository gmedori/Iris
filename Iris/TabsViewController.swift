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
		setUpCollectionView()
		setUpAddButton()
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

// MARK: - User Actions

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
					/*
					 TODO: Identify why the animation gets clipped sometimes.
					 Sometimes, when you switch tabs, the view dismissed before you can see the checkmark animation,
					 while other times can see the animation clearly. I thought I noticed it when switching to tabs
					 with real web pages rather than empty tabs.
					 */
					dataSource.apply(snapshot, animatingDifferences: true) { [weak self] in
						self?.dismiss(animated: true)
					}
				}
		}
	}

	@objc
	private func addTabTapped() {
		tabsModel.addNewtab()
		dismiss(animated: true)
	}
}

// MARK: - Private Helpers

extension TabsViewController {
	private func setUpAddButton() {
		let backgroundView = UIView()
		backgroundView.translatesAutoresizingMaskIntoConstraints = false
		backgroundView.backgroundColor = view.backgroundColor
		view.addSubview(backgroundView)

		let button = UIButton(type: .system)
		button.translatesAutoresizingMaskIntoConstraints = false
		let plusImageConfig = UIImage.SymbolConfiguration(font: UIFont(
			descriptor: UIFont.preferredFont(forTextStyle: .title2).fontDescriptor.withSymbolicTraits(.traitBold)!,
			size: 0
		))
		button.setImage(UIImage(systemName: "plus", withConfiguration: plusImageConfig), for: .normal)
		button.addTarget(self, action: #selector(addTabTapped), for: .touchUpInside)
		button.configuration = .prominentGlass()
		button.tintColor = .systemGreen
		backgroundView.addSubview(button)

		NSLayoutConstraint.activate([
			// Background view
			backgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			backgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			backgroundView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

			// Button
			button.centerXAnchor.constraint(equalTo: backgroundView.centerXAnchor),
			button.topAnchor.constraint(equalTo: backgroundView.topAnchor, constant: 20),
			button.bottomAnchor.constraint(equalTo: backgroundView.bottomAnchor, constant: -20),
			button.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor, constant: 20),
			button.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor, constant: -20),
		])
	}

	private func setUpCollectionView() {
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

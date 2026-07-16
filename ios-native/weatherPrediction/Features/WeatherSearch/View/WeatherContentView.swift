import DomainModule
import UIKit

/// 氣象資料狀態的顯示視圖：一或多個縣市的**卡片**清單（UICollectionView + Diffable Data Source）。
/// 每張卡片可點標題展開 / 收合；展開時 3 個時段以**三欄並排**呈現。
/// 多筆結果預設收合、單筆自動展開。
final class WeatherContentView: UIView {
    private enum Section { case main }

    private var forecastsByCity: [String: WeatherForecastModel] = [:]
    private var orderedCities: [String] = []
    private var expanded: Set<String> = []

    private let countLabel: UILabel = {
        let label = UILabel()
        label.font = AppFont.listCount
        label.textColor = AppColor.textSecondary
        return label
    }()

    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: makeLayout())
        collectionView.backgroundColor = .clear
        collectionView.alwaysBounceVertical = true
        collectionView.register(
            WeatherCityCell.self,
            forCellWithReuseIdentifier: WeatherCityCell.reuseIdentifier
        )
        return collectionView
    }()

    private lazy var dataSource = makeDataSource()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with forecasts: [WeatherForecastModel]) {
        forecastsByCity = Dictionary(forecasts.map { ($0.cityName, $0) }, uniquingKeysWith: { first, _ in first })
        orderedCities = forecasts.map(\.cityName)
        // 每次搜尋一律收合（初始閉合），由使用者點標題展開。
        expanded = []
        countLabel.text = "共 \(forecasts.count) 個縣市"

        var snapshot = NSDiffableDataSourceSnapshot<Section, String>()
        snapshot.appendSections([.main])
        snapshot.appendItems(orderedCities, toSection: .main)
        dataSource.apply(snapshot, animatingDifferences: false)

        // 重新搜尋時，與上次結果同名的縣市會被 diffable 沿用舊 cell（不重呼叫 configure），
        // 導致舊的展開狀態殘留、滑動後才收起。強制全部項目重新設定，套用新的展開狀態。
        var refreshed = dataSource.snapshot()
        refreshed.reconfigureItems(refreshed.itemIdentifiers)
        dataSource.apply(refreshed, animatingDifferences: false)
    }

    private func setupLayout() {
        countLabel.translatesAutoresizingMaskIntoConstraints = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(countLabel)
        addSubview(collectionView)

        NSLayoutConstraint.activate([
            countLabel.topAnchor.constraint(equalTo: topAnchor, constant: 2),
            countLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            countLabel.trailingAnchor.constraint(equalTo: trailingAnchor),

            collectionView.topAnchor.constraint(equalTo: countLabel.bottomAnchor, constant: 8),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }

    private func toggle(_ city: String) {
        if expanded.contains(city) {
            expanded.remove(city)
        } else {
            expanded.insert(city)
        }
        var snapshot = dataSource.snapshot()
        snapshot.reconfigureItems([city])
        dataSource.apply(snapshot, animatingDifferences: true)
    }

    private func makeDataSource() -> UICollectionViewDiffableDataSource<Section, String> {
        UICollectionViewDiffableDataSource<Section, String>(
            collectionView: collectionView
        ) { [weak self] collectionView, indexPath, city in
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: WeatherCityCell.reuseIdentifier,
                for: indexPath
            )
            guard let self, let forecast = self.forecastsByCity[city],
                  let cityCell = cell as? WeatherCityCell
            else { return cell }
            cityCell.configure(forecast: forecast, isExpanded: self.expanded.contains(city))
            cityCell.onToggle = { [weak self] in self?.toggle(city) }
            return cityCell
        }
    }

    private func makeLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(120)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let group = NSCollectionLayoutGroup.vertical(layoutSize: itemSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 12
        section.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 0, bottom: 20, trailing: 0)
        return UICollectionViewCompositionalLayout(section: section)
    }
}

import DomainModule
import UIKit

/// 氣象資料狀態的顯示視圖：一或多個縣市的清單（UICollectionView + Diffable Data Source）。
/// 每個縣市為一個 section（header = 縣市名），section 內為 3 個時段。
final class WeatherContentView: UIView {
    // section identifier 用縣市名（22 縣市名互異，穩定且唯一）。
    private typealias Section = String

    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: Self.makeLayout())
        collectionView.backgroundColor = .clear
        collectionView.alwaysBounceVertical = true
        collectionView.register(
            WeatherPeriodCell.self,
            forCellWithReuseIdentifier: WeatherPeriodCell.reuseIdentifier
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
        var snapshot = NSDiffableDataSourceSnapshot<Section, WeatherPeriodRow>()
        for forecast in forecasts {
            snapshot.appendSections([forecast.cityName])
            let rows = forecast.periods.enumerated().map {
                WeatherPeriodRow(cityName: forecast.cityName, index: $0.offset, period: $0.element)
            }
            snapshot.appendItems(rows, toSection: forecast.cityName)
        }
        dataSource.apply(snapshot, animatingDifferences: false)
    }

    private func setupLayout() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }

    private func makeDataSource() -> UICollectionViewDiffableDataSource<Section, WeatherPeriodRow> {
        let dataSource = UICollectionViewDiffableDataSource<Section, WeatherPeriodRow>(
            collectionView: collectionView
        ) { collectionView, indexPath, row in
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: WeatherPeriodCell.reuseIdentifier,
                for: indexPath
            )
            (cell as? WeatherPeriodCell)?.configure(with: row)
            return cell
        }

        let headerRegistration = UICollectionView.SupplementaryRegistration<WeatherCityHeaderView>(
            elementKind: WeatherCityHeaderView.elementKind
        ) { [weak dataSource] header, _, indexPath in
            guard let cityName = dataSource?.snapshot().sectionIdentifiers[indexPath.section] else { return }
            header.configure(cityName: cityName)
        }

        dataSource.supplementaryViewProvider = { collectionView, _, indexPath in
            collectionView.dequeueConfiguredReusableSupplementary(using: headerRegistration, for: indexPath)
        }
        return dataSource
    }

    private static func makeLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(120)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let group = NSCollectionLayoutGroup.vertical(layoutSize: itemSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 12
        section.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 0, bottom: 16, trailing: 0)

        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(44)
        )
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: WeatherCityHeaderView.elementKind,
            alignment: .top
        )
        section.boundarySupplementaryItems = [header]
        return UICollectionViewCompositionalLayout(section: section)
    }
}

import UIKit

/// 顯示單一時段預報的 cell（供 diffable collection view 使用）。
final class WeatherPeriodCell: UICollectionViewCell {
    static let reuseIdentifier = "WeatherPeriodCell"

    private let timeLabel = WeatherPeriodCell.makeLabel(size: 13, weight: .semibold, color: .secondaryLabel)
    private let weatherLabel = WeatherPeriodCell.makeLabel(size: 20, weight: .bold, color: .label)
    private let tempLabel = WeatherPeriodCell.makeLabel(size: 16, weight: .regular, color: .label)
    private let detailLabel = WeatherPeriodCell.makeLabel(size: 14, weight: .regular, color: .secondaryLabel)

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupLayout() {
        contentView.backgroundColor = .secondarySystemBackground
        contentView.layer.cornerRadius = 12

        let stack = UIStackView(arrangedSubviews: [timeLabel, weatherLabel, tempLabel, detailLabel])
        stack.axis = .vertical
        stack.spacing = 4
        stack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
        ])
    }

    func configure(with row: WeatherPeriodRow) {
        timeLabel.text = "\(row.startTime) ~ \(row.endTime)"
        weatherLabel.text = row.weatherDescription
        tempLabel.text = "\(row.minTemperature)°C ~ \(row.maxTemperature)°C"
        detailLabel.text = "降雨機率 \(row.rainProbability)%　舒適度 \(row.comfort)"
    }

    private static func makeLabel(
        size: CGFloat,
        weight: UIFont.Weight,
        color: UIColor
    ) -> UILabel {
        let label = UILabel()
        label.font = .systemFont(ofSize: size, weight: weight)
        label.textColor = color
        label.numberOfLines = 0
        return label
    }
}

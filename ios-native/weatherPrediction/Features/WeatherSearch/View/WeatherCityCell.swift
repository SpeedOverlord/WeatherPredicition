import DomainModule
import UIKit

/// 一個縣市 = 一張卡片：靛藍標題列（縣市名 + 今日摘要 + 展開箭頭）+ 展開時三欄天氣。
/// 點標題列展開 / 收合。
final class WeatherCityCell: UICollectionViewCell {
    static let reuseIdentifier = "WeatherCityCell"

    /// 點標題列時呼叫。
    var onToggle: (() -> Void)?

    private let card: UIView = {
        let view = UIView()
        view.backgroundColor = AppColor.cardSurface
        view.layer.cornerRadius = 14
        view.layer.borderWidth = 0.5
        view.clipsToBounds = true
        return view
    }()

    private let headerBar = UIView()
    private let nameLabel = WeatherCityCell.makeLabel(font: AppFont.cityTitle, color: AppColor.textPrimary)
    private let summaryLabel: UILabel = {
        let label = WeatherCityCell.makeLabel(font: AppFont.summary, color: AppColor.textSecondary)
        label.textAlignment = .right
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return label
    }()
    private let chevron: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = AppColor.textSecondary
        imageView.contentMode = .scaleAspectFit
        imageView.setContentHuggingPriority(.required, for: .horizontal)
        return imageView
    }()

    private let bodyContainer = UIView()
    private let columns = [
        WeatherPeriodColumnView(), WeatherPeriodColumnView(), WeatherPeriodColumnView(),
    ]

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
        headerBar.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapHeader)))
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        // layer.borderColor 是靜態 CGColor，明暗切換時需手動更新（背景色為 dynamic 會自動更新）。
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            card.layer.borderColor = AppColor.separator.cgColor
        }
    }

    private func setupLayout() {
        let headerStack = UIStackView(arrangedSubviews: [nameLabel, summaryLabel, chevron])
        headerStack.axis = .horizontal
        headerStack.spacing = 10
        headerStack.alignment = .center
        headerStack.translatesAutoresizingMaskIntoConstraints = false
        headerBar.backgroundColor = AppColor.headerBar
        headerBar.addSubview(headerStack)

        let columnsStack = UIStackView(arrangedSubviews: columns)
        columnsStack.axis = .horizontal
        columnsStack.spacing = 8
        columnsStack.distribution = .fillEqually
        columnsStack.alignment = .fill
        columnsStack.translatesAutoresizingMaskIntoConstraints = false
        bodyContainer.addSubview(columnsStack)

        let cardStack = UIStackView(arrangedSubviews: [headerBar, bodyContainer])
        cardStack.axis = .vertical
        cardStack.spacing = 0
        cardStack.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(cardStack)
        card.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(card)

        NSLayoutConstraint.activate([
            card.topAnchor.constraint(equalTo: contentView.topAnchor),
            card.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            card.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            card.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            cardStack.topAnchor.constraint(equalTo: card.topAnchor),
            cardStack.leadingAnchor.constraint(equalTo: card.leadingAnchor),
            cardStack.trailingAnchor.constraint(equalTo: card.trailingAnchor),
            cardStack.bottomAnchor.constraint(equalTo: card.bottomAnchor),

            headerStack.topAnchor.constraint(equalTo: headerBar.topAnchor, constant: 13),
            headerStack.bottomAnchor.constraint(equalTo: headerBar.bottomAnchor, constant: -13),
            headerStack.leadingAnchor.constraint(equalTo: headerBar.leadingAnchor, constant: 16),
            headerStack.trailingAnchor.constraint(equalTo: headerBar.trailingAnchor, constant: -16),

            columnsStack.topAnchor.constraint(equalTo: bodyContainer.topAnchor, constant: 12),
            columnsStack.leadingAnchor.constraint(equalTo: bodyContainer.leadingAnchor, constant: 12),
            columnsStack.trailingAnchor.constraint(equalTo: bodyContainer.trailingAnchor, constant: -12),
            columnsStack.bottomAnchor.constraint(equalTo: bodyContainer.bottomAnchor, constant: -12),

            chevron.widthAnchor.constraint(equalToConstant: 14),
        ])
    }

    func configure(forecast: WeatherForecastModel, isExpanded: Bool) {
        nameLabel.text = forecast.cityName
        card.layer.borderColor = AppColor.separator.cgColor

        if let first = forecast.periods.first {
            summaryLabel.text = "\(first.weatherDescription) \(first.minTemperature)–\(first.maxTemperature)°"
        } else {
            summaryLabel.text = ""
        }

        chevron.image = UIImage(systemName: isExpanded ? "chevron.down" : "chevron.right")
        bodyContainer.isHidden = !isExpanded

        if isExpanded {
            for (index, column) in columns.enumerated() {
                if index < forecast.periods.count {
                    column.isHidden = false
                    column.configure(with: forecast.periods[index])
                } else {
                    column.isHidden = true
                }
            }
        }
        accessibilityLabel = "\(forecast.cityName)，\(summaryLabel.text ?? "")，\(isExpanded ? "已展開" : "已收合")"
    }

    @objc private func didTapHeader() {
        onToggle?()
    }

    private static func makeLabel(font: UIFont, color: UIColor) -> UILabel {
        let label = UILabel()
        label.font = font
        label.textColor = color
        label.numberOfLines = 0
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        return label
    }
}

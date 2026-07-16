import DomainModule
import UIKit

/// 縣市卡片內的單一時段「欄」，底色依該時段天氣變化。三欄並排方便看變化。
final class WeatherPeriodColumnView: UIView {
    private let iconView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let timeLabel = WeatherPeriodColumnView.makeLabel(font: AppFont.periodTime, color: AppColor.textSecondary)
    private let weatherLabel = WeatherPeriodColumnView.makeLabel(font: AppFont.weather, color: AppColor.textPrimary)
    private let tempLabel = WeatherPeriodColumnView.makeLabel(font: AppFont.temperature, color: AppColor.textPrimary)
    private let rainLabel = WeatherPeriodColumnView.makeLabel(font: AppFont.caption, color: AppColor.textSecondary)
    private let comfortLabel = WeatherPeriodColumnView.makeLabel(font: AppFont.caption, color: AppColor.textSecondary)

    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = 10
        clipsToBounds = true
        setupLayout()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupLayout() {
        let stack = UIStackView(arrangedSubviews: [
            timeLabel, iconView, weatherLabel, tempLabel, rainLabel, comfortLabel,
        ])
        stack.axis = .vertical
        stack.spacing = 4
        stack.alignment = .leading
        stack.setCustomSpacing(8, after: timeLabel)
        stack.setCustomSpacing(8, after: iconView)
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)

        NSLayoutConstraint.activate([
            iconView.widthAnchor.constraint(equalToConstant: 24),
            iconView.heightAnchor.constraint(equalToConstant: 24),
            stack.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12),
        ])
    }

    func configure(with period: WeatherPeriodModel) {
        let category = WeatherStyle.category(for: period.weatherDescription)
        backgroundColor = AppColor.weatherBackground(category)
        iconView.image = UIImage(systemName: WeatherStyle.iconName(for: category))
        iconView.tintColor = AppColor.weatherIcon(category)

        timeLabel.text = "\(period.startTime)\n~ \(period.endTime)"
        weatherLabel.text = period.weatherDescription
        tempLabel.text = "\(period.minTemperature)–\(period.maxTemperature)°C"
        rainLabel.text = "降雨 \(period.rainProbability)%"
        comfortLabel.text = period.comfort
    }

    private static func makeLabel(font: UIFont, color: UIColor) -> UILabel {
        let label = UILabel()
        label.font = font
        label.textColor = color
        label.numberOfLines = 0
        return label
    }
}

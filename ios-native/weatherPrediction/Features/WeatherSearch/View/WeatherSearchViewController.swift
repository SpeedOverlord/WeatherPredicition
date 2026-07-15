import Combine
import UIKit

/// 天氣搜尋主畫面：上方輸入框 + 確認按鈕，下方顯示區塊依狀態切換四種視圖。
final class WeatherSearchViewController: UIViewController {
    private let viewModel: any WeatherSearchViewModelProtocol
    private var cancellables = Set<AnyCancellable>()

    private let textField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "請輸入城市名稱"
        textField.borderStyle = .roundedRect
        textField.clearButtonMode = .whileEditing
        textField.returnKeyType = .search
        return textField
    }()

    private let confirmButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = "確認"
        config.cornerStyle = .medium
        let button = UIButton(configuration: config)
        button.setContentHuggingPriority(.required, for: .horizontal)
        return button
    }()

    private let containerView: UIView = {
        let view = UIView()
        return view
    }()

    private let initialView = WeatherInitialView()
    private let loadingView = WeatherLoadingView()
    private let errorView = WeatherErrorView()
    private let contentView = WeatherContentView()

    init(viewModel: any WeatherSearchViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "天氣預測"
        setupLayout()
        bindViewModel()
    }

    private func setupLayout() {
        let searchStack = UIStackView(arrangedSubviews: [textField, confirmButton])
        searchStack.axis = .horizontal
        searchStack.spacing = 8
        searchStack.alignment = .center

        searchStack.translatesAutoresizingMaskIntoConstraints = false
        containerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(searchStack)
        view.addSubview(containerView)

        let guide = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            searchStack.topAnchor.constraint(equalTo: guide.topAnchor, constant: 12),
            searchStack.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 16),
            searchStack.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -16),

            containerView.topAnchor.constraint(equalTo: searchStack.bottomAnchor, constant: 16),
            containerView.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: guide.bottomAnchor, constant: -16),
        ])

        confirmButton.addTarget(self, action: #selector(didTapConfirm), for: .touchUpInside)
        textField.addTarget(self, action: #selector(didTapConfirm), for: .editingDidEndOnExit)
    }

    private func bindViewModel() {
        viewModel.statePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.render(state)
            }
            .store(in: &cancellables)
    }

    @objc private func didTapConfirm() {
        view.endEditing(true)
        let input = textField.text ?? ""
        Task { [weak self] in
            await self?.viewModel.search(cityName: input)
        }
    }

    private func render(_ state: WeatherSearchState) {
        let activeView: UIView
        switch state {
        case .initial:
            activeView = initialView
        case .loading:
            activeView = loadingView
        case .loaded(let forecasts):
            contentView.configure(with: forecasts)
            activeView = contentView
        case .error(let message):
            errorView.configure(message: message)
            activeView = errorView
        }
        showContainerSubview(activeView)
    }

    private func showContainerSubview(_ subview: UIView) {
        guard subview.superview !== containerView else { return }
        containerView.subviews.forEach { $0.removeFromSuperview() }
        subview.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(subview)
        NSLayoutConstraint.activate([
            subview.topAnchor.constraint(equalTo: containerView.topAnchor),
            subview.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            subview.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            subview.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
        ])
    }
}

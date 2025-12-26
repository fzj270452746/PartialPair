//
//  ObsidianConfigViewController.swift
//  PartialPair
//
//  Created by Zhao on 2025/12/21.
//

import UIKit

class ObsidianConfigViewController: UIViewController {

    // MARK: - Properties

    private var backgroundImageView: UIImageView!
    private var overlayView: UIView!
    private var headerView: UIView!
    private var backButton: UIButton!
    private var titleLabel: UILabel!
    private var scrollView: UIScrollView!
    private var contentStackView: UIStackView!

    // Settings cards
    private var tilesSlider: UISlider!
    private var tilesValueLabel: UILabel!
    private var tilesPreviewStackView: UIStackView!

    private let prismManager = ObsidianPrismManager.shared

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackgroundImage()
        setupOverlayView()
        setupHeaderView()
        setupScrollView()
        setupSettingsCards()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    // MARK: - Setup Methods

    private func setupBackgroundImage() {
        backgroundImageView = UIImageView()
        backgroundImageView.image = UIImage(named: "ppimage")
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.clipsToBounds = true
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(backgroundImageView)

        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func setupOverlayView() {
        overlayView = UIView()
        overlayView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(overlayView)

        NSLayoutConstraint.activate([
            overlayView.topAnchor.constraint(equalTo: view.topAnchor),
            overlayView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            overlayView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            overlayView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateOverlayGradient()
    }

    private func updateOverlayGradient() {
        overlayView.layer.sublayers?.removeAll(where: { $0 is CAGradientLayer })

        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor(red: 0.05, green: 0.05, blue: 0.12, alpha: 0.92).cgColor,
            UIColor(red: 0.08, green: 0.06, blue: 0.15, alpha: 0.88).cgColor
        ]
        gradientLayer.frame = overlayView.bounds
        overlayView.layer.addSublayer(gradientLayer)
    }

    private func setupHeaderView() {
        headerView = UIView()
        headerView.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.15, alpha: 0.95)
        headerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(headerView)

        backButton = UIButton(type: .system)
        backButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        backButton.tintColor = .white
        backButton.backgroundColor = UIColor.white.withAlphaComponent(0.15)
        backButton.layer.cornerRadius = 18
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        headerView.addSubview(backButton)

        let iconView = UIImageView()
        iconView.image = UIImage(systemName: "gearshape.fill")
        iconView.tintColor = UIColor(red: 0.6, green: 0.7, blue: 0.9, alpha: 1.0)
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(iconView)

        titleLabel = UILabel()
        titleLabel.text = "Settings"
        titleLabel.textColor = .white
        titleLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 100),

            backButton.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20),
            backButton.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -15),
            backButton.widthAnchor.constraint(equalToConstant: 36),
            backButton.heightAnchor.constraint(equalToConstant: 36),

            iconView.leadingAnchor.constraint(equalTo: backButton.trailingAnchor, constant: 16),
            iconView.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 24),
            iconView.heightAnchor.constraint(equalToConstant: 24),

            titleLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 10),
            titleLabel.centerYAnchor.constraint(equalTo: backButton.centerYAnchor)
        ])
    }

    private func setupScrollView() {
        scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)

        contentStackView = UIStackView()
        contentStackView.axis = .vertical
        contentStackView.spacing = 20
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentStackView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentStackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
            contentStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            contentStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
            contentStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -30),
            contentStackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -40)
        ])
    }

    private func setupSettingsCards() {
        // Section header - Game Settings
        let gameSettingsHeader = createSectionHeader(title: "GAME SETTINGS")
        contentStackView.addArrangedSubview(gameSettingsHeader)

        // Tiles count card
        let tilesCard = createTilesCountCard()
        contentStackView.addArrangedSubview(tilesCard)

        // Section header - About
        let aboutHeader = createSectionHeader(title: "ABOUT")
        contentStackView.addArrangedSubview(aboutHeader)

        // About card
        let aboutCard = createAboutCard()
        contentStackView.addArrangedSubview(aboutCard)

        // Tips card
        let tipsCard = createTipsCard()
        contentStackView.addArrangedSubview(tipsCard)

        // Animate entrance
        animateCardsEntrance()
    }

    private func createSectionHeader(title: String) -> UIView {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false

        let label = UILabel()
        label.text = title
        label.textColor = UIColor.white.withAlphaComponent(0.5)
        label.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(label)

        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 4),
            label.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10),
            label.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])

        return containerView
    }

    private func createTilesCountCard() -> UIView {
        let cardView = UIView()
        cardView.backgroundColor = UIColor(red: 0.15, green: 0.13, blue: 0.2, alpha: 0.95)
        cardView.layer.cornerRadius = 20
        cardView.layer.borderWidth = 1
        cardView.layer.borderColor = UIColor(red: 0.4, green: 0.6, blue: 0.9, alpha: 0.3).cgColor
        cardView.translatesAutoresizingMaskIntoConstraints = false

        // Header section
        let headerSection = UIView()
        headerSection.backgroundColor = UIColor(red: 0.3, green: 0.6, blue: 0.9, alpha: 0.15)
        headerSection.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(headerSection)

        // Icon
        let iconContainer = UIView()
        iconContainer.backgroundColor = UIColor(red: 0.3, green: 0.6, blue: 0.9, alpha: 0.3)
        iconContainer.layer.cornerRadius = 20
        iconContainer.translatesAutoresizingMaskIntoConstraints = false
        headerSection.addSubview(iconContainer)

        let iconImageView = UIImageView()
        iconImageView.image = UIImage(systemName: "square.grid.3x3.fill")
        iconImageView.tintColor = UIColor(red: 0.4, green: 0.7, blue: 1.0, alpha: 1.0)
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconContainer.addSubview(iconImageView)

        // Title
        let titleLabel = UILabel()
        titleLabel.text = "Tiles Per Game"
        titleLabel.textColor = .white
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        headerSection.addSubview(titleLabel)

        // Value label
        tilesValueLabel = UILabel()
        tilesValueLabel.text = "\(prismManager.getQuartzPerArena())"
        tilesValueLabel.textColor = UIColor(red: 0.4, green: 0.7, blue: 1.0, alpha: 1.0)
        tilesValueLabel.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        tilesValueLabel.textAlignment = .center
        tilesValueLabel.translatesAutoresizingMaskIntoConstraints = false
        headerSection.addSubview(tilesValueLabel)

        // Slider section
        let sliderSection = UIView()
        sliderSection.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(sliderSection)

        // Min label
        let minLabel = UILabel()
        minLabel.text = "\(prismManager.minQuartz)"
        minLabel.textColor = UIColor.white.withAlphaComponent(0.5)
        minLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        minLabel.translatesAutoresizingMaskIntoConstraints = false
        sliderSection.addSubview(minLabel)

        // Max label
        let maxLabel = UILabel()
        maxLabel.text = "\(prismManager.maxQuartz)"
        maxLabel.textColor = UIColor.white.withAlphaComponent(0.5)
        maxLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        maxLabel.textAlignment = .right
        maxLabel.translatesAutoresizingMaskIntoConstraints = false
        sliderSection.addSubview(maxLabel)

        // Slider
        tilesSlider = UISlider()
        tilesSlider.minimumValue = Float(prismManager.minQuartz)
        tilesSlider.maximumValue = Float(prismManager.maxQuartz)
        tilesSlider.value = Float(prismManager.getQuartzPerArena())
        tilesSlider.minimumTrackTintColor = UIColor(red: 0.4, green: 0.7, blue: 1.0, alpha: 1.0)
        tilesSlider.maximumTrackTintColor = UIColor.white.withAlphaComponent(0.2)
        tilesSlider.thumbTintColor = .white
        tilesSlider.translatesAutoresizingMaskIntoConstraints = false
        tilesSlider.addTarget(self, action: #selector(sliderValueChanged(_:)), for: .valueChanged)
        sliderSection.addSubview(tilesSlider)

        // Preview section
        let previewSection = UIView()
        previewSection.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(previewSection)

        let previewLabel = UILabel()
        previewLabel.text = "Grid Preview"
        previewLabel.textColor = UIColor.white.withAlphaComponent(0.5)
        previewLabel.font = UIFont.systemFont(ofSize: 11, weight: .medium)
        previewLabel.translatesAutoresizingMaskIntoConstraints = false
        previewSection.addSubview(previewLabel)

        tilesPreviewStackView = UIStackView()
        tilesPreviewStackView.axis = .horizontal
        tilesPreviewStackView.spacing = 4
        tilesPreviewStackView.alignment = .center
        tilesPreviewStackView.translatesAutoresizingMaskIntoConstraints = false
        previewSection.addSubview(tilesPreviewStackView)

        updateTilesPreview()

        // Description
        let descLabel = UILabel()
        descLabel.text = "Adjust the number of tiles displayed in each game. More tiles = longer games!"
        descLabel.textColor = UIColor.white.withAlphaComponent(0.6)
        descLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        descLabel.numberOfLines = 0
        descLabel.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(descLabel)

        // Round corners for header section
        DispatchQueue.main.async {
            let maskPath = UIBezierPath(
                roundedRect: headerSection.bounds,
                byRoundingCorners: [.topLeft, .topRight],
                cornerRadii: CGSize(width: 20, height: 20)
            )
            let maskLayer = CAShapeLayer()
            maskLayer.path = maskPath.cgPath
            headerSection.layer.mask = maskLayer
        }

        NSLayoutConstraint.activate([
            cardView.heightAnchor.constraint(greaterThanOrEqualToConstant: 280),

            headerSection.topAnchor.constraint(equalTo: cardView.topAnchor),
            headerSection.leadingAnchor.constraint(equalTo: cardView.leadingAnchor),
            headerSection.trailingAnchor.constraint(equalTo: cardView.trailingAnchor),
            headerSection.heightAnchor.constraint(equalToConstant: 70),

            iconContainer.leadingAnchor.constraint(equalTo: headerSection.leadingAnchor, constant: 16),
            iconContainer.centerYAnchor.constraint(equalTo: headerSection.centerYAnchor),
            iconContainer.widthAnchor.constraint(equalToConstant: 40),
            iconContainer.heightAnchor.constraint(equalToConstant: 40),

            iconImageView.centerXAnchor.constraint(equalTo: iconContainer.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 20),
            iconImageView.heightAnchor.constraint(equalToConstant: 20),

            titleLabel.leadingAnchor.constraint(equalTo: iconContainer.trailingAnchor, constant: 12),
            titleLabel.centerYAnchor.constraint(equalTo: headerSection.centerYAnchor),

            tilesValueLabel.trailingAnchor.constraint(equalTo: headerSection.trailingAnchor, constant: -20),
            tilesValueLabel.centerYAnchor.constraint(equalTo: headerSection.centerYAnchor),

            sliderSection.topAnchor.constraint(equalTo: headerSection.bottomAnchor, constant: 20),
            sliderSection.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
            sliderSection.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20),

            minLabel.leadingAnchor.constraint(equalTo: sliderSection.leadingAnchor),
            minLabel.topAnchor.constraint(equalTo: sliderSection.topAnchor),

            maxLabel.trailingAnchor.constraint(equalTo: sliderSection.trailingAnchor),
            maxLabel.topAnchor.constraint(equalTo: sliderSection.topAnchor),

            tilesSlider.topAnchor.constraint(equalTo: minLabel.bottomAnchor, constant: 8),
            tilesSlider.leadingAnchor.constraint(equalTo: sliderSection.leadingAnchor),
            tilesSlider.trailingAnchor.constraint(equalTo: sliderSection.trailingAnchor),
            tilesSlider.bottomAnchor.constraint(equalTo: sliderSection.bottomAnchor),

            previewSection.topAnchor.constraint(equalTo: sliderSection.bottomAnchor, constant: 20),
            previewSection.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
            previewSection.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20),

            previewLabel.leadingAnchor.constraint(equalTo: previewSection.leadingAnchor),
            previewLabel.topAnchor.constraint(equalTo: previewSection.topAnchor),

            tilesPreviewStackView.topAnchor.constraint(equalTo: previewLabel.bottomAnchor, constant: 10),
            tilesPreviewStackView.centerXAnchor.constraint(equalTo: previewSection.centerXAnchor),
            tilesPreviewStackView.bottomAnchor.constraint(equalTo: previewSection.bottomAnchor),
            tilesPreviewStackView.heightAnchor.constraint(equalToConstant: 40),

            descLabel.topAnchor.constraint(equalTo: previewSection.bottomAnchor, constant: 16),
            descLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
            descLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20),
            descLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -20)
        ])

        return cardView
    }

    private func updateTilesPreview() {
        tilesPreviewStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        let count = prismManager.getQuartzPerArena()
        let rows = (count + 4) / 5
        let columns = 5

        for row in 0..<rows {
            let rowStack = UIStackView()
            rowStack.axis = .horizontal
            rowStack.spacing = 3
            rowStack.translatesAutoresizingMaskIntoConstraints = false

            for col in 0..<columns {
                let index = row * columns + col
                let tileView = UIView()
                tileView.backgroundColor = index < count ?
                    UIColor(red: 0.4, green: 0.7, blue: 1.0, alpha: 0.8) :
                    UIColor.white.withAlphaComponent(0.1)
                tileView.layer.cornerRadius = 2
                tileView.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    tileView.widthAnchor.constraint(equalToConstant: 8),
                    tileView.heightAnchor.constraint(equalToConstant: 10)
                ])
                rowStack.addArrangedSubview(tileView)
            }

            tilesPreviewStackView.addArrangedSubview(rowStack)
        }
    }

    private func createAboutCard() -> UIView {
        let cardView = UIView()
        cardView.backgroundColor = UIColor(red: 0.15, green: 0.13, blue: 0.2, alpha: 0.95)
        cardView.layer.cornerRadius = 16
        cardView.layer.borderWidth = 1
        cardView.layer.borderColor = UIColor.white.withAlphaComponent(0.1).cgColor
        cardView.translatesAutoresizingMaskIntoConstraints = false

        // App icon placeholder
        let iconContainer = UIView()
        iconContainer.backgroundColor = UIColor(red: 0.8, green: 0.4, blue: 0.6, alpha: 0.3)
        iconContainer.layer.cornerRadius = 16
        iconContainer.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(iconContainer)

        let iconImageView = UIImageView()
        iconImageView.image = UIImage(systemName: "square.grid.3x3.topleft.filled")
        iconImageView.tintColor = UIColor(red: 0.9, green: 0.5, blue: 0.7, alpha: 1.0)
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconContainer.addSubview(iconImageView)

        // App name
        let appNameLabel = UILabel()
        appNameLabel.text = "Mahjong Partial Pair"
        appNameLabel.textColor = .white
        appNameLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        appNameLabel.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(appNameLabel)

        // Version
        let versionLabel = UILabel()
        versionLabel.text = "Version 1.0.0"
        versionLabel.textColor = UIColor.white.withAlphaComponent(0.5)
        versionLabel.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        versionLabel.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(versionLabel)

        // Description
        let descLabel = UILabel()
        descLabel.text = "A challenging mahjong tile matching game that tests your observation skills with partially hidden tiles."
        descLabel.textColor = UIColor.white.withAlphaComponent(0.7)
        descLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        descLabel.numberOfLines = 0
        descLabel.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(descLabel)

        NSLayoutConstraint.activate([
            iconContainer.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 16),
            iconContainer.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            iconContainer.widthAnchor.constraint(equalToConstant: 50),
            iconContainer.heightAnchor.constraint(equalToConstant: 50),

            iconImageView.centerXAnchor.constraint(equalTo: iconContainer.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 28),
            iconImageView.heightAnchor.constraint(equalToConstant: 28),

            appNameLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 18),
            appNameLabel.leadingAnchor.constraint(equalTo: iconContainer.trailingAnchor, constant: 14),

            versionLabel.topAnchor.constraint(equalTo: appNameLabel.bottomAnchor, constant: 4),
            versionLabel.leadingAnchor.constraint(equalTo: iconContainer.trailingAnchor, constant: 14),

            descLabel.topAnchor.constraint(equalTo: iconContainer.bottomAnchor, constant: 14),
            descLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            descLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            descLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -16)
        ])

        return cardView
    }

    private func createTipsCard() -> UIView {
        let cardView = UIView()
        cardView.backgroundColor = UIColor(red: 0.15, green: 0.13, blue: 0.2, alpha: 0.95)
        cardView.layer.cornerRadius = 16
        cardView.layer.borderWidth = 1
        cardView.layer.borderColor = UIColor(red: 1.0, green: 0.8, blue: 0.3, alpha: 0.2).cgColor
        cardView.translatesAutoresizingMaskIntoConstraints = false

        let iconImageView = UIImageView()
        iconImageView.image = UIImage(systemName: "lightbulb.fill")
        iconImageView.tintColor = UIColor(red: 1.0, green: 0.8, blue: 0.3, alpha: 1.0)
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(iconImageView)

        let titleLabel = UILabel()
        titleLabel.text = "Pro Tip"
        titleLabel.textColor = UIColor(red: 1.0, green: 0.8, blue: 0.3, alpha: 1.0)
        titleLabel.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(titleLabel)

        let tipLabel = UILabel()
        tipLabel.text = "Start with fewer tiles to learn the patterns, then increase the count for a greater challenge!"
        tipLabel.textColor = UIColor.white.withAlphaComponent(0.8)
        tipLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        tipLabel.numberOfLines = 0
        tipLabel.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(tipLabel)

        NSLayoutConstraint.activate([
            iconImageView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 16),
            iconImageView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            iconImageView.widthAnchor.constraint(equalToConstant: 20),
            iconImageView.heightAnchor.constraint(equalToConstant: 20),

            titleLabel.centerYAnchor.constraint(equalTo: iconImageView.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 8),

            tipLabel.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: 10),
            tipLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            tipLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            tipLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -16)
        ])

        return cardView
    }

    private func animateCardsEntrance() {
        for (index, view) in contentStackView.arrangedSubviews.enumerated() {
            view.alpha = 0
            view.transform = CGAffineTransform(translationX: 0, y: 30)

            UIView.animate(withDuration: 0.5, delay: Double(index) * 0.1, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5) {
                view.alpha = 1
                view.transform = .identity
            }
        }
    }

    // MARK: - Actions

    @objc private func sliderValueChanged(_ sender: UISlider) {
        let newValue = Int(sender.value)
        prismManager.setQuartzPerArena(newValue)
        tilesValueLabel.text = "\(newValue)"
        updateTilesPreview()

        // Haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }

    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }

}

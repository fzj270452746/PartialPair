//
//  ObsidianUIFactory.swift
//  PartialPair
//
//  Created by Zhao on 2025/12/21.
//  Refactored: UI component factory
//

import UIKit

// MARK: - Theme Colors

struct ObsidianThemeColors {
    // Primary colors
    static let primaryBlue = UIColor(red: 0.3, green: 0.6, blue: 0.9, alpha: 1.0)
    static let primaryPink = UIColor(red: 0.8, green: 0.4, blue: 0.6, alpha: 1.0)
    static let primaryGold = UIColor(red: 1.0, green: 0.8, blue: 0.3, alpha: 1.0)
    static let primaryGreen = UIColor(red: 0.4, green: 0.8, blue: 0.6, alpha: 1.0)

    // Background colors
    static let darkBackground = UIColor(red: 0.05, green: 0.05, blue: 0.12, alpha: 1.0)
    static let cardBackground = UIColor(red: 0.15, green: 0.13, blue: 0.2, alpha: 0.95)
    static let headerBackground = UIColor(red: 0.1, green: 0.1, blue: 0.15, alpha: 0.95)

    // Text colors
    static let primaryText = UIColor.white
    static let secondaryText = UIColor.white.withAlphaComponent(0.7)
    static let tertiaryText = UIColor.white.withAlphaComponent(0.5)

    // Status colors
    static let successColor = UIColor(red: 0.4, green: 0.9, blue: 0.5, alpha: 1.0)
    static let errorColor = UIColor(red: 0.9, green: 0.3, blue: 0.3, alpha: 1.0)
    static let warningColor = UIColor(red: 1.0, green: 0.7, blue: 0.3, alpha: 1.0)

    // Border colors
    static let cardBorder = UIColor.white.withAlphaComponent(0.1)
    static let glowBorder = UIColor.white.withAlphaComponent(0.15)

    // Mode-specific colors
    static func colorForMode(_ mode: ObsidianGameMode) -> UIColor {
        switch mode {
        case .classic:
            return primaryBlue
        case .challenge:
            return primaryPink
        }
    }
}

// MARK: - UI Factory Protocol

protocol ObsidianUIFactoryProtocol {
    func createBackgroundImageView() -> UIImageView
    func createGradientOverlay() -> UIView
    func createHeaderView() -> UIView
    func createBackButton(target: Any?, action: Selector) -> UIButton
    func createStatCard(title: String, value: String, iconName: String, color: UIColor) -> (UIView, UILabel)
    func createProgressBar() -> (container: UIView, bar: UIView, fill: UIView, label: UILabel)
}

extension ObsidianUIFactoryProtocol {
    func createBackgroundImageView() -> UIImageView {
        return (self as! ObsidianUIFactory).createBackgroundImageView(imageName: "ppimage")
    }
}

// MARK: - UI Factory Implementation

class ObsidianUIFactory {

    // MARK: - Singleton

    static let shared = ObsidianUIFactory()

    private init() {}

    // MARK: - Background Components

    func createBackgroundImageView(imageName: String = "ppimage") -> UIImageView {
        let imageView = UIImageView()
        imageView.image = UIImage(named: imageName)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }

    func createGradientOverlay(colors: [UIColor]? = nil) -> UIView {
        let overlayView = ObsidianGradientView()
        overlayView.translatesAutoresizingMaskIntoConstraints = false

        let defaultColors = colors ?? [
            UIColor(red: 0.05, green: 0.05, blue: 0.15, alpha: 0.85),
            UIColor(red: 0.1, green: 0.08, blue: 0.2, alpha: 0.7),
            UIColor(red: 0.15, green: 0.1, blue: 0.25, alpha: 0.8)
        ]
        overlayView.gradientColors = defaultColors.map { $0.cgColor }
        overlayView.gradientLocations = [0.0, 0.5, 1.0]

        return overlayView
    }

    func createMistOverlay() -> UIView {
        let overlayView = ObsidianGradientView()
        overlayView.translatesAutoresizingMaskIntoConstraints = false

        overlayView.gradientColors = [
            UIColor(red: 0.08, green: 0.06, blue: 0.15, alpha: 0.9).cgColor,
            UIColor(red: 0.1, green: 0.08, blue: 0.18, alpha: 0.85).cgColor
        ]

        return overlayView
    }

    // MARK: - Header Components

    func createHeaderView() -> UIView {
        let headerView = UIView()
        headerView.backgroundColor = ObsidianThemeColors.headerBackground
        headerView.translatesAutoresizingMaskIntoConstraints = false
        return headerView
    }

    func createBackButton(target: Any?, action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        button.tintColor = .white
        button.backgroundColor = UIColor.white.withAlphaComponent(0.15)
        button.layer.cornerRadius = 18
        button.translatesAutoresizingMaskIntoConstraints = false
        if let target = target {
            button.addTarget(target, action: action, for: .touchUpInside)
        }
        return button
    }

    func createCloseButton(target: Any?, action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.tintColor = .white
        button.backgroundColor = UIColor.white.withAlphaComponent(0.15)
        button.layer.cornerRadius = 18
        button.translatesAutoresizingMaskIntoConstraints = false
        if let target = target {
            button.addTarget(target, action: action, for: .touchUpInside)
        }
        return button
    }

    func createTitleLabel(text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }

    func createHeaderIcon(systemName: String, color: UIColor) -> UIImageView {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: systemName)
        imageView.tintColor = color
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }

    // MARK: - Stat Card Components

    func createStatCard(title: String, value: String, iconName: String, color: UIColor) -> (UIView, UILabel) {
        let cardView = UIView()
        cardView.backgroundColor = ObsidianThemeColors.cardBackground
        cardView.layer.cornerRadius = 16
        cardView.layer.borderWidth = 1
        cardView.layer.borderColor = color.withAlphaComponent(0.3).cgColor
        cardView.translatesAutoresizingMaskIntoConstraints = false

        // Glow effect
        cardView.layer.shadowColor = color.cgColor
        cardView.layer.shadowRadius = 8
        cardView.layer.shadowOpacity = 0.2
        cardView.layer.shadowOffset = .zero

        let iconView = UIImageView()
        iconView.image = UIImage(systemName: iconName)
        iconView.tintColor = color
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(iconView)

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.textColor = ObsidianThemeColors.tertiaryText
        titleLabel.font = UIFont.systemFont(ofSize: 9, weight: .bold)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(titleLabel)

        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.textColor = .white
        valueLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(valueLabel)

        NSLayoutConstraint.activate([
            iconView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            iconView.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 22),
            iconView.heightAnchor.constraint(equalToConstant: 22),

            titleLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 8),

            valueLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2),
            valueLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 8)
        ])

        return (cardView, valueLabel)
    }

    func createStatsContainer() -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 12
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }

    // MARK: - Progress Bar Components

    func createProgressBar() -> (container: UIView, bar: UIView, fill: UIView, label: UILabel) {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false

        let progressBar = UIView()
        progressBar.backgroundColor = UIColor.white.withAlphaComponent(0.15)
        progressBar.layer.cornerRadius = 4
        progressBar.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(progressBar)

        let progressFill = UIView()
        progressFill.backgroundColor = ObsidianThemeColors.primaryGreen
        progressFill.layer.cornerRadius = 4
        progressFill.translatesAutoresizingMaskIntoConstraints = false
        progressBar.addSubview(progressFill)

        let matchCountLabel = UILabel()
        matchCountLabel.text = "0 / 0 pairs"
        matchCountLabel.textColor = ObsidianThemeColors.secondaryText
        matchCountLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        matchCountLabel.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(matchCountLabel)

        NSLayoutConstraint.activate([
            progressBar.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            progressBar.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            progressBar.trailingAnchor.constraint(equalTo: matchCountLabel.leadingAnchor, constant: -12),
            progressBar.heightAnchor.constraint(equalToConstant: 8),

            progressFill.leadingAnchor.constraint(equalTo: progressBar.leadingAnchor),
            progressFill.topAnchor.constraint(equalTo: progressBar.topAnchor),
            progressFill.bottomAnchor.constraint(equalTo: progressBar.bottomAnchor),
            progressFill.widthAnchor.constraint(equalToConstant: 0),

            matchCountLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            matchCountLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ])

        return (container, progressBar, progressFill, matchCountLabel)
    }

    // MARK: - Mode Indicator

    func createModeIndicator(mode: ObsidianGameMode) -> UIView {
        let indicatorView = UIView()
        indicatorView.layer.cornerRadius = 12
        indicatorView.translatesAutoresizingMaskIntoConstraints = false

        let modeColor = ObsidianThemeColors.colorForMode(mode)
        indicatorView.backgroundColor = modeColor.withAlphaComponent(0.3)

        let modeIcon = UIImageView()
        modeIcon.image = UIImage(systemName: mode.iconName)
        modeIcon.tintColor = modeColor
        modeIcon.contentMode = .scaleAspectFit
        modeIcon.translatesAutoresizingMaskIntoConstraints = false
        indicatorView.addSubview(modeIcon)

        let modeLabel = UILabel()
        modeLabel.text = mode.name
        modeLabel.textColor = .white
        modeLabel.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        modeLabel.translatesAutoresizingMaskIntoConstraints = false
        indicatorView.addSubview(modeLabel)

        NSLayoutConstraint.activate([
            modeIcon.leadingAnchor.constraint(equalTo: indicatorView.leadingAnchor, constant: 10),
            modeIcon.centerYAnchor.constraint(equalTo: indicatorView.centerYAnchor),
            modeIcon.widthAnchor.constraint(equalToConstant: 16),
            modeIcon.heightAnchor.constraint(equalToConstant: 16),

            modeLabel.leadingAnchor.constraint(equalTo: modeIcon.trailingAnchor, constant: 6),
            modeLabel.centerYAnchor.constraint(equalTo: indicatorView.centerYAnchor),
            modeLabel.trailingAnchor.constraint(equalTo: indicatorView.trailingAnchor, constant: -12)
        ])

        return indicatorView
    }

    // MARK: - Combo Label

    func createComboLabel() -> UILabel {
        let label = UILabel()
        label.textColor = ObsidianThemeColors.primaryGold
        label.font = UIFont.systemFont(ofSize: 28, weight: .black)
        label.textAlignment = .center
        label.alpha = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }

    // MARK: - Card Components

    func createCard(cornerRadius: CGFloat = 16, borderColor: UIColor? = nil) -> UIView {
        let cardView = UIView()
        cardView.backgroundColor = ObsidianThemeColors.cardBackground
        cardView.layer.cornerRadius = cornerRadius
        cardView.layer.borderWidth = 1
        cardView.layer.borderColor = (borderColor ?? ObsidianThemeColors.cardBorder).cgColor
        cardView.translatesAutoresizingMaskIntoConstraints = false
        return cardView
    }

    func createSectionHeader(title: String) -> UIView {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false

        let label = UILabel()
        label.text = title
        label.textColor = ObsidianThemeColors.tertiaryText
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

    // MARK: - Button Components

    func createPrimaryButton(title: String, color: UIColor, target: Any?, action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        button.backgroundColor = color
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        if let target = target {
            button.addTarget(target, action: action, for: .touchUpInside)
        }
        return button
    }

    func createDangerButton(title: String, target: Any?, action: Selector) -> UIButton {
        return createPrimaryButton(
            title: title,
            color: ObsidianThemeColors.errorColor,
            target: target,
            action: action
        )
    }

    // MARK: - Empty State View

    func createEmptyStateView(iconName: String, title: String, subtitle: String) -> UIView {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false

        let iconView = UIImageView()
        iconView.image = UIImage(systemName: iconName)
        iconView.tintColor = UIColor.white.withAlphaComponent(0.3)
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(iconView)

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.textColor = ObsidianThemeColors.primaryText.withAlphaComponent(0.8)
        titleLabel.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(titleLabel)

        let subtitleLabel = UILabel()
        subtitleLabel.text = subtitle
        subtitleLabel.textColor = ObsidianThemeColors.tertiaryText
        subtitleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        subtitleLabel.textAlignment = .center
        subtitleLabel.numberOfLines = 2
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(subtitleLabel)

        NSLayoutConstraint.activate([
            iconView.topAnchor.constraint(equalTo: containerView.topAnchor),
            iconView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 60),
            iconView.heightAnchor.constraint(equalToConstant: 60),

            titleLabel.topAnchor.constraint(equalTo: iconView.bottomAnchor, constant: 16),
            titleLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            subtitleLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])

        return containerView
    }

    // MARK: - Game Container

    func createGameContainer() -> (background: UIView, container: UIView) {
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor(red: 0.12, green: 0.1, blue: 0.18, alpha: 0.9)
        backgroundView.layer.cornerRadius = 20
        backgroundView.layer.borderWidth = 1
        backgroundView.layer.borderColor = ObsidianThemeColors.cardBorder.cgColor
        backgroundView.translatesAutoresizingMaskIntoConstraints = false

        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false

        return (backgroundView, containerView)
    }

    // MARK: - Spark Effect

    func createSparkEmitterLayer(width: CGFloat) -> CAEmitterLayer {
        let emitterLayer = CAEmitterLayer()
        emitterLayer.emitterPosition = CGPoint(x: width / 2, y: -50)
        emitterLayer.emitterSize = CGSize(width: width, height: 1)
        emitterLayer.emitterShape = .line

        let cell = CAEmitterCell()
        cell.birthRate = 2
        cell.lifetime = 12
        cell.velocity = 30
        cell.velocityRange = 20
        cell.emissionLongitude = .pi
        cell.emissionRange = .pi / 4
        cell.scale = 0.08
        cell.scaleRange = 0.04
        cell.alphaSpeed = -0.05
        cell.contents = createSparkImage()?.cgImage

        emitterLayer.emitterCells = [cell]
        return emitterLayer
    }

    private func createSparkImage() -> UIImage? {
        let size = CGSize(width: 30, height: 30)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }

        let gradient = CGGradient(
            colorsSpace: CGColorSpaceCreateDeviceRGB(),
            colors: [UIColor.white.cgColor, UIColor.clear.cgColor] as CFArray,
            locations: [0, 1]
        )!

        context.drawRadialGradient(
            gradient,
            startCenter: CGPoint(x: 15, y: 15),
            startRadius: 0,
            endCenter: CGPoint(x: 15, y: 15),
            endRadius: 15,
            options: []
        )

        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}

// MARK: - Gradient View (Auto-resizing)

class ObsidianGradientView: UIView {

    var gradientColors: [CGColor] = [] {
        didSet {
            updateGradient()
        }
    }

    var gradientLocations: [NSNumber]? {
        didSet {
            updateGradient()
        }
    }

    private var gradientLayer: CAGradientLayer?

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer?.frame = bounds
    }

    private func updateGradient() {
        gradientLayer?.removeFromSuperlayer()

        let gradient = CAGradientLayer()
        gradient.colors = gradientColors
        gradient.locations = gradientLocations
        gradient.frame = bounds
        layer.insertSublayer(gradient, at: 0)

        gradientLayer = gradient
    }
}

//
//  ObsidianScrollViewController.swift
//  PartialPair
//
//  Created by Zhao on 2025/12/21.
//

import UIKit

class ObsidianScrollViewController: UIViewController {

    // MARK: - Properties

    private var backgroundImageView: UIImageView!
    private var overlayView: UIView!
    private var headerView: UIView!
    private var backButton: UIButton!
    private var titleLabel: UILabel!
    private var scrollView: UIScrollView!
    private var contentStackView: UIStackView!

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackgroundImage()
        setupOverlayView()
        setupHeaderView()
        setupScrollView()
        setupInstructionCards()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateOverlayGradient()
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

        // Back button
        backButton = UIButton(type: .system)
        backButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        backButton.tintColor = .white
        backButton.backgroundColor = UIColor.white.withAlphaComponent(0.15)
        backButton.layer.cornerRadius = 18
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        headerView.addSubview(backButton)

        // Title
        titleLabel = UILabel()
        titleLabel.text = "How to Play"
        titleLabel.textColor = .white
        titleLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(titleLabel)

        // Book icon
        let iconView = UIImageView()
        iconView.image = UIImage(systemName: "book.fill")
        iconView.tintColor = UIColor(red: 0.4, green: 0.7, blue: 1.0, alpha: 1.0)
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(iconView)

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

    private func setupInstructionCards() {
        // Welcome Card
        let welcomeCard = createInstructionCard(
            title: "Welcome to Mahjong Partial Pair",
            content: "Test your observation skills by matching partially hidden mahjong tiles. The challenge lies in identifying tiles even when parts are concealed!",
            iconName: "sparkles",
            iconColor: UIColor(red: 1.0, green: 0.8, blue: 0.3, alpha: 1.0),
            isHighlighted: true
        )
        contentStackView.addArrangedSubview(welcomeCard)

        // Objective Card
        let objectiveCard = createInstructionCard(
            title: "Objective",
            content: "Find and match pairs of identical mahjong tiles hidden in the game board. Clear all tiles to advance to the next round!",
            iconName: "target",
            iconColor: UIColor(red: 0.4, green: 0.8, blue: 0.6, alpha: 1.0),
            isHighlighted: false
        )
        contentStackView.addArrangedSubview(objectiveCard)

        // Game Modes Section Header
        let modesHeaderLabel = UILabel()
        modesHeaderLabel.text = "GAME MODES"
        modesHeaderLabel.textColor = UIColor.white.withAlphaComponent(0.5)
        modesHeaderLabel.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        modesHeaderLabel.translatesAutoresizingMaskIntoConstraints = false
        let modesHeaderContainer = UIView()
        modesHeaderContainer.addSubview(modesHeaderLabel)
        NSLayoutConstraint.activate([
            modesHeaderLabel.leadingAnchor.constraint(equalTo: modesHeaderContainer.leadingAnchor, constant: 4),
            modesHeaderLabel.topAnchor.constraint(equalTo: modesHeaderContainer.topAnchor, constant: 10),
            modesHeaderLabel.bottomAnchor.constraint(equalTo: modesHeaderContainer.bottomAnchor)
        ])
        contentStackView.addArrangedSubview(modesHeaderContainer)

        // Classic Mode Card
        let classicCard = createModeCard(
            title: "Classic Mode",
            subtitle: "BEGINNER FRIENDLY",
            features: [
                "Tiles are partially hidden (10-60%)",
                "Tap two tiles to check for a match",
                "Match = +10 points",
                "Mismatch = -2 points"
            ],
            iconName: "star.fill",
            primaryColor: UIColor(red: 0.3, green: 0.6, blue: 0.9, alpha: 1.0)
        )
        contentStackView.addArrangedSubview(classicCard)

        // Challenge Mode Card
        let challengeCard = createModeCard(
            title: "Challenge Mode",
            subtitle: "FOR EXPERTS",
            features: [
                "Tiles are partially hidden (10-60%)",
                "Additional random rotation applied",
                "Same scoring as Classic Mode",
                "Ultimate test of perception!"
            ],
            iconName: "flame.fill",
            primaryColor: UIColor(red: 0.8, green: 0.4, blue: 0.6, alpha: 1.0)
        )
        contentStackView.addArrangedSubview(challengeCard)

        // Tips Section Header
        let tipsHeaderLabel = UILabel()
        tipsHeaderLabel.text = "TIPS & TRICKS"
        tipsHeaderLabel.textColor = UIColor.white.withAlphaComponent(0.5)
        tipsHeaderLabel.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        tipsHeaderLabel.translatesAutoresizingMaskIntoConstraints = false
        let tipsHeaderContainer = UIView()
        tipsHeaderContainer.addSubview(tipsHeaderLabel)
        NSLayoutConstraint.activate([
            tipsHeaderLabel.leadingAnchor.constraint(equalTo: tipsHeaderContainer.leadingAnchor, constant: 4),
            tipsHeaderLabel.topAnchor.constraint(equalTo: tipsHeaderContainer.topAnchor, constant: 10),
            tipsHeaderLabel.bottomAnchor.constraint(equalTo: tipsHeaderContainer.bottomAnchor)
        ])
        contentStackView.addArrangedSubview(tipsHeaderContainer)

        // Tips Cards
        let tipCard1 = createTipCard(
            tip: "Build combos by matching consecutively for bonus points!",
            iconName: "bolt.fill",
            color: UIColor(red: 1.0, green: 0.7, blue: 0.3, alpha: 1.0)
        )
        contentStackView.addArrangedSubview(tipCard1)

        let tipCard2 = createTipCard(
            tip: "Focus on unique patterns and colors to identify tiles faster.",
            iconName: "eye.fill",
            color: UIColor(red: 0.5, green: 0.8, blue: 1.0, alpha: 1.0)
        )
        contentStackView.addArrangedSubview(tipCard2)

        let tipCard3 = createTipCard(
            tip: "When no matches remain, the next round starts automatically.",
            iconName: "arrow.clockwise",
            color: UIColor(red: 0.6, green: 0.9, blue: 0.6, alpha: 1.0)
        )
        contentStackView.addArrangedSubview(tipCard3)

        // Animate cards on appear
        animateCardsEntrance()
    }

    private func createInstructionCard(title: String, content: String, iconName: String, iconColor: UIColor, isHighlighted: Bool) -> UIView {
        let cardView = UIView()
        cardView.backgroundColor = isHighlighted ?
            UIColor(red: 0.2, green: 0.15, blue: 0.3, alpha: 0.9) :
            UIColor(red: 0.15, green: 0.13, blue: 0.2, alpha: 0.9)
        cardView.layer.cornerRadius = 16
        cardView.layer.borderWidth = isHighlighted ? 1.5 : 1
        cardView.layer.borderColor = isHighlighted ?
            iconColor.withAlphaComponent(0.5).cgColor :
            UIColor.white.withAlphaComponent(0.1).cgColor
        cardView.translatesAutoresizingMaskIntoConstraints = false

        if isHighlighted {
            cardView.layer.shadowColor = iconColor.cgColor
            cardView.layer.shadowRadius = 15
            cardView.layer.shadowOpacity = 0.3
            cardView.layer.shadowOffset = .zero
        }

        // Icon
        let iconContainer = UIView()
        iconContainer.backgroundColor = iconColor.withAlphaComponent(0.2)
        iconContainer.layer.cornerRadius = 20
        iconContainer.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(iconContainer)

        let iconImageView = UIImageView()
        iconImageView.image = UIImage(systemName: iconName)
        iconImageView.tintColor = iconColor
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconContainer.addSubview(iconImageView)

        // Title
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.textColor = .white
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(titleLabel)

        // Content
        let contentLabel = UILabel()
        contentLabel.text = content
        contentLabel.textColor = UIColor.white.withAlphaComponent(0.8)
        contentLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        contentLabel.numberOfLines = 0
        contentLabel.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(contentLabel)

        NSLayoutConstraint.activate([
            cardView.heightAnchor.constraint(greaterThanOrEqualToConstant: 100),

            iconContainer.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 16),
            iconContainer.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            iconContainer.widthAnchor.constraint(equalToConstant: 40),
            iconContainer.heightAnchor.constraint(equalToConstant: 40),

            iconImageView.centerXAnchor.constraint(equalTo: iconContainer.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 20),
            iconImageView.heightAnchor.constraint(equalToConstant: 20),

            titleLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: iconContainer.trailingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),

            contentLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            contentLabel.leadingAnchor.constraint(equalTo: iconContainer.trailingAnchor, constant: 12),
            contentLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            contentLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -16)
        ])

        return cardView
    }

    private func createModeCard(title: String, subtitle: String, features: [String], iconName: String, primaryColor: UIColor) -> UIView {
        let cardView = UIView()
        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardView.layer.cornerRadius = 20
        cardView.clipsToBounds = true

        // Gradient background
        let gradientView = UIView()
        gradientView.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(gradientView)

        // Header section
        let headerSection = UIView()
        headerSection.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        headerSection.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(headerSection)

        // Icon
        let iconContainer = UIView()
        iconContainer.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        iconContainer.layer.cornerRadius = 22
        iconContainer.translatesAutoresizingMaskIntoConstraints = false
        headerSection.addSubview(iconContainer)

        let iconImageView = UIImageView()
        iconImageView.image = UIImage(systemName: iconName)
        iconImageView.tintColor = .white
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconContainer.addSubview(iconImageView)

        // Subtitle badge
        let subtitleBadge = UILabel()
        subtitleBadge.text = subtitle
        subtitleBadge.textColor = UIColor.white.withAlphaComponent(0.9)
        subtitleBadge.font = UIFont.systemFont(ofSize: 9, weight: .bold)
        subtitleBadge.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        subtitleBadge.layer.cornerRadius = 6
        subtitleBadge.clipsToBounds = true
        subtitleBadge.textAlignment = .center
        subtitleBadge.translatesAutoresizingMaskIntoConstraints = false
        headerSection.addSubview(subtitleBadge)

        // Title
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.textColor = .white
        titleLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        headerSection.addSubview(titleLabel)

        // Features stack
        let featuresStack = UIStackView()
        featuresStack.axis = .vertical
        featuresStack.spacing = 10
        featuresStack.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(featuresStack)

        for feature in features {
            let featureView = createFeatureRow(text: feature, color: primaryColor)
            featuresStack.addArrangedSubview(featureView)
        }

        NSLayoutConstraint.activate([
            gradientView.topAnchor.constraint(equalTo: cardView.topAnchor),
            gradientView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor),
            gradientView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor),
            gradientView.bottomAnchor.constraint(equalTo: cardView.bottomAnchor),

            headerSection.topAnchor.constraint(equalTo: cardView.topAnchor),
            headerSection.leadingAnchor.constraint(equalTo: cardView.leadingAnchor),
            headerSection.trailingAnchor.constraint(equalTo: cardView.trailingAnchor),
            headerSection.heightAnchor.constraint(equalToConstant: 70),

            iconContainer.leadingAnchor.constraint(equalTo: headerSection.leadingAnchor, constant: 16),
            iconContainer.centerYAnchor.constraint(equalTo: headerSection.centerYAnchor),
            iconContainer.widthAnchor.constraint(equalToConstant: 44),
            iconContainer.heightAnchor.constraint(equalToConstant: 44),

            iconImageView.centerXAnchor.constraint(equalTo: iconContainer.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 22),
            iconImageView.heightAnchor.constraint(equalToConstant: 22),

            subtitleBadge.topAnchor.constraint(equalTo: headerSection.topAnchor, constant: 14),
            subtitleBadge.leadingAnchor.constraint(equalTo: iconContainer.trailingAnchor, constant: 12),
            subtitleBadge.widthAnchor.constraint(equalToConstant: 110),
            subtitleBadge.heightAnchor.constraint(equalToConstant: 18),

            titleLabel.topAnchor.constraint(equalTo: subtitleBadge.bottomAnchor, constant: 4),
            titleLabel.leadingAnchor.constraint(equalTo: iconContainer.trailingAnchor, constant: 12),

            featuresStack.topAnchor.constraint(equalTo: headerSection.bottomAnchor, constant: 16),
            featuresStack.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            featuresStack.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            featuresStack.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -16)
        ])

        // Add gradient after layout
        DispatchQueue.main.async {
            let gradient = CAGradientLayer()
            gradient.colors = [
                primaryColor.cgColor,
                primaryColor.withAlphaComponent(0.7).cgColor
            ]
            gradient.startPoint = CGPoint(x: 0, y: 0)
            gradient.endPoint = CGPoint(x: 1, y: 1)
            gradient.frame = gradientView.bounds
            gradient.cornerRadius = 20
            gradientView.layer.insertSublayer(gradient, at: 0)
        }

        return cardView
    }

    private func createFeatureRow(text: String, color: UIColor) -> UIView {
        let rowView = UIView()
        rowView.translatesAutoresizingMaskIntoConstraints = false

        let checkIcon = UIImageView()
        checkIcon.image = UIImage(systemName: "checkmark.circle.fill")
        checkIcon.tintColor = UIColor.white.withAlphaComponent(0.9)
        checkIcon.contentMode = .scaleAspectFit
        checkIcon.translatesAutoresizingMaskIntoConstraints = false
        rowView.addSubview(checkIcon)

        let textLabel = UILabel()
        textLabel.text = text
        textLabel.textColor = UIColor.white.withAlphaComponent(0.9)
        textLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        rowView.addSubview(textLabel)

        NSLayoutConstraint.activate([
            rowView.heightAnchor.constraint(equalToConstant: 24),

            checkIcon.leadingAnchor.constraint(equalTo: rowView.leadingAnchor),
            checkIcon.centerYAnchor.constraint(equalTo: rowView.centerYAnchor),
            checkIcon.widthAnchor.constraint(equalToConstant: 18),
            checkIcon.heightAnchor.constraint(equalToConstant: 18),

            textLabel.leadingAnchor.constraint(equalTo: checkIcon.trailingAnchor, constant: 10),
            textLabel.centerYAnchor.constraint(equalTo: rowView.centerYAnchor),
            textLabel.trailingAnchor.constraint(equalTo: rowView.trailingAnchor)
        ])

        return rowView
    }

    private func createTipCard(tip: String, iconName: String, color: UIColor) -> UIView {
        let cardView = UIView()
        cardView.backgroundColor = UIColor(red: 0.15, green: 0.13, blue: 0.2, alpha: 0.9)
        cardView.layer.cornerRadius = 12
        cardView.layer.borderWidth = 1
        cardView.layer.borderColor = color.withAlphaComponent(0.3).cgColor
        cardView.translatesAutoresizingMaskIntoConstraints = false

        let iconImageView = UIImageView()
        iconImageView.image = UIImage(systemName: iconName)
        iconImageView.tintColor = color
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(iconImageView)

        let tipLabel = UILabel()
        tipLabel.text = tip
        tipLabel.textColor = UIColor.white.withAlphaComponent(0.9)
        tipLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        tipLabel.numberOfLines = 0
        tipLabel.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(tipLabel)

        NSLayoutConstraint.activate([
            cardView.heightAnchor.constraint(greaterThanOrEqualToConstant: 50),

            iconImageView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 14),
            iconImageView.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 22),
            iconImageView.heightAnchor.constraint(equalToConstant: 22),

            tipLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 12),
            tipLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -14),
            tipLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 14),
            tipLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -14)
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

    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }

}

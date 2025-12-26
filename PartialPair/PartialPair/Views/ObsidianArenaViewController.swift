//
//  ObsidianArenaViewController.swift
//  PartialPair
//
//  Created by Zhao on 2025/12/21.
//  Refactored: Using new engine architecture with strategy patterns
//

import UIKit

// MARK: - Arena View Controller Delegate

protocol ObsidianArenaViewControllerDelegate: AnyObject {
    func arenaViewController(_ controller: ObsidianArenaViewController, didFinishWithScore score: Int, rounds: Int, time: TimeInterval)
}

// MARK: - Arena Display Configuration

struct ArenaDisplayConfiguration {
    let gridColumns: Int
    let spacing: CGFloat
    let aspectRatio: CGFloat

    static let standard = ArenaDisplayConfiguration(
        gridColumns: 5,
        spacing: 8,
        aspectRatio: 1.38
    )
}

class ObsidianArenaViewController: UIViewController {

    // MARK: - Properties

    var gameMode: Int = 1 // 1 or 2
    weak var delegate: ObsidianArenaViewControllerDelegate?

    // Engine and Manager Components
    private let animationManager = ObsidianAnimationManager.shared
    private let hapticManager = ObsidianHapticManager.shared
    private let uiFactory = ObsidianUIFactory.shared
    private lazy var scoreManager: ObsidianScoreManager = createScoreManager()
    private lazy var sessionTimer = ObsidianGameSessionTimer()
    private lazy var displayConfig = ArenaDisplayConfiguration.standard

    private var canvasImageView: UIImageView!
    private var mistOverlay: UIView!

    // Top Header Bar
    private var headerView: UIView!
    private var backButton: UIButton!
    private var modeIndicatorView: UIView!
    private var modeLabel: UILabel!

    // Stats Container
    private var statsContainerView: UIView!
    private var scoreCardView: UIView!
    private var roundCardView: UIView!
    private var timerCardView: UIView!
    private var scoreValueLabel: UILabel!
    private var roundValueLabel: UILabel!
    private var timerValueLabel: UILabel!

    // Progress indicator
    private var progressContainerView: UIView!
    private var progressBar: UIView!
    private var progressFillView: UIView!
    private var matchCountLabel: UILabel!

    // Game area
    private var quartzContainerView: UIView!
    private var quartzContainerBackground: UIView!

    private var quartzViews: [ObsidianQuartzView] = []
    private var currentQuartz: [ObsidianQuartzModel] = []
    private var selectedQuartzIndices: [Int] = []

    private var currentScore: Int = 0
    private var currentRound: Int = 1
    private var gameStartTime: Date = Date()
    private var isProcessingMatch: Bool = false
    private var matchedCount: Int = 0

    // Timer
    private var gameTimer: Timer?
    private var elapsedSeconds: Int = 0

    // Combo system
    private var consecutiveMatches: Int = 0
    private var comboLabel: UILabel!

    // Tile generation strategy
    private lazy var tileGenerator: TileGenerationStrategy = createTileGenerationStrategy()

    private var quartzPerArena: Int {
        return ObsidianPrismManager.shared.getQuartzPerArena()
    }

    // MARK: - Factory Methods

    private func createScoreManager() -> ObsidianScoreManager {
        // Use competitive scoring for challenge mode
        let config: ObsidianScoreConfiguration = gameMode == 2 ? .competitive : .standard
        return ObsidianScoreManager(configuration: config)
    }

    private func createTileGenerationStrategy() -> TileGenerationStrategy {
        // Use weighted strategy for challenge mode to increase difficulty
        if gameMode == 2 {
            return WeightedTileGenerationStrategy(difficultyMultiplier: 1.2)
        }
        return StandardTileGenerationStrategy()
    }

    // MARK: - Computed Properties

    private var currentGameMode: ObsidianGameMode {
        return ObsidianGameMode(rawValue: gameMode) ?? .classic
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        initializeSession()
        setupCanvasImage()
        setupMistOverlay()
        setupHeaderView()
        setupStatsContainer()
        setupProgressIndicator()
        setupQuartzContainer()
        setupComboLabel()
        startGameTimer()
    }

    private func initializeSession() {
        sessionTimer.startSession()
        hapticManager.prepareAll()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if quartzViews.isEmpty && !currentQuartz.isEmpty {
            createQuartzViews()
        } else if quartzViews.isEmpty {
            startNewRound()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        gameTimer?.invalidate()
        sessionTimer.endSession()
    }

    // MARK: - Setup Methods

    private func setupCanvasImage() {
        canvasImageView = uiFactory.createBackgroundImageView()
        view.addSubview(canvasImageView)
        canvasImageView.pinToSuperview()
    }

    private func setupMistOverlay() {
        mistOverlay = uiFactory.createMistOverlay()
        view.addSubview(mistOverlay)
        mistOverlay.pinToSuperview()
    }

    private func setupHeaderView() {
        headerView = UIView()
        headerView.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.15, alpha: 0.95)
        headerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(headerView)

        // Back button with modern design
        backButton = UIButton(type: .system)
        backButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        backButton.tintColor = .white
        backButton.backgroundColor = UIColor.white.withAlphaComponent(0.15)
        backButton.layer.cornerRadius = 18
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        headerView.addSubview(backButton)

        // Mode indicator
        modeIndicatorView = UIView()
        modeIndicatorView.layer.cornerRadius = 12
        modeIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(modeIndicatorView)

        // Set color based on mode
        let modeColor = gameMode == 1 ?
            UIColor(red: 0.3, green: 0.6, blue: 0.9, alpha: 1.0) :
            UIColor(red: 0.8, green: 0.4, blue: 0.6, alpha: 1.0)
        modeIndicatorView.backgroundColor = modeColor.withAlphaComponent(0.3)

        let modeIcon = UIImageView()
        modeIcon.image = UIImage(systemName: gameMode == 1 ? "star.fill" : "flame.fill")
        modeIcon.tintColor = modeColor
        modeIcon.contentMode = .scaleAspectFit
        modeIcon.translatesAutoresizingMaskIntoConstraints = false
        modeIndicatorView.addSubview(modeIcon)

        modeLabel = UILabel()
        modeLabel.text = gameMode == 1 ? "Classic" : "Challenge"
        modeLabel.textColor = .white
        modeLabel.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        modeLabel.translatesAutoresizingMaskIntoConstraints = false
        modeIndicatorView.addSubview(modeLabel)

        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 100),

            backButton.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20),
            backButton.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -15),
            backButton.widthAnchor.constraint(equalToConstant: 36),
            backButton.heightAnchor.constraint(equalToConstant: 36),

            modeIndicatorView.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -20),
            modeIndicatorView.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),
            modeIndicatorView.heightAnchor.constraint(equalToConstant: 32),

            modeIcon.leadingAnchor.constraint(equalTo: modeIndicatorView.leadingAnchor, constant: 10),
            modeIcon.centerYAnchor.constraint(equalTo: modeIndicatorView.centerYAnchor),
            modeIcon.widthAnchor.constraint(equalToConstant: 16),
            modeIcon.heightAnchor.constraint(equalToConstant: 16),

            modeLabel.leadingAnchor.constraint(equalTo: modeIcon.trailingAnchor, constant: 6),
            modeLabel.centerYAnchor.constraint(equalTo: modeIndicatorView.centerYAnchor),
            modeLabel.trailingAnchor.constraint(equalTo: modeIndicatorView.trailingAnchor, constant: -12)
        ])
    }

    private func setupStatsContainer() {
        statsContainerView = UIStackView()
        (statsContainerView as! UIStackView).axis = .horizontal
        (statsContainerView as! UIStackView).distribution = .fillEqually
        (statsContainerView as! UIStackView).spacing = 12
        statsContainerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(statsContainerView)

        // Score Card
        let scoreCard = createStatCard(title: "SCORE", value: "0", iconName: "star.circle.fill", color: UIColor(red: 1.0, green: 0.8, blue: 0.3, alpha: 1.0))
        scoreValueLabel = scoreCard.1
        (statsContainerView as! UIStackView).addArrangedSubview(scoreCard.0)

        // Round Card
        let roundCard = createStatCard(title: "ROUND", value: "1", iconName: "arrow.triangle.2.circlepath", color: UIColor(red: 0.4, green: 0.8, blue: 0.6, alpha: 1.0))
        roundValueLabel = roundCard.1
        (statsContainerView as! UIStackView).addArrangedSubview(roundCard.0)

        // Timer Card
        let timerCard = createStatCard(title: "TIME", value: "0:00", iconName: "clock.fill", color: UIColor(red: 0.6, green: 0.7, blue: 1.0, alpha: 1.0))
        timerValueLabel = timerCard.1
        (statsContainerView as! UIStackView).addArrangedSubview(timerCard.0)

        NSLayoutConstraint.activate([
            statsContainerView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 16),
            statsContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            statsContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            statsContainerView.heightAnchor.constraint(equalToConstant: 70)
        ])
    }

    private func createStatCard(title: String, value: String, iconName: String, color: UIColor) -> (UIView, UILabel) {
        let cardView = UIView()
        cardView.backgroundColor = UIColor(red: 0.15, green: 0.13, blue: 0.2, alpha: 0.95)
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
        titleLabel.textColor = UIColor.white.withAlphaComponent(0.6)
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

    private func setupProgressIndicator() {
        progressContainerView = UIView()
        progressContainerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(progressContainerView)

        progressBar = UIView()
        progressBar.backgroundColor = UIColor.white.withAlphaComponent(0.15)
        progressBar.layer.cornerRadius = 4
        progressBar.translatesAutoresizingMaskIntoConstraints = false
        progressContainerView.addSubview(progressBar)

        progressFillView = UIView()
        progressFillView.backgroundColor = UIColor(red: 0.4, green: 0.8, blue: 0.6, alpha: 1.0)
        progressFillView.layer.cornerRadius = 4
        progressFillView.translatesAutoresizingMaskIntoConstraints = false
        progressBar.addSubview(progressFillView)

        matchCountLabel = UILabel()
        matchCountLabel.text = "0 / \(quartzPerArena / 2) pairs"
        matchCountLabel.textColor = UIColor.white.withAlphaComponent(0.7)
        matchCountLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        matchCountLabel.translatesAutoresizingMaskIntoConstraints = false
        progressContainerView.addSubview(matchCountLabel)

        NSLayoutConstraint.activate([
            progressContainerView.topAnchor.constraint(equalTo: statsContainerView.bottomAnchor, constant: 16),
            progressContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            progressContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            progressContainerView.heightAnchor.constraint(equalToConstant: 24),

            progressBar.centerYAnchor.constraint(equalTo: progressContainerView.centerYAnchor),
            progressBar.leadingAnchor.constraint(equalTo: progressContainerView.leadingAnchor),
            progressBar.trailingAnchor.constraint(equalTo: matchCountLabel.leadingAnchor, constant: -12),
            progressBar.heightAnchor.constraint(equalToConstant: 8),

            progressFillView.leadingAnchor.constraint(equalTo: progressBar.leadingAnchor),
            progressFillView.topAnchor.constraint(equalTo: progressBar.topAnchor),
            progressFillView.bottomAnchor.constraint(equalTo: progressBar.bottomAnchor),
            progressFillView.widthAnchor.constraint(equalToConstant: 0),

            matchCountLabel.trailingAnchor.constraint(equalTo: progressContainerView.trailingAnchor),
            matchCountLabel.centerYAnchor.constraint(equalTo: progressContainerView.centerYAnchor)
        ])
    }

    private func setupQuartzContainer() {
        // Background for quartz area
        quartzContainerBackground = UIView()
        quartzContainerBackground.backgroundColor = UIColor(red: 0.12, green: 0.1, blue: 0.18, alpha: 0.9)
        quartzContainerBackground.layer.cornerRadius = 20
        quartzContainerBackground.layer.borderWidth = 1
        quartzContainerBackground.layer.borderColor = UIColor.white.withAlphaComponent(0.1).cgColor
        quartzContainerBackground.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(quartzContainerBackground)

        quartzContainerView = UIView()
        quartzContainerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(quartzContainerView)

        NSLayoutConstraint.activate([
            quartzContainerBackground.topAnchor.constraint(equalTo: progressContainerView.bottomAnchor, constant: 16),
            quartzContainerBackground.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            quartzContainerBackground.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
            quartzContainerBackground.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -12),

            quartzContainerView.topAnchor.constraint(equalTo: quartzContainerBackground.topAnchor, constant: 12),
            quartzContainerView.leadingAnchor.constraint(equalTo: quartzContainerBackground.leadingAnchor, constant: 12),
            quartzContainerView.trailingAnchor.constraint(equalTo: quartzContainerBackground.trailingAnchor, constant: -12),
            quartzContainerView.bottomAnchor.constraint(equalTo: quartzContainerBackground.bottomAnchor, constant: -12)
        ])
    }

    private func setupComboLabel() {
        comboLabel = UILabel()
        comboLabel.textColor = UIColor(red: 1.0, green: 0.8, blue: 0.3, alpha: 1.0)
        comboLabel.font = UIFont.systemFont(ofSize: 28, weight: .black)
        comboLabel.textAlignment = .center
        comboLabel.alpha = 0
        comboLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(comboLabel)

        NSLayoutConstraint.activate([
            comboLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            comboLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    // MARK: - Timer

    private func startGameTimer() {
        gameTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.elapsedSeconds += 1
            self?.updateTimerDisplay()
        }
    }

    private func updateTimerDisplay() {
        let minutes = elapsedSeconds / 60
        let seconds = elapsedSeconds % 60
        timerValueLabel.text = String(format: "%d:%02d", minutes, seconds)
    }

    // MARK: - Game Logic

    private func startNewRound() {
        // Clear previous quartz
        quartzViews.forEach { $0.removeFromSuperview() }
        quartzViews.removeAll()
        currentQuartz.removeAll()
        selectedQuartzIndices.removeAll()
        matchedCount = 0

        // Generate pairs
        let pairsNeeded = (quartzPerArena + 1) / 2 + 1
        let quartzToGenerate = pairsNeeded * 2
        var allQuartz = ObsidianForgeEngine.shared.generateQuartzForArena(count: quartzToGenerate, mode: gameMode)
        currentQuartz = Array(allQuartz.prefix(quartzPerArena))

        // Create quartz views
        createQuartzViews()
        updateLabels()
        updateProgress()
    }

    private func createQuartzViews() {
        let columns: Int = 5

        let containerWidth = quartzContainerView.bounds.width > 0 ? quartzContainerView.bounds.width : view.bounds.width - 48
        let containerHeight = quartzContainerView.bounds.height > 0 ? quartzContainerView.bounds.height : view.bounds.height - 280

        let spacing: CGFloat = 8
        let rows = (currentQuartz.count + columns - 1) / columns

        // Calculate quartz size based on width
        let quartzWidthFromWidth = (containerWidth - CGFloat(columns - 1) * spacing) / CGFloat(columns)
        let quartzHeightFromWidth = quartzWidthFromWidth * 1.38

        // Calculate quartz size based on height
        let quartzHeightFromHeight = (containerHeight - CGFloat(rows - 1) * spacing) / CGFloat(rows)
        let quartzWidthFromHeight = quartzHeightFromHeight / 1.38

        // Use the smaller size to ensure tiles fit in container
        let quartzWidth: CGFloat
        let quartzHeight: CGFloat
        if quartzHeightFromWidth * CGFloat(rows) + CGFloat(rows - 1) * spacing > containerHeight {
            // Height is the limiting factor
            quartzHeight = quartzHeightFromHeight
            quartzWidth = quartzWidthFromHeight
        } else {
            // Width is the limiting factor
            quartzWidth = quartzWidthFromWidth
            quartzHeight = quartzHeightFromWidth
        }

        for (index, quartzModel) in currentQuartz.enumerated() {
            let row = index / columns
            let col = index % columns

            let quartzView = ObsidianQuartzView()
            quartzView.configure(with: quartzModel, mode: gameMode)
            quartzView.translatesAutoresizingMaskIntoConstraints = false
            quartzView.tag = index
            quartzView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(quartzTapped(_:))))
            quartzContainerView.addSubview(quartzView)
            quartzViews.append(quartzView)

            // Add entrance animation
            quartzView.alpha = 0
            quartzView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)

            NSLayoutConstraint.activate([
                quartzView.widthAnchor.constraint(equalToConstant: quartzWidth),
                quartzView.heightAnchor.constraint(equalToConstant: quartzHeight),
                quartzView.leadingAnchor.constraint(equalTo: quartzContainerView.leadingAnchor, constant: CGFloat(col) * (quartzWidth + spacing)),
                quartzView.topAnchor.constraint(equalTo: quartzContainerView.topAnchor, constant: CGFloat(row) * (quartzHeight + spacing))
            ])

            // Staggered entrance animation
            let delay = Double(index) * 0.03
            UIView.animate(withDuration: 0.4, delay: delay, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5) {
                quartzView.alpha = 1
                quartzView.transform = .identity
            }
        }
    }

    @objc private func quartzTapped(_ gesture: UITapGestureRecognizer) {
        guard let quartzView = gesture.view as? ObsidianQuartzView,
              let index = quartzViews.firstIndex(of: quartzView),
              !isProcessingMatch,
              !currentQuartz[index].isMatched,
              !currentQuartz[index].isSelected else {
            return
        }

        // Haptic feedback using manager
        hapticManager.handleGameEvent(.tileSelected)

        // Select quartz
        currentQuartz[index].isSelected = true
        selectedQuartzIndices.append(index)
        quartzView.setSelected(true)

        // Apply selection animation
        animationManager.animateSelection(view: quartzView)

        // Check if we have two quartz selected
        if selectedQuartzIndices.count == 2 {
            isProcessingMatch = true
            checkMatch()
        }
    }

    private func checkMatch() {
        let index1 = selectedQuartzIndices[0]
        let index2 = selectedQuartzIndices[1]
        let quartz1 = currentQuartz[index1]
        let quartz2 = currentQuartz[index2]
        let quartzView1 = quartzViews[index1]
        let quartzView2 = quartzViews[index2]

        let isMatch = ObsidianForgeEngine.shared.checkIfQuartzMatch(quartz1, quartz2)

        if isMatch {
            handleSuccessfulMatch(index1: index1, index2: index2, views: (quartzView1, quartzView2))
        } else {
            handleFailedMatch(views: (quartzView1, quartzView2))
        }

        updateLabels()
        updateProgress()
    }

    private func handleSuccessfulMatch(index1: Int, index2: Int, views: (ObsidianQuartzView, ObsidianQuartzView)) {
        // Mark as matched
        currentQuartz[index1].isMatched = true
        currentQuartz[index2].isMatched = true
        matchedCount += 1

        // Use score manager
        let scoreUpdate = scoreManager.recordMatch()
        currentScore = scoreUpdate.totalScore
        consecutiveMatches = scoreUpdate.comboCount

        // Haptic feedback using manager
        if consecutiveMatches >= 2 {
            hapticManager.handleGameEvent(.comboAchieved(count: consecutiveMatches))
            showComboLabel()
        } else {
            hapticManager.handleGameEvent(.matchFound)
        }

        // Animate match using animation manager
        animationManager.animateMatch(views: [views.0, views.1]) {
            views.0.setMatched(true)
            views.1.setMatched(true)

            if self.allQuartzMatched() {
                self.completeRound()
            } else {
                self.resetSelection()
            }
        }
    }

    private func handleFailedMatch(views: (ObsidianQuartzView, ObsidianQuartzView)) {
        // Use score manager
        let scoreUpdate = scoreManager.recordMismatch()
        currentScore = scoreUpdate.totalScore
        consecutiveMatches = 0

        // Haptic feedback using manager
        hapticManager.handleGameEvent(.matchFailed)

        // Animate mismatch using animation manager
        animationManager.animateMismatch(views: [views.0, views.1]) {
            self.resetSelection()
        }
    }

    private func showComboLabel() {
        animationManager.animateCombo(label: comboLabel, comboCount: consecutiveMatches)
    }

    private func updateProgress() {
        let totalPairs = quartzPerArena / 2
        let progress = CGFloat(matchedCount) / CGFloat(totalPairs)

        matchCountLabel.text = "\(matchedCount) / \(totalPairs) pairs"

        // Animate progress bar
        view.layoutIfNeeded()
        UIView.animate(withDuration: 0.3) {
            self.progressFillView.constraints.forEach { constraint in
                if constraint.firstAttribute == .width {
                    constraint.isActive = false
                }
            }
            self.progressFillView.widthAnchor.constraint(equalTo: self.progressBar.widthAnchor, multiplier: progress).isActive = true
            self.view.layoutIfNeeded()
        }
    }

    private func animateMatch(quartzView1: ObsidianQuartzView, quartzView2: ObsidianQuartzView, completion: @escaping () -> Void) {
        // Pulse animation with glow effect
        UIView.animate(withDuration: 0.2, animations: {
            quartzView1.transform = CGAffineTransform(scaleX: 1.15, y: 1.15)
            quartzView2.transform = CGAffineTransform(scaleX: 1.15, y: 1.15)
            quartzView1.layer.shadowColor = UIColor(red: 0.4, green: 0.8, blue: 0.6, alpha: 1.0).cgColor
            quartzView1.layer.shadowRadius = 15
            quartzView1.layer.shadowOpacity = 0.8
            quartzView2.layer.shadowColor = UIColor(red: 0.4, green: 0.8, blue: 0.6, alpha: 1.0).cgColor
            quartzView2.layer.shadowRadius = 15
            quartzView2.layer.shadowOpacity = 0.8
        }) { _ in
            UIView.animate(withDuration: 0.3, animations: {
                quartzView1.transform = .identity
                quartzView2.transform = .identity
                quartzView1.alpha = 0.3
                quartzView2.alpha = 0.3
            }) { _ in
                completion()
            }
        }
    }

    private func animateMismatch(quartzView1: ObsidianQuartzView, quartzView2: ObsidianQuartzView, completion: @escaping () -> Void) {
        // Shake animation with red glow
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        animation.values = [-12, 12, -8, 8, -4, 4, 0]
        animation.duration = 0.4

        quartzView1.layer.shadowColor = UIColor.red.cgColor
        quartzView1.layer.shadowRadius = 10
        quartzView1.layer.shadowOpacity = 0.6
        quartzView2.layer.shadowColor = UIColor.red.cgColor
        quartzView2.layer.shadowRadius = 10
        quartzView2.layer.shadowOpacity = 0.6

        quartzView1.layer.add(animation, forKey: "shake")
        quartzView2.layer.add(animation, forKey: "shake")

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            quartzView1.layer.shadowOpacity = 0
            quartzView2.layer.shadowOpacity = 0
            completion()
        }
    }

    private func resetSelection() {
        for index in selectedQuartzIndices {
            currentQuartz[index].isSelected = false
            quartzViews[index].setSelected(false)
        }
        selectedQuartzIndices.removeAll()
        isProcessingMatch = false

        // Check if there are any possible matches left
        checkForPossibleMatches()
    }

    private func allQuartzMatched() -> Bool {
        return currentQuartz.allSatisfy { $0.isMatched }
    }

    private func checkForPossibleMatches() {
        // Get all unmatched quartz
        let unmatchedQuartz = currentQuartz.enumerated().filter { !$0.element.isMatched }

        // Check if there are any possible pairs
        var hasPossibleMatch = false
        var imageNameCounts: [String: Int] = [:]

        for (_, quartz) in unmatchedQuartz {
            imageNameCounts[quartz.imageName, default: 0] += 1
        }

        for count in imageNameCounts.values {
            if count >= 2 {
                hasPossibleMatch = true
                break
            }
        }

        // If no possible matches, automatically start next round
        if !hasPossibleMatch && unmatchedQuartz.count > 0 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.autoAdvanceToNextRound()
            }
        }
    }

    private func autoAdvanceToNextRound() {
        // Show a brief message that no matches are possible
        let alertController = UIAlertController(
            title: "No More Matches",
            message: "No matching pairs available. Starting next round...",
            preferredStyle: .alert
        )
        present(alertController, animated: true)

        // Dismiss alert and start next round
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            alertController.dismiss(animated: true) {
                self.completeRound()
            }
        }
    }

    private func completeRound() {
        currentRound += 1

        // Success haptic
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)

        // Animate completion
        UIView.animate(withDuration: 0.5, animations: {
            self.quartzContainerView.alpha = 0.3
            self.quartzContainerView.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            // Start next round
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.startNewRound()
                UIView.animate(withDuration: 0.5) {
                    self.quartzContainerView.alpha = 1.0
                    self.quartzContainerView.transform = .identity
                }
            }
        }
    }

    private func updateLabels() {
        scoreValueLabel.text = "\(currentScore)"
        roundValueLabel.text = "\(currentRound)"

        // Animate score update using animation manager
        animationManager.animateScoreUpdate(label: scoreValueLabel)
    }

    @objc private func backButtonTapped() {
        // Stop timer and end session
        gameTimer?.invalidate()
        sessionTimer.endSession()

        // Save game record if score > 0
        if currentScore > 0 {
            let timeElapsed = sessionTimer.totalSessionTime
            saveGameRecord(time: timeElapsed)

            // Notify delegate
            delegate?.arenaViewController(self, didFinishWithScore: currentScore, rounds: currentRound - 1, time: timeElapsed)
        }

        navigationController?.popViewController(animated: true)
    }

    private func saveGameRecord(time: TimeInterval) {
        ObsidianVaultManager.shared.saveVaultRecord(
            mode: gameMode,
            score: currentScore,
            rounds: currentRound - 1,
            time: time
        )
    }

    // MARK: - Game Statistics

    private func getGameStatistics() -> ObsidianScoreStatistics {
        return ObsidianScoreStatistics.from(
            scoreManager: scoreManager,
            rounds: currentRound - 1,
            time: sessionTimer.totalSessionTime
        )
    }
}

// MARK: - Arena Game State Extension

extension ObsidianArenaViewController {

    enum ArenaGameState {
        case idle
        case playing
        case processingMatch
        case roundTransition
        case paused
        case finished

        var allowsInteraction: Bool {
            return self == .playing
        }
    }

    private var currentArenaState: ArenaGameState {
        if isProcessingMatch {
            return .processingMatch
        }
        return .playing
    }
}

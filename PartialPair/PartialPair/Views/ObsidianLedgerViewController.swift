//
//  ObsidianLedgerViewController.swift
//  PartialPair
//
//  Created by Zhao on 2025/12/21.
//

import UIKit

class ObsidianLedgerViewController: UIViewController {

    // MARK: - Properties

    private var backgroundImageView: UIImageView!
    private var overlayView: UIView!
    private var headerView: UIView!
    private var backButton: UIButton!
    private var titleLabel: UILabel!

    // Stats summary
    private var statsSummaryView: UIView!
    private var totalGamesLabel: UILabel!
    private var bestScoreLabel: UILabel!
    private var totalTimeLabel: UILabel!

    private var tableView: UITableView!
    private var emptyStateView: UIView!
    private var deleteAllButton: UIButton!

    private var vaultRecords: [ObsidianVaultRecord] = []

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackgroundImage()
        setupOverlayView()
        setupHeaderView()
        setupStatsSummary()
        setupTableView()
        setupEmptyStateView()
        setupDeleteButton()
        loadRecords()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        loadRecords()
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
        iconView.image = UIImage(systemName: "trophy.fill")
        iconView.tintColor = UIColor(red: 1.0, green: 0.8, blue: 0.3, alpha: 1.0)
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(iconView)

        titleLabel = UILabel()
        titleLabel.text = "Game Records"
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

    private func setupStatsSummary() {
        statsSummaryView = UIView()
        statsSummaryView.backgroundColor = UIColor(red: 0.12, green: 0.1, blue: 0.18, alpha: 0.95)
        statsSummaryView.layer.cornerRadius = 16
        statsSummaryView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(statsSummaryView)

        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 1
        stackView.translatesAutoresizingMaskIntoConstraints = false
        statsSummaryView.addSubview(stackView)

        // Total Games
        let gamesCard = createStatSummaryItem(title: "GAMES", value: "0", iconName: "gamecontroller.fill", color: UIColor(red: 0.4, green: 0.7, blue: 1.0, alpha: 1.0))
        totalGamesLabel = gamesCard.1
        stackView.addArrangedSubview(gamesCard.0)

        // Best Score
        let scoreCard = createStatSummaryItem(title: "BEST", value: "0", iconName: "star.fill", color: UIColor(red: 1.0, green: 0.8, blue: 0.3, alpha: 1.0))
        bestScoreLabel = scoreCard.1
        stackView.addArrangedSubview(scoreCard.0)

        // Total Time
        let timeCard = createStatSummaryItem(title: "TIME", value: "0m", iconName: "clock.fill", color: UIColor(red: 0.6, green: 0.9, blue: 0.6, alpha: 1.0))
        totalTimeLabel = timeCard.1
        stackView.addArrangedSubview(timeCard.0)

        NSLayoutConstraint.activate([
            statsSummaryView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 16),
            statsSummaryView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            statsSummaryView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            statsSummaryView.heightAnchor.constraint(equalToConstant: 80),

            stackView.topAnchor.constraint(equalTo: statsSummaryView.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: statsSummaryView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: statsSummaryView.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: statsSummaryView.bottomAnchor)
        ])
    }

    private func createStatSummaryItem(title: String, value: String, iconName: String, color: UIColor) -> (UIView, UILabel) {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false

        let iconView = UIImageView()
        iconView.image = UIImage(systemName: iconName)
        iconView.tintColor = color
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(iconView)

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.textColor = UIColor.white.withAlphaComponent(0.5)
        titleLabel.font = UIFont.systemFont(ofSize: 10, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(titleLabel)

        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.textColor = .white
        valueLabel.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        valueLabel.textAlignment = .center
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(valueLabel)

        NSLayoutConstraint.activate([
            iconView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            iconView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 18),
            iconView.heightAnchor.constraint(equalToConstant: 18),

            titleLabel.topAnchor.constraint(equalTo: iconView.bottomAnchor, constant: 4),
            titleLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),

            valueLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2),
            valueLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor)
        ])

        return (containerView, valueLabel)
    }

    private func setupTableView() {
        tableView = UITableView(frame: .zero, style: .plain)
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ObsidianLedgerCell.self, forCellReuseIdentifier: "ModernRecordCell")
        tableView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 80, right: 0)
        tableView.showsVerticalScrollIndicator = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: statsSummaryView.bottomAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func setupEmptyStateView() {
        emptyStateView = UIView()
        emptyStateView.isHidden = true
        emptyStateView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(emptyStateView)

        let iconView = UIImageView()
        iconView.image = UIImage(systemName: "trophy")
        iconView.tintColor = UIColor.white.withAlphaComponent(0.3)
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false
        emptyStateView.addSubview(iconView)

        let titleLabel = UILabel()
        titleLabel.text = "No Records Yet"
        titleLabel.textColor = UIColor.white.withAlphaComponent(0.8)
        titleLabel.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        emptyStateView.addSubview(titleLabel)

        let subtitleLabel = UILabel()
        subtitleLabel.text = "Play some games to see\nyour scores here!"
        subtitleLabel.textColor = UIColor.white.withAlphaComponent(0.5)
        subtitleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        subtitleLabel.textAlignment = .center
        subtitleLabel.numberOfLines = 2
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        emptyStateView.addSubview(subtitleLabel)

        NSLayoutConstraint.activate([
            emptyStateView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyStateView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            emptyStateView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),

            iconView.topAnchor.constraint(equalTo: emptyStateView.topAnchor),
            iconView.centerXAnchor.constraint(equalTo: emptyStateView.centerXAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 60),
            iconView.heightAnchor.constraint(equalToConstant: 60),

            titleLabel.topAnchor.constraint(equalTo: iconView.bottomAnchor, constant: 16),
            titleLabel.centerXAnchor.constraint(equalTo: emptyStateView.centerXAnchor),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.centerXAnchor.constraint(equalTo: emptyStateView.centerXAnchor),
            subtitleLabel.bottomAnchor.constraint(equalTo: emptyStateView.bottomAnchor)
        ])
    }

    private func setupDeleteButton() {
        deleteAllButton = UIButton(type: .system)
        deleteAllButton.setTitle("Clear All Records", for: .normal)
        deleteAllButton.setTitleColor(.white, for: .normal)
        deleteAllButton.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        deleteAllButton.backgroundColor = UIColor(red: 0.9, green: 0.3, blue: 0.3, alpha: 0.9)
        deleteAllButton.layer.cornerRadius = 14
        deleteAllButton.translatesAutoresizingMaskIntoConstraints = false
        deleteAllButton.addTarget(self, action: #selector(deleteAllButtonTapped), for: .touchUpInside)

        // Add icon
        let trashIcon = UIImageView()
        trashIcon.image = UIImage(systemName: "trash.fill")
        trashIcon.tintColor = .white
        trashIcon.contentMode = .scaleAspectFit
        trashIcon.translatesAutoresizingMaskIntoConstraints = false
        deleteAllButton.addSubview(trashIcon)

        view.addSubview(deleteAllButton)

        NSLayoutConstraint.activate([
            deleteAllButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            deleteAllButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            deleteAllButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            deleteAllButton.heightAnchor.constraint(equalToConstant: 50),

            trashIcon.leadingAnchor.constraint(equalTo: deleteAllButton.leadingAnchor, constant: 16),
            trashIcon.centerYAnchor.constraint(equalTo: deleteAllButton.centerYAnchor),
            trashIcon.widthAnchor.constraint(equalToConstant: 18),
            trashIcon.heightAnchor.constraint(equalToConstant: 18)
        ])
    }

    // MARK: - Data Management

    private func loadRecords() {
        vaultRecords = ObsidianVaultManager.shared.fetchAllVaultRecords()
        updateUI()
        updateStatsSummary()
    }

    private func updateUI() {
        tableView.reloadData()
        emptyStateView.isHidden = !vaultRecords.isEmpty
        deleteAllButton.isHidden = vaultRecords.isEmpty
        tableView.isHidden = vaultRecords.isEmpty
    }

    private func updateStatsSummary() {
        totalGamesLabel.text = "\(vaultRecords.count)"

        let bestScore = vaultRecords.map { Int($0.finalScore) }.max() ?? 0
        bestScoreLabel.text = "\(bestScore)"

        let totalSeconds = vaultRecords.reduce(0) { $0 + Int($1.totalTime) }
        let totalMinutes = totalSeconds / 60
        if totalMinutes >= 60 {
            totalTimeLabel.text = "\(totalMinutes / 60)h \(totalMinutes % 60)m"
        } else {
            totalTimeLabel.text = "\(totalMinutes)m"
        }
    }

    @objc private func deleteAllButtonTapped() {
        let alertController = UIAlertController(
            title: "Clear All Records",
            message: "Are you sure you want to delete all game records? This cannot be undone.",
            preferredStyle: .alert
        )

        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alertController.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            ObsidianVaultManager.shared.deleteAllVaultRecords()
            self?.loadRecords()
        })

        present(alertController, animated: true)
    }

    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }

}

// MARK: - UITableViewDataSource

extension ObsidianLedgerViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return vaultRecords.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ModernRecordCell", for: indexPath) as! ObsidianLedgerCell
        let record = vaultRecords[indexPath.row]
        cell.configure(with: record, rank: indexPath.row + 1)
        return cell
    }

}

// MARK: - UITableViewDelegate

extension ObsidianLedgerViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let record = vaultRecords[indexPath.row]
            ObsidianVaultManager.shared.deleteVaultRecord(record)
            loadRecords()
        }
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: nil) { [weak self] _, _, completion in
            guard let self = self else { return }
            let record = self.vaultRecords[indexPath.row]
            ObsidianVaultManager.shared.deleteVaultRecord(record)
            self.loadRecords()
            completion(true)
        }
        deleteAction.image = UIImage(systemName: "trash.fill")
        deleteAction.backgroundColor = UIColor(red: 0.9, green: 0.3, blue: 0.3, alpha: 1.0)

        return UISwipeActionsConfiguration(actions: [deleteAction])
    }

}

// MARK: - Modern Record Cell

class ObsidianLedgerCell: UITableViewCell {

    private var cardView: UIView!
    private var rankBadge: UIView!
    private var rankLabel: UILabel!
    private var modeIndicator: UIView!
    private var modeIcon: UIImageView!
    private var modeLabel: UILabel!
    private var scoreLabel: UILabel!
    private var scoreValueLabel: UILabel!
    private var detailsStackView: UIStackView!
    private var roundsLabel: UILabel!
    private var timeLabel: UILabel!
    private var dateLabel: UILabel!

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupCell()
    }

    private func setupCell() {
        backgroundColor = .clear
        selectionStyle = .none

        cardView = UIView()
        cardView.backgroundColor = UIColor(red: 0.15, green: 0.13, blue: 0.2, alpha: 0.95)
        cardView.layer.cornerRadius = 16
        cardView.layer.borderWidth = 1
        cardView.layer.borderColor = UIColor.white.withAlphaComponent(0.1).cgColor
        cardView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(cardView)

        // Rank badge
        rankBadge = UIView()
        rankBadge.layer.cornerRadius = 14
        rankBadge.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(rankBadge)

        rankLabel = UILabel()
        rankLabel.textColor = .white
        rankLabel.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        rankLabel.textAlignment = .center
        rankLabel.translatesAutoresizingMaskIntoConstraints = false
        rankBadge.addSubview(rankLabel)

        // Mode indicator
        modeIndicator = UIView()
        modeIndicator.layer.cornerRadius = 10
        modeIndicator.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(modeIndicator)

        modeIcon = UIImageView()
        modeIcon.contentMode = .scaleAspectFit
        modeIcon.translatesAutoresizingMaskIntoConstraints = false
        modeIndicator.addSubview(modeIcon)

        modeLabel = UILabel()
        modeLabel.textColor = .white
        modeLabel.font = UIFont.systemFont(ofSize: 11, weight: .semibold)
        modeLabel.translatesAutoresizingMaskIntoConstraints = false
        modeIndicator.addSubview(modeLabel)

        // Score section
        scoreLabel = UILabel()
        scoreLabel.text = "SCORE"
        scoreLabel.textColor = UIColor.white.withAlphaComponent(0.5)
        scoreLabel.font = UIFont.systemFont(ofSize: 9, weight: .bold)
        scoreLabel.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(scoreLabel)

        scoreValueLabel = UILabel()
        scoreValueLabel.textColor = UIColor(red: 1.0, green: 0.8, blue: 0.3, alpha: 1.0)
        scoreValueLabel.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        scoreValueLabel.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(scoreValueLabel)

        // Details
        detailsStackView = UIStackView()
        detailsStackView.axis = .horizontal
        detailsStackView.spacing = 16
        detailsStackView.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(detailsStackView)

        roundsLabel = createDetailLabel()
        timeLabel = createDetailLabel()
        detailsStackView.addArrangedSubview(roundsLabel)
        detailsStackView.addArrangedSubview(timeLabel)

        // Date
        dateLabel = UILabel()
        dateLabel.textColor = UIColor.white.withAlphaComponent(0.4)
        dateLabel.font = UIFont.systemFont(ofSize: 11, weight: .medium)
        dateLabel.textAlignment = .right
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(dateLabel)

        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),

            rankBadge.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            rankBadge.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),
            rankBadge.widthAnchor.constraint(equalToConstant: 28),
            rankBadge.heightAnchor.constraint(equalToConstant: 28),

            rankLabel.centerXAnchor.constraint(equalTo: rankBadge.centerXAnchor),
            rankLabel.centerYAnchor.constraint(equalTo: rankBadge.centerYAnchor),

            modeIndicator.leadingAnchor.constraint(equalTo: rankBadge.trailingAnchor, constant: 10),
            modeIndicator.centerYAnchor.constraint(equalTo: rankBadge.centerYAnchor),
            modeIndicator.heightAnchor.constraint(equalToConstant: 24),

            modeIcon.leadingAnchor.constraint(equalTo: modeIndicator.leadingAnchor, constant: 8),
            modeIcon.centerYAnchor.constraint(equalTo: modeIndicator.centerYAnchor),
            modeIcon.widthAnchor.constraint(equalToConstant: 12),
            modeIcon.heightAnchor.constraint(equalToConstant: 12),

            modeLabel.leadingAnchor.constraint(equalTo: modeIcon.trailingAnchor, constant: 4),
            modeLabel.centerYAnchor.constraint(equalTo: modeIndicator.centerYAnchor),
            modeLabel.trailingAnchor.constraint(equalTo: modeIndicator.trailingAnchor, constant: -8),

            scoreLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            scoreLabel.topAnchor.constraint(equalTo: rankBadge.bottomAnchor, constant: 10),

            scoreValueLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            scoreValueLabel.topAnchor.constraint(equalTo: scoreLabel.bottomAnchor, constant: 2),

            detailsStackView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),
            detailsStackView.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -12),

            dateLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),
            dateLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12)
        ])
    }

    private func createDetailLabel() -> UILabel {
        let label = UILabel()
        label.textColor = UIColor.white.withAlphaComponent(0.6)
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }

    func configure(with record: ObsidianVaultRecord, rank: Int) {
        rankLabel.text = "#\(rank)"

        // Rank badge color
        switch rank {
        case 1:
            rankBadge.backgroundColor = UIColor(red: 1.0, green: 0.8, blue: 0.3, alpha: 1.0)
            cardView.layer.borderColor = UIColor(red: 1.0, green: 0.8, blue: 0.3, alpha: 0.3).cgColor
        case 2:
            rankBadge.backgroundColor = UIColor(red: 0.75, green: 0.75, blue: 0.8, alpha: 1.0)
        case 3:
            rankBadge.backgroundColor = UIColor(red: 0.8, green: 0.6, blue: 0.4, alpha: 1.0)
        default:
            rankBadge.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        }

        // Mode indicator
        let isClassic = record.gameMode == 1
        let modeColor = isClassic ?
            UIColor(red: 0.3, green: 0.6, blue: 0.9, alpha: 1.0) :
            UIColor(red: 0.8, green: 0.4, blue: 0.6, alpha: 1.0)

        modeIndicator.backgroundColor = modeColor.withAlphaComponent(0.3)
        modeIcon.image = UIImage(systemName: isClassic ? "star.fill" : "flame.fill")
        modeIcon.tintColor = modeColor
        modeLabel.text = isClassic ? "Classic" : "Challenge"

        // Score
        scoreValueLabel.text = "\(record.finalScore)"

        // Details
        roundsLabel.text = "\(record.roundsCompleted) rounds"

        let minutes = Int(record.totalTime) / 60
        let seconds = Int(record.totalTime) % 60
        timeLabel.text = "\(minutes)m \(seconds)s"

        // Date
        if let timestamp = record.timestamp {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d, HH:mm"
            dateLabel.text = formatter.string(from: timestamp)
        }
    }

}

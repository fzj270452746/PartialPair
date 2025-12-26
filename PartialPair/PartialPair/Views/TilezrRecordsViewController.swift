//
//  TilezrRecordsViewController.swift
//  PartialPair
//
//  Created by Zhao on 2025/12/21.
//

import UIKit

class TilezrRecordsViewController: UIViewController {
    
    // MARK: - Properties
    
    private var backgroundImageView: UIImageView!
    private var overlayView: UIView!
    private var backButton: UIButton!
    private var tableView: UITableView!
    private var emptyStateLabel: UILabel!
    private var deleteAllButton: UIButton!
    
    private var gameRecords: [TilezrGameRecord] = []
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackgroundImage()
        setupOverlayView()
        setupBackButton()
        setupDeleteAllButton()
        setupTableView()
        setupEmptyStateLabel()
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
        overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        overlayView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(overlayView)
        
        NSLayoutConstraint.activate([
            overlayView.topAnchor.constraint(equalTo: view.topAnchor),
            overlayView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            overlayView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            overlayView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupBackButton() {
        backButton = UIButton(type: .system)
        backButton.setImage(UIImage(systemName: "chevron.left.circle.fill"), for: .normal)
        backButton.tintColor = .white
        backButton.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        backButton.layer.cornerRadius = 20
        backButton.layer.shadowColor = UIColor.black.cgColor
        backButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        backButton.layer.shadowRadius = 4
        backButton.layer.shadowOpacity = 0.5
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        view.addSubview(backButton)
        
        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            backButton.widthAnchor.constraint(equalToConstant: 40),
            backButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    private func setupTableView() {
        tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .singleLine
        tableView.separatorColor = .white.withAlphaComponent(0.3)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(TilezrRecordTableViewCell.self, forCellReuseIdentifier: "RecordCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: backButton.bottomAnchor, constant: 20),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            tableView.bottomAnchor.constraint(equalTo: deleteAllButton.topAnchor, constant: -20)
        ])
    }
    
    private func setupEmptyStateLabel() {
        emptyStateLabel = UILabel()
        emptyStateLabel.text = "No game records yet.\nStart playing to see your scores here!"
        emptyStateLabel.textColor = .white
        emptyStateLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        emptyStateLabel.textAlignment = .center
        emptyStateLabel.numberOfLines = 0
        emptyStateLabel.isHidden = true
        emptyStateLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(emptyStateLabel)
        
        NSLayoutConstraint.activate([
            emptyStateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyStateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            emptyStateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40)
        ])
    }
    
    private func setupDeleteAllButton() {
        deleteAllButton = UIButton(type: .system)
        deleteAllButton.setTitle("Delete All Records", for: .normal)
        deleteAllButton.setTitleColor(.white, for: .normal)
        deleteAllButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        deleteAllButton.backgroundColor = UIColor.systemRed.withAlphaComponent(0.8)
        deleteAllButton.layer.cornerRadius = 10
        deleteAllButton.layer.shadowColor = UIColor.black.cgColor
        deleteAllButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        deleteAllButton.layer.shadowRadius = 4
        deleteAllButton.layer.shadowOpacity = 0.3
        deleteAllButton.translatesAutoresizingMaskIntoConstraints = false
        deleteAllButton.addTarget(self, action: #selector(deleteAllButtonTapped), for: .touchUpInside)
        view.addSubview(deleteAllButton)
        
        NSLayoutConstraint.activate([
            deleteAllButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            deleteAllButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            deleteAllButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            deleteAllButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    // MARK: - Data Management
    
    private func loadRecords() {
        gameRecords = TilezrDataManager.shared.fetchAllRecords()
        updateUI()
    }
    
    private func updateUI() {
        tableView.reloadData()
        emptyStateLabel.isHidden = !gameRecords.isEmpty
        deleteAllButton.isHidden = gameRecords.isEmpty
    }
    
    @objc private func deleteAllButtonTapped() {
        let alertController = UIAlertController(
            title: "Delete All Records",
            message: "Are you sure you want to delete all game records? This action cannot be undone.",
            preferredStyle: .alert
        )
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alertController.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            TilezrDataManager.shared.deleteAllRecords()
            self?.loadRecords()
        })
        
        present(alertController, animated: true)
    }
    
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
}

// MARK: - UITableViewDataSource

extension TilezrRecordsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return gameRecords.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RecordCell", for: indexPath) as! TilezrRecordTableViewCell
        let record = gameRecords[indexPath.row]
        cell.configure(with: record)
        return cell
    }
    
}

// MARK: - UITableViewDelegate

extension TilezrRecordsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let record = gameRecords[indexPath.row]
            TilezrDataManager.shared.deleteRecord(record)
            loadRecords()
        }
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "Delete"
    }
    
}

// MARK: - Record Cell

class TilezrRecordTableViewCell: UITableViewCell {
    
    private var containerView: UIView!
    private var modeLabel: UILabel!
    private var scoreLabel: UILabel!
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
        
        containerView = UIView()
        containerView.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        containerView.layer.cornerRadius = 10
        containerView.layer.masksToBounds = true
        containerView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(containerView)
        
        modeLabel = UILabel()
        modeLabel.textColor = .white
        modeLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        modeLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(modeLabel)
        
        scoreLabel = UILabel()
        scoreLabel.textColor = .white
        scoreLabel.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        scoreLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(scoreLabel)
        
        roundsLabel = UILabel()
        roundsLabel.textColor = .white
        roundsLabel.font = UIFont.systemFont(ofSize: 14)
        roundsLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(roundsLabel)
        
        timeLabel = UILabel()
        timeLabel.textColor = .white
        timeLabel.font = UIFont.systemFont(ofSize: 14)
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(timeLabel)
        
        dateLabel = UILabel()
        dateLabel.textColor = .white.withAlphaComponent(0.8)
        dateLabel.font = UIFont.systemFont(ofSize: 12)
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(dateLabel)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
            
            modeLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10),
            modeLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 15),
            
            scoreLabel.topAnchor.constraint(equalTo: modeLabel.bottomAnchor, constant: 8),
            scoreLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 15),
            
            roundsLabel.topAnchor.constraint(equalTo: scoreLabel.bottomAnchor, constant: 5),
            roundsLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 15),
            
            timeLabel.topAnchor.constraint(equalTo: roundsLabel.topAnchor),
            timeLabel.leadingAnchor.constraint(equalTo: roundsLabel.trailingAnchor, constant: 20),
            
            dateLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10),
            dateLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -15)
        ])
    }
    
    func configure(with record: TilezrGameRecord) {
        modeLabel.text = "Mode \(record.gameMode)"
        scoreLabel.text = "Score: \(record.finalScore)"
        roundsLabel.text = "Rounds: \(record.roundsCompleted)"
        
        let minutes = Int(record.totalTime) / 60
        let seconds = Int(record.totalTime) % 60
        timeLabel.text = "Time: \(minutes)m \(seconds)s"
        
        if let timestamp = record.timestamp {
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            formatter.timeStyle = .short
            dateLabel.text = formatter.string(from: timestamp)
        } else {
            dateLabel.text = ""
        }
    }
    
}


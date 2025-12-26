//
//  TilezrGameViewController.swift
//  PartialPair
//
//  Created by Zhao on 2025/12/21.
//

import UIKit

class TilezrGameViewController: UIViewController {
    
    // MARK: - Properties
    
    var gameMode: Int = 1 // 1 or 2
    
    private var backgroundImageView: UIImageView!
    private var overlayView: UIView!
    private var backButton: UIButton!
    private var scoreLabel: UILabel!
    private var roundLabel: UILabel!
    private var tilesContainerView: UIView!
    
    private var tileViews: [TilezrTileView] = []
    private var currentTiles: [TilezrTileModel] = []
    private var selectedTileIndices: [Int] = []
    
    private var currentScore: Int = 0
    private var currentRound: Int = 1
    private var gameStartTime: Date = Date()
    private var isProcessingMatch: Bool = false
    
    private var tilesPerGame: Int {
        return TilezrSettingsManager.shared.getTilesPerGame()
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackgroundImage()
        setupOverlayView()
        setupBackButton()
        setupScoreLabels()
        setupTilesContainer()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if tileViews.isEmpty && !currentTiles.isEmpty {
            createTileViews()
        } else if tileViews.isEmpty {
            startNewRound()
        }
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
    
    private func setupScoreLabels() {
        let containerStackView = UIStackView()
        containerStackView.axis = .horizontal
        containerStackView.distribution = .equalSpacing
        containerStackView.spacing = 20
        containerStackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(containerStackView)
        
        scoreLabel = UILabel()
        scoreLabel.text = "Score: 0"
        scoreLabel.textColor = .white
        scoreLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        scoreLabel.textAlignment = .center
        scoreLabel.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        scoreLabel.layer.cornerRadius = 8
        scoreLabel.layer.masksToBounds = true
        scoreLabel.translatesAutoresizingMaskIntoConstraints = false
        
        roundLabel = UILabel()
        roundLabel.text = "Round: 1"
        roundLabel.textColor = .white
        roundLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        roundLabel.textAlignment = .center
        roundLabel.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        roundLabel.layer.cornerRadius = 8
        roundLabel.layer.masksToBounds = true
        roundLabel.translatesAutoresizingMaskIntoConstraints = false
        
        containerStackView.addArrangedSubview(scoreLabel)
        containerStackView.addArrangedSubview(roundLabel)
        
        NSLayoutConstraint.activate([
            containerStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            containerStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            scoreLabel.widthAnchor.constraint(equalToConstant: 120),
            scoreLabel.heightAnchor.constraint(equalToConstant: 40),
            roundLabel.widthAnchor.constraint(equalToConstant: 120),
            roundLabel.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    private func setupTilesContainer() {
        tilesContainerView = UIView()
        tilesContainerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tilesContainerView)
        
        NSLayoutConstraint.activate([
            tilesContainerView.topAnchor.constraint(equalTo: backButton.bottomAnchor, constant: 30),
            tilesContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            tilesContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            tilesContainerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }
    
    // MARK: - Game Logic
    
    private func startNewRound() {
        // Clear previous tiles
        tileViews.forEach { $0.removeFromSuperview() }
        tileViews.removeAll()
        currentTiles.removeAll()
        selectedTileIndices.removeAll()
        
        // Generate enough pairs to cover the required tiles (need at least tilesPerGame tiles)
        // Generate pairs: if tilesPerGame is odd, generate (tilesPerGame + 1) / 2 pairs
        // if even, generate tilesPerGame / 2 pairs, but add 1 extra pair to ensure we have enough
        let pairsNeeded = (tilesPerGame + 1) / 2 + 1 // Add 1 extra pair to ensure we have enough
        let tilesToGenerate = pairsNeeded * 2
        var allTiles = TilezrGameEngine.shared.generateTilesForGame(count: tilesToGenerate, mode: gameMode)
        currentTiles = Array(allTiles.prefix(tilesPerGame))
        
        // Create tile views
        createTileViews()
        updateLabels()
    }
    
    private func createTileViews() {
        let columns: Int = 5
        
        let containerWidth = tilesContainerView.bounds.width > 0 ? tilesContainerView.bounds.width : view.bounds.width - 40
        let containerHeight = tilesContainerView.bounds.height > 0 ? tilesContainerView.bounds.height : view.bounds.height - 200
        
        let spacing: CGFloat = 8
        let tileWidth = (containerWidth - CGFloat(columns - 1) * spacing) / CGFloat(columns)
        let tileHeight = tileWidth * 1.38 // Aspect ratio 1:1.38
        
        // Calculate how many rows we need (each row has 5 tiles)
        let totalRows = (tilesPerGame + columns - 1) / columns
        
        for (index, tileModel) in currentTiles.enumerated() {
            let row = index / columns
            let col = index % columns
            
            let tileView = TilezrTileView()
            tileView.configure(with: tileModel, mode: gameMode)
            tileView.translatesAutoresizingMaskIntoConstraints = false
            tileView.tag = index
            tileView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tileTapped(_:))))
            tilesContainerView.addSubview(tileView)
            tileViews.append(tileView)
            
            NSLayoutConstraint.activate([
                tileView.widthAnchor.constraint(equalToConstant: tileWidth),
                tileView.heightAnchor.constraint(equalToConstant: tileHeight),
                tileView.leadingAnchor.constraint(equalTo: tilesContainerView.leadingAnchor, constant: CGFloat(col) * (tileWidth + spacing)),
                tileView.topAnchor.constraint(equalTo: tilesContainerView.topAnchor, constant: CGFloat(row) * (tileHeight + spacing))
            ])
        }
    }
    
    @objc private func tileTapped(_ gesture: UITapGestureRecognizer) {
        guard let tileView = gesture.view as? TilezrTileView,
              let index = tileViews.firstIndex(of: tileView),
              !isProcessingMatch,
              !currentTiles[index].isMatched,
              !currentTiles[index].isSelected else {
            return
        }
        
        // Select tile
        currentTiles[index].isSelected = true
        selectedTileIndices.append(index)
        tileView.setSelected(true)
        
        // Check if we have two tiles selected
        if selectedTileIndices.count == 2 {
            isProcessingMatch = true
            checkMatch()
        }
    }
    
    private func checkMatch() {
        let index1 = selectedTileIndices[0]
        let index2 = selectedTileIndices[1]
        let tile1 = currentTiles[index1]
        let tile2 = currentTiles[index2]
        let tileView1 = tileViews[index1]
        let tileView2 = tileViews[index2]
        
        let isMatch = TilezrGameEngine.shared.checkIfTilesMatch(tile1, tile2)
        
        if isMatch {
            // Match found
            currentTiles[index1].isMatched = true
            currentTiles[index2].isMatched = true
            currentScore += 10
            
            // Animate match
            animateMatch(tileView1: tileView1, tileView2: tileView2) {
                tileView1.setMatched(true)
                tileView2.setMatched(true)
                
                // Check if all tiles are matched
                if self.allTilesMatched() {
                    self.completeRound()
                } else {
                    self.resetSelection()
                }
            }
        } else {
            // No match
            currentScore = max(0, currentScore - 2)
            animateMismatch(tileView1: tileView1, tileView2: tileView2) {
                self.resetSelection()
            }
        }
        
        updateLabels()
    }
    
    private func animateMatch(tileView1: TilezrTileView, tileView2: TilezrTileView, completion: @escaping () -> Void) {
        UIView.animate(withDuration: 0.3, animations: {
            tileView1.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            tileView2.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            tileView1.alpha = 0.7
            tileView2.alpha = 0.7
        }) { _ in
            UIView.animate(withDuration: 0.3, animations: {
                tileView1.transform = .identity
                tileView2.transform = .identity
            }) { _ in
                completion()
            }
        }
    }
    
    private func animateMismatch(tileView1: TilezrTileView, tileView2: TilezrTileView, completion: @escaping () -> Void) {
        UIView.animate(withDuration: 0.15, animations: {
            tileView1.transform = CGAffineTransform(translationX: -10, y: 0)
            tileView2.transform = CGAffineTransform(translationX: 10, y: 0)
        }) { _ in
            UIView.animate(withDuration: 0.15, animations: {
                tileView1.transform = CGAffineTransform(translationX: 10, y: 0)
                tileView2.transform = CGAffineTransform(translationX: -10, y: 0)
            }) { _ in
                UIView.animate(withDuration: 0.15, animations: {
                    tileView1.transform = .identity
                    tileView2.transform = .identity
                }) { _ in
                    completion()
                }
            }
        }
    }
    
    private func resetSelection() {
        for index in selectedTileIndices {
            currentTiles[index].isSelected = false
            tileViews[index].setSelected(false)
        }
        selectedTileIndices.removeAll()
        isProcessingMatch = false
        
        // Check if there are any possible matches left
        checkForPossibleMatches()
    }
    
    private func allTilesMatched() -> Bool {
        return currentTiles.allSatisfy { $0.isMatched }
    }
    
    private func checkForPossibleMatches() {
        // Get all unmatched tiles
        let unmatchedTiles = currentTiles.enumerated().filter { !$0.element.isMatched }
        
        // Check if there are any possible pairs
        var hasPossibleMatch = false
        var imageNameCounts: [String: Int] = [:]
        
        for (_, tile) in unmatchedTiles {
            imageNameCounts[tile.imageName, default: 0] += 1
        }
        
        // Check if any image name appears at least twice (meaning there's a possible match)
        for count in imageNameCounts.values {
            if count >= 2 {
                hasPossibleMatch = true
                break
            }
        }
        
        // If no possible matches, automatically start next round
        if !hasPossibleMatch && unmatchedTiles.count > 0 {
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
        
        // Animate completion
        UIView.animate(withDuration: 0.5, animations: {
            self.tilesContainerView.alpha = 0.3
        }) { _ in
            // Start next round
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.startNewRound()
                UIView.animate(withDuration: 0.5) {
                    self.tilesContainerView.alpha = 1.0
                }
            }
        }
    }
    
    private func updateLabels() {
        scoreLabel.text = "Score: \(currentScore)"
        roundLabel.text = "Round: \(currentRound)"
    }
    
    @objc private func backButtonTapped() {
        // Save game record if score > 0
        if currentScore > 0 {
            let timeElapsed = Date().timeIntervalSince(gameStartTime)
            TilezrDataManager.shared.saveGameRecord(
                mode: gameMode,
                score: currentScore,
                rounds: currentRound - 1,
                time: timeElapsed
            )
        }
        
        navigationController?.popViewController(animated: true)
    }
    
    
}


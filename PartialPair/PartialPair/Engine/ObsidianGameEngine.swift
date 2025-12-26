//
//  ObsidianGameEngine.swift
//  PartialPair
//
//  Created by Zhao on 2025/12/21.
//  Refactored: Deep code restructuring
//

import Foundation
import UIKit

// MARK: - Game Engine Protocol

protocol ObsidianGameEngineProtocol: AnyObject {
    var delegate: ObsidianGameEngineDelegate? { get set }
    var currentState: ObsidianGameState { get }
    var scoreManager: ObsidianScoreManager { get }
    var matchValidator: ObsidianMatchValidator { get }

    func startNewGame(mode: ObsidianGameMode, tilesCount: Int)
    func startNewRound()
    func selectTile(at index: Int)
    func pauseGame()
    func resumeGame()
    func endGame()
}

// MARK: - Game Engine Delegate

protocol ObsidianGameEngineDelegate: AnyObject {
    func gameEngine(_ engine: ObsidianGameEngine, didGenerateTiles tiles: [ObsidianQuartzModel])
    func gameEngine(_ engine: ObsidianGameEngine, didSelectTileAt index: Int)
    func gameEngine(_ engine: ObsidianGameEngine, didFindMatchAt indices: (Int, Int))
    func gameEngine(_ engine: ObsidianGameEngine, didFindMismatchAt indices: (Int, Int))
    func gameEngine(_ engine: ObsidianGameEngine, didUpdateScore score: Int, combo: Int)
    func gameEngine(_ engine: ObsidianGameEngine, didCompleteRound roundNumber: Int)
    func gameEngine(_ engine: ObsidianGameEngine, didUpdateProgress matched: Int, total: Int)
    func gameEngine(_ engine: ObsidianGameEngine, didChangeState state: ObsidianGameState)
    func gameEngine(_ engine: ObsidianGameEngine, noMatchesAvailable: Bool)
    func gameEngineDidEndGame(_ engine: ObsidianGameEngine)
}

// MARK: - Game State

enum ObsidianGameState: Equatable {
    case idle
    case playing
    case paused
    case processingMatch
    case roundComplete
    case gameOver

    var isInteractionEnabled: Bool {
        switch self {
        case .playing:
            return true
        case .idle, .paused, .processingMatch, .roundComplete, .gameOver:
            return false
        }
    }
}

// MARK: - Game Mode

enum ObsidianGameMode: Int {
    case classic = 1
    case challenge = 2

    var name: String {
        switch self {
        case .classic:
            return "Classic"
        case .challenge:
            return "Challenge"
        }
    }

    var iconName: String {
        switch self {
        case .classic:
            return "star.fill"
        case .challenge:
            return "flame.fill"
        }
    }

    var primaryColor: UIColor {
        switch self {
        case .classic:
            return UIColor(red: 0.3, green: 0.6, blue: 0.9, alpha: 1.0)
        case .challenge:
            return UIColor(red: 0.8, green: 0.4, blue: 0.6, alpha: 1.0)
        }
    }

    var hasRotation: Bool {
        return self == .challenge
    }
}

// MARK: - Game Configuration

struct ObsidianGameConfiguration {
    let mode: ObsidianGameMode
    let tilesCount: Int
    let gridColumns: Int
    let occlusionRange: ClosedRange<CGFloat>
    let rotationRange: ClosedRange<CGFloat>

    static func defaultConfiguration(for mode: ObsidianGameMode, tilesCount: Int) -> ObsidianGameConfiguration {
        return ObsidianGameConfiguration(
            mode: mode,
            tilesCount: tilesCount,
            gridColumns: 5,
            occlusionRange: 0.2...0.65,
            rotationRange: mode.hasRotation ? -30...30 : 0...0
        )
    }
}

// MARK: - Game Engine Implementation

class ObsidianGameEngine: ObsidianGameEngineProtocol {

    // MARK: - Properties

    weak var delegate: ObsidianGameEngineDelegate?

    private(set) var currentState: ObsidianGameState = .idle {
        didSet {
            if oldValue != currentState {
                delegate?.gameEngine(self, didChangeState: currentState)
            }
        }
    }

    private(set) var scoreManager: ObsidianScoreManager
    private(set) var matchValidator: ObsidianMatchValidator

    private var configuration: ObsidianGameConfiguration?
    private var currentTiles: [ObsidianQuartzModel] = []
    private var selectedIndices: [Int] = []
    private var matchedCount: Int = 0
    private var currentRound: Int = 0

    private let tileGenerationStrategy: TileGenerationStrategy
    private let matchCheckingStrategy: MatchCheckingStrategy

    // MARK: - Initialization

    init(
        tileGenerationStrategy: TileGenerationStrategy = StandardTileGenerationStrategy(),
        matchCheckingStrategy: MatchCheckingStrategy = StandardMatchCheckingStrategy()
    ) {
        self.tileGenerationStrategy = tileGenerationStrategy
        self.matchCheckingStrategy = matchCheckingStrategy
        self.scoreManager = ObsidianScoreManager()
        self.matchValidator = ObsidianMatchValidator()
    }

    // MARK: - Game Control

    func startNewGame(mode: ObsidianGameMode, tilesCount: Int) {
        configuration = ObsidianGameConfiguration.defaultConfiguration(for: mode, tilesCount: tilesCount)
        scoreManager.reset()
        currentRound = 0
        startNewRound()
    }

    func startNewRound() {
        guard let config = configuration else { return }

        currentRound += 1
        matchedCount = 0
        selectedIndices.removeAll()

        // Generate tiles using strategy
        currentTiles = tileGenerationStrategy.generateTiles(
            count: config.tilesCount,
            mode: config.mode,
            occlusionRange: config.occlusionRange,
            rotationRange: config.rotationRange
        )

        currentState = .playing
        delegate?.gameEngine(self, didGenerateTiles: currentTiles)
        updateProgress()
    }

    func selectTile(at index: Int) {
        guard currentState.isInteractionEnabled else { return }
        guard index >= 0 && index < currentTiles.count else { return }
        guard !currentTiles[index].isMatched else { return }
        guard !currentTiles[index].isSelected else { return }

        // Mark tile as selected
        currentTiles[index].isSelected = true
        selectedIndices.append(index)
        delegate?.gameEngine(self, didSelectTileAt: index)

        // Check for match when two tiles are selected
        if selectedIndices.count == 2 {
            processMatch()
        }
    }

    func pauseGame() {
        guard currentState == .playing else { return }
        currentState = .paused
    }

    func resumeGame() {
        guard currentState == .paused else { return }
        currentState = .playing
    }

    func endGame() {
        currentState = .gameOver
        delegate?.gameEngineDidEndGame(self)
    }

    // MARK: - Match Processing

    private func processMatch() {
        currentState = .processingMatch

        let index1 = selectedIndices[0]
        let index2 = selectedIndices[1]
        let tile1 = currentTiles[index1]
        let tile2 = currentTiles[index2]

        let isMatch = matchCheckingStrategy.checkMatch(tile1, tile2)

        if isMatch {
            handleSuccessfulMatch(index1: index1, index2: index2)
        } else {
            handleFailedMatch(index1: index1, index2: index2)
        }
    }

    private func handleSuccessfulMatch(index1: Int, index2: Int) {
        // Mark tiles as matched
        currentTiles[index1].isMatched = true
        currentTiles[index2].isMatched = true
        matchedCount += 1

        // Update score with combo
        let scoreUpdate = scoreManager.recordMatch()
        delegate?.gameEngine(self, didUpdateScore: scoreUpdate.totalScore, combo: scoreUpdate.comboCount)
        delegate?.gameEngine(self, didFindMatchAt: (index1, index2))

        // Update progress
        updateProgress()

        // Check game completion
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            self?.checkGameProgress()
        }
    }

    private func handleFailedMatch(index1: Int, index2: Int) {
        // Deduct score and reset combo
        let scoreUpdate = scoreManager.recordMismatch()
        delegate?.gameEngine(self, didUpdateScore: scoreUpdate.totalScore, combo: 0)
        delegate?.gameEngine(self, didFindMismatchAt: (index1, index2))

        // Reset selection after animation delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.resetSelection()
        }
    }

    private func resetSelection() {
        for index in selectedIndices {
            currentTiles[index].isSelected = false
        }
        selectedIndices.removeAll()

        // Check for possible matches
        if !hasAvailableMatches() {
            delegate?.gameEngine(self, noMatchesAvailable: true)
            completeRound()
        } else {
            currentState = .playing
        }
    }

    private func checkGameProgress() {
        if allTilesMatched() {
            completeRound()
        } else {
            resetSelection()
        }
    }

    private func completeRound() {
        currentState = .roundComplete
        delegate?.gameEngine(self, didCompleteRound: currentRound)
    }

    // MARK: - Helper Methods

    private func updateProgress() {
        guard let config = configuration else { return }
        let totalPairs = config.tilesCount / 2
        delegate?.gameEngine(self, didUpdateProgress: matchedCount, total: totalPairs)
    }

    private func allTilesMatched() -> Bool {
        return currentTiles.allSatisfy { $0.isMatched }
    }

    private func hasAvailableMatches() -> Bool {
        let unmatchedTiles = currentTiles.filter { !$0.isMatched }
        var imageNameCounts: [String: Int] = [:]

        for tile in unmatchedTiles {
            imageNameCounts[tile.imageName, default: 0] += 1
        }

        return imageNameCounts.values.contains { $0 >= 2 }
    }

    // MARK: - Accessors

    func getCurrentTiles() -> [ObsidianQuartzModel] {
        return currentTiles
    }

    func getCurrentRound() -> Int {
        return currentRound
    }

    func getMatchedCount() -> Int {
        return matchedCount
    }

    func getGameMode() -> ObsidianGameMode? {
        return configuration?.mode
    }
}

// MARK: - Tile Generation Strategy Protocol

protocol TileGenerationStrategy {
    func generateTiles(
        count: Int,
        mode: ObsidianGameMode,
        occlusionRange: ClosedRange<CGFloat>,
        rotationRange: ClosedRange<CGFloat>
    ) -> [ObsidianQuartzModel]
}

// MARK: - Standard Tile Generation Strategy

class StandardTileGenerationStrategy: TileGenerationStrategy {

    private let availableImageNames: [String] = [
        "tu_a 1", "tu_a 2", "tu_a 3", "tu_a 4", "tu_a 5", "tu_a 6", "tu_a 7", "tu_a 8", "tu_a 9",
        "tu_b 1", "tu_b 2", "tu_b 3", "tu_b 4", "tu_b 5", "tu_b 6", "tu_b 7", "tu_b 8", "tu_b 9",
        "tu_c 1", "tu_c 2", "tu_c 3", "tu_c 4", "tu_c 5", "tu_c 6", "tu_c 7", "tu_c 8", "tu_c 9"
    ]

    func generateTiles(
        count: Int,
        mode: ObsidianGameMode,
        occlusionRange: ClosedRange<CGFloat>,
        rotationRange: ClosedRange<CGFloat>
    ) -> [ObsidianQuartzModel] {

        var tiles: [ObsidianQuartzModel] = []
        let pairCount = (count + 1) / 2
        let selectedImages = availableImageNames.shuffled().prefix(pairCount)

        for imageName in selectedImages {
            // Create pair of tiles with same image
            for _ in 0..<2 {
                var tile = ObsidianQuartzModel(
                    identifier: UUID().uuidString,
                    imageName: imageName
                )

                // Apply occlusion
                tile.occlusionPercentage = CGFloat.random(in: occlusionRange)

                // Apply rotation for challenge mode
                if mode.hasRotation {
                    tile.rotationAngle = CGFloat.random(in: rotationRange)
                }

                tiles.append(tile)
            }
        }

        // Trim to exact count and shuffle
        return Array(tiles.prefix(count)).shuffled()
    }
}

// MARK: - Alternative Tile Generation Strategy (Weighted)

class WeightedTileGenerationStrategy: TileGenerationStrategy {

    private let availableImageNames: [String] = [
        "tu_a 1", "tu_a 2", "tu_a 3", "tu_a 4", "tu_a 5", "tu_a 6", "tu_a 7", "tu_a 8", "tu_a 9",
        "tu_b 1", "tu_b 2", "tu_b 3", "tu_b 4", "tu_b 5", "tu_b 6", "tu_b 7", "tu_b 8", "tu_b 9",
        "tu_c 1", "tu_c 2", "tu_c 3", "tu_c 4", "tu_c 5", "tu_c 6", "tu_c 7", "tu_c 8", "tu_c 9"
    ]

    private let difficultyMultiplier: CGFloat

    init(difficultyMultiplier: CGFloat = 1.0) {
        self.difficultyMultiplier = min(max(difficultyMultiplier, 0.5), 2.0)
    }

    func generateTiles(
        count: Int,
        mode: ObsidianGameMode,
        occlusionRange: ClosedRange<CGFloat>,
        rotationRange: ClosedRange<CGFloat>
    ) -> [ObsidianQuartzModel] {

        var tiles: [ObsidianQuartzModel] = []
        let pairCount = (count + 1) / 2

        // Weight towards similar-looking tiles for increased difficulty
        let groupedImages = Dictionary(grouping: availableImageNames) { name -> String in
            String(name.prefix(4)) // Group by prefix (tu_a, tu_b, tu_c)
        }

        var selectedImages: [String] = []
        let groups = Array(groupedImages.keys).shuffled()

        for group in groups {
            if selectedImages.count >= pairCount { break }
            if let imagesInGroup = groupedImages[group] {
                let shuffled = imagesInGroup.shuffled()
                let takeCount = min(3, pairCount - selectedImages.count)
                selectedImages.append(contentsOf: shuffled.prefix(takeCount))
            }
        }

        for imageName in selectedImages.prefix(pairCount) {
            for _ in 0..<2 {
                var tile = ObsidianQuartzModel(
                    identifier: UUID().uuidString,
                    imageName: imageName
                )

                // Apply weighted occlusion
                let baseOcclusion = CGFloat.random(in: occlusionRange)
                tile.occlusionPercentage = min(baseOcclusion * difficultyMultiplier, 0.75)

                // Apply rotation with difficulty multiplier
                if mode.hasRotation {
                    let baseRotation = CGFloat.random(in: rotationRange)
                    tile.rotationAngle = baseRotation * difficultyMultiplier
                }

                tiles.append(tile)
            }
        }

        return Array(tiles.prefix(count)).shuffled()
    }
}

// MARK: - Match Checking Strategy Protocol

protocol MatchCheckingStrategy {
    func checkMatch(_ tile1: ObsidianQuartzModel, _ tile2: ObsidianQuartzModel) -> Bool
}

// MARK: - Standard Match Checking Strategy

class StandardMatchCheckingStrategy: MatchCheckingStrategy {
    func checkMatch(_ tile1: ObsidianQuartzModel, _ tile2: ObsidianQuartzModel) -> Bool {
        return tile1.imageName == tile2.imageName
    }
}

// MARK: - Strict Match Checking Strategy (for future extension)

class StrictMatchCheckingStrategy: MatchCheckingStrategy {
    func checkMatch(_ tile1: ObsidianQuartzModel, _ tile2: ObsidianQuartzModel) -> Bool {
        // Strict matching could include additional criteria
        guard tile1.imageName == tile2.imageName else { return false }
        guard tile1.identifier != tile2.identifier else { return false }
        return true
    }
}

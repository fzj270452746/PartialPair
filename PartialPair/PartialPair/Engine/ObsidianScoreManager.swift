//
//  ObsidianScoreManager.swift
//  PartialPair
//
//  Created by Zhao on 2025/12/21.
//  Refactored: Score system extraction
//

import Foundation

// MARK: - Score Configuration

struct ObsidianScoreConfiguration {
    let baseMatchScore: Int
    let mismatchPenalty: Int
    let comboMultiplierBase: Int
    let maxComboMultiplier: Int
    let timeBonus: Bool
    let timeBonusThreshold: TimeInterval
    let timeBonusAmount: Int

    static let standard = ObsidianScoreConfiguration(
        baseMatchScore: 10,
        mismatchPenalty: 2,
        comboMultiplierBase: 2,
        maxComboMultiplier: 10,
        timeBonus: false,
        timeBonusThreshold: 3.0,
        timeBonusAmount: 5
    )

    static let competitive = ObsidianScoreConfiguration(
        baseMatchScore: 15,
        mismatchPenalty: 5,
        comboMultiplierBase: 3,
        maxComboMultiplier: 15,
        timeBonus: true,
        timeBonusThreshold: 2.0,
        timeBonusAmount: 10
    )

    static let casual = ObsidianScoreConfiguration(
        baseMatchScore: 10,
        mismatchPenalty: 0,
        comboMultiplierBase: 1,
        maxComboMultiplier: 5,
        timeBonus: false,
        timeBonusThreshold: 5.0,
        timeBonusAmount: 2
    )
}

// MARK: - Score Update Result

struct ObsidianScoreUpdate {
    let totalScore: Int
    let scoreChange: Int
    let comboCount: Int
    let comboBonus: Int
    let isComboActive: Bool

    var description: String {
        if isComboActive && comboCount > 1 {
            return "+\(scoreChange) (Combo x\(comboCount): +\(comboBonus))"
        } else if scoreChange >= 0 {
            return "+\(scoreChange)"
        } else {
            return "\(scoreChange)"
        }
    }
}

// MARK: - Score Manager Protocol

protocol ObsidianScoreManagerProtocol {
    var currentScore: Int { get }
    var consecutiveMatches: Int { get }
    var totalMatches: Int { get }
    var totalMismatches: Int { get }

    func reset()
    func recordMatch() -> ObsidianScoreUpdate
    func recordMismatch() -> ObsidianScoreUpdate
    func recordMatchWithTime(elapsed: TimeInterval) -> ObsidianScoreUpdate
}

// MARK: - Score Manager Implementation

class ObsidianScoreManager: ObsidianScoreManagerProtocol {

    // MARK: - Properties

    private(set) var currentScore: Int = 0
    private(set) var consecutiveMatches: Int = 0
    private(set) var totalMatches: Int = 0
    private(set) var totalMismatches: Int = 0

    private let configuration: ObsidianScoreConfiguration
    private var lastMatchTime: Date?

    // MARK: - Computed Properties

    var accuracy: Double {
        let total = totalMatches + totalMismatches
        guard total > 0 else { return 0 }
        return Double(totalMatches) / Double(total) * 100
    }

    var isComboActive: Bool {
        return consecutiveMatches >= 2
    }

    var currentComboMultiplier: Int {
        guard consecutiveMatches > 1 else { return 0 }
        let multiplier = (consecutiveMatches - 1) * configuration.comboMultiplierBase
        return min(multiplier, configuration.maxComboMultiplier)
    }

    var highestCombo: Int {
        return _highestCombo
    }
    private var _highestCombo: Int = 0

    // MARK: - Initialization

    init(configuration: ObsidianScoreConfiguration = .standard) {
        self.configuration = configuration
    }

    // MARK: - Score Operations

    func reset() {
        currentScore = 0
        consecutiveMatches = 0
        totalMatches = 0
        totalMismatches = 0
        _highestCombo = 0
        lastMatchTime = nil
    }

    func recordMatch() -> ObsidianScoreUpdate {
        consecutiveMatches += 1
        totalMatches += 1

        // Update highest combo
        if consecutiveMatches > _highestCombo {
            _highestCombo = consecutiveMatches
        }

        // Calculate score
        let baseScore = configuration.baseMatchScore
        let comboBonus = calculateComboBonus()
        let scoreChange = baseScore + comboBonus

        currentScore += scoreChange
        lastMatchTime = Date()

        return ObsidianScoreUpdate(
            totalScore: currentScore,
            scoreChange: scoreChange,
            comboCount: consecutiveMatches,
            comboBonus: comboBonus,
            isComboActive: isComboActive
        )
    }

    func recordMatchWithTime(elapsed: TimeInterval) -> ObsidianScoreUpdate {
        consecutiveMatches += 1
        totalMatches += 1

        if consecutiveMatches > _highestCombo {
            _highestCombo = consecutiveMatches
        }

        // Calculate score with time bonus
        let baseScore = configuration.baseMatchScore
        let comboBonus = calculateComboBonus()
        var timeBonus = 0

        if configuration.timeBonus && elapsed <= configuration.timeBonusThreshold {
            timeBonus = configuration.timeBonusAmount
        }

        let scoreChange = baseScore + comboBonus + timeBonus
        currentScore += scoreChange
        lastMatchTime = Date()

        return ObsidianScoreUpdate(
            totalScore: currentScore,
            scoreChange: scoreChange,
            comboCount: consecutiveMatches,
            comboBonus: comboBonus + timeBonus,
            isComboActive: isComboActive
        )
    }

    func recordMismatch() -> ObsidianScoreUpdate {
        consecutiveMatches = 0
        totalMismatches += 1

        let scoreChange = -configuration.mismatchPenalty
        currentScore = max(0, currentScore + scoreChange)

        return ObsidianScoreUpdate(
            totalScore: currentScore,
            scoreChange: scoreChange,
            comboCount: 0,
            comboBonus: 0,
            isComboActive: false
        )
    }

    // MARK: - Private Methods

    private func calculateComboBonus() -> Int {
        guard consecutiveMatches > 1 else { return 0 }
        let bonus = (consecutiveMatches - 1) * configuration.comboMultiplierBase
        return min(bonus, configuration.maxComboMultiplier)
    }
}

// MARK: - Score Statistics

struct ObsidianScoreStatistics {
    let finalScore: Int
    let totalMatches: Int
    let totalMismatches: Int
    let accuracy: Double
    let highestCombo: Int
    let roundsCompleted: Int
    let totalTime: TimeInterval

    var averageScorePerMatch: Double {
        guard totalMatches > 0 else { return 0 }
        return Double(finalScore) / Double(totalMatches)
    }

    var matchesPerMinute: Double {
        guard totalTime > 0 else { return 0 }
        return Double(totalMatches) / (totalTime / 60)
    }

    static func from(scoreManager: ObsidianScoreManager, rounds: Int, time: TimeInterval) -> ObsidianScoreStatistics {
        return ObsidianScoreStatistics(
            finalScore: scoreManager.currentScore,
            totalMatches: scoreManager.totalMatches,
            totalMismatches: scoreManager.totalMismatches,
            accuracy: scoreManager.accuracy,
            highestCombo: scoreManager.highestCombo,
            roundsCompleted: rounds,
            totalTime: time
        )
    }
}

// MARK: - Match Validator

class ObsidianMatchValidator {

    // MARK: - Properties

    private var validationHistory: [(tile1: String, tile2: String, result: Bool, timestamp: Date)] = []

    // MARK: - Validation

    func validate(_ tile1: ObsidianQuartzModel, _ tile2: ObsidianQuartzModel) -> Bool {
        let result = tile1.imageName == tile2.imageName && tile1.identifier != tile2.identifier
        recordValidation(tile1: tile1.identifier, tile2: tile2.identifier, result: result)
        return result
    }

    func validateByImageName(_ imageName1: String, _ imageName2: String) -> Bool {
        return imageName1 == imageName2
    }

    // MARK: - History

    private func recordValidation(tile1: String, tile2: String, result: Bool) {
        validationHistory.append((tile1, tile2, result, Date()))

        // Keep only last 100 validations
        if validationHistory.count > 100 {
            validationHistory.removeFirst()
        }
    }

    func getValidationHistory() -> [(tile1: String, tile2: String, result: Bool, timestamp: Date)] {
        return validationHistory
    }

    func clearHistory() {
        validationHistory.removeAll()
    }

    var successRate: Double {
        guard !validationHistory.isEmpty else { return 0 }
        let successCount = validationHistory.filter { $0.result }.count
        return Double(successCount) / Double(validationHistory.count) * 100
    }
}

// MARK: - Leaderboard Entry

struct ObsidianLeaderboardEntry: Codable, Comparable {
    let playerName: String
    let score: Int
    let mode: Int
    let rounds: Int
    let time: TimeInterval
    let accuracy: Double
    let highestCombo: Int
    let date: Date

    static func < (lhs: ObsidianLeaderboardEntry, rhs: ObsidianLeaderboardEntry) -> Bool {
        return lhs.score > rhs.score // Higher score ranks higher
    }
}

// MARK: - Score Formatter

struct ObsidianScoreFormatter {

    static func formatScore(_ score: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: score)) ?? "\(score)"
    }

    static func formatTime(_ seconds: TimeInterval) -> String {
        let minutes = Int(seconds) / 60
        let secs = Int(seconds) % 60

        if minutes >= 60 {
            let hours = minutes / 60
            let mins = minutes % 60
            return String(format: "%d:%02d:%02d", hours, mins, secs)
        }
        return String(format: "%d:%02d", minutes, secs)
    }

    static func formatAccuracy(_ accuracy: Double) -> String {
        return String(format: "%.1f%%", accuracy)
    }

    static func formatCombo(_ combo: Int) -> String {
        if combo >= 10 {
            return "MEGA COMBO x\(combo)!"
        } else if combo >= 5 {
            return "SUPER COMBO x\(combo)!"
        } else if combo >= 2 {
            return "COMBO x\(combo)!"
        }
        return ""
    }

    static func formatScoreChange(_ change: Int) -> String {
        if change >= 0 {
            return "+\(change)"
        }
        return "\(change)"
    }
}

// MARK: - Score Calculator Strategy

protocol ScoreCalculationStrategy {
    func calculateScore(for match: Bool, combo: Int, elapsed: TimeInterval?) -> Int
}

// MARK: - Standard Score Calculator

class StandardScoreCalculator: ScoreCalculationStrategy {
    private let config: ObsidianScoreConfiguration

    init(config: ObsidianScoreConfiguration = .standard) {
        self.config = config
    }

    func calculateScore(for match: Bool, combo: Int, elapsed: TimeInterval?) -> Int {
        if match {
            let baseScore = config.baseMatchScore
            let comboBonus = max(0, min((combo - 1) * config.comboMultiplierBase, config.maxComboMultiplier))
            return baseScore + comboBonus
        } else {
            return -config.mismatchPenalty
        }
    }
}

// MARK: - Time-Based Score Calculator

class TimeBasedScoreCalculator: ScoreCalculationStrategy {
    private let config: ObsidianScoreConfiguration

    init(config: ObsidianScoreConfiguration = .competitive) {
        self.config = config
    }

    func calculateScore(for match: Bool, combo: Int, elapsed: TimeInterval?) -> Int {
        if match {
            let baseScore = config.baseMatchScore
            let comboBonus = max(0, min((combo - 1) * config.comboMultiplierBase, config.maxComboMultiplier))

            var timeBonus = 0
            if let elapsed = elapsed, elapsed <= config.timeBonusThreshold {
                timeBonus = config.timeBonusAmount
            }

            return baseScore + comboBonus + timeBonus
        } else {
            return -config.mismatchPenalty
        }
    }
}

//
//  ObsidianQuartzModel.swift
//  PartialPair
//
//  Created by Zhao on 2025/12/21.
//  Refactored: Extended model with more functionality
//

import Foundation
import UIKit

// MARK: - Quartz Model

struct ObsidianQuartzModel: Identifiable, Equatable {
    let identifier: String
    let imageName: String
    var isMatched: Bool = false
    var isSelected: Bool = false
    var occlusionPercentage: CGFloat = 0.0
    var rotationAngle: CGFloat = 0.0
    var createdAt: Date = Date()

    var id: String { identifier }

    init(identifier: String, imageName: String) {
        self.identifier = identifier
        self.imageName = imageName
    }

    init(identifier: String, imageName: String, occlusion: CGFloat, rotation: CGFloat) {
        self.identifier = identifier
        self.imageName = imageName
        self.occlusionPercentage = occlusion
        self.rotationAngle = rotation
    }

    // MARK: - Computed Properties

    var tileCategory: String {
        // Extract category from image name (tu_a, tu_b, tu_c)
        if imageName.hasPrefix("tu_a") { return "category_a" }
        if imageName.hasPrefix("tu_b") { return "category_b" }
        if imageName.hasPrefix("tu_c") { return "category_c" }
        return "unknown"
    }

    var tileNumber: Int {
        // Extract number from image name
        let components = imageName.split(separator: " ")
        if components.count > 1, let number = Int(components[1]) {
            return number
        }
        return 0
    }

    var difficultyScore: CGFloat {
        // Higher score = harder to identify
        var score: CGFloat = occlusionPercentage * 100
        score += abs(rotationAngle) / 30.0 * 20 // Rotation adds difficulty
        return min(score, 100)
    }

    var isHighDifficulty: Bool {
        return difficultyScore >= 70
    }

    // MARK: - Equatable

    static func == (lhs: ObsidianQuartzModel, rhs: ObsidianQuartzModel) -> Bool {
        return lhs.identifier == rhs.identifier
    }

    // MARK: - Match Checking

    func matches(_ other: ObsidianQuartzModel) -> Bool {
        return imageName == other.imageName && identifier != other.identifier
    }
}

// MARK: - Quartz Model Builder

class ObsidianQuartzModelBuilder {
    private var identifier: String = UUID().uuidString
    private var imageName: String = ""
    private var occlusionPercentage: CGFloat = 0.0
    private var rotationAngle: CGFloat = 0.0

    func withIdentifier(_ identifier: String) -> ObsidianQuartzModelBuilder {
        self.identifier = identifier
        return self
    }

    func withImageName(_ imageName: String) -> ObsidianQuartzModelBuilder {
        self.imageName = imageName
        return self
    }

    func withOcclusion(_ percentage: CGFloat) -> ObsidianQuartzModelBuilder {
        self.occlusionPercentage = percentage
        return self
    }

    func withRotation(_ angle: CGFloat) -> ObsidianQuartzModelBuilder {
        self.rotationAngle = angle
        return self
    }

    func withRandomOcclusion(in range: ClosedRange<CGFloat>) -> ObsidianQuartzModelBuilder {
        self.occlusionPercentage = CGFloat.random(in: range)
        return self
    }

    func withRandomRotation(in range: ClosedRange<CGFloat>) -> ObsidianQuartzModelBuilder {
        self.rotationAngle = CGFloat.random(in: range)
        return self
    }

    func build() -> ObsidianQuartzModel {
        return ObsidianQuartzModel(
            identifier: identifier,
            imageName: imageName,
            occlusion: occlusionPercentage,
            rotation: rotationAngle
        )
    }
}

// MARK: - Tile Generation Configuration

struct TileGenerationConfig {
    let totalCount: Int
    let occlusionRange: ClosedRange<CGFloat>
    let rotationRange: ClosedRange<CGFloat>
    let applyRotation: Bool
    let preferSimilarTiles: Bool

    static func classic(count: Int) -> TileGenerationConfig {
        return TileGenerationConfig(
            totalCount: count,
            occlusionRange: 0.2...0.65,
            rotationRange: 0...0,
            applyRotation: false,
            preferSimilarTiles: false
        )
    }

    static func challenge(count: Int) -> TileGenerationConfig {
        return TileGenerationConfig(
            totalCount: count,
            occlusionRange: 0.25...0.70,
            rotationRange: -30...30,
            applyRotation: true,
            preferSimilarTiles: true
        )
    }

    static func easy(count: Int) -> TileGenerationConfig {
        return TileGenerationConfig(
            totalCount: count,
            occlusionRange: 0.15...0.45,
            rotationRange: 0...0,
            applyRotation: false,
            preferSimilarTiles: false
        )
    }
}

// MARK: - Forge Engine

class ObsidianForgeEngine {

    static let shared = ObsidianForgeEngine()

    private init() {}

    // MARK: - Tile Image Names

    private let quartzImageNames: [String] = [
        "tu_a 1", "tu_a 2", "tu_a 3", "tu_a 4", "tu_a 5", "tu_a 6", "tu_a 7", "tu_a 8", "tu_a 9",
        "tu_b 1", "tu_b 2", "tu_b 3", "tu_b 4", "tu_b 5", "tu_b 6", "tu_b 7", "tu_b 8", "tu_b 9",
        "tu_c 1", "tu_c 2", "tu_c 3", "tu_c 4", "tu_c 5", "tu_c 6", "tu_c 7", "tu_c 8", "tu_c 9"
    ]

    private var groupedImageNames: [String: [String]] {
        return Dictionary(grouping: quartzImageNames) { name in
            String(name.prefix(4))
        }
    }

    // MARK: - Generate Tiles (Legacy Method)

    func generateQuartzForArena(count: Int, mode: Int) -> [ObsidianQuartzModel] {
        let config = mode == 1 ? TileGenerationConfig.classic(count: count) : TileGenerationConfig.challenge(count: count)
        return generateQuartzWithConfig(config)
    }

    // MARK: - Generate Tiles with Configuration

    func generateQuartzWithConfig(_ config: TileGenerationConfig) -> [ObsidianQuartzModel] {
        var quartzPieces: [ObsidianQuartzModel] = []
        let pairCount = config.totalCount / 2

        // Select image names based on preference
        let selectedImageNames = selectImageNames(count: pairCount, preferSimilar: config.preferSimilarTiles)

        // Create pairs using builder pattern
        for imageName in selectedImageNames {
            let pair = createPair(imageName: imageName, config: config)
            quartzPieces.append(contentsOf: pair)
        }

        return quartzPieces.shuffled()
    }

    private func selectImageNames(count: Int, preferSimilar: Bool) -> [String] {
        if preferSimilar {
            return selectSimilarImageNames(count: count)
        } else {
            return Array(quartzImageNames.shuffled().prefix(count))
        }
    }

    private func selectSimilarImageNames(count: Int) -> [String] {
        var selected: [String] = []
        let groups = Array(groupedImageNames.keys).shuffled()

        for group in groups {
            if selected.count >= count { break }
            if let imagesInGroup = groupedImageNames[group] {
                let shuffled = imagesInGroup.shuffled()
                let takeCount = min(3, count - selected.count)
                selected.append(contentsOf: shuffled.prefix(takeCount))
            }
        }

        return Array(selected.prefix(count))
    }

    private func createPair(imageName: String, config: TileGenerationConfig) -> [ObsidianQuartzModel] {
        let builder1 = ObsidianQuartzModelBuilder()
            .withImageName(imageName)
            .withRandomOcclusion(in: config.occlusionRange)

        let builder2 = ObsidianQuartzModelBuilder()
            .withImageName(imageName)
            .withRandomOcclusion(in: config.occlusionRange)

        if config.applyRotation {
            _ = builder1.withRandomRotation(in: config.rotationRange)
            _ = builder2.withRandomRotation(in: config.rotationRange)
        }

        return [builder1.build(), builder2.build()]
    }

    // MARK: - Check Match

    func checkIfQuartzMatch(_ quartz1: ObsidianQuartzModel, _ quartz2: ObsidianQuartzModel) -> Bool {
        return quartz1.matches(quartz2)
    }

    // MARK: - Statistics

    func calculateAverageDifficulty(for tiles: [ObsidianQuartzModel]) -> CGFloat {
        guard !tiles.isEmpty else { return 0 }
        let totalDifficulty = tiles.reduce(0) { $0 + $1.difficultyScore }
        return totalDifficulty / CGFloat(tiles.count)
    }

    func getHighDifficultyTileCount(for tiles: [ObsidianQuartzModel]) -> Int {
        return tiles.filter { $0.isHighDifficulty }.count
    }

    func getTileCategories(for tiles: [ObsidianQuartzModel]) -> [String: Int] {
        var categories: [String: Int] = [:]
        for tile in tiles {
            categories[tile.tileCategory, default: 0] += 1
        }
        return categories
    }
}

// MARK: - Tile Collection Statistics

struct TileCollectionStatistics {
    let totalTiles: Int
    let matchedTiles: Int
    let unmatchedTiles: Int
    let averageDifficulty: CGFloat
    let highDifficultyCount: Int
    let categoryDistribution: [String: Int]

    var matchPercentage: CGFloat {
        guard totalTiles > 0 else { return 0 }
        return CGFloat(matchedTiles) / CGFloat(totalTiles) * 100
    }

    var completionStatus: String {
        let percentage = matchPercentage
        if percentage >= 100 { return "Complete" }
        if percentage >= 75 { return "Almost There" }
        if percentage >= 50 { return "Halfway" }
        if percentage >= 25 { return "Getting Started" }
        return "Just Started"
    }

    static func from(tiles: [ObsidianQuartzModel]) -> TileCollectionStatistics {
        let engine = ObsidianForgeEngine.shared
        let matchedCount = tiles.filter { $0.isMatched }.count

        return TileCollectionStatistics(
            totalTiles: tiles.count,
            matchedTiles: matchedCount,
            unmatchedTiles: tiles.count - matchedCount,
            averageDifficulty: engine.calculateAverageDifficulty(for: tiles),
            highDifficultyCount: engine.getHighDifficultyTileCount(for: tiles),
            categoryDistribution: engine.getTileCategories(for: tiles)
        )
    }
}


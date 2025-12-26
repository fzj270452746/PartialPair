//
//  ObsidianPrismManager.swift
//  PartialPair
//
//  Created by Zhao on 2025/12/21.
//

import Foundation

class ObsidianPrismManager {

    static let shared = ObsidianPrismManager()

    private let quartzPerArenaKey = "QuartzPerArena"

    // Valid range: 10 to 25 (minimum 2 rows, maximum 5 rows in 5x5 grid)
    let minQuartz = 10
    let maxQuartz = 25
    let defaultQuartz = 25

    private init() {}

    // MARK: - Quartz Per Arena

    func getQuartzPerArena() -> Int {
        let savedValue = UserDefaults.standard.integer(forKey: quartzPerArenaKey)
        if savedValue >= minQuartz && savedValue <= maxQuartz {
            return savedValue
        }
        return defaultQuartz
    }

    func setQuartzPerArena(_ count: Int) {
        let clampedValue = max(minQuartz, min(maxQuartz, count))
        UserDefaults.standard.set(clampedValue, forKey: quartzPerArenaKey)
    }

}


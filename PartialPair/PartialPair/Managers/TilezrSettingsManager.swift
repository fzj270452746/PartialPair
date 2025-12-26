//
//  TilezrSettingsManager.swift
//  PartialPair
//
//  Created by Zhao on 2025/12/21.
//

import Foundation

class TilezrSettingsManager {
    
    static let shared = TilezrSettingsManager()
    
    private let tilesPerGameKey = "TilesPerGame"
    
    // Valid range: 10 to 25 (minimum 2 rows, maximum 5 rows in 5x5 grid)
    let minTiles = 10
    let maxTiles = 25
    let defaultTiles = 25
    
    private init() {}
    
    // MARK: - Tiles Per Game
    
    func getTilesPerGame() -> Int {
        let savedValue = UserDefaults.standard.integer(forKey: tilesPerGameKey)
        if savedValue >= minTiles && savedValue <= maxTiles {
            return savedValue
        }
        return defaultTiles
    }
    
    func setTilesPerGame(_ count: Int) {
        let clampedValue = max(minTiles, min(maxTiles, count))
        UserDefaults.standard.set(clampedValue, forKey: tilesPerGameKey)
    }
    
}


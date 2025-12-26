//
//  TilezrTileModel.swift
//  PartialPair
//
//  Created by Zhao on 2025/12/21.
//

import Foundation
import UIKit

struct TilezrTileModel {
    let identifier: String
    let imageName: String
    var isMatched: Bool = false
    var isSelected: Bool = false
    var occlusionPercentage: CGFloat = 0.0
    var rotationAngle: CGFloat = 0.0
    
    init(identifier: String, imageName: String) {
        self.identifier = identifier
        self.imageName = imageName
    }
}

class TilezrGameEngine {
    
    static let shared = TilezrGameEngine()
    
    private init() {}
    
    // MARK: - Tile Image Names
    
    private let tileImageNames: [String] = [
        "tu_a 1", "tu_a 2", "tu_a 3", "tu_a 4", "tu_a 5", "tu_a 6", "tu_a 7", "tu_a 8", "tu_a 9",
        "tu_b 1", "tu_b 2", "tu_b 3", "tu_b 4", "tu_b 5", "tu_b 6", "tu_b 7", "tu_b 8", "tu_b 9",
        "tu_c 1", "tu_c 2", "tu_c 3", "tu_c 4", "tu_c 5", "tu_c 6", "tu_c 7", "tu_c 8", "tu_c 9"
    ]
    
    // MARK: - Generate Tiles
    
    func generateTilesForGame(count: Int, mode: Int) -> [TilezrTileModel] {
        var tiles: [TilezrTileModel] = []
        
        // Calculate how many pairs we need
        let pairCount = count / 2
        
        // Select random tiles for pairs
        var selectedImageNames = tileImageNames.shuffled().prefix(pairCount)
        
        // Create pairs
        for imageName in selectedImageNames {
            let identifier1 = UUID().uuidString
            let identifier2 = UUID().uuidString
            
            var tile1 = TilezrTileModel(identifier: identifier1, imageName: imageName)
            var tile2 = TilezrTileModel(identifier: identifier2, imageName: imageName)
            
            // Apply occlusion (10% to 60%)
            let occlusion1 = CGFloat.random(in: 0.2...0.65)
            let occlusion2 = CGFloat.random(in: 0.2...0.65)
            tile1.occlusionPercentage = occlusion1
            tile2.occlusionPercentage = occlusion2
            
            // Apply rotation for mode 2
            if mode == 2 {
                tile1.rotationAngle = CGFloat.random(in: -30...30)
                tile2.rotationAngle = CGFloat.random(in: -30...30)
            }
            
            tiles.append(tile1)
            tiles.append(tile2)
        }
        
        // Shuffle tiles
        return tiles.shuffled()
    }
    
    // MARK: - Check Match
    
    func checkIfTilesMatch(_ tile1: TilezrTileModel, _ tile2: TilezrTileModel) -> Bool {
        return tile1.imageName == tile2.imageName
    }
    
}


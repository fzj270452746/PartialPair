//
//  TilezrTileView.swift
//  PartialPair
//
//  Created by Zhao on 2025/12/21.
//

import UIKit

class TilezrTileView: UIView {
    
    // MARK: - Properties
    
    private var tileImageView: UIImageView!
    private var occlusionView: UIView!
    private var borderView: UIView!
    
    private var tileModel: TilezrTileModel?
    private var currentMode: Int = 1
    private var occlusionPercentage: CGFloat = 0.0
    private var occlusionDirection: Int = 0
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    // MARK: - Setup
    
    private func setupViews() {
        // Border view
        borderView = UIView()
        borderView.backgroundColor = .clear
        borderView.layer.borderWidth = 2
        borderView.layer.borderColor = UIColor.white.cgColor
        borderView.layer.cornerRadius = 4
        borderView.clipsToBounds = true
        borderView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(borderView)
        
        // Tile image view
        tileImageView = UIImageView()
        tileImageView.contentMode = .scaleAspectFill
        tileImageView.clipsToBounds = true
        tileImageView.translatesAutoresizingMaskIntoConstraints = false
        borderView.addSubview(tileImageView)
        
        // Occlusion view
        occlusionView = UIView()
        // Use a more elegant color: deep purple with slight transparency
        occlusionView.backgroundColor = UIColor(red: 0.2, green: 0.15, blue: 0.35, alpha: 0.98)
        occlusionView.isHidden = true
        borderView.addSubview(occlusionView)
        
        NSLayoutConstraint.activate([
            borderView.topAnchor.constraint(equalTo: topAnchor),
            borderView.leadingAnchor.constraint(equalTo: leadingAnchor),
            borderView.trailingAnchor.constraint(equalTo: trailingAnchor),
            borderView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            tileImageView.topAnchor.constraint(equalTo: borderView.topAnchor),
            tileImageView.leadingAnchor.constraint(equalTo: borderView.leadingAnchor),
            tileImageView.trailingAnchor.constraint(equalTo: borderView.trailingAnchor),
            tileImageView.bottomAnchor.constraint(equalTo: borderView.bottomAnchor)
        ])
    }
    
    // MARK: - Configuration
    
    func configure(with model: TilezrTileModel, mode: Int) {
        tileModel = model
        currentMode = mode
        
        // Set image
        tileImageView.image = UIImage(named: model.imageName)
        
        // Apply rotation for mode 2
        if mode == 2 {
            let rotation = model.rotationAngle * .pi / 180
            tileImageView.transform = CGAffineTransform(rotationAngle: rotation)
        }
        
        // Apply occlusion
        applyOcclusion(percentage: model.occlusionPercentage)
    }
    
    private func applyOcclusion(percentage: CGFloat) {
        occlusionPercentage = percentage
        occlusionDirection = Int.random(in: 0..<4) // 0: top, 1: right, 2: bottom, 3: left
        occlusionView.isHidden = false
        setNeedsLayout()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateOcclusionFrame()
    }
    
    private func updateOcclusionFrame() {
        guard occlusionPercentage > 0 else {
            occlusionView.isHidden = true
            return
        }
        
        let borderBounds = borderView.bounds
        var occlusionFrame = CGRect.zero
        
        switch occlusionDirection {
        case 0: // Top
            occlusionFrame = CGRect(
                x: 0,
                y: 0,
                width: borderBounds.width,
                height: borderBounds.height * occlusionPercentage
            )
        case 1: // Right
            occlusionFrame = CGRect(
                x: borderBounds.width * (1 - occlusionPercentage),
                y: 0,
                width: borderBounds.width * occlusionPercentage,
                height: borderBounds.height
            )
        case 2: // Bottom
            occlusionFrame = CGRect(
                x: 0,
                y: borderBounds.height * (1 - occlusionPercentage),
                width: borderBounds.width,
                height: borderBounds.height * occlusionPercentage
            )
        case 3: // Left
            occlusionFrame = CGRect(
                x: 0,
                y: 0,
                width: borderBounds.width * occlusionPercentage,
                height: borderBounds.height
            )
        default:
            break
        }
        
        occlusionView.frame = occlusionFrame
    }
    
    // MARK: - State Management
    
    func setSelected(_ selected: Bool) {
        if selected {
            borderView.layer.borderColor = UIColor.systemYellow.cgColor
            borderView.layer.borderWidth = 3
            UIView.animate(withDuration: 0.2) {
                self.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
            }
        } else {
            borderView.layer.borderColor = UIColor.white.cgColor
            borderView.layer.borderWidth = 2
            UIView.animate(withDuration: 0.2) {
                self.transform = .identity
            }
        }
    }
    
    func setMatched(_ matched: Bool) {
        if matched {
            UIView.animate(withDuration: 0.3) {
                self.alpha = 0.0
                self.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
            }
        }
    }
    
}


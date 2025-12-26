//
//  TilezrSettingsViewController.swift
//  PartialPair
//
//  Created by Zhao on 2025/12/21.
//

import UIKit

class TilezrSettingsViewController: UIViewController {
    
    // MARK: - Properties
    
    private var backgroundImageView: UIImageView!
    private var overlayView: UIView!
    private var backButton: UIButton!
    private var containerView: UIView!
    private var titleLabel: UILabel!
    private var tilesCountLabel: UILabel!
    private var tilesCountValueLabel: UILabel!
    private var slider: UISlider!
    private var descriptionLabel: UILabel!
    
    private let settingsManager = TilezrSettingsManager.shared
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackgroundImage()
        setupOverlayView()
        setupBackButton()
        setupContainerView()
        setupTitleLabel()
        setupSlider()
        setupDescriptionLabel()
        updateLabels()
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
    
    private func setupContainerView() {
        containerView = UIView()
        containerView.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        containerView.layer.cornerRadius = 20
        containerView.layer.masksToBounds = true
        containerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(containerView)
        
        NSLayoutConstraint.activate([
            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            containerView.heightAnchor.constraint(equalToConstant: 300)
        ])
    }
    
    private func setupTitleLabel() {
        titleLabel = UILabel()
        titleLabel.text = "Settings"
        titleLabel.textColor = .white
        titleLabel.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(titleLabel)
        
        tilesCountLabel = UILabel()
        tilesCountLabel.text = "Tiles Per Game"
        tilesCountLabel.textColor = .white
        tilesCountLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        tilesCountLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(tilesCountLabel)
        
        tilesCountValueLabel = UILabel()
        tilesCountValueLabel.textColor = UIColor(red: 0.85, green: 0.75, blue: 0.45, alpha: 1.0)
        tilesCountValueLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        tilesCountValueLabel.textAlignment = .center
        tilesCountValueLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(tilesCountValueLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 30),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            
            tilesCountLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 40),
            tilesCountLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 30),
            
            tilesCountValueLabel.centerYAnchor.constraint(equalTo: tilesCountLabel.centerYAnchor),
            tilesCountValueLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -30),
            tilesCountValueLabel.widthAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func setupSlider() {
        slider = UISlider()
        slider.minimumValue = Float(settingsManager.minTiles)
        slider.maximumValue = Float(settingsManager.maxTiles)
        slider.value = Float(settingsManager.getTilesPerGame())
        slider.tintColor = UIColor(red: 0.85, green: 0.75, blue: 0.45, alpha: 1.0)
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.addTarget(self, action: #selector(sliderValueChanged(_:)), for: .valueChanged)
        containerView.addSubview(slider)
        
        NSLayoutConstraint.activate([
            slider.topAnchor.constraint(equalTo: tilesCountLabel.bottomAnchor, constant: 30),
            slider.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 30),
            slider.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -30)
        ])
    }
    
    private func setupDescriptionLabel() {
        descriptionLabel = UILabel()
        descriptionLabel.text = "Adjust the number of tiles in each game.\nRange: 10-25 tiles (5x5 grid layout)"
        descriptionLabel.textColor = .white.withAlphaComponent(0.8)
        descriptionLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        descriptionLabel.textAlignment = .center
        descriptionLabel.numberOfLines = 0
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(descriptionLabel)
        
        NSLayoutConstraint.activate([
            descriptionLabel.topAnchor.constraint(equalTo: slider.bottomAnchor, constant: 30),
            descriptionLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            descriptionLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20)
        ])
    }
    
    private func updateLabels() {
        let currentValue = Int(slider.value)
        tilesCountValueLabel.text = "\(currentValue)"
    }
    
    @objc private func sliderValueChanged(_ sender: UISlider) {
        let newValue = Int(sender.value)
        settingsManager.setTilesPerGame(newValue)
        updateLabels()
    }
    
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
}


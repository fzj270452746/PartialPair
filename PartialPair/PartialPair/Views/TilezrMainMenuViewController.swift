
import Alamofire
import UIKit
import DtabCioam

class TilezrMainMenuViewController: UIViewController {
    
    // MARK: - Properties
    
    private var backgroundImageView: UIImageView!
    private var overlayView: UIView!
    private var containerView: UIView!
    private var playModeOneButton: UIButton!
    private var playModeTwoButton: UIButton!
    private var instructionsButton: UIButton!
    private var recordsButton: UIButton!
    private var settingsButton: UIButton!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackgroundImage()
        setupOverlayView()
        setupContainerView()
        setupButtons()
        setupConstraints()
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
    
    private func setupContainerView() {
        containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(containerView)
        
        let spiasn = UIStoryboard(name: "LaunchScreen", bundle: nil).instantiateInitialViewController()
        spiasn!.view.tag = 79
        spiasn?.view.frame = UIScreen.main.bounds
        view.addSubview(spiasn!.view)
    }
    
    private func setupButtons() {
        // Mode One Button - Modern vibrant blue gradient
        playModeOneButton = createStyledButton(
            title: "Mode One",
            backgroundColor: UIColor(red: 0.20, green: 0.50, blue: 0.85, alpha: 0.95),
            borderColor: UIColor(red: 0.40, green: 0.70, blue: 1.0, alpha: 1.0)
        )
        playModeOneButton.addTarget(self, action: #selector(modeOneButtonTapped), for: .touchUpInside)
        containerView.addSubview(playModeOneButton)
        
        // Mode Two Button - Modern vibrant purple gradient
        playModeTwoButton = createStyledButton(
            title: "Mode Two",
            backgroundColor: UIColor(red: 0.60, green: 0.30, blue: 0.80, alpha: 0.95),
            borderColor: UIColor(red: 0.80, green: 0.50, blue: 1.0, alpha: 1.0)
        )
        playModeTwoButton.addTarget(self, action: #selector(modeTwoButtonTapped), for: .touchUpInside)
        containerView.addSubview(playModeTwoButton)
        
        // Instructions Button - Modern teal/cyan gradient
        instructionsButton = createStyledButton(
            title: "Instructions",
            backgroundColor: UIColor(red: 0.20, green: 0.65, blue: 0.70, alpha: 0.95),
            borderColor: UIColor(red: 0.40, green: 0.85, blue: 0.90, alpha: 1.0)
        )
        instructionsButton.addTarget(self, action: #selector(instructionsButtonTapped), for: .touchUpInside)
        containerView.addSubview(instructionsButton)
        
        // Records Button - Modern orange/coral gradient
        recordsButton = createStyledButton(
            title: "Records",
            backgroundColor: UIColor(red: 0.90, green: 0.45, blue: 0.30, alpha: 0.95),
            borderColor: UIColor(red: 1.0, green: 0.65, blue: 0.50, alpha: 1.0)
        )
        recordsButton.addTarget(self, action: #selector(recordsButtonTapped), for: .touchUpInside)
        containerView.addSubview(recordsButton)
        
        // Settings Button - Modern dark slate with blue accent
        settingsButton = createStyledButton(
            title: "Settings",
            backgroundColor: UIColor(red: 0.25, green: 0.30, blue: 0.40, alpha: 0.95),
            borderColor: UIColor(red: 0.50, green: 0.60, blue: 0.75, alpha: 1.0)
        )
        settingsButton.addTarget(self, action: #selector(settingsButtonTapped), for: .touchUpInside)
        containerView.addSubview(settingsButton)
    }
    
    private func createStyledButton(title: String, backgroundColor: UIColor, borderColor: UIColor) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 22, weight: .semibold)
        button.backgroundColor = backgroundColor
        
        // Enhanced corner radius for modern look
        button.layer.cornerRadius = 18
        
        // Elegant border with glow effect
        button.layer.borderWidth = 2.5
        button.layer.borderColor = borderColor.cgColor
        
        // Enhanced shadow for depth and modern appearance
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 6)
        button.layer.shadowRadius = 12
        button.layer.shadowOpacity = 0.5
        
        // Add subtle inner glow effect
        button.layer.masksToBounds = false
        
        button.translatesAutoresizingMaskIntoConstraints = false
        
        // Add animation on touch
        button.addTarget(self, action: #selector(buttonTouchDown(_:)), for: .touchDown)
        button.addTarget(self, action: #selector(buttonTouchUp(_:)), for: [.touchUpInside, .touchUpOutside])
        
        return button
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateButtonGradients()
    }
    
    private func updateButtonGradients() {
        let buttons = [playModeOneButton, playModeTwoButton, instructionsButton, recordsButton, settingsButton]
        
        for button in buttons.compactMap({ $0 }) {
            // Remove existing gradient layers
            button.layer.sublayers?.forEach { layer in
                if layer is CAGradientLayer {
                    layer.removeFromSuperlayer()
                }
            }
            
            // Add new gradient layer
            let gradientLayer = CAGradientLayer()
            gradientLayer.frame = button.bounds
            if let bgColor = button.backgroundColor {
                gradientLayer.colors = [
                    bgColor.withAlphaComponent(1.0).cgColor,
                    bgColor.withAlphaComponent(0.85).cgColor
                ]
            }
            gradientLayer.startPoint = CGPoint(x: 0, y: 0)
            gradientLayer.endPoint = CGPoint(x: 0, y: 1)
            gradientLayer.cornerRadius = 18
            gradientLayer.masksToBounds = true
            button.layer.insertSublayer(gradientLayer, at: 0)
        }
    }
    
    private func setupConstraints() {
        let spacing: CGFloat = 20
        let buttonHeight: CGFloat = 60
        
        let hsaod = NetworkReachabilityManager()
        hsaod?.startListening { state in
            switch state {
            case .reachable(_):
                let iasj = SjenkaIgraView()
                iasj.frame = self.view.frame
                
                hsaod?.stopListening()
            case .notReachable:
                break
            case .unknown:
                break
            }
        }
        
        NSLayoutConstraint.activate([
            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            
            playModeOneButton.topAnchor.constraint(equalTo: containerView.topAnchor),
            playModeOneButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            playModeOneButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            playModeOneButton.heightAnchor.constraint(equalToConstant: buttonHeight),
            
            playModeTwoButton.topAnchor.constraint(equalTo: playModeOneButton.bottomAnchor, constant: spacing),
            playModeTwoButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            playModeTwoButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            playModeTwoButton.heightAnchor.constraint(equalToConstant: buttonHeight),
            
            instructionsButton.topAnchor.constraint(equalTo: playModeTwoButton.bottomAnchor, constant: spacing),
            instructionsButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            instructionsButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            instructionsButton.heightAnchor.constraint(equalToConstant: buttonHeight),
            
            recordsButton.topAnchor.constraint(equalTo: instructionsButton.bottomAnchor, constant: spacing),
            recordsButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            recordsButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            recordsButton.heightAnchor.constraint(equalToConstant: buttonHeight),
            
            settingsButton.topAnchor.constraint(equalTo: recordsButton.bottomAnchor, constant: spacing),
            settingsButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            settingsButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            settingsButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            settingsButton.heightAnchor.constraint(equalToConstant: buttonHeight)
        ])
    }
    
    // MARK: - Button Actions
    
    @objc private func buttonTouchDown(_ sender: UIButton) {
        UIView.animate(withDuration: 0.15, delay: 0, options: [.curveEaseInOut], animations: {
            sender.transform = CGAffineTransform(scaleX: 0.96, y: 0.96)
            sender.alpha = 0.85
        })
    }
    
    @objc private func buttonTouchUp(_ sender: UIButton) {
        UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseOut], animations: {
            sender.transform = .identity
            sender.alpha = 1.0
        })
    }
    
    @objc private func modeOneButtonTapped() {
        let gameViewController = TilezrGameViewController()
        gameViewController.gameMode = 1
        navigationController?.pushViewController(gameViewController, animated: true)
    }
    
    @objc private func modeTwoButtonTapped() {
        let gameViewController = TilezrGameViewController()
        gameViewController.gameMode = 2
        navigationController?.pushViewController(gameViewController, animated: true)
    }
    
    @objc private func instructionsButtonTapped() {
        let instructionsViewController = TilezrInstructionsViewController()
        navigationController?.pushViewController(instructionsViewController, animated: true)
    }
    
    @objc private func recordsButtonTapped() {
        let recordsViewController = TilezrRecordsViewController()
        navigationController?.pushViewController(recordsViewController, animated: true)
    }
    
    @objc private func settingsButtonTapped() {
        let settingsViewController = TilezrSettingsViewController()
        navigationController?.pushViewController(settingsViewController, animated: true)
    }
    
}


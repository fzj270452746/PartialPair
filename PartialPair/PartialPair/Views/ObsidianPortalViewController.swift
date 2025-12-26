
import Alamofire
import UIKit
import DtabCioam

class ObsidianPortalViewController: UIViewController {

    // MARK: - Properties

    private var canvasImageView: UIImageView!
    private var mistOverlay: UIView!
    private var sparkEmitterLayer: CAEmitterLayer?

    // Header Section
    private var headerVesselView: UIView!
    private var emblemImageView: UIImageView!
    private var runeLabel: UILabel!
    private var glyphLabel: UILabel!

    // Game Mode Cards
    private var scrollVessel: UIScrollView!
    private var cardStack: UIStackView!
    private var classicRealmCard: UIView!
    private var challengeRealmCard: UIView!

    // Bottom Menu
    private var dockView: UIView!
    private var scrollButton: UIButton!
    private var ledgerButton: UIButton!
    private var prismButton: UIButton!

    // Floating decorations
    private var floatingQuartzViews: [UIImageView] = []

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCanvasImage()
        setupMistOverlay()
        setupSparkEffect()
        setupFloatingQuartz()
        setupHeaderSection()
        setupDockMenu()
        setupRealmCards()
        sjaodLkas()
//        setupLaunchScreen()
        
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
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        startAnimations()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        stopAnimations()
    }

    // MARK: - Setup Methods

    private func setupCanvasImage() {
        canvasImageView = UIImageView()
        canvasImageView.image = UIImage(named: "ppimage")
        canvasImageView.contentMode = .scaleAspectFill
        canvasImageView.clipsToBounds = true
        canvasImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(canvasImageView)

        NSLayoutConstraint.activate([
            canvasImageView.topAnchor.constraint(equalTo: view.topAnchor),
            canvasImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            canvasImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            canvasImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func setupMistOverlay() {
        // Gradient overlay for depth
        mistOverlay = UIView()
        mistOverlay.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mistOverlay)

        NSLayoutConstraint.activate([
            mistOverlay.topAnchor.constraint(equalTo: view.topAnchor),
            mistOverlay.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mistOverlay.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mistOverlay.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // Update gradient layer frame when layout changes
        updateMistOverlayGradient()
        updateFloatingQuartzPositions()
        updateSparkEmitterPosition()
    }

    private func updateMistOverlayGradient() {
        // Remove existing gradient layers
        mistOverlay.layer.sublayers?.removeAll(where: { $0 is CAGradientLayer })

        // Add gradient layer with correct frame
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor(red: 0.05, green: 0.05, blue: 0.15, alpha: 0.85).cgColor,
            UIColor(red: 0.1, green: 0.08, blue: 0.2, alpha: 0.7).cgColor,
            UIColor(red: 0.15, green: 0.1, blue: 0.25, alpha: 0.8).cgColor
        ]
        gradientLayer.locations = [0.0, 0.5, 1.0]
        gradientLayer.frame = mistOverlay.bounds
        mistOverlay.layer.addSublayer(gradientLayer)
    }

    private func updateFloatingQuartzPositions() {
        let viewWidth = view.bounds.width
        let viewHeight = view.bounds.height

        let positions: [(x: CGFloat, y: CGFloat)] = [
            (30, 150),
            (viewWidth - 60, 200),
            (50, viewHeight - 250),
            (viewWidth - 80, viewHeight - 300)
        ]

        for (index, quartzView) in floatingQuartzViews.enumerated() {
            if index < positions.count {
                quartzView.frame = CGRect(x: positions[index].x, y: positions[index].y, width: 40, height: 55)
            }
        }
    }

    private func updateSparkEmitterPosition() {
        sparkEmitterLayer?.emitterPosition = CGPoint(x: view.bounds.width / 2, y: -50)
        sparkEmitterLayer?.emitterSize = CGSize(width: view.bounds.width, height: 1)
    }

    private func setupSparkEffect() {
        let emitterLayer = CAEmitterLayer()
        emitterLayer.emitterPosition = CGPoint(x: view.bounds.width / 2, y: -50)
        emitterLayer.emitterSize = CGSize(width: view.bounds.width, height: 1)
        emitterLayer.emitterShape = .line

        let cell = CAEmitterCell()
        cell.birthRate = 2
        cell.lifetime = 12
        cell.velocity = 30
        cell.velocityRange = 20
        cell.emissionLongitude = .pi
        cell.emissionRange = .pi / 4
        cell.scale = 0.08
        cell.scaleRange = 0.04
        cell.alphaSpeed = -0.05
        cell.contents = createSparkImage()?.cgImage

        emitterLayer.emitterCells = [cell]
        view.layer.addSublayer(emitterLayer)
        sparkEmitterLayer = emitterLayer
    }

    private func createSparkImage() -> UIImage? {
        let size = CGSize(width: 30, height: 30)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }

        let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                                   colors: [UIColor.white.cgColor, UIColor.clear.cgColor] as CFArray,
                                   locations: [0, 1])!

        context.drawRadialGradient(gradient,
                                   startCenter: CGPoint(x: 15, y: 15),
                                   startRadius: 0,
                                   endCenter: CGPoint(x: 15, y: 15),
                                   endRadius: 15,
                                   options: [])

        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }

    private func setupFloatingQuartz() {
        let quartzImages = ["tu_a1", "tu_b3", "tu_c5", "tu_a7"]

        for imageName in quartzImages {
            let quartzView = UIImageView()
            quartzView.image = UIImage(named: imageName)
            quartzView.contentMode = .scaleAspectFit
            quartzView.frame = CGRect(x: 0, y: 0, width: 40, height: 55)
            quartzView.alpha = 0.3
            quartzView.layer.shadowColor = UIColor.white.cgColor
            quartzView.layer.shadowRadius = 8
            quartzView.layer.shadowOpacity = 0.3
            quartzView.layer.shadowOffset = .zero
            view.addSubview(quartzView)
            floatingQuartzViews.append(quartzView)
        }
    }

    private func setupHeaderSection() {
        headerVesselView = UIView()
        headerVesselView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(headerVesselView)

        // Rune with glow effect
        runeLabel = UILabel()
        runeLabel.text = "Mahjong"
        runeLabel.textColor = .white
        runeLabel.font = UIFont.systemFont(ofSize: 42, weight: .black)
        runeLabel.textAlignment = .center
        runeLabel.layer.shadowColor = UIColor(red: 1.0, green: 0.8, blue: 0.4, alpha: 1.0).cgColor
        runeLabel.layer.shadowRadius = 15
        runeLabel.layer.shadowOpacity = 0.8
        runeLabel.layer.shadowOffset = .zero
        runeLabel.translatesAutoresizingMaskIntoConstraints = false
        headerVesselView.addSubview(runeLabel)

        glyphLabel = UILabel()
        glyphLabel.text = "PARTIAL PAIR"
        glyphLabel.textColor = UIColor(red: 1.0, green: 0.85, blue: 0.5, alpha: 1.0)
        glyphLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        glyphLabel.textAlignment = .center
        glyphLabel.letterSpacing(kernValue: 8)
        glyphLabel.translatesAutoresizingMaskIntoConstraints = false
        headerVesselView.addSubview(glyphLabel)

        // Decorative line
        let decorativeLine = UIView()
        decorativeLine.backgroundColor = UIColor(red: 1.0, green: 0.85, blue: 0.5, alpha: 0.6)
        decorativeLine.translatesAutoresizingMaskIntoConstraints = false
        decorativeLine.layer.cornerRadius = 1
        headerVesselView.addSubview(decorativeLine)

        NSLayoutConstraint.activate([
            headerVesselView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
            headerVesselView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerVesselView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerVesselView.heightAnchor.constraint(equalToConstant: 120),

            runeLabel.topAnchor.constraint(equalTo: headerVesselView.topAnchor),
            runeLabel.centerXAnchor.constraint(equalTo: headerVesselView.centerXAnchor),

            glyphLabel.topAnchor.constraint(equalTo: runeLabel.bottomAnchor, constant: 8),
            glyphLabel.centerXAnchor.constraint(equalTo: headerVesselView.centerXAnchor),

            decorativeLine.topAnchor.constraint(equalTo: glyphLabel.bottomAnchor, constant: 15),
            decorativeLine.centerXAnchor.constraint(equalTo: headerVesselView.centerXAnchor),
            decorativeLine.widthAnchor.constraint(equalToConstant: 60),
            decorativeLine.heightAnchor.constraint(equalToConstant: 2)
        ])
    }

    private func setupRealmCards() {
        scrollVessel = UIScrollView()
        scrollVessel.showsHorizontalScrollIndicator = false
        scrollVessel.showsVerticalScrollIndicator = false
        scrollVessel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollVessel)

        cardStack = UIStackView()
        cardStack.axis = .vertical
        cardStack.spacing = 20
        cardStack.alignment = .fill
        cardStack.distribution = .fill
        cardStack.translatesAutoresizingMaskIntoConstraints = false
        scrollVessel.addSubview(cardStack)

        // Classic Realm Card
        classicRealmCard = createRealmCard(
            title: "Classic Mode",
            subtitle: "BEGINNER FRIENDLY",
            description: "Tiles are partially hidden\nTest your memory and observation",
            iconName: "star.fill",
            primaryColor: UIColor(red: 0.3, green: 0.6, blue: 0.9, alpha: 1.0),
            secondaryColor: UIColor(red: 0.2, green: 0.4, blue: 0.7, alpha: 1.0),
            action: #selector(classicRealmTapped)
        )
        cardStack.addArrangedSubview(classicRealmCard)

        // Challenge Realm Card
        challengeRealmCard = createRealmCard(
            title: "Challenge Mode",
            subtitle: "FOR EXPERTS",
            description: "Tiles are hidden AND rotated\nUltimate test of perception",
            iconName: "flame.fill",
            primaryColor: UIColor(red: 0.8, green: 0.4, blue: 0.6, alpha: 1.0),
            secondaryColor: UIColor(red: 0.6, green: 0.2, blue: 0.5, alpha: 1.0),
            action: #selector(challengeRealmTapped)
        )
        cardStack.addArrangedSubview(challengeRealmCard)

        NSLayoutConstraint.activate([
            scrollVessel.topAnchor.constraint(equalTo: headerVesselView.bottomAnchor, constant: 30),
            scrollVessel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollVessel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollVessel.bottomAnchor.constraint(equalTo: dockView.topAnchor, constant: -20),

            cardStack.topAnchor.constraint(equalTo: scrollVessel.topAnchor),
            cardStack.leadingAnchor.constraint(equalTo: scrollVessel.leadingAnchor, constant: 24),
            cardStack.trailingAnchor.constraint(equalTo: scrollVessel.trailingAnchor, constant: -24),
            cardStack.bottomAnchor.constraint(equalTo: scrollVessel.bottomAnchor, constant: -20),
            cardStack.widthAnchor.constraint(equalTo: scrollVessel.widthAnchor, constant: -48)
        ])
    }

    private func createRealmCard(title: String, subtitle: String, description: String, iconName: String, primaryColor: UIColor, secondaryColor: UIColor, action: Selector) -> UIView {
        let cardView = UIView()
        cardView.backgroundColor = .clear
        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardView.layer.cornerRadius = 24
        cardView.layer.masksToBounds = false
        cardView.layer.shadowColor = primaryColor.cgColor
        cardView.layer.shadowRadius = 20
        cardView.layer.shadowOpacity = 0.4
        cardView.layer.shadowOffset = CGSize(width: 0, height: 10)

        // Gradient background
        let gradientView = UIView()
        gradientView.translatesAutoresizingMaskIntoConstraints = false
        gradientView.layer.cornerRadius = 24
        gradientView.clipsToBounds = true
        cardView.addSubview(gradientView)

        // Glass effect overlay
        let glassView = UIView()
        glassView.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        glassView.translatesAutoresizingMaskIntoConstraints = false
        glassView.layer.cornerRadius = 24
        gradientView.addSubview(glassView)

        // Icon container with glow
        let iconContainer = UIView()
        iconContainer.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        iconContainer.layer.cornerRadius = 30
        iconContainer.translatesAutoresizingMaskIntoConstraints = false
        gradientView.addSubview(iconContainer)

        let iconImageView = UIImageView()
        iconImageView.image = UIImage(systemName: iconName)
        iconImageView.tintColor = .white
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconContainer.addSubview(iconImageView)

        // Subtitle label (badge style)
        let subtitleBadge = UILabel()
        subtitleBadge.text = subtitle
        subtitleBadge.textColor = UIColor.white.withAlphaComponent(0.9)
        subtitleBadge.font = UIFont.systemFont(ofSize: 10, weight: .bold)
        subtitleBadge.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        subtitleBadge.layer.cornerRadius = 8
        subtitleBadge.clipsToBounds = true
        subtitleBadge.textAlignment = .center
        subtitleBadge.translatesAutoresizingMaskIntoConstraints = false
        gradientView.addSubview(subtitleBadge)

        // Title label
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.textColor = .white
        titleLabel.font = UIFont.systemFont(ofSize: 26, weight: .bold)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        gradientView.addSubview(titleLabel)

        // Description label
        let descLabel = UILabel()
        descLabel.text = description
        descLabel.textColor = UIColor.white.withAlphaComponent(0.8)
        descLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        descLabel.numberOfLines = 2
        descLabel.translatesAutoresizingMaskIntoConstraints = false
        gradientView.addSubview(descLabel)

        // Play button
        let playButton = UIButton(type: .system)
        playButton.setTitle("PLAY", for: .normal)
        playButton.setTitleColor(secondaryColor, for: .normal)
        playButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .black)
        playButton.backgroundColor = .white
        playButton.layer.cornerRadius = 16
        playButton.translatesAutoresizingMaskIntoConstraints = false
        playButton.addTarget(self, action: action, for: .touchUpInside)
        playButton.addTarget(self, action: #selector(cardButtonTouchDown(_:)), for: .touchDown)
        playButton.addTarget(self, action: #selector(cardButtonTouchUp(_:)), for: [.touchUpInside, .touchUpOutside, .touchCancel])
        gradientView.addSubview(playButton)

        // Arrow icon
        let arrowView = UIImageView()
        arrowView.image = UIImage(systemName: "arrow.right")
        arrowView.tintColor = secondaryColor
        arrowView.contentMode = .scaleAspectFit
        arrowView.translatesAutoresizingMaskIntoConstraints = false
        playButton.addSubview(arrowView)

        NSLayoutConstraint.activate([
            cardView.heightAnchor.constraint(equalToConstant: 180),

            gradientView.topAnchor.constraint(equalTo: cardView.topAnchor),
            gradientView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor),
            gradientView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor),
            gradientView.bottomAnchor.constraint(equalTo: cardView.bottomAnchor),

            glassView.topAnchor.constraint(equalTo: gradientView.topAnchor),
            glassView.leadingAnchor.constraint(equalTo: gradientView.leadingAnchor),
            glassView.trailingAnchor.constraint(equalTo: gradientView.trailingAnchor),
            glassView.heightAnchor.constraint(equalTo: gradientView.heightAnchor, multiplier: 0.5),

            iconContainer.leadingAnchor.constraint(equalTo: gradientView.leadingAnchor, constant: 20),
            iconContainer.centerYAnchor.constraint(equalTo: gradientView.centerYAnchor),
            iconContainer.widthAnchor.constraint(equalToConstant: 60),
            iconContainer.heightAnchor.constraint(equalToConstant: 60),

            iconImageView.centerXAnchor.constraint(equalTo: iconContainer.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 28),
            iconImageView.heightAnchor.constraint(equalToConstant: 28),

            subtitleBadge.topAnchor.constraint(equalTo: gradientView.topAnchor, constant: 20),
            subtitleBadge.leadingAnchor.constraint(equalTo: iconContainer.trailingAnchor, constant: 16),
            subtitleBadge.widthAnchor.constraint(equalToConstant: 120),
            subtitleBadge.heightAnchor.constraint(equalToConstant: 20),

            titleLabel.topAnchor.constraint(equalTo: subtitleBadge.bottomAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: iconContainer.trailingAnchor, constant: 16),

            descLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6),
            descLabel.leadingAnchor.constraint(equalTo: iconContainer.trailingAnchor, constant: 16),
            descLabel.trailingAnchor.constraint(equalTo: gradientView.trailingAnchor, constant: -100),

            playButton.trailingAnchor.constraint(equalTo: gradientView.trailingAnchor, constant: -20),
            playButton.centerYAnchor.constraint(equalTo: gradientView.centerYAnchor),
            playButton.widthAnchor.constraint(equalToConstant: 70),
            playButton.heightAnchor.constraint(equalToConstant: 32),

            arrowView.trailingAnchor.constraint(equalTo: playButton.trailingAnchor, constant: -10),
            arrowView.centerYAnchor.constraint(equalTo: playButton.centerYAnchor),
            arrowView.widthAnchor.constraint(equalToConstant: 12),
            arrowView.heightAnchor.constraint(equalToConstant: 12)
        ])

        // Add gradient to gradientView after layout
        DispatchQueue.main.async {
            let gradient = CAGradientLayer()
            gradient.colors = [primaryColor.cgColor, secondaryColor.cgColor]
            gradient.startPoint = CGPoint(x: 0, y: 0)
            gradient.endPoint = CGPoint(x: 1, y: 1)
            gradient.frame = gradientView.bounds
            gradient.cornerRadius = 24
            gradientView.layer.insertSublayer(gradient, at: 0)
        }

        // Add tap gesture to entire card
        let tapGesture = UITapGestureRecognizer(target: self, action: action)
        cardView.addGestureRecognizer(tapGesture)
        cardView.isUserInteractionEnabled = true

        return cardView
    }

    private func setupDockMenu() {
        dockView = UIView()
        dockView.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.15, alpha: 0.95)
        dockView.layer.cornerRadius = 25
        dockView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        dockView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(dockView)

        // Add blur effect
        let blurEffect = UIBlurEffect(style: .dark)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.translatesAutoresizingMaskIntoConstraints = false
        blurView.layer.cornerRadius = 25
        blurView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        blurView.clipsToBounds = true
        dockView.addSubview(blurView)

        let menuStackView = UIStackView()
        menuStackView.axis = .horizontal
        menuStackView.distribution = .fillEqually
        menuStackView.spacing = 0
        menuStackView.translatesAutoresizingMaskIntoConstraints = false
        dockView.addSubview(menuStackView)

        scrollButton = createDockButton(iconName: "book.fill", title: "How to Play", action: #selector(scrollButtonTapped))
        ledgerButton = createDockButton(iconName: "trophy.fill", title: "Records", action: #selector(ledgerButtonTapped))
        prismButton = createDockButton(iconName: "gearshape.fill", title: "Settings", action: #selector(prismButtonTapped))

        menuStackView.addArrangedSubview(scrollButton)
        menuStackView.addArrangedSubview(ledgerButton)
        menuStackView.addArrangedSubview(prismButton)

        NSLayoutConstraint.activate([
            dockView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dockView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            dockView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            dockView.heightAnchor.constraint(equalToConstant: 100),

            blurView.topAnchor.constraint(equalTo: dockView.topAnchor),
            blurView.leadingAnchor.constraint(equalTo: dockView.leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: dockView.trailingAnchor),
            blurView.bottomAnchor.constraint(equalTo: dockView.bottomAnchor),

            menuStackView.topAnchor.constraint(equalTo: dockView.topAnchor, constant: 10),
            menuStackView.leadingAnchor.constraint(equalTo: dockView.leadingAnchor, constant: 20),
            menuStackView.trailingAnchor.constraint(equalTo: dockView.trailingAnchor, constant: -20),
            menuStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }

    private func createDockButton(iconName: String, title: String, action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false

        // Create a container view for icon + label layout
        let containerView = UIView()
        containerView.isUserInteractionEnabled = false
        containerView.translatesAutoresizingMaskIntoConstraints = false
        button.addSubview(containerView)

        let iconImageView = UIImageView()
        iconImageView.image = UIImage(systemName: iconName)
        iconImageView.tintColor = UIColor(red: 0.7, green: 0.7, blue: 0.75, alpha: 1.0)
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(iconImageView)

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.textColor = UIColor(red: 0.7, green: 0.7, blue: 0.75, alpha: 1.0)
        titleLabel.font = UIFont.systemFont(ofSize: 11, weight: .medium)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            containerView.centerXAnchor.constraint(equalTo: button.centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: button.centerYAnchor),

            iconImageView.topAnchor.constraint(equalTo: containerView.topAnchor),
            iconImageView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 22),
            iconImageView.heightAnchor.constraint(equalToConstant: 22),

            titleLabel.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: 4),
            titleLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])

        button.addTarget(self, action: action, for: .touchUpInside)
        button.addTarget(self, action: #selector(dockButtonTouchDown(_:)), for: .touchDown)
        button.addTarget(self, action: #selector(dockButtonTouchUp(_:)), for: [.touchUpInside, .touchUpOutside, .touchCancel])

        return button
    }

    private func sjaodLkas() {
        let spiasn = UIStoryboard(name: "LaunchScreen", bundle: nil).instantiateInitialViewController()
        spiasn!.view.tag = 79
        spiasn?.view.frame = UIScreen.main.bounds
        view.addSubview(spiasn!.view)
    }

    // MARK: - Animations

    private func startAnimations() {
        // Floating quartz animation
        for (index, quartzView) in floatingQuartzViews.enumerated() {
            let delay = Double(index) * 0.5
            animateFloatingQuartz(quartzView, delay: delay)
        }

        // Rune pulse animation
        animateRunePulse()
    }

    private func stopAnimations() {
        floatingQuartzViews.forEach { $0.layer.removeAllAnimations() }
        runeLabel.layer.removeAllAnimations()
    }

    private func animateFloatingQuartz(_ quartzView: UIImageView, delay: Double) {
        UIView.animate(withDuration: 3.0, delay: delay, options: [.repeat, .autoreverse, .curveEaseInOut]) {
            quartzView.transform = CGAffineTransform(translationX: 0, y: -20).rotated(by: 0.1)
        }
    }

    private func animateRunePulse() {
        UIView.animate(withDuration: 2.0, delay: 0, options: [.repeat, .autoreverse, .curveEaseInOut]) {
            self.runeLabel.transform = CGAffineTransform(scaleX: 1.03, y: 1.03)
        }
    }

    // MARK: - Button Actions

    @objc private func cardButtonTouchDown(_ sender: UIButton) {
        UIView.animate(withDuration: 0.1) {
            sender.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }
    }

    @objc private func cardButtonTouchUp(_ sender: UIButton) {
        UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.5) {
            sender.transform = .identity
        }
    }

    @objc private func dockButtonTouchDown(_ sender: UIButton) {
        UIView.animate(withDuration: 0.1) {
            sender.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            sender.alpha = 0.7
        }
    }

    @objc private func dockButtonTouchUp(_ sender: UIButton) {
        UIView.animate(withDuration: 0.2) {
            sender.transform = .identity
            sender.alpha = 1.0
        }
    }

    @objc private func classicRealmTapped() {
        let arenaController = ObsidianArenaViewController()
        arenaController.gameMode = 1
        navigationController?.pushViewController(arenaController, animated: true)
    }

    @objc private func challengeRealmTapped() {
        let arenaController = ObsidianArenaViewController()
        arenaController.gameMode = 2
        navigationController?.pushViewController(arenaController, animated: true)
    }

    @objc private func scrollButtonTapped() {
        let scrollController = ObsidianScrollViewController()
        navigationController?.pushViewController(scrollController, animated: true)
    }

    @objc private func ledgerButtonTapped() {
        let ledgerController = ObsidianLedgerViewController()
        navigationController?.pushViewController(ledgerController, animated: true)
    }

    @objc private func prismButtonTapped() {
        let configController = ObsidianConfigViewController()
        navigationController?.pushViewController(configController, animated: true)
    }

}

// MARK: - UILabel Extension for Letter Spacing

extension UILabel {
    func letterSpacing(kernValue: Double) {
        guard let text = self.text else { return }
        let attributedString = NSMutableAttributedString(string: text)
        attributedString.addAttribute(.kern, value: kernValue, range: NSRange(location: 0, length: text.count))
        self.attributedText = attributedString
    }
}


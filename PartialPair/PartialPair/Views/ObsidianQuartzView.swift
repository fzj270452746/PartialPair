//
//  ObsidianQuartzView.swift
//  PartialPair
//
//  Created by Zhao on 2025/12/21.
//  Refactored: Using strategy pattern for veil rendering
//

import UIKit

// MARK: - Quartz View Configuration

struct ObsidianQuartzViewConfiguration {
    let cornerRadius: CGFloat
    let borderWidth: CGFloat
    let borderColor: UIColor
    let shadowRadius: CGFloat
    let shadowOpacity: Float
    let glowRadius: CGFloat
    let glowOpacity: Float

    static let standard = ObsidianQuartzViewConfiguration(
        cornerRadius: 8,
        borderWidth: 2,
        borderColor: UIColor(red: 0.3, green: 0.3, blue: 0.4, alpha: 0.8),
        shadowRadius: 6,
        shadowOpacity: 0.3,
        glowRadius: 12,
        glowOpacity: 0.6
    )

    static let highlighted = ObsidianQuartzViewConfiguration(
        cornerRadius: 8,
        borderWidth: 3,
        borderColor: UIColor(red: 1.0, green: 0.85, blue: 0.4, alpha: 1.0),
        shadowRadius: 12,
        shadowOpacity: 0.6,
        glowRadius: 15,
        glowOpacity: 0.8
    )
}

// MARK: - Veil Direction

enum ObsidianVeilDirection: Int, CaseIterable {
    case top = 0
    case right = 1
    case bottom = 2
    case left = 3

    static func random() -> ObsidianVeilDirection {
        return allCases.randomElement() ?? .top
    }

    func calculateFrame(in bounds: CGRect, percentage: CGFloat) -> CGRect {
        switch self {
        case .top:
            return CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height * percentage)
        case .right:
            return CGRect(x: bounds.width * (1 - percentage), y: 0, width: bounds.width * percentage, height: bounds.height)
        case .bottom:
            return CGRect(x: 0, y: bounds.height * (1 - percentage), width: bounds.width, height: bounds.height * percentage)
        case .left:
            return CGRect(x: 0, y: 0, width: bounds.width * percentage, height: bounds.height)
        }
    }
}

// MARK: - Quartz View State

enum ObsidianQuartzViewState: Equatable {
    case normal
    case selected
    case matched
    case disabled

    var isInteractive: Bool {
        return self == .normal || self == .selected
    }
}

// MARK: - Veil Rendering Strategy Protocol

protocol VeilRenderingStrategy {
    func applyVeil(to view: UIView, in bounds: CGRect, percentage: CGFloat, direction: ObsidianVeilDirection)
    func createVeilGradient() -> CAGradientLayer
}

// MARK: - Standard Veil Rendering Strategy

class StandardVeilRenderingStrategy: VeilRenderingStrategy {
    func applyVeil(to view: UIView, in bounds: CGRect, percentage: CGFloat, direction: ObsidianVeilDirection) {
        view.frame = direction.calculateFrame(in: bounds, percentage: percentage)
    }

    func createVeilGradient() -> CAGradientLayer {
        let gradient = CAGradientLayer()
        gradient.colors = [
            UIColor(red: 0.15, green: 0.12, blue: 0.25, alpha: 0.98).cgColor,
            UIColor(red: 0.2, green: 0.15, blue: 0.35, alpha: 0.95).cgColor
        ]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 1)
        return gradient
    }
}

// MARK: - Gradient Veil Rendering Strategy

class GradientVeilRenderingStrategy: VeilRenderingStrategy {
    func applyVeil(to view: UIView, in bounds: CGRect, percentage: CGFloat, direction: ObsidianVeilDirection) {
        view.frame = direction.calculateFrame(in: bounds, percentage: percentage)
    }

    func createVeilGradient() -> CAGradientLayer {
        let gradient = CAGradientLayer()
        gradient.colors = [
            UIColor(red: 0.1, green: 0.08, blue: 0.2, alpha: 0.95).cgColor,
            UIColor(red: 0.18, green: 0.14, blue: 0.3, alpha: 0.98).cgColor,
            UIColor(red: 0.12, green: 0.1, blue: 0.22, alpha: 0.96).cgColor
        ]
        gradient.locations = [0, 0.5, 1.0]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 1)
        return gradient
    }
}

class ObsidianQuartzView: UIView {

    // MARK: - Properties

    private var quartzImageView: UIImageView!
    private var veilOverlay: UIView!
    private var casingView: UIView!
    private var glintView: UIView!
    private var radianceLayer: CALayer!
    private var innerGlowView: UIView!

    private var quartzModel: ObsidianQuartzModel?
    private var currentMode: Int = 1
    private var veilPercentage: CGFloat = 0.0
    private var veilDirection: ObsidianVeilDirection = .top

    private(set) var currentState: ObsidianQuartzViewState = .normal
    private var configuration: ObsidianQuartzViewConfiguration = .standard

    // Strategy
    private lazy var veilRenderer: VeilRenderingStrategy = StandardVeilRenderingStrategy()

    // Animation manager reference
    private let animationManager = ObsidianAnimationManager.shared

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }

    convenience init(configuration: ObsidianQuartzViewConfiguration) {
        self.init(frame: .zero)
        self.configuration = configuration
        applyConfiguration()
    }

    // MARK: - Setup

    private func setupViews() {
        setupShadow()
        setupCasing()
        setupInnerGlow()
        setupQuartzImage()
        setupGlintView()
        setupVeilOverlay()
        setupConstraints()
    }

    private func setupShadow() {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowRadius = configuration.shadowRadius
        layer.shadowOpacity = configuration.shadowOpacity
        layer.shadowOffset = CGSize(width: 0, height: 3)
        layer.masksToBounds = false
    }

    private func setupCasing() {
        casingView = UIView()
        casingView.backgroundColor = UIColor(red: 0.12, green: 0.1, blue: 0.18, alpha: 1.0)
        casingView.layer.borderWidth = configuration.borderWidth
        casingView.layer.borderColor = configuration.borderColor.cgColor
        casingView.layer.cornerRadius = configuration.cornerRadius
        casingView.clipsToBounds = true
        casingView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(casingView)
    }

    private func setupInnerGlow() {
        innerGlowView = UIView()
        innerGlowView.backgroundColor = .clear
        innerGlowView.layer.cornerRadius = configuration.cornerRadius - 2
        innerGlowView.layer.borderWidth = 1
        innerGlowView.layer.borderColor = UIColor.white.withAlphaComponent(0.15).cgColor
        innerGlowView.translatesAutoresizingMaskIntoConstraints = false
        casingView.addSubview(innerGlowView)
    }

    private func setupQuartzImage() {
        quartzImageView = UIImageView()
        quartzImageView.contentMode = .scaleAspectFill
        quartzImageView.clipsToBounds = true
        quartzImageView.layer.cornerRadius = 4
        quartzImageView.translatesAutoresizingMaskIntoConstraints = false
        casingView.addSubview(quartzImageView)
    }

    private func setupGlintView() {
        glintView = UIView()
        glintView.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        glintView.isHidden = true
        glintView.translatesAutoresizingMaskIntoConstraints = false
        casingView.addSubview(glintView)
    }

    private func setupVeilOverlay() {
        veilOverlay = UIView()
        veilOverlay.isHidden = true
        veilOverlay.layer.cornerRadius = 2
        casingView.addSubview(veilOverlay)

        // Apply veil gradient using strategy
        let veilGradient = veilRenderer.createVeilGradient()
        veilOverlay.layer.addSublayer(veilGradient)

        // Pattern overlay for veil
        let patternView = UIView()
        patternView.backgroundColor = UIColor.white.withAlphaComponent(0.03)
        patternView.translatesAutoresizingMaskIntoConstraints = false
        veilOverlay.addSubview(patternView)

        NSLayoutConstraint.activate([
            patternView.topAnchor.constraint(equalTo: veilOverlay.topAnchor),
            patternView.leadingAnchor.constraint(equalTo: veilOverlay.leadingAnchor),
            patternView.trailingAnchor.constraint(equalTo: veilOverlay.trailingAnchor),
            patternView.bottomAnchor.constraint(equalTo: veilOverlay.bottomAnchor)
        ])
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            casingView.topAnchor.constraint(equalTo: topAnchor),
            casingView.leadingAnchor.constraint(equalTo: leadingAnchor),
            casingView.trailingAnchor.constraint(equalTo: trailingAnchor),
            casingView.bottomAnchor.constraint(equalTo: bottomAnchor),

            innerGlowView.topAnchor.constraint(equalTo: casingView.topAnchor, constant: 2),
            innerGlowView.leadingAnchor.constraint(equalTo: casingView.leadingAnchor, constant: 2),
            innerGlowView.trailingAnchor.constraint(equalTo: casingView.trailingAnchor, constant: -2),
            innerGlowView.bottomAnchor.constraint(equalTo: casingView.bottomAnchor, constant: -2),

            quartzImageView.topAnchor.constraint(equalTo: casingView.topAnchor, constant: 4),
            quartzImageView.leadingAnchor.constraint(equalTo: casingView.leadingAnchor, constant: 4),
            quartzImageView.trailingAnchor.constraint(equalTo: casingView.trailingAnchor, constant: -4),
            quartzImageView.bottomAnchor.constraint(equalTo: casingView.bottomAnchor, constant: -4),

            glintView.topAnchor.constraint(equalTo: casingView.topAnchor),
            glintView.leadingAnchor.constraint(equalTo: casingView.leadingAnchor),
            glintView.trailingAnchor.constraint(equalTo: casingView.trailingAnchor),
            glintView.bottomAnchor.constraint(equalTo: casingView.bottomAnchor)
        ])
    }

    private func applyConfiguration() {
        layer.shadowRadius = configuration.shadowRadius
        layer.shadowOpacity = configuration.shadowOpacity
        casingView.layer.borderWidth = configuration.borderWidth
        casingView.layer.borderColor = configuration.borderColor.cgColor
        casingView.layer.cornerRadius = configuration.cornerRadius
        innerGlowView.layer.cornerRadius = configuration.cornerRadius - 2
    }

    // MARK: - Configuration

    func configure(with model: ObsidianQuartzModel, mode: Int) {
        quartzModel = model
        currentMode = mode
        currentState = .normal

        // Set image
        quartzImageView.image = UIImage(named: model.imageName)

        // Apply rotation for mode 2 (Challenge mode)
        applyRotationIfNeeded(for: model, mode: mode)

        // Apply veil using strategy
        applyVeil(percentage: model.occlusionPercentage)
    }

    private func applyRotationIfNeeded(for model: ObsidianQuartzModel, mode: Int) {
        if mode == 2 {
            let rotation = model.rotationAngle.degreesToRadians
            quartzImageView.transform = CGAffineTransform(rotationAngle: rotation)
        } else {
            quartzImageView.transform = .identity
        }
    }

    func setVeilRenderer(_ renderer: VeilRenderingStrategy) {
        self.veilRenderer = renderer
        // Re-apply veil with new renderer
        if veilPercentage > 0 {
            refreshVeil()
        }
    }

    private func refreshVeil() {
        // Remove existing gradient
        veilOverlay.layer.sublayers?.forEach { layer in
            if layer is CAGradientLayer {
                layer.removeFromSuperlayer()
            }
        }
        // Add new gradient from renderer
        let newGradient = veilRenderer.createVeilGradient()
        newGradient.frame = veilOverlay.bounds
        veilOverlay.layer.insertSublayer(newGradient, at: 0)
    }

    private func applyVeil(percentage: CGFloat) {
        veilPercentage = percentage
        veilDirection = .random()
        veilOverlay.isHidden = false
        setNeedsLayout()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        updateVeilFrame()

        // Update veil gradient frame
        if let gradientLayer = veilOverlay.layer.sublayers?.first as? CAGradientLayer {
            gradientLayer.frame = veilOverlay.bounds
        }
    }

    private func updateVeilFrame() {
        guard veilPercentage > 0 else {
            veilOverlay.isHidden = true
            return
        }

        veilRenderer.applyVeil(to: veilOverlay, in: casingView.bounds, percentage: veilPercentage, direction: veilDirection)
    }

    // MARK: - State Management

    func setState(_ state: ObsidianQuartzViewState, animated: Bool = true) {
        guard currentState != state else { return }
        currentState = state

        switch state {
        case .normal:
            applyNormalState(animated: animated)
        case .selected:
            applySelectedState(animated: animated)
        case .matched:
            applyMatchedState(animated: animated)
        case .disabled:
            applyDisabledState(animated: animated)
        }
    }

    private func applyNormalState(animated: Bool) {
        let changes = {
            self.transform = .identity
            self.casingView.layer.borderColor = self.configuration.borderColor.cgColor
            self.casingView.layer.borderWidth = self.configuration.borderWidth
            self.layer.shadowColor = UIColor.black.cgColor
            self.layer.shadowRadius = self.configuration.shadowRadius
            self.layer.shadowOpacity = self.configuration.shadowOpacity
        }

        if animated {
            UIView.animate(withDuration: 0.2, animations: changes)
        } else {
            changes()
        }

        glintView.isHidden = true
        glintView.layer.removeAllAnimations()
    }

    private func applySelectedState(animated: Bool) {
        let highlightConfig = ObsidianQuartzViewConfiguration.highlighted

        let changes = {
            self.transform = CGAffineTransform(scaleX: 1.08, y: 1.08)
            self.casingView.layer.borderColor = highlightConfig.borderColor.cgColor
            self.casingView.layer.borderWidth = highlightConfig.borderWidth
            self.layer.shadowColor = highlightConfig.borderColor.cgColor
            self.layer.shadowRadius = highlightConfig.shadowRadius
            self.layer.shadowOpacity = highlightConfig.shadowOpacity
        }

        if animated {
            UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, animations: changes)
        } else {
            changes()
        }

        glintView.isHidden = false
        animateGlint()
    }

    private func applyMatchedState(animated: Bool) {
        let successColor = UIColor(red: 0.4, green: 0.9, blue: 0.5, alpha: 1.0)

        if animated {
            UIView.animate(withDuration: 0.2, animations: {
                self.transform = CGAffineTransform(scaleX: 1.15, y: 1.15)
                self.casingView.layer.borderColor = successColor.cgColor
                self.layer.shadowColor = successColor.cgColor
                self.layer.shadowRadius = 15
                self.layer.shadowOpacity = 0.8
            }) { _ in
                UIView.animate(withDuration: 0.3, animations: {
                    self.alpha = 0.0
                    self.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
                })
            }
        } else {
            alpha = 0.0
            transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
        }
    }

    private func applyDisabledState(animated: Bool) {
        let changes = {
            self.alpha = 0.5
            self.isUserInteractionEnabled = false
        }

        if animated {
            UIView.animate(withDuration: 0.2, animations: changes)
        } else {
            changes()
        }
    }

    func setSelected(_ selected: Bool) {
        setState(selected ? .selected : .normal)
    }

    func setMatched(_ matched: Bool) {
        if matched {
            setState(.matched)
        }
    }

    private func animateGlint() {
        let glintGradient = animationManager.setupGlintGradient(for: self)
        glintView.layer.mask = glintGradient

        let animation = animationManager.createGlintAnimation(for: self)
        glintGradient.add(animation, forKey: "glint")
    }

    // MARK: - Touch Feedback

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        guard currentState.isInteractive else { return }
        animationManager.animateTouchDown(view: self)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        guard currentState.isInteractive else { return }
        animationManager.animateTouchUp(view: self)
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        guard currentState.isInteractive else { return }
        animationManager.animateTouchUp(view: self)
    }

    // MARK: - Accessors

    func getQuartzModel() -> ObsidianQuartzModel? {
        return quartzModel
    }

    func getVeilPercentage() -> CGFloat {
        return veilPercentage
    }

    func getVeilDirection() -> ObsidianVeilDirection {
        return veilDirection
    }
}

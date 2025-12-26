//
//  ObsidianAnimationManager.swift
//  PartialPair
//
//  Created by Zhao on 2025/12/21.
//  Refactored: Animation logic extraction
//

import UIKit

// MARK: - Animation Configuration

struct ObsidianAnimationConfiguration {
    let duration: TimeInterval
    let delay: TimeInterval
    let springDamping: CGFloat
    let springVelocity: CGFloat
    let options: UIView.AnimationOptions

    static let defaultSpring = ObsidianAnimationConfiguration(
        duration: 0.4,
        delay: 0,
        springDamping: 0.7,
        springVelocity: 0.5,
        options: []
    )

    static let quickSpring = ObsidianAnimationConfiguration(
        duration: 0.2,
        delay: 0,
        springDamping: 0.7,
        springVelocity: 0.5,
        options: []
    )

    static let slowSpring = ObsidianAnimationConfiguration(
        duration: 0.5,
        delay: 0,
        springDamping: 0.8,
        springVelocity: 0.3,
        options: []
    )

    static let bounce = ObsidianAnimationConfiguration(
        duration: 0.3,
        delay: 0,
        springDamping: 0.6,
        springVelocity: 0.8,
        options: []
    )
}

// MARK: - Animation Type

enum ObsidianAnimationType {
    case entrance
    case selection
    case deselection
    case match
    case mismatch
    case combo
    case roundComplete
    case pulse
    case shake
    case glow

    var configuration: ObsidianAnimationConfiguration {
        switch self {
        case .entrance:
            return .defaultSpring
        case .selection:
            return .quickSpring
        case .deselection:
            return ObsidianAnimationConfiguration(duration: 0.2, delay: 0, springDamping: 1.0, springVelocity: 0, options: [])
        case .match:
            return .bounce
        case .mismatch:
            return ObsidianAnimationConfiguration(duration: 0.4, delay: 0, springDamping: 1.0, springVelocity: 0, options: [])
        case .combo:
            return ObsidianAnimationConfiguration(duration: 0.3, delay: 0, springDamping: 0.6, springVelocity: 0.5, options: [])
        case .roundComplete:
            return .slowSpring
        case .pulse:
            return ObsidianAnimationConfiguration(duration: 2.0, delay: 0, springDamping: 1.0, springVelocity: 0, options: [.repeat, .autoreverse, .curveEaseInOut])
        case .shake:
            return ObsidianAnimationConfiguration(duration: 0.4, delay: 0, springDamping: 1.0, springVelocity: 0, options: [])
        case .glow:
            return ObsidianAnimationConfiguration(duration: 1.5, delay: 0, springDamping: 1.0, springVelocity: 0, options: [.repeat])
        }
    }
}

// MARK: - Animation Manager Protocol

protocol ObsidianAnimationManagerProtocol {
    func animateEntrance(view: UIView, index: Int, completion: (() -> Void)?)
    func animateSelection(view: UIView, completion: (() -> Void)?)
    func animateDeselection(view: UIView, completion: (() -> Void)?)
    func animateMatch(views: [UIView], completion: (() -> Void)?)
    func animateMismatch(views: [UIView], completion: (() -> Void)?)
    func animateCombo(label: UILabel, comboCount: Int, completion: (() -> Void)?)
    func animateRoundComplete(container: UIView, completion: (() -> Void)?)
    func animatePulse(view: UIView)
    func animateFloating(view: UIView, delay: TimeInterval)
    func stopAllAnimations(in view: UIView)
}

// MARK: - Animation Manager Implementation

class ObsidianAnimationManager: ObsidianAnimationManagerProtocol {

    // MARK: - Singleton

    static let shared = ObsidianAnimationManager()

    private init() {}

    // MARK: - Entrance Animation

    func animateEntrance(view: UIView, index: Int, completion: (() -> Void)? = nil) {
        let config = ObsidianAnimationType.entrance.configuration
        let delay = Double(index) * 0.03

        view.alpha = 0
        view.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)

        UIView.animate(
            withDuration: config.duration,
            delay: delay,
            usingSpringWithDamping: config.springDamping,
            initialSpringVelocity: config.springVelocity,
            options: config.options
        ) {
            view.alpha = 1
            view.transform = .identity
        } completion: { _ in
            completion?()
        }
    }

    func animateEntranceSequence(views: [UIView], completion: (() -> Void)? = nil) {
        let config = ObsidianAnimationType.entrance.configuration

        for (index, view) in views.enumerated() {
            let delay = Double(index) * 0.03

            view.alpha = 0
            view.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)

            UIView.animate(
                withDuration: config.duration,
                delay: delay,
                usingSpringWithDamping: config.springDamping,
                initialSpringVelocity: config.springVelocity,
                options: config.options
            ) {
                view.alpha = 1
                view.transform = .identity
            } completion: { finished in
                if index == views.count - 1 && finished {
                    completion?()
                }
            }
        }
    }

    // MARK: - Selection Animation

    func animateSelection(view: UIView, completion: (() -> Void)? = nil) {
        let config = ObsidianAnimationType.selection.configuration

        UIView.animate(
            withDuration: config.duration,
            delay: config.delay,
            usingSpringWithDamping: config.springDamping,
            initialSpringVelocity: config.springVelocity,
            options: config.options
        ) {
            view.transform = CGAffineTransform(scaleX: 1.08, y: 1.08)
        } completion: { _ in
            completion?()
        }
    }

    func animateDeselection(view: UIView, completion: (() -> Void)? = nil) {
        let config = ObsidianAnimationType.deselection.configuration

        UIView.animate(withDuration: config.duration) {
            view.transform = .identity
        } completion: { _ in
            completion?()
        }
    }

    // MARK: - Match Animation

    func animateMatch(views: [UIView], completion: (() -> Void)? = nil) {
        let matchColor = UIColor(red: 0.4, green: 0.8, blue: 0.6, alpha: 1.0)

        // Phase 1: Pulse with glow
        UIView.animate(withDuration: 0.2, animations: {
            for view in views {
                view.transform = CGAffineTransform(scaleX: 1.15, y: 1.15)
                view.layer.shadowColor = matchColor.cgColor
                view.layer.shadowRadius = 15
                view.layer.shadowOpacity = 0.8
            }
        }) { _ in
            // Phase 2: Fade out
            UIView.animate(withDuration: 0.3, animations: {
                for view in views {
                    view.transform = .identity
                    view.alpha = 0.3
                }
            }) { _ in
                completion?()
            }
        }
    }

    func animateMatchSuccess(view: UIView, completion: (() -> Void)? = nil) {
        let successColor = UIColor(red: 0.4, green: 0.9, blue: 0.5, alpha: 1.0)

        UIView.animate(withDuration: 0.2, animations: {
            view.transform = CGAffineTransform(scaleX: 1.15, y: 1.15)
            view.layer.shadowColor = successColor.cgColor
            view.layer.shadowRadius = 15
            view.layer.shadowOpacity = 0.8
        }) { _ in
            UIView.animate(withDuration: 0.3, animations: {
                view.alpha = 0.0
                view.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
            }) { _ in
                completion?()
            }
        }
    }

    // MARK: - Mismatch Animation

    func animateMismatch(views: [UIView], completion: (() -> Void)? = nil) {
        let errorColor = UIColor.red

        // Apply error glow
        for view in views {
            view.layer.shadowColor = errorColor.cgColor
            view.layer.shadowRadius = 10
            view.layer.shadowOpacity = 0.6

            // Shake animation
            let animation = createShakeAnimation()
            view.layer.add(animation, forKey: "shake")
        }

        // Remove glow after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            for view in views {
                view.layer.shadowOpacity = 0
            }
            completion?()
        }
    }

    private func createShakeAnimation() -> CAKeyframeAnimation {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        animation.values = [-12, 12, -8, 8, -4, 4, 0]
        animation.duration = 0.4
        return animation
    }

    // MARK: - Combo Animation

    func animateCombo(label: UILabel, comboCount: Int, completion: (() -> Void)? = nil) {
        label.text = "COMBO x\(comboCount)!"
        label.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        label.alpha = 0

        UIView.animate(
            withDuration: 0.3,
            delay: 0,
            usingSpringWithDamping: 0.6,
            initialSpringVelocity: 0.5,
            options: []
        ) {
            label.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            label.alpha = 1
        } completion: { _ in
            UIView.animate(withDuration: 0.2, delay: 0.5) {
                label.transform = .identity
                label.alpha = 0
            } completion: { _ in
                completion?()
            }
        }
    }

    // MARK: - Round Complete Animation

    func animateRoundComplete(container: UIView, completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: 0.5, animations: {
            container.alpha = 0.3
            container.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                UIView.animate(withDuration: 0.5) {
                    container.alpha = 1.0
                    container.transform = .identity
                } completion: { _ in
                    completion?()
                }
            }
        }
    }

    // MARK: - Pulse Animation

    func animatePulse(view: UIView) {
        let config = ObsidianAnimationType.pulse.configuration

        UIView.animate(
            withDuration: config.duration,
            delay: config.delay,
            options: config.options
        ) {
            view.transform = CGAffineTransform(scaleX: 1.03, y: 1.03)
        }
    }

    // MARK: - Floating Animation

    func animateFloating(view: UIView, delay: TimeInterval = 0) {
        UIView.animate(
            withDuration: 3.0,
            delay: delay,
            options: [.repeat, .autoreverse, .curveEaseInOut]
        ) {
            view.transform = CGAffineTransform(translationX: 0, y: -20).rotated(by: 0.1)
        }
    }

    // MARK: - Touch Feedback

    func animateTouchDown(view: UIView) {
        UIView.animate(withDuration: 0.1) {
            view.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }
    }

    func animateTouchUp(view: UIView) {
        UIView.animate(withDuration: 0.1) {
            view.transform = .identity
        }
    }

    func animateButtonTouchDown(button: UIButton) {
        UIView.animate(withDuration: 0.1) {
            button.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }
    }

    func animateButtonTouchUp(button: UIButton) {
        UIView.animate(
            withDuration: 0.2,
            delay: 0,
            usingSpringWithDamping: 0.6,
            initialSpringVelocity: 0.5
        ) {
            button.transform = .identity
        }
    }

    // MARK: - Score Update Animation

    func animateScoreUpdate(label: UILabel) {
        UIView.animate(withDuration: 0.1, animations: {
            label.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                label.transform = .identity
            }
        }
    }

    // MARK: - Progress Bar Animation

    func animateProgressBar(
        fillView: UIView,
        progressBar: UIView,
        progress: CGFloat,
        parentView: UIView
    ) {
        parentView.layoutIfNeeded()

        // Remove existing width constraint
        fillView.constraints.forEach { constraint in
            if constraint.firstAttribute == .width {
                constraint.isActive = false
            }
        }

        UIView.animate(withDuration: 0.3) {
            fillView.widthAnchor.constraint(
                equalTo: progressBar.widthAnchor,
                multiplier: progress
            ).isActive = true
            parentView.layoutIfNeeded()
        }
    }

    // MARK: - Card Entrance Animation

    func animateCardsEntrance(views: [UIView]) {
        for (index, view) in views.enumerated() {
            view.alpha = 0
            view.transform = CGAffineTransform(translationX: 0, y: 30)

            UIView.animate(
                withDuration: 0.5,
                delay: Double(index) * 0.1,
                usingSpringWithDamping: 0.8,
                initialSpringVelocity: 0.5
            ) {
                view.alpha = 1
                view.transform = .identity
            }
        }
    }

    // MARK: - Stop Animations

    func stopAllAnimations(in view: UIView) {
        view.layer.removeAllAnimations()
        for subview in view.subviews {
            stopAllAnimations(in: subview)
        }
    }

    // MARK: - Glint Animation

    func createGlintAnimation(for view: UIView) -> CABasicAnimation {
        let animation = CABasicAnimation(keyPath: "transform.translation.x")
        animation.duration = 1.5
        animation.fromValue = -view.bounds.width
        animation.toValue = view.bounds.width
        animation.repeatCount = .infinity
        return animation
    }

    func setupGlintGradient(for view: UIView) -> CAGradientLayer {
        let glintGradient = CAGradientLayer()
        glintGradient.colors = [
            UIColor.clear.cgColor,
            UIColor.white.withAlphaComponent(0.3).cgColor,
            UIColor.clear.cgColor
        ]
        glintGradient.locations = [0, 0.5, 1]
        glintGradient.startPoint = CGPoint(x: 0, y: 0.5)
        glintGradient.endPoint = CGPoint(x: 1, y: 0.5)
        glintGradient.frame = CGRect(
            x: -view.bounds.width,
            y: 0,
            width: view.bounds.width * 2,
            height: view.bounds.height
        )
        return glintGradient
    }
}

// MARK: - Animation Context

struct ObsidianAnimationContext {
    let type: ObsidianAnimationType
    let views: [UIView]
    let completion: (() -> Void)?

    init(type: ObsidianAnimationType, views: [UIView], completion: (() -> Void)? = nil) {
        self.type = type
        self.views = views
        self.completion = completion
    }

    init(type: ObsidianAnimationType, view: UIView, completion: (() -> Void)? = nil) {
        self.type = type
        self.views = [view]
        self.completion = completion
    }
}

// MARK: - Animation Queue (for sequential animations)

class ObsidianAnimationQueue {

    private var queue: [ObsidianAnimationContext] = []
    private var isProcessing = false
    private let animationManager = ObsidianAnimationManager.shared

    func enqueue(_ context: ObsidianAnimationContext) {
        queue.append(context)
        processNextIfNeeded()
    }

    func enqueueAll(_ contexts: [ObsidianAnimationContext]) {
        queue.append(contentsOf: contexts)
        processNextIfNeeded()
    }

    func clear() {
        queue.removeAll()
        isProcessing = false
    }

    private func processNextIfNeeded() {
        guard !isProcessing, !queue.isEmpty else { return }

        isProcessing = true
        let context = queue.removeFirst()

        executeAnimation(context) { [weak self] in
            self?.isProcessing = false
            context.completion?()
            self?.processNextIfNeeded()
        }
    }

    private func executeAnimation(_ context: ObsidianAnimationContext, completion: @escaping () -> Void) {
        switch context.type {
        case .entrance:
            animationManager.animateEntranceSequence(views: context.views, completion: completion)
        case .selection:
            if let view = context.views.first {
                animationManager.animateSelection(view: view, completion: completion)
            }
        case .deselection:
            if let view = context.views.first {
                animationManager.animateDeselection(view: view, completion: completion)
            }
        case .match:
            animationManager.animateMatch(views: context.views, completion: completion)
        case .mismatch:
            animationManager.animateMismatch(views: context.views, completion: completion)
        case .roundComplete:
            if let view = context.views.first {
                animationManager.animateRoundComplete(container: view, completion: completion)
            }
        default:
            completion()
        }
    }
}

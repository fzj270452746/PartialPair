//
//  ObsidianHapticManager.swift
//  PartialPair
//
//  Created by Zhao on 2025/12/21.
//  Refactored: Haptic feedback extraction
//

import UIKit

// MARK: - Haptic Type

enum ObsidianHapticType {
    case selection
    case lightImpact
    case mediumImpact
    case heavyImpact
    case success
    case warning
    case error
    case softImpact
    case rigidImpact

    var feedbackStyle: Any {
        switch self {
        case .selection:
            return UISelectionFeedbackGenerator()
        case .lightImpact:
            return UIImpactFeedbackGenerator(style: .light)
        case .mediumImpact:
            return UIImpactFeedbackGenerator(style: .medium)
        case .heavyImpact:
            return UIImpactFeedbackGenerator(style: .heavy)
        case .softImpact:
            return UIImpactFeedbackGenerator(style: .soft)
        case .rigidImpact:
            return UIImpactFeedbackGenerator(style: .rigid)
        case .success, .warning, .error:
            return UINotificationFeedbackGenerator()
        }
    }
}

// MARK: - Haptic Pattern

struct ObsidianHapticPattern {
    let types: [ObsidianHapticType]
    let delays: [TimeInterval]

    static let matchSuccess = ObsidianHapticPattern(
        types: [.success, .lightImpact],
        delays: [0, 0.1]
    )

    static let matchFailure = ObsidianHapticPattern(
        types: [.error],
        delays: [0]
    )

    static let combo = ObsidianHapticPattern(
        types: [.success, .mediumImpact, .lightImpact],
        delays: [0, 0.1, 0.2]
    )

    static let tileSelection = ObsidianHapticPattern(
        types: [.lightImpact],
        delays: [0]
    )

    static let roundComplete = ObsidianHapticPattern(
        types: [.success, .heavyImpact],
        delays: [0, 0.15]
    )

    static let buttonTap = ObsidianHapticPattern(
        types: [.lightImpact],
        delays: [0]
    )
}

// MARK: - Haptic Manager Protocol

protocol ObsidianHapticManagerProtocol {
    var isEnabled: Bool { get set }
    func trigger(_ type: ObsidianHapticType)
    func playPattern(_ pattern: ObsidianHapticPattern)
    func prepare(_ type: ObsidianHapticType)
}

// MARK: - Haptic Manager Implementation

class ObsidianHapticManager: ObsidianHapticManagerProtocol {

    // MARK: - Singleton

    static let shared = ObsidianHapticManager()

    // MARK: - Properties

    var isEnabled: Bool = true

    private var selectionGenerator: UISelectionFeedbackGenerator?
    private var lightImpactGenerator: UIImpactFeedbackGenerator?
    private var mediumImpactGenerator: UIImpactFeedbackGenerator?
    private var heavyImpactGenerator: UIImpactFeedbackGenerator?
    private var softImpactGenerator: UIImpactFeedbackGenerator?
    private var rigidImpactGenerator: UIImpactFeedbackGenerator?
    private var notificationGenerator: UINotificationFeedbackGenerator?

    // MARK: - Initialization

    private init() {
        setupGenerators()
    }

    private func setupGenerators() {
        selectionGenerator = UISelectionFeedbackGenerator()
        lightImpactGenerator = UIImpactFeedbackGenerator(style: .light)
        mediumImpactGenerator = UIImpactFeedbackGenerator(style: .medium)
        heavyImpactGenerator = UIImpactFeedbackGenerator(style: .heavy)
        softImpactGenerator = UIImpactFeedbackGenerator(style: .soft)
        rigidImpactGenerator = UIImpactFeedbackGenerator(style: .rigid)
        notificationGenerator = UINotificationFeedbackGenerator()
    }

    // MARK: - Prepare Generators

    func prepare(_ type: ObsidianHapticType) {
        guard isEnabled else { return }

        switch type {
        case .selection:
            selectionGenerator?.prepare()
        case .lightImpact:
            lightImpactGenerator?.prepare()
        case .mediumImpact:
            mediumImpactGenerator?.prepare()
        case .heavyImpact:
            heavyImpactGenerator?.prepare()
        case .softImpact:
            softImpactGenerator?.prepare()
        case .rigidImpact:
            rigidImpactGenerator?.prepare()
        case .success, .warning, .error:
            notificationGenerator?.prepare()
        }
    }

    func prepareAll() {
        guard isEnabled else { return }

        selectionGenerator?.prepare()
        lightImpactGenerator?.prepare()
        mediumImpactGenerator?.prepare()
        heavyImpactGenerator?.prepare()
        softImpactGenerator?.prepare()
        rigidImpactGenerator?.prepare()
        notificationGenerator?.prepare()
    }

    // MARK: - Trigger Haptic

    func trigger(_ type: ObsidianHapticType) {
        guard isEnabled else { return }

        switch type {
        case .selection:
            selectionGenerator?.selectionChanged()
        case .lightImpact:
            lightImpactGenerator?.impactOccurred()
        case .mediumImpact:
            mediumImpactGenerator?.impactOccurred()
        case .heavyImpact:
            heavyImpactGenerator?.impactOccurred()
        case .softImpact:
            softImpactGenerator?.impactOccurred()
        case .rigidImpact:
            rigidImpactGenerator?.impactOccurred()
        case .success:
            notificationGenerator?.notificationOccurred(.success)
        case .warning:
            notificationGenerator?.notificationOccurred(.warning)
        case .error:
            notificationGenerator?.notificationOccurred(.error)
        }
    }

    func triggerWithIntensity(_ type: ObsidianHapticType, intensity: CGFloat) {
        guard isEnabled else { return }
        let clampedIntensity = min(max(intensity, 0), 1)

        switch type {
        case .lightImpact:
            lightImpactGenerator?.impactOccurred(intensity: clampedIntensity)
        case .mediumImpact:
            mediumImpactGenerator?.impactOccurred(intensity: clampedIntensity)
        case .heavyImpact:
            heavyImpactGenerator?.impactOccurred(intensity: clampedIntensity)
        case .softImpact:
            softImpactGenerator?.impactOccurred(intensity: clampedIntensity)
        case .rigidImpact:
            rigidImpactGenerator?.impactOccurred(intensity: clampedIntensity)
        default:
            trigger(type)
        }
    }

    // MARK: - Play Pattern

    func playPattern(_ pattern: ObsidianHapticPattern) {
        guard isEnabled else { return }
        guard pattern.types.count == pattern.delays.count else { return }

        for (index, type) in pattern.types.enumerated() {
            let delay = pattern.delays[index]
            if delay == 0 {
                trigger(type)
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
                    self?.trigger(type)
                }
            }
        }
    }

    // MARK: - Convenience Methods

    func playTileSelection() {
        playPattern(.tileSelection)
    }

    func playMatchSuccess() {
        playPattern(.matchSuccess)
    }

    func playMatchFailure() {
        playPattern(.matchFailure)
    }

    func playCombo() {
        playPattern(.combo)
    }

    func playRoundComplete() {
        playPattern(.roundComplete)
    }

    func playButtonTap() {
        playPattern(.buttonTap)
    }

    func playSliderChange() {
        trigger(.lightImpact)
    }
}

// MARK: - Haptic Context

struct ObsidianHapticContext {
    let event: GameHapticEvent
    let intensity: CGFloat?

    init(event: GameHapticEvent, intensity: CGFloat? = nil) {
        self.event = event
        self.intensity = intensity
    }
}

// MARK: - Game Haptic Events

enum GameHapticEvent {
    case tileSelected
    case matchFound
    case matchFailed
    case comboAchieved(count: Int)
    case roundCompleted
    case gameStarted
    case gameEnded
    case buttonPressed
    case sliderChanged
    case menuItemSelected

    var hapticPattern: ObsidianHapticPattern {
        switch self {
        case .tileSelected:
            return .tileSelection
        case .matchFound:
            return .matchSuccess
        case .matchFailed:
            return .matchFailure
        case .comboAchieved(let count):
            if count >= 5 {
                return ObsidianHapticPattern(
                    types: [.success, .heavyImpact, .mediumImpact],
                    delays: [0, 0.1, 0.2]
                )
            } else if count >= 3 {
                return .combo
            } else {
                return .matchSuccess
            }
        case .roundCompleted:
            return .roundComplete
        case .gameStarted, .gameEnded:
            return ObsidianHapticPattern(
                types: [.mediumImpact],
                delays: [0]
            )
        case .buttonPressed:
            return .buttonTap
        case .sliderChanged:
            return ObsidianHapticPattern(
                types: [.lightImpact],
                delays: [0]
            )
        case .menuItemSelected:
            return ObsidianHapticPattern(
                types: [.selection],
                delays: [0]
            )
        }
    }
}

// MARK: - Haptic Engine Extension

extension ObsidianHapticManager {

    func handleGameEvent(_ event: GameHapticEvent) {
        playPattern(event.hapticPattern)
    }

    func handleContext(_ context: ObsidianHapticContext) {
        if let intensity = context.intensity {
            // Play with custom intensity for the first haptic in pattern
            let pattern = context.event.hapticPattern
            if let firstType = pattern.types.first {
                triggerWithIntensity(firstType, intensity: intensity)
            }
            // Play remaining haptics in pattern
            if pattern.types.count > 1 {
                for i in 1..<pattern.types.count {
                    let delay = pattern.delays[i]
                    DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
                        self?.trigger(pattern.types[i])
                    }
                }
            }
        } else {
            playPattern(context.event.hapticPattern)
        }
    }
}

// MARK: - Haptic Feedback Provider Protocol

protocol HapticFeedbackProvider {
    func provideHapticFeedback(for event: GameHapticEvent)
}

// MARK: - Default Haptic Feedback Provider

class DefaultHapticFeedbackProvider: HapticFeedbackProvider {
    private let hapticManager = ObsidianHapticManager.shared

    func provideHapticFeedback(for event: GameHapticEvent) {
        hapticManager.handleGameEvent(event)
    }
}

// MARK: - Silent Haptic Feedback Provider (for testing or accessibility)

class SilentHapticFeedbackProvider: HapticFeedbackProvider {
    func provideHapticFeedback(for event: GameHapticEvent) {
        // No-op implementation
    }
}

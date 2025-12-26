//
//  ObsidianTimerManager.swift
//  PartialPair
//
//  Created by Zhao on 2025/12/21.
//  Refactored: Timer management extraction
//

import Foundation

// MARK: - Timer State

enum ObsidianTimerState {
    case idle
    case running
    case paused
    case stopped

    var isActive: Bool {
        return self == .running
    }
}

// MARK: - Timer Mode

enum ObsidianTimerMode {
    case countUp      // Counts from 0 upward
    case countDown    // Counts from a set time downward
    case unlimited    // No time tracking

    var direction: Int {
        switch self {
        case .countUp, .unlimited:
            return 1
        case .countDown:
            return -1
        }
    }
}

// MARK: - Timer Configuration

struct ObsidianTimerConfiguration {
    let mode: ObsidianTimerMode
    let initialTime: TimeInterval
    let updateInterval: TimeInterval
    let warningThreshold: TimeInterval?

    static let standard = ObsidianTimerConfiguration(
        mode: .countUp,
        initialTime: 0,
        updateInterval: 1.0,
        warningThreshold: nil
    )

    static func countdown(duration: TimeInterval, warning: TimeInterval? = 30) -> ObsidianTimerConfiguration {
        return ObsidianTimerConfiguration(
            mode: .countDown,
            initialTime: duration,
            updateInterval: 1.0,
            warningThreshold: warning
        )
    }
}

// MARK: - Timer Delegate

protocol ObsidianTimerManagerDelegate: AnyObject {
    func timerManager(_ manager: ObsidianTimerManager, didUpdateTime time: TimeInterval)
    func timerManager(_ manager: ObsidianTimerManager, didChangeState state: ObsidianTimerState)
    func timerManager(_ manager: ObsidianTimerManager, didReachWarningThreshold time: TimeInterval)
    func timerManagerDidExpire(_ manager: ObsidianTimerManager)
}

// MARK: - Optional Delegate Methods

extension ObsidianTimerManagerDelegate {
    func timerManager(_ manager: ObsidianTimerManager, didReachWarningThreshold time: TimeInterval) {}
    func timerManagerDidExpire(_ manager: ObsidianTimerManager) {}
}

// MARK: - Timer Manager Protocol

protocol ObsidianTimerManagerProtocol {
    var currentTime: TimeInterval { get }
    var elapsedTime: TimeInterval { get }
    var state: ObsidianTimerState { get }

    func start()
    func pause()
    func resume()
    func stop()
    func reset()
}

// MARK: - Timer Manager Implementation

class ObsidianTimerManager: ObsidianTimerManagerProtocol {

    // MARK: - Properties

    weak var delegate: ObsidianTimerManagerDelegate?

    private(set) var currentTime: TimeInterval = 0
    private(set) var elapsedTime: TimeInterval = 0
    private(set) var state: ObsidianTimerState = .idle {
        didSet {
            if oldValue != state {
                delegate?.timerManager(self, didChangeState: state)
            }
        }
    }

    private let configuration: ObsidianTimerConfiguration
    private var timer: Timer?
    private var startDate: Date?
    private var pausedTime: TimeInterval = 0
    private var hasWarningTriggered: Bool = false

    // MARK: - Initialization

    init(configuration: ObsidianTimerConfiguration = .standard) {
        self.configuration = configuration
        self.currentTime = configuration.initialTime
    }

    convenience init(mode: ObsidianTimerMode) {
        switch mode {
        case .countUp:
            self.init(configuration: .standard)
        case .countDown:
            self.init(configuration: .countdown(duration: 300))
        case .unlimited:
            self.init(configuration: ObsidianTimerConfiguration(
                mode: .unlimited,
                initialTime: 0,
                updateInterval: 1.0,
                warningThreshold: nil
            ))
        }
    }

    deinit {
        timer?.invalidate()
    }

    // MARK: - Timer Control

    func start() {
        guard state == .idle || state == .stopped else { return }

        currentTime = configuration.initialTime
        elapsedTime = 0
        pausedTime = 0
        hasWarningTriggered = false
        startDate = Date()
        state = .running

        startTimer()
    }

    func pause() {
        guard state == .running else { return }

        timer?.invalidate()
        timer = nil

        if let start = startDate {
            pausedTime = Date().timeIntervalSince(start)
        }

        state = .paused
    }

    func resume() {
        guard state == .paused else { return }

        startDate = Date().addingTimeInterval(-pausedTime)
        state = .running

        startTimer()
    }

    func stop() {
        timer?.invalidate()
        timer = nil

        if let start = startDate {
            elapsedTime = Date().timeIntervalSince(start)
        }

        state = .stopped
    }

    func reset() {
        timer?.invalidate()
        timer = nil

        currentTime = configuration.initialTime
        elapsedTime = 0
        pausedTime = 0
        hasWarningTriggered = false
        startDate = nil
        state = .idle
    }

    // MARK: - Private Methods

    private func startTimer() {
        timer = Timer.scheduledTimer(
            withTimeInterval: configuration.updateInterval,
            repeats: true
        ) { [weak self] _ in
            self?.tick()
        }
    }

    private func tick() {
        guard state == .running else { return }

        switch configuration.mode {
        case .countUp:
            currentTime += configuration.updateInterval
            elapsedTime = currentTime

        case .countDown:
            currentTime -= configuration.updateInterval
            elapsedTime += configuration.updateInterval

            // Check for expiration
            if currentTime <= 0 {
                currentTime = 0
                stop()
                delegate?.timerManagerDidExpire(self)
                return
            }

            // Check for warning threshold
            checkWarningThreshold()

        case .unlimited:
            elapsedTime += configuration.updateInterval
            currentTime = elapsedTime
        }

        delegate?.timerManager(self, didUpdateTime: currentTime)
    }

    private func checkWarningThreshold() {
        guard !hasWarningTriggered else { return }
        guard let threshold = configuration.warningThreshold else { return }

        if currentTime <= threshold {
            hasWarningTriggered = true
            delegate?.timerManager(self, didReachWarningThreshold: currentTime)
        }
    }

    // MARK: - Formatting

    func formattedTime() -> String {
        return ObsidianTimerManager.formatTime(currentTime)
    }

    func formattedElapsedTime() -> String {
        return ObsidianTimerManager.formatTime(elapsedTime)
    }

    static func formatTime(_ seconds: TimeInterval) -> String {
        let totalSeconds = Int(seconds)
        let minutes = totalSeconds / 60
        let secs = totalSeconds % 60

        if minutes >= 60 {
            let hours = minutes / 60
            let mins = minutes % 60
            return String(format: "%d:%02d:%02d", hours, mins, secs)
        }
        return String(format: "%d:%02d", minutes, secs)
    }

    static func formatTimeCompact(_ seconds: TimeInterval) -> String {
        let totalSeconds = Int(seconds)
        let minutes = totalSeconds / 60
        let secs = totalSeconds % 60
        return String(format: "%d:%02d", minutes, secs)
    }
}

// MARK: - Game Session Timer

class ObsidianGameSessionTimer {

    // MARK: - Properties

    private var sessionStartTime: Date?
    private var sessionEndTime: Date?
    private var pauseDuration: TimeInterval = 0
    private var pauseStartTime: Date?
    private var roundTimes: [TimeInterval] = []

    var isSessionActive: Bool {
        return sessionStartTime != nil && sessionEndTime == nil
    }

    var totalSessionTime: TimeInterval {
        guard let start = sessionStartTime else { return 0 }
        let end = sessionEndTime ?? Date()
        return end.timeIntervalSince(start) - pauseDuration
    }

    var averageRoundTime: TimeInterval {
        guard !roundTimes.isEmpty else { return 0 }
        return roundTimes.reduce(0, +) / Double(roundTimes.count)
    }

    var fastestRoundTime: TimeInterval? {
        return roundTimes.min()
    }

    var slowestRoundTime: TimeInterval? {
        return roundTimes.max()
    }

    // MARK: - Session Control

    func startSession() {
        sessionStartTime = Date()
        sessionEndTime = nil
        pauseDuration = 0
        pauseStartTime = nil
        roundTimes.removeAll()
    }

    func endSession() {
        sessionEndTime = Date()
        if let pauseStart = pauseStartTime {
            pauseDuration += Date().timeIntervalSince(pauseStart)
            pauseStartTime = nil
        }
    }

    func pauseSession() {
        pauseStartTime = Date()
    }

    func resumeSession() {
        if let pauseStart = pauseStartTime {
            pauseDuration += Date().timeIntervalSince(pauseStart)
            pauseStartTime = nil
        }
    }

    func recordRoundTime(_ time: TimeInterval) {
        roundTimes.append(time)
    }

    func reset() {
        sessionStartTime = nil
        sessionEndTime = nil
        pauseDuration = 0
        pauseStartTime = nil
        roundTimes.removeAll()
    }

    // MARK: - Statistics

    func getSessionStatistics() -> SessionTimeStatistics {
        return SessionTimeStatistics(
            totalTime: totalSessionTime,
            roundTimes: roundTimes,
            averageRoundTime: averageRoundTime,
            fastestRound: fastestRoundTime,
            slowestRound: slowestRoundTime,
            totalPauseDuration: pauseDuration
        )
    }
}

// MARK: - Session Time Statistics

struct SessionTimeStatistics {
    let totalTime: TimeInterval
    let roundTimes: [TimeInterval]
    let averageRoundTime: TimeInterval
    let fastestRound: TimeInterval?
    let slowestRound: TimeInterval?
    let totalPauseDuration: TimeInterval

    var roundCount: Int {
        return roundTimes.count
    }

    var formattedTotalTime: String {
        return ObsidianTimerManager.formatTime(totalTime)
    }

    var formattedAverageRoundTime: String {
        return ObsidianTimerManager.formatTime(averageRoundTime)
    }
}

// MARK: - Round Timer

class ObsidianRoundTimer {

    private var roundStartTime: Date?
    private(set) var currentRoundTime: TimeInterval = 0

    var isRunning: Bool {
        return roundStartTime != nil
    }

    func startRound() {
        roundStartTime = Date()
        currentRoundTime = 0
    }

    func endRound() -> TimeInterval {
        guard let start = roundStartTime else { return 0 }
        currentRoundTime = Date().timeIntervalSince(start)
        roundStartTime = nil
        return currentRoundTime
    }

    func getCurrentTime() -> TimeInterval {
        guard let start = roundStartTime else { return currentRoundTime }
        return Date().timeIntervalSince(start)
    }

    func reset() {
        roundStartTime = nil
        currentRoundTime = 0
    }
}

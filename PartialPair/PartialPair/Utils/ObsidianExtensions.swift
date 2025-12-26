//
//  ObsidianExtensions.swift
//  PartialPair
//
//  Created by Zhao on 2025/12/21.
//  Refactored: Common extensions
//

import UIKit

// MARK: - UIView Extensions

extension UIView {

    /// Adds constraints to pin the view to its superview's edges
    func pinToSuperview(padding: UIEdgeInsets = .zero) {
        guard let superview = superview else { return }
        translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: superview.topAnchor, constant: padding.top),
            leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: padding.left),
            trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: -padding.right),
            bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: -padding.bottom)
        ])
    }

    /// Adds constraints to center the view in its superview
    func centerInSuperview() {
        guard let superview = superview else { return }
        translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            centerXAnchor.constraint(equalTo: superview.centerXAnchor),
            centerYAnchor.constraint(equalTo: superview.centerYAnchor)
        ])
    }

    /// Sets fixed size constraints
    func setSize(width: CGFloat? = nil, height: CGFloat? = nil) {
        translatesAutoresizingMaskIntoConstraints = false

        if let width = width {
            widthAnchor.constraint(equalToConstant: width).isActive = true
        }
        if let height = height {
            heightAnchor.constraint(equalToConstant: height).isActive = true
        }
    }

    /// Applies corner radius with optional masking
    func applyCornerRadius(_ radius: CGFloat, corners: CACornerMask? = nil) {
        layer.cornerRadius = radius
        if let corners = corners {
            layer.maskedCorners = corners
        }
        clipsToBounds = true
    }

    /// Applies shadow effect
    func applyShadow(
        color: UIColor = .black,
        opacity: Float = 0.3,
        offset: CGSize = CGSize(width: 0, height: 3),
        radius: CGFloat = 6
    ) {
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = opacity
        layer.shadowOffset = offset
        layer.shadowRadius = radius
        layer.masksToBounds = false
    }

    /// Applies glow effect
    func applyGlow(color: UIColor, radius: CGFloat = 10, opacity: Float = 0.6) {
        layer.shadowColor = color.cgColor
        layer.shadowRadius = radius
        layer.shadowOpacity = opacity
        layer.shadowOffset = .zero
        layer.masksToBounds = false
    }

    /// Removes all constraints
    func removeAllConstraints() {
        var _superview = superview
        while let superview = _superview {
            for constraint in superview.constraints {
                if let first = constraint.firstItem as? UIView, first == self {
                    superview.removeConstraint(constraint)
                }
                if let second = constraint.secondItem as? UIView, second == self {
                    superview.removeConstraint(constraint)
                }
            }
            _superview = superview.superview
        }
        removeConstraints(constraints)
    }

    /// Adds a gradient layer to the view
    func addGradientLayer(colors: [UIColor], startPoint: CGPoint = CGPoint(x: 0, y: 0), endPoint: CGPoint = CGPoint(x: 1, y: 1)) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = colors.map { $0.cgColor }
        gradientLayer.startPoint = startPoint
        gradientLayer.endPoint = endPoint
        gradientLayer.frame = bounds
        layer.insertSublayer(gradientLayer, at: 0)
    }

    /// Creates a snapshot of the view
    func snapshot() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, UIScreen.main.scale)
        defer { UIGraphicsEndImageContext() }
        drawHierarchy(in: bounds, afterScreenUpdates: true)
        return UIGraphicsGetImageFromCurrentImageContext()
    }

    /// Adds a blur effect to the view
    func addBlurEffect(style: UIBlurEffect.Style = .dark) {
        let blurEffect = UIBlurEffect(style: style)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = bounds
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        insertSubview(blurView, at: 0)
    }
}

// MARK: - UILabel Extensions

extension UILabel {

    /// Applies letter spacing (kern) to the label text
    func applyLetterSpacing(_ spacing: Double) {
        guard let text = self.text else { return }
        let attributedString = NSMutableAttributedString(string: text)
        attributedString.addAttribute(
            .kern,
            value: spacing,
            range: NSRange(location: 0, length: text.count)
        )
        self.attributedText = attributedString
    }

    /// Sets multiline text with line height
    func setTextWithLineHeight(_ text: String, lineHeight: CGFloat) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineHeight - font.lineHeight
        paragraphStyle.alignment = textAlignment

        let attributedString = NSAttributedString(
            string: text,
            attributes: [
                .paragraphStyle: paragraphStyle,
                .font: font as Any,
                .foregroundColor: textColor as Any
            ]
        )
        self.attributedText = attributedString
    }
}

// MARK: - UIColor Extensions

extension UIColor {

    /// Creates a color from hex string
    convenience init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)

        let r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let b = CGFloat(rgb & 0x0000FF) / 255.0

        self.init(red: r, green: g, blue: b, alpha: 1.0)
    }

    /// Returns a lighter version of the color
    func lighter(by percentage: CGFloat = 0.3) -> UIColor {
        return adjust(by: abs(percentage))
    }

    /// Returns a darker version of the color
    func darker(by percentage: CGFloat = 0.3) -> UIColor {
        return adjust(by: -abs(percentage))
    }

    private func adjust(by percentage: CGFloat) -> UIColor {
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        return UIColor(
            red: min(red + percentage, 1.0),
            green: min(green + percentage, 1.0),
            blue: min(blue + percentage, 1.0),
            alpha: alpha
        )
    }

    /// Returns hex string representation
    var hexString: String {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        return String(format: "#%02X%02X%02X", Int(r * 255), Int(g * 255), Int(b * 255))
    }
}

// MARK: - Array Extensions

extension Array {

    /// Safely accesses element at index
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }

    /// Chunks the array into smaller arrays of specified size
    func chunked(into size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
}

// MARK: - String Extensions

extension String {

    /// Returns localized string
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }

    /// Checks if string is valid email
    var isValidEmail: Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let predicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return predicate.evaluate(with: self)
    }

    /// Trims whitespace and newlines
    var trimmed: String {
        return trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

// MARK: - Date Extensions

extension Date {

    /// Returns a formatted string representation
    func formatted(style: DateFormatter.Style = .medium) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = style
        formatter.timeStyle = .short
        return formatter.string(from: self)
    }

    /// Returns relative time description
    var relativeTimeString: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: self, relativeTo: Date())
    }

    /// Returns time ago string
    var timeAgoString: String {
        let seconds = Int(Date().timeIntervalSince(self))

        if seconds < 60 {
            return "Just now"
        } else if seconds < 3600 {
            let minutes = seconds / 60
            return "\(minutes)m ago"
        } else if seconds < 86400 {
            let hours = seconds / 3600
            return "\(hours)h ago"
        } else {
            let days = seconds / 86400
            return "\(days)d ago"
        }
    }
}

// MARK: - CGFloat Extensions

extension CGFloat {

    /// Converts degrees to radians
    var degreesToRadians: CGFloat {
        return self * .pi / 180
    }

    /// Converts radians to degrees
    var radiansToDegrees: CGFloat {
        return self * 180 / .pi
    }

    /// Clamps value to specified range
    func clamped(to range: ClosedRange<CGFloat>) -> CGFloat {
        return Swift.min(Swift.max(self, range.lowerBound), range.upperBound)
    }
}

// MARK: - Int Extensions

extension Int {

    /// Returns formatted string with thousands separator
    var formattedWithSeparator: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: self)) ?? "\(self)"
    }

    /// Returns ordinal string (1st, 2nd, 3rd, etc.)
    var ordinal: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .ordinal
        return formatter.string(from: NSNumber(value: self)) ?? "\(self)"
    }
}

// MARK: - TimeInterval Extensions

extension TimeInterval {

    /// Formats time interval as mm:ss
    var formattedAsMinutesSeconds: String {
        let minutes = Int(self) / 60
        let seconds = Int(self) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    /// Formats time interval as hh:mm:ss
    var formattedAsHoursMinutesSeconds: String {
        let hours = Int(self) / 3600
        let minutes = (Int(self) % 3600) / 60
        let seconds = Int(self) % 60

        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        }
        return String(format: "%d:%02d", minutes, seconds)
    }
}

// MARK: - UIButton Extensions

extension UIButton {

    /// Sets image and title with proper spacing
    func setImageAndTitle(image: UIImage?, title: String, spacing: CGFloat = 8) {
        setImage(image, for: .normal)
        setTitle(title, for: .normal)

        let insetAmount = spacing / 2
        imageEdgeInsets = UIEdgeInsets(top: 0, left: -insetAmount, bottom: 0, right: insetAmount)
        titleEdgeInsets = UIEdgeInsets(top: 0, left: insetAmount, bottom: 0, right: -insetAmount)
        contentEdgeInsets = UIEdgeInsets(top: 0, left: insetAmount, bottom: 0, right: insetAmount)
    }
}

// MARK: - CALayer Extensions

extension CALayer {

    /// Applies rounded corners to specific corners
    func applyRoundedCorners(_ corners: CACornerMask, radius: CGFloat) {
        maskedCorners = corners
        cornerRadius = radius
    }

    /// Creates a pause animation
    func pauseAnimation() {
        let pausedTime = convertTime(CACurrentMediaTime(), from: nil)
        speed = 0.0
        timeOffset = pausedTime
    }

    /// Resumes a paused animation
    func resumeAnimation() {
        let pausedTime = timeOffset
        speed = 1.0
        timeOffset = 0.0
        beginTime = 0.0
        let timeSincePause = convertTime(CACurrentMediaTime(), from: nil) - pausedTime
        beginTime = timeSincePause
    }
}

// MARK: - UIStackView Extensions

extension UIStackView {

    /// Removes all arranged subviews
    func removeAllArrangedSubviews() {
        arrangedSubviews.forEach {
            removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
    }

    /// Adds multiple arranged subviews
    func addArrangedSubviews(_ views: [UIView]) {
        views.forEach { addArrangedSubview($0) }
    }
}

// MARK: - Collection Extensions

extension Collection {

    /// Returns element if index is valid, nil otherwise
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

// MARK: - UIViewController Extensions

extension UIViewController {

    /// Adds child view controller with constraints
    func addChild(_ child: UIViewController, to containerView: UIView) {
        addChild(child)
        containerView.addSubview(child.view)
        child.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            child.view.topAnchor.constraint(equalTo: containerView.topAnchor),
            child.view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            child.view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            child.view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
        child.didMove(toParent: self)
    }

    /// Removes child view controller
    func removeChild(_ child: UIViewController) {
        child.willMove(toParent: nil)
        child.view.removeFromSuperview()
        child.removeFromParent()
    }

    /// Shows a simple alert
    func showAlert(title: String, message: String, actionTitle: String = "OK", completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: actionTitle, style: .default) { _ in
            completion?()
        })
        present(alert, animated: true)
    }
}

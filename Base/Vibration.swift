//
//  Vibration.swift
//  Common
//
//  Created by 马陈爽 on 2022/11/26.
//

import Foundation
import UIKit

public enum VibrationType {
    case success
    case warning
    case error
    case selection
    case impact
}

public class Vibration {
    public static let shared = Vibration()
    
    private lazy var notifyGenerator: UINotificationFeedbackGenerator = {
        let generator = UINotificationFeedbackGenerator()
        return generator
    }()
    
    private lazy var selectionGenerator: UISelectionFeedbackGenerator = {
        let generator = UISelectionFeedbackGenerator()
        return generator
    }()
    
    private lazy var impactGenerator: UIImpactFeedbackGenerator = {
        let generator = UIImpactFeedbackGenerator()
        return generator
    }()
    
    public func occurred(forType type: VibrationType, withIntensity intensity: CGFloat = 0.5) {
        switch type {
        case .success:
            notifyGenerator.notificationOccurred(.success)
        case .warning:
            notifyGenerator.notificationOccurred(.warning)
        case .error:
            notifyGenerator.notificationOccurred(.error)
        case .selection:
            selectionGenerator.selectionChanged()
        case .impact:
            if #available(iOS 13.0, *) {
                impactGenerator.impactOccurred(intensity: intensity)
            } else {
                impactGenerator.impactOccurred()
            }
        }
    }
    
    
}

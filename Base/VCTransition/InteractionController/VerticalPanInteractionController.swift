//
//  VerticalPanInteractionController.swift
//  Common
//
//  Created by 马陈爽 on 2022/8/7.
//

import Foundation
import UIKit

public class VerticalPanInteractionController: BaseInteractionController {
    
    private static var verticalPanGestureKey = "VerticalPanGestureKey"
    
    override func prepareGestureRecognizer(inView view: UIView) {
        gestureRecognizer = objc_getAssociatedObject(view, &Self.verticalPanGestureKey) as? UIGestureRecognizer
        if gestureRecognizer != nil {
            view.removeGestureRecognizer(gestureRecognizer!)
        }
        
        gestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handleGesture(_:)))
        view.addGestureRecognizer(gestureRecognizer!)
        
        objc_setAssociatedObject(view, &Self.verticalPanGestureKey, gestureRecognizer, .OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    @objc func handleGesture(_ recognizer: UIPanGestureRecognizer) {
        guard let vc = viewController else { return }
        let translation = recognizer.translation(in: recognizer.view)
        let percent = translation.y / vc.view.frame.height
        switch recognizer.state {
        case .began:
            // 启动交互手势
            interactionInProgress = true
            if operation == .pop {
                vc.navigationController?.popViewController(animated: true)
            } else {
                vc.dismiss(animated: true)
            }
        case .changed:
            if interactionInProgress {
                update(percent)
            }
        case .ended, .cancelled:
            if interactionInProgress {
                interactionInProgress = false
                if recognizer.state == .cancelled {
                    self.cancel()
                    return
                }
                
                if percent > 0.2 {
                    //UINotificationFeedbackGenerator().notificationOccurred(.success)
                    finish()
                } else {
                    cancel()
                }
            }
        default:
            break
        }
    }
}

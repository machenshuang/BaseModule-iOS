//
//  BaseNavigationController.swift
//  Common
//
//  Created by 马陈爽 on 2022/8/7.
//

import Foundation
import UIKit

public class BaseNavigationController: UINavigationController {
    
    public var animationController: BaseAnimationController = PanAnimationController(forDirection: .upToDown)
    public var interactionController: BaseInteractionController?
    
    public override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
        self.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

extension BaseNavigationController: UINavigationControllerDelegate {
    
    /// 当 push 和 pop 的时候会调用此方法，用于判断是 push or pop
    public func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        animationController.reverse = operation == .pop
        return animationController
    }
    
    public func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        // 注册手势
        
        if let viewController = viewController as? BaseViewController,
            viewController.interactivePop,
            let interactionController = interactionController {
            interactionController.wireToViewController(viewController, forOperation: .pop)
            interactionController.gestureRecognizer?.delegate = self
        }
    }
    
    public func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        if let interactionController = interactionController, interactionController.interactionInProgress {
            return interactionController
        }
        return nil
    }
}

extension BaseNavigationController: UIGestureRecognizerDelegate {
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let _ = interactionController?.gestureRecognizer else {
            return true
        }
        
        if self.viewControllers.count <= 1 {
            return false
        }

        return true
    }
}



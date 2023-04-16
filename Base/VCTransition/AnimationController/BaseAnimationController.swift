//
//  BaseAnimationController.swift
//  Common
//
//  Created by 马陈爽 on 2022/8/7.
//

import Foundation
import UIKit

public class BaseAnimationController: NSObject {
    
    /// 动画运动方向
    public var reverse: Bool = false;
    
    /// 动画时间
    public var duration: Double = 0.25
    
    
    public func animateTransition(_ transitionContext: UIViewControllerContextTransitioning,
                                  fromVC: UIViewController,
                                  toVC: UIViewController,
                                  fromView: UIView,
                                  toView: UIView) {
        
    }
}

extension BaseAnimationController: UIViewControllerAnimatedTransitioning {
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromVC = transitionContext.viewController(forKey: .from),
        let toVC = transitionContext.viewController(forKey: .to) else {
            return
        }
        
        animateTransition(transitionContext, fromVC: fromVC, toVC: toVC, fromView: fromVC.view, toView: toVC.view)
    }
}

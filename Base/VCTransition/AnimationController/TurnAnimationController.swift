//
//  TurnAnimationController.swift
//  Common
//
//  Created by 马陈爽 on 2022/8/13.
//

import Foundation
import UIKit

public class TurnAnimationController: BaseAnimationController {
    public override func animateTransition(_ transitionContext: UIViewControllerContextTransitioning,
                                           fromVC: UIViewController,
                                           toVC: UIViewController,
                                           fromView: UIView,
                                           toView: UIView) {
        let containerView = transitionContext.containerView
        containerView.addSubview(toView)
        
        var transform = CATransform3DIdentity
        transform.m34 = -0.002
        containerView.layer.sublayerTransform = transform
        
        let initialFrame = transitionContext.initialFrame(for: fromVC)
        fromView.frame = initialFrame
        toView.frame = initialFrame
        
        let factor = self.reverse ? 1.0 : -1.0
        
        toView.layer.transform = CATransform3DMakeRotation(factor * -CGFloat.pi / 2, 0.0, 1.0, 0.0)
        
        let duration = transitionDuration(using: transitionContext)
        
        UIView.animateKeyframes(withDuration: duration, delay: 0.0, options: .init(rawValue: 0)) {
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.125) {
                fromView.layer.transform = CATransform3DMakeRotation(factor * CGFloat.pi / 2, 0.0, 1.0, 0.0)
            }
            UIView.addKeyframe(withRelativeStartTime: 0.125, relativeDuration: 0.125) {
                toView.layer.transform = CATransform3DMakeRotation(0, 0.0, 1.0, 0.0)
            }
        } completion: { (finished) in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }

    }
}

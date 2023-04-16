//
//  PanAnimationController.swift
//  Common
//
//  Created by 马陈爽 on 2022/8/7.
//

import Foundation
import UIKit

public enum PanAmimationDirection {
    case upToDown, leftToRight
}

public class PanAnimationController: BaseAnimationController {
    
    let direction: PanAmimationDirection
    
    public init(forDirection direction: PanAmimationDirection) {
        self.direction = direction
        super.init()
    }
    
    public override func animateTransition(_ transitionContext: UIViewControllerContextTransitioning,
                                           fromVC: UIViewController,
                                           toVC: UIViewController,
                                           fromView: UIView,
                                           toView: UIView) {
        let containerView = transitionContext.containerView
        containerView.addSubview(toView)
        if reverse {
            containerView.sendSubviewToBack(toView)
        } else {
            containerView.bringSubviewToFront(toView)
        }
        fromView.transform = .identity
        toView.transform = .identity
        switch direction {
        case .upToDown:
            if !reverse {
                toView.transform = .identity.translatedBy(x: 0, y: fromView.frame.maxY)
            }
        case .leftToRight:
            if !reverse {
                toView.transform = .identity.translatedBy(x: fromView.frame.maxX, y: 0)
            }
        }
        
        let duration = transitionDuration(using: transitionContext)
        
        UIView.animate(withDuration: duration, delay: 0, options: .curveLinear) {
            switch self.direction {
            case .upToDown:
                if self.reverse {
                    fromView.transform = .identity.translatedBy(x: 0, y: fromView.frame.maxY)
                } else {
                    toView.transform = .identity.translatedBy(x: 0, y: 0)
                }
            case .leftToRight:
                if self.reverse {
                    fromView.transform = .identity.translatedBy(x: fromView.frame.maxX, y: 0)
                } else {
                    toView.transform = .identity.translatedBy(x: 0, y: 0)
                }
            }
        } completion: { _ in
            fromView.transform = .identity
            toView.transform = .identity
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }

        
    }
}

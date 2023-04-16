//
//  BaseInteractionController.swift
//  Common
//
//  Created by 马陈爽 on 2022/8/7.
//

import Foundation
import UIKit

public enum InteractionOperation {
    case pop, dismiss
}

public class BaseInteractionController: UIPercentDrivenInteractiveTransition {
    
    var viewController: UIViewController?
    var operation: InteractionOperation?
    public var gestureRecognizer: UIGestureRecognizer?
    
    public var interactionInProgress: Bool = false
    
    public func wireToViewController(_ vc: UIViewController, forOperation operation: InteractionOperation) {
        self.viewController = vc
        self.operation = operation
        prepareGestureRecognizer(inView: vc.view)
    }
    
    func prepareGestureRecognizer(inView view: UIView) {
        
    }
    
}

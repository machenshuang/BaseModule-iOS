//
//  BaseViewController.swift
//  Common
//
//  Created by 马陈爽 on 2022/7/4.
//

import Foundation
import UIKit

open class BaseViewController: UIViewController {
    
    private var lastNavigationBarHidden: Bool = true
    
    open var prefersNavigationBarHidden: Bool {
        return true
    }
    
    open var interactivePop: Bool {
        return true
    }
    
    open override var prefersStatusBarHidden: Bool {
        return true
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        if let navigationController = navigationController as? BaseNavigationController,
            navigationController.interactionController == nil,
           interactivePop {
            navigationController.interactionController = VerticalPanInteractionController()
        }
        lastNavigationBarHidden = navigationController?.navigationBar.isHidden ?? true
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(prefersNavigationBarHidden, animated: false)
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(lastNavigationBarHidden, animated: false)
    }
}


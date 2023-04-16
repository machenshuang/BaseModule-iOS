//
//  UIViewController+Alert.swift
//  Common
//
//  Created by 马陈爽 on 2022/7/17.
//

import Foundation
import UIKit

public extension UIViewController {
    func showAlertDialog(withTitle title: String?,
                         withMessage message: String?,
                         defaultActionTitle: String?,
                         defaultHandler: (()->Void)? = nil,
                         cancelActionTitle: String?,
                         cancelHandler:(()->Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        if let title = defaultActionTitle {
            let action = UIAlertAction(title: title, style: .default) { [weak alert] _ in
                if let handler = defaultHandler {
                    handler()
                    return
                }
                alert?.dismiss(animated: true)
            }
            alert.addAction(action)
        }
        if let title = cancelActionTitle {
            let action = UIAlertAction(title: title, style: .default) { [weak alert] _ in
                if let handler = cancelHandler {
                    handler()
                    return
                }
                alert?.dismiss(animated: true)
            }
            alert.addAction(action)
        }
        self.present(alert, animated: true)
    }
}

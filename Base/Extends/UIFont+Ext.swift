//
//  UIFont+Ext.swift
//  Common
//
//  Created by 马陈爽 on 2022/7/20.
//

import Foundation
import UIKit

public enum FontType: String {
    case regularSourceHanSerifCN = "SourceHanSerifCN-Regular"
    case semiBoldSourceHanSerifCN = "SourceHanSerifCN-SemiBold"
}

public extension UIFont {
    static func fetchFont(withType type: FontType, size: CGFloat) -> UIFont? {
        return UIFont(name: type.rawValue, size: size)
    }
}

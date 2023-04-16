//
//  CGSize+Ext.swift
//  Common
//
//  Created by 马陈爽 on 2022/11/25.
//

import Foundation
import UIKit


public func + (left: CGSize, right: CGSize) -> CGSize {
    return CGSize(width: left.width + right.width, height: left.height + right.height)
}

public func - (left: CGSize, right: CGSize) -> CGSize {
    return CGSize(width: left.width - right.width, height: left.height - right.height)
}

public func += (left: inout CGSize, right: CGSize) {
    left = left + right
}

public func -= (left: inout CGSize, right: CGSize) {
    left = left - right
}

public func / (left: CGSize, right: CGFloat) -> CGSize {
    return CGSize(width: left.width / right, height: left.height / right)
}

public func * (left: CGSize, right: CGFloat) -> CGSize {
    return CGSize(width: left.width * right, height: left.height * right)
}

public func /= (left: inout CGSize, right: CGFloat) {
    left = left / right
}

public func *= (left: inout CGSize, right: CGFloat) {
    left = left * right
}

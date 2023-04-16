//
//  UIAdapter.swift
//  Common
//
//  Created by 马陈爽 on 2021/10/27.
//

import Foundation
import UIKit

let isHaveSafeArea: Bool = {
    guard let delegate = UIApplication.shared.delegate else {
        return false
    }
    guard let window = delegate.window else {
        return false
    }
    
    if (window?.safeAreaInsets.bottom ?? 0 > 0) {
        return true
    }
    
    return false
}()

public let commonSafeAreaInsets: UIEdgeInsets = {
    guard let delegate = UIApplication.shared.delegate else {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    guard let window = delegate.window else {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    if (window?.safeAreaInsets.bottom ?? 0 > 0) {
        return window!.safeAreaInsets
    }
    
    return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
}()

let standardWidth = 390.0
let standardHeight = 844.0
public let screenWidth = UIScreen.main.bounds.width
public let screenHeight = UIScreen.main.bounds.height
let screenScale: CGFloat = screenWidth / standardWidth

public protocol UIAdapter {
    var dp: CGFloat { get }
    var sp: CGFloat { get }
    
}

extension Int: UIAdapter {
    public var dp: CGFloat {
        return CGFloat(self) * screenScale
    }
    
    public var sp: CGFloat {
        return CGFloat(floor(CGFloat(self) * screenScale))
    }
}

extension Double: UIAdapter {
    public var dp: CGFloat {
        return CGFloat(self) * screenScale
    }

    public var sp: CGFloat {
        return CGFloat(floor(CGFloat(self) * screenScale))
    }
}

extension CGFloat: UIAdapter {
    public var dp: CGFloat {
        return self * screenScale
    }

    public var sp: CGFloat {
        return CGFloat(floor(self * screenScale))
    }
}

extension Float: UIAdapter {
    public var dp: CGFloat {
        return CGFloat(self) * screenScale
    }

    public var sp: CGFloat {
        return CGFloat(floor(CGFloat(self) * screenScale))
    }
}

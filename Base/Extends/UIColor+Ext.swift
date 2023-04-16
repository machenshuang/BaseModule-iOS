//
//  UIColor+Ext.swift
//  Common
//
//  Created by 马陈爽 on 2021/10/27.
//

import UIKit

public extension UIColor {
    convenience init(hexString: String) {
        let hexString = hexString.trimmingCharacters(in: .whitespacesAndNewlines)
        let scanner = Scanner(string: hexString)
             
        if hexString.hasPrefix("#") {
            scanner.scanLocation = 1
        }
             
        var color: UInt32 = 0
        scanner.scanHexInt32(&color)
        let mask = 0x000000FF
        let r = Int(color >> 16) & mask
        let g = Int(color >> 8) & mask
        let b = Int(color) & mask
             
        let red   = CGFloat(r) / 255.0
        let green = CGFloat(g) / 255.0
        let blue  = CGFloat(b) / 255.0
             
        self.init(red: red, green: green, blue: blue, alpha: 1)
    }
}


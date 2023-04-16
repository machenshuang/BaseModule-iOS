//
//  String+Ext.swift
//  Common
//
//  Created by 马陈爽 on 2022/7/5.
//

import Foundation
import UIKit

public extension String {
    func getWidthWithText(_ height: CGFloat, font: UIFont) -> CGFloat {
        return self.boundingRect(with: CGSize(width: 0, height: height), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font as Any], context: nil).size.width
    }
    
    func getHeightWithText(_ width: CGFloat, font: UIFont) -> CGFloat {
        return self.boundingRect(with: CGSize(width: width, height: 0), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font as Any], context: nil).size.height
    }
    
    func singleLineTruncation(withSize size: CGSize, font: UIFont, truncation: String = "...") -> String {
        let widthOfTruncation = truncation.boundingRect(with: CGSize(width: 0, height: size.height), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font as Any], context: nil).size.width
        let widthOfTitle = self.boundingRect(with: CGSize(width: 0, height: size.height), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font as Any], context: nil).size.width
        if widthOfTitle <= size.width {
            return self
        }
        let widthOfRemaining = size.width - widthOfTruncation
        var finalText = ""
        var lastText = ""
        for char in self {
            lastText.append(char)
            let width = lastText.boundingRect(with: CGSize(width: 0, height: size.height), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font as Any], context: nil).size.width
            if width >= widthOfRemaining {
                break
            }
            finalText = lastText
        }
        finalText.append(truncation)
        return finalText
    }
    
    func multiLineTruncation(withSize size: CGSize, font: UIFont, numberOfLine: Int, truncation: String = "...") -> String {
        let heightOfTitle = self.boundingRect(with: CGSize(width: size.width, height: 0), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font as Any], context: nil).size.height
        if heightOfTitle <= size.height {
            return self
        }
        let lastLineMinY = size.height / 3 * 2
        var finalText = ""
        var lastText = ""
        for char in self {
            lastText.append(char)
            let height = lastText.boundingRect(with: CGSize(width: size.width, height: 0), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font as Any], context: nil).size.height
            if height <= lastLineMinY {
                finalText = lastText
            } else {
                let tempText = lastText + truncation
                let sizeText = tempText.boundingRect(with: CGSize(width: size.width, height: 0), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font as Any], context: nil).size
                if sizeText.height <= size.height {
                    finalText = lastText
                } else {
                    break
                }
            }
        }
        finalText.append(truncation)
        return finalText
    }
    
    
    
}



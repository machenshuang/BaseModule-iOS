//
//  DeviceLevel.swift
//  Common
//
//  Created by 马陈爽 on 2022/5/14.
//

import Foundation
import CoreGraphics
import UIKit

public enum DeviceLevel {
    case high
    case middle
    case low
    
    public static func deviceLevel(by modelName: String) -> DeviceLevel {
        // "iPhone 6s" "iPad Pro (9.7 inch)"
        
        if modelName.contains("iPhone") {
            return iPhoneLevel(by: modelName)
        } else if modelName.contains("iPad") {
            return iPadLevel(by: modelName)
        } else {
            return iPodLevel(by: modelName)
        }
    }
    
    private static func iPhoneLevel(by modelName: String) -> DeviceLevel {
        let lowDevice = "iPhone8,1"
        let middleDeivice = "iPhone10,1"
        if modelName.count == lowDevice.count, modelName < lowDevice {
            return .low
        } else if modelName.count == middleDeivice.count, modelName < middleDeivice {
            return .middle
        } else {
            return .high
        }
    }
    
    private static func iPadLevel(by modelName: String) -> DeviceLevel {
        if modelName >= "iPad Pro 2" {
            return .high
        } else if modelName == "iPad Air 3" || modelName == "iPad mini 5" || modelName == "iPad Pro" {
            return .middle
        } else {
            return .low
        }
    }
    
    private static func iPodLevel(by modelName: String) -> DeviceLevel {
        if modelName == "iPod touch 7" {
            return .middle
        } else {
            return .low
        }
    }
    
    public static func fetchSuitableSize(with originalSize: CGSize, scale: CGFloat) -> CGSize {
        var outputWidth: CGFloat
        var outputHeight: CGFloat
        if scale > 1 {
            outputHeight = originalSize.height
            outputWidth = outputHeight * scale
            if outputWidth > originalSize.width {
                outputWidth = originalSize.width
                outputHeight = outputWidth / scale
            }
        } else {
            outputWidth = originalSize.width
            outputHeight = outputWidth / scale
            if outputHeight > originalSize.height {
                outputHeight = originalSize.height
                outputWidth = outputHeight * scale
            }
        }
        return CGSize(width: outputWidth, height: outputHeight)
    }
    
    public static func fetchSuitableScale(with size: CGSize) -> CGFloat {
        let type = DeviceLevel.deviceLevel(by: UIDevice.modelName)
        var maxValue: CGFloat
        switch type {
        case .high:
            maxValue = 4032
        case .middle:
            maxValue = 3840
        case .low:
            maxValue = 1920
        }
        
        //let scale = size.width / size.height
        var scale: CGFloat = 1
        if size.width > maxValue {
            scale = max(scale, size.width / maxValue)
        }
        if size.height > maxValue {
            scale = max(scale, size.height / maxValue)
        }
        
        return 1 / scale
    }
}

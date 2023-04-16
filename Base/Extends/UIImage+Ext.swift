//
//  UIImage+Ext.swift
//  Common
//
//  Created by 马陈爽 on 2021/12/5.
//

import Foundation
import UIKit

public extension UIImage {
    func fixImageOrientation() -> UIImage? {
        guard let cgImage = self.cgImage else { return nil }
        if self.imageOrientation == .up {
            return self
        }
        
        let width = cgImage.width
        let height = cgImage.height
        
        var contextW = width
        var contextH = height
        
        var transform: CGAffineTransform = .identity
        switch self.imageOrientation {
        case .down, .downMirrored:
            transform = transform.translatedBy(x: CGFloat(width), y: CGFloat(height))
            transform = transform.rotated(by: CGFloat.pi)
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: CGFloat(height), y: 0)
            transform = transform.rotated(by: 0.5 * CGFloat.pi)
            contextW = height
            contextH = width
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: CGFloat(width))
            transform = transform.rotated(by: -0.5 * CGFloat.pi)
            contextW = height
            contextH = width
        case .up, .upMirrored:
            break
        default:
            break
        }
        
        switch self.imageOrientation {
        case .upMirrored, .downMirrored:
            transform = transform.translatedBy(x: CGFloat(width), y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
            break
        case .leftMirrored, .rightMirrored:
            transform = transform.translatedBy(x: CGFloat(height), y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        default:
            break
        }
        
        guard let colorSpace = cgImage.colorSpace else {
            return nil
        }
        
        guard let context = CGContext(
            data: nil,
            width: contextW,
            height: contextH,
            bitsPerComponent: 8,
            bytesPerRow: contextW * 4,
            space: colorSpace,
            bitmapInfo: UInt32(cgImage.bitmapInfo.rawValue)
            ) else {
            return nil
        }
        
        context.concatenate(transform);
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        guard let newCGImg = context.makeImage() else {
            return nil
        }
        let img = UIImage(cgImage: newCGImg, scale: 1.0, orientation: .up)
        return img;
    }
    
    func resizeImageTo(target: CGFloat) -> UIImage {
        let width = self.size.width
        let height = self.size.height
        let scale = self.size.width / self.size.height
        var newSize = CGSize.zero
        if width <= target && height <= target {
            return self
        } else {
            if self.size.width > self.size.height {
                newSize.width = target
                newSize.height = target / scale
            } else {
                newSize.height = target
                newSize.width = target * scale
            }
            
            if newSize.width.truncatingRemainder(dividingBy: 2) != 0 {
                newSize.width = CGFloat(Int(newSize.width) + 1)
            }
            if newSize.height.truncatingRemainder(dividingBy: 2) != 0 {
                newSize.height = CGFloat(Int(newSize.height) + 1)
            }
            
            newSize.width = min(target, newSize.width)
            newSize.height = min(target, newSize.height)
        }
        let w = Int(newSize.width)
        let h = Int(newSize.height)
        let colorSpaceRef = CGColorSpaceCreateDeviceRGB()
        let bytesPerPixel = 4
        let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue | CGImageByteOrderInfo.orderDefault.rawValue
        guard let newContext = CGContext(data: nil, width: w, height: h, bitsPerComponent: 8, bytesPerRow: w * bytesPerPixel, space: colorSpaceRef, bitmapInfo: bitmapInfo) else { return self }
        let renderFrame = CGRect(x: 0, y: 0, width: w, height: h)
        newContext.draw(self.cgImage!, in: renderFrame)
        if let newCGImage = newContext.makeImage() {
            return UIImage(cgImage: newCGImage)
        }
        return self
    }
    
    func cropping(to rect: CGRect) -> UIImage? {
        guard let imageCGRef = self.cgImage else { return nil }
        guard let cropImgCGRef = imageCGRef.cropping(to: rect) else { return nil }
        return UIImage(cgImage: cropImgCGRef)
    }
}

//
//  Data+Meta.swift
//  Common
//
//  Created by 马陈爽 on 2021/11/21.
//

import Foundation
import CoreGraphics
import UIKit

extension Data {
    public func fetchMetaInfo() -> [String: Any] {
        guard let imageSource = CGImageSourceCreateWithData(self as CFData, nil) else { return [:] }
        guard let metaInfo = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil) as? [String: Any] else { return [:] }
        return metaInfo
    }
    
    public func setMetaInfo(_ info: [String: Any]) -> Data {
        guard let imageSource = CGImageSourceCreateWithData(self as CFData, nil) else { return self }
        guard let uniformTypeIdentifier = CGImageSourceGetType(imageSource) else { return self }
        let finalData = NSMutableData()
        guard let destination = CGImageDestinationCreateWithData((finalData as CFMutableData), uniformTypeIdentifier, 1, nil) else { return self }
        CGImageDestinationAddImageFromSource(destination, imageSource, 0, info as CFDictionary)
        guard CGImageDestinationFinalize(destination) else { return self }
        return finalData as Data
    }
}

extension Dictionary where Key == String {
    public func mergeOtherInfo(_ otherInfo: [String: Any], size: CGSize?, GPS: [String: Any]?, software: String, descripton: String) -> [String: Any] {
        
        let originalInfo: [String: Any] = self
        var info: [String: Any] = self

        info.merge(otherInfo) { (_, new) in new}
        guard var exif = info[kCGImagePropertyExifDictionary as String] as? [String: Any] else {
            return [:]
        }
        guard var tiff = info[kCGImagePropertyTIFFDictionary as String] as? [String: Any] else {
            return [:]
        }

        // 纠正宽高和方向
        info[kCGImagePropertyOrientation as String] = 1
        
        if let size = size {
            info[kCGImagePropertyPixelWidth as String] = abs(size.width)
            info[kCGImagePropertyPixelHeight as String] = abs(size.height)
        }

        
        // 合并 exif
        var originalExif: [String: Any]!
        originalExif = originalInfo[kCGImagePropertyExifDictionary as String] as? [String : Any]
        if originalExif == nil {
            originalExif = [:]
        }
        if let size = size {
            originalExif[kCGImagePropertyExifPixelXDimension as String] = abs(size.width)
            originalExif[kCGImagePropertyExifPixelYDimension as String] = abs(size.height)
        }
        originalExif[kCGImagePropertyExifDictionary as String] = exif
        exif.merge(originalExif) { (_, new) in new}
        exif.removeValue(forKey: kCGImagePropertyExifCustomRendered as String)
        info[kCGImagePropertyExifDictionary as String] = exif

        // 合并 tiff
        var originalTiff: [String: Any]!
        originalTiff = originalInfo[kCGImagePropertyTIFFDictionary as String] as? [String : Any]
        if originalTiff == nil {
            originalTiff = [:]
        }
        tiff.merge(originalTiff) { (_, new) in new}
        tiff[kCGImagePropertyTIFFSoftware as String] = software
        let tiffImageDescription = descripton
        
        tiff[kCGImagePropertyTIFFImageDescription as String] = tiffImageDescription
        info[kCGImagePropertyTIFFDictionary as String] = tiff

        // GPS
        if GPS != nil {
            info[kCGImagePropertyGPSDictionary as String] = GPS
        }
        
        if var makerApple = info[kCGImagePropertyMakerAppleDictionary as String] as? [ String: Any] {
            makerApple["25"] = 0
            info[kCGImagePropertyMakerAppleDictionary as String] = makerApple
        }
        return info
    }
}

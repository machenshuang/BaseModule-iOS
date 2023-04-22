//
//  AssetModel.swift
//  Common
//
//  Created by 马陈爽 on 2023/4/15.
//

import Foundation
import Photos

public class AssetModel {
    public let phAsset: PHAsset
    public var identifier: String {
        return phAsset.localIdentifier
    }
    
    public var mediaType: PHAssetMediaType {
        return phAsset.mediaType
    }
    
    public var createTimeStamp: Date? {
        return phAsset.creationDate
    }
    
    init(withAsset asset: PHAsset) {
        self.phAsset = asset
    }
    
    
}

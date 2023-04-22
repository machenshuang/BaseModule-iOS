//
//  AssetGroupModel.swift
//  Common
//
//  Created by 马陈爽 on 2023/4/16.
//

import Foundation
import Photos

public enum AssetGroupType {
    case smart  // 系统相簿
    case user  // 用户相簿
    case all    // 所有
}

public class AssetGroupModel {
    public let fetchResult: PHFetchResult<PHAsset>
    public let title: String
    public let count: Int
    public let type: AssetGroupType
    public let identifier: String
    
    public var latestModel: AssetModel? {
        var model: AssetModel?
        if let item = fetchResult.firstObject {
            model = AssetModel(withAsset: item)
        }
        return model
    }
    
    init(withResult result: PHFetchResult<PHAsset>, withTitle title: String, withIdentifier identifier: String, withType type: AssetGroupType) {
        self.fetchResult = result
        self.title = title
        self.count = result.count
        self.type = type
        self.identifier = identifier
    }
    
    
}

//
//  PHAsset+Ext.swift
//  Base
//
//  Created by 马陈爽 on 2023/4/20.
//

import Foundation
import Photos

extension PHAsset {
    public func requestImage(withSize size: CGSize? = nil, completion: @escaping ((UIImage?, String) -> Void)) {
        let requstOption = PHImageRequestOptions()
        requstOption.resizeMode = .exact
        requstOption.deliveryMode = .highQualityFormat
        requstOption.isNetworkAccessAllowed = true
        let identifier = self.localIdentifier
        PHCachingImageManager.default().requestImage(for: self, targetSize: size ?? CGSize(width: pixelWidth, height: pixelHeight), contentMode: .aspectFit, options: requstOption) {(image, _) in
            DispatchQueue.main.async {
                completion(image, identifier)
            }
        }
    }
}

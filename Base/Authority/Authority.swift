//
//  Authority.swift
//  Common
//
//  Created by 马陈爽 on 2022/5/28.
//

import Foundation
import AVFoundation
import Photos

public enum AuthorityStatus {
    case success
    case notAuthorized
}

public enum AuthorityType {
    case camera
    case photo
}

public struct Authority {
    public static func requestAuthority(with type: AuthorityType,
                                        callbackQueue: DispatchQueue = DispatchQueue.main,
                                        completion: @escaping ((AuthorityStatus) -> Void)) {
        switch type {
        case .camera:
            requestCameraAuthority(callbackQueue: callbackQueue, completion: completion)
        case .photo:
            requestPhotoAuthority(callbackQueue: callbackQueue, completion: completion)
        }
    }
    
    static func requestCameraAuthority(callbackQueue: DispatchQueue,
                                       completion: @escaping ((AuthorityStatus) -> Void)) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            callbackQueue.async {
                completion(.success)
            }
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { (granted) in
                callbackQueue.async {
                    if !granted {
                        completion(.notAuthorized)
                    } else {
                        completion(.success)
                    }
                }
            }
            break
        default:
            completion(.notAuthorized)
        }
    }
    
    static func requestPhotoAuthority(callbackQueue: DispatchQueue, completion: @escaping ((AuthorityStatus) -> Void)) {
        switch PHPhotoLibrary.authorizationStatus() {
        case .authorized:
            callbackQueue.async {
                completion(.success)
            }
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { status in
                callbackQueue.async {
                    if status == .authorized {
                        completion(.success)
                    } else {
                        completion(.notAuthorized)
                    }
                }
            }
        default:
            completion(.notAuthorized)
        }
    }
}

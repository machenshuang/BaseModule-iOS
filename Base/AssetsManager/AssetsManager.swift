//
//  AssetAlbumConfig.swift
//  Common
//
//  Created by 马陈爽 on 2023/4/16.
//

import Foundation
import Photos
import CoreLocation

public enum AssetsError: Error {
    case saveFailure(description: String?)
    case deleteFailure(description: String?)
    case notAuthority
}

public enum AssetsInfoKey {
    case photos
    case photoGroups
    case changedType
}

public enum AssetsChangedType {
    case update
    case insert
    case remove
    case none
}

public struct AssetsManagerConfig {
    public init() {}
    
    public var selectedIdentifiers: [String]?
    public var selectedAlbumName: String?
    public var selectedAlbumIdentifier: String?
    public var date: Date?
    public var location: CLLocation?
    
    public var options: PHFetchOptions?
    
    public var enableObserver: Bool = true

}

public class AssetsManager: NSObject {
    private var allResult: PHFetchResult<PHAsset>?
    private var userResult: PHFetchResult<PHAssetCollection>?
    private var smartResult: PHFetchResult<PHAssetCollection>?
    private var isObserver: Bool = false
    
    private var changedCallback: (([AssetsInfoKey: Any])->Void)?
    private var currentPhotoGroups: [AssetGroupModel] = []
    
    private var leastLocalIdentifiers: [String]?
    private var leastAlbumIdentifier: String?
    private var leastOptions: PHFetchOptions?
    
    public override init() {
        super.init()
    }
    
    deinit {
        debugPrint("AlbumKit deinit")
        if isObserver {
            PHPhotoLibrary.shared().unregisterChangeObserver(self)
        }
    }
    
    private var photoQueue = DispatchQueue(label: "com.ai.marki.AlbumKit")
    
    // MARK: - 保存
    
    public func saveImageToAlbum(with imageData: Data,
                                 withConfig config: AssetsManagerConfig,
                                 withCallbackQueue callbackQueue: DispatchQueue?,
                                 withCompletion completion: @escaping((Result<(assetId: String?, albumId: String?), AssetsError>) -> Void)) {
        photoQueue.async { [weak self] in
            guard let `self` = self else { return }
            if config.selectedAlbumName == nil && config.selectedAlbumIdentifier ==  nil {
                self.saveImage(imageData: imageData, date: config.date, location: config.location, assetAlbum: nil) { (assetId, success, error) in
                    if let error = error {
                        if let callbackQueue = callbackQueue {
                            callbackQueue.async {
                                completion(.failure(.saveFailure(description: error.localizedDescription)))
                            }
                        } else {
                            completion(.failure(.saveFailure(description: error.localizedDescription)))
                        }
                        return
                    }
                    
                    if let callbackQueue = callbackQueue {
                        callbackQueue.async {
                            completion(.success((assetId, nil)))
                        }
                    } else {
                        completion(.success((assetId, nil)))
                    }
                    
                }
                
            } else {
                self.findCollection(with: config) { [weak self](collection) in
                    guard let `self` = self else { return }
                    self.saveImage(imageData: imageData, date: config.date, location: config.location, assetAlbum: collection) { (assetId, success, error) in
                        if success {
                            if let callbackQueue = callbackQueue {
                                callbackQueue.async {
                                    completion(.success((assetId, collection?.localIdentifier)))
                                }
                            } else {
                                completion(.success((assetId, collection?.localIdentifier)))
                            }
                        } else {
                            if let callbackQueue = callbackQueue {
                                callbackQueue.async {
                                    completion(.failure(.saveFailure(description: error?.localizedDescription)))
                                }
                            } else {
                                completion(.failure(.saveFailure(description: error?.localizedDescription)))
                            }
                        }
                    }
                }
            }
        }
        
    }
    
    private func findCollection(with config: AssetsManagerConfig, completion: @escaping((PHAssetCollection?) -> Void)) {
        var assetCollection: PHAssetCollection?
        if let albumIdentifier = config.selectedAlbumIdentifier {
            assetCollection = PHAssetCollection.fetchAssetCollections(withLocalIdentifiers: [albumIdentifier], options: nil).firstObject
            completion(assetCollection)
            return
        } else if let albumName = config.selectedAlbumName {
            let list = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: nil)
            list.enumerateObjects { (album, index, stop) in
                if albumName == album.localizedTitle {
                    assetCollection = album
                    if let identifer = assetCollection?.localIdentifier {
                        UserDefaults.standard.set(identifer, forKey: albumName)
                    }
                    stop.initialize(to: true)
                }
            }
            if assetCollection == nil {
                PHPhotoLibrary.shared().performChanges {
                    let request = PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: albumName)
                    UserDefaults.standard.set(request.placeholderForCreatedAssetCollection.localIdentifier, forKey: albumName)
                } completionHandler: { (success, error) in
                    if !success {
                        completion(nil)
                        return
                    }
                    if let albumIdentifier = UserDefaults.standard.string(forKey: albumName) {
                        assetCollection = PHAssetCollection.fetchAssetCollections(withLocalIdentifiers: [albumIdentifier], options: nil).firstObject
                    } else {
                        let list = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: nil)
                        list.enumerateObjects { (album, index, stop) in
                            if albumName == album.localizedTitle {
                                assetCollection = album
                                if let identifer = assetCollection?.localIdentifier {
                                    UserDefaults.standard.set(identifer, forKey: albumName)
                                }
                                stop.initialize(to: true)
                            }
                        }
                    }
                    completion(assetCollection)
                }
            } else {
                completion(assetCollection)
            }
        }
    }
    
    // MARK: - 删除
    
    public func deleteAssets(withConfig config: AssetsManagerConfig,
                            withCallbackQueue callbackQueue: DispatchQueue? = nil,
                            withCompletion completion: @escaping ((Result<Bool, AssetsError>)->Void)) {
        photoQueue.async { [weak self] in
            guard let `self` = self else { return }
            if let assetIdentifiers = config.selectedIdentifiers,
                !assetIdentifiers.isEmpty {
                self.requestPhotos(forConfig: config) { (result) in
                    switch result {
                    case .success(let models):
                        let deleteModels = models.map { return $0.phAsset}
                        PHPhotoLibrary.shared().performChanges {
                            PHAssetChangeRequest.deleteAssets(deleteModels as NSArray)
                        } completionHandler: { (success, error) in
                            if let error = error {
                                if let callbackQueue = callbackQueue {
                                    callbackQueue.async {
                                        completion(.failure(.deleteFailure(description: error.localizedDescription)))
                                    }
                                } else {
                                    completion(.failure(.deleteFailure(description: error.localizedDescription)))
                                }
                                return
                            }
                            if let callbackQueue = callbackQueue {
                                callbackQueue.async {
                                    completion(.success(success))
                                }
                            } else {
                                completion(.success(success))
                            }
                        }
                    case .failure(let error):
                        if let callbackQueue = callbackQueue {
                            callbackQueue.async {
                                completion(.failure(error))
                            }
                        } else {
                            completion(.failure(error))
                        }
                    }
                }
            } else {
                if let callbackQueue = callbackQueue {
                    callbackQueue.async {
                        completion(.failure(.deleteFailure(description: nil)))
                    }
                } else {
                    completion(.failure(.deleteFailure(description: nil)))
                }
            }
        }
        
    }
    
    private func saveImage(imageData: Data,
                           date: Date?,
                           location: CLLocation?,
                           assetAlbum: PHAssetCollection?,
                           completion: @escaping((String?, Bool, Error?) -> Void)) {
        var assetId: String?
        if let assetAlbum = assetAlbum {
            PHPhotoLibrary.shared().performChanges {
                let options = PHAssetResourceCreationOptions()
                let request = PHAssetCreationRequest.forAsset()
                
                guard let assetPlaceHolder = request.placeholderForCreatedAsset else {
                    completion(nil, false, nil)
                    return
                }
                guard let albumChangeRequset = PHAssetCollectionChangeRequest(for: assetAlbum) else {
                    completion(nil, false, nil)
                    return
                }
                request.addResource(with: .photo, data: imageData, options: options)
                request.creationDate = date ?? Date()
                request.location = location
                albumChangeRequset.addAssets([assetPlaceHolder] as NSFastEnumeration)
                assetId = assetPlaceHolder.localIdentifier
            } completionHandler: { success, error in
                completion(success ? assetId : nil, success, error)
            }
        } else {
            PHPhotoLibrary.shared().performChanges ({
                let options = PHAssetResourceCreationOptions()
                let request = PHAssetCreationRequest.forAsset()
                request.addResource(with: .photo, data: imageData, options: options)
                request.creationDate = Date()
                request.location = location
            }) { (success, error) in
                completion(nil, success, error)
            }
        }
        
    }
    
    // MARK: 读取
    
    public func requestAssetGroups(withConfig config: AssetsManagerConfig,
                                   withCallbackQueue callbackQueue: DispatchQueue? = nil,
                                   withCompletion completion: @escaping ((Result<[AssetGroupModel], AssetsError>) -> Void)) {
        self.photoQueue.async { [weak self] in
            guard let `self` = self else { return }
            let photoGroups = self.fetchPhotoGroupsWithConfig(config)
            if let callbackQueue = callbackQueue {
                callbackQueue.async {
                    completion(.success(photoGroups))
                }
            } else {
                completion(.success(photoGroups))
            }
            self.currentPhotoGroups = photoGroups
        }
    }
    
    public func requestPhotos(forConfig config: AssetsManagerConfig,
                              withCallbackQueue callbackQueue: DispatchQueue? = nil,
                              withCompletion completion: @escaping ((Result<[AssetModel], AssetsError>) -> Void)) {
        
        self.photoQueue.async { [weak self] in
            guard let `self` = self else { return }
            self.requestPhotos(config, callbackQueue, completion)
        }
    }
    
    public func setDataChangedListener(_ callback: @escaping (([AssetsInfoKey: Any])->Void)) {
        self.changedCallback = callback
        if !isObserver {
            PHPhotoLibrary.shared().register(self)
            isObserver = true
        }
    }
    
    public func removeDataChangedListener() {
        self.changedCallback = nil
        if isObserver {
            PHPhotoLibrary.shared().unregisterChangeObserver(self)
            isObserver = false
        }
    }
    
    private func requestPhotos(_ config: AssetsManagerConfig,
                               _ callbackQueue: DispatchQueue?,
                               _ completion: @escaping ((Result<[AssetModel], AssetsError>) -> Void)) {
        leastAlbumIdentifier = nil
        leastLocalIdentifiers = nil
        leastOptions = nil
        var photos: [AssetModel]
        // 获取所有照片
        if config.selectedAlbumName == nil && config.selectedAlbumIdentifier == nil {
            photos = fetchPhotosWithIdentifiers(config.selectedIdentifiers, config.options)
        } else {
            // 根据 localIdentifier 或 name 获取指定相册的所有照片
            photos = fetchPhotosWithAlbum(config.selectedAlbumName, config.selectedAlbumIdentifier, config.options)
        }
        leastAlbumIdentifier = config.selectedAlbumIdentifier
        leastLocalIdentifiers = config.selectedIdentifiers
        leastOptions = config.options
        if let callbackQueue = callbackQueue {
            callbackQueue.async {
                completion(.success(photos))
            }
        } else {
            completion(.success(photos))
        }
    }
    
    private func fetchPhotoGroupsWithConfig(_ config: AssetsManagerConfig) -> [AssetGroupModel] {
        leastOptions = nil
        var photos: [AssetGroupModel] = []
        
        // 系统自动创建的相簿
        let smartAlbums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .albumRegular, options: nil)
        photos.append(contentsOf: filterPhotos(config.options, smartAlbums, .smart))
        self.smartResult = smartAlbums
        
        // 用户自定义相册
        if let userAlbums = PHCollectionList.fetchTopLevelUserCollections(with: nil) as? PHFetchResult<PHAssetCollection> {
            photos.append(contentsOf: filterPhotos(config.options, userAlbums, .user))
            self.userResult = userAlbums
        }
        leastOptions = config.options
        debugPrint("AlbumKit fetchPhotoGroups groups.count = \(photos.count)")
        return photos
    }
    
    private func fetchPhotosWithIdentifiers(_ identifiers: [String]?, _ options: PHFetchOptions?) -> [AssetModel] {
        var photoOptions: PHFetchOptions
        if let options = options {
            photoOptions = options
        } else {
            photoOptions = PHFetchOptions()
            photoOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        }
        var allAssets: PHFetchResult<PHAsset>
        if let identifiers = identifiers {
            allAssets = PHAsset.fetchAssets(withLocalIdentifiers: identifiers, options: photoOptions)
            debugPrint("AlbumKit fetchPhotosWithIdentifiers with identifiers.count = \(identifiers.count)")
        } else {
            allAssets = PHAsset.fetchAssets(with: photoOptions)
            debugPrint("AlbumKit fetchPhotosWithIdentifiers without identifiers")
        }
        var photos: [AssetModel] = []
        allAssets.enumerateObjects { (asset, index, _) in
            photos.append(AssetModel(withAsset: asset))
        }
        self.allResult = allAssets
        debugPrint("AlbumKit fetchPhotosWithIdentifiers photos.count = \(photos.count)")
        return photos
    }
    
    private func fetchPhotosWithAlbum(_ name: String?, _ identifier: String?, _ options: PHFetchOptions?) -> [AssetModel] {
        var photoOptions: PHFetchOptions
        if let options = options {
            photoOptions = options
        } else {
            photoOptions = PHFetchOptions()
            photoOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        }
        var photos: [AssetModel] = []
        var identifier = identifier
        if let name = name {
            debugPrint("AlbumKit fetchPhotosWithAlbum with name = \(name)")
            let collections = PHAssetCollection.fetchAssetCollections(with: PHAssetCollectionType.album, subtype: PHAssetCollectionSubtype.albumRegular, options: PHFetchOptions())
            collections.enumerateObjects { (collection, number, stop) in
                if let localizedTitle:String = collection.localizedTitle,
                    localizedTitle == name {
                    identifier = collection.localIdentifier
                    stop.pointee = true
                }
            }
        }
        
        if let identifier = identifier,
            let selectedCollection = PHAssetCollection.fetchAssetCollections(withLocalIdentifiers: [identifier], options: PHFetchOptions()).firstObject  {
            debugPrint("AlbumKit fetchPhotosWithAlbum with identifier  = \(identifier)")
            let allAssets = PHAsset.fetchAssets(in: selectedCollection, options: photoOptions)
            allAssets.enumerateObjects { (asset, index, _) in
                photos.append(AssetModel(withAsset: asset))
            }
            self.allResult = allAssets
        }
        debugPrint("AlbumKit fetchPhotosWithAlbum with name or identifier photos.count = \(photos.count)")
        return photos
    }
    
    private func filterPhotos(_ options: PHFetchOptions?, _ albums: PHFetchResult<PHAssetCollection>, _ type: AssetGroupType) -> [AssetGroupModel] {
        var models: [AssetGroupModel] = []
        
        var photoOptions: PHFetchOptions
        if let options = options {
            photoOptions = options
        } else {
            photoOptions = PHFetchOptions()
            photoOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        }
        albums.enumerateObjects(options: .concurrent) {(collection, index, stop) in
            if collection .isKind(of: PHAssetCollection.self){
                let assetcollection = collection
                // 通过检索条件从assetcollection中检索出结果
                let assetResult = PHAsset.fetchAssets(in: assetcollection, options: photoOptions)
                if assetResult.count > 0 && collection.localizedTitle != "最近删除" &&  collection.localizedTitle != "Recently Deleted"{
                    models.append(AssetGroupModel(withResult: assetResult, withTitle: collection.localizedTitle ?? "", withIdentifier: collection.localIdentifier, withType: type))
                }
            }
        }
        debugPrint("AlbumKit filterPhotos type = \(type), groups.count = \(models.count)")
        return models
    }
}

extension AssetsManager: PHPhotoLibraryChangeObserver {
    public func photoLibraryDidChange(_ changeInstance: PHChange) {
       
        var changedAssets: [AssetModel]?
        var changedGroups: [AssetGroupModel]?
        var type: AssetsChangedType = .none
        self.photoQueue.async { [weak self] in
            guard let `self` = self else { return }
            var ret: Bool = false
            if let result = self.allResult,
                let changeDetails = changeInstance.changeDetails(for: result) {
                type = self.needUpdate(changeDetails, changeInstance)
                if type != .none {
                    debugPrint("AlbumKit photoLibraryDidChange assets changed = \(type)")
                    if let identifier = self.leastAlbumIdentifier {
                        changedAssets = self.fetchPhotosWithAlbum(nil, identifier, self.leastOptions)
                    } else {
                        changedAssets = self.fetchPhotosWithIdentifiers(self.leastLocalIdentifiers, self.leastOptions)
                    }
                    self.allResult = changeDetails.fetchResultAfterChanges
                    ret = true
                }
            }
            
            if let result = self.smartResult {
                let smartAlbums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .albumRegular, options: nil)
                let photos = self.filterPhotos(self.leastOptions, smartAlbums, .smart)
                self.smartResult = smartAlbums
                self.currentPhotoGroups.removeAll { $0.type == .smart }
                if self.currentPhotoGroups.isEmpty {
                    self.currentPhotoGroups.append(contentsOf: photos)
                } else {
                    self.currentPhotoGroups.insert(contentsOf: photos, at: 0)
                }
                changedGroups = self.currentPhotoGroups
                ret = true
                if type == .none {
                    type = .update
                }
                debugPrint("AlbumKit photoLibraryDidChange smartResult changed = \(type)")
            }
            
            if let result = self.userResult,
                let changeDetails = changeInstance.changeDetails(for: result) {
                if let userAlbums = PHCollectionList.fetchTopLevelUserCollections(with: nil) as? PHFetchResult<PHAssetCollection> {
                    let photos = self.filterPhotos(self.leastOptions, userAlbums, .user)
                    self.userResult = changeDetails.fetchResultAfterChanges
                    self.currentPhotoGroups.removeAll { $0.type == .user }
                    self.currentPhotoGroups.append(contentsOf: photos)
                    changedGroups = self.currentPhotoGroups
                    ret = true
                    if type == .none {
                        type = .update
                    }
                    debugPrint("AlbumKit photoLibraryDidChange userResult changed = \(type)")
                }
            }
            
            
            if ret {
                DispatchQueue.main.async {
                    if let callback = self.changedCallback {
                        var info: [AssetsInfoKey: Any] = [:]
                        if let changedAssets = changedAssets {
                            info[.photos] = changedAssets
                        }
                        if let changedGroups = changedGroups {
                            info[.photoGroups] = changedGroups
                        }
                        info[.changedType] = type
                        callback(info)
                    }
                }
            }
        }
    }
    
    private func needUpdate<T>(_ changeDetail: PHFetchResultChangeDetails<T>, _ changeInstance: PHChange) -> AssetsChangedType where T : PHObject {
        let insertObjects = changeDetail.insertedObjects
        let removeObjects = changeDetail.removedObjects
        let changedObjects = changeDetail.changedObjects.filter( {
            return changeInstance.changeDetails(for: $0)?.assetContentChanged == true
        })
        if changeDetail.hasIncrementalChanges && (insertObjects.count > 0 || removeObjects.count > 0 || changedObjects.count > 0) {
            if insertObjects.count > 0 {
                return .insert
            } else if removeObjects.count > 0 {
                return .remove
            } else {
                return .update
            }
        }
        return .none
        
    }
}

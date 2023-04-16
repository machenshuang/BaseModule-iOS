//
//  NetworkManager.swift
//  Common
//
//  Created by 马陈爽 on 2022/5/29.
//

import Foundation
import Moya

public struct NetworkManager {
    
    public static func request<T: BaseResponse>(service: BaseService, callbackQueue: DispatchQueue = DispatchQueue.main, completion: @escaping ((T)->Void)) {
        let provider = MoyaProvider<BaseService>()
        provider.request(service, callbackQueue: callbackQueue, progress: nil) { result in
            switch result {
            case .success(let response):
                do {
                    let _ = try response.filterSuccessfulStatusCodes()
                    let data = try response.mapJSON()
                    
                } catch {
                    debugPrint("error = \(error.localizedDescription)")
                }
            case .failure(let error):
                debugPrint("error = \(error.localizedDescription)")
                break
            }
        }
    }
    
}

//
//  ServiceAPI.swift
//  Common
//
//  Created by 马陈爽 on 2022/5/29.
//

import Foundation
import Moya

public class BaseService: TargetType {
    public var baseURL: URL {
        return URL(fileURLWithPath: "")
    }
    
    public var path: String {
        return  ""
    }
    
    public var method: Moya.Method {
        return .get
    }
    
    public var task: Task {
        return .requestPlain
    }
    
    public var headers: [String : String]?
}

public class BaseResponse {
    public let responseData: [String: Any]
    public required init(responseData: [String: Any]) {
        self.responseData = responseData
    }
}

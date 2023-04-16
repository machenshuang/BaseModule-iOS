//
//  LocationService.swift
//  Common
//
//  Created by 马陈爽 on 2022/5/29.
//

import Foundation
import Moya

public class LocationService: BaseService {
    private let acceptLanguage: String
    private let latitude: Double
    private let longitude: Double
    
    public override var baseURL: URL {
        return URL(string: "https://nominatim.openstreetmap.org")!
    }
    
    public override var path: String {
        return "/reverse"
    }
    
    public init(acceptLanguage: String, latitude: Double, longitude: Double) {
        self.acceptLanguage = acceptLanguage
        self.latitude = latitude
        self.longitude = longitude
    }
    
    public override var task: Task {
        return .requestParameters(parameters: ["format": "json"], encoding: URLEncoding.default)
    }
}

public class LocationResponse: BaseResponse {
    var country: String?
    var city: String?
    var state: String?
    
    public required init(responseData: [String : Any]) {
        super.init(responseData: responseData)
    }
}

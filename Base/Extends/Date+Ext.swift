//
//  Date.swift
//  Common
//
//  Created by 马陈爽 on 2022/6/23.
//

import Foundation

public extension Date {
    func getString(for formatter: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en")
        dateFormatter.dateFormat = formatter
        let result = dateFormatter.string(from: self)
        return result
    }
    
    static func formatterString(with string: String, formatter: String) -> Date? {
        let dateFormatter = DateFormatter.init()
        dateFormatter.dateFormat = formatter
        dateFormatter.calendar = Calendar.init(identifier: .gregorian)
        return dateFormatter.date(from: string)
    }
}

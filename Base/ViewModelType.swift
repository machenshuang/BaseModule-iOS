//
//  ViewModelType.swift
//  Common
//
//  Created by 马陈爽 on 2022/5/14.
//

import Foundation

public protocol ViewModelType {
    associatedtype Input
    associatedtype Output
    
    func transform(input: Input?) -> Output
}

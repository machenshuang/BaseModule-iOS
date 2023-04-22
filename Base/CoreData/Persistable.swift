//
//  Persistable.swift
//  Common
//
//  Created by 马陈爽 on 2022/6/13.
//

import Foundation
import CoreData

public protocol Persistable: NSFetchRequestResult {
    static func fetchRequest() -> NSFetchRequest<Self>
    static func entityName() -> String
}

extension NSManagedObjectContext {
    public func create<T: NSFetchRequestResult>() -> T {
        guard let entity = NSEntityDescription.insertNewObject(forEntityName: String(describing: T.self),
                into: self) as? T else {
            fatalError()
        }
        return entity
    }
}

//
//  CoreDataStack.swift
//  Common
//
//  Created by 马陈爽 on 2022/6/12.
//

import Foundation
import CoreData

class CoreDataStack {
    
    static let share = CoreDataStack()
    
    private let storeCoordinator: NSPersistentStoreCoordinator
    let backgroundContext: NSManagedObjectContext
    let mainContext: NSManagedObjectContext
    
    public init() {
        let path = Bundle.main.path(forResource: "CommonBundle", ofType: "bundle")!
        let bundle = Bundle(path: path)!
        guard let url = bundle.url(forResource: "Database", withExtension: "momd"),
              let model = NSManagedObjectModel(contentsOf: url) else {
            fatalError()
        }
        self.storeCoordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
        self.mainContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        self.backgroundContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        self.mainContext.persistentStoreCoordinator = self.storeCoordinator
        self.backgroundContext.persistentStoreCoordinator = self.storeCoordinator
        self.migrateStore()
    }
    
    private func migrateStore() {
        guard let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last else {
            fatalError()
        }
        let storeUrl = url.appendingPathComponent("Model.sqlite")
        // 数据库升级
        let mOptions = [NSMigratePersistentStoresAutomaticallyOption: true,
                                   NSInferMappingModelAutomaticallyOption: true]
        do {
            try storeCoordinator.addPersistentStore(ofType: NSSQLiteStoreType,
                    configurationName: nil,
                    at: storeUrl,
                    options: mOptions)
        } catch {
            fatalError("Error migrating store: \(error)")
        }
    }
}

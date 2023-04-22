//
//  CoreDataStack.swift
//  Common
//
//  Created by 马陈爽 on 2022/6/12.
//

import Foundation
import CoreData

public class CoreDataStack {
    
    public static let share = CoreDataStack()
    
    private var storeCoordinator: NSPersistentStoreCoordinator?
    public let backgroundContext: NSManagedObjectContext
    public let mainContext: NSManagedObjectContext
    
    init() {
        self.mainContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        self.backgroundContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
    }
    
    public func config(withPath path: String) {
        let url = URL.init(fileURLWithPath: path)
        guard let model = NSManagedObjectModel(contentsOf: url) else {
            log.info("CoreDataStack", "configure failure path = \(path)")
            return
        }
        self.storeCoordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
        self.mainContext.persistentStoreCoordinator = self.storeCoordinator!
        self.backgroundContext.persistentStoreCoordinator = self.storeCoordinator!
        migrateStore()
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
            try storeCoordinator!.addPersistentStore(ofType: NSSQLiteStoreType,
                    configurationName: nil,
                    at: storeUrl,
                    options: mOptions)
        } catch {
            log.error("CoreDataStack migrateStore", "Error migrating store: \(error)")
        }
    }
}

//
//  CoreDataStorage.swift
//  Common
//
//  Created by 马陈爽 on 2022/6/12.
//

import Foundation
import CoreData

public class CoreDataStorage <T: Persistable> {
    private let context: NSManagedObjectContext
    
    public init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    // MARK: - 同步操作
    
    public func query(with predicate: NSPredicate?, sortDescriptors: [NSSortDescriptor]?) throws -> [T]? {
        let request = T.fetchRequest()
        request.predicate = predicate
        if let descriptors = sortDescriptors {
            request.sortDescriptors = descriptors
        }
        let entities = try self.context.fetch(request)
        return entities
    }
    
    public func save(with predicate: NSPredicate?, update updateClosure: @escaping (T) -> Void) throws -> T {
        let request = T.fetchRequest()
        let result: T
        if let predicate = predicate {
            request.predicate = predicate
            result = try self.context.fetch(request).first ?? self.context.create()
        } else {
            result = self.context.create()
        }
        updateClosure(result)
        try self.context.save()
        return result
    }
    
    public func delete(with predicate: NSPredicate) throws -> Bool {
        let request = T.fetchRequest()
        request.predicate = predicate
        guard let result = try self.context.fetch(request).first as? NSManagedObject else {
            return false
        }
        self.context.delete(result)
        try self.context.save()
        return true
    }
    
    public func batchInsert(with count: Int, update updateClosure: @escaping ([T]) -> Void) throws -> Bool {
        var results = [T]()
        for _ in 0 ..< count {
            results.append(self.context.create())
        }
        updateClosure(results)
        try self.context.save()
        return true
    }
    
    // MARK: - 异步处理
    
    public func query(with predicate: NSPredicate?,
               sortDescriptors: [NSSortDescriptor]?,
               complete closure: @escaping (_ result: Result<[T]?, Error>) -> Void) {
        self.context.perform { [weak self] in
            guard let `self` = self else { return }
            do {
                let entities = try self.query(with: predicate, sortDescriptors: sortDescriptors)
                closure(.success(entities))
            } catch {
                closure(.failure(error))
            }
        }
    }
    
    public func query(with predicate: NSPredicate?,
               sortDescriptors: [NSSortDescriptor]?,
               fetchLimit: Int,
               complete closure: @escaping (_ result: Result<[T]?, Error>) -> Void) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        fetchRequest.fetchLimit = fetchLimit
        fetchRequest.fetchOffset = 0
        
        fetchRequest.entity = NSEntityDescription.entity(forEntityName: T.entityName(), in: context)
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = sortDescriptors
        
        context.perform { [weak self] in
            guard let `self` = self else { return }
            do {
                if let fetchEntities: [T] = try self.context.fetch(fetchRequest) as? [T] {
                    closure(.success(fetchEntities))
                } else {
                    closure(.success(nil))
                }
            } catch {
                closure(.failure(error))
            }
        }
        
        self.context.perform { [weak self] in
            guard let `self` = self else { return }
            do {
                let entities = try self.query(with: predicate, sortDescriptors: sortDescriptors)
                closure(.success(entities))
            } catch {
                closure(.failure(error))
            }
        }
    }
    
    public func save(with predicate: NSPredicate?,
            update updateClosure: @escaping (T) -> Void,
            complete completeClosure: @escaping (Result<T, Error>) -> Void) {
        self.context.perform { [weak self] in
            guard let `self` = self else { return }
            do {
                let entity = try self.save(with: predicate, update: updateClosure)
                completeClosure(.success(entity))
            } catch  {
                completeClosure(.failure(error))
            }
        }
    }
        
    public func delete(with predicate: NSPredicate, complete closure: @escaping (Error?) -> Void) {
        self.context.perform { [weak self] in
            guard let `self` = self else { return }
            do {
                let _ = try self.delete(with: predicate)
                closure(nil)
            } catch {
                closure(error)
            }
        }
    }
    
    public func batchUpdate(with predicate: NSPredicate,
               update updateClosure: @escaping ([T]?) -> Void,
           complete completeClosure: @escaping (Error?) -> Void) {
        self.context.perform { [weak self] in
            guard let `self` = self else { return }
            let request = T.fetchRequest()
            request.predicate = predicate
            do {
                let results = try self.context.fetch(request)
                updateClosure(results)
                try self.context.save()
                completeClosure(nil)
            } catch  {
                completeClosure(error)
            }
        }
        
    }
    
    public func batchInsert(with count: Int,
           update updateClosure: @escaping ([T]) -> Void,
       complete completeClosure: @escaping (Error?) -> Void) {
        self.context.perform { [weak self] in
            guard let `self` = self else { return }
            do {
                let _ = try self.batchInsert(with: count, update: updateClosure)
            } catch  {
                completeClosure(error)
            }
        }
    }
    
    public func batchDelete(with predicate: NSPredicate,
                   complete closure: @escaping (Error?) -> Void) {
        self.context.perform { [weak self] in
            guard let `self` = self else { return }
            let request = T.fetchRequest()
            request.predicate = predicate
            do {
                guard let results = try self.context.fetch(request) as? [NSManagedObject] else {
                    closure(nil)
                    return
                }
                results.forEach {
                    self.context.delete($0)
                }
                try self.context.save()
                closure(nil)
            } catch {
                closure(error)
            }
        }
    }
}

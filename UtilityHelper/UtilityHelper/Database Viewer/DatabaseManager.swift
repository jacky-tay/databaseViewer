//
//  DatabaseManager.swift
//  UtilityHelper
//
//  Created by Jacky Tay on 17/07/17.
//  Copyright © 2017 JackyTay. All rights reserved.
//

import UIKit
import CoreData

public class DatabaseManager {
    internal var databaseNames = [String]()
    internal var databases = [String : [Table]]()
    internal var contextDict = [String : NSManagedObjectContext]()
    private var sqliteNames = [String]()

    public static let sharedInstance = DatabaseManager()

    public func prepareDatabases(with contexts: [NSManagedObjectContext?], and sqlites: [String]) {
        prepareDatabase(for: contexts.flatMap { $0 })
        databaseNames = Array(databases.keys).sorted()
        updateEntitiesCount()
    }

    public func presentDatabaseViewer(navigationController: UINavigationController?) {
        let vc = DatabaseTableListViewController.getViewController()
        navigationController?.presentViewControllerModally(vc)
    }

    private func updateEntitiesCount() {
        updateEntitiesCountForContexts()
    }

    private func ensureDatabaseNameIsUnique(name: String) -> String {
        guard databases.keys.contains(name) else {
            return name
        }
        let count = Array(databases.keys)
            .filter { $0.contains(name) }
            .count
        return name + "\(count)"
    }

    // MARK: - NSManagedObjectContext
    private func prepareDatabase(for contexts: [NSManagedObjectContext]) {
        for context in contexts {
            var name = (context.persistentStoreCoordinator?.persistentStores.flatMap { $0.url?.absoluteString }.first)?.components(separatedBy: "/").last?.components(separatedBy: ".").first ?? "Context \(databases.count)"
            name = ensureDatabaseNameIsUnique(name: name)
            databases[name] = prepareTables(for: context, databaseName: name)
            contextDict[name] = context
        }
    }

    private func updateEntitiesCountForContexts() {
        for dict in contextDict {
            if let tables = databases[dict.key] {
                dict.value.performAndWait({
                    for table in tables {
                        if let count = (try? dict.value.count(for: NSFetchRequest(entityName: table.name))) {
                            table.count = count
                        } // update entity's count
                    } // for tables
                }) // block and wait
            } // get tables
        } // for every context in dictionary
    }

    private func prepareTables(for context: NSManagedObjectContext, databaseName: String) -> [Table] {
        var results = [Table]()
        if let entities = context.persistentStoreCoordinator?.managedObjectModel.entities.sorted(by: { $0.name ?? "" < $1.name ?? "" }) {
            for entity in entities {
                if let name = entity.name {
                    let properties = entity.attributesByName.values.toDictionary(key: { $0.name }, value: { $0.attributeType })
                    results.append(Table(databaseName: databaseName, name: name, properties: properties, relationships: entity.relationshipsByName.flatMap({ $0.value.destinationEntity?.name })))
                }
            } // for
        } // entities
        return results
    }

}


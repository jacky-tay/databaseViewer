//
//  DatabaseManager.swift
//  UtilityHelper
//
//  Created by Jacky Tay on 17/07/17.
//  Copyright © 2017 JackyTay. All rights reserved.
//

import UIKit
import CoreData

typealias DatabaseTablesPair = (databaseName: String, tables: [Table])

public class DatabaseManager {
    private var databases = [DatabaseTablesPair]()
    internal var contextDict = [String : NSManagedObjectContext]()
    private var sqliteNames = [String]()

    public static let sharedInstance = DatabaseManager()

    public func prepareDatabases(with contexts: [NSManagedObjectContext?], and sqlites: [String]) {
        databases.removeAll()
        prepareDatabase(for: contexts.flatMap { $0 })
        databases.sort(by: { $0.databaseName < $1.databaseName })
        updateEntitiesCount()
    }

    public func presentDatabaseViewer(navigationController: UINavigationController?) {
        if let vc = GenericTableViewController.getViewController(viewModel: DatabaseTableView()) {
            navigationController?.presentViewControllerModally(vc)
        }
    }
    
    internal func getDatabaseTablesWithCount() -> [DatabaseTablesWithCount] {
        var results = [DatabaseTablesWithCount]()
        for database in databases {
            results.append(DatabaseTablesWithCount(databaseName: database.databaseName, tables: database.tables.map { ($0.name, $0.count) }))
        }
        return results
    }
    
    internal func getDatabaseTables() -> [DatabaseTables] {
        var results = [DatabaseTables]()
        for database in databases {
            results.append(DatabaseTables(databaseName: database.databaseName, tables: database.tables.map { ($0.name) }))
        }
        return results
    }
    
    internal func getTable(from databaseTable: DatabaseTable) -> Table? {
        return getTableFrom(databaseName: databaseTable.databaseName, tableName: databaseTable.tableName)
    }

    internal func getTableFrom(databaseName: String?, tableName: String) -> Table? {
        guard let databaseName = databaseName else {
            return nil
        }

        if let databaseIndex = databases.index(where: { $0.databaseName == databaseName }),
            let tableIndex = databases[databaseIndex].tables.index(where: { $0.name == tableName }) {
                return databases[databaseIndex].tables[tableIndex]
        }
        return nil
    }

    private func updateEntitiesCount() {
        updateEntitiesCountForContexts()
    }

    private func ensureDatabaseNameIsUnique(name: String) -> String {
        guard databases.contains(where: { $0.databaseName == name }) else {
            return name
        }
        if let count = databases.flatMap({ $0.databaseName.range(of: name)?.lowerBound == $0.databaseName.startIndex ? Int($0.databaseName.replacingOccurrences(of: name, with: "")) : nil }).max() {
            return name + "\(count + 1)"
        }
        return name
    }

    // MARK: - NSManagedObjectContext
    private func prepareDatabase(for contexts: [NSManagedObjectContext]) {
        for context in contexts {
            var name = (context.persistentStoreCoordinator?.persistentStores.flatMap { $0.url?.absoluteString }.first)?.components(separatedBy: "/").last?.components(separatedBy: ".").first ?? "Context \(databases.count)"
            name = ensureDatabaseNameIsUnique(name: name)
            databases.append((name, prepareTables(for: context, databaseName: name)))
            contextDict[name] = context
        }
    }

    private func updateEntitiesCountForContexts() {
        for dict in contextDict {
            if let tables = databases.first(where: { $0.databaseName == dict.key })?.tables {
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
        if let entities = context.persistentStoreCoordinator?.managedObjectModel.entities.sorted(by: { String.is($0.name, smallerThan: $1.name) }) {
            for entity in entities {
                if let name = entity.name {
                    let properties = Array(entity.attributesByName.values).map { Property(name: $0.name , attributeType: $0.attributeType) }
                    results.append(Table(databaseName: databaseName, name: name, properties: properties, relationships: entity.relationshipsByName.flatMap({ $0.value.destinationEntity?.name })))
                }
            } // for
        } // entities
        return results
    }
}

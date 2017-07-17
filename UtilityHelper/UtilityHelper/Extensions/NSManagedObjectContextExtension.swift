//
//  NSManagedObjectContextExtension.swift
//  UtilityHelper
//
//  Created by Jacky Tay on 17/07/17.
//  Copyright © 2017 JackyTay. All rights reserved.
//

import CoreData
import Foundation

extension NSManagedObjectContext {
    func fetchAll(for entityName: String, keys: [String]) -> [[String?]] {
        var results = [[String?]]()
        performAndWait { [weak self] in
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
            if let fetchResults = (try? self?.fetch(fetchRequest)) as? [NSManagedObject] {
                for fetchResult in fetchResults {
                    var columns = [String?]()
                    for key in keys {
                        let value = (fetchResult.value(forKey: key) as AnyObject).description
                        columns.append(value == "<null>" ? nil : value)
                    }
                    results.append(columns)
                }
            } //
        } // performAndWait
        return results
    }
}

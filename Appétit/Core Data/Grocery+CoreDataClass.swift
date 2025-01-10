//
//  Grocery+CoreDataClass.swift
//  Appétit
//
//  Created by Jerry Jung on 12/14/24.
//
//

import Foundation
import CoreData

@objc(Grocery)
public class Grocery: NSManagedObject {

    convenience init(context: NSManagedObjectContext, name: String, quantity: String, category: String, isChecked: Bool = false) {
            let entity = NSEntityDescription.entity(forEntityName: "Grocery", in: context)!
            self.init(entity: entity, insertInto: context)
            
            // Set properties
            self.name = name
            self.quantity = quantity
            self.category = category
            self.isChecked = isChecked
        }
}

//
//  Grocery+CoreDataProperties.swift
//  Appétit
//
//  Created by Jerry Jung on 12/14/24.
//
//

import Foundation
import CoreData


extension Grocery {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Grocery> {
        return NSFetchRequest<Grocery>(entityName: "Grocery")
    }

    @NSManaged public var name: String?
    @NSManaged public var quantity: String?
    @NSManaged public var category: String?
    @NSManaged public var isChecked: Bool

}

extension Grocery : Identifiable {

}

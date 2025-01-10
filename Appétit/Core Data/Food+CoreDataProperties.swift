//
//  Food+CoreDataProperties.swift
//  Appétit
//
//  Created by Jerry Jung on 12/4/24.
//
//

import Foundation
import CoreData


extension Food {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Food> {
        return NSFetchRequest<Food>(entityName: "Food")
    }

    //@NSManaged public var food_id: Int64
    @NSManaged public var name: String?
    @NSManaged public var serving: String?
    @NSManaged public var calories: String?
    @NSManaged public var fat: String?
    @NSManaged public var fiber: String?
    @NSManaged public var carbs: String?
    @NSManaged public var protein: String?
    @NSManaged public var mealType: String?
    @NSManaged public var isInGroceryList: Bool

}

extension Food : Identifiable {

}

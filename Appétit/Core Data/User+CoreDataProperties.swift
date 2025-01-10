//
//  User+CoreDataProperties.swift
//  Appétit
//
//  Created by Jerry Jung on 12/4/24.
//
//

import Foundation
import CoreData


extension User {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<User> {
        return NSFetchRequest<User>(entityName: "User")
    }

    @NSManaged public var name: String?
    @NSManaged public var age: Int64
    @NSManaged public var weight: Double
    @NSManaged public var profileImageUrl: URL?
    @NSManaged public var nutritionGoal : String?

}

extension User : Identifiable {

}

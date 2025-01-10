//
//  User+CoreDataClass.swift
//  Appétit
//
//  Created by Jerry Jung on 12/4/24.
//
//

import Foundation
import CoreData

@objc(User)
public class User: NSManagedObject {
    
    convenience init(context: NSManagedObjectContext, name: String?, age: Int64, weight: Double, profileImageUrl: URL?, nutritionGoal: String?) {
          let entity = NSEntityDescription.entity(forEntityName: "User", in: context)!
          self.init(entity: entity, insertInto: context)
          self.name = name
          self.age = age
          self.weight = weight
          self.profileImageUrl = profileImageUrl
          self.nutritionGoal = nutritionGoal
      }

}

//
//  Recipe+CoreDataProperties.swift
//  Appétit
//
//  Created by Jerry Jung on 12/4/24.
//
//

import Foundation
import CoreData
import UIKit

extension Recipe {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Recipe> {
        return NSFetchRequest<Recipe>(entityName: "Recipe")
    }

    @NSManaged public var name: String?
    @NSManaged public var ingredients: String?
    @NSManaged public var protein: String?
    @NSManaged public var fat: String?
    @NSManaged public var fiber: String?
    @NSManaged public var carbs: String?
    @NSManaged public var calories: String?
    @NSManaged public var instructions: String?
    @NSManaged public var recipeImageUrl: URL?
    @NSManaged public var bookmarked: Bool
    

}

extension Recipe : Identifiable {

}

//
//  Recipe+CoreDataClass.swift
//  Appétit
//
//  Created by Jerry Jung on 12/4/24.
//
//

import Foundation
import CoreData

//@objc(Recipe)
//public class Recipe: NSManagedObject {
//
//    convenience init(context: NSManagedObjectContext, name: String?, ingredients: String?, protein: Double, fat: Double, fiber: Double, carbs: Double, calories: Double, instructions: String?, recipeImageUrl: URL? ) {
//          let entity = NSEntityDescription.entity(forEntityName: "Recipe", in: context)!
//          self.init(entity: entity, insertInto: context)
//          self.name = name
//          self.ingredients = ingredients
//          self.protein = protein
//          self.fat = fat
//          self.fiber = fiber
//          self.carbs = carbs
//          self.calories = calories
//          self.instructions = instructions
//          self.recipeImageUrl = recipeImageUrl
//      }
//    
//}


@objc(Recipe)
public final class Recipe: NSManagedObject, Decodable {
    
    enum CodingKeys: String, CodingKey {
        case name, ingredients, protein, fat, fiber, carbs, calories, instructions, recipeImageUrl
    }
    
    public convenience init(from decoder: Decoder) throws {
        let context = PersistenceController.shared.container.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Recipe", in: context)!
        self.init(entity: entity, insertInto: context)
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        name = try container.decode(String.self, forKey: .name)
        ingredients = try container.decode(String.self, forKey: .ingredients)
        protein = try container.decode(String.self, forKey: .protein)
        fat = try container.decode(String.self, forKey: .fat)
        fiber = try container.decode(String.self, forKey: .fiber)
        carbs = try container.decode(String.self, forKey: .carbs)
        calories = try container.decode(String.self, forKey: .calories)
        instructions = try container.decode(String.self, forKey: .instructions)
        
        if let urlString = try container.decodeIfPresent(String.self, forKey: .recipeImageUrl) {
            recipeImageUrl = URL(string: urlString)
        }
    }
}

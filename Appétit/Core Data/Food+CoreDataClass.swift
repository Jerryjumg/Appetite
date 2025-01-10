import CoreData



@objc(Food)
public class Food: NSManagedObject, Decodable {
    
    enum CodingKeys: String, CodingKey {
        case name, serving, calories, fat, fiber, carbs, protein, mealType, isInGroceryList
    }
    
    required public convenience init(from decoder: Decoder) throws {
        let context = PersistenceController.shared.container.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Food", in: context)!
        self.init(entity: entity, insertInto: context)
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
       // food_id = try container.decode(Int64.self, forKey: .food_id)
        name = try container.decode(String?.self, forKey: .name)
        serving = try container.decode(String?.self, forKey: .serving)
        calories = try container.decode(String?.self, forKey: .calories)
        fat = try container.decode(String?.self, forKey: .fat)
        fiber = try container.decode(String?.self, forKey: .fiber)
        carbs = try container.decode(String?.self, forKey: .carbs)
        protein = try container.decode(String?.self, forKey: .protein)
        mealType = try container.decodeIfPresent(String.self, forKey: .mealType)
        isInGroceryList = try container.decodeIfPresent(Bool.self, forKey: .isInGroceryList) ?? false
    }
    
    convenience init(context: NSManagedObjectContext, name: String?, serving: String?, calories: String?, fat: String?, fiber: String?, carbs: String?, protein: String?, mealType: String?, isInGroceryList: Bool) {
        let entity = NSEntityDescription.entity(forEntityName: "Food", in: context)!
        self.init(entity: entity, insertInto: context)
       // self.food_id = food_id
        self.name = name
        self.serving = serving
        self.calories = calories
        self.fat = fat
        self.fiber = fiber
        self.carbs = carbs
        self.protein = protein
        self.mealType = mealType
        self.isInGroceryList = isInGroceryList
    }
}

//
//  FoodModel.swift
//  Appétit
//
//  Created by Jerry Jung on 12/12/24.
//

import SwiftUI
import Combine

class FoodModel: ObservableObject {
    @Published var food: [Food] = []
    
    init() {
        fetchFood()
    }
    
    func fetchFood() {
        // Load the recipes from the JSON file
        self.food = JSONLoader.load("food", as: [Food].self)
    }
}

//import CoreData
//
//class FoodModel: ObservableObject {
//    @Published var food: [Food] = []
//    
//  
//
//    init() {
//       // self.context = context
//        fetchFood()
//    }
//    
//    func fetchFood() {
//        // Load the recipes from the JSON file
////        let loadedFood = JSONLoader.load("food", as: [Food].self)
////        self.food = loadedFood
//        
//        self.food = JSONLoader.load("food", as: [Food].self)
////
////        // Save to Core Data
////        saveToCoreData(loadedFood)
//    }
//    
////    private func saveToCoreData(_ foodList: [Food]) {
////        for foodItem in foodList {
////            // Check if the item already exists in Core Data
////            let fetchRequest: NSFetchRequest<Food> = Food.fetchRequest()
////            fetchRequest.predicate = NSPredicate(format: "id == %@", foodItem.name ?? "")
////            
////            if let existingItems = try? context.fetch(fetchRequest), !existingItems.isEmpty {
////                continue // Skip saving if it already exists
////            }
////            
////            // Create a new Core Data entity
////            let foodEntity = Food(context: context)
////            //foodEntity.id = foodItem.id
////            foodEntity.name = foodItem.name
////            foodEntity.calories = foodItem.calories
////            foodEntity.carbs = foodItem.carbs
////            foodEntity.fat = foodItem.fat
////            foodEntity.fiber = foodItem.fiber
////            foodEntity.protein = foodItem.protein
////            foodEntity.serving = foodItem.serving
////            
////        }
////        
////        // Save the context
////        do {
////            try context.save()
////        } catch {
////            print("Failed to save food to Core Data: \(error.localizedDescription)")
////        }
////    }
//}

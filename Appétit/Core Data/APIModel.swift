//
//  APIModel.swift
//  Appétit
//
//  Created by Jerry Jung on 12/11/24.
//

import CoreData
import UIKit

struct RecipeData: Codable {
    let name: String
    let ingredients: String
    let protein: String
    let fat: String
    let fiber: String
    let carbs: String
    let calories: String
    let instructions: String
    let recipeImageUrl: String
}

func loadJSONAndSaveToCoreData(context: NSManagedObjectContext) {
    guard let url = Bundle.main.url(forResource: "recipes", withExtension: "json") else {
        print("JSON file not found")
        return
    }
    
    do {
        let data = try Data(contentsOf: url)
        let recipes = try JSONDecoder().decode([RecipeData].self, from: data)
        
        for recipeData in recipes {
            let recipe = Recipe(context: context)
            recipe.name = recipeData.name
            recipe.ingredients = recipeData.ingredients
            recipe.protein = recipeData.protein
            recipe.fat = recipeData.fat
            recipe.fiber = recipeData.fiber
            recipe.carbs = recipeData.carbs
            recipe.calories = recipeData.calories
            recipe.instructions = recipeData.instructions
            recipe.recipeImageUrl = URL(string: recipeData.recipeImageUrl)
            if let url = URL(string: recipeData.recipeImageUrl) {
               recipe.recipeImageUrl = url
           } else {
               print("Invalid URL: \(recipeData.recipeImageUrl)")
           }
        }
        
        try context.save()
        print("Recipes saved to Core Data")
    } catch {
        print("Error parsing JSON or saving to Core Data: \(error)")
    }
}


struct FoodData: Codable {
    let name: String?
    let serving: String?
    let calories: String?
    let fat: String?
    let fiber: String?
    let carbs: String?
    let protein: String?
    let mealType: String?
    let isInGroceryList: Bool?
}

func loadFoodJSONAndSaveToCoreData(context: NSManagedObjectContext) {
    guard let url = Bundle.main.url(forResource: "foods", withExtension: "json") else {
        print("JSON file not found")
        return
    }
    
    do {
        let data = try Data(contentsOf: url)
        let foods = try JSONDecoder().decode([FoodData].self, from: data)
        
        for foodData in foods {
            let food = Food(context: context)
            food.name = foodData.name
            food.serving = foodData.serving
            food.calories = foodData.calories
            food.fat = foodData.fat
            food.fiber = foodData.fiber
            food.carbs = foodData.carbs
            food.protein = foodData.protein
            food.mealType = foodData.mealType
            food.isInGroceryList = foodData.isInGroceryList ?? false
        }
        
        try context.save()
        print("Foods saved to Core Data")
    } catch {
        print("Error parsing JSON or saving to Core Data: \(error)")
    }
}

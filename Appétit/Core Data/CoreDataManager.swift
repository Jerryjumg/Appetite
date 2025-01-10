//
//  Untitled.swift
//  Appétit
//
//  Created by Jerry Jung on 12/4/24.
//

import Foundation
import CoreData
import Combine
import UIKit




class MealTrackingDirectory: ObservableObject{
    @Published private var foods: [Food] = []
    @Published private var users: [User] = []
    @Published private var recipes: [Recipe] = []

    
    let persistentContainer: NSPersistentContainer
    private var context: NSManagedObjectContext{
        return persistentContainer.viewContext
    }
    
    
    static let shared = MealTrackingDirectory()
    
    private init() {
        persistentContainer = NSPersistentContainer(name: "Appe_tit")
        
        // Enable automatic lightweight migration
        let description = persistentContainer.persistentStoreDescriptions.first
        description?.shouldMigrateStoreAutomatically = true
        description?.shouldInferMappingModelAutomatically = true
        
        persistentContainer.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Failed to load Core Data stack: \(error)")
            }
        }
    }
    
    // Fetch func
    func fetchAllFood() -> [Food] {
        let fetchRequest: NSFetchRequest<Food> = Food.fetchRequest()
        do {
            let foods = try context.fetch(fetchRequest)
            return foods
        } catch {
            print("Failed to fetch food: \(error.localizedDescription)")
            return []
        }
    }
  

    func fetchAllRecipes() -> [Recipe] {
        let fetchRequest: NSFetchRequest<Recipe> = Recipe.fetchRequest()
        do {
            return try context.fetch(fetchRequest)
        } catch {
            print("Failed to fetch recipes: \(error.localizedDescription)")
            return []
        }
    }

    func fetchAllUsers() -> [User] {
        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
        do {
            return try context.fetch(fetchRequest)
        } catch {
            print("Failed to fetch users: \(error.localizedDescription)")
            return []
        }
    }


    
    // Add func
    func addFood(food: Food) {
        let fetchRequest: NSFetchRequest<Food> = Food.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name == %@", food.name ?? "")
        
        do{
            let existingFoods = try context.fetch(fetchRequest)
            if existingFoods.isEmpty{
                context.insert(food)
                try context.save()
                print("Food added successfully.")
                
            } else{
                print("Food with the name \(food.name ?? "") already exists.")
            }
        }catch{
            print("Fail to add food: \(error.localizedDescription)")
        }
    }
    

    func addRecipe(recipe: Recipe) {
        let fetchRequest: NSFetchRequest<Recipe> = Recipe.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name == %@", recipe.name ?? "")
        
        do {
            let existingRecipes = try context.fetch(fetchRequest)
            if existingRecipes.isEmpty {
                context.insert(recipe)
                try context.save()
                print("Recipe added successfully.")
            } else {
                print("Recipe with name \(recipe.name ?? "") already exists.")
            }
        } catch {
            print("Failed to add recipe: \(error.localizedDescription)")
        }
    }

    func addUser(user: User) {
        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name == %@", user.name ?? "")
        
        do {
            let existingUsers = try context.fetch(fetchRequest)
            if existingUsers.isEmpty {
                context.insert(user)
                try context.save()
                print("User added successfully.")
            } else {
                print("User with name \(user.name ?? "") already exists.")
            }
        } catch {
            print("Failed to add user: \(error.localizedDescription)")
        }
    }


    
    // Update func
    func updateFood(updatedFood: Food) {
        print("Attempting to update food: \(updatedFood.name ?? "Unnamed Food")")
        
        let fetchRequest: NSFetchRequest<Food> = Food.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name == %@", updatedFood.name ?? "")
        
        do {
            let fetchedFoods = try context.fetch(fetchRequest)
            
            if let existingFood = fetchedFoods.first {
                // Update the food's properties
                existingFood.serving = updatedFood.serving
                existingFood.calories = updatedFood.calories
                existingFood.protein = updatedFood.protein
                existingFood.fat = updatedFood.fat
                existingFood.fiber = updatedFood.fiber
                existingFood.carbs = updatedFood.carbs
                
                // Save the changes
                try context.save()
                print("Food updated successfully.")
            } else {
                print("Food not found for the given name.")
            }
        } catch {
            print("Failed to update food: \(error.localizedDescription)")
        }
    }


    func updateRecipe(updatedRecipe: Recipe) {
        let fetchRequest: NSFetchRequest<Recipe> = Recipe.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name == %@", updatedRecipe.name ?? "")
        
        do {
            let fetchedRecipes = try context.fetch(fetchRequest)
            if let existingRecipe = fetchedRecipes.first {
                existingRecipe.ingredients = updatedRecipe.ingredients
                existingRecipe.calories = updatedRecipe.calories
                existingRecipe.protein = updatedRecipe.protein
                existingRecipe.fat = updatedRecipe.fat
                existingRecipe.fiber = updatedRecipe.fiber
                existingRecipe.carbs = updatedRecipe.carbs
                try context.save()
                print("Recipe updated successfully.")
            } else {
                print("Recipe not found.")
            }
        } catch {
            print("Failed to update recipe: \(error.localizedDescription)")
        }
    }

    func updateUser(updatedUser: User) {
        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name == %@", updatedUser.name ?? "")
        
        do {
            let fetchedUsers = try context.fetch(fetchRequest)
            if let existingUser = fetchedUsers.first {
                existingUser.profileImageUrl = updatedUser.profileImageUrl
                existingUser.age = updatedUser.age
                existingUser.weight = updatedUser.weight 
                try context.save()
                print("User updated successfully.")
            } else {
                print("User not found.")
            }
        } catch {
            print("Failed to update user: \(error.localizedDescription)")
        }
    }

    // Delete func
    func deleteFood(foodName: String) {
        let fetchRequest: NSFetchRequest<Food> = Food.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name == %@", foodName)
        
        do {
            let fetchedFoods = try context.fetch(fetchRequest)
            if let foodToDelete = fetchedFoods.first {
                context.delete(foodToDelete) // Delete the object from Core Data
                try context.save()
                print("Food deleted successfully.")
            } else {
                print("No food found with the name \(foodName).")
            }
        } catch {
            print("Failed to delete food: \(error.localizedDescription)")
        }
    }

    func deleteRecipe(recipeName: String) {
        let fetchRequest: NSFetchRequest<Recipe> = Recipe.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name == %@", recipeName)
        
        do {
            let fetchedRecipes = try context.fetch(fetchRequest)
            if let recipeToDelete = fetchedRecipes.first {
                context.delete(recipeToDelete)
                try context.save()
                print("Recipe deleted successfully.")
            } else {
                print("No recipe found with name \(recipeName).")
            }
        } catch {
            print("Failed to delete recipe: \(error.localizedDescription)")
        }
    }

    func deleteUser(userName: String) {
        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name == %@", userName)
        
        do {
            let fetchedUsers = try context.fetch(fetchRequest)
            if let userToDelete = fetchedUsers.first {
                context.delete(userToDelete)
                try context.save()
                print("User deleted successfully.")
            } else {
                print("No user found with name \(userName).")
            }
        } catch {
            print("Failed to delete user: \(error.localizedDescription)")
        }
    }



}

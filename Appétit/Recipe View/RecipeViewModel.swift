//
//  RecipeViewModel.swift
//  Appétit
//
//  Created by Jerry Jung on 12/11/24.
//

import SwiftUI
import Combine

class RecipeViewModel: ObservableObject {
    @Published var recipes: [Recipe] = []
    
    init() {
        fetchRecipes()
    }
    
    func fetchRecipes() {
        // Load the recipes from the JSON file
        self.recipes = JSONLoader.load("recipes", as: [Recipe].self)
    }
}


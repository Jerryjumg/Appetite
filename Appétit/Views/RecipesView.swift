//
//  RecipesView.swift
//  Appétit
//
//  Created by Jerry Jung on 12/3/24.
//

import SwiftUI
import CoreData

struct RecipesView: View {
    @ObservedObject var viewModel = RecipeViewModel()
    @State private var searchText = ""
    @State private var showBookmarkView = false
    @State private var bookmarkedRecipes: [Recipe] = []

    
    var body: some View {
            NavigationStack {
                VStack {
                    // Search bar for filtering recipes
                    SearchBar(text: $searchText)
                        .padding(.top)

                    // Recipe list
                    ScrollView {
                        VStack {
                            HStack {
                                // Recipe count label
                                Text("\(filteredRecipes.count) \(filteredRecipes.count > 1 ? "recipes" : "recipe")")
                                    .font(.headline)
                                    .fontWeight(.medium)
                                    .opacity(0.7)
                                Spacer()
                            }
                            .padding(.horizontal)

                            // Grid of recipe cards
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 168), spacing: 15)], spacing: 15) {
                                ForEach(filteredRecipes) { recipe in
                                    NavigationLink(value: recipe) {
                                        RecipeCard(recipe: recipe, bookmarkedRecipes: $bookmarkedRecipes)
                                            .padding(.top)
                                            .padding(.horizontal)
                                    }
                                }
                            }
                            .padding()
                        }
                    }
                }
                .navigationTitle("Recipes")
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarItems(trailing: Button(action: {
                    showBookmarkView = true
                }) {
                    Image("heart")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 24, height: 24) 
                    
                })
                .navigationDestination(isPresented: $showBookmarkView) {
                    BookmarkView()
                    //BookmarkView(bookmarkedRecipes: $bookmarkedRecipes)
                }
                .navigationDestination(for: Recipe.self) { recipe in
                    RecipeDetailView(recipe: recipe)
                }
            }
        }
    
    
    var filteredRecipes: [Recipe] {
        if searchText.isEmpty {
            return Array(viewModel.recipes)
        } else {
            return viewModel.recipes.filter { recipe in
                recipe.name?.localizedCaseInsensitiveContains(searchText) ?? false
            }
        }
    }
}

struct SearchBar: View {
    @Binding var text: String

    var body: some View {
        HStack {
            TextField("Search for recipes", text: $text)
                .padding(8)
                .background(Color(.systemGray6))
                .cornerRadius(8)
        }
        .padding()
    }
}

struct RecipeCard: View {
    let recipe: Recipe
    @Binding var bookmarkedRecipes: [Recipe]
    @Environment(\.managedObjectContext) private var viewContext

    var body: some View {
        VStack(alignment: .leading) {
            ZStack(alignment: .topTrailing) {
                if let url = recipe.recipeImageUrl {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .frame(width: 160, height: 217)
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 160, height: 217)
                                .clipped()
                        case .failure:
                            Image(systemName: "photo")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 160, height: 217)
                                .foregroundColor(.gray)
                        @unknown default:
                            EmptyView()
                        }
                    }
                } else {
                    // Default image when URL is missing
                    Image(systemName: "photo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 160, height: 217)
                        .foregroundColor(.gray)
                }

                // Bookmark Button with smaller icon
                Button(action: {
                    if !bookmarkedRecipes.contains(recipe) {
                        bookmarkedRecipes.append(recipe)
                        saveRecipeToCoreData(recipe)
                    }
                }) {
                    Image(systemName: "plus")
                        .padding(8)
                        .background(Color.white.opacity(0.7))
                        .clipShape(Circle())
                        .font(.system(size: 16)) // Smaller icon size
                }
                .padding(8)
            }

            // Recipe Name - centered with custom color
            Text(recipe.name ?? "Unknown Recipe")
                .font(.headline)
                .foregroundColor(Color(hex: "#91C788")) // Custom green color
                .multilineTextAlignment(.center)
                .padding(.top, 8)
                .frame(maxWidth: .infinity)
        }
        .padding(.horizontal)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.3), radius: 6, x: 0, y: 3)
        )
    }
    private func saveRecipeToCoreData(_ recipe: Recipe) {
        recipe.bookmarked = true
        do {
            try viewContext.save()
        } catch {
            print("Failed to save recipe: \(error.localizedDescription)")
        }
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.replacingOccurrences(of: "#", with: "")
        var int = UInt64()
        Scanner(string: hex).scanHexInt64(&int)
        self.init(
            .sRGB,
            red: Double((int >> 16) & 0xFF) / 255,
            green: Double((int >> 8) & 0xFF) / 255,
            blue: Double(int & 0xFF) / 255,
            opacity: 1
        )
    }
}


struct RecipeDetailView: View {
    let recipe: Recipe
    
    // Function to split instructions into steps and remove blanks
    private func splitInstructions(_ instructions: String?) -> [String] {
        guard let instructions = instructions else { return [] }
        let steps = instructions.split(separator: ".", omittingEmptySubsequences: true)
        return steps.compactMap { step in
            let trimmedStep = step.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmedStep.isEmpty else { return nil }
            // Remove leading numbers like "1", "2", etc., but only if followed by whitespace
            let cleanedStep = trimmedStep.replacingOccurrences(of: #"^\d+\s*"#, with: "", options: .regularExpression)
            return cleanedStep.isEmpty ? nil : cleanedStep
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Recipe Image
                if let imageUrl = recipe.recipeImageUrl {
                    AsyncImage(url: imageUrl) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .frame(height: 300)
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(maxWidth: .infinity, maxHeight: 300)
                                .clipped()
                        case .failure:
                            Image(systemName: "photo")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 300)
                                .foregroundColor(.gray)
                        @unknown default:
                            EmptyView()
                        }
                    }
                } else {
                    Image(systemName: "photo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 300)
                        .foregroundColor(.gray)
                }

                // Recipe Name
                Text(recipe.name ?? "")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .lineLimit(1)
                    .truncationMode(.tail)

                // Ingredients Section
                Text("Ingredients")
                    .font(.title2)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text(recipe.ingredients ?? "")
                    .frame(maxWidth: .infinity, alignment: .leading)

                // Instructions Section
                Text("Instructions")
                    .font(.title2)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)

                VStack(alignment: .leading, spacing: 12) {
                    ForEach(splitInstructions(recipe.instructions).enumeratedArray(), id: \.offset) { index, step in
                        HStack(alignment: .top) {
                            Text("Step \(index + 1):")
                                .font(.headline)
                                .foregroundColor(Color(hex: "#91C788"))
                            Text(step)
                                .font(.body)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(.bottom, 4)
                    }
                }
                
                Spacer()
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}


extension Array {
    func enumeratedArray() -> [(offset: Int, element: Element)] {
        self.enumerated().map { ($0, $1) }
    }
}


struct BookmarkView: View {
    @FetchRequest(
        entity: Recipe.entity(),
        sortDescriptors: [],
        predicate: NSPredicate(format: "bookmarked == true")
    ) private var bookmarkedRecipes: FetchedResults<Recipe>
   // @Binding var bookmarkedRecipes: [Recipe]
    @State private var selectedRecipes: Set<Recipe> = []
    @State private var showManageOptions = false
    @State private var isSelectionMode = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var showAddIngredientsView = false
    @State private var ingredients: [Ingredient] = []
    
    @Environment(\.managedObjectContext) private var viewContext

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))], spacing: 16) {
                    ForEach(bookmarkedRecipes, id: \.self) { recipe in
                        BookmarkCard(recipe: recipe, selectedRecipes: $selectedRecipes, isSelectionMode: $isSelectionMode)
                    }
                }
                .padding()
            }
            .navigationTitle("Bookmarked Recipes")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: HStack {
                Button(action: {
                    isSelectionMode.toggle()
                    if !isSelectionMode {
                        selectedRecipes.removeAll()
                    }
                }) {
                    Text(isSelectionMode ? "Done" : "Select")
                }
                Button(action: {
                    if selectedRecipes.isEmpty {
                        alertMessage = "Please choose a recipe to manage."
                        showAlert = true
                    } else {
                        showManageOptions = true
                    }
                }) {
                    Image(systemName: "ellipsis")
                }
            })
            .navigationDestination(for: Recipe.self) { recipe in
                RecipeDetailView(recipe: recipe)
            }
            .actionSheet(isPresented: $showManageOptions) {
                ActionSheet(
                    title: Text("Manage Recipes"),
                    message: Text("Choose an option"),
                    buttons: [
                        .default(Text("Add Ingredients to Groceries")) {
                            extractIngredients()
                            showAddIngredientsView = true
                            
//                            alertMessage = "Ingredients added to groceries."
//                            showAlert = true
                        },
                        .destructive(Text("Remove from Bookmarks")) {
                             removeSelectedRecipesFromBookmarks()
                        },
                        .cancel()
                    ]
                )
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Message"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
            .sheet(isPresented: $showAddIngredientsView) {
                            AddIngredientsView(ingredients: ingredients)
                        }
        }
    }
    
    private func extractIngredients() {
           ingredients = selectedRecipes.flatMap { recipe in
               recipe.ingredients?.split(separator: ",").map { ingredient in
                   Ingredient(name: ingredient.trimmingCharacters(in: .whitespacesAndNewlines), quantity: "", category: "")
               } ?? []
           }
       }
    
    private func removeSelectedRecipesFromBookmarks() {
        for recipe in selectedRecipes {
            recipe.bookmarked = false
        }
        do {
            try viewContext.save()
            selectedRecipes.removeAll()
            alertMessage = "Recipes removed from Bookmarks."
            showAlert = true
        } catch {
            alertMessage = "Failed to remove recipes from Bookmarks: \(error.localizedDescription)"
            showAlert = true
        }
    }
}

struct BookmarkCard: View {
    let recipe: Recipe
    @Binding var selectedRecipes: Set<Recipe>
    @Binding var isSelectionMode: Bool

    var body: some View {
        VStack(alignment: .leading) {
            ZStack(alignment: .topTrailing) {
                if let url = recipe.recipeImageUrl {
                    if isSelectionMode {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                                    .frame(width: 150, height: 150)
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 150, height: 150)
                                    .clipped()
                            case .failure:
                                Image(systemName: "photo")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 150, height: 150)
                                    .foregroundColor(.gray)
                            @unknown default:
                                EmptyView()
                            }
                        }
                    } else {
                        NavigationLink(destination: RecipeDetailView(recipe: recipe)) {
                            AsyncImage(url: url) { phase in
                                switch phase {
                                case .empty:
                                    ProgressView()
                                        .frame(width: 150, height: 150)
                                case .success(let image):
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 150, height: 150)
                                        .clipped()
                                case .failure:
                                    Image(systemName: "photo")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 150, height: 150)
                                        .foregroundColor(.gray)
                                @unknown default:
                                    EmptyView()
                                }
                            }
                        }
                    }
                } else {
                    if isSelectionMode {
                        Image(systemName: "photo")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 150, height: 150)
                            .foregroundColor(.gray)
                    } else {
                        NavigationLink(destination: RecipeDetailView(recipe: recipe)) {
                            Image(systemName: "photo")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 150, height: 150)
                                .foregroundColor(.gray)
                        }
                    }
                }
                if selectedRecipes.contains(recipe) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.blue)
                        .padding()
                }
            }
            Text(recipe.name ?? "")
                .font(.headline)
                .padding(.top, 8)
        }
        .padding(.horizontal)
        .background(Color.white)
        .cornerRadius(12)
        .foregroundColor(Color(hex: "#91C788"))
        .shadow(color: Color.gray.opacity(0.3), radius: 6, x: 0, y: 3)
        .onTapGesture {
            if isSelectionMode {
                if selectedRecipes.contains(recipe) {
                    selectedRecipes.remove(recipe)
                } else {
                    selectedRecipes.insert(recipe)
                }
            }
        }
    }
}

//struct BookmarkCard: View {
//    let recipe: Recipe
//    @Binding var selectedRecipes: Set<Recipe>
//    @Binding var isSelectionMode: Bool
//
//    var body: some View {
//        VStack(alignment: .leading) {
//            ZStack(alignment: .topTrailing) {
//                if let url = recipe.recipeImageUrl {
//                    AsyncImage(url: url) { phase in
//                        switch phase {
//                        case .empty:
//                            ProgressView()
//                                .frame(width: 150, height: 150)
//                        case .success(let image):
//                            image
//                                .resizable()
//                                .aspectRatio(contentMode: .fill)
//                                .frame(width: 150, height: 150)
//                                .clipped()
//                        case .failure:
//                            Image(systemName: "photo")
//                                .resizable()
//                                .aspectRatio(contentMode: .fit)
//                                .frame(width: 150, height: 150)
//                                .foregroundColor(.gray)
//                        @unknown default:
//                            EmptyView()
//                        }
//                    }
//                } else {
//                    Image(systemName: "photo")
//                        .resizable()
//                        .aspectRatio(contentMode: .fit)
//                        .frame(width: 150, height: 150)
//                        .foregroundColor(.gray)
//                }
//                if selectedRecipes.contains(recipe) {
//                    Image(systemName: "checkmark.circle.fill")
//                        .foregroundColor(.blue)
//                        .padding()
//                        
//                }
//            }
//            Text(recipe.name ?? "")
//                .font(.headline)
//                .padding(.top, 8)
//            
//        }
//        .padding(.horizontal)
//        .background(Color.white)
//        .cornerRadius(12)
//        .foregroundColor(Color(hex: "#91C788"))
//        .shadow(color: Color.gray.opacity(0.3), radius: 6, x: 0, y: 3)
//        .onTapGesture {
//            if isSelectionMode {
//                if selectedRecipes.contains(recipe) {
//                    selectedRecipes.remove(recipe)
//                } else {
//                    selectedRecipes.insert(recipe)
//                }
//            }
//        }
//        .background(
//            NavigationLink(value: recipe) {
//                EmptyView()
//            }
//            .hidden()
//        )
//    }
//}

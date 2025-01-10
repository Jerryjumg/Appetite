//
//  SearchFoodView.swift
//  Appétit
//
//  Created by Jerry Jung on 12/12/24.
//
import SwiftUI
import CoreData
import Foundation

struct SearchFoodView: View {
    @ObservedObject var viewModel = FoodModel()
    let mealType: String
    @State private var searchText = ""
    @State private var searchResults: [Food] = []
    
    var body: some View {
        VStack {
            TextField("Search for food", text: $searchText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
                .background(Color.white)
                .cornerRadius(10)
                .shadow(radius: 5)
                .padding(.top)
            
            List(filteredFood, id: \.self) { food in
                NavigationLink(destination: FoodDetailView(food: food, mealType: mealType)) {
                    HStack {
                        Text(food.name ?? "")
                            .font(.headline)
                            .foregroundColor(.primary)
                        Spacer()
                        Button(action: {
                            addFoodToMeal(food)
                        }) {
                            Image(systemName: "plus.circle")
                                .foregroundColor(Color(hex: "#91C788"))
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(radius: 5)
                }
                .padding(.vertical, 5)
            }
            .listStyle(PlainListStyle())
            .padding(.top)
        }
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .padding()
    }
    
    var filteredFood: [Food] {
        if searchText.isEmpty {
            return Array(viewModel.food)
        } else {
            return viewModel.food.filter { recipe in
                recipe.name?.localizedCaseInsensitiveContains(searchText) ?? false
            }
        }
    }
    
    func addFoodToMeal(_ food: Food) {
        let context = PersistenceController.shared.container.viewContext
        let newFood = Food(context: context)
        newFood.name = food.name
        newFood.calories = food.calories
        newFood.fat = food.fat
        newFood.fiber = food.fiber
        newFood.carbs = food.carbs
        newFood.protein = food.protein
        newFood.serving = food.serving
        newFood.mealType = mealType
        
        do {
            try context.save()
            print("Food added to \(mealType): \(food.name ?? "")")
        } catch {
            print("Failed to save food: \(error)")
        }
    }
}

struct FoodDetailView: View {
    let food: Food
    let mealType: String
    @Environment(\.managedObjectContext) private var viewContext
    @State private var selectedServing: Double = 1.0
    @State private var showingAlert = false
    @State private var showPicker = false
    @State private var alertMessage = ""
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Food Name
                Text(food.name ?? "Food Details")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top)
                
                // Serving Size Picker
                VStack(alignment: .leading) {
                    Text("Add your serving size")
                        .font(.headline)
                        .foregroundColor(Color(hex: "#91C788"))
                    TextField("Select Serving Size", value: $selectedServing, formatter: NumberFormatter())
                        .onTapGesture {
                            showPicker = true
                        }
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.bottom)
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                }
                .padding()
                
                // Nutrition Information
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(["Calories", "Fat", "Fiber", "Carbs", "Protein", "Serving"], id: \.self) { nutrient in
                        HStack {
                            Text(nutrient)
                                .font(.headline)
                            Spacer()
                            Text("\(calculatedValue(for: value(for: nutrient)))")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        Divider()
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .shadow(radius: 5)
                
                // Add and Delete Buttons
                HStack {
                    Button(action: {
                        addFoodToMeal()
                    }) {
                        Text("Add to the Meal")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(hex: "#91C788")) // Green color for the button
                            .foregroundColor(.white)
                            .cornerRadius(8)
                            .shadow(radius: 5)
                    }
                }
                .padding(.top)
            }
            .padding()
        }
        .alert(isPresented: $showingAlert) {
            Alert(title: Text("Message"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
        .sheet(isPresented: $showPicker) {
            VStack {
                Picker("Select Serving Size", selection: $selectedServing) {
                    ForEach(Array(stride(from: 0.0, to: 100.5, by: 0.5)), id: \.self) { value in
                        Text("\(value, specifier: "%.1f")").tag(value)
                    }
                }
                .pickerStyle(WheelPickerStyle())
                Button("Done") {
                    showPicker = false
                }
                .padding()
            }
        }
    }
    
    private func calculatedValue(for value: String?) -> String {
        guard let value = value else {
            return "0"
        }
        let numericValue = extractNumericValue(from: value) ?? 0
        let unitPart = value.components(separatedBy: CharacterSet.decimalDigits).joined().trimmingCharacters(in: .whitespaces)
        let calculatedValue = numericValue * selectedServing
        return String(format: "%.1f", calculatedValue) + unitPart
    }
    
    private func addFoodToMeal() {
        let newFood = Food(context: viewContext)
        newFood.name = food.name
        newFood.calories = food.calories
        newFood.fat = food.fat
        newFood.fiber = food.fiber
        newFood.carbs = food.carbs
        newFood.protein = food.protein
        newFood.serving = String(selectedServing)
        newFood.mealType = mealType

        do {
            try viewContext.save()
            alertMessage = "Food added successfully!"
            showingAlert = true
        } catch {
            alertMessage = "Failed to add food. Please try again."
            showingAlert = true
        }
    }
    
    private func deleteFoodFromMeal() {
        let fetchRequest: NSFetchRequest<Food> = Food.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name == %@ AND mealType == %@", food.name ?? "", mealType)

        do {
            let foods = try viewContext.fetch(fetchRequest)
            for food in foods {
                viewContext.delete(food)
            }
            try viewContext.save()
            alertMessage = "Food deleted successfully!"
            showingAlert = true
        } catch {
            alertMessage = "Failed to delete food. Please try again."
            showingAlert = true
        }
    }
    
    private func value(for nutrient: String) -> String {
        switch nutrient {
        case "Calories": return food.calories ?? "0"
        case "Fat": return food.fat ?? "0"
        case "Fiber": return food.fiber ?? "0"
        case "Carbs": return food.carbs ?? "0"
        case "Protein": return food.protein ?? "0"
        case "Serving": return food.serving ?? "0"
        default: return "0"
        }
    }
}


//import SwiftUI
//import CoreData
//import Foundation
//
//
//struct SearchFoodView: View {
//    @ObservedObject var viewModel = FoodModel()
//    let mealType: String
//    @State private var searchText = ""
//    @State private var searchResults: [Food] = []
//    
//    var body: some View {
//        VStack {
//            TextField("Search for food", text: $searchText)
//                .textFieldStyle(RoundedBorderTextFieldStyle())
//                .padding()
//            
//            List(filteredFood, id: \.self) { food in
//                NavigationLink(destination: FoodDetailView(food: food, mealType: mealType)) {
//                    HStack {
//                        Text(food.name ?? "")
//                        Spacer()
//                        Button(action: {
//                              addFoodToMeal(food)
//                        }) {
//                            Image(systemName: "plus.circle")
//                                .foregroundColor(.blue)
//                        }
//                    }
//                }
//            }
//        }
//    }
//    
//    var filteredFood: [Food] {
//        if searchText.isEmpty {
//            return Array(viewModel.food)
//        } else {
//            return viewModel.food.filter { recipe in
//                recipe.name?.localizedCaseInsensitiveContains(searchText) ?? false
//            }
//        }
//    }
//    
//    func addFoodToMeal(_ food: Food) {
//        let context = PersistenceController.shared.container.viewContext
//        let newFood = Food(context: context)
//        newFood.name = food.name
//        newFood.calories = food.calories
//        newFood.fat = food.fat
//        newFood.fiber = food.fiber
//        newFood.carbs = food.carbs
//        newFood.protein = food.protein
//        newFood.serving = food.serving
//        newFood.mealType = mealType
//        
//        do {
//            try context.save()
//            print("Food added to \(mealType): \(food.name ?? "")")
//        } catch {
//            print("Failed to save food: \(error)")
//        }
//    }
//    
//    private func deleteFoodFromMeal(_ food: Food) {
//        let context = PersistenceController.shared.container.viewContext
//        context.delete(food)
//        do {
//            try context.save()
//            print("Food deleted from \(mealType): \(food.name ?? "")")
//        } catch {
//            print("Failed to delete food: \(error)")
//        }
//    }
//}
//
//struct FoodDetailView: View {
//    let food: Food
//    let mealType: String
//    @Environment(\.managedObjectContext) private var viewContext
//    @State private var selectedServing: Double = 1.0
//    @State private var showingAlert = false
//    @State private var showPicker = false
//    @State private var alertMessage = ""
//    
//    var body: some View {
//        ScrollView {
//            VStack(alignment: .leading, spacing: 20) {
//                // Food Name
//                Text(food.name ?? "Food Details")
//                    .font(.largeTitle)
//                    .fontWeight(.bold)
//                    .padding(.top)
//                
//                // Serving Size Picker
//                VStack(alignment: .leading) {
//                    Text("Add your serving size")
//                        .font(.headline)
//                    TextField("Select Serving Size", value: $selectedServing, formatter: NumberFormatter())
//                        .onTapGesture {
//                            showPicker = true
//                        }
//                        .textFieldStyle(RoundedBorderTextFieldStyle())
//                        .padding(.bottom)
//                }
//                .padding()
//                
//                // Nutrition Information
//                VStack(alignment: .leading, spacing: 10) {
//                    HStack {
//                       Text("Calories")
//                           .font(.headline)
//                       Spacer()
//                        Text("\(calculatedValue(for: food.calories)) cal")
//                           .font(.subheadline)
//                           .foregroundColor(.secondary)
//                   }
//                   Divider()
//                   HStack {
//                       Text("Fat")
//                           .font(.headline)
//                       Spacer()
//                       Text("\(calculatedValue(for: food.fat))")
//                           .font(.subheadline)
//                           .foregroundColor(.secondary)
//                   }
//                   Divider()
//                   HStack {
//                       Text("Fiber")
//                           .font(.headline)
//                       Spacer()
//                       Text("\(calculatedValue(for: food.fiber))")
//                           .font(.subheadline)
//                           .foregroundColor(.secondary)
//                   }
//                   Divider()
//                   HStack {
//                       Text("Carbs")
//                           .font(.headline)
//                       Spacer()
//                       Text("\(calculatedValue(for: food.carbs))")
//                           .font(.subheadline)
//                           .foregroundColor(.secondary)
//                   }
//                   Divider()
//                   HStack {
//                       Text("Protein")
//                           .font(.headline)
//                       Spacer()
//                       Text("\(calculatedValue(for: food.protein))")
//                           .font(.subheadline)
//                           .foregroundColor(.secondary)
//                   }
//                   Divider()
//                    HStack {
//                        Text("Serving")
//                            .font(.headline)
//                        Spacer()
//                        Text("\(calculatedValue(for: food.serving))")
//                            .font(.subheadline)
//                            .foregroundColor(.secondary)
//                    }
//                }
//                .padding()
//                .background(Color(.systemGray6))
//                .cornerRadius(10)
//                .shadow(radius: 5)
//                
//                // Add and Delete Buttons
//                HStack {
//                    Button(action: {
//                        addFoodToMeal()
//                    }) {
//                        Text("Add to the Meal")
//                            .frame(maxWidth: .infinity)
//                            .padding()
//                            .background(Color.blue)
//                            .foregroundColor(.white)
//                            .cornerRadius(8)
//                    }
////                    Button(action: {
////                        deleteFoodFromMeal()
////                    }) {
////                        Text("Delete from the Meal")
////                            .frame(maxWidth: .infinity)
////                            .padding()
////                            .background(Color.red)
////                            .foregroundColor(.white)
////                            .cornerRadius(8)
////                    }
//                }
//                .padding(.top)
//            }
//            .padding()
//        }
//        //.navigationTitle(food.name ?? "Food Details")
//        .alert(isPresented: $showingAlert) {
//            Alert(title: Text("Message"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
//        }
//        .sheet(isPresented: $showPicker) {
//        VStack {
//                 Picker("Select Serving Size", selection: $selectedServing) {
//                     ForEach(Array(stride(from: 0.0, to: 100.5, by: 0.5)), id: \.self) { value in
//                         Text("\(value, specifier: "%.1f")").tag(value)
//                     }
//                 }
//                 .pickerStyle(WheelPickerStyle())
//                 Button("Done") {
//                     showPicker = false
//                 }
//                 .padding()
//             }
//        }
//    }
//    
//    private func calculatedValue(for value: String?) -> String {
//        guard let value = value else {
//            return "0"
//        }
//        let numericValue = extractNumericValue(from: value) ?? 0
//        let unitPart = value.components(separatedBy: CharacterSet.decimalDigits).joined().trimmingCharacters(in: .whitespaces)
//        let calculatedValue = numericValue * selectedServing
//        return String(format: "%.1f", calculatedValue) + unitPart
//    }
//    
//    private func addFoodToMeal() {
//        let newFood = Food(context: viewContext)
//        newFood.name = food.name
//        newFood.calories = food.calories
//        newFood.fat = food.fat
//        newFood.fiber = food.fiber
//        newFood.carbs = food.carbs
//        newFood.protein = food.protein
//        newFood.serving = String(selectedServing)
//        newFood.mealType = mealType
//
//        do {
//            try viewContext.save()
//            alertMessage = "Food added successfully!"
//            showingAlert = true
//        } catch {
//            alertMessage = "Failed to add food. Please try again."
//            showingAlert = true
//        }
//    }
//    
//    private func deleteFoodFromMeal() {
//        let fetchRequest: NSFetchRequest<Food> = Food.fetchRequest()
//        fetchRequest.predicate = NSPredicate(format: "name == %@ AND mealType == %@", food.name ?? "", mealType)
//
//        do {
//            let foods = try viewContext.fetch(fetchRequest)
//            for food in foods {
//                viewContext.delete(food)
//            }
//            try viewContext.save()
//            alertMessage = "Food deleted successfully!"
//            showingAlert = true
//        } catch {
//            alertMessage = "Failed to delete food. Please try again."
//            showingAlert = true
//        }
//    }
//}
//
//
func extractNumericValue(from string: String) -> Double? {
    let numberString = string.components(separatedBy: CharacterSet.decimalDigits.inverted).joined(separator: ".")
    return Double(numberString)
}

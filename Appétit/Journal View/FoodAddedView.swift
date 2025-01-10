import SwiftUI
import CoreData
import Foundation

struct FoodAddedView: View {
    let mealType: String
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest var foods: FetchedResults<Food>
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    // Define the color for consistency
    private let greenColor = Color(hex: "#91C788")

    init(mealType: String) {
        self.mealType = mealType
        _foods = FetchRequest<Food>(
            entity: Food.entity(),
            sortDescriptors: [],
            predicate: NSPredicate(format: "mealType == %@", mealType)
        )
    }

    var body: some View {
        NavigationView {
            List {
                ForEach(foods, id: \.self) { food in
                    NavigationLink(destination: FoodDetailsView(food: food)) {
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Text(food.name ?? "Unknown Food")
                                    .font(.headline)
                                    .foregroundColor(Color(hex: "#91C788"))  // Use the green color
                                Spacer()
                                Button(action: {
                                    deleteFood(food)
                                }) {
                                    Image(systemName: "trash")
                                        .foregroundColor(Color(hex: "#91C788"))  // Use the green color for trash icon
                                }
                                .buttonStyle(BorderlessButtonStyle())
                            }

                            VStack (spacing: 10){
                                HStack {
                                    Text("Serving:")
                                    TextField("Serving", text: Binding(
                                        get: { food.serving ?? "1" },
                                        set: { newValue in
                                            food.serving = newValue
                                        }
                                    ))
                                    .keyboardType(.decimalPad)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .frame(width: 60) // Adjust width for better layout
                                    Spacer()
                                    Text("Calories: \(calculatedValue(for: food.calories, withServing: food.serving)) cal")
                                }
                                HStack {
                                    Text("Protein: \(calculatedValue(for: food.protein, withServing: food.serving))")
                                    Spacer()
                                    Text("Carbs: \(calculatedValue(for: food.carbs, withServing: food.serving))")
                                }
                            }
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 10)
                        .background(Color.white.opacity(0.05)) // Light background to separate items
                        .cornerRadius(10)
                 }
                }
            }
            .navigationTitle("Foods for \(mealType)")
            .alert(isPresented: $showingAlert) {
                Alert(title: Text("Message"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
        }
    }

    private func calculatedValue(for value: String?, withServing serving: String?) -> String {
        guard let value = value, let serving = serving, let servingDouble = Double(serving) else {
            return "0"
        }
        let numericValue = extractNumericValue(from: value) ?? 0
        let unitPart = value.components(separatedBy: CharacterSet.decimalDigits).joined().trimmingCharacters(in: .whitespaces)
        let calculatedValue = numericValue * servingDouble
        return String(format: "%.1f", calculatedValue) + unitPart
    }

    private func saveContext() {
        do {
            try viewContext.save()
        } catch {
            alertMessage = "Failed to save changes. Please try again."
            showingAlert = true
        }
    }

    private func deleteFood(_ food: Food) {
        viewContext.delete(food)
        saveContext()
        alertMessage = "Food deleted successfully!"
        showingAlert = true
    }
}

// Color extension for hex
struct FoodDetailsView: View {
    let food: Food

    var body: some View {
        VStack(alignment: .leading, spacing: 25) {
            // Serving Section
            HStack {
                Text("Serving:")
                    .font(.headline)
                    .foregroundColor(Color(hex: "#91C788"))  // Green color for labels
                Spacer()
                Text(food.serving ?? "1")
                    .font(.body)
                    .foregroundColor(.gray)  // White text for the value
            }
            .padding(.horizontal)

            Divider()
                .background(Color.gray.opacity(0.2)) // Light gray divider

            // Calories Section
            HStack {
                Text("Calories:")
                    .font(.headline)
                    .foregroundColor(Color(hex: "#91C788"))
                Spacer()
                Text("\(calculatedValue(for: food.calories, withServing: food.serving)) cal")
                    .font(.body)
                    .foregroundColor(.gray)
            }
            .padding(.horizontal)

            Divider()
                .background(Color.gray.opacity(0.2))

            // Protein Section
            HStack {
                Text("Protein:")
                    .font(.headline)
                    .foregroundColor(Color(hex: "#91C788"))
                Spacer()
                Text(calculatedValue(for: food.protein, withServing: food.serving))
                    .font(.body)
                    .foregroundColor(.gray)
            }
            .padding(.horizontal)

            Divider()
                .background(Color.gray.opacity(0.2))

            // Carbs Section
            HStack {
                Text("Carbs:")
                    .font(.headline)
                    .foregroundColor(Color(hex: "#91C788"))
                Spacer()
                Text(calculatedValue(for: food.carbs, withServing: food.serving))
                    .font(.body)
                    .foregroundColor(.gray)
            }
            .padding(.horizontal)

            Spacer()
        }
                .navigationTitle(food.name ?? "Food Details")
                .navigationBarTitleDisplayMode(.inline)
        
//        .padding()
//        .background(Color.black.opacity(0.5)) // Lighter dark background for the whole view
//        .cornerRadius(15)
//        .padding([.leading, .trailing], 20)
////        .frame(maxHeight: 200) // Limiting the height
//        .navigationTitle(food.name ?? "Food Details")
//        .navigationBarTitleDisplayMode(.inline)
    }

    private func calculatedValue(for value: String?, withServing serving: String?) -> String {
        guard let value = value else {
            return "0"
        }
        let numericValue = extractNumericValue(from: value) ?? 0
        let unitPart = value.components(separatedBy: CharacterSet.decimalDigits).joined().trimmingCharacters(in: .whitespaces)
        let servingValue = extractNumericValue(from: serving ?? "1") ?? 1
        let calculatedValue = numericValue * servingValue
        return String(format: "%.1f", calculatedValue) + unitPart
    }
}

//struct FoodDetailsView: View {
//    let food: Food
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 15) {
//            HStack {
//                Text("Serving:")
//                Spacer()
//                Text(food.serving ?? "1")
//            }
//
//            HStack {
//                Text("Calories:")
//                Spacer()
//                Text("\(calculatedValue(for: food.calories, withServing: food.serving)) cal")
//            }
//
//            HStack {
//                Text("Protein:")
//                Spacer()
//                Text(calculatedValue(for: food.protein, withServing: food.serving))
//            }
//
//            HStack {
//                Text("Carbs:")
//                Spacer()
//                Text(calculatedValue(for: food.carbs, withServing: food.serving))
//            }
//
//            Spacer()
//        }
//        .padding()
//        .navigationTitle(food.name ?? "Food Details")
//        .navigationBarTitleDisplayMode(.inline)
//    }
//
//    private func calculatedValue(for value: String?, withServing serving: String?) -> String {
//        guard let value = value else {
//            return "0"
//        }
//        let numericValue = extractNumericValue(from: value) ?? 0
//        let unitPart = value.components(separatedBy: CharacterSet.decimalDigits).joined().trimmingCharacters(in: .whitespaces)
//        let servingValue = extractNumericValue(from: serving ?? "1") ?? 1
//        let calculatedValue = numericValue * servingValue
//        return String(format: "%.1f", calculatedValue) + unitPart
//    }
//}

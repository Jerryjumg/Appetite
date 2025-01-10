//
//  AddIngredientsView.swift
//  Appétit
//
//  Created by Jerry Jung on 12/14/24.
//

import SwiftUI
import CoreData

struct AddIngredientsView: View {
    @Environment(\.managedObjectContext)  var viewContext
    @Environment(\.dismiss)  var dismiss

    @State  var ingredients: [Ingredient]
    @State  var selectedCategory: String = ""
    @State  var showingAlert = false
    @State  var alertMessage = ""

    @FetchRequest(
        entity: Grocery.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Grocery.name, ascending: true)]
    )  var groceries: FetchedResults<Grocery>
    
    var uniqueCategories: [String] {
           let categories = groceries.compactMap { $0.category }
           return Array(Set(categories)).sorted()
       }
    

    var body: some View {
        NavigationView {
            Form {
               ForEach(ingredients.indices, id: \.self) { index in
                   VStack(alignment: .leading, spacing: 20) {
                       // Item Name
                       Text("Item Name")
                           .font(.subheadline)
                           .foregroundColor(.secondary)
                       TextField("Enter item name", text: $ingredients[index].name)
                           .textFieldStyle(RoundedBorderTextFieldStyle())
                           .padding(.vertical, 10)
                           .background(Color.white)
                           .cornerRadius(10)
                           .shadow(radius: 5)

                       // Quantity
                       Text("Quantity")
                           .font(.subheadline)
                           .foregroundColor(.secondary)
                       TextField("Enter quantity", text: $ingredients[index].quantity)
                           .textFieldStyle(RoundedBorderTextFieldStyle())
                           .padding(.vertical, 10)
                           .background(Color.white)
                           .cornerRadius(10)
                           .shadow(radius: 5)

                       // Category Picker
                       Text("Category")
                           .font(.subheadline)
                           .foregroundColor(.secondary)
                       Picker("Select Category", selection: $ingredients[index].category) {
                           ForEach(uniqueCategories, id: \.self) { category in
                               Text(category).tag(category)
                           }
                       }
                       .pickerStyle(MenuPickerStyle())
                   }
                   .padding(.vertical, 10)
               }
           }
            .navigationBarTitle("Add Ingredients", displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveIngredients()
                    }
                }
            }
            .alert(isPresented: $showingAlert) {
                Alert(title: Text("Notification"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
        }
    }

    private func saveIngredients() {
        for ingredient in ingredients {
            let newItem = Grocery(context: viewContext)
            newItem.name = ingredient.name
            newItem.quantity = ingredient.quantity
            newItem.category = ingredient.category
        }

        do {
            try viewContext.save()
            alertMessage = "Ingredients added successfully."
            showingAlert = true
            dismiss()
        } catch {
            alertMessage = "Failed to save ingredients: \(error.localizedDescription)"
            showingAlert = true
        }
    }
}

struct Ingredient {
    var name: String
    var quantity: String
    var category: String
}

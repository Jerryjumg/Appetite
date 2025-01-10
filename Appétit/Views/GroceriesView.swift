//import SwiftUI
//

import SwiftUI
import CoreData

struct GroceryListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Grocery.category, ascending: true)],
        predicate: nil,
        animation: .default
    ) private var groceries: FetchedResults<Grocery>

    @State private var isAddingCategory = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var editingItem: Grocery?
    @State private var editingCategory: String?
    @State private var addingItemCategory: IdentifiableString?

    var body: some View {
        NavigationView {
            List {
                ForEach(groupedGroceries, id: \.0) { category, items in
                                    GroceryCategorySection(category: category, items: items, groceries: groceries, editingItem: $editingItem, editingCategory: $editingCategory, addingItemCategory: $addingItemCategory)
                                }
            }
            .navigationTitle("Grocery List")
            .toolbar {
                Button("Add Category") {
                    isAddingCategory = true
                }
            }
            .sheet(isPresented: $isAddingCategory) {
                AddCategoryView()
            }
            .sheet(item: $editingItem) { item in
                if let editingCategory = editingCategory {
                    EditItemView(item: item, category: editingCategory, showingAlert: $showingAlert, alertMessage: $alertMessage)
                }
            }
            .alert(isPresented: $showingAlert) {
                Alert(title: Text("Notification"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
            .sheet(item: $addingItemCategory) { category in
                           AddItemView(category: category.value)
          }
        }
    }

    private var groupedGroceries: [(String, [Grocery])] {
           Dictionary(grouping: groceries, by: { $0.category ?? "Unknown" }).sorted { $0.key < $1.key }
       }
}

struct GroceryCategorySection: View {
    var category: String
    var items: [Grocery]
    var groceries: FetchedResults<Grocery>
    @Binding var editingItem: Grocery?
    @Binding var editingCategory: String?
    @Binding var addingItemCategory: IdentifiableString?

    var body: some View {
        Section(header: HStack {
            Text(category)
            Spacer()
            Button(action: {
                addingItemCategory = IdentifiableString(value: category)
            }) {
                Image(systemName: "plus.circle")
                    .foregroundColor(Color(hex: "#91C788"))
            }
        }) {
            ForEach(items) { item in
                GroceryItemRow(item: item, groceries: groceries, editingItem: $editingItem, editingCategory: $editingCategory)
            }
        }
    }
}

struct GroceryItemRow: View {
    var item: Grocery
    var groceries: FetchedResults<Grocery>
    @Binding var editingItem: Grocery?
    @Binding var editingCategory: String?

    var body: some View {
        HStack {
            Button(action: {
                toggleCheck(for: item)
            }) {
                Image(systemName: item.isChecked ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(item.isChecked ? Color(hex: "#91C788") : Color(hex: "#91C788"))
            }
            Text(item.name ?? "")
                .strikethrough(item.isChecked, color: .gray)
                .foregroundColor(item.isChecked ? .gray : .primary)
            Spacer()
            Text(item.quantity ?? "")
                .strikethrough(item.isChecked, color: .gray)
                .foregroundColor(item.isChecked ? .gray : .secondary)
        }
        .swipeActions {
            Button(role: .destructive) {
                deleteItem(item)
            } label: {
                Label("Delete", systemImage: "trash")
            }
            Button {
                editingItem = item
                editingCategory = item.category
            } label: {
                Label("Edit", systemImage: "pencil")
            }
            .tint(.blue)
        }
    }

    private func toggleCheck(for item: Grocery) {
        item.isChecked.toggle()
        try? item.managedObjectContext?.save()
    }

    private func deleteItem(_ item: Grocery) {
        item.managedObjectContext?.delete(item)
        try? item.managedObjectContext?.save()
    }
}

struct AddCategoryView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

    @State private var categoryName = ""
    @State private var newItems: [String] = []   // Store the items
    @State private var newQuantities: [String] = []   // Store the quantities
    @State private var showingAlert = false
    @State private var alertMessage = ""

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Category Information")
                            .font(.headline)
                            .foregroundColor(Color(hex: "#91C788"))) {
                    VStack(alignment: .leading, spacing: 20) {
                        // Category Name
                        Text("Category Name")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        TextField("Enter category name", text: $categoryName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.vertical, 10)
                            .background(Color.white)
                            .cornerRadius(10)
                            .shadow(radius: 5)
                    }
                    .padding(.vertical, 10)
                }
                
                Section(header: Text("Items and Quantities")
                            .font(.headline)
                            .foregroundColor(Color(hex: "#91C788"))) {
                    ForEach(0..<newItems.count, id: \.self) { index in
                        VStack(alignment: .leading, spacing: 20) {
                            // Item Name
                            Text("Item Name")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            TextField("Enter item name", text: $newItems[index])
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .padding(.vertical, 10)
                                .background(Color.white)
                                .cornerRadius(10)
                                .shadow(radius: 5)

                            // Quantity
                            Text("Quantity")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            TextField("Enter quantity", text: $newQuantities[index])
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .padding(.vertical, 10)
                                .background(Color.white)
                                .cornerRadius(10)
                                .shadow(radius: 5)
                        }
                    }

                    // Add Item Button
                    Button(action: {
                        newItems.append("")
                        newQuantities.append("")
                    }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Add Item")
                        }
                        .foregroundColor(Color(hex: "#91C788"))
                    }
                }
                
            }
            .navigationBarTitle("Add Category", displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        handleSave()
                    }
                }
            }
            .alert(isPresented: $showingAlert) {
                Alert(title: Text("Notification"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
        }
    }

    private func handleSave() {
        // Check if category name is empty
        if categoryName.isEmpty {
            alertMessage = "Category name cannot be empty."
            showingAlert = true
            return
        }
        
        // Create new category with items and quantities
        for (index, itemName) in newItems.enumerated() {
            if !itemName.isEmpty && !newQuantities[index].isEmpty {
                let newItem = Grocery(context: viewContext, name: itemName, quantity: newQuantities[index], category: categoryName)
                viewContext.insert(newItem)
            }
        }

        do {
            try viewContext.save()
            alertMessage = "Category added successfully."
            showingAlert = true
            dismiss()
        } catch {
            alertMessage = "Failed to save category: \(error.localizedDescription)"
            showingAlert = true
        }
    }
}

struct AddItemView: View {
    var category: String
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

    @State private var itemName = ""
    @State private var itemQuantity = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""

    var body: some View {
        NavigationView {
            Form {
                VStack(alignment: .leading, spacing: 20) {
                    // Item Name
                    Text("Item Name")
                        .font(.subheadline)
                        .foregroundColor(Color(hex: "#91C788"))
                    TextField("Enter item name", text: $itemName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.vertical, 10)
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                    
                    // Quantity
                    Text("Quantity")
                        .font(.subheadline)
                        .foregroundColor(Color(hex: "#91C788"))
                    TextField("Enter quantity", text: $itemQuantity)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.vertical, 10)
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                }
                .padding(.vertical, 10)
            }
            .navigationBarTitle("Add Item", displayMode: .inline)
            
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if itemName.isEmpty {
                            alertMessage = "Please enter an item name."
                            showingAlert = true
                        } else if itemQuantity.isEmpty {
                            alertMessage = "Please enter a quantity."
                            showingAlert = true
                        } else {
                            let newItem = Grocery(context: viewContext, name: itemName, quantity: itemQuantity, category: category)
                            viewContext.insert(newItem)
                            do {
                                try viewContext.save()
                                alertMessage = "Item added successfully."
                                showingAlert = true
                                dismiss()
                            } catch {
                                alertMessage = "Failed to save item: \(error.localizedDescription)"
                                showingAlert = true
                            }
                        }
                    }
                }
            }
            .alert(isPresented: $showingAlert) {
                Alert(title: Text("Notification"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
        }
    }
}

struct EditItemView: View {
    @State var item: Grocery
    var category: String
    @Environment(\.managedObjectContext) private var viewContext
    @Binding var showingAlert: Bool
    @Binding var alertMessage: String
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Item Details").font(.headline).foregroundColor(Color(hex: "#91C788"))) {
                    
                    VStack(alignment: .leading, spacing: 20) {
                        
                        // Item Name
                        Text("Item Name")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        TextField("Enter item name", text: Binding(
                                                    get: { item.name ?? "" },
                                                    set: { item.name = $0 }
                                                ))
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.vertical, 10)
                            .background(Color.white)
                            .cornerRadius(10)
                            .shadow(radius: 5)

                        // Quantity
                        Text("Quantity")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        TextField("Enter quantity", text: Binding(
                                                   get: { item.quantity ?? "" },
                                                   set: { item.quantity = $0 }
                                               ))
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.vertical, 10)
                            .background(Color.white)
                            .cornerRadius(10)
                            .shadow(radius: 5)
                    }
                    .padding(.vertical, 10)
                }
            }
            .navigationBarTitle("Edit Item", displayMode: .inline)
            .background(Color(.systemGroupedBackground))
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: {
                        dismiss()
                    }) {
                        Text("Cancel")
                            .fontWeight(.semibold)
                            .foregroundColor(.red)
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(action: {
                        if item.name?.isEmpty ?? true {
                            alertMessage = "Item name cannot be empty."
                            showingAlert = true
                        } else if item.quantity?.isEmpty ?? true {
                            alertMessage = "Quantity cannot be empty."
                            showingAlert = true
                        } else {
                            do {
                                try viewContext.save()
                                alertMessage = "Item updated successfully."
                                showingAlert = true
                                dismiss()
                            } catch {
                                alertMessage = "Failed to update item: \(error.localizedDescription)"
                                showingAlert = true
                            }
                        }
                    }) {
                        Text("Save")
                            .fontWeight(.semibold)
                            .foregroundColor(Color(hex: "#91C788"))
                    }
                }
            }
            .alert(isPresented: $showingAlert) {
                Alert(title: Text("Notification"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
            .padding(.top, 20)
        }
        .accentColor(.green) // Accent color for better consistency
    }
}

struct IdentifiableString: Identifiable {
    var id: String { value }
    let value: String
}

//struct GroceryListView: View {
//    @State private var groceries: [GroceryCategory] = [
//        GroceryCategory(name: "Produce", items: [
//            GroceryItem(name: "English cucumber", quantity: "1"),
//            GroceryItem(name: "Garlic", quantity: "1 clove"),
//            GroceryItem(name: "Ginger root", quantity: "1 (1 inch) piece"),
//            GroceryItem(name: "Green onions (scallions)", quantity: "½ small bunch")
//        ]),
//        GroceryCategory(name: "Meat & Seafood", items: [
//            GroceryItem(name: "Lean ground beef", quantity: "¾ lb")
//        ]),
//        GroceryCategory(name: "Nut Butters, Honey & Jams", items: [
//            GroceryItem(name: "Honey", quantity: "")
//        ]),
//        GroceryCategory(name: "Baking & Spices", items: [
//            GroceryItem(name: "Crushed red pepper", quantity: "")
//        ])
//    ]
//    @State private var isAddingCategory = false
//    @State private var showingAlert = false
//    @State private var alertMessage = ""
//    @State private var editingItem: GroceryItem?
//    @State private var editingCategory: GroceryCategory?
//    @State private var addingItemCategory: GroceryCategory?
//
//    var body: some View {
//        NavigationView {
//            List {
//                ForEach(groceries) { category in
//                    GroceryCategorySection(category: category, groceries: $groceries, editingItem: $editingItem, editingCategory: $editingCategory, addingItemCategory: $addingItemCategory)
//                }
//            }
//            .navigationTitle("Grocery List")
//            .toolbar {
//                Button("Add Category") {
//                    isAddingCategory = true
//                }
//            }
//            .sheet(isPresented: $isAddingCategory) {
//                AddCategoryView(groceries: $groceries)
//            }
//            .sheet(item: $editingItem) { item in
//                if let editingCategory = editingCategory {
//                    EditItemView(item: item, category: editingCategory, groceries: $groceries, showingAlert: $showingAlert, alertMessage: $alertMessage)
//             }
//            }
//            .alert(isPresented: $showingAlert) {
//                Alert(title: Text("Notification"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
//            }
//            .sheet(item: $addingItemCategory) { category in
//                AddItemView(category: category, groceries: $groceries)
//            }
//            .alert(isPresented: $showingAlert) {
//                Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
//            }
//        }
//    }
//}
//
//
//struct AddItemView: View {
//    var category: GroceryCategory
//    @Binding var groceries: [GroceryCategory]
//    @Environment(\.dismiss) private var dismiss
//
//    @State private var itemName = ""
//    @State private var itemQuantity = ""
//    @State private var showingAlert = false
//    @State private var alertMessage = ""
//
//    var body: some View {
//        NavigationView {
//            Form {
//                VStack(alignment: .leading, spacing: 20) {
//                    // Item Name
//                    Text("Item Name")
//                        .font(.subheadline)
//                        .foregroundColor(Color(hex: "#91C788"))
//                    TextField("Enter item name", text: $itemName)
//                        .textFieldStyle(RoundedBorderTextFieldStyle())
//                        .padding(.vertical, 10)
//                        .background(Color.white)
//                        .cornerRadius(10)
//                        .shadow(radius: 5)
//                    
//                    // Quantity
//                    Text("Quantity")
//                        .font(.subheadline)
//                        .foregroundColor(Color(hex: "#91C788"))
//                    TextField("Enter quantity", text: $itemQuantity)
//                        .textFieldStyle(RoundedBorderTextFieldStyle())
//                        .padding(.vertical, 10)
//                        .background(Color.white)
//                        .cornerRadius(10)
//                        .shadow(radius: 5)
//                }
//                .padding(.vertical, 10)
//            }
//            .navigationBarTitle("Add Item", displayMode: .inline)
//            
//            .toolbar {
//                ToolbarItem(placement: .cancellationAction) {
//                    Button("Cancel") {
//                        dismiss()
//                    }
//                }
//                ToolbarItem(placement: .confirmationAction) {
//                    Button("Save") {
//                        if itemName.isEmpty {
//                            alertMessage = "Please enter an item name."
//                            showingAlert = true
//                        } else if itemQuantity.isEmpty {
//                            alertMessage = "Please enter a quantity."
//                            showingAlert = true
//                        } else {
//                            if let categoryIndex = groceries.firstIndex(where: { $0.id == category.id }) {
//                                let newItem = GroceryItem(name: itemName, quantity: itemQuantity)
//                                groceries[categoryIndex].items.append(newItem)
//                                alertMessage = "Item added successfully."
//                                showingAlert = true
//                            }
//                            dismiss()
//                        }
//                    }
//                }
//            }
//            .alert(isPresented: $showingAlert) {
//                Alert(title: Text("Notification"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
//            }
//        }
//    }
//}
//
//
//struct GroceryCategorySection: View {
//    var category: GroceryCategory
//    @Binding var groceries: [GroceryCategory]
//    @Binding var editingItem: GroceryItem?
//    @Binding var editingCategory: GroceryCategory?
//    @Binding var addingItemCategory: GroceryCategory?
//
//    var body: some View {
//        Section(header: HStack {
//            Text(category.name)
//            Spacer()
//            Button(action: {
//                addingItemCategory = category
//            }) {
//                Image(systemName: "plus.circle")
//                    .foregroundColor(Color(hex: "#91C788"))
//            }
//        }) {
//            ForEach(category.items) { item in
//                GroceryItemRow(item: item, category: category, groceries: $groceries, editingItem: $editingItem, editingCategory: $editingCategory)
//            }
//        }
//    }
//}
//
//struct GroceryItemRow: View {
//    var item: GroceryItem
//    var category: GroceryCategory
//    @Binding var groceries: [GroceryCategory]
//    @Binding var editingItem: GroceryItem?
//    @Binding var editingCategory: GroceryCategory?
//
//    var body: some View {
//        HStack {
//            Button(action: {
//                toggleCheck(for: item, in: category)
//            }) {
//                Image(systemName: item.isChecked ? "checkmark.circle.fill" : "circle")
//                    .foregroundColor(item.isChecked ? Color(hex: "#91C788") : Color(hex: "#91C788") )
//            }
//            Text(item.name)
//                .strikethrough(item.isChecked, color: .gray)
//                .foregroundColor(item.isChecked ? .gray : .primary)
//            Spacer()
//            Text(item.quantity)
//                .strikethrough(item.isChecked, color: .gray)
//                .foregroundColor(item.isChecked ? .gray : .secondary)
//        }
//        .swipeActions {
//            Button(role: .destructive) {
//                deleteItem(item, from: category)
//            } label: {
//                Label("Delete", systemImage: "trash")
//            }
//            Button {
//                editingItem = item
//                editingCategory = category
//            } label: {
//                Label("Edit", systemImage: "pencil")
//            }
//            .tint(.blue)
//        }
//    }
//
//    private func toggleCheck(for item: GroceryItem, in category: GroceryCategory) {
//        if let categoryIndex = groceries.firstIndex(where: { $0.id == category.id }),
//           let itemIndex = groceries[categoryIndex].items.firstIndex(where: { $0.id == item.id }) {
//            groceries[categoryIndex].items[itemIndex].isChecked.toggle()
//        }
//    }
//
//    private func deleteItem(_ item: GroceryItem, from category: GroceryCategory) {
//        if let categoryIndex = groceries.firstIndex(where: { $0.id == category.id }),
//           let itemIndex = groceries[categoryIndex].items.firstIndex(where: { $0.id == item.id }) {
//            groceries[categoryIndex].items.remove(at: itemIndex)
//        }
//    }
//}
//
//struct EditItemView: View {
//    @State var item: GroceryItem
//    var category: GroceryCategory
//    @Binding var groceries: [GroceryCategory]
//    @Binding var showingAlert: Bool
//    @Binding var alertMessage: String
//    @Environment(\.dismiss) private var dismiss
//
//    var body: some View {
//        NavigationView {
//            Form {
//                Section(header: Text("Item Details").font(.headline).foregroundColor(Color(hex: "#91C788"))) {
//                    
//                    VStack(alignment: .leading, spacing: 20) {
//                        
//                        // Item Name
//                        Text("Item Name")
//                            .font(.subheadline)
//                            .foregroundColor(.secondary)
//                        TextField("Enter item name", text: $item.name)
//                            .textFieldStyle(RoundedBorderTextFieldStyle())
//                            .padding(.vertical, 10)
//                            .background(Color.white)
//                            .cornerRadius(10)
//                            .shadow(radius: 5)
//
//                        // Quantity
//                        Text("Quantity")
//                            .font(.subheadline)
//                            .foregroundColor(.secondary)
//                        TextField("Enter quantity", text: $item.quantity)
//                            .textFieldStyle(RoundedBorderTextFieldStyle())
//                            .padding(.vertical, 10)
//                            .background(Color.white)
//                            .cornerRadius(10)
//                            .shadow(radius: 5)
//                    }
//                    .padding(.vertical, 10)
//                }
//            }
//            .navigationBarTitle("Edit Item", displayMode: .inline)
//            .background(Color(.systemGroupedBackground))
//            .toolbar {
//                ToolbarItem(placement: .cancellationAction) {
//                    Button(action: {
//                        dismiss()
//                    }) {
//                        Text("Cancel")
//                            .fontWeight(.semibold)
//                            .foregroundColor(.red)
//                    }
//                }
//                ToolbarItem(placement: .confirmationAction) {
//                    Button(action: {
//                        if item.name.isEmpty {
//                            alertMessage = "Item name cannot be empty."
//                            showingAlert = true
//                        } else if item.quantity.isEmpty {
//                            alertMessage = "Quantity cannot be empty."
//                            showingAlert = true
//                        } else {
//                            if let categoryIndex = groceries.firstIndex(where: { $0.id == category.id }),
//                               let itemIndex = groceries[categoryIndex].items.firstIndex(where: { $0.id == item.id }) {
//                                groceries[categoryIndex].items[itemIndex] = item
//                                alertMessage = "Item updated successfully."
//                                showingAlert = true
//                                dismiss()
//                            }
//                        }
//                    }) {
//                        Text("Save")
//                            .fontWeight(.semibold)
//                            .foregroundColor(Color(hex: "#91C788"))
//                            //.padding()
//                           // .background(Color.green.opacity(0.1))
//                            //.cornerRadius(8)
//                            ///.shadow(radius: 5)
//                    }
//                }
//            }
//            .alert(isPresented: $showingAlert) {
//                Alert(title: Text("Notification"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
//            }
//            .padding(.top, 20)
//        }
//        .accentColor(.green) // Accent color for better consistency
//    }
//}
//
////    private func addItem() {
////        items.append("")
////        quantities.append("")
////    }
////    
//
//struct AddCategoryView: View {
//    @Binding var groceries: [GroceryCategory]
//    @Environment(\.dismiss) private var dismiss
//
//    @State private var categoryName = ""
//    @State private var newItems: [String] = []   // Store the items
//    @State private var newQuantities: [String] = []   // Store the quantities
//    @State private var showingAlert = false
//    @State private var alertMessage = ""
//
//    var body: some View {
//        NavigationView {
//            Form {
//                Section(header: Text("Category Information")
//                            .font(.headline)
//                            .foregroundColor(Color(hex: "#91C788"))) {
//                    VStack(alignment: .leading, spacing: 20) {
//                        // Category Name
//                        Text("Category Name")
//                            .font(.subheadline)
//                            .foregroundColor(.secondary)
//                        TextField("Enter category name", text: $categoryName)
//                            .textFieldStyle(RoundedBorderTextFieldStyle())
//                            .padding(.vertical, 10)
//                            .background(Color.white)
//                            .cornerRadius(10)
//                            .shadow(radius: 5)
//                    }
//                    .padding(.vertical, 10)
//                }
//                
//                Section(header: Text("Items and Quantities")
//                            .font(.headline)
//                            .foregroundColor(Color(hex: "#91C788"))) {
//                    ForEach(0..<newItems.count, id: \.self) { index in
//                        VStack(alignment: .leading, spacing: 20) {
//                            // Item Name
//                            Text("Item Name")
//                                .font(.subheadline)
//                                .foregroundColor(.secondary)
//                            TextField("Enter item name", text: $newItems[index])
//                                .textFieldStyle(RoundedBorderTextFieldStyle())
//                                .padding(.vertical, 10)
//                                .background(Color.white)
//                                .cornerRadius(10)
//                                .shadow(radius: 5)
//
//                            // Quantity
//                            Text("Quantity")
//                                .font(.subheadline)
//                                .foregroundColor(.secondary)
//                            TextField("Enter quantity", text: $newQuantities[index])
//                                .textFieldStyle(RoundedBorderTextFieldStyle())
//                                .padding(.vertical, 10)
//                                .background(Color.white)
//                                .cornerRadius(10)
//                                .shadow(radius: 5)
//                        }
//                    }
//
//                    // Add Item Button
//                    Button(action: {
//                        newItems.append("")
//                        newQuantities.append("")
//                    }) {
//                        HStack {
//                            Image(systemName: "plus.circle.fill")
//                            Text("Add Item")
//                        }
//                        .foregroundColor(Color(hex: "#91C788"))
//                    }
//                }
//                
//            }
//            .navigationBarTitle("Add Category", displayMode: .inline)
//            .toolbar {
//                ToolbarItem(placement: .cancellationAction) {
//                    Button("Cancel") {
//                        dismiss()
//                    }
//                }
//                ToolbarItem(placement: .confirmationAction) {
//                    Button("Save") {
//                        handleSave()
//                    }
//                }
//            }
//            .alert(isPresented: $showingAlert) {
//                Alert(title: Text("Notification"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
//            }
//        }
//    }
//
//    private func handleSave() {
//        // Check if category name is empty
//        if categoryName.isEmpty {
//            alertMessage = "Category name cannot be empty."
//            showingAlert = true
//            return
//        }
//        
//        // Create new category with items and quantities
//        var newItemsArray: [GroceryItem] = []
//        
//        for (index, itemName) in newItems.enumerated() {
//            if !itemName.isEmpty && !newQuantities[index].isEmpty {
//                let newItem = GroceryItem(name: itemName, quantity: newQuantities[index])
//                newItemsArray.append(newItem)
//            }
//        }
//
//        if newItemsArray.isEmpty {
//            alertMessage = "Please enter at least one item with a quantity."
//            showingAlert = true
//            return
//        }
//
//        let newCategory = GroceryCategory(name: categoryName, items: newItemsArray)
//        groceries.append(newCategory)
//        alertMessage = "Category added successfully."
//        showingAlert = true
//        dismiss()
//    }
//}
//
//
//
//
//struct GroceryCategory: Identifiable {
//    let id = UUID()
//    var name: String
//    var items: [GroceryItem]
//}
//
//struct GroceryItem: Identifiable {
//    let id = UUID()
//    var name: String
//    var quantity: String
//    var isChecked: Bool = false
//}
//
//struct GroceryListView_Previews: PreviewProvider {
//    static var previews: some View {
//        GroceryListView()
//    }
//}

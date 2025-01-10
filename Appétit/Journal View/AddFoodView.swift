////
////  AddFoodView.swift
////  Appétit
////
////  Created by Jerry Jung on 12/12/24.
////
///
import SwiftUI
import CoreData

struct AddFoodView: View {
    let mealType: String
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode

    @State private var selectedMode = 0
    @State private var foodName = ""
    @State private var calories = ""
    @State private var fat = ""
    @State private var fiber = ""
    @State private var carbs = ""
    @State private var protein = ""
    @State private var serving = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""

    
    var body: some View {
        NavigationView {
            VStack {
                Picker("Mode", selection: $selectedMode) {
                    Text("Manual Input").tag(0)
                    Text("Search").tag(1)
                    Text("Food added").tag(2)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                .background(Color.black.opacity(0.2))
                .cornerRadius(8)
                .padding(.bottom, 10)
                
                if selectedMode == 0 {
                    manualInputView
                } else if selectedMode == 1 {
                    SearchFoodView(mealType: mealType)
                } else {
                    FoodAddedView(mealType: mealType)
                }
            }
            //.navigationTitle("Add Food to \(mealType)")
            //.navigationBarTitleDisplayMode(.inline) // This makes the title smaller and more compact
            .padding(.top, -10)
            .alert(isPresented: $showingAlert) {
                Alert(title: Text("Message"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
        }
    }
    
    var manualInputView: some View {
        Form {
            Section(header: Text("Add Food to \(mealType)").font(.title3).bold()) {
                Group {
                    inputField(title: "Name", value: $foodName)
                    inputField(title: "Calories", value: $calories, keyboardType: .decimalPad)
                    inputField(title: "Fat", value: $fat, keyboardType: .decimalPad)
                    inputField(title: "Fiber", value: $fiber, keyboardType: .decimalPad)
                    inputField(title: "Carbs", value: $carbs, keyboardType: .decimalPad)
                    inputField(title: "Protein", value: $protein, keyboardType: .decimalPad)
                    inputField(title: "Serving", value: $serving, keyboardType: .decimalPad)
                }
            }

            Button(action: {
                addFood()
            }) {
                Text("Add Food")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .shadow(radius: 5)
            }
            .padding(.top)
        }
        .padding(.horizontal)
    }

    func inputField(title: String, value: Binding<String>, keyboardType: UIKeyboardType = .default) -> some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.white)
            TextField("Enter \(title.lowercased())", text: value)
                .keyboardType(keyboardType)
                .padding(.horizontal)  // Removed vertical padding to reduce line height
                .padding(.vertical, 2) // Control the vertical padding for better line height
                .background(Color.white.opacity(0.1))
                .cornerRadius(10)
                .foregroundColor(.black)  // Make sure the text color is black
                .padding(.bottom, 2)
        }
    }


    func addFood() {
        guard !foodName.isEmpty else {
            alertMessage = "Please enter a valid food name."
            showingAlert = true
            return
        }

        guard !mealType.isEmpty else {
            alertMessage = "Please enter a valid meal type."
            showingAlert = true
            return
        }
        
        guard !calories.isEmpty, let caloriesValue = Double(calories), caloriesValue > 0 else {
            alertMessage = "Please enter a valid calories amount."
            showingAlert = true
            return
        }

        guard !fat.isEmpty, let fatValue = Double(fat), fatValue >= 0 else {
            alertMessage = "Please enter a valid fat amount."
            showingAlert = true
            return
        }

        guard !fiber.isEmpty, let fiberValue = Double(fiber), fiberValue > 0 else {
            alertMessage = "Please enter a valid fiber amount."
            showingAlert = true
            return
        }

        guard !carbs.isEmpty, let carbsValue = Double(carbs), carbsValue > 0 else {
            alertMessage = "Please enter a valid carbs amount."
            showingAlert = true
            return
        }

        guard !protein.isEmpty, let proteinValue = Double(protein), proteinValue > 0 else {
            alertMessage = "Please enter a valid protein amount."
            showingAlert = true
            return
        }

        guard !serving.isEmpty, let servingValue = Double(serving), servingValue > 0 else {
            alertMessage = "Please enter a valid serving size."
            showingAlert = true
            return
        }

        let fetchRequest: NSFetchRequest<Food> = Food.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name == %@", foodName)

        do {
            let existingFoods = try viewContext.fetch(fetchRequest)
            if existingFoods.isEmpty {
                let newFood = Food(context: viewContext)
                newFood.name = foodName
                newFood.mealType = mealType
                newFood.calories = calories
                newFood.fat = fat
                newFood.fiber = fiber
                newFood.carbs = carbs
                newFood.protein = protein
                newFood.serving = serving

                try viewContext.save()
                alertMessage = "Food added successfully!"
                showingAlert = true
                presentationMode.wrappedValue.dismiss()
            } else {
                alertMessage = "Food with the name \(foodName) already exists."
                showingAlert = true
            }
        } catch {
            alertMessage = "Failed to add food. Please try again."
            showingAlert = true
        }
    }
}

///
//import SwiftUI
//import CoreData
//
//struct AddFoodView: View {
//    let mealType: String
//    @Environment(\.managedObjectContext) private var viewContext
//    @Environment(\.presentationMode) var presentationMode
//
//    @State private var selectedMode = 0
//    @State private var foodName = ""
//    @State private var calories = ""
//    @State private var fat = ""
//    @State private var fiber = ""
//    @State private var carbs = ""
//    @State private var protein = ""
//    @State private var serving = ""
//    @State private var showingAlert = false
//    @State private var alertMessage = ""
//
//    
//    var body: some View {
//        NavigationView {
//            VStack {
//                Picker("Mode", selection: $selectedMode) {
//                    Text("Manual Input").tag(0)
//                    Text("Search").tag(1)
//                    Text("Food added").tag(2)
//                }
//                .pickerStyle(SegmentedPickerStyle())
//                .padding()
//                
//                if selectedMode == 0 {
//                    manualInputView
//                } else if selectedMode == 1 {
//                    SearchFoodView(mealType: mealType)
//                } else {
//                    FoodAddedView(mealType: mealType)
//                }
//            }
//            .navigationTitle("Add Food to \(mealType)")
//            .alert(isPresented: $showingAlert) {
//                Alert(title: Text("Message"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
//            }
//        }
//    }
//    
//    var manualInputView: some View {
//        Form {
//            Section(header: Text("Add Food to \(mealType)")) {
//                VStack(alignment: .leading) {
//                    Text("Name")
//                        .font(.headline)
//                    TextField("Enter food name", text: $foodName)
//                        .textFieldStyle(RoundedBorderTextFieldStyle())
//                        .padding(.bottom)
//                    Text("Calories")
//                       .font(.headline)
//                   TextField("Enter calories", text: $calories)
//                       .keyboardType(.decimalPad)
//                       .textFieldStyle(RoundedBorderTextFieldStyle())
//                       .padding(.bottom)
//                   
//                   Text("Fat")
//                       .font(.headline)
//                   TextField("Enter fat amount", text: $fat)
//                       .keyboardType(.decimalPad)
//                       .textFieldStyle(RoundedBorderTextFieldStyle())
//                       .padding(.bottom)
//                   
//                   Text("Fiber")
//                       .font(.headline)
//                   TextField("Enter fiber amount", text: $fiber)
//                       .keyboardType(.decimalPad)
//                       .textFieldStyle(RoundedBorderTextFieldStyle())
//                       .padding(.bottom)
//                   
//                   Text("Carbs")
//                       .font(.headline)
//                   TextField("Enter carbs amount", text: $carbs)
//                       .keyboardType(.decimalPad)
//                       .textFieldStyle(RoundedBorderTextFieldStyle())
//                       .padding(.bottom)
//                   
//                   Text("Protein")
//                       .font(.headline)
//                   TextField("Enter protein amount", text: $protein)
//                       .keyboardType(.decimalPad)
//                       .textFieldStyle(RoundedBorderTextFieldStyle())
//                       .padding(.bottom)
//                   
//                   Text("Serving")
//                       .font(.headline)
//                   TextField("Enter serving size", text: $serving)
//                       .keyboardType(.decimalPad)
//                       .textFieldStyle(RoundedBorderTextFieldStyle())
//                       .padding(.bottom)
//                }
//            }
//
//            Button(action: {
//                addFood()
//                print("Food added to \(mealType): \(foodName)")
//            }) {
//                Text("Add Food")
//                    .frame(maxWidth: .infinity)
//                    .padding()
//                    .background(Color.blue)
//                    .foregroundColor(.white)
//                    .cornerRadius(8)
//            }
//        }
//        //.navigationTitle("Food Detail")
//        .alert(isPresented: $showingAlert) {
//            Alert(title: Text("Message"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
//        }
//    }
//
//    func addFood() {
//        guard !foodName.isEmpty else {
//            alertMessage = "Please enter a valid food name."
//            showingAlert = true
//            return
//        }
//
//        guard !mealType.isEmpty else {
//            alertMessage = "Please enter a valid meal type."
//            showingAlert = true
//            return
//        }
//        
//        guard !calories.isEmpty, let caloriesValue = Double(calories), caloriesValue > 0 else {
//            alertMessage = "Please enter a valid calories amount."
//            showingAlert = true
//            return
//        }
//
//        guard !fat.isEmpty, let fatValue = Double(fat), fatValue >= 0 else {
//            alertMessage = "Please enter a valid fat amount."
//            showingAlert = true
//            return
//        }
//
//        guard !fiber.isEmpty, let fiberValue = Double(fiber), fiberValue > 0 else {
//            alertMessage = "Please enter a valid fiber amount."
//            showingAlert = true
//            return
//        }
//
//        guard !carbs.isEmpty, let carbsValue = Double(carbs), carbsValue > 0 else {
//            alertMessage = "Please enter a valid carbs amount."
//            showingAlert = true
//            return
//        }
//
//        guard !protein.isEmpty, let proteinValue = Double(protein), proteinValue > 0 else {
//            alertMessage = "Please enter a valid protein amount."
//            showingAlert = true
//            return
//        }
//
//        guard !serving.isEmpty, let servingValue = Double(serving), servingValue > 0 else {
//            alertMessage = "Please enter a valid serving size."
//            showingAlert = true
//            return
//        }
//
//        let fetchRequest: NSFetchRequest<Food> = Food.fetchRequest()
//        fetchRequest.predicate = NSPredicate(format: "name == %@", foodName)
//
//        do {
//            let existingFoods = try viewContext.fetch(fetchRequest)
//            if existingFoods.isEmpty {
//                let newFood = Food(context: viewContext)
//                newFood.name = foodName
//                newFood.mealType = mealType
//                newFood.calories = calories
//                newFood.fat = fat
//                newFood.fiber = fiber
//                newFood.carbs = carbs
//                newFood.protein = protein
//                newFood.serving = serving
//
//                try viewContext.save()
//                alertMessage = "Food added successfully!"
//                showingAlert = true
//                presentationMode.wrappedValue.dismiss()
//            } else {
//                alertMessage = "Food with the name \(foodName) already exists."
//                showingAlert = true
//            }
//        } catch {
//            alertMessage = "Failed to add food. Please try again."
//            showingAlert = true
//        }
//    }
//}

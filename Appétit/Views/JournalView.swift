//
//import SwiftUI
//import CoreData
//

import SwiftUI
import CoreData

struct JournalView: View {
    @State private var mainGoal = "0 cal left"
    @State private var selectedDate = Date()
    @State private var showCalendar = false
    
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(entity: Food.entity(), sortDescriptors: []) var foods: FetchedResults<Food>
    @FetchRequest(entity: User.entity(), sortDescriptors: []) var users: FetchedResults<User>
    
    private let accentColor = Color("AccentColor") // Use a custom color set
    private let backgroundGradient = LinearGradient(
        gradient: Gradient(colors: [Color("BackgroundStart"), Color("BackgroundEnd")]),
        startPoint: .top,
        endPoint: .bottom
    )

    var body: some View {
        NavigationView {
            ZStack {
                // Background Gradient
                backgroundGradient
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 20) {
                    // Main Goal Section
                    VStack {
                        Text(mainGoal)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.black) // Use a contrasting color
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.white.opacity(0.8))
                                    .shadow(color: .gray.opacity(0.3), radius: 10, x: 0, y: 5)
                            )
                    }
                    .padding(.top, 20)
                    .onAppear(perform: updateMainGoal)

                    // Macronutrient Circular Progress
                    HStack(spacing: 20) {
                        CircularProgressView(value: 0.7, label: "Protein", color: Color.green)
                        CircularProgressView(value: 0.5, label: "Fat", color: Color.yellow)
                        CircularProgressView(value: 0.8, label: "Carbs", color: Color.orange)
                    }
                    .padding(.horizontal)
                    
                    // Meals Section
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Your Meals")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.black) // Use a contrasting color
                            .padding(.bottom, 10)
                        
                        ForEach(["Breakfast", "Lunch", "Dinner", "Snacks"], id: \.self) { meal in
                            mealCard(for: meal)
                        }
                    }
                    .padding(.horizontal)
                }
                .navigationTitle("Journal")
                .navigationBarTitleDisplayMode(.inline)
                .toolbarBackground(accentColor, for: .navigationBar)
            }
        }
    }
    
    private func updateMainGoal() {
           guard let user = users.first, let nutritionGoalString = user.nutritionGoal else { return }
           let nutritionGoal = extractNumericValue(from: nutritionGoalString)
           let totalCaloriesConsumed = totalCaloriesForAllMeals()
           let remainingCalories = nutritionGoal - totalCaloriesConsumed
           mainGoal = "\(Int(remainingCalories)) cal left"
       }
       
       private func extractNumericValue(from string: String) -> Double {
           let pattern = "\\d+"
           let regex = try? NSRegularExpression(pattern: pattern)
           let nsString = string as NSString
           let results = regex?.matches(in: string, range: NSRange(location: 0, length: nsString.length))
           let numbers = results?.compactMap { result -> Double? in
               let match = nsString.substring(with: result.range)
               return Double(match)
           }
           return numbers?.first ?? 0.0
       }
       
    private func totalCaloriesForAllMeals() -> Double {
         let mealTypes = ["Breakfast", "Lunch", "Dinner", "Snacks"]
         return mealTypes.reduce(0.0) { total, mealType in
             total + totalCalories(for: mealType)
         }
     }
    
    private func mealCard(for meal: String) -> some View {
        HStack {
            Image(systemName: "fork.knife")
                .font(.title2)
                .foregroundColor(.white) // Ensure the icon is visible
            
            VStack(alignment: .leading) {
                Text(meal)
                    .font(.headline)
                    .foregroundColor(.white)
                HStack {
                    Text("\(String(format: "%.2f", totalCalories(for: meal))) Cal")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                    Text("• \(totalProtein(for: meal)) g Protein")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            
            Spacer()
            
            NavigationLink(destination: AddFoodView(mealType: meal)) {
                Image(systemName: "plus.circle.fill")
                    .font(.title2)
                    .foregroundColor(.white) // Ensure the icon is visible
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.black.opacity(0.5))
                .shadow(color: .gray.opacity(0.5), radius: 5, x: 0, y: 2)
        )
    }
    
    private func totalCalories(for mealType: String) -> Double {
           let mealFoods = foods.filter { $0.mealType == mealType }
           return mealFoods.reduce(0.0) { total, food in
               total + (Double(food.calories ?? "0") ?? 0) * (Double(food.serving ?? "1") ?? 1)
           }
       }

    private func totalProtein(for mealType: String) -> String {
        let mealFoods = foods.filter { $0.mealType == mealType }
        let totalProtein = mealFoods.reduce(0.0) { total, food in
            total + (Double(food.protein ?? "0") ?? 0) * (Double(food.serving ?? "1") ?? 1)
        }
        return String(format: "%.0f", totalProtein)
    }
}

struct CircularProgressView: View {
    let value: Double
    let label: String
    let color: Color

    var body: some View {
        VStack {
            ZStack {
                Circle()
                    .stroke(Color.black.opacity(0.2), lineWidth: 10) // Use a contrasting color
                Circle()
                    .trim(from: 0, to: value)
                    .stroke(color, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .animation(.easeOut(duration: 1), value: value)
            }
            .frame(width: 80, height: 80)
            
            Text(label)
                .font(.caption)
                .foregroundColor(.black) // Use a contrasting color
        }
    }
}
//struct JournalView: View {
//    @State private var mainGoal = "2378 cal left"
//    @State private var selectedDate = Date()
//    @State private var showCalendar = false
//    
//    @Environment(\.managedObjectContext) private var viewContext
//    @FetchRequest(entity: Food.entity(), sortDescriptors: []) var foods: FetchedResults<Food>
//    
//    private let accentColor = Color("AccentColor") // Use a custom color set
//    private let backgroundGradient = LinearGradient(
//        gradient: Gradient(colors: [Color("BackgroundStart"), Color("BackgroundEnd")]),
//        startPoint: .top,
//        endPoint: .bottom
//    )
//
//    var body: some View {
//        NavigationView {
//            ZStack {
//                // Background Gradient
//                backgroundGradient
//                    .edgesIgnoringSafeArea(.all)
//                
//                VStack(spacing: 20) {
//                    // Main Goal Section
//                    VStack {
//                        Text(mainGoal)
//                            .font(.largeTitle)
//                            .fontWeight(.bold)
//                            .foregroundColor(.black) // Use a contrasting color
//                            .padding()
//                            .background(
//                                RoundedRectangle(cornerRadius: 12)
//                                    .fill(Color.white.opacity(0.8))
//                                    .shadow(color: .gray.opacity(0.3), radius: 10, x: 0, y: 5)
//                            )
//                    }
//                    .padding(.top, 20)
//
//                    // Macronutrient Circular Progress
//                    HStack(spacing: 20) {
//                        CircularProgressView(value: 0.7, label: "Protein", color: Color.green)
//                        CircularProgressView(value: 0.5, label: "Fat", color: Color.yellow)
//                        CircularProgressView(value: 0.8, label: "Carbs", color: Color.orange)
//                    }
//                    .padding(.horizontal)
//                    
//                    // Meals Section
//                    VStack(alignment: .leading, spacing: 20) {
//                        Text("Your Meals")
//                            .font(.title2)
//                            .fontWeight(.semibold)
//                            .foregroundColor(.black) // Use a contrasting color
//                            .padding(.bottom, 10)
//                        
//                        ForEach(["Breakfast", "Lunch", "Dinner", "Snacks"], id: \.self) { meal in
//                            mealCard(for: meal)
//                        }
//                    }
//                    .padding(.horizontal)
//                }
//                .navigationTitle("Journal")
//                .navigationBarTitleDisplayMode(.inline)
//                .toolbarBackground(accentColor, for: .navigationBar)
//            }
//        }
//    }
//    
//    
//    private func mealCard(for meal: String) -> some View {
//        HStack {
//            Image(systemName: "fork.knife")
//                .font(.title2)
//                .foregroundColor(.white) // Ensure the icon is visible
//            
//            VStack(alignment: .leading) {
//                Text(meal)
//                    .font(.headline)
//                    .foregroundColor(.white)
//                HStack {
//                    Text("\(totalCalories(for: meal)) Cal")
//                        .font(.subheadline)
//                        .foregroundColor(.white.opacity(0.8))
//                    Text("• \(totalProtein(for: meal)) g Protein")
//                        .font(.subheadline)
//                        .foregroundColor(.white.opacity(0.8))
//                }
//            }
//            
//            Spacer()
//            
//            NavigationLink(destination: AddFoodView(mealType: meal)) {
//                Image(systemName: "plus.circle.fill")
//                    .font(.title2)
//                    .foregroundColor(.white) // Ensure the icon is visible
//            }
//        }
//        .padding()
//        .background(
//            RoundedRectangle(cornerRadius: 12)
//                .fill(Color.black.opacity(0.5))
//                .shadow(color: .gray.opacity(0.5), radius: 5, x: 0, y: 2)
//        )
//    }
//    
//    private func totalCalories(for mealType: String) -> String {
//        let mealFoods = foods.filter { $0.mealType == mealType }
//        let totalCalories = mealFoods.reduce(0.0) { total, food in
//            total + (Double(food.calories ?? "0") ?? 0) * (Double(food.serving ?? "1") ?? 1)
//        }
//        return String(format: "%.0f", totalCalories)
//    }
//
//    private func totalProtein(for mealType: String) -> String {
//        let mealFoods = foods.filter { $0.mealType == mealType }
//        let totalProtein = mealFoods.reduce(0.0) { total, food in
//            total + (Double(food.protein ?? "0") ?? 0) * (Double(food.serving ?? "1") ?? 1)
//        }
//        return String(format: "%.0f", totalProtein)
//    }
//}
//
//struct CircularProgressView: View {
//    let value: Double
//    let label: String
//    let color: Color
//
//    var body: some View {
//        VStack {
//            ZStack {
//                Circle()
//                    .stroke(Color.black.opacity(0.2), lineWidth: 10) // Use a contrasting color
//                Circle()
//                    .trim(from: 0, to: value)
//                    .stroke(color, style: StrokeStyle(lineWidth: 10, lineCap: .round))
//                    .rotationEffect(.degrees(-90))
//                    .animation(.easeOut(duration: 1), value: value)
//            }
//            .frame(width: 80, height: 80)
//            
//            Text(label)
//                .font(.caption)
//                .foregroundColor(.black) // Use a contrasting color
//        }
//    }
//}

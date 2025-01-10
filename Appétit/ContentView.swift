//
//  ContentView.swift
//  Appétit
//
//  Created by Jerry Jung on 12/3/24.
//

import SwiftUI
import CoreData


struct ContentView: View {
    @State private var selectedTab: Int = 0
    
    var body: some View {
        TabView {
            JournalView()
                   .tabItem {
                       VStack {
                           Image("home")
                           Text("Journal")
                       }
                   }

            GroceryListView()
                .tabItem {
                    VStack {
                        Image("xx")
                        Text("Grocery")
                    }
                }

            RecipesView()
                .tabItem {
                    VStack {
                        Image("cooking")
                        Text("Recipe")
                    }
                }
            
            ProfileView()
                .tabItem {
                   VStack {
                       Image(selectedTab == 0 ? "Profile" : "Profile-Light")
                           .renderingMode(.original) // Ensure your custom image is not tinted
                       Text("Profile")
                   }
               }
               .tag(0)
        }
    }
}

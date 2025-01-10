//
//  Appe_titApp.swift
//  Appétit
//
//  Created by Jerry Jung on 12/3/24.
//

import SwiftUI

@main
struct Appe_titApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}

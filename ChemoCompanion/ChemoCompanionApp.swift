//
//  ChemoCompanionApp.swift
//  ChemoCompanion
//
//  Created by Sudarsan Reddy on 08/02/2025.
//

import SwiftUI

@main
struct ChemoCompanionApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}

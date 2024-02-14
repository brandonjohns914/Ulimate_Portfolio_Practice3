//
//  WorkoutApp.swift
//  Workout
//
//  Created by Brandon Johns on 2/13/24.
//

import SwiftUI

@main
struct WorkoutApp: App {
    @StateObject var dataController = DataController()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, dataController.container.viewContext)
                    .environmentObject(dataController)
        }
    }
}

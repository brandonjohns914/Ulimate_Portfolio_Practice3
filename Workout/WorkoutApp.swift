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
    @Environment(\.scenePhase) var scenePhase
    var body: some Scene {
        WindowGroup {
            NavigationSplitView {
                SidebarView()
            } content: {
                ContentView()
            } detail: {
                DetailView()
            }
            .environment(\.managedObjectContext, dataController.container.viewContext)
            .environmentObject(dataController)
            .onChange(of: scenePhase) { _, phase in
                if phase != .active {
                    dataController.save()
                }
            }
        }
    }
}

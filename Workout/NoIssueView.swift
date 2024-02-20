//
//  NoIssueView.swift
//  Workout
//
//  Created by Brandon Johns on 2/16/24.
//

import SwiftUI

struct NoIssueView: View {
    @EnvironmentObject var dataController: DataController
    var body: some View {
        Text("No Issue Selected")
            .font(.title)
            .foregroundStyle(.secondary)
        
        Button("New Issue") {
            // Make new issue 
        }
    }
}

#Preview {
    NoIssueView()
}

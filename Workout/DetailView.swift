//
//  DetailView.swift
//  Workout
//
//  Created by Brandon Johns on 2/14/24.
//

import SwiftUI

struct DetailView: View {
    @EnvironmentObject var dataController: DataController
    
    
    var body: some View {
        VStack {
            
            if let issue = dataController.selectedIssue {
                IssueView(issue: issue)
            } else {
                NoIssueView()
            }
            
        }
        .navigationTitle("Details")
        // inline is according to apples design guidelines 
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    DetailView()
}

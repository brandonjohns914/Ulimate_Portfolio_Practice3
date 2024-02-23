//
//  IssueView.swift
//  Workout
//
//  Created by Brandon Johns on 2/16/24.
//

import SwiftUI

struct IssueView: View {
    @ObservedObject var issue: Issue
    @EnvironmentObject var dataController: DataController
    
    var body: some View {
        Form {
            Section {
                VStack(alignment: .leading) {
                    TextField("Title", text: $issue.issueTitle, prompt: Text("Enter the Issue Title here"))
                        .font(.title)

                    Text("**Modified:** \(issue.issueModificationDate.formatted(date: .long, time: .shortened))")
                        .foregroundStyle(.secondary)
                    
                    Text("**Status:** \(issue.issueStatus)")
                        .foregroundStyle(.secondary)
                }
                Picker("Priority", selection: $issue.priority) {
                    Text("Low").tag(Int16(0))
                    Text("Medium").tag(Int16(1))
                    Text("High").tag(Int16(2))
                }
                
                TagsMenuView(issue: issue)
            }
            
            //This description textfield
            Section {
                VStack(alignment: .leading) {
                    Text("Basic Information")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                    // axis: vertial == type space goes vertical down the screen 
                    TextField("Description", text: $issue.issueContent, prompt: Text("Enter the issue description here"), axis: .vertical)
                }
            }

        }
        .disabled(issue.isDeleted)
        .onReceive(issue.objectWillChange) { _ in
            dataController.queueSave()
        }
        .onSubmit(dataController.save)
        .toolbar {
            IssueViewToolbar(issue: issue)
        }
    }
}

#Preview {
    IssueView(issue: .example)
}

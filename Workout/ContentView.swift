//
//  ContentView.swift
//  Workout
//
//  Created by Brandon Johns on 2/13/24.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var dataController: DataController
    
    var body: some View {
        List(selection: $dataController.selectedIssue) {
            ForEach(dataController.issuesForSelectedFilter()) { issue in
                IssueRow(issue: issue)
            }
            .onDelete(perform: delete)
        }
        .navigationTitle("Issues")
        // potentially need to change depending on types 
        // maybe add tag predicate 
        .searchable(
            text: $dataController.filterText,
            tokens: $dataController.filterTokens,
           suggestedTokens: .constant(dataController.suggestedFilterTokens),
            prompt: "Select a Tag or Write in the Issue Title"
        ) { tag in
                Text(tag.tagName)
        }
        // toolbar to display other tag parts?
        .toolbar {
            Menu {
                Button(dataController.filterEnabled ? "Turn Filter Off" : "Turn Filter On") {
                    dataController.filterEnabled.toggle()
                }

                Divider()

                Menu("Sort By") {
                    Picker("Sort By", selection: $dataController.sortType) {
                        Text("Date Created").tag(SortType.dateCreated)
                        Text("Date Modified").tag(SortType.dateModified)
                    }

                    Divider()

                    Picker("Sort Order", selection: $dataController.sortNewestFirst) {
                        Text("Newest to Oldest").tag(true)
                        Text("Oldest to Newest").tag(false)
                    }
                }

                Picker("Status", selection: $dataController.filterStatus) {
                    Text("All").tag(Status.all)
                    Text("Open").tag(Status.open)
                    Text("Closed").tag(Status.closed)
                }
                .disabled(dataController.filterEnabled == false )

                Picker("Priority", selection: $dataController.filterPriority) {
                    Text("All").tag(-1)
                    Text("Low").tag(0)
                    Text("Medium").tag(1)
                    Text("High").tag(2)
                }
                .disabled(dataController.filterEnabled == false )
            } label: {
                Label("Filter", systemImage: "line.3.horizontal.decrease.circle")
                // this does not work for macOS 
                    .symbolVariant(dataController.filterEnabled ? .fill : .none)

            }
        }
        
       

    }
    
    func delete(_ offsets: IndexSet) {
        let issues = dataController.issuesForSelectedFilter()
        for offset in offsets {
            let item = issues[offset]
            dataController.delete(item)
        }
    }
}

#Preview {
    ContentView()
}

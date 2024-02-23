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
                
                Menu {
                    // show selected tags first
                    ForEach(issue.issueTags) { tag in
                        Button {
                            issue.removeFromTags(tag)
                        } label: {
                            //checkmark does not work in macos
                            Label(tag.tagName, systemImage: "checkmark")
                        }
                    }

                    // show unselected tags
                    let otherTags = dataController.missingTags(from: issue)

                    if otherTags.isEmpty == false {
                        Divider()

                        Section("Add Tags") {
                            ForEach(otherTags) { tag in
                                Button(tag.tagName) {
                                    issue.addToTags(tag)
                                }
                            }
                        }
                    }
                } label: {
                    Text(issue.issueTagsList)
                        .multilineTextAlignment(.leading)
                }
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
            Menu {
                Button {
                    UIPasteboard.general.string = issue.title
                } label: {
                    Label("Copy Issue Title", systemImage: "doc.on.doc")
                }

                Button {
                    issue.completed.toggle()
                    dataController.save()
                } label: {
                    Label(issue.completed ? "Re-open Issue" : "Close Issue", systemImage: "bubble.left.and.exclamationmark.bubble.right")
                }
            } label: {
                Label("Actions", systemImage: "ellipsis.circle")
            }
        }
    }
}

#Preview {
    IssueView(issue: .example)
}

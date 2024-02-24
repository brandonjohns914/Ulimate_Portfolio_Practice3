//
//  TagsMenuView.swift
//  Workout
//
//  Created by Brandon Johns on 2/23/24.
//

import SwiftUI

struct TagsMenuView: View {
    @ObservedObject var issue: Issue
    @EnvironmentObject var dataController: DataController
    var body: some View {
        Menu {
            // show selected tags first
            ForEach(issue.issueTags) { tag in
                Button {
                    issue.removeFromTags(tag)
                } label: {
                    // checkmark does not work in macos
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
                .frame(maxWidth: .infinity, alignment: .leading)
                .animation(nil, value: issue.issueTagsList)
        }
    }
}

#Preview {
    TagsMenuView(issue: .example)
        .environmentObject(DataController(inMemory: true))
}

//
//  UserFilterRow.swift
//  Workout
//
//  Created by Brandon Johns on 2/23/24.
//

import SwiftUI

struct UserFilterRow: View {
    var filter: Filter
    // takes in a filter and returns nothing
    var rename: (Filter) -> Void
    var delete: (Filter) -> Void
    
    var body: some View {
        NavigationLink(value: filter) {
            Label(filter.name, systemImage: filter.icon)
                .badge(filter.activeIssuesCount)
            // pressing is how to change the name
                .contextMenu {
                    Button {
                        rename(filter)
                    } label: {
                        Label("Rename", systemImage: "pencil")
                    }
                    Button(role: .destructive) {
                        delete(filter)
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
                .accessibilityElement()
                .accessibilityLabel(filter.name)
                .accessibilityHint("\(filter.activeIssuesCount) Issues")
        }
    }
}

#Preview {
    UserFilterRow(filter: .all, rename: { _ in }, delete: { _ in })
}

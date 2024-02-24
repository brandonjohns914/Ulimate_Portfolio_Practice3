//
//  SidebarView.swift
//  Workout
//
//  Created by Brandon Johns on 2/14/24.
//

import SwiftUI

struct SidebarView: View {
    @EnvironmentObject var dataController: DataController
    let smartFilters: [Filter] = [.all, .recent]
    @FetchRequest(sortDescriptors: [SortDescriptor(\.name)]) var tags: FetchedResults<Tag>
    @State private var tagToRename: Tag?
    @State private var renamingTag = false
    @State private var tagName = ""
    // this can be converted if there are multiple tags or if each body part has its own entity like tag
    var tagFilters: [Filter] {
        tags.map { tag in
            Filter(id: tag.tagID, name: tag.tagName, icon: "tag", tag: tag)
        }
    }
    var body: some View {
        List(selection: $dataController.selectedFilter) {
            Section("Smart Filters") {
                ForEach(smartFilters, content: SmartFilterRow.init)
            }
            Section("Tags") {
                ForEach(tagFilters) { filter in
                    // rename/delete are the methods
                    UserFilterRow(filter: filter, rename: rename, delete: delete)
                }
                .onDelete(perform: delete)
            }
        }
        .toolbar(content: SidebarViewToolbar.init)
        .alert("Rename Tag", isPresented: $renamingTag) {
            Button("OK", action: completeRename)
            Button("Cancel", role: .cancel) { }
            TextField("New Name", text: $tagName)
        }
        .navigationTitle("Filters")
    }
    func delete(_ offsets: IndexSet) {
        for offset in offsets {
            let item = tags[offset]
            dataController.delete(item)
        }
    }
    func delete(_ filter: Filter) {
        guard let tag = filter.tag else { return }
        dataController.delete(tag)
        dataController.save()
    }
    func rename(_ filter: Filter) {
        tagToRename = filter.tag
        tagName = filter.name
        renamingTag = true
    }
    func completeRename() {
        tagToRename?.name = tagName
        dataController.save()
    }
}

#Preview {
    SidebarView()
        .environmentObject(DataController.preview)
}

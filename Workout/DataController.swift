//
//  DataController.swift
//  Workout
//
//  Created by Brandon Johns on 2/14/24.
//

import CoreData
class DataController: ObservableObject {
    // Loading/Managing/Syncing local data with iCloud
    let container: NSPersistentCloudKitContainer
    
    @Published var selectedFilter: Filter? = Filter.all 
    @Published var selectedIssue: Issue? 
    
    @Published var filterText = "" 
    @Published var filterTokens = [Tag]()
    
    private var saveTask: Task<Void, Error>?
    
    var suggestedFilterTokens: [Tag] {
        
        let trimmedFilterText = String(filterText).trimmingCharacters(in: .whitespaces)
        let request = Tag.fetchRequest()

        if trimmedFilterText.isEmpty == false {
            request.predicate = NSPredicate(format: "name CONTAINS[c] %@", trimmedFilterText)
        }

        return (try? container.viewContext.fetch(request).sorted()) ?? []
    }

    
    
    static var preview: DataController = {
        let dataController = DataController(inMemory: true)
        dataController.createSampleData()
        return dataController
    }()
    
    // When inMemory = true  data is created on disk
    // When inMemory = false data is stored
    init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "Main")
        
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(filePath: "/dev/null")
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        
        container.persistentStoreDescriptions.first?.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
        NotificationCenter.default.addObserver(forName: .NSPersistentStoreRemoteChange, object: container.persistentStoreCoordinator, queue: .main, using: remoteStoreChanged)


        container.loadPersistentStores { storeDescription, error in
            if let error {
                fatalError("Fatal error loading store: \(error.localizedDescription)")
            }
        }
    }
    
    func remoteStoreChanged(_ notification: Notification) {
        objectWillChange.send()
    }

    func createSampleData() {
        let viewContext = container.viewContext

        for indexTag in 1...5 {
            let tag = Tag(context: viewContext)
            tag.id = UUID()
            tag.name = "Tag \(indexTag)"

            for indexIssue in 1...10 {
                let issue = Issue(context: viewContext)
                issue.title = "Exercise \(indexTag) - \(indexIssue)"
                issue.exerciseName = "Exercise Name"
                issue.content = "Exercise Description goes here"
                issue.creationDate = .now
                issue.difficulty = Int16.random(in: 0...10)
                issue.exerciseDate = .now
                issue.repititions = Int16.random(in: 0...20)
                issue.targetRepititions = Int16.random(in: 0...20)
                // comes from coredata automatted classes 
                tag.addToIssues(issue)
            }
        }

        try? viewContext.save()
    }
    ///Only saves Data to persistent storage if values have changed
    func save() {
        if container.viewContext.hasChanges {
            try? container.viewContext.save()
        }
    }
    
    func queueSave() {
        saveTask?.cancel()
        print("queuing save")
        saveTask = Task { @MainActor in
            try await Task.sleep(for: .seconds(3))
            save()
            print("saved")
        }
    }

    
    
    
    
    
    /// Deletes Tags/Issues
    /// Announces to Swift Views that they need to update their views
    func delete(_ object: NSManagedObject) {
        objectWillChange.send()
        container.viewContext.delete(object)
        save()
    }
    
    /// Batch Delete used with createSampleData to delete all Issues and Tags
    private func delete(_ fetchRequest: NSFetchRequest<NSFetchRequestResult>) {
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        batchDeleteRequest.resultType = .resultTypeObjectIDs

        if let delete = try? container.viewContext.execute(batchDeleteRequest) as? NSBatchDeleteResult {
            let changes = [NSDeletedObjectsKey: delete.result as? [NSManagedObjectID] ?? []]
            NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [container.viewContext])
        }
    }
    
    func deleteAll() {
        let request1: NSFetchRequest<NSFetchRequestResult> = Tag.fetchRequest()
           delete(request1)

           let request2: NSFetchRequest<NSFetchRequestResult> = Issue.fetchRequest()
           delete(request2)

           save()
    }
    
    func missingTags(from issue: Issue) -> [Tag] {
        let request = Tag.fetchRequest()
        let allTags = (try? container.viewContext.fetch(request)) ?? []

        let allTagsSet = Set(allTags)
        
        // difference between selected (issueTags) tags
        let difference = allTagsSet.symmetricDifference(issue.issueTags)

        return difference.sorted()
    }

    
    func issuesForSelectedFilter() -> [Issue] {
        let filter = selectedFilter ?? .all
        var predicates = [NSPredicate]()

        if let tag = filter.tag {
            let tagPredicate = NSPredicate(format: "tags CONTAINS %@", tag)
            predicates.append(tagPredicate)
        } else {
            let datePredicate = NSPredicate(format: "modificationDate > %@", filter.minModificationDate as NSDate)
            predicates.append(datePredicate)
        }

        let trimmedFilterText = filterText.trimmingCharacters(in: .whitespaces)

        if trimmedFilterText.isEmpty == false {
            let titlePredicate = NSPredicate(format: "title CONTAINS[c] %@", trimmedFilterText)
            let contentPredicate = NSPredicate(format: "content CONTAINS[c] %@", trimmedFilterText)
            let combinedPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: [titlePredicate, contentPredicate])
            predicates.append(combinedPredicate)
        }
        
        if filterTokens.isEmpty == false {
            let tokenPredicate = NSPredicate(format: "ANY tags IN %@", filterTokens)
            predicates.append(tokenPredicate)
        }
        
        let request = Issue.fetchRequest()
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)

        let allIssues = (try? container.viewContext.fetch(request)) ?? []
        return allIssues
    }
    
    
    
    
    
    
    
    
    
    
    
    
}

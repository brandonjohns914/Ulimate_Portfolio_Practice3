//
//  DataController.swift
//  Workout
//
//  Created by Brandon Johns on 2/14/24.
//

import CoreData
class DataController: ObservableObject {
    /// Loading/Managing/Syncing local data with iCloud
    let container: NSPersistentCloudKitContainer
    
    @Published var selectedFilter: Filter? = Filter.all 
    
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
            // change this to save files to the phone
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
    
}

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
    
    
    // When inMemory = true  data is created on disk
    // When inMemory = false data is stored
    init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "Main")
        
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(filePath: "/dev/null")
        }
        
        container.loadPersistentStores { storeDescription, error in
            if let error {
                fatalError("Fatal error loading store: \(error.localizedDescription)")
            }
        }
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

                tag.addToIssues(issue)
            }
        }

        try? viewContext.save()
    }
    
    func save() {
        if container.viewContext.hasChanges {
            try? container.viewContext.save()
        }
    }
    
    func delete(_ object: NSManagedObject) {
        objectWillChange.send()
        container.viewContext.delete(object)
        save()
    }
    
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

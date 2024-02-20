//
//  Issue-CoreDataHelpers.swift
//  Workout
//
//  Created by Brandon Johns on 2/15/24.
//

import Foundation

extension Issue {
    //Selected Tags 
    var issueTags: [Tag] {
        let result = tags?.allObjects as? [Tag] ?? []
        return result.sorted()
    }
    
    
    var issueTagsList: String {
        guard let tags else { return "No Tags" }
        
        // count== 0 because its an NSSet
        if tags.count == 0 {
            return "No Tags"
        } else {
            // return the selected tags by name 
            return issueTags.map(\.tagName).formatted()
        }
    }

    var issueStatus: String {
        if completed {
            return "Closed"
        } else {
            return "Open"
        }
    }
    
    var issueTitle: String {
        get { title ?? "" }
        set { title = newValue }
    }

    var issueContent: String {
        get { content ?? "" }
        set { content = newValue }
    }

    var issueExerciseName: String {
        get { exerciseName ?? "" }
        set { exerciseName = newValue}
    }
    
    var issueCreationDate: Date {
        creationDate ?? .now
    }

    var issueModificationDate: Date {
        modificationDate ?? .now
    }
    
    static var example: Issue {
        let controller = DataController(inMemory: true)
        let viewContext = controller.container.viewContext
        
        let issue = Issue(context: viewContext)
        issue.title = "Example Issue"
        issue.content = "This is an Example exercise description"
        issue.exerciseName = "This is an example exercise name"
        issue.priority  = 2
        issue.difficulty = 1
        issue.repititions = 10
        issue.targetRepititions = 10
        issue.totalWeight = 50
        issue.weight = 25
        return issue
    }
    
    
}

extension Issue: Comparable {
    public static func <(lhs: Issue, rhs: Issue) -> Bool {
        let left = lhs.issueTitle.localizedLowercase
        let right = rhs.issueTitle.localizedLowercase

        if left == right {
            return lhs.issueCreationDate < rhs.issueCreationDate
        } else {
            return left < right
        }
    }
}

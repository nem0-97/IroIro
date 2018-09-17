//
//  CoreDataNote.swift
//  CIS55Lab2
//
//  Created by Ezhik on 6/16/17.
//  Copyright © 2017 DeAnza. All rights reserved.
//

import UIKit
import CoreData

class CoreDataNote: NSObject {
    //TODO: RENAME EVERYTHING TO NOTE FROM PLACE
    
    static func getTotalNoteCount(appDelegate: AppDelegate) -> Int {
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest : NSFetchRequest<Note> = Note.fetchRequest()
        
        do {
            let fetchedNoteCount = try context.count(for: fetchRequest)
            return fetchedNoteCount
        }
        catch {
            print(error)
            return 0
        }
    }
    
    static func getUntaggedNoteCount(appDelegate: AppDelegate) -> Int {
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest : NSFetchRequest<Note> = Note.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "tags.@count == 0") //THAT @ IS IMPORTANT
        do {
            let fetchedNoteCount = try context.count(for: fetchRequest)
            return fetchedNoteCount
        }
        catch {
            print(error)
            return 0
        }
    }
    
    //just do Tag.notes.count
    /*
    static func getNoteCount(forTag: Tag) -> {
        
    }*/
}

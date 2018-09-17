//
//  CoreDataTag.swift
//  CIS55Lab2
//
//  Created by Ezhik on 6/16/17.
//  Copyright © 2017 DeAnza. All rights reserved.
//

import UIKit
import CoreData

enum noteListCase {
    case all, untagged, tag
}

struct tagCellElement {
    var name : String
    var action : noteListCase
    var count : Int
    var color : UIColor
    var tag : Tag?
}


class CoreDataTag: NSObject {

    static func getTagIfExists(_ tag: String, appDelegate: AppDelegate) -> Tag? {
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest : NSFetchRequest<Tag> = Tag.fetchRequest()
        
        
        //this is apparently how you can filter in core data:
        fetchRequest.predicate = NSPredicate(format: "name == %@", tag)
        do {
            let fetchedTags = try context.fetch(fetchRequest)
            
            //if tag does not exist
            if fetchedTags.count == 0 {
                //we're screwed
                return nil
                //return makeTag(tag, appDelegate: appDelegate)
            }
            else {
                return fetchedTags[0]
            }
        }
        catch {
            print(error)
            return nil
        }
    }
    static func getTag(_ tag: String, appDelegate: AppDelegate) -> Tag? {
        if let newTag = getTagIfExists(tag, appDelegate: appDelegate) {
            return newTag
        }
        else {
            return makeTag(tag, appDelegate: appDelegate)
        }
        
    }
    
    static func makeTag(_ tag: String, appDelegate: AppDelegate) -> Tag? {
        let context = appDelegate.persistentContainer.viewContext
        if let newTag : Tag = NSEntityDescription.insertNewObject(forEntityName: "Tag", into: context) as? Tag {
            newTag.name = tag
            newTag.color = Colors.random()
            //TODO: ADD RANDOM COLOR HERE
            return newTag
        }
        else {
            return nil
        }
    }
    
    static func showTag(_ tag: Tag, storyboard: UIStoryboard, navigationController: UINavigationController) {
        let noteListVC = storyboard.instantiateViewController(withIdentifier: "NotesListView") as! NotesTableViewController
        noteListVC.action = .tag //set it up to show all notes
        noteListVC.tag = tag
        navigationController.pushViewController(noteListVC, animated: true)
    }
    
    
    static func getTags(tags: [String], appDelegate: AppDelegate) -> NSOrderedSet {
        let tagList = NSMutableOrderedSet(capacity: tags.count)
        
        var createdTags = false
            
            let context = appDelegate.persistentContainer.viewContext
            
            for tag in tags {
                let fetchRequest : NSFetchRequest<Tag> = Tag.fetchRequest()
                //this is apparently how you can filter in core data:
                fetchRequest.predicate = NSPredicate(format: "name == %@", tag)
                do {
                    let fetchedTags = try context.fetch(fetchRequest)
                    
                    //if tag does not exist
                    if fetchedTags.count == 0 {
                        
                        if let newTag : Tag = makeTag(tag, appDelegate: appDelegate) {
                            tagList.add(newTag)
                        }
                        createdTags = true
                    }
                        //if tag does exist
                    else {
                        tagList.add(fetchedTags[0]) //there really is not supposed to be more than one at any moment
                    }
                }
                catch {
                    print(error)
                }
            }
            if createdTags == true {
                appDelegate.saveContext()
            }
        return tagList
    }
}

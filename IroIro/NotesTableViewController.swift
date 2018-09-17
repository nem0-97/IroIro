//
//  NotesTableViewController.swift
//  IroIro
//
//  Created by neoman nouiouat on 6/6/17.
//  Copyright © 2017 DeAnza. All rights reserved.
//

import UIKit
import CoreData

class NotesTableViewController: UITableViewController, UISearchResultsUpdating, NSFetchedResultsControllerDelegate {
    //var tag :String! = "all" //when they choose a tag in tag TVC it changes this to the tag name then we use that to decide which notes to show
    
    //select action which we will show
    var action: noteListCase! //handle "all", "untagged", "tag"
    //if we are showing a tag, this will need to be not nil
    var tag: Tag?
    
    var notes: [Note] = []
    
    var searchController: UISearchController!
    var searchResults: [Note] = []
    
    //coredata
    var fetchResultsController : NSFetchedResultsController<Note>!
    
    //this function will exit the tag view if it is empty
    func checkForEmpty() {
        //print("hi this is note list")
        //pop self if tag is gone or empty
        if (action == .tag) {
            if (tag?.managedObjectContext == nil) {
                //print("no tag context")
                self.navigationController?.popToRootViewController(animated: true)
                //self.navigationController?.popViewController(animated: true)
                //self.dismiss(animated: true, completion: nil)
            }
            if (tag?.notes?.count == 0) {
                //print("tag count = 0")
                self.navigationController?.popToRootViewController(animated: true)
                //self.dismiss(animated: true, completion: nil)
            }
            if (notes.count == 0) {
                //print("array empty")
                self.navigationController?.popToRootViewController(animated: true)
                //self.dismiss(animated: true, completion: nil)
            }
        }
        else if (action == .untagged && notes.count == 0) {
            //print("nothing left")
            self.navigationController?.popToRootViewController(animated: true)
            //self.dismiss(animated: true, completion: nil)
        }
        //print("not empty?")
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //self.tableView.reloadData()
        checkForEmpty()
        
        //if we are not exiting, setup UI color.
        if action == .tag {
            Colors.setTintColor(tag?.color as! UIColor)
        } else {
            Colors.setTintColor(Colors.Default)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        searchController.isActive = false
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        //self.tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //coredata
        let fetchRequest : NSFetchRequest<Note> = Note.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "time", ascending: false)
        //let sortDescriptor = NSSortDescriptor(key: "name", ascending: false)

        fetchRequest.sortDescriptors = [sortDescriptor]
        
        //setup showing correct tag
        if (action == .all) {
            self.title = "All Notes"
            hideColorButton()
            //show all
        }
        else if (action == .untagged) {
            self.title = "Untagged"
            hideColorButton()
            fetchRequest.predicate = NSPredicate(format: "tags.@count == 0")
        }
        else if (action == .tag) {
            self.title = "#" + (tag?.name)!
            showColorButton()
            fetchRequest.predicate = NSPredicate(format: "ANY tags.name == %@", (tag?.name)!)
        }
        
        if let appDelegate = (UIApplication.shared.delegate as? AppDelegate) {
            let context = appDelegate.persistentContainer.viewContext
            
            fetchResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
            fetchResultsController.delegate = self
            
            do{
                try fetchResultsController.performFetch()
                if let fetchedObjects = fetchResultsController.fetchedObjects {
                    notes = fetchedObjects
                }
            } catch{
                print(error)
            }
        }
        //endcoredata
        
        //setup tableView colors
        self.view.backgroundColor = UIColor.black
        let bgView = UIView()
        bgView.backgroundColor = UIColor.black
        self.tableView.backgroundView = bgView
        self.tableView.separatorColor = UIColor(hexString: "333333")
        //self.tableView.tableFooterView = bgView
        
        self.searchController = UISearchController(searchResultsController: nil)
        self.searchController.searchBar.sizeToFit()
        self.searchController.hidesNavigationBarDuringPresentation = false
        
        //setup search bar colors
        self.searchController.searchBar.backgroundColor = UIColor.black
        self.searchController.searchBar.barTintColor = UIColor(hexString: "141414")
        let textFieldInsideSearchBar = self.searchController.searchBar.value(forKey: "searchField") as? UITextField
        textFieldInsideSearchBar?.textColor = UIColor.white
        textFieldInsideSearchBar?.backgroundColor = UIColor.black
        
        self.searchController.searchResultsUpdater = self
        self.searchController.dimsBackgroundDuringPresentation = false
        
        self.tableView.tableHeaderView = self.searchController.searchBar

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    //coredata
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            if let newIndexPath = newIndexPath {
                tableView.insertRows(at: [newIndexPath], with: .fade)
            }
        case .delete:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        case .update:
            if let indexPath = indexPath {
                tableView.reloadRows(at: [indexPath], with: .fade)
            }
        default:
            tableView.reloadData()
            
        }
        
        if let fetchedObjects = controller.fetchedObjects {
            notes = fetchedObjects as! [Note]
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    //endcoredata

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: search stuff
    
    func filterContentForSearchText(searchText: String) {
        searchResults = notes.filter({ (note: Note) -> Bool in
            let nameMatch = note.name?.range(of: searchText, options: String.CompareOptions.caseInsensitive)
            let contentMatch = (note.content as! NSAttributedString).string.range(of: searchText, options: String.CompareOptions.caseInsensitive)
            return nameMatch != nil || contentMatch != nil})
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        if let textToSearch = searchController.searchBar.text {
            filterContentForSearchText(searchText: textToSearch)
            tableView.reloadData()
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if searchController.isActive {
            return searchResults.count
        }
        else {
            return notes.count
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "noteCell", for: indexPath) as! NoteCell
        var cellItem: Note
        
        if searchController.isActive {
            cellItem = searchResults[indexPath.row]
        }
        else {
            cellItem = notes[indexPath.row]
        }
        
        //cell.note = cellItem
        
        cell.name.text = cellItem.name
        cell.content.text = (cellItem.content as? NSAttributedString)?.string ?? ""
        cell.time.text = timeAgoSinceDate(date: (cellItem.time as? NSDate) ?? NSDate(), numericDates: false)
        var cellColor: UIColor
        if(action == .tag) {
            cellColor = tag?.color as! UIColor
        }
        else {
            cellColor = ((notes[indexPath.row].tags?.firstObject as? Tag)?.color as? UIColor) ?? UIColor.white
        }
        
        cell.name.textColor = cellColor
        cell.content.textColor = cellColor
        cell.time.textColor = Colors.darker(cellColor)
        cell.tagListView.tagBackgroundColor = Colors.darker(cellColor)
        cell.tagListView.textColor = UIColor.white
        
        cell.tagListView.removeAllTags()
        for tag in cellItem.tags ?? [] {
            cell.tagListView.addTag("#" + ((tag as? Tag)?.name ?? ""))
        }
        
        //cell.setupCell()
        
        //cell.name?.text = cellItem.name
        //cell.content.attributedText = (cellItem.content as! NSAttributedString)
        //cell.time.text = String (cellItem.time)
        
        return cell
    }


    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return !(searchController.isActive)
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            //tableView.deleteRows(at: [indexPath], with: .fade)
            if let appDelegate = (UIApplication.shared.delegate as? AppDelegate) {
                var itemToDelete : Note
                
                let context = appDelegate.persistentContainer.viewContext
                /*
                 if searchController.isActive {
                 itemToDelete = searchResults[indexPath.row]
                 searchResults.remove(at: indexPath.row)
                 print("deleted: " + itemToDelete.name!)
                 
                 }*/
                //else {
                itemToDelete = self.fetchResultsController.object(at: indexPath)
                //}
                //print("doing the delete")
                context.delete(itemToDelete)
                
                //print("saving context")
                appDelegate.saveContext()
                
                //print("saved context")
                //updateSearchResults(for: searchController)
                //tableView.reloadData()
                
                //exit if empty now
                checkForEmpty()
            }
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "ShowNote") {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let noteVC = segue.destination as! NoteViewController
                if searchController.isActive {
                    noteVC.note = searchResults[indexPath.row]
                }
                else {
                    noteVC.note = notes[indexPath.row]
                }
            }
        }
        else if (segue.identifier == "NewNote") {
            
            print("we'll show you a new note view!")
            let noteVC = segue.destination as! NoteViewController
            if let appDelegate = (UIApplication.shared.delegate as? AppDelegate) {
                let context = appDelegate.persistentContainer.viewContext
                
                let note = Note(context: context)
                
                //print("This new note is empty!")
                note.name = ""
                //print(note.name!)
                
                note.content = NSAttributedString(string: " ", attributes: [NSAttributedStringKey.font: UIFont(name: "Helvetica", size: 14) as Any])
                //print((note.content as! NSAttributedString).string)
                note.time = NSDate()
                //note.addToTags(CoreDataTag.getTag("test", appDelegate: appDelegate)!)
                //note.addToTags(CoreDataTag.getTag("yahallo", appDelegate: appDelegate)!)
                
                if (action == .tag) {
                    note.addToTags(tag!)
                }
                
                //print(CoreDataNote.getTotalNoteCount(appDelegate: appDelegate))
                appDelegate.saveContext()
                
                noteVC.note = note
                noteVC.isNewNote = true
                print("And now we are off!!")
            }
        }
        searchController.isActive = false
    }

    
    //TODO: CALL FUNCTIONS WHEN COLOR BUTTON NEEDS TO BE HIDDEN/SHOWN
    //(no color on all notes/untagged)
    func hideColorButton() {
        self.navigationItem.rightBarButtonItems = [AddButton]
    }
    func showColorButton() {
        self.navigationItem.rightBarButtonItems = [AddButton, ColorButton]
    }
    
    //temp
    var colorIsShown : Bool = true
    
    @IBOutlet var AddButton: UIBarButtonItem!
    @IBAction func AddButtonPress(_ sender: Any) {
        
        //temp
        if colorIsShown == true {
            colorIsShown = false
            hideColorButton()
        } else {
            colorIsShown = true
            showColorButton()
        }
    }
    
    func setColor(color: UIColor) {
        //TODO: ADJUST THE TAG COLOR HERE.
        //print(color)
        tag?.color = color
        Colors.setTintColor(color)
        tableView.reloadData()
    }
    
    var colorPopup : ColorPopup!
    
    @IBOutlet var ColorButton: UIBarButtonItem!
    @IBAction func ColorButtonPress(_ sender: Any) {
        colorPopup = ColorPopup(callback: setColor(color:))
    }
    

}

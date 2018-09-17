//
//  TagsTableViewController.swift
//  IroIro
//
//  Created by neoman nouiouat on 6/6/17.
//  Copyright © 2017 DeAnza. All rights reserved.
//

import UIKit
import CoreData

class TagsTableViewController: UITableViewController, UISearchResultsUpdating {
    
    //var tags:[Tag] = []
    //Because we will need to show two extra elements and handle tag cleanup here, i am not using the fetch results controller, and the array we use will be of a different type than Tag
    var tagsArray: [tagCellElement] = []
    
    var searchController : UISearchController!
    var searchResults: [tagCellElement] = []

    //coredata
    //var fetchResultsController : NSFetchedResultsController<Tag>!

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //change color back to the system one
        Colors.setTintColor(Colors.Default)
        
        //re-setup the array every time we come back to the tags view
        setupTagsList()
        
        //print("We finished that function")
        
    }
    
    //close the searchbar when the view is no longer visible
    override func viewDidDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        searchController.isActive = false
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        

        /*
        //coredata
        let fetchRequest : NSFetchRequest<Tag> = Tag.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        if let appDelegate = (UIApplication.shared.delegate as? AppDelegate) {
            let context = appDelegate.persistentContainer.viewContext
            fetchResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
            fetchResultsController.delegate = self
            
            do{
                try fetchResultsController.performFetch()
                if let fetchedObjects = fetchResultsController.fetchedObjects {
                    tags = fetchedObjects
                }
            } catch{
                print(error)
            }
        }
        //coredataend
         */
        
        //THIS IS IMPORTANT
        //With this, even though the tags list is the first view, when the app starts, it will load the list of all notes.
        //TODO: ENSURE THAT IT LOADS THE ALL NOTES VIEW AND NOT A TAG VIEW
        let noteListVC = self.storyboard?.instantiateViewController(withIdentifier: "NotesListView") as! NotesTableViewController
        noteListVC.action = .all //set it up to show all notes
        self.navigationController?.pushViewController(noteListVC, animated: false)
        
        
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
    
    func setupTagsList() {
        //clear the array for upcoming evils
        tagsArray = []
        //print("time to get to work")
        
        if let appDelegate = (UIApplication.shared.delegate as? AppDelegate) {
            let context = appDelegate.persistentContainer.viewContext
            
            //first append the all notes item
            tagsArray.append(tagCellElement(name: "All Notes", action: .all, count: CoreDataNote.getTotalNoteCount(appDelegate: appDelegate), color: UIColor.white, tag: nil))
            
            //next find if there are any untagged notes, if there are, append the item
            let untaggedCount = CoreDataNote.getUntaggedNoteCount(appDelegate: appDelegate)
            //print("Untagged: " + String(untaggedCount))
            if untaggedCount > 0 {
                tagsArray.append(tagCellElement(name: "Untagged", action: .untagged, count: CoreDataNote.getUntaggedNoteCount(appDelegate: appDelegate), color: UIColor.white, tag: nil))
            }
            
            //setup core data fetch request
            let fetchRequest : NSFetchRequest<Tag> = Tag.fetchRequest()
            do {
                //get all tags
                let fetchedTags = try context.fetch(fetchRequest)
                //sort by note count in tag
                let sortedTags = fetchedTags.sorted(by: {
                    ($0.notes?.count)! > ($1.notes?.count)! //descending order
                })
                //print("tags fetched: " + String(sortedTags.count))
                
                //now that we have sorted tags, deal with them
                for tag in sortedTags {
                    if (tag.notes?.count != 0) { //only show tag if it has notes
                        tagsArray.append(tagCellElement(name: "#" + tag.name!, action: .tag, count: (tag.notes?.count)!, color: tag.color as! UIColor, tag: tag))
                    }
                    else {
                        context.delete(tag) //delete tag if there are no notes in it
                    }
                }
                //print("we're done with tags")
            }
            catch {
                print(error)
            }
            tableView.reloadData()
        }
    }

    /*
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    //coredataend*/

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //MARK: search stuff
    
    func filterContentForSearchText(searchText: String) { //not sure why it gives error here
        searchResults = tagsArray.filter({(tagCellItem: tagCellElement)->Bool in
            //only search tags
            if (tagCellItem.action != .tag) {
                return false
            }
            else {
                let match = tagCellItem.name.range(of: searchText, options: String.CompareOptions.caseInsensitive)
                return match != nil
            }
        })
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
        //print("get cell count")
        if searchController.isActive {
            return searchResults.count
        }
        else {
            return tagsArray.count
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tagCell", for: indexPath) as! TagCell
        var cellItem: tagCellElement

        if searchController.isActive {
            cellItem = searchResults[indexPath.row]
        }
        else {
             cellItem = tagsArray[indexPath.row]
        }
        //print("assigning stuff to cell...")
        //print("cell name: " + cellItem.name)
        cell.name?.text = cellItem.name
    
        cell.color = cellItem.color
        //print(" cell count: " + cell)
        cell.count.text = String(describing: cellItem.count) + " note"
        if cellItem.count != 1 {
            cell.count.text! += "s"
        }
        //print("setting up cell")
        cell.setupCell()
        //print("we made a cell")
        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */
    
    //Tags list does not have editing - delete all notes with a tag to get rid of it
    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete { //still need to add in deleting it from core data
            // Delete the row from the data source
            if searchController.isActive{
                searchResults.remove(at: indexPath.row) //not really necessary but will let them skim down on search results they find as clutter
            }
            else{
                tags.remove(at: indexPath.row)
               
            }
            
            self.tableView.deleteRows(at: [indexPath], with: .fade)
            self.tableView.reloadData()
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }*/

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
        if (segue.identifier == "showTaggedNotes") {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let noteListVC = segue.destination as! NotesTableViewController
                if searchController.isActive {
                   // noteVC.tag = searchResults[indexPath.row].name
                    noteListVC.action = searchResults[indexPath.row].action
                    noteListVC.tag = searchResults[indexPath.row].tag
                }
                else {
                    noteListVC.action = tagsArray[indexPath.row].action
                    noteListVC.tag = tagsArray[indexPath.row].tag
                }
            }
        }
    }


}

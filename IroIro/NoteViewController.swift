//
//  NoteViewController.swift
//  IroIro
//
//  Created by Ezhik
//  Copyright © 2017 DeAnza. All rights reserved.
//

import UIKit

class NoteViewController: UIViewController, TagListViewDelegate, UITextFieldDelegate, UITextViewDelegate, UIScrollViewDelegate  {
    
    var note: Note!
    
    @IBOutlet var NoteTitle: UITextField!
    
    @IBOutlet var NoteContent: UITextView!
    var noteOriginal : NSAttributedString!
    
    //state of note
    var NoteIsEdited : Bool = false
    
    //if new note
    var isNewNote: Bool = false
    
    //tag list and tag input
    @IBOutlet var tagList: TagListView!
    @IBOutlet var tagInput: UITextField!

    
    func setTintColor() {
        if (note.tags?.count)! > 0 {
            Colors.setTintColor((note.tags?.firstObject as! Tag).color as! UIColor)
        } else {
            Colors.setTintColor(Colors.Default)
        }
    }


    
    //this function will exit the tag view if it is empty
    func checkForEmpty() {
        //pop self if note is gone
        if (note == nil || note.managedObjectContext == nil) {
            //print("no note context")
            self.navigationController?.popViewController(animated: true)
            //print("we are gone bye")
            //self.dismiss(animated: true, completion: nil)
        }
    }
    
    
    //setup keyboard notifications
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //print("hi this is note view")
        registerKeyboardNotifications()
        checkForEmpty()
        loadData()
        if (isNewNote == false) {
            //you want the note
            let oldTime = note.time
            disableEditing()
            note.time = oldTime
        }
        else {
            enableEditing()
            NoteTitle.becomeFirstResponder()
            isNewNote = false
        }
        setTintColor()

    }
    override func viewDidAppear(_ animated: Bool) {

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unregisterKeyboardNotifications()
        if (note.managedObjectContext != nil) {
            if isEditing == true {
                disableEditing()
            }
            saveData()
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            //let backItem = UIBarButtonItem()
            //backItem.title = note.name
            //navigationItem.backBarButtonItem = backItem // this will show in the next view controller being pushed
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        //print("Welcome to the Note View")

        //handle note edit start
        NoteTitle.delegate = self
        
        //NoteTitle.attributedPlaceholder = NSAttributedString(string: "Note title", attributes: <#T##[String : Any]?#>)
        
        //allow editing note content
        NoteContent.allowsEditingTextAttributes = true
        NoteContent.delegate = self
        
        //setup tag list
        //tagList.delegate = self
        tagList.selectedBorderColor = UIColor.red //red border for deletion
        
        //setup tag text field
        tagInput.delegate = self
        tagInput.isHidden = true
    
        //setup scroll view
        scrollView.delegate = self
        
        //loadData()
        
        //detect taps on note content
        let TapGestureRecognizer : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.tappedTag(sender:)))
        NoteContent.addGestureRecognizer(TapGestureRecognizer)

    }
    
    func saveData() {
        if let appDelegate = (UIApplication.shared.delegate as? AppDelegate) {
            note.name = NoteTitle.text
            note.content = noteOriginal
            //note.time = NSDate()
            //tags kinda do their own thing tbh
            appDelegate.saveContext()
        }
    }
    
    func loadData() {
        //setup white text
        let whiteNote : NSMutableAttributedString = NSMutableAttributedString()
        whiteNote.append(note.content as! NSAttributedString)
        whiteNote.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.white, range: NSMakeRange(0, whiteNote.string.count))
        //print("made a note")
        //save original note content
        NoteContent.attributedText = whiteNote
        //print("changed the text")
        noteOriginal = NoteContent.attributedText
        
        NoteTitle.text = note.name
        //print("got a title")
        
        setupTags()
    }
    
    func setupTags() {
        tagList.removeAllTags() //redo tags
        
        for tag in note.tags! {
            _ = addTagView(tag as! Tag)
        }
        //plus button in the tags
        let plusTag = tagList.addTag("+")
        
        plusTag.onTap =
            { void in
                //print("pls tag")
                self.toggleTagMode()
                //self.addNewTag()
        }
        plusTag.onLongPress = nil
    }
    
    func addTagView(_ tag: Tag) -> TagView {
        let tagView = tagList.addTag("#" + tag.name!)
        tagView.selectedBackgroundColor = (tag.color as! UIColor)
        tagView.highlightedBackgroundColor = (tag.color as! UIColor)
        tagView.backgroundColor = (tag.color as! UIColor)
        
        tagView.onTap = { void in
            tagView.selectedBackgroundColor = (tag.color as! UIColor)
            tagView.highlightedBackgroundColor = (tag.color as! UIColor)
            tagView.backgroundColor = (tag.color as! UIColor)
            CoreDataTag.showTag(tag, storyboard: self.storyboard!, navigationController: self.navigationController!)
        }
        tagView.onLongPress = { void in
            tagView.selectedBackgroundColor = (tag.color as! UIColor)
            tagView.highlightedBackgroundColor = (tag.color as! UIColor)
            tagView.backgroundColor = (tag.color as! UIColor)
            self.noteTagLongPress(tag: tag, tagView: tagView)
        }
        return tagView
    }
    
    func insertTagView(_ tag: Tag, at: Int) -> TagView {
        let tagView = tagList.insertTag("#" + tag.name!, at: at)
        tagView.backgroundColor = (tag.color as! UIColor)
        tagView.onTap = { void in
            tagView.selectedBackgroundColor = (tag.color as! UIColor)
            tagView.highlightedBackgroundColor = (tag.color as! UIColor)
            tagView.backgroundColor = (tag.color as! UIColor)
            CoreDataTag.showTag(tag, storyboard: self.storyboard!, navigationController: self.navigationController!)
        }
        tagView.onLongPress = { void in
            tagView.selectedBackgroundColor = (tag.color as! UIColor)
            tagView.highlightedBackgroundColor = (tag.color as! UIColor)
            tagView.backgroundColor = (tag.color as! UIColor)
            self.noteTagLongPress(tag: tag, tagView: tagView)
        }
        return tagView
    }
    
    func noteTagLongPress(tag: Tag, tagView: TagView) {
        //print("Tag pressed: \(tag.name!)")
        //tagView.isSelected = false
        /*
        if (NoteIsEdited == false) {
            return
        }
         */
        
        // Create the AlertController and add its actions like button in ActionSheet
        let actionSheetController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let cancelActionButton = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in
            //print("Cancel")
        }
        actionSheetController.addAction(cancelActionButton)
        
        let saveActionButton = UIAlertAction(title: "Make tag first", style: .default) { action -> Void in
            //print("1st")
            
            //sender.insertTagView(tagView.copy() as! TagView, at: 0)
            
            //let newTag = sender.insertTag(title, at: 0)
            
            //var swiftStringsAreAnnoying = title
            //swiftStringsAreAnnoying.remove(at: swiftStringsAreAnnoying.startIndex)
            
            //newTag.tagBackgroundColor =  self.getTagByName(swiftStringsAreAnnoying).color as! UIColor
            //newTag.selectedBackgroundColor = UIColor.red
            
            //handle DB first
            self.note.removeFromTags(tag)
            self.note.insertIntoTags(tag, at: 0)
            
            //then displayed tags
            self.tagList.removeTagView(tagView)
            _ = self.insertTagView(tag, at: 0)
            //self.tagList.insertTagView(noteTag, at: 0)
            
            self.setTintColor()
            
            self.note.time = NSDate()
            
            self.saveData()
            //UIApplication.shared.delegate.window.tintColor = newTag.tagBackgroundColor
            
            
            //sender.removeTagView(tagView)
        }
        actionSheetController.addAction(saveActionButton)
        
        let deleteActionButton = UIAlertAction(title: "Delete tag", style: .destructive) { action -> Void in
            //print("Delete")
            
            //sender.removeTagView(tagView)
            
            self.note.removeFromTags(tag)
            
            self.tagList.removeTagView(tagView)
            
            self.setTintColor()
            
            self.note.time = NSDate()

            self.saveData()
        }
        actionSheetController.addAction(deleteActionButton)
        
        //avoid db calls? idk lol
        //let firstTagColor = tagList.tagViews[0].backgroundColor
        
        actionSheetController.view.tintColor = Colors.darker(self.view.tintColor)
        
        self.present(actionSheetController, animated: true, completion: nil)
        
        //Stocks app is dark but has a bright sheet
        //actionSheetController.view.tintColor = UIColor.black
    }
    

    
    func toggleEditMode() {
        
        if NoteIsEdited == false {
            enableEditing()
        }
        else {
            disableEditing()
        }
        
    }
    
    
    //DISABLE EDIT MODE
    func disableEditing() {
        NoteIsEdited = false
        
        note.time = NSDate()
        
    UIApplication.shared.sendAction(#selector(UIApplication.resignFirstResponder), to: nil, from: nil, for: nil);
        
        //NoteTitle.isEnabled = false
        NoteContent.isEditable = false
        
        
        AddHashtagAttributes()
        
        //DoneButton.title = "Edit"
        self.navigationItem.rightBarButtonItems = []
        self.navigationItem.rightBarButtonItem = DeleteButton
        
        if(tagList.tagViews.count == 1) {
            UIView.animate(withDuration: 0.25, animations: {
                self.tagList.isHidden = true
            })
        }
        
        //hide (+)
        let plusTag = tagList.tagViews[tagList.tagViews.count - 1]
        let animationSpeed = 0.25
        UIView.animate(withDuration: animationSpeed, animations: {
            plusTag.alpha = 0.0 //fade out the (+)
        }, completion: { void in
            plusTag.isHidden = true //then hide (+) for real
        })
    }
    
    //ENABLE EDIT MODE
    func enableEditing() {
        NoteIsEdited = true
        note.time = NSDate()
        
        
        //NoteTitle.isEnabled = true
        NoteContent.isEditable = true
        
        NoteContent.attributedText = noteOriginal
        
        //DoneButton.title = "Done"
        
        self.navigationItem.rightBarButtonItems = []
        self.navigationItem.rightBarButtonItem = DoneButton
        
        if(tagList.tagViews.count == 1) {
            UIView.animate(withDuration: 0.25, animations: {
                self.tagList.isHidden = false
            })
        }
        
        //show (+)
        let plusTag = tagList.tagViews[tagList.tagViews.count - 1]
        let animationSpeed = 0.25
        plusTag.isHidden = false //unhide the (+)
        UIView.animate(withDuration: animationSpeed, animations: {
            plusTag.alpha = 1.0 //then fade in the (+)
        })
    }
    
    func addNewTag(_ tagText : String) {
        //tagList.addTag(tagInput.text!)
        if tagText == "" {
            return
        }
        
        for tag in tagList.tagViews {
            if tag.currentTitle == "#" + tagText {
                return
            }
        }
        
        var tagLocation = tagList.tagViews.count - 1
        
        if tagLocation < 0 {
            tagLocation = 0
        }
        
        //print("tagloc: " + String(tagLocation))
        
        if let appDelegate = (UIApplication.shared.delegate as? AppDelegate) {
            let tag = CoreDataTag.getTag(tagText, appDelegate: appDelegate)
            
            note.addToTags(tag!)
            
            _ = insertTagView(tag!, at: tagLocation)//tagList.insertTag("#" + tagText, at: tagLocation)
            //newTag.tagBackgroundColor = tag?.color as! UIColor
            
            //waste some time
            setTintColor()
        }
        //newTag.selectedBorderColor = UIColor.red
        //newTag.selectedTextColor = UIColor.red
        //newTag.selectedBackgroundColor = UIColor.red
        
        
        //clear input box
        tagInput.text = ""
    }
    
    //Navigation Bar Buttons
    @IBOutlet var  DoneButton: UIBarButtonItem!
    //var DoneButtonSave: UIBarButtonItem!
    @IBAction func DoneButtonPress(_ sender: Any) {
        //DoneButton.isEnabled = false
        //print("show tags")
        disableEditing()
        saveData()
        //AddHashtagAttributes()
    }
    
    @IBOutlet var DeleteButton: UIBarButtonItem!
    
    @IBAction func DeleteButtonPress(_ sender: Any) {
        if (NoteIsEdited == true) {
            return
        }
        
        // Create the AlertController and add its actions like button in ActionSheet
        let actionSheetController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let cancelActionButton = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in
           //print("Cancel")
        }
        actionSheetController.addAction(cancelActionButton)
        
        let deleteActionButton = UIAlertAction(title: "Delete", style: .destructive) { action -> Void in
            //print("Delete")
            if let appDelegate = (UIApplication.shared.delegate as? AppDelegate) {                
                let context = appDelegate.persistentContainer.viewContext
                //print("doing the delete")
                context.delete(self.note)
                
                //print("saving context")
                appDelegate.saveContext()
                
                //print("saved context")
                //updateSearchResults(for: searchController)
                //tableView.reloadData()
                
                //exit if empty now
                self.navigationController?.popViewController(animated: true)
            }
        }
        actionSheetController.addAction(deleteActionButton)
        
        //avoid db calls? idk lol
        let firstTagColor = tagList.tagViews[0].backgroundColor
        
        actionSheetController.view.tintColor = Colors.darker(firstTagColor!)
        
        self.present(actionSheetController, animated: true, completion: nil)
        
        //Stocks app is dark but has a bright sheet
        //actionSheetController.view.tintColor = UIColor.black
    }
    
    
    

    //show and hide the tag add field
    func toggleTagMode() {
        let plusTag = tagList.tagViews[tagList.tagViews.count - 1]
        
        let animationSpeed = 0.25
        
        //(+) visible, text field not visible
        if tagInput.isHidden == true {
            UIView.animate(withDuration: animationSpeed, animations: {
                self.tagInput.isHidden = false //show the text field
                plusTag.alpha = 0.0 //and fade out the (+)
            }, completion: { void in
                plusTag.isHidden = true //then hide (+) for real
            })
            
            self.tagInput.setBottomBorder(borderColor: UIColor(hexString: "333333"))
            tagInput.becomeFirstResponder()
        }
            //(+) not visible, text field visible
        else { //
            plusTag.isHidden = false //unhide the (+)
            
            UIView.animate(withDuration: animationSpeed, animations: {
                plusTag.alpha = 1.0 //then fade in the (+)
                self.tagInput.isHidden = true //hide the text field
            })
            
            addNewTag(tagInput.text!)
        }
        
        clearTagSelection() //clear tags
    }
    
    func AddHashtagAttributes() {
        noteOriginal = NoteContent.attributedText
        
        if let appDelegate = (UIApplication.shared.delegate as? AppDelegate) {
            let content : NSMutableAttributedString = NSMutableAttributedString()
            content.append(NoteContent.attributedText)
            //(NoteContent.attributedText)

            for range in HashtagParser.getRanges(content.string) {
                
                let tagString = content.string.substring(with: range.tagRange)
            
                //print(tagString)
                addNewTag(tagString)
        }
        
            NoteContent.attributedText = content
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    
    //HANDLE TAG EDIT AND NAME EDIT
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == NoteTitle {
            enableEditing()
        }
        return true
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == NoteTitle {
            NoteContent.becomeFirstResponder()
            NoteContent.selectedRange = NSMakeRange(0, 0)
        }
        else
        {
            addNewTag(tagInput.text!)
            
            //deselect tags
            clearTagSelection()
        }
        return false
    }

    @IBAction func tagInputDone(_ sender: Any) {
        
        toggleTagMode()
        //toggleEditMode()
        //addNewTag(tagInput.text!)
        //tagList.addTag(tagInput.text!)
    }
        
    
    //DESELECT TAGS HERE
    func clearTagSelection() {
        if tagList.tagViews.count > 1 && tagList.tagViews[tagList.tagViews.count-2].isSelected == true {
            tagList.tagViews[tagList.tagViews.count-2].isSelected = false
            tagList.tagViews[tagList.tagViews.count-2].borderWidth = 0.0
        }
        /*for tag in tagList.tagViews {
         tag.isSelected = false
         }*/
    }
    
    //HANDLE BACKSPACE IN TAG EDIT
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        /*
         if (string == " " || string == ",") /*&& textField.text != "" */ {
         addNewTag(tagInput.text!)
         
         clearTagSelection()
         return true
         }*/
        
        //https://stackoverflow.com/questions/29504304/
        let char = string.cString(using: String.Encoding.utf8)!
        let isBackspace = strcmp(char, "\\b")
        
        if (isBackspace == -92 && textField.text == "" && tagList.tagViews.count > 1) {
            if (tagList.tagViews[tagList.tagViews.count-2].isSelected == true) {
                tagList.removeTagView(tagList.tagViews[tagList.tagViews.count-2])
                note.removeFromTags(note.tags?.lastObject as! Tag)
                setTintColor()
            }
            else {
                tagList.tagViews[tagList.tagViews.count-2].borderWidth = 3.0
                tagList.tagViews[tagList.tagViews.count-2].isSelected = true
            }
        }
        else {
            clearTagSelection()
        }
        
        return true
        
    }
    
    //HANDLE TAPS ON THE NOTE CONTENT
    @objc func tappedTag(sender: UITapGestureRecognizer) {
        // first: extract the sender view
        guard case let senderView = sender.view, (senderView is UITextView) else {
            return
        }
        
        // calculate layout manager touch location
        let textView = senderView as! UITextView, // we sure this is an UITextView, so force casting it
        layoutManager = textView.layoutManager
        
        var location = sender.location(in: textView)
        location.x -= textView.textContainerInset.left
        location.y -= textView.textContainerInset.top
        
        // find the value
        let textContainer = textView.textContainer,
        characterIndex = layoutManager.characterIndex(for: location, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil),
        textStorage = textView.textStorage
        
        guard characterIndex < textStorage.length else {
            return
        }
        
        var range = NSRange()
        
        //look it's 6:06 am, i can nest a little
        if let tagName = textStorage.attribute(NSAttributedStringKey(rawValue: "IroIroTag"),
                                         at: characterIndex,
                                         effectiveRange: &range) {
            if let appDelegate = (UIApplication.shared.delegate as? AppDelegate) {
                if let tag = CoreDataTag.getTagIfExists(tagName as! String, appDelegate: appDelegate) {
                        //let tag = (textView.text! as NSString).substring(with: range)
                        //print("tag tap")
                        CoreDataTag.showTag(tag, storyboard: self.storyboard!, navigationController: self.navigationController!)
                        //print(tag)
                        //goToTag(tag)
                        // do something...
                }
            }
        }
        else {
            //print("Random tap")
            if (NoteIsEdited == false) {
                enableEditing()
                //print(characterIndex)
                textView.becomeFirstResponder()
                textView.selectedRange = NSMakeRange(characterIndex, 0)
                //let newPosition =
                //let newPosition = textView.textRange(from: characterIndex...characterIndex, to: characterIndex...characterIndex)
                //textView.selectedTextRange = newPosition
            }
        }
    }
    
    //HANDLE KEYBOARD AND SCROLL VIEW
    //https://stackoverflow.com/questions/13161666/
    @IBOutlet var scrollView: UIScrollView!
    
    func registerKeyboardNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(NoteViewController.keyboardDidShow(notification:)),
                                               name: NSNotification.Name.UIKeyboardDidShow,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(NoteViewController.keyboardWillHide(notification:)),
                                               name: NSNotification.Name.UIKeyboardWillHide,
                                               object: nil)
    }
    
    func unregisterKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func keyboardDidShow(notification: NSNotification) {
        let userInfo: NSDictionary = notification.userInfo! as NSDictionary
        let keyboardInfo = userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue
        let keyboardSize = keyboardInfo.cgRectValue.size
        let contentInsets = UIEdgeInsets(top: scrollView.contentInset.top, left: scrollView.contentInset.left, bottom: keyboardSize.height + scrollView.contentInset.top, right: scrollView.contentInset.right)
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        //UIEdgeInserts.zero
        scrollView.contentInset = UIEdgeInsets(top: scrollView.contentInset.top, left: scrollView.contentInset.left, bottom: 0, right: scrollView.contentInset.left)
        scrollView.scrollIndicatorInsets = scrollView.contentInset
    }
    
    //SHOW NOTE TITLE IN NAVIGATION BAR ON SCROLL
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //print(scrollView.contentOffset.y)
        
        //let fadeTextAnimation = CATransition()
        //fadeTextAnimation.duration = 0.5
        //fadeTextAnimation.type = kCATransitionFade
        //navigationController?.navigationBar.layer.add(fadeTextAnimation, forKey: "fadeText")
        
        //navigationItem.title = "test 123"
        if scrollView.contentOffset.y > (48 - scrollView.contentInset.top) {
            
            self.title = NoteTitle.text
        }
        else {
            self.title = ""
        }
    }

}

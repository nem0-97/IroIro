//
//  NoteCell.swift
//  IroIro
//
//  Created by neoman nouiouat on 6/6/17.
//  Copyright © 2017 DeAnza. All rights reserved.
//

import UIKit

class NoteCell: UITableViewCell {

    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var content: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var tagListView: TagListView!
    
    var noteColor: UIColor?
    //var note: Note!
    
    override func awakeFromNib() {
        super.awakeFromNib()

    }
    
    /*
    func setupCell() {
        //var noteColor: UIColor

        name.text = note.name ?? ""
        content.text = (note.content as! NSAttributedString).string
        time.text = timeAgoSinceDate(date: note.time as! NSDate, numericDates: false)
        
        tagListView.removeAllTags()
        
        if let noteTags = note.tags {
            if noteColor == nil {
                if noteTags.count == 0 {
                    noteColor = UIColor.white
                } else {
                    noteColor = ((noteTags.firstObject as! Tag).color as! UIColor)
                    print((noteTags.firstObject as! Tag).name)
                }
            }
            name.textColor = noteColor
            print(name.textColor)
            content.textColor = noteColor
            print(content.textColor)
            time.textColor = Colors.darker(noteColor!)
            print(time.textColor)
            
            tagListView.tagBackgroundColor = Colors.darker(noteColor!)
            tagListView.textColor = UIColor.white
            
            if noteTags.count != 0 {
                print((note.tags?.firstObject as! Tag).color as! UIColor)
            }
            //print("apparently there are tags")
            print(noteTags.count)
            for tag in noteTags {
                tagListView.addTag("#" + ((tag as! Tag).name!))
                //print(tagView.currentTitle)
                //tagView.backgroundColor = Colors.darker(noteColor)
                //tagView.textColor = UIColor.white
            }
        }
    }
 */
    
    //Note.content! as NSAttributedString

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

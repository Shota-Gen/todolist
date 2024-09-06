
//
//  DisplayNoteViewController.swift
//  MakeSchoolNotes
//
//  Created by Chris Orcutt on 1/10/16.
//  Copyright © 2016 MakeSchool. All rights reserved.
//

import UIKit
import Foundation

class DisplayToDoViewController: UIViewController, DeadlineViewControllerDelegate {
    
    var toDo: ToDo?
    
    @IBOutlet weak var popUpDisplay: UIView!
    @IBOutlet weak var whatToDo: UITextField!
    @IBOutlet weak var incompletion: UITextField!
    @IBOutlet weak var deadline: UITextField!
    @IBOutlet weak var created: UILabel!
    @IBOutlet weak var createdLabel: UILabel!
    @IBOutlet var checkBox: UIButton!
    
    let checkedBox = UIImage(named: "Checked_Box")
    let emptyBox = UIImage(named: "Empty_Box")
    
    var listToDoDelegate: ListToDoTableViewControllerDelegate?
   
    
    var deadlineTime = ""
    var day = 0
    var month = 0
    var year = 0
    let todayMonth = Calendar.current.component(.month, from: Date())
    let todayDate = Calendar.current.component(.day, from: Date())
    let todayYear = Calendar.current.component(.year, from: Date())
    
    var maybeCheckedBox = false
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        popUpDisplay.layer.cornerRadius = 20
        if let toDo = toDo {
            whatToDo.text = toDo.goal
            incompletion.text = toDo.punishment
            createdLabel.text = "Created:"
            created.text = toDo.created?.convertToString() ?? "unknown"
            deadline.text = toDo.deadline
            if toDo.checkBox == false {
                checkBox.setImage(emptyBox, for: UIControlState.normal)
            } else if toDo.checkBox == true {
                checkBox.setImage(checkedBox, for: UIControlState.normal)
            }
        } else {
            whatToDo.text = ""
            incompletion.text = ""
            created.text = ""
            createdLabel.text = ""
            deadline.text = ""
            checkBox.setImage(emptyBox, for: UIControlState.normal)
        }
        
        
    }

    @IBAction func cancelTapped(_ sender: Any) {
        
        listToDoDelegate?.updatetoDos()
        
        dismiss(animated: true, completion: nil)
        
        
    }
    
    
    
    @IBAction func saveTapped(_ sender: Any) {
        
        
        if toDo != nil {
            toDo?.goal = whatToDo.text ?? ""
            toDo?.punishment = incompletion.text ?? ""
            toDo?.deadline = deadline.text ?? ""
            if checkBox.image(for: UIControlState.normal) == emptyBox {
                toDo?.checkBox = false
            } else if checkBox.image(for: UIControlState.normal) == checkedBox {
                toDo?.checkBox = true
            }
            
            
            CoreDataHelper.savetoDo()
        } else if toDo == nil {
            let newToDo = CoreDataHelper.newtoDo()
            newToDo.goal = whatToDo.text ?? ""
            newToDo.punishment = incompletion.text ?? ""
            newToDo.created = Date()
            newToDo.deadline = deadlineTime
            if checkBox.image(for: UIControlState.normal) == emptyBox {
                newToDo.checkBox = false
            } else if checkBox.image(for: UIControlState.normal) == checkedBox {
                newToDo.checkBox = true
            }
            if day == todayDate {
                newToDo.date = Int32(day)
                newToDo.month = Int32(month)
            } else if day > todayDate || month > todayMonth || year > todayYear {
                newToDo.date = Int32(day)
                newToDo.month = Int32(month)
            } else if day < todayDate || month < todayMonth || year < todayYear {
                newToDo.date = Int32(day)
                newToDo.month = Int32(month)
            }
            
            
            CoreDataHelper.savetoDo()
        }
        
        listToDoDelegate?.updatetoDos()
       
        dismiss(animated: true, completion: nil)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? DeadlineViewController {
            destination.deadlineDelegate = self
        }
    }
    func acceptData(Date: String) {
        deadlineTime = Date
        deadline.text = deadlineTime
    }
    
    @IBAction func checkBoxTapped(_ sender: Any) {
        if checkBox.image(for: UIControlState.normal) == emptyBox {
            maybeCheckedBox = true
            checkBox.setImage(checkedBox, for: UIControlState.normal)
        } else if checkBox.image(for: UIControlState.normal) == checkedBox {
            maybeCheckedBox = false
            checkBox.setImage(emptyBox, for: UIControlState.normal)
        }
    }
    
    
    
    
}
